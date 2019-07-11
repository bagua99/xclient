
local GameDeskScene = class("GameDeskScene", G_BaseScene)

local GameLeaveNoticeLayer      = require("app.scenes.lobby.common.GameLeaveNoticeLayer")
local GameDisbandApplyLayer     = require("app.scenes.lobby.common.GameDisbandApplyLayer")
local GameDisbandNoticeLayer    = require("app.scenes.lobby.common.GameDisbandNoticeLayer")
local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameDeskLayer             = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".game.GameDeskLayer")
local GameEndLayer              = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".game.GameEndLayer")
local GameTotalEndLayer         = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".game.GameTotalEndLayer")
local GameAvatarLayer           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".avatar.GameAvatarLayer")
local GameCardManager           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".card.GameCardManager")
local GameLogic                 = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".logic.GameLogic")
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
    self.tRoomInfo = {}
    self.ullMasterID = 0
    self.nGameDisbandNoticeTAG = 100
    self.nGameDisbandApplyTAG = 110

    G_GameDefine.nGameStatus = GS_GAME_FREE

	self.m_pGameEnd = nil
	self.m_pGameGameTotalEnd = nil

    self.GameLogic = GameLogic.create()

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

	cc.SpriteFrameCache:getInstance():addSpriteFrames(GameConfigManager.tGameID.PDK.."/GameDesk/Game.plist")
	--桌面
	self.GameDeskLayer = GameDeskLayer.create()
	self:addChild(self.GameDeskLayer)

	--游戏牌管理类
	self.GameCardManager = GameCardManager.create()
	self:addChild(self.GameCardManager)
	--头像
	self.GameAvatarLayer = GameAvatarLayer.create()
	self:addChild(self.GameAvatarLayer)
	--离开通知
	self.GameLeaveNoticeLayer = GameLeaveNoticeLayer.create()
	self.GameLeaveNoticeLayer:setVisible(false)
	self:addChild(self.GameLeaveNoticeLayer)
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

function GameDeskScene:Action_Restart(byAgree)

    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
	self.m_pGameEnd = nil

    -- 清除出牌
    self.GameCardManager:clearShowOutCard(G_GameDefine.nMaxPlayerCount)

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

function GameDeskScene:setBankerBySeat(nLocalSeat)
	self.GameAvatarLayer:setBankerBySeat(nLocalSeat)
end

function GameDeskScene:playEffectOver(audioID)
	self.GameAvatarLayer:hideYuyin(self.map_music[audioID])
end

function GameDeskScene:handleMessage(event)
    -- event  msgName, msgID, msgLen, msgData

    if event.msgName == "GAME_HeartBeatAck" then
    elseif event.msgName == "GAME_ChatAck" then
		self:handleChatAck(event)
    elseif event.msgName == "GAME_DefaultChatAck" then
        self:handleDefaultChatAck(event)
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
	elseif event.msgName == "GAME_OutCardAck" then
		self:handleOutCardAck(event)
    elseif event.msgName == "GAME_PassCardAck" then
		self:handlePassCardAck(event)
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

    local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
    if nLocalSeat ~= 1 then
        -- 显示聊天信息
        self.GameDeskLayer.GameChatLayer:ShowChatInfo(nLocalSeat, tInfo.dwMsgID)
    end
end

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
			local iCurSeat = G_GamePlayer:getLocalSeat(i-1)
			strInfo = strInfo.."["..curPlayerInfo["szNickName"].."]"
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
			local iCurSeat = G_GamePlayer:getLocalSeat(i-1)
			if G_Data.GAME_DissolveGameVoteResultAck.bApprove[i] == 0 then
				strInfo = strInfo.."["..curPlayerInfo["szNickName"].."]"
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
    local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
    if nLocalSeat == 1 then
        -- 设置准备按钮
        self.GameDeskLayer:SetReadyBtn(tInfo.bAgree, true)
    end
    -- 设置玩家准备状态
    self.GameAvatarLayer:setReady(tInfo.wChairID, tInfo.bAgree)
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
end

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

	self.GameAvatarLayer:resetPos()

	G_GameDefine.nGameCount = tInfo.nCurGameCount
	G_GameDefine.nGameStatus = tInfo.nGameStatus
	G_GameDefine.nTotalGameCount = tInfo.nTotalGameCount
    self.ullMasterID = tInfo.ullMasterID
	
	for i=1,#tInfo.UserGameData do
		if tInfo.UserGameData[i].ullUserID ~= 0 and tInfo.UserGameData[i].ullUserID ~= G_GamePlayer:getMainPlayer().ullUserID then
			tInfo.UserGameData[i].seat = i-1
			G_GamePlayer:addPlayerInfo(tInfo.UserGameData[i])
			self.GameAvatarLayer:showAvatarBySeverSeat(i)
		end
	end

    self.GameDeskLayer:handleEnterGameAck(tInfo)
end

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
                self.GameAvatarLayer:setGameAvatar(i-1, false)
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

                if tInfo.dwGameStatus == GS_GAME_FREE then
                    self.GameAvatarLayer:showAvatar(i-1, tInfo.arrImgUrl[i], tInfo.arrNickName[i], tInfo.arrUserID[i], tInfo.dwGameScore[i], tInfo.bReadyStatus[i], curPlayerInfo.ip)
                else
                    self.GameAvatarLayer:showAvatar(i-1, tInfo.arrImgUrl[i], tInfo.arrNickName[i], tInfo.arrUserID[i], tInfo.dwGameScore[i], 0, curPlayerInfo.ip)
                end
            else
                local curPlayerInfo = {}
				curPlayerInfo.ullUserID = tInfo.arrUserID[i]
				curPlayerInfo.seat = i-1
                curPlayerInfo.ip = playerInfo.ip
				curPlayerInfo.szNickName = tInfo.arrNickName[i]
				curPlayerInfo.imgurl = tInfo.arrImgUrl[i]
                curPlayerInfo.sex = tInfo.sex
				G_GamePlayer:addPlayerInfo(curPlayerInfo)
                
                if tInfo.dwGameStatus == GS_GAME_FREE then
                    if G_GamePlayer:getLocalSeat(i-1) == 1 and  G_GameDefine.nGameCount == 1 then
                        self.GameAvatarLayer:showAvatar(i-1, tInfo.arrImgUrl[i], tInfo.arrNickName[i], tInfo.arrUserID[i], tInfo.dwGameScore[i], 0, curPlayerInfo.ip)
                    else
                        self.GameAvatarLayer:showAvatar(i-1, tInfo.arrImgUrl[i], tInfo.arrNickName[i], tInfo.arrUserID[i], tInfo.dwGameScore[i], tInfo.bReadyStatus[i], curPlayerInfo.ip)
                    end
                else
                    self.GameAvatarLayer:showAvatar(i-1, tInfo.arrImgUrl[i], tInfo.arrNickName[i], tInfo.arrUserID[i], tInfo.dwGameScore[i], 0, curPlayerInfo.ip)
                end
			end
			self.GameAvatarLayer:showAvatarBySeverSeat(i)
		end
	end

    self.wLastOutUser = tInfo.wLastOutUser
    self.wCurrentUser = tInfo.wCurrentUser
    self.tOutCardData = tInfo.cbTurnCardData
    self.nOutCardCount = tInfo.cbTurnCardCount

    -- 设置房间信息
    self.tRoomInfo = tInfo.RoomInfo
    -- 显示房间信息
    self:showRoomInfo()

	for i=1, G_GameDefine.nPlayerCount do
		self.GameAvatarLayer:setCurScore(i-1, tInfo.dwGameScore[i])
	end

    -- 取解析的table索引是从1开始,要加1
    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
	if tInfo.dwGameStatus == GS_GAME_FREE or tInfo.dwGameStatus == GS_GAME_END then
        self.GameDeskLayer:SetReadyBtn(tInfo.bReadyStatus[nSelfServerSeat+1], true)
        self.GameAvatarLayer:setReady(nSelfServerSeat, tInfo.bReadyStatus[nSelfServerSeat+1])
		return
	else
		G_GameDefine.nGameStatus = GS_GAME_PLAY
	end 

	for i=1,G_GameDefine.nPlayerCount do
		self.GameAvatarLayer:setCurScore(i-1, tInfo.dwGameScore[i])
		self.GameAvatarLayer:setReady(i-1, 0)
	end

    for i=1, G_GameDefine.nPlayerCount do
        -- 设置玩家牌数
        self.GameCardManager:setUserCardCount(i-1, tInfo.cbCardCount[i])
    end

    -- 显示出牌
    local nOutCardSeat = G_GamePlayer:getLocalSeat(self.wLastOutUser)
    self.GameCardManager:createShowOutCard(nOutCardSeat, tInfo.cbTurnCardData, tInfo.cbTurnCardCount)

    -- 自己牌处理
    self.GameCardManager:createShowStandCard(1, tInfo.cbCardData, tInfo.cbCardCount[nSelfServerSeat+1])
    self.GameCardManager:setVisible(true)

    -- 游戏状态,显示出牌相关
    if G_GameDefine.nGameStatus == GS_GAME_PLAY then
        if nSelfServerSeat == self.wCurrentUser then
            if self.wLastOutUser == self.wCurrentUser then
                self.GameDeskLayer:setNodeShow2(true)

                -- 是自己，尝试自动出完牌
                self.GameCardManager:autoOutCard(true, {}, 0)
            else
                -- 必须管
                if self.tRoomInfo.bMustPressCard > 0 then
                    self.GameDeskLayer:setNodeShow2(true)

                    -- 大得起
                    if self.GameCardManager:pressCard(self.tOutCardData, self.nOutCardCount) then
                        -- 是自己，尝试自动出完牌
                        self.GameCardManager:autoOutCard(false, self.tOutCardData, self.nOutCardCount)
                    else
                        -- 设置不可选择状态
                        self.GameCardManager:recoverTouchState(false)
                        -- 过牌
	                    self.GameDeskLayer:passCard()
                    end
                else
                    self.GameDeskLayer:setNodeShow1(true)

                     -- 大得起
                    if self.GameCardManager:pressCard(self.tOutCardData, self.nOutCardCount) then
                        -- 是自己，尝试自动出完牌
                        self.GameCardManager:autoOutCard(false, self.tOutCardData, self.nOutCardCount)
                    else
                        -- 设置不可选择状态
                        self.GameCardManager:recoverTouchState(false)
                    end
                end
            end
        end
    end

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
        if gameDisbandNoticeTAG then
            gameDisbandNoticeTAG:removeFromParent()
        end

        local gameDisbandApplyTAG = self:getChildByTag(self.nGameDisbandApplyTAG)
        if gameDisbandApplyTAG then
            gameDisbandApplyTAG:removeFromParent()
        end
	end
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
    -- 设置游戏局数
    G_GameDefine.nGameCount = G_GameDefine.nGameCount + 1

    -- 清除牌数据
    self.GameCardManager:restore()

    self.tOutCardData = {}
    self.nOutCardCount = 0

    -- 隐藏准备图片
	for i=1, G_GameDefine.nPlayerCount do
		self.GameAvatarLayer:setReady(i-1, 0)
	end

    -- 隐藏结算界面
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
    self.m_pGameEnd = nil
	
	local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wCurrentUser)

	if G_GameDefine.bReplay then
	else
        -- 设置庄家
		self.GameAvatarLayer:setBankerBySeat(nLocalSeat)
        -- 显示闹钟
        self.GameAvatarLayer:showOutTime(nLocalSeat, true)
	end

    -- 桌子层消息处理
    self.GameDeskLayer:handleGameStartAck(tInfo)

    -- 显示时间
    self.GameAvatarLayer:showOutTime(nLocalSeat, true)

    -- 显示操作等
    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if nSelfServerSeat == tInfo.wCurrentUser then
        self.GameDeskLayer:setNodeShow2(true)
    else
        self.GameDeskLayer:setNodeShow1(false)
        self.GameDeskLayer:setNodeShow2(false)
    end

    -- 牌类处理
    self.GameCardManager:createShowStandCard(1, tInfo.cbCardData, tInfo.cbCardCount)
	self.GameCardManager:setVisible(true)

    -- 显示牌数
    for i=1, G_GameDefine.nMaxPlayerCount do
        self.GameAvatarLayer:setCardCount(i-1, G_GameDefine.nCardCount)
    end
end

-- 出牌消息
function GameDeskScene:handleOutCardAck(event)

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

    local tInfo = G_Data.GAME_OutCardAck

	self.GameLeaveNoticeLayer:outCardUser()

    self.wLastOutUser = tInfo.wOutCardUser
    self.wCurrentUser = tInfo.wCurrentUser
    self.tOutCardData = tInfo.cbCardData
    self.nOutCardCount = tInfo.cbCardCount

    local nCurrentLocalSeatUser = G_GamePlayer:getLocalSeat(self.wCurrentUser)
	if G_GameDefine.bReplay then
	else
		self.GameAvatarLayer:showOutTime(nCurrentLocalSeatUser, true)
	end

    local nServerSeat = G_GamePlayer:getServerSeat(1)
    -- 是自己出牌
    if self.wLastOutUser == nServerSeat then
        -- 必须管
        self.GameDeskLayer:setNodeShow1(false)
        self.GameDeskLayer:setNodeShow2(false)
    end

    -- 操作玩家是自己
    if self.wCurrentUser == nServerSeat then
        -- 必须管
        if self.tRoomInfo.bMustPressCard > 0 then
            self.GameDeskLayer:setNodeShow2(true)

            -- 大得起
            if self.GameCardManager:pressCard(tInfo.cbCardData, tInfo.cbCardCount) then
                -- 是自己，尝试自动出完牌
                self.GameCardManager:autoOutCard(false, tInfo.cbCardData, tInfo.cbCardCount)
            else
                -- 设置不可选择状态
                self.GameCardManager:recoverTouchState(false)
                -- 过牌
	            self.GameDeskLayer:passCard()
            end
        else
            self.GameDeskLayer:setNodeShow1(true)

             -- 大得起
            if self.GameCardManager:pressCard(tInfo.cbCardData, tInfo.cbCardCount) then
                -- 是自己，尝试自动出完牌
                self.GameCardManager:autoOutCard(false, tInfo.cbCardData, tInfo.cbCardCount)
            else
                -- 设置不可选择状态
                self.GameCardManager:recoverTouchState(false)
            end
        end

        -- 清除自己显示出牌
        self.GameCardManager:clearShowOutCard(1)
    end

    -- 增加玩家牌数
    self.GameCardManager:addUserCardCount(self.wLastOutUser, tInfo.cbCardCount)

    -- 取得玩家信息
    local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(self.wLastOutUser)
    -- 性别
    local nSex = (curPlayerInfo == nil) and 1 or curPlayerInfo.sex
    local strSex = (nSex == 1) and "man" or "woman"
    local strCard = bit.band(tInfo.cbCardData[1], 0x0F)
    -- 取得牌类型
    local nCardType = self.GameLogic:getCardType(tInfo.cbCardData, tInfo.cbCardCount)
    if nCardType == CT_SINGLE then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/"..strCard..".wav", false)
    elseif nCardType == CT_DOUBLE then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/2_"..strCard..".wav", false)
    elseif nCardType == CT_THREE then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/3_"..strCard..".wav", false)
    elseif nCardType == CT_SINGLE_LINE then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/Straight.wav", false)
    elseif nCardType == CT_DOUBLE_LINE then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/MorePairs.wav", false)
    elseif nCardType == CT_THREE_LINE then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/Plane.wav", false)
    elseif nCardType == CT_THREE_TAKE_ONE then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/ThreeAndOne.wav", false)
    elseif nCardType == CT_THREE_TAKE_TWO then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/ThreeAndDui.wav", false)
    elseif nCardType == CT_BOMB_CARD then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/Bomb.wav", false)
    end

    local nLastOutLocalSeat = G_GamePlayer:getLocalSeat(self.wLastOutUser)
    if self.GameCardManager.nCardCount[nLastOutLocalSeat] == 1 then
        G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/Warning.wav")
    end

    -- 显示出牌
    local nOutCardUser = G_GamePlayer:getLocalSeat(self.wLastOutUser)
    self.GameCardManager:createShowOutCard(nOutCardUser, tInfo.cbCardData, tInfo.cbCardCount)
end

-- 过牌消息
function GameDeskScene:handlePassCardAck(event)

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

    local tInfo = G_Data.GAME_PassCardAck

    -- 取得玩家信息
    local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(tInfo.wPassUser)
    -- 性别
    local nSex = (curPlayerInfo == nil) and 1 or curPlayerInfo.sex
    local strSex = (nSex == 1) and "man" or "woman"
    G_GameDeskManager.Music:playSound(GameConfigManager.tGameID.PDK.."/"..strSex.."/Pass"..math.random(1,4)..".wav", false)

    local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wCurrentUser)
    -- 新一轮
    if tInfo.bNewTurn > 0 then
        -- 不是自己,隐藏按钮等
        if nLocalSeat ~= 1 then
            -- 必须管
            if self.tRoomInfo.bMustPressCard > 0 then
                self.GameDeskLayer:setNodeShow2(false)
            else
                self.GameDeskLayer:setNodeShow1(false)
            end
        else
            -- 是自己，尝试自动出完牌
            self.GameCardManager:autoOutCard(true, {}, 0)
        end

        -- 清除显示出牌
        self.GameCardManager:clearShowOutCard(G_GameDefine.nMaxPlayerCount)

        -- 设置可选择状态
        self.GameCardManager:recoverTouchState(true)

        self.tOutCardData = {}
        self.nOutCardCount = 0
    else
        -- 必须管
        if self.tRoomInfo.bMustPressCard > 0 then
            self.GameDeskLayer:setNodeShow2(false)
        else
            self.GameDeskLayer:setNodeShow1(false)
        end
    end

    if nLocalSeat == 1 then
        self.GameDeskLayer:setNodeShow2(true)
    end

    -- 显示时钟
    self.GameAvatarLayer:showOutTime(nLocalSeat, true)
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

    self.GameAvatarLayer:showOutTime(-1, false)

	for i=1, G_GameDefine.nPlayerCount do
		self.GameAvatarLayer:setCurScore(i-1,tInfo.lTotalScore[i])
	end

    for i=1, G_GameDefine.nMaxPlayerCount do
        -- 创建显示结束牌
        local nLocalSeat = G_GamePlayer:getLocalSeat(i-1)
        self.GameCardManager:createShowEndCard(nLocalSeat, tInfo.cbCardData[i], tInfo.cbCardCount[i])
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
    end
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
        self.m_pGameGameTotalEnd:GameTotalEndAck(tInfo, self.bDisovleGame)
        self.m_pGameGameTotalEnd:setVisible(false)
        self:addChild(self.m_pGameGameTotalEnd, 101)
    end
end

-- 显示房间信息
function GameDeskScene:showRoomInfo()
    
    local strShowCard = self.tRoomInfo.bShowCard > 0 and "显示牌数 " or "不显示牌数 "
    local strBankerCard = self.tRoomInfo.bOutBankerCard > 0 and "首局黑桃3必出 " or ""
    local strPressCard = self.tRoomInfo.bMustPressCard > 0 and "必须管 " or ""
    local strHongTen = self.tRoomInfo.bHongTen > 0 and "红桃10扎鸟" or ""
    local strInfo = "经典玩法 "..self.nUserCount.."人 "..strShowCard..strBankerCard..strPressCard..strHongTen
    -- 显示房间信息
    self.GameDeskLayer:showRoomInfo(strInfo)
end

-- 提示
function GameDeskScene:prompt()

    if self.nOutCardCount == 0 then
        return
    end

    return self.GameCardManager:prompt(self.tOutCardData, self.nOutCardCount)
end

return GameDeskScene
