
local M = class("GameDeskManager")

local GameConfigManager         = require ("app.scenes.gamedesk.GameConfigManager")
local EventConfig               = require ("app.config.EventConfig")

function M:ctor()
    self.DeskManager = nil
    self.nGameID = nil
    self.Music = require("app.music.AudioManager"):create()
end

function M:initGame()
    self.nGameID = G_Data.gameid
    if self.nGameID == nil or self.nGameID == 0 then
        return
    end
    G_MsgDefine.register_mod("app.scenes.gamedesk."..self.nGameID..".msg.msg")
	G_Pbc:register_file("app.scenes.gamedesk."..self.nGameID..".msg.pb")
    cc.exports.G_GameDefine = require("app.scenes.gamedesk."..self.nGameID..".GameDefine"):create()
    cc.exports.G_GamePlayer = require("app.scenes.gamedesk."..self.nGameID..".GamePlayer"):create()

    local tPlist = GameConfigManager.tPlist[self.nGameID]
    if tPlist ~= nil and next(tPlist) ~= nil then
        G_CommonFunc:resAsyncLoad(tPlist,function()
            self.DeskManager = require("app.scenes.gamedesk."..self.nGameID..".game.GameDeskScene"):create()
            display.runScene(self.DeskManager, nil, 0, display.COLOR_WHITE)
        end)
    else
        self.DeskManager = require("app.scenes.gamedesk."..self.nGameID..".game.GameDeskScene"):create()
        display.runScene(self.DeskManager, nil, 0, display.COLOR_WHITE)
    end
end

function M:clearGame(error)
    cc.exports.G_GameDefine = nil
    cc.exports.G_GamePlayer = nil
    self.DeskManager:handlerClose(error)
    self.DeskManager = nil
end

function M:enterGame()
    -- 加入主角
    if not G_Data.bReplay then
        local tUserInfo = {}
	    tUserInfo.userid = G_Data.UserBaseInfo.userid
	    tUserInfo.szNickName = G_Data.UserBaseInfo.nickname
	    tUserInfo.sex = G_Data.UserBaseInfo.sex
	    tUserInfo.ip = G_Data.UserBaseInfo.ip
	    tUserInfo.headimgurl = G_Data.UserBaseInfo.headimgurl
	    G_GamePlayer:addPlayerInfo(tUserInfo, true)
    end
    -- 请求场景消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.GameSceneReq", {})
end

-- 进入游戏请求
function M:EnterGameReq(reconnect)
    local msg = 
    {
		userid = G_Data.UserBaseInfo.userid,
		roomid = G_Data.roomid, 
		ticket = G_Data.ticket,
		reconnect = reconnect,
        latitude = G_Data.latitude,
        longitude = G_Data.longitude,
        adds  = G_Data.adds
	}
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.EnterGameReq", msg)
end

function M:netEvent_Connected(event)

end

function M:netEvent_getMsg(name, msg)
    if self.nGameID == nil then
        return
    end

    -- 进入游戏回复
    if name == "protocol.EnterGameAck" then
        -- 进入游戏失败
        if msg.err == 0 then
            self:enterGame()
        else
            self:clearGame(msg.err)
        end
        return
    end

    if self.DeskManager == nil then
        return
    end
    if self.DeskManager.handleMessage then 
        self.DeskManager:handleMessage(name, msg)
    end 
end

-- 掉线了
function M:netEvent_offline()
    if self.DeskManager == nil then
        return
    end

	self.DeskManager:handle_Offline()
end

return M