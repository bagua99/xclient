
local GameDeskLayer = class("GameDeskLayer", G_BaseLayer)

local GameConfigManager             = require("app.scenes.gamedesk.GameConfigManager")

GameDeskLayer.RESOURCE_FILENAME = GameConfigManager.tGameID.NN.."/GameDeskLayer.csb"

local GameLeaveRoomLayer            = require("app.scenes.lobby.common.GameLeaveRoomLayer")
local GameDisbandApplyLayer         = require("app.scenes.lobby.common.GameDisbandApplyLayer")
local GameSetLayer                  = require("app.scenes.lobby.common.GameSetLayer")
local GameChatLayer                 = require("app.scenes.lobby.common.GameChatLayer")

local scheduler = cc.Director:getInstance():getScheduler()

function GameDeskLayer:onCreate()

    -- 邀请按钮
	self.YaoQingBtn             = self.resourceNode_.node["YaoQingBtn"]
    -- 准备按钮
    self.ReadyBtn               = self.resourceNode_.node["ReadyBtn"]
    -- 取消准备按钮
    self.CancelReadyBtn         = self.resourceNode_.node["CancelReadyBtn"]
    -- 房间信息
    self.RoomInfoText           = self.resourceNode_.node["Sprite_Top"].node["RoomInfoText"]
    -- 回放信息
    self.ReplayBg               = self.resourceNode_.node["ReplayBg"]
    -- 设置
    self.setBtn                 = self.resourceNode_.node["SetBtn"]
    -- 离开
    self.LeaveBtn               = self.resourceNode_.node["LeaveBtn"]
    -- 录音
    self.LuYinBtn               = self.resourceNode_.node["LuYinBtn"]
    -- 聊天
	self.ChatBtn                = self.resourceNode_.node["ChatBtn"]

    -- 开始
    self.BeginBtn               = self.resourceNode_.node["BeginBtn"]

    -- 玩家头像信息
    self.Node_Head = self.resourceNode_.node["Node_Head"]
    self.tHeadInfo = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        local tData = {}
        tData.Node_Head = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i]
        tData.NameText = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["NameText_"..i]
        tData.ScoreText = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["ScoreText_"..i]
        tData.Head = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["Head_"..i]
        self.tHeadInfo[i] = tData
    end

    self.Node_Btn = self.resourceNode_.node["Node_Btn"]
    self.tScoreBtn = {}
    for i=1, 4 do
        self.tScoreBtn[i] = self.resourceNode_.node["Node_Btn"].node["ScoreBtn_"..i]
    end

    self.Node_Bank = self.resourceNode_.node["Node_Bank"]
    self.NeedBankBtn = self.resourceNode_.node["Node_Bank"].node["NeedBankBtn"]
    self.PassBankBtn = self.resourceNode_.node["Node_Bank"].node["PassBankBtn"]

    self.Node_Ready = self.resourceNode_.node["Node_Ready"]
    self.tReady = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tReady[i] = self.resourceNode_.node["Node_Ready"].node["Ready_"..i]
    end

    self.Node_Score = self.resourceNode_.node["Node_Score"]
    self.tScore = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tScore[i] = self.resourceNode_.node["Node_Score"].node["Score_"..i]
    end
    self.Banker = self.resourceNode_.node["Banker"]

    self.scehdule_updateClockTime = nil
    self.nTimeCount = 0
end

function GameDeskLayer:initView()

    -- 语音相关
    self.SpriteLuyin1 = cc.Sprite:create("Voice/record_0.png")
	self.SpriteLuyin1:setPosition(cc.p(display.width/2,display.height/2))
	self.SpriteLuyin1:setVisible(false)
	self:addChild(self.SpriteLuyin1)

	local actSpr = cc.Sprite:create("Voice/p1.png")
	actSpr:setPosition(cc.p(self.SpriteLuyin1:getBoundingBox().width/2 + 50, self.SpriteLuyin1:getBoundingBox().height/2 + 30))
	local curAnimate = cc.Animation:create()
	for i=1,6 do
		curAnimate:addSpriteFrameWithFile("Voice/p"..i..".png")
	end
	curAnimate:setDelayPerUnit(1/3)
	curAnimate:setRestoreOriginalFrame(true)
	local curAction = cc.Animate:create(curAnimate)
	actSpr:runAction(cc.RepeatForever:create(curAction))
	self.SpriteLuyin1:addChild(actSpr)

    local tPoint = cc.p(556, 314)
    -- 闹钟
	self.ClockBg = cc.Sprite:create("Common/clock.png")
	self.ClockBg:setPosition(tPoint)
	self.ClockBg:setOpacity(150)
    self.ClockBg:setVisible(false)
	self:addChild(self.ClockBg)

	self.ClockTime = ccui.TextAtlas:create("15","Common/clock_font.png",20,28,"0")
	self.ClockTime:setPosition(cc.pSub(tPoint, cc.p(0,2)))
    self.ClockTime:setVisible(false)
	self:addChild(self.ClockTime)

    self.GameChatLayer = GameChatLayer.create()
	self.GameChatLayer:setVisible(false)
	self:addChild(self.GameChatLayer)

	self.YaoQingBtn:setVisible(false)
    self.ReadyBtn:setVisible(false)
    self.CancelReadyBtn:setVisible(false)
    self.RoomInfoText:setVisible(true)
    self.setBtn:setVisible(true)
    self.LeaveBtn:setVisible(true)
    self.LuYinBtn:setVisible(true)
    self.ChatBtn:setVisible(true)
    self.BeginBtn:setVisible(false)

    self.Node_Head:setVisible(true)
    for nIndex, tData in ipairs(self.tHeadInfo) do
        tData.Node_Head:setVisible(false)
    end

    self.Node_Bank:setVisible(true)
    self.NeedBankBtn:setVisible(false)
    self.PassBankBtn:setVisible(false)

    self.Node_Btn:setVisible(true)
    for nIndex, pButton in ipairs(self.tScoreBtn) do
        pButton:setTag(nIndex)
        pButton:setVisible(false)
    end

    self.Node_Ready:setVisible(true)
    for nIndex, pImage in ipairs(self.tReady) do
        pImage:setVisible(false)
    end

    self.Node_Score:setVisible(true)
    for nIndex, pScore in ipairs(self.tScore) do
        pScore:setVisible(false)
    end

	if G_GameDefine.bReplay then
        self.ReplayBg:setVisible(true)
	else
        self.ReplayBg:setVisible(false)
	end
end

function GameDeskLayer:initTouch()

	self.YaoQingBtn:addClickEventListener(handler(self,self.Click_YaoQing))
    self.ReadyBtn:addClickEventListener(handler(self,self.Click_Ready))
    self.CancelReadyBtn:addClickEventListener(handler(self,self.Click_CancelReady))
    self.BeginBtn:addClickEventListener(handler(self,self.Click_Begin))

    self.NeedBankBtn:addTouchEventListener(handler(self,self.Click_NeedBank))
	self.PassBankBtn:addClickEventListener(handler(self,self.Click_PassBank))

    self.setBtn:addClickEventListener(handler(self,self.Click_Set))
    self.LeaveBtn:addClickEventListener(handler(self,self.Click_Leave))
    self.LuYinBtn:addTouchEventListener(handler(self,self.Click_LuYin))
	self.ChatBtn:addClickEventListener(handler(self,self.Click_Chat))

    for nIndex, pButton in ipairs(self.tScoreBtn) do
        pButton:addClickEventListener(handler(self, self.Click_Score))
    end
end

-- 邀请
function GameDeskLayer:Click_YaoQing()

	local strContent = string.format("宁乡牛牛，房间号：%06d,%d人,%d局,%s，来战啊！",G_GameDeskManager.nGameID,G_GameDefine.nPlayerCount,G_GameDefine.nGameCount,self.RoomInfoText:getString())
	ef.extensFunction:getInstance():wxInviteFriend(0, "好友@你", strContent, "Icon-120.png", "http://www.abletele.com/xiaoyou/index.html")
end

-- 离开
function GameDeskLayer:Click_Leave()

	if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == GS_GAME_FREE then

        local tPlayer = G_GamePlayer:getMainPlayer()
        if tPlayer.ullUserID == G_DeskScene.ullMasterID then
		    local curLayer = GameLeaveRoomLayer:create()
		    G_DeskScene:addChild(curLayer)
        else
            G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME,"GAME_DissolveGameReq")

            G_NetManager:disconnect(NETTYPE_GAME)
	        G_SceneManager:enterScene(SCENE_LOBBY)
        end
	else
		G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME,"GAME_DissolveGameReq")

        local curLayer = GameDisbandApplyLayer.create()
	    G_DeskScene:addChild(curLayer, 10, G_DeskScene.nGameDisbandApplyTAG)
	end
end

-- 点击准备
function GameDeskLayer:Click_Ready()

	G_Data.GAME_ReadyReq = {}
    G_Data.GAME_ReadyReq.bAgree = true
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_ReadyReq")
end

-- 取消准备
function GameDeskLayer:Click_CancelReady()

    G_Data.GAME_ReadyReq = {}
    G_Data.GAME_ReadyReq.bAgree = false
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_ReadyReq")
end

-- 点击开始
function GameDeskLayer:Click_Begin()

    G_Data.GAME_BeginReq = {}
    G_Data.GAME_BeginReq.bBegin = true
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_BeginReq")
end

-- 抢庄
function GameDeskLayer:Click_NeedBank()

    G_Data.GAME_GameBankReq = {}
    G_Data.GAME_GameBankReq.bNeed = true
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_GameBankReq")
end

-- 不抢庄
function GameDeskLayer:Click_PassBank()

    G_Data.GAME_GameBankReq = {}
    G_Data.GAME_GameBankReq.bNeed = false
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_GameBankReq")
end

-- 聊天
function GameDeskLayer:Click_Chat(sender, eventType)

	self.GameChatLayer:setVisible(true)
end

-- 设置
function GameDeskLayer:Click_Set(sender, eventType)

    local curayer = GameSetLayer.create()
    curayer:setVisible(true)
	self:addChild(curayer, 10)
end

-- 录音
function GameDeskLayer:Click_LuYin(sender, eventType)

	if eventType == ccui.TouchEventType.began then
		self.nStartTime = os.time()
		self.SpriteLuyin1:setVisible(true)
		ef.extensFunction:getInstance():startRecording(true)
	elseif eventType == ccui.TouchEventType.moved then
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self.SpriteLuyin1:setVisible(false)
		if os.time() - self.nStartTime < 1 then
			ef.extensFunction:getInstance():stopReording()
			return
		end
		
		ef.extensFunction:getInstance():startRecording(false)
		ef.extensFunction:getInstance():stopReording()
	end
end

-- 下注
function GameDeskLayer:Click_Score(sender, eventType)

    local nTag = sender:getTag()

    G_Data.GAME_CallScoreReq = {}
    G_Data.GAME_CallScoreReq.cbScoreIndex = nTag
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_CallScoreReq")
end

-- 默认聊天回复
function GameDeskLayer:handleDefaultChatAck(tInfo)

	local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
    if nLocalSeat ~= 1 then
        -- 显示聊天信息
        self.GameChatLayer:ShowChatInfo(nLocalSeat, tInfo.dwMsgID)
    end
end

-- 玩家离开游戏
function GameDeskLayer:handleLeaveGameAck(tInfo)

	-- 显示玩家信息
    self:ShowUserInfo(tInfo.wChairID, false)

    -- 设置玩家准备状态
    self:SetReady(tInfo.wChairID, false)
end

-- 玩家准备
function GameDeskLayer:handleReadyAck(tInfo)

    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if nServerSeat == tInfo.wChairID then
        -- 显示玩家信息
        self:SetReadyBtn(tInfo.bAgree, true)

        for i=1, G_GameDefine.nPlayerCount do
            self.tScore[i]:setVisible(false)
        end
    end

    -- 设置玩家准备状态
    self:SetReady(tInfo.wChairID, tInfo.bAgree)
end

-- 新玩家
function GameDeskLayer:handleNewPlayerAck(tInfo)

	-- 显示玩家信息
    self:ShowUserInfo(tInfo.wChairID, true)
end

-- 进入游戏
function GameDeskLayer:handleEnterGameAck(tInfo)

	if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == GS_GAME_FREE then
		self.YaoQingBtn:setVisible(true)
	else
		self.YaoQingBtn:setVisible(false)
	end
	self.RoomInfoText:setString("房号:"..G_Data.CL_JoinGameAck.roomid.."       对局:"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount)

    -- 第一局人数不够，庄家可以手动开始
    if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == GS_GAME_FREE then

        local tPlayer = G_GamePlayer:getMainPlayer()
        if tPlayer.ullUserID == G_DeskScene.ullMasterID then
            self.BeginBtn:setVisible(true)
        end
    end
end

-- 场景消息
function GameDeskLayer:handleSceneAck(tInfo)

    -- 取解析的table索引是从1开始,要加1
    local nServerSeat = G_GamePlayer:getServerSeat(1)
	if tInfo.dwGameStatus == GS_GAME_FREE or tInfo.dwGameStatus == GS_GAME_END then
        self:SetReadyBtn(tInfo.bReadyStatus[nServerSeat+1], true)
	end 

	for i=1,G_GameDefine.nPlayerCount do
        if tInfo.arrUserID[i] > 0 then
            -- 显示玩家信息
            self:ShowUserInfo(i-1, true)
            -- 设置玩家分数
            self:SetUserScore(i-1, tInfo.dwGameScore[i])
            -- 设置玩家名字
            self:SetUserName(i-1, tInfo.arrNickName[i])
            -- 设置准备
            self:SetReady(i-1, tInfo.bReadyStatus[i])
        end
	end

    -- 设置庄家
    self:setBankerUser(tInfo.wBankerUser, true)

    -- 显示操作相关
    if tInfo.dwGameStatus == GS_GAME_PLAY then

        local bQiangZhuang = true
        -- 抢庄模式
        if tInfo.RoomInfo.cbBankType == 1 then
            for i=1,G_GameDefine.nPlayerCount do
                if tInfo.arrUserID[i] > 0 then
                    if tInfo.cbNeed[i] == 1 then
                        bQiangZhuang = false
                        break
                    end
                end
            end
        else
            bQiangZhuang = false
        end

        -- 抢庄状态
        if bQiangZhuang then
            -- 没有操作
            if tInfo.cbNeed[nServerSeat+1] == 0 then
                self.NeedBankBtn:setVisible(true)
                self.PassBankBtn:setVisible(true)
            end
        else
            if nServerSeat ~= tInfo.wBankerUser then
                self.Node_Btn:setVisible(true)
                for nIndex, pButton in ipairs(self.tScoreBtn) do
                    pButton:setVisible(true)
                end
            end
        end
    end
end

-- 游戏开始
function GameDeskLayer:handleGameStartAck(tInfo)

	self.YaoQingBtn:setVisible(false)
    self:SetReadyBtn(0, false)
	self.RoomInfoText:setString("房号:"..G_Data.CL_JoinGameAck.roomid.."       对局:"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount)

    -- 设置庄家
    self:setBankerUser(tInfo.wBankerUser, true)
    -- 显示闹钟
    self:setClockTime(true)

    -- 隐藏抢庄相关
    self.NeedBankBtn:setVisible(false)
    self.PassBankBtn:setVisible(false)

     -- 隐藏准备图片
	for i=1, G_GameDefine.nPlayerCount do
        -- 隐藏准备
        self:SetReady(i-1, 0)
	end

    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if nServerSeat ~= tInfo.wBankerUser then
        self.Node_Btn:setVisible(true)
        for nIndex, pButton in ipairs(self.tScoreBtn) do
            pButton:setVisible(true)
        end
    end

    -- 隐藏开始按钮
    self.BeginBtn:setVisible(false)
end

-- 下注消息
function GameDeskLayer:handleCallScoreAck(tInfo)

    local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wCallScoreUser)
    if nLocalSeat == 1 then
        self.Node_Btn:setVisible(false)
        for nIndex, pButton in ipairs(self.tScoreBtn) do
            pButton:setVisible(false)
        end
    end

    self.tScore[nLocalSeat]:setString(tInfo.nCallScore)
    self.tScore[nLocalSeat]:setVisible(true)
end

-- 抢庄消息
function GameDeskLayer:handleBeginBankAck(tInfo)

    self.YaoQingBtn:setVisible(false)
    self:SetReadyBtn(0, false)

     -- 隐藏准备图片
	for i=1, G_GameDefine.nPlayerCount do
        -- 隐藏准备
        self:SetReady(i-1, 0)
	end

    -- 隐藏开始按钮
    self.BeginBtn:setVisible(false)

    self.NeedBankBtn:setVisible(true)
    self.PassBankBtn:setVisible(true)
end

-- 抢庄消息
function GameDeskLayer:handleGameBankAck(tInfo)

    local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
    if nLocalSeat == 1 then
        self.NeedBankBtn:setVisible(false)
        self.PassBankBtn:setVisible(false)
    end
end

-- 游戏结束消息
function GameDeskLayer:handleGameEndAck(tInfo)

    -- 隐藏闹钟
    self:setClockTime(false)

	for i=1, G_GameDefine.nPlayerCount do
        -- 设置分数
        self:SetUserScore(i-1, tInfo.lTotalScore[i])
	end
end

-- 进入场景
function GameDeskLayer:onEnter()

end

-- 退出场景
function GameDeskLayer:onExit()

    if self.scehdule_updateClockTime ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
		self.scehdule_updateClockTime = nil
	end
end

-- 显示准备按钮
function GameDeskLayer:SetReadyBtn(byReady, bShow)

    local bReady = false
    if byReady == 1 then
        bReady = true
    end

    if bShow then
        self.ReadyBtn:setVisible(not bReady)
        self.CancelReadyBtn:setVisible(bReady)
    else
        self.ReadyBtn:setVisible(false)
        self.CancelReadyBtn:setVisible(false)
    end
end

-- 显示准备图片
function GameDeskLayer:SetReady(nServerSeat, byReady)

    local bReady = false
    if byReady == 1 then
        bReady = true
    end

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tReady[nLocalSeat]:setVisible(bReady)
end

-- 显示玩家信息
function GameDeskLayer:ShowUserInfo(nServerSeat, bVisible)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].Node_Head:setVisible(bVisible)
end

-- 设置玩家名字
function GameDeskLayer:SetUserName(nServerSeat, szName)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].NameText:setString(szName)
end

-- 设置玩家分数
function GameDeskLayer:SetUserScore(nServerSeat, nScore)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].ScoreText:setString(nScore)
end

-- 设置庄家
function GameDeskLayer:setBankerUser(nServerSeat, bShow)

    self.Banker:setVisible(bShow)

    if not bShow then
        return
    end

    local tPoint = {cc.p(91, 133), cc.p(486, 552), cc.p(286, 552), cc.p(679, 552), cc.p(28, 419), cc.p(1110, 419), cc.p(160, 552), cc.p(905, 552)}
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.Banker:setPosition(tPoint[nLocalSeat])
end

-- 设置闹钟
function GameDeskLayer:setClockTime(bShow)

    if self.scehdule_updateClockTime ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
		self.scehdule_updateClockTime = nil
	end

    self.ClockTime:setVisible(bShow)
    self.ClockBg:setVisible(bShow)

    if not bShow then
        return
    end

    self.nTimeCount = 16
    self:updateClockTime()
    self.scehdule_updateClockTime = scheduler:scheduleScriptFunc(handler(self, self.updateClockTime), 1, false)
end

-- 更新闹钟
function GameDeskLayer:updateClockTime()

	self.nTimeCount = self.nTimeCount - 1
	if self.nTimeCount <= 0 then
        self.ClockBg:setVisible(false)
        self.ClockTime:setVisible(false)
		if self.scehdule_updateClockTime ~= nil then
			scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
			self.scehdule_updateClockTime = nil
		end
	else
		self.ClockTime:setString(string.format("%d", self.nTimeCount))
	end
end

return GameDeskLayer
