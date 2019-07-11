
local M = class("GameDeskLayer", G_BaseLayer)

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME             = GameConfigManager.tGameID.DGNN.."/GameDeskLayer.csb"

local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".card.GameCard")

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
    -- self.RoomInfoText           = self.resourceNode_.node["Sprite_Top"].node["RoomInfoText"]
    self.Text_Fang_V = self.resourceNode_.node["Sprite_Top"].node["Text_Fang_V"]
    self.Text_Ju_V = self.resourceNode_.node["Sprite_Top"].node["Text_Ju_V"]
    -- 回放信息
    self.ReplayBg               = self.resourceNode_.node["ReplayBg"]
    self.PauseBtn               = self.resourceNode_.node["ReplayBg"].node["PauseBtn"]
    self.ExitBtn                = self.resourceNode_.node["ReplayBg"].node["ExitBtn"]

    -- 录音
    self.LuYinBtn               = self.resourceNode_.node["LuYinBtn"]
    -- 聊天
	self.ChatBtn                = self.resourceNode_.node["ChatBtn"]

    -- 开始
    self.BeginBtn               = self.resourceNode_.node["BeginBtn"]

    --自动结算
    self.Btn_AutoSuan           = self.resourceNode_.node["Btn_AutoSuan"]
    self.Btn_AutoSuan:setVisible(false)

    --奖池 
    self.IMG_Jiangchi = self.resourceNode_.node["IMG_Jiangchi"]
    self.IMG_Jiangchi:setVisible(false)

    -- Left Btns
    self.BTN_BTS1               = self.resourceNode_.node["BTN_BTS1"]
    -- 离开
    self.BTN_BACK               = self.resourceNode_.node["BTN_BACK"]
    -- 解散
    self.BTN_DISMISS            = self.resourceNode_.node["BTN_DISMISS"]

    -- Right Btns
    self.BTN_BTS2               = self.resourceNode_.node["BTN_BTS2"]
    -- 帮助
    self.BTN_HELP               = self.resourceNode_.node["BTN_HELP"]
     -- 设置
    self.BTN_SETTING            = self.resourceNode_.node["BTN_SETTING"]

    --Node1
    self.Node1 = self.resourceNode_.node["Node1"]
    --Node2
    self.Node2 = self.resourceNode_.node["Node2"]
    --换庄印显示
    self.IMG_SwitchZhuang = self.resourceNode_.node["IMG_SwitchZhuang"]
    self.IMG_SwitchZhuang:setVisible(false)



    -- 奖池信息
    self.Text_LeijiScore           = self.resourceNode_.node["IMG_Jiangchi"].node["Text_LeijiScore"]
    self.Text_Name                 = self.resourceNode_.node["IMG_Jiangchi"].node["Text_Name"]
    self.IMG_HEAD_ICON             = self.resourceNode_.node["IMG_Jiangchi"].node["IMG_HEAD_ICON_BG"].node["IMG_HEAD_ICON"]
    -- self.Text_Score           = self.resourceNode_.node["IMG_Jiangchi"].node["Text_Score"]

    -- 玩家头像信息
    self.Node_Head = self.resourceNode_.node["Node_Head"]
    self.tHeadInfo = {}

    for i=1, 5 do
        local tData = {}
        tData.Node_Head = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i]
        tData.NameText = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["NameText_"..i]
        tData.ScoreText = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["ScoreText_"..i]
        tData.Head = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["Head_"..i]
        tData.offLine  = self.resourceNode_.node["Node_OFFLINE"].node["IMG_OFF"..i]
        tData.HeadSprite =self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["Head_"..i]
        tData.offLine:setVisible(false)
        self.tHeadInfo[i] = tData
    end

    self.Node_Btn = self.resourceNode_.node["Node_Btn"]
    self.tScoreBtn = {}
    for i=1, 5 do
        self.tScoreBtn[i] = self.resourceNode_.node["Node_Btn"].node["ScoreBtn_"..i]
    end

    self.Node_Bank = self.resourceNode_.node["Node_Bank"]
    self.NeedBankBtn = self.resourceNode_.node["Node_Bank"].node["NeedBankBtn"]
    self.PassBankBtn = self.resourceNode_.node["Node_Bank"].node["PassBankBtn"]

    self.Node_Ready = self.resourceNode_.node["Node_Ready"]
    self.tReady = {}

    for i=1, 5 do
        self.tReady[i] = self.resourceNode_.node["Node_Ready"].node["Ready_"..i]
    end

    self.Node_Score = self.resourceNode_.node["Node_Score"]
    self.tScore = {}
    for i=1, 5 do
        self.tScore[i] = self.resourceNode_.node["Node_Score"].node["Score_"..i]
    end
    self.Banker = self.resourceNode_.node["Banker"]
    self.Banker:setVisible(false)
    self.scehdule_updateClockTime = nil
    self.nTimeCount = 0
    self.scoreImg = { }
    self.tGetHead = {}

    self.head_bg_btn = { }
    for i=1,5 do 
        self.head_bg_btn[i] = self.resourceNode_.node["Node_Head"].node["Node_Head_"..i].node["IMG_HEAD_BG"]
    end 

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

    local tPoint = cc.p(385,265)
    -- 闹钟
	self.ClockBg = cc.Sprite:create("Common/clock.png")
	self.ClockBg:setPosition(tPoint)
	-- self.ClockBg:setOpacity(150)
    self.ClockBg:setVisible(false)
	self:addChild(self.ClockBg)

	self.ClockTime = ccui.TextAtlas:create("15","Common/clock_font.png",20,28,"0")
    self.ClockTime:setVisible(false)
	self:addChild(self.ClockTime)

	self.YaoQingBtn:setVisible(false)
    self.ReadyBtn:setVisible(false)
    self.CancelReadyBtn:setVisible(false)
    -- self.RoomInfoText:setVisible(true)
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

    self.ReplayBg:setVisible(false)

    self.Node_Btn:setVisible(false)
    for nIndex, pButton in ipairs(self.tScoreBtn) do
        pButton:setTag(nIndex)
    end

    self.Node_Ready:setVisible(true)
    for nIndex, pImage in ipairs(self.tReady) do
        pImage:setVisible(false)
    end

    self.Node_Score:setVisible(true)
    for nIndex, pScore in ipairs(self.tScore) do
        pScore:setVisible(false)
    end

    local x1 = self.Node1:getPositionX()
    local x2 = self.Node2:getPositionX()
    self.Node1:setPositionX(x1-300)
    self.Node2:setPositionX(x2+300)
end

function M:initTouch()
	self.YaoQingBtn:addClickEventListener(handler(self,self.Click_YaoQing))
    self.ReadyBtn:addClickEventListener(handler(self,self.Click_Ready))
    self.CancelReadyBtn:addClickEventListener(handler(self,self.Click_CancelReady))
    self.BeginBtn:addClickEventListener(handler(self,self.Click_Begin))

    self.NeedBankBtn:addTouchEventListener(handler(self,self.Click_NeedBank))
	self.PassBankBtn:addClickEventListener(handler(self,self.Click_PassBank))

    self.LuYinBtn:addTouchEventListener(handler(self,self.Click_LuYin))
	self.ChatBtn:addClickEventListener(handler(self,self.Click_Chat))
    self.Btn_AutoSuan:addClickEventListener(handler(self,self.Click_AutoSuan))

    for nIndex, pButton in ipairs(self.tScoreBtn) do
        pButton:addClickEventListener(handler(self, self.Click_Score))
    end

    self.BTN_BTS1:addClickEventListener(handler(self,self.showLeftBtns))
    self.BTN_BACK:addClickEventListener(handler(self,self.Click_Leave))
    self.BTN_DISMISS:addClickEventListener(handler(self,self.Click_Vote))

    self.BTN_BTS2:addClickEventListener(handler(self,self.showRightBtns))
    self.BTN_HELP:addClickEventListener(handler(self,self.Click_Help))
    self.BTN_SETTING:addClickEventListener(handler(self,self.Click_Set))

    self.PauseBtn:addClickEventListener(handler(self,self.Click_Pause))
    self.ExitBtn:addClickEventListener(handler(self,self.Click_Exit))
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

    if self.scehdule_replay ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_replay)
		self.scehdule_replay = nil
	end
end

-- 邀请
function M:Click_YaoQing()
    G_CommonFunc:addClickSound()
	local strContent = string.format("宁乡牛牛，房间号：%06d,%d人,%d局,来战啊！",G_Data.roomid, G_GameDefine.nPlayerCount, G_GameDefine.nTotalGameCount)
    ef.extensFunction:getInstance():wxInviteFriend(0, "好友@你", strContent, "", GameConfig.download_url.."?u="..G_Data.UserBaseInfo.userid)
end

-- 离开
function M:Click_Leave()
    G_CommonFunc:addClickSound()
    G_DeskScene:Click_Leave()
end

-- 解散
function M:Click_Vote()
    G_CommonFunc:addClickSound()
    G_DeskScene:Click_Vote()
end

-- 点击准备
function M:Click_Ready()
    if self.clicktime == nil then 
        self.clicktime = os.time()
        G_CommonFunc:addClickSound()
        G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_ReadyReq", {bAgree=true})
    else 
        local t = os.time()
        local dur =  t-self.clicktime  
        if dur<3  and t>0  then 
            G_CommonFunc:showGeneralTips(GameConfigManager.tGameID.PDK,"请3秒之后再操作",self,cc.p(display.cx,display.cy))
            return 
        end
        self.clicktime = t 
        G_CommonFunc:addClickSound()
        G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_ReadyReq", {bAgree=true})
    end
end

-- 取消准备
function M:Click_CancelReady()
    if self.clicktime == nil then 
        self.clicktime = os.time()
        G_CommonFunc:addClickSound()
        G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_ReadyReq", {bAgree=false})
    else 
        local t = os.time()
        local dur =  t-self.clicktime  
        if dur<3  and t>0  then 
            G_CommonFunc:showGeneralTips(GameConfigManager.tGameID.PDK,"请3秒之后再操作",self,cc.p(display.cx,display.cy))
            return 
        end
        self.clicktime = t 
        G_CommonFunc:addClickSound()
        G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_ReadyReq", {bAgree=false})
    end
end

-- 点击开始
function M:Click_Begin()
    --**获取当前人数是否进来了**
    local count = G_GameDefine.nPlayerCount
    if count <= 1 then 
        return 
    end 
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_BeginReq",{})
end

-- 抢庄
function M:Click_NeedBank()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_GameBankReq",{bNeed=true})
end

-- 不抢庄
function M:Click_PassBank()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_GameBankReq", {bNeed=false})
end

-- 聊天
function M:Click_Chat(sender, eventType)
    G_CommonFunc:addClickSound()
    G_DeskScene:setChatLayerVisible(true)
end

-- 设置
function M:Click_Set(sender, eventType)
    G_CommonFunc:addClickSound()
    G_DeskScene:showSetLayer()
end

--自动算牛
function M:Click_AutoSuan( sender, eventType )
    -- body
    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_GameSuanNiuReq",{})
    self.Btn_AutoSuan:setVisible(false)
end

-- 录音
function M:Click_LuYin(sender,eventType)
    G_CommonFunc:addClickSound()
	if eventType == ccui.TouchEventType.began then
        
		self.nStartTime = os.time()
		self.SpriteLuyin1:setVisible(true)
        --停止背景音乐
        G_GameDeskManager.Music:pauseBackMusic()
        if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
            
            local function callbackLua(url)
                if url then
                    self:stopRecord()

                    G_GameDeskManager.Music:resumeBackMusic()

                    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.VoiceChatReq",{voice=url})
                    
                    local userid=G_GamePlayer:getMainPlayer().userid

                    local recordStart = function( params )
                        -- body
                        
                        G_GameDeskManager.Music:pauseBackMusic()
                        if self.playRecordSp then 
                            self.playRecordSp:removeFromParent()
                        end 
                        self.playRecordSp = nil 


                        local actSpr = cc.Sprite:create("Voice/voice0.png")
                        local curAnimate = cc.Animation:create()
                        for i=0,3 do
                            curAnimate:addSpriteFrameWithFile("Voice/voice"..i..".png")
                        end
                        curAnimate:setDelayPerUnit(1/3)
                        curAnimate:setRestoreOriginalFrame(true)
                    
                        local curAction = cc.Animate:create(curAnimate)
                        actSpr:runAction(cc.RepeatForever:create(curAction)) 
                        self.playRecordSp = actSpr 

                        local seat = G_GamePlayer:getPlayerByUserId(userid).seat
                        local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
                        self.tHeadInfo[nLocalSeat].Node_Head:addChild(self.playRecordSp)
                        actSpr:setPosition(80,0)
                        if nLocalSeat == 1 or nLocalSeat == 4 or nLocalSeat == 5 then 

                        else 
                            --X轴反向
                            self.playRecordSp:setFlipX(true)
                        end 
                    end

                    local recordFinish = function( params )
                        -- body
                        
                        if self.playRecordSp then 
                            self.playRecordSp:removeFromParent()
                        end 
                        self.playRecordSp = nil 
                        G_GameDeskManager.Music:resumeBackMusic()
                    end

                    local args = {url,recordStart,recordFinish}
                    local sigs = "(Ljava/lang/String;II)V"
                    local luaj = require "cocos.cocos2d.luaj"
                    local className = "com/hnqp/pdkgame/AppActivity"
                    local ok = luaj.callStaticMethod(className,"playRecordByFile",args,sigs)
                    if not ok then
                        
                    end 


                end
            end
            local args = { callbackLua }
            local sigs = "(I)V"
            local luaj = require "cocos.cocos2d.luaj"
            local className = "com/hnqp/pdkgame/AppActivity"
            local ok = luaj.callStaticMethod(className,"record",args,sigs)
            if not ok then
                
            end
        elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then 
            local function callbackLua(url)
                
                self:stopRecord()
                G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.VoiceChatReq",{voice=url})

                G_GameDeskManager.Music:pauseBackMusic()
                local userid=G_GamePlayer:getMainPlayer().userid
                local recordStart = function( params )
                    
                    if self.playRecordSp then 
                        self.playRecordSp:removeFromParent()
                    end 
                    self.playRecordSp = nil 
                    local actSpr = cc.Sprite:create("Voice/voice0.png")
                    local curAnimate = cc.Animation:create()
                    for i=0,3 do
                        curAnimate:addSpriteFrameWithFile("Voice/voice"..i..".png")
                    end
                    curAnimate:setDelayPerUnit(1/3)
                    curAnimate:setRestoreOriginalFrame(true)
                    
                    local curAction = cc.Animate:create(curAnimate)
                    actSpr:runAction(cc.RepeatForever:create(curAction)) 
                    self.playRecordSp = actSpr 

                    local seat = G_GamePlayer:getPlayerByUserId(userid).seat
                    local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
                    self.tHeadInfo[nLocalSeat].Node_Head:addChild(self.playRecordSp)
                    actSpr:setPosition(80,0)
                    if nLocalSeat == 1 or nLocalSeat == 4 or nLocalSeat == 5 then 

                    else 
                        --X轴反向
                        self.playRecordSp:setFlipX(true)
                    end 
                end 
                local recordFinish = function( params ) 

                    
                    if self.playRecordSp then 
                        self.playRecordSp:removeFromParent()
                    end 
                    self.playRecordSp = nil 
                    G_GameDeskManager.Music:resumeBackMusic()
                end 
                local luaoc = require "cocos.cocos2d.luaoc"
                local className = "RootViewController"
                recordStart()
                luaoc.callStaticMethod(className,"playRecordByFile", { recordStart = recordStart,recordFinish = recordFinish } ) 
            end
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "RootViewController"
            luaoc.callStaticMethod(className,"record", {scriptHandler = callbackLua } ) 
        end

	elseif eventType == ccui.TouchEventType.moved then
        G_GameDeskManager.Music:resumeBackMusic()
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self.SpriteLuyin1:setVisible(false)
        G_GameDeskManager.Music:resumeBackMusic()
		if os.time() - self.nStartTime < 1 then
            self:stopRecord()
			return
		end
        self:stopRecord()
	end

end

function M:stopRecord(  )
    -- body
    -- G_GameDeskManager.Music:pauseBackMusic()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {}
        local sigs = "()V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/hnqp/pdkgame/AppActivity"
        local ok = luaj.callStaticMethod(className,"stopRecord",args,sigs)
        if not ok then
            
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then 
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "RootViewController"
        luaoc.callStaticMethod(className,"stopRecord", {  } ) 
    end 
end

-- 下注
function M:Click_Score(sender, eventType)
    --**判断总分**
    G_CommonFunc:addClickSound()
    local nTag = sender:getTag()
    local me = G_GamePlayer:getMainPlayer()
    local score = me.score 
    dump(score)
    if score < nTag*3 then 
        --玩家不可下注需要换注
        G_CommonFunc:showGeneralTips(GameConfigManager.tGameID.DGNN,"您当前底分不能下注当前筹码!",self,cc.p(display.cx,display.cy))
    else
        G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_CallScoreReq",{nScoreIndex = nTag})
        local sound = "res/Music/3/score/bet.mp3"
        G_GameDeskManager.Music:playSound(sound,false)
    end 
end

-- 默认聊天回复
function M:handleChatAck(tInfo)
	local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
    if nLocalSeat ~= 1 then
        -- 显示聊天信息
        G_DeskScene:ShowChatInfo(nLocalSeat,tInfo.nMsgID,tInfo.text)
    end
end

-- 玩家进入
function M:handlePlayerEnterAck(msg)
    
    -- 显示玩家信息
    self:ShowUserInfo(msg.userData.seat, true)
    -- 设置玩家分数
    self:SetUserScore(msg.userData.seat,msg.userData.score)
    --
    self:SetUserDataScore(msg.userData.seat,msg.userData.score)
    -- 设置玩家名称
    self:SetUserName(msg.userData.seat,msg.userData.nickname)
    --是否准备
    self:SetReady(msg.userData.seat,msg.userData.ready)
end

function M:SetUserDataScore(nServerSeat,score)
    -- body
    local _player = G_GamePlayer:getPlayerBySeverSeat(nServerSeat)
    _player.score = score
end

-- 玩家离开
function M:handlePlayerLeaveAck(msg)
    -- 显示玩家信息
    self:ShowUserInfo(msg.nSeat, false)
    --显示准备状态
    self:SetReady(msg.nSeat, false)
    
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nSeat)
    self.tGetHead[nLocalSeat] = false 

    -- 删除玩家
    G_GamePlayer:removePlayerBySeat(msg.nSeat)
    G_GameDefine.nPlayerCount = G_GamePlayer:getPlayerCount()
end

-- 玩家离开游戏
function M:handleLeaveGameAck(tInfo)
	-- 显示玩家信息
    self:ShowUserInfo(tInfo.wChairID, false)

    -- 设置玩家准备状态
    self:SetReady(tInfo.wChairID, false)
end

-- 进入游戏
function M:handleEnterGameAck(msg)
    if EventConfig.CHECK_IOS then 
        self.YaoQingBtn:setVisible(false)
        if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then

        else
            self.IMG_Jiangchi:setVisible(true)
        end
    else 
        if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then
            self.YaoQingBtn:setVisible(true)
        else
            self.YaoQingBtn:setVisible(false)
            self.IMG_Jiangchi:setVisible(true)
        end
    end 
    self.BeginBtn:setVisible(false)
    self.Text_Fang_V:setString(G_Data.roomid)
    self.Text_Ju_V:setString( "第"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")
end

function M:initRoomInfo(msg, bReady)
    self.IMG_Jiangchi:setVisible(false)
    if msg.bank_seat and msg.bank_seat ~= 0 then
        self.IMG_Jiangchi:setVisible(true)
        self:changeScore(self.Text_LeijiScore,msg.bank_score)
        self:setBankerUser(msg.bank_seat,true)
    end 
    if not bReady then
        self:setClockTime(true)
    
        --隐藏开始
        self.BeginBtn:setVisible(false)
        self.ReadyBtn:setVisible(false)
        self.CancelReadyBtn:setVisible(false)
    else
        self:setClockTime(false)
    end

    for _,p in pairs(msg.players) do
        if p.seat == msg.bank_seat then
            local szName = p.nickname
            local len = string.len(szName)
            if len>12 then 
                szName = string.sub(szName,1,12).."..."
            end 
            self.Text_Name:setString(szName)
            --设置头像
            if p ~= nil then
                local url = p.headimgurl
                local nSeat = G_GamePlayer:getLocalSeat(p.seat)
                self.tReady[nSeat]:setVisible(false)
                if url and string.len(url) > 1 then
                    local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead"..p.userid..".png"
                    local f = cc.FileUtils:getInstance():isFileExist(saveName) 
                    local nHeadSize = 47.85
                    if f == true then
                        if self.IMG_HEAD_ICON ~= nil then
                            self.IMG_HEAD_ICON:loadTexture(saveName)
                            local width = self.IMG_HEAD_ICON:getContentSize().width
                            local height = self.IMG_HEAD_ICON:getContentSize().height
                            self.IMG_HEAD_ICON:setScale(nHeadSize/width, nHeadSize/height)
                        end
                    else
                        local msg = {seat = p.seat, saveName = saveName}
                        G_CommonFunc:httpForImg(url, saveName,function(tMsg, bSuccess)
                            if not bSuccess then
                                local nLocalSeat = tMsg.seat
                                self.tHeadInfo[nLocalSeat].HeadSprite:setTexture(cc.Director:getInstance():getTextureCache():addImage("Common/img_head.png"))
                                return
                            end
                            -- body
                            self.IMG_HEAD_ICON:loadTexture(saveName)
                            local width = self.IMG_HEAD_ICON:getContentSize().width
                            local height = self.IMG_HEAD_ICON:getContentSize().height
                            self.IMG_HEAD_ICON:setScale(nHeadSize/width, nHeadSize/height)
                        end, msg) 
                    end
                end
            end
            break
        end 
    end
end

function M:initRoomTitle()
    -- body
    self.Text_Fang_V:setString(G_Data.roomid)
    self.Text_Ju_V:setString("第"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")
end

function M:showPlayer(seat1,p,ready)
    self:ShowUserInfo(seat1,true)
    self:SetUserScore(seat1,p.score)
    self:SetUserName(seat1,p.nickname)
    self:SetReady(seat1,ready)
end

-- 玩家准备
function M:handleReadyAck(tInfo)
    local nServerSeat = G_GamePlayer:getServerSeat(1)
	print(nServerSeat, tInfo.wChairID)
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

-- 游戏开始
function M:handleGameStartAck(tInfo)

    --**玩家这两个信息先清除掉**
    local allPlayers = G_GamePlayer.players
    for k,v in pairs(allPlayers) do 
        v.callscore = 0
        v.cards = { }
    end 
    self.hasXiazhu = false 
	self.YaoQingBtn:setVisible(false)
    self:SetReadyBtn(0,false)
    self.Text_Fang_V:setString(G_Data.roomid)
    self.Text_Ju_V:setString("第"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")
    --协议已经改动不可使用...
    -- 设置庄家
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
    -- 隐藏开始按钮
    self.BeginBtn:setVisible(false)
    self.IMG_Jiangchi:setVisible(true)

    --所有的准备状态变为false 
    for nIndex, pImage in ipairs(self.tReady) do
        pImage:setVisible(false)
    end
    --显示压庄
    self.isShowAuto = false
    self.Btn_AutoSuan:setVisible(false) 
    for k,v in pairs(self.scoreImg) do 
        v:removeFromParent()
    end 
    self.scoreImg = { }
    self:switchZhuangAnims()
    if self.isBanker_ then
        G_DeskScene:showEmptyCard(handler(self,self.showScore))
    else 
        local me = G_GamePlayer:getMainPlayer()
        local score = me.score 
        if score<3 then
            --隐藏下注按钮
            self.Node_Btn:setVisible(false)
            self:showOutMode(true)
            G_CommonFunc:showGeneralTips(GameConfigManager.tGameID.DGNN,"您当前底分不足进入观看模式",self,cc.p(display.cx,display.cy))
            G_DeskScene:showEmptyCard(handler(self,self.showScore))
        else 
            G_DeskScene:showEmptyCard(handler(self,self.showScore))
        end
    end
    for k,v in pairs(allPlayers) do
        local seat = v.seat
        local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
        local head_bg_btn_ =  self.head_bg_btn[nLocalSeat]
        if head_bg_btn_.info then 

        else 
            head_bg_btn_.info = v
            head_bg_btn_:addClickEventListener(handler(self,self.Click_User_Info))                                 
        end 
    end 
end

function M:showScore( )
    -- body 
    if self.isBanker_ then 
        self.Node_Btn:setVisible(false)
    else     
        self.Node_Btn:setVisible(true)
        if self.hasXiazhu == true then 
            self.Node_Btn:setVisible(false)
        else 
            self.Node_Btn:setVisible(true)
        end 
    end
    local me = G_GamePlayer:getMainPlayer()
    local score = me.score 
    if score<3 then
        self:showOutMode(true)
        self.Node_Btn:setVisible(false)
    end 
end

function M:makeScores( nLocalSeat,number )
    -- body
    local pos1 = nil
    if number > 5 then 
        number = 5
    end
    local middle = math.floor(number/2)
    if number%2==0 then 
    else
        middle = middle+1 
    end 
    for i=1,number do 
        local imageView = ccui.ImageView:create()
        imageView:loadTexture("nnResult_img_pyq_chip_1.png", ccui.TextureResType.plistType)
        self:addChild(imageView)
        self.scoreImg[#self.scoreImg+1] = imageView
        local pos = cc.p(568,180+(i-1)*4)
        if nLocalSeat == 1 then 
            pos = cc.p(568,180+(i-1)*4)
        elseif nLocalSeat == 2 then
            pos = cc.p(908,280+(i-1)*4)
        elseif nLocalSeat == 3 then
            pos = cc.p(650,420+(i-1)*4)
        elseif nLocalSeat == 4 then
            pos = cc.p(450,420+(i-1)*4)
        elseif nLocalSeat == 5 then
            pos = cc.p(148,340+(i-1)*4)
        end
        if i==middle then 
            pos1 = pos
        end 
        imageView:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end))) 
    end
    --添加数值
    if pos1 then 
        local tips = G_CommonFunc:showScoreTips(number,self,cc.p(pos1.x+45,pos1.y))
        self.scoreImg[#self.scoreImg+1] = tips
    end 
end

-- 下注消息
function M:handleCallScoreAck(tInfo)
    local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.nCallScoreUser)
    if nLocalSeat == 1 then
        self.Node_Btn:setVisible(false)
    end
    local call = function( )    
        -- body
        --**可以显示自动算牛**
        self.isShowAuto = true 
    end
    --开始翻牌
    if #tInfo.cards>0 then
        
        if self.isBanker_ == true then 
            local delay =cc.DelayTime:create(0.2)
            local function callEnd()
                G_DeskScene:ShowEndCardSimple(1,tInfo.cards,call)    
            end
            local seq = cc.Sequence:create(delay,cc.CallFunc:create(callEnd))
            self:runAction(seq)
        else 
            G_DeskScene:ShowEndCardSimple(1,tInfo.cards,call)    
        end
    end
    self.ReadyBtn:setVisible(false)
    self.CancelReadyBtn:setVisible(false)
    if nLocalSeat == 1 and self.isBanker_  then 
        self.tScore[nLocalSeat]:setVisible(false)  
    else
        self.tScore[nLocalSeat]:setString(tInfo.nCallScore)    
        self.tScore[nLocalSeat]:setVisible(false)
        self:makeScores(nLocalSeat,tInfo.nCallScore)
    end 

end

-- 抢庄消息
function M:handleBeginBankAck(tInfo)

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
    self.IMG_Jiangchi:setVisible(true)
end

-- 抢庄消息
function M:handleGameBankAck(tInfo)
    local nLocalSeat = G_GamePlayer:getLocalSeat(tInfo.wChairID)
    if nLocalSeat == 1 then
        self.NeedBankBtn:setVisible(false)
        self.PassBankBtn:setVisible(false)
    end
end

-- 游戏结束消息
function M:handleGameEndAck(tInfo)
    -- 隐藏闹钟
    self:setClockTime(false)
	-- 设置分数

	for _, info in ipairs(tInfo.infos) do
        local nLocalSeat = G_GamePlayer:getLocalSeat(info.seat)
        local posx = self.tScore[nLocalSeat]:getPositionX()-20
        local posy = self.tScore[nLocalSeat]:getPositionY()+60
        if info.score ~=0 then
            self:SetUserScore(info.seat,info.total_score)
            self:SetUserDataScore(info.seat,info.total_score)
            G_CommonFunc:showSmallTips(info.score,self.Node_Score,cc.p(posx,posy),function( ... )
                -- body
            end)
	    end 
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
function M:ShowUserInfo(nServerSeat,bVisible)
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].Node_Head:setVisible(bVisible)
    self.tHeadInfo[nLocalSeat].Node_Head:setOpacity(255)
    self.tHeadInfo[nLocalSeat].offLine:setVisible(false)
    self.tReady[nLocalSeat]:setVisible(false)
    if nLocalSeat == 0 then
        for i = 1, G_GameDefine.nMaxPlayerCount do
            local nSeat = G_GamePlayer:getLocalSeat(i)
            if not self.tGetHead[nSeat] then
                local _player = G_GamePlayer:getPlayerBySeat(nSeat)
                if _player ~= nil then
                    local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
                    local msg = {seat = nSeat, saveName = saveName}
                    if cc.FileUtils:getInstance():isFileExist(saveName) then
                        self:getHeadImg(msg, true)
                    end
                    local url = _player.headimgurl
                    if url and string.len(url) > 1 then
                        G_CommonFunc:httpForImg(url, saveName, handler(self, self.getHeadImg), msg)
                    else 
                        self.tHeadInfo[nLocalSeat].HeadSprite:setTexture(cc.Director:getInstance():getTextureCache():addImage("Common/img_head.png"))
                    end
                end
            end
        end 
    else
        if not self.tGetHead[nLocalSeat] then
            local _player = G_GamePlayer:getPlayerBySeat(nLocalSeat)
            if _player ~= nil then
                local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
                local msg = {seat = nLocalSeat, saveName = saveName}
                if cc.FileUtils:getInstance():isFileExist(saveName) then
                    self:getHeadImg(msg, true)
                end
                local url = _player.headimgurl
                if url and string.len(url) > 0 then
                    G_CommonFunc:httpForImg(url, saveName, handler(self, self.getHeadImg), msg)
                else
                    self.tHeadInfo[nLocalSeat].HeadSprite:setTexture(cc.Director:getInstance():getTextureCache():addImage("Common/img_head.png"))
                end
            else 
                
            end
        end 
    end
end

-- 取得头像
function M:getHeadImg(msg, bSuccess)
    if not bSuccess  then
        local nLocalSeat = msg.seat
        self.tHeadInfo[nLocalSeat].HeadSprite:setTexture(cc.Director:getInstance():getTextureCache():addImage("Common/img_head.png"))    
        return
    end
    local nLocalSeat = msg.seat
    self.tGetHead[nLocalSeat] = true
    local nHeadSize = 82.5
    if self.tHeadInfo[nLocalSeat].HeadSprite ~= nil then
        self.tHeadInfo[nLocalSeat].HeadSprite:setTexture(msg.saveName)
        local width = self.tHeadInfo[nLocalSeat].HeadSprite:getContentSize().width
        local height = self.tHeadInfo[nLocalSeat].HeadSprite:getContentSize().height
        self.tHeadInfo[nLocalSeat].HeadSprite:setScale(nHeadSize/width, nHeadSize/height)
    end 
end

-- 设置玩家名字
function M:SetUserName(nServerSeat,szName)
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    local len = string.len(szName)
    if len>12 then 
        szName = string.sub(szName,1,12).."..."
    end
    self.tHeadInfo[nLocalSeat].NameText:setString(szName)
end

-- 设置玩家分数
function M:SetUserScore(nServerSeat, nScore)
    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tHeadInfo[nLocalSeat].ScoreText:setString(nScore)
    --玩家身上的分数进行重新赋值

end

-- 设置庄家
function M:setBankerUser(nServerSeat, bShow)
    self.Banker:setVisible(bShow)
    if not bShow then
        return
    end
    local tPoint = {cc.p(91, 133),cc.p(1110, 419),cc.p(944, 556),cc.p(312,602), cc.p(28, 419)}
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
        self.ClockTime:setString("0")
        --self.ClockBg:setVisible(false)
        --self.ClockTime:setVisible(false)
        --警告的音效
        local sound = "Music/3/score/bellx2final.wav"
        G_GameDeskManager.Music:playSound(sound,false)
		if self.scehdule_updateClockTime ~= nil then
			scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
			self.scehdule_updateClockTime = nil
		end
	else
		self.ClockTime:setString(string.format("%d", self.nTimeCount))
	end
end

function M:showBeginBtn( status )
    -- body
    if status == true then 
        self.BeginBtn:setVisible(true)
        self.ReadyBtn:setVisible(false)
        self.CancelReadyBtn:setVisible(false)
        -- self.IMG_Jiangchi:setVisible(true)
    end   
end

function M:showReadyBtn( msg , master_id )
    -- body
    for k,v in pairs(msg.players) do
        if v.userid == G_GamePlayer:getMainPlayer().userid then
            if v.ready == true then
                self.ReadyBtn:setVisible(false)
                self.CancelReadyBtn:setVisible(true)
            else 
                self.ReadyBtn:setVisible(true)
                self.CancelReadyBtn:setVisible(false)
            end
            break
        end 
    end 
end

function M:changeScore(lable,endNum)
    -- body
    local taction = { }
    local delay =cc.DelayTime:create(0.01)
    table.insert(taction,delay)
    local _beginNum = tonumber(lable:getString())
    local _endNum = endNum
    math.randomseed(3000)
    local  _dis = math.random(0,_endNum-_beginNum)
    local rtime = (_endNum-_beginNum)/_dis
    local posX = lable:getPositionX()
    local posY = lable:getPositionY()
    local X = posX
    local Y = posY
    local X1 = 130  
    local Y1 = 43
    local function chagenum()
        if (_beginNum <  _endNum) then
           _beginNum= _beginNum +_dis
           lable:setString(_beginNum)
        elseif (_beginNum ==  _endNum) then
            lable:setString(_endNum)
            lable:setPosition(X1,Y1)
        end
    end
    local seq = cc.Sequence:create(delay,cc.CallFunc:create(chagenum))
    --分数转动
    local size = lable:getContentSize()
    local UPY = 2.0*Y
    local DownY = 0.1*Y
    local move1 = cc.MoveTo:create(0.05,cc.p(X,UPY))
    local move2 = cc.MoveTo:create(0.05,cc.p(X,DownY))
    local move3 = cc.MoveTo:create(0.05,cc.p(X,Y))

    local scale1 = cc.ScaleTo:create(0.05,1,0.001)
    local scale2 = cc.ScaleTo:create(0.05,1,1)

    local UP =   cc.Sequence:create(move1,scale1)
    local Down =   cc.Sequence:create(move2,scale1,scale2,move3)
    local spawn = cc.Spawn:create(UP,seq,Down)
    local rep = cc.Repeat:create(spawn,1)
    --设置真值
    local function setnum()
        _beginNum =  _endNum
        lable:setString(_beginNum)
        lable:setPosition(X1,Y1)
    end
    local call = cc.CallFunc:create(setnum)
    local seq2 = cc.Sequence:create(rep,delay,call)
    table.insert(taction,seq2)
    local seqaction = cc.Sequence:create(taction)
    lable:runAction(seqaction)

    --add音效
    local sound = "Music/3/score/score.mp3"
    G_GameDeskManager.Music:playSound(sound,false)

end

--上庄
function M:handleGameShangZhuangAck(msg)
    G_GameDefine.nGameCount = 0
    self.Text_Ju_V:setString("第"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")
    self:changeScore(self.Text_LeijiScore,msg.bank_score)
    
    self:SetUserScore(msg.bank_user_seat,msg.bank_user_score)
    self:SetUserDataScore(msg.bank_user_seat,msg.bank_user_score)
    

    self.wBankerUser = msg.bank_user_seat
    self.isBanker_ = (G_GamePlayer:getMainPlayer().seat == self.wBankerUser)

    self.tScore[msg.bank_user_seat]:setVisible(false)

    local playerInfo = G_GamePlayer:getPlayerBySeverSeat(msg.bank_user_seat)
    self.banker_userId = playerInfo.userid
    local szName = playerInfo.nickname
    local len = string.len(szName)
    if len>12 then 
        szName = string.sub(szName,1,12).."..."
    end
    self.Text_Name:setString(szName)

    local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead"..playerInfo.userid..".png"
    local f = cc.FileUtils:getInstance():isFileExist(saveName) 
    if f == true then
        local nHeadSize = 47.85
        if self.IMG_HEAD_ICON ~= nil then
            self.IMG_HEAD_ICON:loadTexture(saveName)
            local width = self.IMG_HEAD_ICON:getContentSize().width
            local height = self.IMG_HEAD_ICON:getContentSize().height
            self.IMG_HEAD_ICON:setScale(nHeadSize/width, nHeadSize/height)
        end
    else 
        --恢复默认头像
        self.IMG_HEAD_ICON:loadTexture("img_head.png", ccui.TextureResType.plistType)
    end

end



--下庄
function M:handleGameXiaZhuangAck(  msg )
    -- body
    dump("handleGameXiaZhuangAck")
    self:SetUserScore(msg.old_bank_user_seat,msg.old_bank_user_score)
    self:SetUserDataScore(msg.old_bank_user_seat,msg.old_bank_user_score)
    self.old_bank_user_seat = msg.old_bank_user_seat
    self.tScore[msg.old_bank_user_seat]:setVisible(false)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.old_bank_user_seat)
    local x = self.tHeadInfo[nLocalSeat].Node_Head:getPositionX()
    local y = self.tHeadInfo[nLocalSeat].Node_Head:getPositionY()

    -- 下庄玩家显示准备相关
    self:SetReady(msg.old_bank_user_seat, true)
    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if nServerSeat == msg.old_bank_user_seat then
        -- 显示玩家准备按钮相关
        self:SetReadyBtn(true, true)
    end
end

function M:switchZhuangAnims()
    -- body
    local tPoint = {cc.p(91, 133),cc.p(1110, 419),cc.p(944, 556),cc.p(312,602), cc.p(28, 419)}
    local nLocalSeat = G_GamePlayer:getLocalSeat(self.wBankerUser)
    local pos = tPoint[nLocalSeat]
    if self.old_bank_user_seat == nil then 
        self.Banker:setVisible(true)
        self.Banker:setPosition(pos)
        return 
    end
    if self.old_bank_user_seat == self.wBankerUser then 
        self.Banker:setVisible(true)
        self.Banker:setPosition(pos)
        return 
    end  
    self.Banker:setVisible(true)
    self.Banker:runAction(cc.Sequence:create(cc.MoveTo:create(1.5,pos),cc.CallFunc:create(function()
        
    end))) 
    self.IMG_SwitchZhuang:setVisible(true)
    local action = cc.Sequence:create(cc.FadeIn:create(0.5),cc.FadeOut:create(0.4))
    self.IMG_SwitchZhuang:runAction(action)
    self.old_bank_user_seat = self.wBankerUser
end

function M:setAllScore( score,tInfo )
    -- body
    self:changeScore(self.Text_LeijiScore,score)
end


function M:isBanker( )
    -- body
    return self.isBanker_
end

function M:bankerId(  )
    -- body
    return self.wBankerUser
end

function M:handleVoiceChatAck( msg )
    -- body
    local userid = msg.userid
    local url = msg.voice
    if (cc.PLATFORM_OS_ANDROID == targetPlatform   ) then

        local recordStart = function( params )
            -- body
             G_GameDeskManager.Music:pauseBackMusic()
            if self.playRecordSp then 
                self.playRecordSp:removeFromParent()
            end 
            self.playRecordSp = nil 

            local actSpr = cc.Sprite:create("Voice/voice0.png")
            local curAnimate = cc.Animation:create()
            for i=0,3 do
                curAnimate:addSpriteFrameWithFile("Voice/voice"..i..".png")
            end
            curAnimate:setDelayPerUnit(1/3)
            curAnimate:setRestoreOriginalFrame(true)

            local curAction = cc.Animate:create(curAnimate)
            actSpr:runAction(cc.RepeatForever:create(curAction)) 
            self.playRecordSp = actSpr 

            local seat = G_GamePlayer:getPlayerByUserId(userid).seat
            local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
            self.tHeadInfo[nLocalSeat].Node_Head:addChild(self.playRecordSp)
            if nLocalSeat == 1 or nLocalSeat == 4 or nLocalSeat == 5 then 
                self.playRecordSp:setPosition(80,0)
            else 
                --X轴反向
                self.playRecordSp:setPosition(-80,0)
                self.playRecordSp:setFlipX(true)
            end 
        end

        local recordFinish = function( params )
            -- body
            if self.playRecordSp then 
                self.playRecordSp:removeFromParent()
            end 
            self.playRecordSp = nil
            G_GameDeskManager.Music:resumeBackMusic()
        end

        local args = {url,recordStart,recordFinish}
        local sigs = "(Ljava/lang/String;II)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/hnqp/pdkgame/AppActivity"
        local ok = luaj.callStaticMethod(className,"playRecord",args,sigs)
        if not ok then
            
        end 
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then 

         local recordStart = function( params )
            
            G_GameDeskManager.Music:pauseBackMusic()
            if self.playRecordSp then 
                self.playRecordSp:removeFromParent()
            end 
            self.playRecordSp = nil 
            local actSpr = cc.Sprite:create("Voice/voice0.png")
            local curAnimate = cc.Animation:create()
            for i=0,3 do
                curAnimate:addSpriteFrameWithFile("Voice/voice"..i..".png")
            end
            curAnimate:setDelayPerUnit(1/3)
            curAnimate:setRestoreOriginalFrame(true)
                    
            local curAction = cc.Animate:create(curAnimate)
            actSpr:runAction(cc.RepeatForever:create(curAction)) 
            self.playRecordSp = actSpr 

            local seat = G_GamePlayer:getPlayerByUserId(userid).seat
            local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
            self.tHeadInfo[nLocalSeat].Node_Head:addChild(self.playRecordSp)
            actSpr:setPosition(80,0)
            if nLocalSeat == 1 or nLocalSeat == 4 or nLocalSeat == 5 then 
                self.playRecordSp:setPosition(80,0)
            else 
                --X轴反向
                self.playRecordSp:setPosition(-80,0)
                self.playRecordSp:setFlipX(true)
            end 
        end 
        local recordFinish = function( params ) 

                
                if self.playRecordSp then 
                    self.playRecordSp:removeFromParent()
                end 
                self.playRecordSp = nil 
                 G_GameDeskManager.Music:resumeBackMusic()
        end 
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "RootViewController"
        recordStart()
        luaoc.callStaticMethod(className,"playRecord", { recordStart = recordStart,recordFinish = recordFinish,url=url } ) 
    end
end

function M:handleGameSuanNiuBeginAck(  )
    -- body
    --显示那个自动算牛的按钮
    local me = G_GamePlayer:getMainPlayer()
    local score = me.score 
    if score<3 then
        self.Btn_AutoSuan:setVisible(false)
    else
        self.Btn_AutoSuan:setVisible(true)
    end 
end

--自动算牛的结果
function M:handleGameSuanNiuAck( msg )
    -- body
    local seat = msg.seat 
    local cards = msg.cards 
    local type = msg.type
    local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
    if #cards>0  then
        G_DeskScene:ShowEndCardAuto(nLocalSeat,cards,type,seat) 
    end
end

--断线通知
function M:handleUserOfflineAck( msg )
    -- body
    local userid = msg.userid 
    local player = G_GamePlayer:getPlayerByUserId(userid)
    if player == nil then 
        return 
    end 
    local nLocalSeat = G_GamePlayer:getLocalSeat(player.seat)
    self.tHeadInfo[nLocalSeat].Node_Head:setOpacity(80)
    self.tHeadInfo[nLocalSeat].offLine:setVisible(true)
    --ready -- offline
    self:SetReady(player.seat,false)
end

function M:showCathecticBtn( msg )
    -- body
    -- 判断自己是否已经下注
    self:hideAllPlayerReady()
    self:hideAllBtns()
    --显示cards bg
    local mainPlayer = G_GamePlayer:getMainPlayer()
    local hasXiazhu = false

    if mainPlayer.callscore and mainPlayer.callscore>0 then 
        hasXiazhu = true 
    end
    self.hasXiazhu = hasXiazhu

    G_DeskScene:showEmptyCard(function()
        -- body 
        if self.isBanker_ then 
            self.Node_Btn:setVisible(false)
        else     
            self.Node_Btn:setVisible(true)
            if self.hasXiazhu == true then 
                self.Node_Btn:setVisible(false)
            else 
                self.Node_Btn:setVisible(true)
            end 
        end
        local me = G_GamePlayer:getMainPlayer()
        local score = me.score 
        if score<3 then
            --隐藏下注按钮
            self:showOutMode(true)
            self.Node_Btn:setVisible(false)
        end 

        --开始翻牌
        for _,p in ipairs(msg.players) do
            local nLocalSeat = G_GamePlayer:getLocalSeat(p.seat)
            if p.callscore and p.callscore>0 then 
                --显示卡牌
                self:makeScores(nLocalSeat,p.callscore)
                --显示下注的数目
            end
            if p and p.cards and #p.cards>0 then
                
                G_DeskScene:ShowEndCardSimple(nLocalSeat,p.cards,function()
                        -- body

                end)
            end  
        end

    end)
end

function M:showAutoBtn(msg)
    -- body
    self:hideAllPlayerReady()
    self:hideAllBtns()
    G_DeskScene:showEmptyCard(function( )
        -- body
        --显示cards value
        local mePlayer = nil 
        local call = function( )
            -- body
            self.isShowAuto = true
            if mePlayer and mePlayer.suanniu == true then 
                self.Btn_AutoSuan:setVisible(false)
            else 
                self.Btn_AutoSuan:setVisible(true)
                local score = mePlayer.score 
                if score<3 then
                    self.Btn_AutoSuan:setVisible(false)
                else
                    self.Btn_AutoSuan:setVisible(true)
                end 
            end
        end
        --开始翻牌
        for _,p in ipairs(msg.players) do
            --显示下注的数目
            local nLocalSeat = G_GamePlayer:getLocalSeat(p.seat)
            if p and p.callscore then 
                self:makeScores(nLocalSeat,p.callscore)
            end 
            local isMe = p.userid == G_GamePlayer:getMainPlayer().userid
            if #p.cards > 0 then 
                --显示卡牌
                G_DeskScene:ShowEndCardSimple(nLocalSeat,p.cards,function(  )
                    -- body
                    if p.suanniu == true then 
                        G_DeskScene:ShowEndCardAuto(nLocalSeat,p.cards,p.type,p.seat)  
                    end 
                    if isMe then 
                        call()
                    end
                end)
            else 
                --显示背景
            end
            if isMe then
                mePlayer = p 
            end
        end
    end)
end

--隐藏所有的准备状态
function M:hideAllPlayerReady( )
    -- body
    for nIndex, pImage in ipairs(self.tReady) do
        pImage:setVisible(false)
    end
end

function M:hideAllBtns(  )
    -- body
    self.YaoQingBtn:setVisible(false)
    self.CancelReadyBtn:setVisible(false)
end

function M:makeScores1( nLocalSeat,number )
    -- body
    local pos1 = nil
    if number > 5 then 
        number = 5
    end
    local middle = math.floor(number/2)
    if number%2==0 then 
    else
        middle = middle+1 
    end 
    for i=1,number do 
        local imageView = ccui.ImageView:create()
        imageView:loadTexture("nnResult_img_pyq_chip_1.png", ccui.TextureResType.plistType)
        self:addChild(imageView)
        imageView:setPosition(cc.p(568,420))
        self.scoreImg[#self.scoreImg+1] = imageView
        local pos = cc.p(568,180+(i-1)*4) 
        if nLocalSeat == 1 then 
            pos = cc.p(568,180+(i-1)*4)
        elseif nLocalSeat == 2 then
            pos = cc.p(908,300+(i-1)*4)
        elseif nLocalSeat == 3 then
            pos = cc.p(700,400+(i-1)*4)
        elseif nLocalSeat == 4 then
            pos = cc.p(500,400+(i-1)*4)
        elseif nLocalSeat == 5 then
            pos = cc.p(208,300+(i-1)*4)
        end
        if i==middle then 
            pos1 = pos
        end 
        imageView:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end))) 
    end
    --添加数值
    -- if pos1 then 
    --     G_CommonFunc:showScoreTips(number,self,cc.p(pos1.x+45,pos1.y))
    -- end 
end

function M:makeScores2( nLocalSeat,number )
    -- body
    local pos1 = nil
    if number > 5 then 
        number = 5
    end
    local middle = math.floor(number/2)
    if number%2==0 then 
    else
        middle = middle+1 
    end  
    for i=1,number do 
        local imageView = ccui.ImageView:create()
        imageView:loadTexture("nnResult_img_pyq_chip_1.png", ccui.TextureResType.plistType)
        self:addChild(imageView)
        self.scoreImg[#self.scoreImg+1] = imageView
        local pos = cc.p(568,180+(i-1)*4)
        if nLocalSeat == 1 then 
            pos = cc.p(568,180+(i-1)*4)
        elseif nLocalSeat == 2 then
            pos = cc.p(908,300+(i-1)*4)
        elseif nLocalSeat == 3 then
            pos = cc.p(700,400+(i-1)*4)
        elseif nLocalSeat == 4 then
            pos = cc.p(500,400+(i-1)*4)
        elseif nLocalSeat == 5 then
            pos = cc.p(208,300+(i-1)*4)
        end
        if i==middle then 
            pos1 = pos
        end
        imageView:setPosition(pos) 
        imageView:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(488,340+i*4)),cc.CallFunc:create(function()

        end))) 
    end
    --添加数值
    -- if pos1 then 
    --     G_CommonFunc:showScoreTips(number,self,cc.p(pos1.x+45,pos1.y))
    -- end 
end


--执行动画
function M:handleAnimas(tInfo,call)
    -- body
    local x = 568
    local y = 420
    local func = nil 
    local count = 0 
    func = function()
        -- body
        for _, info in ipairs(tInfo.infos) do
            local seat = info.seat
            local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
            if seat == self.wBankerUser then 
                --庄家不处理
            else 
                if info.score > 0  then
                    count = count + 1
                    self:makeScores1(nLocalSeat,info.score)
                   --移动到赢的玩家的位置
                elseif info.score < 0 then
                    count = count + 1 
                    self:makeScores2(nLocalSeat,math.abs(info.score)) 
                else 

                end 
                local sound = "Music/3/score/movechips.mp3"
                G_GameDeskManager.Music:playSound(sound,false)
            end

        end  
    end
    func()
    local action = cc.Sequence:create(cc.DelayTime:create(0.5*(count+1)),cc.CallFunc:create(function()
        if call then 
            call()
        end 
    end))
    self:runAction(action) 
end

function M:clearDeak()
    for k,v in pairs(self.scoreImg) do 
        v:removeFromParent()
    end 
    self.scoreImg = { }
end

function M:Click_Help()
    G_CommonFunc:addClickSound()
    G_CommonFunc:startGame()
end

function M:showLeftBtns()
    G_CommonFunc:addClickSound()
    if not self.selectLeft then 
        self.selectLeft = true
    else 
        self.selectLeft = not self.selectLeft
    end

    if self.selectLeft then 
        self.BTN_BTS1:loadTexture("left-2.png", ccui.TextureResType.plistType)
        local x = 49
        local y = 537
        local pos = cc.p(x,y)
        self.Node1:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end))) 

    else 
        self.BTN_BTS1:loadTexture("left-1.png", ccui.TextureResType.plistType)
        local x = self.Node1:getPositionX() - 300
        local y = 537 
        local pos = cc.p(x,y)
        self.Node1:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end))) 
    end 

end

function M:showRightBtns(  )
    -- body
    G_CommonFunc:addClickSound()
    if not self.selectRight then 
        self.selectRight = true
    else 
        self.selectRight = not self.selectRight
    end
    if self.selectRight then 
        self.BTN_BTS2:loadTexture("right-2.png", ccui.TextureResType.plistType)
        local x = 1030
        local y = 537
        local pos = cc.p(x,y)
        self.Node2:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end)))
    else
        self.BTN_BTS2:loadTexture("right-1.png", ccui.TextureResType.plistType)
        local x = self.Node2:getPositionX() + 300
        local y = 537 
        local pos = cc.p(x,y)
        self.Node2:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end))) 
    end 
end

function M:replayPrepare()
    G_Data.roomid = G_Data.ReplayData.head.room_id
    self.Text_Fang_V:setString(G_Data.roomid)

    G_GameDefine.nTotalGameCount = 15
    self.Text_Ju_V:setString("第"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

    self.BTN_BTS1:setVisible(false)
    self.BTN_BTS2:setVisible(false)

    self.LuYinBtn:setVisible(false)
	self.ChatBtn:setVisible(false)

    self.ReplayBg:setVisible(true)

    local msg = G_Data.ReplayData
    for i = 1, G_GameDefine.nMaxPlayerCount do
        local p = G_GamePlayer:getPlayerBySeverSeat(i)
        if p ~= nil then
            -- 显示玩家信息
            self:ShowUserInfo(i, true)
            -- 设置玩家分数
            self:SetUserScore(i, p.score)
            -- 设置玩家名称
            self:SetUserName(i, p.nickname)
            --是否准备
            self:SetReady(i, p.ready)
        end
    end

    if self.scehdule_replay ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_replay)
		self.scehdule_replay = nil
	end
    self.scehdule_replay = scheduler:scheduleScriptFunc(handler(self, self.updateReplay), 3, false)
    self.replay_index = 0
end

function M:updateReplay()
    if G_Data.bReplayPause then
        return
    end

    local tbl_data = G_Data.ReplayData.game.data
    self.replay_index = self.replay_index + 1
    if self.replay_index > #tbl_data then
        if self.scehdule_replay ~= nil then
		    scheduler:unscheduleScriptEntry(self.scehdule_replay)
		    self.scehdule_replay = nil
	    end
        return
    end
    
    local data = tbl_data[self.replay_index]
    G_DeskScene:handleMessage(data.name, data.msg)
end

-- 回放暂停
function M:Click_Pause(sender, eventType)
    G_CommonFunc:addClickSound()
    G_Data.bReplayPause = not G_Data.bReplayPause
    if G_Data.bReplayPause == true then 
        self.PauseBtn:loadTextures("res/Common/a2.png","res/Common/a2.png","")
    else
        self.PauseBtn:loadTextures("res/Common/a1.png","res/Common/a1.png","")
    end
end

-- 回放退出
function M:Click_Exit(sender, eventType)
    G_CommonFunc:addClickSound()
    G_DeskScene:LeaveRoom(GameConfigManager.tGameID.DGNN)
end

function M:showZhuangzhu(msg)
    if msg.bank_seat and msg.bank_seat ~= 0 then 
        self:setBankerUser(msg.bank_seat,true)
    end
end

function M:Click_User_Info(e)
    -- body
    G_CommonFunc:addClickSound()
    G_DeskScene:Click_User_Info(e)
end

function M:showOutMode( isOut )
    -- body
    if isOut == true then 
        self.Node_Btn:setVisible(false)
        self.BeginBtn:setVisible(false)
        self.ReadyBtn:setVisible(false)
        self.CancelReadyBtn:setVisible(false)
        self.Btn_AutoSuan:setVisible(false)
    end 
end

return M
