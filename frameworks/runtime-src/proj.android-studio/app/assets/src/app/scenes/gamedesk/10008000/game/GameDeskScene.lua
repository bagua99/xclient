
local GameDeskScene = class("GameDeskScene", G_BaseScene)

local GameLeaveNoticeLayer      = require("app.scenes.lobby.common.GameLeaveNoticeLayer")
local GameDisbandApplyLayer     = require("app.scenes.lobby.common.GameDisbandApplyLayer")
local GameDisbandNoticeLayer    = require("app.scenes.lobby.common.GameDisbandNoticeLayer")
local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameDeskLayer             = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".game.GameDeskLayer")
local GameEndLayer              = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".game.GameEndLayer")
local GameTotalEndLayer         = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".game.GameTotalEndLayer")
local GameCardManager           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".card.GameCardManager")
local ByteArray                 = require("componentex.ByteArray")


function GameDeskScene:onCreate()

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
    self.nGameDisbandNoticeTAG = 100
    self.nGameDisbandApplyTAG = 110

    G_GameDefine.nGameStatus = GS_GAME_FREE

	self.m_pGameEnd = nil
	self.m_pGameGameTotalEnd = nil

	cc.exports.G_DeskScene = self

    self:initView()
end

function GameDeskScene:initView()

    if not G_GameDefine.bReplay then
		local tUserInfo = {}
		tUserInfo.ullUserID = G_Data.UserBaseInfo.userid
		tUserInfo.szNickName = G_Data.UserBaseInfo.nickname
		tUserInfo.sex = G_Data.UserBaseInfo.sex
		tUserInfo.ip = G_Data.UserBaseInfo.ip
		tUserInfo.imgurl = G_Data.UserBaseInfo.headimgurl
		G_GamePlayer:addPlayerInfo(tUserInfo, true)
	end

    self.msg_recordOver = G_CommonFunc:addEvent("UserRecordOver", handler(self,self.msg_recordOver))

	cc.SpriteFrameCache:getInstance():addSpriteFrames(GameConfigManager.tGameID.NN.."/GameDesk/Game.plist")
	--桌面
	self.GameDeskLayer = GameDeskLayer.create()
	self:addChild(self.GameDeskLayer)

	--游戏牌管理类
	self.GameCardManager = GameCardManager.create()
	self:addChild(self.GameCardManager)
	--离开通知
	self.GameLeaveNoticeLayer = GameLeaveNoticeLayer.create()
	self.GameLeaveNoticeLayer:setVisible(false)
	self:addChild(self.GameLeaveNoticeLayer)

	self.infoLayer = display.newLayer()
	self:addChild(self.infoLayer)
end

-- 场景进入
function GameDeskScene:onEnter()

    -- 播放音乐
    G_GameDeskManager.Music:playBackMusic("BACK_MUSIC.mp3", true)

    if not G_GameDefine.bReplay then

        -- 发送进入游戏请求
        self:sendEnterGameReq()
    else

        -- 处理回放
    end
end

-- 场景退出
function GameDeskScene:onExit()

    -- 停止音乐
    G_GameDeskManager.Music:stopBackMusic()

    cc.exports.G_DeskScene = nil

	G_Data.roomid = 0
	G_Data.CL_JoinGameAck.roomid = 0
	
	G_CommonFunc:removeEvent(self.msg_recordOver)
	G_NetManager:disconnect(NETTYPE_GAME)
end

-- 进入房间错误
function GameDeskScene:handleEnterError(iError)

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

function GameDeskScene:handleMessage(event)
    -- event  msgName, msgID, msgLen, msgData

    if event.msgName == "GAME_HeartBeatAck" then
    elseif event.msgName == "GAME_ChatAck" then
		self:handleChatAck(event)
    elseif event.msgName == "GAME_DefaultChatAck" then
        self:handleDefaultChatAck(event)
    elseif event.msgName == "GAME_LeaveGameAck" then
        self:handleLeaveGameAck(event)
    elseif event.msgName == "GAME_DissolveGameAck" then
		self:handleDissolveGameAck(event)
	elseif event.msgName == "GAME_DissolveGameVoteAck" then
		self:handleDissolveGameVoteAck(event)
	elseif event.msgName == "GAME_DissolveGameVoteResultAck" then
		self:handleDissolveGameVoteResultAck(event)
    elseif event.msgName == "GAME_ReadyAck" then
		self:handleReadyAck(event)
    elseif event.msgName == "GAME_NewPlayerAck" then
		self:handleNewPlayerAck(event)
    elseif event.msgName == "GAME_EnterGameAck" then
		self:handleEnterGameAck(event)
	elseif event.msgName == "GAME_GameSceneAck" then
		self:handleSceneAck(event)
	elseif event.msgName == "GAME_GameStartAck" then
		self:handleGameStartAck(event)
    elseif event.msgName == "GAME_CallScoreAck" then
        self:handleCallScoreAck(event)
    elseif event.msgName == "GAME_BeginBankAck" then
        self:handleBeginBankAck(event)
    elseif event.msgName == "GAME_GameBankAck" then
        self:handleGameBankAck(event) 
	elseif event.msgName == "GAME_GameEndAck" then
		self:handleGameEndAck(event)
    elseif event.msgName == "GAME_GameTotalEndAck" then
		self:handleGameTotalEndAck(event)
    else
        print("error reve="..event.msgName)
	end
end

function GameDeskScene:msg_recordOver()
	--G_NetManager:sendFileFunc("RecordFile.mp3")
end

-- 发送进入游戏请求
function GameDeskScene:sendEnterGameReq()

    -- 回放不处理
    if G_GameDefine.bReplay then
        return
    end

    if G_Data.CL_JoinGameAck.roomid <= 0 then
        return
    end

	G_Data.GAME_EnterGameReq = {}
    G_Data.GAME_EnterGameReq.ullUserID = G_Data.UserBaseInfo.userid
    G_Data.GAME_EnterGameReq.ullRoomID = G_Data.CL_JoinGameAck.roomid 
    G_Data.GAME_EnterGameReq.szTicket = G_Data.CL_JoinGameAck.ticket
    G_Data.GAME_EnterGameReq.bReconnect = 0
    G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_EnterGameReq")
end

----------------------------------------------------------------------------
-- 解析数据包获取游戏数据
function GameDeskScene:handleGetGameData(event)

    -- 非游戏消息处理
    if event.msgID < ID_BASEGAMELOGIC then
        return
    end

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]
    if tMsg == nil then
        release_print("handleGetGameData no find event.msgID "..event.msgID)
        return
    end

    local tMsgName = string.split(tMsg["MsgName"],"|")
    G_Data[tMsgName[1]] = {}
    G_GameDeskManager:writeGameRecvMsg(G_Data[tMsgName[1]], event.msgData, tMsg)

    if event.msgID ~= ID_BASEGAMELOGIC + 0x1000 then
        release_print("handleGetGameData "..tMsgName[1])
    end
end

-- 聊天回复
function GameDeskScene:handleChatAck(event)

end

-- 默认聊天回复
function GameDeskScene:handleDefaultChatAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_DefaultChatAck

    -- 桌子层消息处理
    self.GameDeskLayer:handleDefaultChatAck(tInfo)
end

-- 玩家离开游戏
function GameDeskScene:handleLeaveGameAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_LeaveGameAck

    -- 桌子层消息处理
    self.GameDeskLayer:handleLeaveGameAck(tInfo)
end

-- 玩家投票结果
function GameDeskScene:handleDissolveGameAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_DissolveGameAck
    
	local nCurSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
	if nCurSeat == 1 then
		return
	end
	if tInfo.dwResult == 1 then
		local curLayer = GameDisbandNoticeLayer.create()
		local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(tInfo.wChairID)
		curLayer:setUserName(curPlayerInfo["szNickName"])
		self:addChild(curLayer, 10, self.nGameDisbandNoticeTAG)
	elseif tInfo.dwResult == 0 then
		G_NetManager:disconnect(NETTYPE_GAME)
		G_SceneManager:enterScene(SCENE_LOBBY)
	end
end

-- 广播投票
function GameDeskScene:handleDissolveGameVoteAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_DissolveGameVoteAck

	local nCurSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
	if nCurSeat == 1 then
		return
	end
	local curLayer = self:getChildByTag(self.nGameDisbandApplyTAG)
	if curLayer then
		curLayer:DissolveGameVoteAck(tInfo)
	end
end

-- 广播投票结果
function GameDeskScene:handleDissolveGameVoteResultAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_DissolveGameVoteResultAck
    
	local curLayer = self:getChildByTag(self.nGameDisbandApplyTAG)
	if curLayer then
		curLayer:removeFromParent()
	end

	local curLayer2 = self:getChildByTag(self.nGameDisbandNoticeTAG)
	if curLayer2 then
		curLayer2:removeFromParent()
	end
	if tInfo.dwResult == 0 then
		local strInfo = ""
		for i=1,G_GameDefine.nPlayerCount do
			local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i-1)
            if curPlayerInfo ~= nil then
			    strInfo = strInfo.."["..curPlayerInfo.szNickName.."]"
            end
		end

		local strShow = string.format("经玩家%s同意，房间解散成功",strInfo)
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self,self.showOneOver))
        self:addChild(curLayer)

        self.bDisovleGame = true
	else
		local strInfo = ""
		for i=1,G_GameDefine.nPlayerCount do
			local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i-1)
			if G_Data.GAME_DissolveGameVoteResultAck.bApprove[i] == 0 then
				if curPlayerInfo ~= nil then
			        strInfo = strInfo.."["..curPlayerInfo.szNickName.."]"
                end
				break
			end
		end
		local strShow = string.format("由于玩家%s拒绝，房间解散失败，游戏继续",strInfo)
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        self:addChild(curLayer)
	end
end

-- 准备消息
function GameDeskScene:handleReadyAck(event)

    -- 回放不处理
    if G_GameDefine.bReplay then
        return   
    end

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_ReadyAck

    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if nServerSeat == tInfo.wChairID then
        -- 清除结束牌
        self.GameCardManager:clearShowEndCard(G_GameDefine.nMaxPlayerCount)
    end

    -- 桌子层消息处理
    self.GameDeskLayer:handleReadyAck(tInfo)
end

-- 新玩家信息
function GameDeskScene:handleNewPlayerAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_NewPlayerAck
	tInfo.UserGameData.seat = tInfo.wChairID

	G_GamePlayer:addPlayerInfo(tInfo.UserGameData)

	if self.GameLeaveNoticeLayer:getPeopleOffline() > 0 then
		if G_GameDefine.nGameCount >= 1 then
			self.GameLeaveNoticeLayer:setVisible(true)
			self.GameLeaveNoticeLayer:showOnline(tInfo.UserGameData.szNickName)
		end
	end

    -- 桌子层消息处理
    self.GameDeskLayer:handleNewPlayerAck(tInfo)
end

-- 进入游戏消息
function GameDeskScene:handleEnterGameAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_EnterGameAck

    -- 进入房间失败
	if tInfo.dwResult == 0 then
		self:handleEnterError(tInfo.dwErrorCode)
		return
	end

	G_GameDefine.nPlayerCount = tInfo.nPlayerCount
    self.nUserCount = tInfo.nPlayerCount

	local tUserInfo = {}
	tUserInfo.seat = tInfo.wChairID
	tUserInfo.ullUserID = G_GamePlayer:getMainPlayer().ullUserID
	G_GamePlayer:addPlayerInfo(tUserInfo,true)

	G_GameDefine.nGameCount = tInfo.nCurGameCount
	G_GameDefine.nGameStatus = tInfo.nGameStatus
	G_GameDefine.nTotalGameCount = tInfo.nTotalGameCount
    self.ullMasterID = tInfo.ullMasterID
	
	for i=1,#tInfo.UserGameData do
		if tInfo.UserGameData[i].ullUserID ~= 0 and tInfo.UserGameData[i].ullUserID ~= G_GamePlayer:getMainPlayer().ullUserID then
			tInfo.UserGameData[i].seat = i-1
			G_GamePlayer:addPlayerInfo(tInfo.UserGameData[i])
		end
	end

    -- 桌子层消息处理
    self.GameDeskLayer:handleEnterGameAck(tInfo)
end

-- 场景消息
function GameDeskScene:handleSceneAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_GameSceneAck

	for i=1, G_GameDefine.nMaxPlayerCount do
		if tInfo.arrUserID[i] == 0 then
            if i > G_GameDefine.nPlayerCount then
                -- 隐藏头像信息self.GameAvatarLayer:setGameAvatar(i-1, false)
            end
        else
			local playerInfo = G_GamePlayer:getPlayerByUserId(tInfo.arrUserID[i]) 
			if playerInfo == nil then
				local curPlayerInfo = {}
				curPlayerInfo.ullUserID = tInfo.arrUserID[i]
				curPlayerInfo.seat = i-1
                curPlayerInfo.ip = "离线"
				curPlayerInfo.szNickName = tInfo.arrNickName[i]
				curPlayerInfo.imgurl = tInfo.arrImgUrl[i]
                curPlayerInfo.sex = 0
				G_GamePlayer:addPlayerInfo(curPlayerInfo)
            else
                local curPlayerInfo = {}
				curPlayerInfo.ullUserID = tInfo.arrUserID[i]
				curPlayerInfo.seat = i-1
                curPlayerInfo.ip = playerInfo.ip
				curPlayerInfo.szNickName = tInfo.arrNickName[i]
				curPlayerInfo.imgurl = tInfo.arrImgUrl[i]
                curPlayerInfo.sex = tInfo.sex
				G_GamePlayer:addPlayerInfo(curPlayerInfo)
			end
		end
	end

    self.wLastOutUser = tInfo.wLastOutUser
    self.wCurrentUser = tInfo.wCurrentUser
    self.tOutCardData = tInfo.cbTurnCardData
    self.nOutCardCount = tInfo.cbTurnCardCount

    -- 设置房间信息
    self.tRoomInfo = tInfo.RoomInfo
    -- 设置游戏状态
    G_GameDefine.nGameStatus = tInfo.dwGameStatus

    -- 投票相关
	if tInfo.dwGameStatus == GS_GAME_VOTE then
		if tInfo.wDissoveUser == -1 then
		else
			local nDisSeat = G_GamePlayer:getLocalSeat(tInfo.wDissoveUser)
			if nDisSeat == 1 then
				local curLayer = GameDisbandApplyLayer.create()
				self:addChild(curLayer, 10, self.nGameDisbandApplyTAG)
				for i=1, G_GameDefine.nPlayerCount do
					curLayer:refreshUserName(tInfo.arrNickName[i],i-1,tInfo.bVoteStatus[i],tInfo.bVoteNote[i])
				end
			else
                -- 取解析的table索引是从1开始,要加1
				local nCurServerSeat = G_GamePlayer:getServerSeat(1)
				local curPlayer = G_GamePlayer:getPlayerBySeverSeat(nCurServerSeat)
				if tInfo.bVoteStatus[nCurServerSeat+1] == 0 then
					local gdnoticeLayer = GameDisbandNoticeLayer.create()
					gdnoticeLayer:setUserName(curPlayer.szNickName)
					self:addChild(gdnoticeLayer, 10, self.nGameDisbandNoticeTAG)
				end
			end
		end
    else
        local gameDisbandNoticeTAG = self:getChildByTag(self.nGameDisbandNoticeTAG)
        if gameDisbandNoticeTAG ~= nil then
            gameDisbandNoticeTAG:removeFromParent()
        end

        local gameDisbandApplyTAG = self:getChildByTag(self.nGameDisbandApplyTAG)
        if gameDisbandApplyTAG ~= nil then
            gameDisbandApplyTAG:removeFromParent()
        end
	end

    -- 桌子层消息处理
    self.GameDeskLayer:handleSceneAck(tInfo)
end

function GameDeskScene:handleGameStartAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_GameStartAck

    -- 更新游戏状态
    G_GameDefine.nGameStatus = GS_GAME_PLAY

    -- 清除牌数据
    self.GameCardManager:restore()

    -- 隐藏结算界面
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
    self.m_pGameEnd = nil

    -- 桌子层消息处理
    self.GameDeskLayer:handleGameStartAck(tInfo)
end

-- 下注消息
function GameDeskScene:handleCallScoreAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_CallScoreAck

    -- 桌子层消息处理
    self.GameDeskLayer:handleCallScoreAck(tInfo)
end

-- 开始抢庄消息
function GameDeskScene:handleBeginBankAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_BeginBankAck

    -- 桌子层消息处理
    self.GameDeskLayer:handleBeginBankAck(tInfo)
end

-- 抢庄消息
function GameDeskScene:handleGameBankAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_GameBankAck

    -- 桌子层消息处理
    self.GameDeskLayer:handleGameBankAck(tInfo)
end

function GameDeskScene:handleGameEndAck(event)
	
    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_GameEndAck

    for i=1, G_GameDefine.nMaxPlayerCount do
        -- 创建显示结束牌
        local nLocalSeat = G_GamePlayer:getLocalSeat(i-1)
        self.GameCardManager:createShowEndCard(nLocalSeat, tInfo.cbCardData[i], G_GameDefine.nCardCount)
    end

    -- 不是解散，显示结算
    if not self.bDisovleGame then
	    if self.m_pGameEnd == nil then
		    self.m_pGameEnd = GameEndLayer.create()
		    self:addChild(self.m_pGameEnd)
		    self.m_pGameEnd:GameEndAck(G_GameDefine.nGameCount, G_GameDefine.nTotalGameCount, tInfo)
        else
            self.m_pGameEnd:GameEndAck(G_GameDefine.nGameCount, G_GameDefine.nTotalGameCount, tInfo)
	    end

        G_GameDefine.nGameCount = G_GameDefine.nGameCount + 1
    end

    -- 桌子层消息处理
    self.GameDeskLayer:handleGameEndAck(tInfo)
end

-- 总结算信息
function GameDeskScene:handleGameTotalEndAck(event)

    local tMsg = G_GameDeskManager.DeskManager.Protocol.res_protocol[event.msgID]["protocol"]
    if tMsg == nil then
        release_print("no find event.msgID "..event.msgID)
        return
    end

    local nMsgLen = G_GameDeskManager:getMsgLen(tMsg)
    if nMsgLen ~= event.msgLen then
        release_print("nLen != nMsgLen, msgName="..event.msgName..",nMsgLen="..nMsgLen..",msgLen="..event.msgLen)
        return
    end

    -- 解析数据包获取游戏数据
    self:handleGetGameData(event)

    local tInfo = G_Data.GAME_GameTotalEndAck

    if self.m_pGameGameTotalEnd == nil then
        self.m_pGameGameTotalEnd = GameTotalEndLayer:create()
        self.m_pGameGameTotalEnd:GameTotalEndAck(tInfo)
        self.m_pGameGameTotalEnd:setVisible(false)
        self:addChild(self.m_pGameGameTotalEnd, 101)
    end
end

-- 显示总结算
function GameDeskScene:showOneOver()

    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
	self.m_pGameEnd = nil

	if self.m_pGameGameTotalEnd then
		self.m_pGameGameTotalEnd:addTouch()
		self.m_pGameGameTotalEnd:setVisible(true)
	else
		G_NetManager:disconnect(NETTYPE_GAME)
		G_SceneManager:enterScene(SCENE_LOBBY)
	end
end

-- 游戏重置
function GameDeskScene:Action_Restart(byAgree)

    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
	self.m_pGameEnd = nil

	G_GameDefine.nGameStatus = GS_GAME_FREE

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if byAgree == 1 then
        -- 发送准备
        self.GameDeskLayer:Click_Ready()
    else
        -- 设置准备按钮
        self.GameDeskLayer:SetReadyBtn(0, true)
    end
end

return GameDeskScene
