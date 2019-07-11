
local MainLayer             = require("app.scenes.lobby.MainLayer")
local JoinRoomLayer         = require("app.scenes.lobby.JoinRoomLayer")

local LobbyScene = class("LobbyScene",G_BaseScene)

function LobbyScene:onCreate()

    local curLayer = MainLayer.create()
    self:addChild(curLayer) 

    self.JoinRoomLayer = JoinRoomLayer.create()
    self.JoinRoomLayer:setVisible(false)
    self:addChild(self.JoinRoomLayer)
end


function LobbyScene:handleMsg(event)
	
	if event.msgName == "CL_JoinGameAck" then
        dump(G_Data.CL_JoinGameAck)
		if G_Data.CL_JoinGameAck.dwResult == 1 then
			G_NetManager:connectGame(G_Data.CL_JoinGameAck.ip ,G_Data.CL_JoinGameAck.port,handler(self,self.connectOk),handler(self,self.connectFailed))
		else
			local curLayer = G_WarnLayer.create()
            curLayer:setTips("加入房间失败")
            curLayer:setTypes(1)
            self:addChild(curLayer)
		end
	end
end


function LobbyScene:connectOk()

    if G_Data.CL_JoinGameAck.nGameID > 0 then

        -- 进入游戏
        if G_GameDeskManager ~= nil then
	        G_GameDeskManager:enterGame()
        end
    end
end

function LobbyScene:connectFailed()
	local curLayer = G_WarnLayer.create()
    curLayer:setTips("游戏服无法连接")
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

function LobbyScene:onEnter()
    -- 断开游戏连接
    G_NetManager:disconnect(NETTYPE_GAME)

    -- 播放音乐
    G_GameDeskManager.Music:playBackMusic("BACK_MUSIC.mp3", true)

    self.target, self.event_showjoinroom = G_Event:addEventListener("showJoinRoom",handler(self,self.btn_showJoinRoom))
    self.target, self.event_handlermsg = G_Event:addEventListener("receiveMsg",handler(self,self.handleMsg))

    if G_Data.UserBaseInfo.roomid ~= 0 then
		G_Data.CL_JoinGameReq = {}
		G_Data.CL_JoinGameReq.roomid = G_Data.roomid
		G_Data.CL_JoinGameReq.mode = 1
		G_NetManager:sendMsg(NETTYPE_LOGIN,"CL_JoinGameReq")
	end
end

function LobbyScene:onExit()

     -- 停止音乐
    G_GameDeskManager.Music:stopBackMusic()

	G_Event:removeEventListener(self.event_handlermsg)
    G_Event:removeEventListener(self.event_showjoinroom)
end

function LobbyScene:btn_showJoinRoom()

	if G_Data.roomid ~= 0 then
		G_Data.CL_JoinGameReq = {}
		G_Data.CL_JoinGameReq.roomid = G_Data.roomid
		G_Data.CL_JoinGameReq.mode = 1
		G_NetManager:sendMsg(NETTYPE_LOGIN,"CL_JoinGameReq")
		return
	end
	self.JoinRoomLayer:setVisible(true)
end

return LobbyScene
