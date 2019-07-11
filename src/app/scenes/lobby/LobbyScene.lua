local M = class("LobbyScene",G_BaseScene)

local utils                     = require "utils"
local cjson 					= require("componentex.cjson")
local GameConfig                = require "app.config.GameConfig"
local EventConfig               = require ("app.config.EventConfig")
local MainLayer                 = require ("app.scenes.lobby.MainLayer")
local targetPlatform            = cc.Application:getInstance():getTargetPlatform()

function M:onCreate()
    local curLayer = MainLayer.create()
    self:addChild(curLayer) 
	self.status = "login"
end

-- 进入场景
function M:onEnter()
    -- 断开游戏连接
    G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
	self:LoginLobby()

    -- 播放音乐
    G_GameDeskManager.Music:playBackMusic("Music/BACK_MUSIC.mp3", true)

	self.target, self.event_CreateRoom = G_Event:addEventListener("sendMsg_CreateRoom", handler(self,self.CreateRoom))
	self.target, self.event_JoinRoom = G_Event:addEventListener("sendMsg_JoinRoom", handler(self,self.JoinRoom))

    --开始获取地理位置了
    self:getLocation()

    --加载共用图集
    local tPlist = {{img = "res/plist/common.png", plist = "res/plist/common.plist"}}
    G_CommonFunc:resAsyncLoad(tPlist,function()
    	-- dump("load common plist success")
    end)

end

-- 退出场景
function M:onExit()
     -- 停止音乐
    -- G_GameDeskManager.Music:stopBackMusic()
	G_Event:removeEventListener(self.event_CreateRoom)
    G_Event:removeEventListener(self.event_JoinRoom)
    G_GameDeskManager.Music:unloadSound()
end

-- 提示信息
function M:tips(str, okCall, CancelCall)
	local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    curLayer:setOkCallback(okCall)
    curLayer:setCancelCallback(CancelCall)
    self:addChild(curLayer)
end

-- 连接游戏成功
function M:connectGameOk()
    if G_Data.gameid ~= 0 then
        if G_GameDeskManager ~= nil then
            -- 设置非回放
            G_Data.bReplay = false
	        G_GameDeskManager:initGame()
        end
    end
end

-- 连接游戏失败
function M:connectGameFailed()
	self:tips("游戏服无法连接")
end

function M:LoginLobby()
	local msg = {
		account = G_Data.UserBaseInfo.account,
		userid = G_Data.UserBaseInfo.userid,
		openid = G_Data.UserBaseInfo.openid,
		nickname = G_Data.UserBaseInfo.nickname,
		sex = G_Data.UserBaseInfo.sex,
		headimgurl = utils.base64encode(G_Data.UserBaseInfo.headimgurl),
		token = G_Data.UserBaseInfo.token
	}

	G_CommonFunc:httpForJsonLobby("/login_lobby", 5, msg, handler(self, self.LoginLobbyResult), nil)
end

function M:LoginLobbyResult(msg)
	dump(msg)
	if msg.result == "success" then
		G_Data.UserBaseInfo.score = msg.score
		G_Data.UserBaseInfo.roomcard = msg.roomcard
		G_Data.UserBaseInfo.sign = msg.sign

		G_Data.gameid = msg.gameid
		G_Data.roomid = msg.roomid
		G_Data.room_ip = msg.ip
		G_Data.room_port = msg.port

		if msg.roomid ~= nil and msg.roomid ~= 0 then 
			-- 设置断线重连
			G_Data.reconnect = G_Data.gameid ~= 0
			G_NetManager:connectGame(G_Data.room_ip, G_Data.room_port, handler(self,self.connectGameOk), handler(self,self.connectGameFailed))
		else
			-- 设置非断线重连
			G_Data.reconnect = false
		end
		self.status = "normal"

        G_Event:dispatchEvent({name="Update_UserBaseInfo"})
	else
        self:tips("登录大厅失败")
	end
end

function M:CreateRoom(event)
	G_CommonFunc:httpForJsonLobby("/create_room", 5, event.msg, handler(self, self.CreateRoomResult), handler(self, self.CreateRoomTimeout))
	G_CommonFunc:loading("创建房间中...",self)
end

function M:CreateRoomResult(msg)
    G_CommonFunc:dismissLoading()
	-- 设置非断线重连
	G_Data.reconnect = false
	G_Data.roomid = msg.roomid
	G_Data.gameid = msg.gameid
	G_Data.room_ip = msg.ip
	G_Data.room_port = msg.port
	if msg.result == "success" then
		G_NetManager:connectGame(G_Data.room_ip, G_Data.room_port, handler(self,self.connectGameOk), handler(self,self.connectGameFailed))
	else
        if msg.result == "relogin" then
            self:tips("需要重新登录游戏", handler(self,self.startGame))
        elseif msg.result == "sign fail" then
            self:tips("需要重新登录游戏", handler(self,self.startGame))
        elseif msg.result == "roomcard fail" then
            self:tips("房卡不足,创建房间失败")
        elseif msg.result == "game not find" then
            self:tips("不存在此游戏,创建房间失败")
        elseif msg.result == "gameserver not find" then
            self:tips("游戏服务器未启动,创建房间失败")
        else
            if G_Data.roomid and G_Data.roomid ~= 0 then
			    self:tips("当前正在房间中，请点击加入房间")
		    else
				self:tips("创建房间失败")
		    end
        end
	end
end

-- 创建房间超时
function M:CreateRoomTimeout()
	G_CommonFunc:dismissLoading()
	
end

function M:JoinRoom(event)
	G_CommonFunc:httpForJsonLobby("/join_room", 5, event.msg, handler(self, self.JoinRoomResult), handler(self, self.JoinRoomTimeout))
	G_CommonFunc:loading("加入房间中...",self)
end

function M:JoinRoomResult(msg)
	-- 设置非断线重连
	G_CommonFunc:dismissLoading()
	G_Data.reconnect = false
	if msg.result == "success" then
		G_Data.roomid = msg.roomid
		G_Data.gameid = msg.gameid
		G_Data.room_host = msg.host
		G_Data.room_ip = msg.ip
		G_Data.room_port = msg.port

		if not msg.roomid or msg.roomid == 0  then 
			self:tips("此房间不存在")
			G_Event:dispatchEvent({name="sendMsg_clearInputNumber",msg={}})
			return 
		end 
		G_NetManager:connectGame(G_Data.room_ip, G_Data.room_port, handler(self,self.connectGameOk), handler(self,self.connectGameFailed))
    elseif msg.result == "relogin" then
		self:tips("需要重新登录游戏", handler(self,self.startGame))
    elseif msg.result == "sign fail" then
		self:tips("需要重新登录游戏", handler(self,self.startGame))
	elseif msg.result == "room not find" then
		self:tips("此房间不存在,加入房间失败")
    elseif msg.result == "game begin" then
        self:tips("游戏已开始,加入房间失败")
    elseif msg.result == "player full" then
        self:tips("房间人数已满,加入房间失败")
    else
        self:tips("加入房间失败")
	end
    G_Event:dispatchEvent({name="sendMsg_clearInputNumber",msg={}})
end

-- 加入房间超时
function M:JoinRoomTimeout()
	G_CommonFunc:dismissLoading()
end

function M:getLocation()
	local getLocationFinish = function( params )
		local output = cjson.decode(params)
		local latitude = output.latitude
		local longitude = output.longitude
		local adds     = output.addr
		G_Data.latitude = latitude
		G_Data.longitude = longitude
		G_Data.adds = adds
	end
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {getLocationFinish}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/hnqp/pdkgame/AppActivity"
        local ok = luaj.callStaticMethod(className,"getLocation",args,sigs)
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then
        if EventConfig.CHECK_IOS then
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "RootViewController"
            luaoc.callStaticMethod(className, "startLocation", {scriptHandler = getLocationFinish})
        end
    end 
end

function M:startGame()
    G_CommonFunc:startGame()
end

return M
