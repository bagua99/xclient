
local M = class("GameDeskLayer", G_BaseLayer)

local GameConfigManager             = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.NN.."/GameDeskLayer.csb"

local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".card.GameCard")

local GameSetLayer              = require("app.scenes.lobby.GameSet.GameSetLayer")
local GameChatLayer             = require("app.scenes.lobby.common.GameChatLayer")
local GameLeaveLayer            = require("app.scenes.lobby.common.GameLeaveLayer")
local GameVoteLayer             = require("app.scenes.lobby.common.GameVoteLayer")
local GameVoteNoticeLayer       = require("app.scenes.lobby.common.GameVoteNoticeLayer")

local scheduler                 = cc.Director:getInstance():getScheduler()
local GameConfig                = require ("app.config.GameConfig")
local EventConfig               = require ("app.config.EventConfig")

function M:onCreate()
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

function M:initView()
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
    self.ClockTime:setVisible(false)
	self:addChild(self.ClockTime)

    self.GameChatLayer = GameChatLayer.create()
	self.GameChatLayer:setVisible(false)
	self:addChild(self.GameChatLayer)

    -- 离开
    self.GameLeaveLayer = GameLeaveLayer.create()
    self.GameLeaveLayer:setVisible(false)
    self:addChild(self.GameLeaveLayer, 100)

    -- 投票
    self.GameVoteLayer = GameVoteLayer.create()
    self.GameVoteLayer:setVisible(false)
    self:addChild(self.GameVoteLayer, 100)

    -- 投票信息
    self.GameVoteNoticeLayer = GameVoteNoticeLayer.create()
    self.GameVoteNoticeLayer:setVisible(false)
    self:addChild(self.GameVoteNoticeLayer, 110)

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

	if G_Data.bReplay then
        self.ReplayBg:setVisible(true)
	else
        self.ReplayBg:setVisible(false)
	end
end

function M:initTouch()
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

-- 进入场景
function M:onEnter()

end

-- 退出场景
function M:onExit()
    if self.scehdule_updateClockTime ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
		self.scehdule_updateClockTime = nil
	end
end

-- 邀请
function M:Click_YaoQing()
    G_CommonFunc:addClickSound()
	local strContent = string.format("宁乡牛牛，房间号：%06d,%d人,%d局,%s，来战啊！",G_Data.roomid, G_GameDefine.nPlayerCount, G_GameDefine.nTotalGameCount, self.RoomInfoText:getString())
	ef.extensFunction:getInstance():wxInviteFriend(0, "好友@你", strContent, "", GameConfig.download_url.."?u="..G_Data.UserBaseInfo.userid)
end

-- 离开
function M:Click_Leave()
    G_CommonFunc:addClickSound()
    if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then
        local _player = G_GamePlayer:getMainPlayer()
        if _player.userid == G_DeskScene.tRoomInfo.master_id then
            self.GameLeaveLayer:setConfirmCallback(handler(self, self.GameLeave_Confirm))
            self.GameLeaveLayer:setVisible(true)
        else
            self:LeaveRoom()
        end
	else
        local strInfo ="申请解散房间!"
        self.GameLeaveLayer:setContentText(strInfo)
        self.GameLeaveLayer:setConfirmCallback(handler(self, self.GameVote_Confirm))
		self.GameLeaveLayer:setVisible(true)
	end
end

-- 点击准备
function M:Click_Ready()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nn.GAME_ReadyReq", {bAgree=true})
end

-- 取消准备
function M:Click_CancelReady()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nn.GAME_ReadyReq",{bAgree=false})
end

-- 点击开始
function M:Click_Begin()
    G_CommonFunc:addClickSound()
    G_Data.GAME_BeginReq = {}
    G_Data.GAME_BeginReq.bBegin = true
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nn.GAME_BeginReq",{bBegin=true})
end

-- 抢庄
function M:Click_NeedBank()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nn.GAME_GameBankReq",{bNeed=true})
end

-- 不抢庄
function M:Click_PassBank()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nn.GAME_GameBankReq", {bNeed=false})
end

-- 聊天
function M:Click_Chat(sender, eventType)
    G_CommonFunc:addClickSound()
	self.GameChatLayer:setVisible(true)
end

-- 设置
function M:Click_Set(sender, eventType)
    G_CommonFunc:addClickSound()
    local curayer = GameSetLayer.create()
    curayer:setVisible(true)
	self:addChild(curayer, 10)
end

-- 录音
function M:Click_LuYin(sender, eventType)
    G_CommonFunc:addClickSound()
	if eventType == ccui.TouchEventType.began then
		self.nStartTime = os.time()
		self.SpriteLuyin1:setVisible(true)
	elseif eventType == ccui.TouchEventType.moved then
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self.SpriteLuyin1:setVisible(false)
		if os.time() - self.nStartTime < 1 then
			return
		end
	end
end

-- 下注
function M:Click_Score(sender, eventType)
    G_CommonFunc:addClickSound()
    local nTag = sender:getTag()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nn.GAME_CallScoreReq",{nScoreIndex = nTag})
end

-- 默认聊天回复
function M:handleChatAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.wChairID)
    if nLocalSeat ~= 1 then
        -- 显示聊天信息
        self.GameChatLayer:ShowChatInfo(nLocalSeat, msg.dwMsgID)
    end
end

-- 游戏离开回复
function M:handleGameLeaveAck(msg)
	if msg.nResult == 1 then
		self:LeaveRoom()
    elseif msg.nResult == 2 then
        local strInfo = "房间已被解散!"
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strInfo)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self, self.LeaveRoom))
        self:addChild(curLayer)
	end
end

-- 游戏投票结果
function M:handleGameVoteAck(msg)
    -- 已投票数量
    local nVoteCount = 0
    for nIndex, tInfo in ipairs(msg.vote) do
        if tInfo.nVoteState ~= 0 then
            nVoteCount = nVoteCount + 1
        end
    end

    local bFind = false
    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    for nIndex, tInfo in ipairs(msg.vote) do
        -- 玩家还未投票
        if tInfo.nSeat == nSelfServerSeat and tInfo.nVoteState == 0 then
            if nVoteCount == 1 then
                local strInfo ="玩家申请解散房间,请问是否同意?(超过5分钟未选择,默认同意)"
                local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nDissoveSeat)
                if _player ~= nil then
                    strInfo = "玩家[".._player.nickname.."]申请解散房间,请问是否同意?(超过5分钟未选择,默认同意)"
                end
                self.GameVoteLayer:setContentText(strInfo)
                self.GameVoteLayer:setClockTime(300)
                self.GameVoteLayer:setConfirmCallback(handler(self, self.GameVote_Confirm))
                self.GameVoteLayer:setCancelCallback(handler(self, self.GameVote_Cancel))
                self.GameVoteLayer:setEndTimeCallback(handler(self, self.GameVote_Confirm))
            end
            -- 显示投票框
            self.GameVoteLayer:setVisible(true)

            bFind = true
            break
        end
    end

    -- 已投票就显示投票信息
    if not bFind then
        -- 显示投票信息
        self.GameVoteNoticeLayer:setGameVoteAck(msg.nDissoveSeat, msg.vote)
	    self.GameVoteNoticeLayer:setVisible(true)
    end
end

-- 游戏投票结果
function M:handleGameVoteResultAck(msg)
    -- 隐藏投票框
    self.GameVoteLayer:onExit()
    -- 隐藏投票信息
    self.GameVoteNoticeLayer:setVisible(false)
end

-- 玩家进入
function M:handlePlayerEnterAck(msg)
    -- 显示玩家信息
    self:ShowUserInfo(msg.userData.seat, true)
end

-- 玩家离开
function M:handlePlayerLeaveAck(msg)
    -- 显示玩家信息
    self:ShowUserInfo(msg.nSeat, false)

    -- 设置玩家准备状态
    self:SetReady(msg.nSeat, false)
end

-- 进入游戏
function M:handleEnterGameAck(msg)
	if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then
		self.YaoQingBtn:setVisible(true)
	else
		self.YaoQingBtn:setVisible(false)
	end
	self.RoomInfoText:setString("房号:"..G_Data.roomid.."       对局:1/"..G_GameDefine.nTotalGameCount)
    self.BeginBtn:setVisible(false)
	self:SetReadyBtn(false, true)
end

function M:showPlayer(seat, p, ready)
    self:ShowUserInfo(seat, true)
    self:SetUserScore(seat, p.score)
    self:SetUserName(seat, p.nickname)
    self:SetReady(seat, ready)
end

-- 场景消息
function M:handleSceneAck(msg)
    local nServerSeat = G_GamePlayer:getServerSeat(1)
	if msg.nGameStatus == G_GameDefine.game_free then
        self:SetReadyBtn(msg.bReadyStatus[nServerSeat], true)
	end 

    -- 设置庄家
    self:setBankerUser(msg.nBankerSeat, true)

    -- 显示操作相关
    if msg.nGameStatus == G_GameDefine.game_play then

        local bQiangZhuang = true
        -- 抢庄模式
        if msg.RoomInfo.cbBankType == 1 then
            for i=1,G_GameDefine.nPlayerCount do
                if msg.arrUserID[i] > 0 then
                    if msg.cbNeed[i] == 1 then
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
            if msg.nNeed[nServerSeat] == 0 then
                self.NeedBankBtn:setVisible(true)
                self.PassBankBtn:setVisible(true)
            end
        else
            if nServerSeat ~= msg.nBankerSeat then
                self.Node_Btn:setVisible(true)
                for nIndex, pButton in ipairs(self.tScoreBtn) do
                    pButton:setVisible(true)
                end
            end
        end
    end

    -- 投票相关
	if msg.nGameStatus == G_GameDefine.game_vote then
		if msg.nDissoveSeat > 0 then
            local tVoteResult = {}
            for i = 1, #msg.nVoteState do
                table.insert(tVoteResult, {nSeat = i, nVoteState = msg.nVoteState[i]})
            end
            local tInfo = 
            {
                nDissoveSeat = msg.nDissoveSeat,
                voteResult = tVoteResult,
            }
			self:handleGameVoteAck(tInfo)
		end
    else
        -- 隐藏投票框
        self.GameVoteLayer:setVisible(false)
        -- 隐藏投票信息
        self.GameVoteNoticeLayer:setVisible(false)
	end
end

-- 玩家准备
function M:handleReadyAck(msg)
    local nServerSeat = G_GamePlayer:getServerSeat(1)
	print(nServerSeat, msg.wChairID)
    if nServerSeat == msg.wChairID then
        -- 显示玩家信息
        self:SetReadyBtn(msg.bAgree, true)

        for i=1, G_GameDefine.nPlayerCount do
            self.tScore[i]:setVisible(false)
        end
    end

    -- 设置玩家准备状态
    self:SetReady(msg.wChairID, msg.bAgree)
end

-- 游戏开始
function M:handleGameStartAck(msg)
	self.YaoQingBtn:setVisible(false)
    self:SetReadyBtn(0, false)
	self.RoomInfoText:setString("房号:"..G_Data.roomid.."       对局:"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount)

    -- 设置庄家
    self:setBankerUser(msg.wBankerUser, true)
    -- 显示闹钟
    self:setClockTime(true)

    -- 隐藏抢庄相关
    self.NeedBankBtn:setVisible(false)
    self.PassBankBtn:setVisible(false)

     -- 隐藏准备图片
	for i=1, G_GameDefine.nPlayerCount do
        -- 隐藏准备
        self:SetReady(i, false)
	end

    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if nServerSeat ~= msg.wBankerUser then
        self.Node_Btn:setVisible(true)
        for nIndex, pButton in ipairs(self.tScoreBtn) do
            pButton:setVisible(true)
        end
    end

    -- 隐藏开始按钮
    self.BeginBtn:setVisible(false)

    --开始发牌
    G_DeskScene:showEmptyCard()
    
end

-- 下注消息
function M:handleCallScoreAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCallScoreUser)
    if nLocalSeat == 1 then
        self.Node_Btn:setVisible(false)
        for nIndex, pButton in ipairs(self.tScoreBtn) do
            pButton:setVisible(false)
        end
    end

    self.tScore[nLocalSeat]:setString(msg.nCallScore)
    self.tScore[nLocalSeat]:setVisible(true)
end

-- 抢庄消息
function M:handleBeginBankAck(msg)

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
function M:handleGameBankAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.wChairID)
    if nLocalSeat == 1 then
        self.NeedBankBtn:setVisible(false)
        self.PassBankBtn:setVisible(false)
    end
end

-- 游戏结束消息
function M:handleGameEndAck(msg)
    -- 隐藏闹钟
    self:setClockTime(false)

	-- 设置分数
	for _, info in ipairs(msg.infos) do
        self:SetUserScore(info.seat, info.total_score)
	end
end

-- 显示准备按钮
function M:SetReadyBtn(ready, bShow)
    if bShow then
        self.ReadyBtn:setVisible(not ready)
        self.CancelReadyBtn:setVisible(ready)
    else
        self.ReadyBtn:setVisible(false)
        self.CancelReadyBtn:setVisible(false)
    end
end

-- 显示准备图片
function M:SetReady(seat, ready)
    local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
    self.tReady[nLocalSeat]:setVisible(ready)
end

-- 显示玩家信息
function M:ShowUserInfo(nServerSeat, bVisible)
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].Node_Head:setVisible(bVisible)
end

-- 设置玩家名字
function M:SetUserName(nServerSeat, szName)
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].NameText:setString(szName)
end

-- 设置玩家分数
function M:SetUserScore(nServerSeat, nScore)
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].ScoreText:setString(nScore)
end

-- 设置庄家
function M:setBankerUser(nServerSeat, bShow)
    self.Banker:setVisible(bShow)

    if not bShow then
        return
    end

    local tPoint = {cc.p(91, 133), cc.p(486, 552), cc.p(286, 552), cc.p(679, 552), cc.p(28, 419), cc.p(1110, 419), cc.p(160, 552), cc.p(905, 552)}
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.Banker:setPosition(tPoint[nLocalSeat])
end

-- 设置闹钟
function M:setClockTime(bShow)
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
function M:updateClockTime()
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

-- 游戏离开
function M:GameLeave_Confirm()
    -- 发送解散消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameLeaveReq", {})
end

-- 游戏离开
function M:LeaveRoom()
    -- 清理数据
    G_Data.roomid = 0
    G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
	G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end

-- 投票-同意
function M:GameVote_Confirm()
    -- 发送解散消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameVoteReq", {bAgree = true})
end

-- 投票-取消
function M:GameVote_Cancel()
    -- 发送解散消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameVoteReq", {bAgree = false})
end

return M
