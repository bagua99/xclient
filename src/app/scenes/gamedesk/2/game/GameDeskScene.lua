
local M = class("GameDeskScene", G_BaseScene)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameDeskLayer             = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".game.GameDeskLayer")
local GameEndLayer              = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".game.GameEndLayer")
local GameTotalEndLayer         = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".game.GameTotalEndLayer")
local GameCardManager           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".card.GameCardManager")

local EventConfig               = require ("app.config.EventConfig")

-- 创建
function M:onCreate()
	self.map_music = {}
    self.nTotalGameCount = 0
    self.nCurGameCount = 0
    self.nRoomID = 0
    self.pGameBalance = nil
    self.pGameOneOver = nil
	self.bDisovleGame = false
    self.nUserCount = G_GameDefine.nMaxPlayerCount
    self.wLastOutUser = 0
    self.wCurrentUser = 0
    self.tOutCardData = {}
    self.nOutCardCount = 0
    self.bEnd = false
    self.ullMasterID = 0
    self.tRoomInfo = {}

    self.isTotalConclude = false
    self.isShow = false  

    G_GameDefine.nGameStatus = G_GameDefine.game_free

	self.m_pGameEnd = nil
	self.m_pGameGameTotalEnd = nil

	cc.exports.G_DeskScene = self

    self:initView()
end

-- 初始视图
function M:initView()
    if not G_Data.bReplay then
		local tUserInfo = {}
		tUserInfo.userid = G_Data.UserBaseInfo.userid
		tUserInfo.nickname = G_Data.UserBaseInfo.nickname
		tUserInfo.sex = G_Data.UserBaseInfo.sex
		tUserInfo.ip = G_Data.UserBaseInfo.ip
		tUserInfo.headimgurl = G_Data.UserBaseInfo.headimgurl
		G_GamePlayer:addPlayerInfo(tUserInfo, true)
	end

	cc.SpriteFrameCache:getInstance():addSpriteFrames("Common/douniu/Game.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("Common/douniu/result.plist")

	--桌面
	self.GameDeskLayer = GameDeskLayer.create()
	self:addChild(self.GameDeskLayer)

	--游戏牌管理类
	self.GameCardManager = GameCardManager.create()
	self:addChild(self.GameCardManager)
end

-- 场景进入
function M:onEnter()
	local music = "Music/"..GameConfigManager.tGameID.NN.."/nn_bg.mp3"
    G_Data.music = music
    G_GameDeskManager.Music:playBackMusic(music, true)

    if not G_Data.bReplay then
        self:sendEnterGameReq()
    else
        -- 处理回放
    end
end

-- 场景退出
function M:onExit()
    -- 停止音乐
    G_GameDeskManager.Music:stopBackMusic()

    cc.exports.G_DeskScene = nil

	G_Data.roomid = 0
	
	G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
end

-- 进入房间错误
function M:handleEnterError(iError)
	local curLayer = G_WarnLayer.create()
   	curLayer:setTypes(1)
    self:addChild(curLayer)
    if iError == 0 then
    	curLayer:setTips("未找到该房间!")
    elseif iError == 1 then
    	curLayer:setTips("游戏刚结束!")
    elseif iError == 2 then
    	curLayer:setTips("该房间座位已满!")
    else
    	curLayer:setTips("未知的错误"..iError)
    end
end

-- 处理消息
function M:handleMessage(name, msg)
    if name == "protocol.ChatAck" then
        self:handleChatAck(msg)
    elseif name == "protocol.HeartBeatAck" then
    elseif name == "nn.GAME_GameLeaveAck" then
		self:handleGameLeaveAck(msg)
	elseif name == "nn.GAME_GameVoteAck" then
		self:handleGameVoteAck(msg)
	elseif name == "nn.GAME_GameVoteResultAck" then
		self:handleGameVoteResultAck(msg)
    elseif name == "nn.GAME_PlayerEnterAck" then
        self:handlePlayerEnterAck(msg)
    elseif name == "nn.GAME_PlayerLeaveAck" then
		self:handlePlayerLeaveAck(msg)
    elseif name == "nn.GAME_EnterGameAck" then
		self:handleEnterGameAck(msg)
	elseif name == "nn.GAME_GameSceneAck" then
		self:handleSceneAck(msg)
    elseif name == "nn.GAME_ReadyAck" then
		self:handleReadyAck(msg)
	elseif name == "nn.GAME_GameStartAck" then
		self:handleGameStartAck(msg)
    elseif name == "nn.GAME_CallScoreAck" then
        self:handleCallScoreAck(msg)
    elseif name == "nn.GAME_BeginBankAck" then
        self:handleBeginBankAck(msg)
    elseif name == "nn.GAME_GameBankAck" then
        self:handleGameBankAck(msg) 
	elseif name == "nn.GAME_GameEndAck" then
		self:handleGameEndAck(msg)
    elseif name == "nn.GAME_GameTotalEndAck" then
		self:handleGameTotalEndAck(msg)
    else
        print("error reve="..name)
	end
end

-- 发送进入游戏请求
function M:sendEnterGameReq()
    if G_Data.bReplay then
        return
    end

    if G_Data.roomid <= 0 then
        return
    end

	local msg = {
		userid = G_Data.UserBaseInfo.userid,
		roomid = G_Data.roomid, 
		ticket = G_Data.ticket,
		reconnect = false
	}
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.EnterGameReq", msg)
end

-- 默认聊天
function M:handleChatAck(msg)
    -- 桌子层消息处理
    self.GameDeskLayer:handleChatAck(msg)
end

-- 解散
function M:handleGameLeaveAck(msg)
    -- 桌子层消息处理
    self.GameDeskLayer:handleGameLeaveAck(msg)
end

-- 投票
function M:handleGameVoteAck(msg)
    -- 桌子层消息处理
    self.GameDeskLayer:handleGameVoteAck(msg)
end

-- 解散结果
function M:handleGameVoteResultAck(msg)
    if msg.nResult == 1 then
		local strInfo = ""
		for nIndex, tInfo in ipairs(msg.voteResult) do
			local _player = G_GamePlayer:getPlayerBySeverSeat(tInfo.nSeat)
			if _player and tInfo.nVoteState == 1 then
				strInfo = strInfo.."[".._player["nickname"].."]"
			end
		end

		local strShow = string.format("经玩家%s同意，房间解散成功", strInfo)
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self, self.showGameTotalEnd))
        self:addChild(curLayer)

        self.bDisovleGame = true
	else
		local strInfo = ""
        for nIndex, tInfo in ipairs(msg.voteResult) do
			local _player = G_GamePlayer:getPlayerBySeverSeat(tInfo.nSeat)
			if _player and tInfo.nVoteState == 2 then
				strInfo = strInfo.."[".._player["nickname"].."]"
			end
		end
		local strShow = string.format("由于玩家%s拒绝，房间解散失败，游戏继续", strInfo)
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        self:addChild(curLayer)
	end

    -- 桌子层消息处理
    self.GameDeskLayer:handleGameVoteResultAck(msg)
end

-- 新玩家
function M:handlePlayerEnterAck(msg)
    -- 增加玩家
	G_GamePlayer:addPlayerInfo(msg.userData)

    -- 桌子层处理
    self.GameDeskLayer:handlePlayerEnterAck(msg)
end

-- 玩家离开
function M:handlePlayerLeaveAck(msg)
    -- 桌子层处理
    self.GameDeskLayer:handlePlayerLeaveAck(msg)
end

-- 进入游戏消息
function M:handleEnterGameAck(msg)
    -- 进入房间失败
	if msg.err ~= 0 then
		self:handleEnterError(msg.err)
		return
	end

	G_GameDefine.nPlayerCount = #msg.players
    self.nUserCount = #msg.players

	G_GameDefine.nGameCount = 0
	G_GameDefine.nGameStatus = 0
	G_GameDefine.nTotalGameCount = 15
    self.ullMasterID = 1
	
	for _,p in ipairs(msg.players) do
		G_GamePlayer:addPlayerInfo(p, p.userid == G_GamePlayer:getMainPlayer().userid)
	end

    -- 桌子层消息处理
    self.GameDeskLayer:handleEnterGameAck(msg)
	
	for _,p in ipairs(msg.players) do
		self.GameDeskLayer:showPlayer(p.seat, p)
	end

	G_GameDefine.nPlayerCount = G_GamePlayer:getPlayerCount()
end

-- 场景消息
function M:handleSceneAck(msg)
    -- 设置游戏状态
    G_GameDefine.nGameStatus = msg.nGameStatus

    -- 桌子层消息处理
    self.GameDeskLayer:handleSceneAck(msg)
end

-- 准备消息
function M:handleReadyAck(msg)
    -- 回放不处理
    if G_Data.bReplay then
        return   
    end
    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if nServerSeat == msg.wChairID then
        -- 清除结束牌
        self.GameCardManager:clearShowEndCard(G_GameDefine.nMaxPlayerCount)
    end

    -- 桌子层消息处理
    self.GameDeskLayer:handleReadyAck(msg)
end

function M:handleGameStartAck(msg)
    -- 更新游戏状态
    G_GameDefine.nGameStatus = G_GameDefine.game_play

    -- 清除牌数据
    self.GameCardManager:restore()

    -- 隐藏结算界面
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
    self.m_pGameEnd = nil

    -- 桌子层消息处理
    self.GameDeskLayer:handleGameStartAck(msg)
end

-- 下注消息
function M:handleCallScoreAck(msg)
    -- 桌子层消息处理
    self.GameDeskLayer:handleCallScoreAck(msg)
end

-- 开始抢庄消息
function M:handleBeginBankAck(msg)
    -- 桌子层消息处理
    self.GameDeskLayer:handleBeginBankAck(msg)
end

-- 抢庄消息
function M:handleGameBankAck(msg)
    -- 桌子层消息处理
    self.GameDeskLayer:handleGameBankAck(msg)
end

function M:handleGameEndAck(msg)
	self.tInfo = msg
	local i = 0
	local size = table.getn(msg.infos)
    --一家一家翻牌
    local func
    table.sort(msg.infos,function( a,b )
        -- body
        local nLocalSeata = G_GamePlayer:getLocalSeat(a.seat)
        local nLocalSeatb = G_GamePlayer:getLocalSeat(b.seat)
        return nLocalSeata < nLocalSeatb
    end)
    func = function( i )
    	-- body
    	if i==size+1 then 
    		return 
    	end
    	local info = msg.infos[i] 
    	local nLocalSeat = G_GamePlayer:getLocalSeat(info.seat)
        local call = nil 
        if i==size then 
        	call = handler(self,self.showConclude)
        end
        local callFinish = function(  )
        	-- body
        	i = i + 1
        	func(i) 
        end
        self.GameCardManager:createShowEndCard(nLocalSeat, info.cards,5,info.type,info.seat,callFinish,call)
    end
    func(1)
end

function M:showConclude()
	-- body
	-- 不是解散，显示结算
	local tInfo = self.tInfo
    if not self.bDisovleGame then
	    if self.m_pGameEnd == nil then
	    	--延时5s播放
	    	self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function()
	    		-- body
	    		self.m_pGameEnd = GameEndLayer.create()
		    	self:addChild(self.m_pGameEnd)
		    	self.m_pGameEnd:GameEndAck(G_GameDefine.nGameCount, G_GameDefine.nTotalGameCount, tInfo,self.isTotalConclude)
	    	end)))
        else
            self.m_pGameEnd:GameEndAck(G_GameDefine.nGameCount, G_GameDefine.nTotalGameCount, tInfo)
	    end

        G_GameDefine.nGameCount = G_GameDefine.nGameCount + 1
    end
    -- 桌子层消息处理
    self.GameDeskLayer:handleGameEndAck(tInfo)
end

-- 总结算信息
function M:handleGameTotalEndAck(tInfo)
    if self.m_pGameGameTotalEnd == nil then
        self.m_pGameGameTotalEnd = GameTotalEndLayer:create()
        self.m_pGameGameTotalEnd:GameTotalEndAck(tInfo)
        self.m_pGameGameTotalEnd:setVisible(self.isShow)
        self:addChild(self.m_pGameGameTotalEnd, 101)
		--设置总结算的标示  true
		self.isTotalConclude = true 
    end
end

-- 显示总结算
function M:showGameTotalEnd()
    if self.m_pGameGameTotalEnd ~= nil then
        self.m_pGameGameTotalEnd:setVisible(true)
    end
end

-- 游戏重置
function M:Action_Restart(byAgree)
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
	self.m_pGameEnd = nil

	G_GameDefine.nGameStatus = G_GameDefine.game_free

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if byAgree == 1 then
        -- 发送准备
        self.GameDeskLayer:Click_Ready()
    else
        -- 设置准备按钮
        self.GameDeskLayer:SetReadyBtn(false,true)
    end
end

function M:showEmptyCard()
	self.GameCardManager:showEmptyCard()
end

return M
