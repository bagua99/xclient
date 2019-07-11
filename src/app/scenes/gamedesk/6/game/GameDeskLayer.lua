
local M = class("GameDeskLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.YZBP.."/GameDeskLayer.csb"

local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.YZBP..".card.GameCard")

local scheduler = cc.Director:getInstance():getScheduler()
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local LocationMapLayer          = require("app.component.LocationMapLayer")

local GameConfig                = require ("app.config.GameConfig")
local EventConfig               = require ("app.config.EventConfig")

-- 创建
function M:onCreate()
    -- 语音相关
    self.SpriteRecord = nil
    self.nStartTime = 0

    -- Left Setting
    self.Button_Setting1 = self.resourceNode_.node["Button_Setting1"]
    self.Node1                  = self.resourceNode_.node["Node1"]
    self.Button_Back            = self.resourceNode_.node["Node1"].node["Button_Back"]
    self.Button_Dismiss         = self.resourceNode_.node["Node1"].node["Button_Dismiss"]

    -- Right Setting
    self.Button_Setting2 = self.resourceNode_.node["Button_Setting2"]
    self.Node2                  = self.resourceNode_.node["Node2"]
    self.Button_Help            = self.resourceNode_.node["Node2"].node["Button_Help"]
    self.Button_Setting         = self.resourceNode_.node["Node2"].node["Button_Setting"]

    -- 回放背景
    self.ReplayBg               = self.resourceNode_.node["ReplayBg"]
    -- 暂停
    self.Button_Pause           = self.resourceNode_.node["ReplayBg"].node["Button_Pause"]
    -- 退出
    self.Button_Exit            = self.resourceNode_.node["ReplayBg"].node["Button_Exit"]

    -- 背景图
    self.Image_BG               = self.resourceNode_.node["Image_BG"]

    -- 房间号
    self.Text_RommID            = self.resourceNode_.node["ImageView_Title"].node["Text_RommID"]
    -- 局数
    self.Text_JuShu             = self.resourceNode_.node["ImageView_Title"].node["Text_JuShu"]

    -- 叫主
    self.ImageView_Main                 = self.resourceNode_.node["ImageView_Banker"].node["ImageView_Main"]
    -- 庄分
    self.TextAtlas_BankerScore          = self.resourceNode_.node["ImageView_Banker"].node["TextAtlas_BankerScore"]
    -- 得分
    self.TextAtlas_Score                = self.resourceNode_.node["ImageView_Banker"].node["TextAtlas_Score"]

    -- 聊天
    self.Button_Chat                    = self.resourceNode_.node["Panel_Operation"].node["Button_Chat"]
    -- 录音
    self.Button_Record                  = self.resourceNode_.node["Panel_Operation"].node["Button_Record"]
    -- 邀请按钮
    self.Button_Share                   = self.resourceNode_.node["Panel_Operation"].node["Button_Share"]
    -- 取消准备按钮
    self.Button_CancelReady             = self.resourceNode_.node["Panel_Operation"].node["Button_CancelReady"]
    -- 准备按钮
    self.Button_Ready                   = self.resourceNode_.node["Panel_Operation"].node["Button_Ready"]
    -- 查牌
    self.Button_LookCard                = self.resourceNode_.node["Panel_Operation"].node["Button_LookCard"]
    -- 底牌
    self.Button_BackCard                = self.resourceNode_.node["Panel_Operation"].node["Button_BackCard"]
    -- 提示
    self.Button_Prompt                  = self.resourceNode_.node["Panel_Operation"].node["Button_Prompt"]
    -- 来分
    self.Button_Score                   = self.resourceNode_.node["Panel_Operation"].node["Button_Score"]
    -- 出牌
    self.Button_OutCard                 = self.resourceNode_.node["Panel_Operation"].node["Button_OutCard"]
    -- 投降
    self.Button_Surrender               = self.resourceNode_.node["Panel_Operation"].node["Button_Surrender"]
    -- 埋底
    self.Button_BuryCard                = self.resourceNode_.node["Panel_Operation"].node["Button_BuryCard"]

    -- 叫主背景
    self.ImageView_MainBG               = self.resourceNode_.node["ImageView_MainBG"]
    -- 无主
    self.Button_WuZhu                   = self.resourceNode_.node["ImageView_MainBG"].node["Button_WuZhu"]
    -- 黑
    self.Button_Hei                     = self.resourceNode_.node["ImageView_MainBG"].node["Button_Hei"]
    -- 红
    self.Button_Hong                    = self.resourceNode_.node["ImageView_MainBG"].node["Button_Hong"]
    -- 梅
    self.Button_Mei                     = self.resourceNode_.node["ImageView_MainBG"].node["Button_Mei"]
    -- 方
    self.Button_Fang                    = self.resourceNode_.node["ImageView_MainBG"].node["Button_Fang"]

    -- 叫分节点
    self.Node_Score                     = self.resourceNode_.node["Node_Score"]
    -- 叫分底图
    self.ImageView_Score                = self.resourceNode_.node["Node_Score"].node["ImageView_Score"]
    -- 过
    self.Button_Pass                    = self.resourceNode_.node["Node_Score"].node["ImageView_Score"].node["Button_Pass"]
    -- 叫分
    self.Button_Call                    = self.resourceNode_.node["Node_Score"].node["ImageView_Score"].node["Button_Call"]
    -- 叫分按钮
    self.Button_CallScore               = self.resourceNode_.node["Node_Score"].node["Button_CallScore"]
    -- 叫分选择
    self.Image_ChooseScore              = self.resourceNode_.node["Node_Score"].node["Button_CallScore"].node["Image_ChooseScore"]
    -- 叫分信息
    self.tCallScore = {}
    for i = 1, G_GameDefine.player_count do
        local tInfo = {}
        tInfo.Node_CallScore        = self.resourceNode_.node["Node_CallScore"..i]
        tInfo.Image_BG              = self.resourceNode_.node["Node_CallScore"..i].node["Image_BG"]
        tInfo.Image_Pass            = self.resourceNode_.node["Node_CallScore"..i].node["Image_Pass"]
        tInfo.AtlasLabel_Score      = self.resourceNode_.node["Node_CallScore"..i].node["AtlasLabel_Score"]
        tInfo.Image_Fen             = self.resourceNode_.node["Node_CallScore"..i].node["Image_Fen"]
        self.tCallScore[i] = tInfo
    end

    -- 叫主
    self.Image_TempMain                 = self.resourceNode_.node["Image_TempMain"]
    -- 得分
    self.Text_TempScore                 = self.resourceNode_.node["Text_TempScore"]
    -- 埋牌提示
    self.Image_BuryCard                 = self.resourceNode_.node["Image_BuryCard"]

    -- 来分
    self.tLaiFei = {}
    -- 得分
    self.Node_LF                        = self.resourceNode_.node["Node_LF"]
    for i = 1, G_GameDefine.player_count do
        self.tLaiFei[i] = self.resourceNode_.node["Node_LF"].node["Image_"..i]
    end

    -- 闹钟相关
    self.Image_Clock = self.resourceNode_.node["Image_Clock"]
	self.TextAtlas_ClockNum = self.resourceNode_.node["Image_Clock"].node["TextAtlas_ClockNum"]
	self.scehdule_updateClockTime = nil
    self.nTimeCount = 0

    -- 头像相关
    self.tHeadInfo = {}
    self.tGetHead = {}
    for i = 1, G_GameDefine.player_count do
        self.tGetHead[i] = false

        local Panel = self.resourceNode_.node["Panel_"..i]
        local tInfo = {}
        tInfo.Panel             = Panel
        tInfo.Text_Name         = Panel.node["Text_Name"]
        tInfo.Text_ScoreText    = Panel.node["Text_ScoreText"]
        tInfo.Text_Score        = Panel.node["Text_Score"]
        tInfo.Image_Ready       = Panel.node["Image_Ready"]
        tInfo.Image_Face        = Panel.node["Panel_Head"].node["Image_Face"]
        tInfo.Image_Online      = Panel.node["Panel_Head"].node["Image_Online"]
        tInfo.Image_BG          = Panel.node["Panel_Head"].node["Image_BG"]
        tInfo.Image_Banker      = Panel.node["Panel_Head"].node["Image_Banker"]
        tInfo.Image_Agree       = Panel.node["Panel_Head"].node["Image_Agree"]
        self.tHeadInfo[i] = tInfo
    end

    -- 破
    self.Image_Po                 = self.resourceNode_.node["Image_Po"]

    -- 当前叫分
    self.nCallScore = 0
    -- 当前选择分数
    self.nChooseScore = 0
    -- 当前得分
    self.nPickScore = 0
end

-- 初始化视图
function M:initView()
    -- 录音动画相关
    self.SpriteRecord = cc.Sprite:create("Voice/record_0.png")
	self.SpriteRecord:setPosition(cc.p(display.width/2, display.height/2))
	self.SpriteRecord:setVisible(false)
    self:addChild(self.SpriteRecord)

    local actSpr = cc.Sprite:create("Voice/p1.png")
	actSpr:setPosition(cc.p(self.SpriteRecord:getBoundingBox().width/2 + 50, self.SpriteRecord:getBoundingBox().height/2 + 30))
	local curAnimate = cc.Animation:create()
	for i = 1, 6 do
		curAnimate:addSpriteFrameWithFile("Voice/p"..i..".png")
	end
	curAnimate:setDelayPerUnit(1/3)
	curAnimate:setRestoreOriginalFrame(true)

	local curAction = cc.Animate:create(curAnimate)
	actSpr:runAction(cc.RepeatForever:create(curAction))
    self.SpriteRecord:addChild(actSpr)

    self.Button_Setting1:setVisible(true)
    self.Button_Setting2:setVisible(true)
    self.Node1:setVisible(false)
    self.Node2:setVisible(false)
    self.Node1:setPositionX(self.Node1:getPositionX() - 300)
    self.Node2:setPositionX(self.Node2:getPositionX() + 300)

    self.ReplayBg:setVisible(false)
    
    self.Text_RommID:setString(G_Data.roomid)
    self.Text_RommID:setVisible(true)
    self.Text_JuShu:setVisible(true)

    self.ImageView_Main:setVisible(false)
    self.TextAtlas_BankerScore:setVisible(false)
    self.TextAtlas_Score:setVisible(false)

	self.Button_Share:setVisible(false)
    self.Button_Ready:setVisible(false)
    self.Button_CancelReady:setVisible(false)
    self.Button_LookCard:setVisible(false)
    self.Button_BackCard:setVisible(false)
    self.Button_Prompt:setVisible(false)
    self.Button_Score:setVisible(false)
    self.Button_OutCard:setVisible(false)
    self.Button_Surrender:setVisible(false)
    self.Button_BuryCard:setVisible(false)

    self.ImageView_MainBG:setVisible(false)

    self.Node_Score:setVisible(false)

    for _, v in pairs(self.tCallScore) do
        v.Node_CallScore:setVisible(false)
    end

    self.Image_TempMain:setVisible(false)
    self.Text_TempScore:setVisible(false)
    self.Image_BuryCard:setVisible(false)

    for _, Image in pairs(self.tLaiFei) do
        Image:setVisible(false)
    end

    self.Image_Clock:setVisible(false)

    for _, tInfo in pairs(self.tHeadInfo) do
        tInfo.Panel:setVisible(false)
    end

    self.Image_Po:setVisible(false)

    -- 缩放
    local viewsize = cc.Director:getInstance():getWinSize()
    local bgSize = self.Image_BG:getContentSize()
    self.tScale = {width = viewsize.width/bgSize.width, height = viewsize.height/bgSize.height}
    self:setScale(self.tScale.width, self.tScale.height)
end

-- 初始化触摸
function M:initTouch()
    self.Button_Setting1:addClickEventListener(handler(self, self.showLeftBtns))
    self.Button_Back:addClickEventListener(handler(self, self.Click_Leave))
    self.Button_Dismiss:addClickEventListener(handler(self, self.Click_Vote))

    self.Button_Setting2:addClickEventListener(handler(self, self.showRightBtns))
    self.Button_Help:addClickEventListener(handler(self, self.Click_Help))
    self.Button_Setting:addClickEventListener(handler(self, self.Click_Set))

    self.Button_Pause:addClickEventListener(handler(self, self.Click_Pause))
    self.Button_Exit:addClickEventListener(handler(self, self.Click_Exit))

    self.Button_Chat:addClickEventListener(handler(self, self.Click_Chat))
    self.Button_Record:addTouchEventListener(handler(self, self.Click_Record))
    self.Button_Share:addClickEventListener(handler(self, self.Click_Share))
    self.Button_Ready:addClickEventListener(handler(self, self.Click_Ready))
    self.Button_CancelReady:addClickEventListener(handler(self, self.Click_CancelReady))
    self.Button_LookCard:addClickEventListener(handler(self, self.Click_LookCard))
    self.Button_BackCard:addClickEventListener(handler(self, self.Click_BackCard))
    self.Button_Prompt:addClickEventListener(handler(self, self.Click_Prompt))
    self.Button_Score:addClickEventListener(handler(self, self.Click_Score))
    self.Button_OutCard:addClickEventListener(handler(self, self.Click_OutCard))
    self.Button_Surrender:addClickEventListener(handler(self, self.Click_Surrender))
    self.Button_BuryCard:addClickEventListener(handler(self, self.Click_BuryCard))

    -- 无主
    self.Button_WuZhu:addClickEventListener(handler(self, self.Click_CallMain))
    -- 黑
    self.Button_Hei:addClickEventListener(handler(self, self.Click_CallMain))
    -- 红
    self.Button_Hong:addClickEventListener(handler(self, self.Click_CallMain))
    -- 梅
    self.Button_Mei:addClickEventListener(handler(self, self.Click_CallMain))
    -- 方
    self.Button_Fang:addClickEventListener(handler(self, self.Click_CallMain))

    -- 不叫
    self.Button_Pass:addClickEventListener(handler(self, self.Click_Pass))
    -- 叫分
    self.Button_Call:addClickEventListener(handler(self, self.Click_Call))
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

function M:Click_Share()
    G_CommonFunc:addClickSound()
    local strContent = string.format("永州包牌，房间号：%06d,%d人,%d局,来战啊！",G_Data.roomid, G_GameDefine.player_count, G_GameDefine.nTotalGameCount)
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

-- 聊天
function M:Click_Chat(sender, eventType)
    G_CommonFunc:addClickSound()
    G_DeskScene:setChatLayerVisible(true)
end

-- 设置
function M:Click_Set()
    G_CommonFunc:addClickSound()
    G_DeskScene:Click_Set()
end

-- 回放暂停
function M:Click_Pause(sender, eventType)
    G_CommonFunc:addClickSound()
    G_Data.bReplayPause = not G_Data.bReplayPause
    if G_Data.bReplayPause == true then 
        self.Button_Pause:loadTextures("res/Common/a2.png","res/Common/a2.png","")
    else
        self.Button_Pause:loadTextures("res/Common/a1.png","res/Common/a1.png","")
    end
end

-- 回放退出
function M:Click_Exit(sender, eventType)
    G_CommonFunc:addClickSound()
    G_DeskScene:LeaveRoom(GameConfigManager.tGameID.YZBP)
end

function M:Click_Record(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.nStartTime = os.time()
        self.SpriteRecord:setVisible(true)
        --停止背景音乐
        G_GameDeskManager.Music:pauseBackMusic()
        if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
            local function callbackLua(url)
                if url then
                    G_GameDeskManager.Music:resumeBackMusic()
                    self:stopRecord()
        
                    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.VoiceChatReq",{voice=url})
                    
                    local userid=G_GamePlayer:getMainPlayer().userid

                    local recordStart = function(params)
                        
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
                        self.tHeadInfo[nLocalSeat].HeadBg:addChild(self.playRecordSp)
                        actSpr:setPosition(80,0)
                        if nLocalSeat == 1 or nLocalSeat == 3 then 

                        else 
                            --X轴反向
                            actSpr:setPosition(-80,0)
                            self.playRecordSp:setFlipX(true)
                        end 
                    end

                    local recordFinish = function(params)
                        
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
        elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then 
            local function callbackLua(url)
                if url then
                    G_GameDeskManager.Music:resumeBackMusic()
                    self:stopRecord()
                    
                    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.VoiceChatReq",{voice=url})
                    
                    local userid=G_GamePlayer:getMainPlayer().userid

                    local recordStart = function(params)
                        
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
                        self.tHeadInfo[nLocalSeat].HeadBg:addChild(self.playRecordSp)
                        actSpr:setPosition(140,40)
                        dump(nLocalSeat)
                        if nLocalSeat == 1 or nLocalSeat == 3 then 

                        else 
                            --X轴反向
                            actSpr:setPosition(-20,40)
                            self.playRecordSp:setFlipX(true)
                        end 
                    end

                    local recordFinish = function(params)
                        
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
            end

            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "RootViewController"
            luaoc.callStaticMethod(className,"record", {scriptHandler = callbackLua } )
        end
    elseif eventType == ccui.TouchEventType.moved then
        G_GameDeskManager.Music:resumeBackMusic()
    elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        self.SpriteRecord:setVisible(false)
        G_GameDeskManager.Music:resumeBackMusic()
        if os.time() - self.nStartTime < 1 then
            self:stopRecord()
            return
        end
        self:stopRecord()
    end
end

function M:stopRecord()
    -- G_GameDeskManager.Music:pauseBackMusic()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {}
        local sigs = "()V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/hnqp/pdkgame/AppActivity"
        local ok = luaj.callStaticMethod(className,"stopRecord",args,sigs)
        if not ok then
            
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then 
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "RootViewController"
        luaoc.callStaticMethod(className,"stopRecord", {}) 
    end 
end

-- 点击准备
function M:Click_Ready()
    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_ReadyReq", {bReady=true})
end

-- 取消准备
function M:Click_CancelReady()
     G_CommonFunc:addClickSound()
     G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_ReadyReq", {bReady=false})
end

-- 查牌
function M:Click_LookCard(sender)
    if G_Data.bReplay then
        return
    end
end

-- 底牌
function M:Click_BackCard(sender)
    if G_Data.bReplay then
        return
    end
end

-- 提示
function M:Click_Prompt(sender)
    if G_Data.bReplay then
        return
    end
end

-- 喊来
function M:Click_Score(sender)
    if G_Data.bReplay then
        return
    end
end

-- 出牌
function M:Click_OutCard(sender)
    if G_Data.bReplay then
        return
    end

    G_CommonFunc:addClickSound()
    -- 获取选择牌
    local tCardData = G_DeskScene.GameCardManager:getCardArray(1, GameCard.Card_Selected)
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_OutCardReq", {nCardData = tCardData})
end

-- 投降
function M:Click_Surrender(sender)
    if G_Data.bReplay then
        return
    end

    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_SurrenderReq", {})
end

-- 埋牌
function M:Click_BuryCard(sender)
    if G_Data.bReplay then
        return
    end

    G_CommonFunc:addClickSound()
    -- 获取选择牌
    local tCardData = G_DeskScene.GameCardManager:getCardArray(1, GameCard.Card_Selected)
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_BuryCardReq", {nCardData = tCardData})
end

-- 不叫
function M:Click_Pass(sender)
    if G_Data.bReplay then
        return
    end

    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_CallScoreReq", {nCallScore = 0})
end

-- 叫分
function M:Click_Call(sender)
    if G_Data.bReplay then
        return
    end

    if self.nChooseScore == 0 or self.nChooseScore <= self.nCallScore then
        return
    end

    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_CallScoreReq", {nCallScore = self.nChooseScore})
end

-- 叫主
function M:Click_CallMain(sender)
    if G_Data.bReplay then
        return
    end

    local nCardData = 0x00
    local strName = sender:getName()
    if strName == "Button_WuZhu" then
        nCardData = G_DeskScene.GameLogic.COLOR_CHANGEZHU
    elseif strName == "Button_Hei" then
        nCardData = G_DeskScene.GameLogic.COLOR_HEI
    elseif strName == "Button_Hong" then
        nCardData = G_DeskScene.GameLogic.COLOR_HONG
    elseif strName == "Button_Mei" then
        nCardData = G_DeskScene.GameLogic.COLOR_MEI
    elseif strName == "Button_Fang" then
        nCardData = G_DeskScene.GameLogic.COLOR_FANG
    end

    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_MainCardReq", {nCardData = nCardData})
end

-- 投降同意
function M:Click_SurrenderConfirm(sender)
    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_SurrenderVoteReq", {bAgree = true})
end

-- 投降不同意
function M:Click_SurrenderCancel(sender)
    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_SurrenderVoteReq", {bAgree = false})
end

-- 显示玩家信息
function M:showUserInfo(nLocalSeat)
    if nLocalSeat == 0 then
        for i = 1, G_GameDefine.player_count do
            local nSeat = G_GamePlayer:getLocalSeat(i)
            if not self.tGetHead[nSeat] then
	            local _player = G_GamePlayer:getPlayerBySeat(nSeat)
                if _player ~= nil then
                    local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
                    local msg = {seat = nSeat, saveName = saveName}
                    if cc.FileUtils:getInstance():isFileExist(saveName) then
                        self:getHeadImg(msg, true)
                    end
                    -- 微信未设置图片为"\0"
                    local url = _player.headimgurl
	                if url and string.len(url) > 1 then
			            G_CommonFunc:httpForImg(url, saveName, handler(self, self.getHeadImg), msg)
	                end
	                self:setNickname(nSeat, _player.nickname)
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
                -- 微信未设置图片为"\0"
                local url = _player.headimgurl
	            if url and string.len(url) > 1 then
			        G_CommonFunc:httpForImg(url, saveName, handler(self, self.getHeadImg), msg)
	            end
	            self:setNickname(nLocalSeat, _player.nickname)
            end
        end
    end
end

-- 取得头像
function M:getHeadImg(msg, bSuccess)
    if not bSuccess then
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

-- 设置名字
function M:setNickname(nLocalSeat, szNickName)
    local len = string.len(szNickName)
    if len > 12 then 
        szNickName = string.sub(szNickName, 1, 12).."..."
    end
    self.tHeadInfo[nLocalSeat].Text_Name:setString(szNickName)
end

-- 设置分数
function M:setScore(nLocalSeat, nScore)
	self.tHeadInfo[nLocalSeat].Text_Score:setString(nScore)
end

-- 设置准备
function M:setReady(nLocalSeat, bReady)
   self.tHeadInfo[nLocalSeat].Image_Ready:setVisible(bReady)
end

-- 显示闹钟
function M:showOutTime(nLocalSeat, bShow)
	if self.scehdule_updateClockTime ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
		self.scehdule_updateClockTime = nil
	end

    self.TextAtlas_ClockNum:setVisible(bShow)
    self.Image_Clock:setVisible(bShow)

    if not bShow then
        return
    end

    self.nTimeCount = 15
    local tPoint = {cc.p(180,296), cc.p(1106,560), cc.p(532,706), cc.p(170,514)}
    self.Image_Clock:setPosition(tPoint[nLocalSeat])
    self.TextAtlas_ClockNum:setString(self.nTimeCount)
    self.scehdule_updateClockTime = scheduler:scheduleScriptFunc(handler(self, self.updateClockTime), 1, false)
end

-- 更新闹钟
function M:updateClockTime()
	self.nTimeCount = self.nTimeCount - 1
	if self.nTimeCount <= 0 then
        self.TextAtlas_ClockNum:setString("0")
		if self.scehdule_updateClockTime ~= nil then
			scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
			self.scehdule_updateClockTime = nil
		end 
	else
        if self.nTimeCount<=3 then 
            local sound = "Music/timeup_alarm.mp3"
            G_GameDeskManager.Music:playSound(sound,false)
        end 
		self.TextAtlas_ClockNum:setString(self.nTimeCount)
	end
end

-- 显示庄
function M:setBanker(nLocalSeat)
    for i = 1, G_GameDefine.player_count do
        self.tHeadInfo[i].Image_Banker:setVisible(i == nLocalSeat)
    end
end

-- 语音消息
function M:handleVoiceChatAck(msg)
    local userid = msg.userid
    local url = msg.voice
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local recordStart = function(params)
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
            self.tHeadInfo[nLocalSeat].HeadBg:addChild(self.playRecordSp)
            dump(nLocalSeat)
            if nLocalSeat == 1 or  nLocalSeat == 3 then 
                self.playRecordSp:setPosition(140,40)
            else 
                --X轴反向
                self.playRecordSp:setPosition(-80,0)
                self.playRecordSp:setFlipX(true)
            end 
        end

        local recordFinish = function(params)
            
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
         local recordStart = function(params)
            
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
            self.tHeadInfo[nLocalSeat].HeadBg:addChild(self.playRecordSp)
            if nLocalSeat == 1 or nLocalSeat == 4 or nLocalSeat == 5 then 
                self.playRecordSp:setPosition(80,0)
            else 
                --X轴反向
                self.playRecordSp:setPosition(-80,0)
                self.playRecordSp:setFlipX(true)
            end 
        end

        local recordFinish = function(params)
            
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

-- 玩家断线
function M:handleUserOfflineAck(msg)
    local userid = msg.userid 
    local player = G_GamePlayer:getPlayerByUserId(userid)
    if player == nil then 
        return 
    end 
    local nLocalSeat = G_GamePlayer:getLocalSeat(player.seat)
    self.tHeadInfo[nLocalSeat].Panel:setOpacity(80)
    self.tHeadInfo[nLocalSeat].Image_Online:setVisible(true)
end

-- 新玩家
function M:handlePlayerEnterAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.userData.seat)
    -- 显示头像相关
    if msg.userData.offline then
        self.tHeadInfo[nLocalSeat].Panel:setOpacity(80)
    else
        self.tHeadInfo[nLocalSeat].Panel:setOpacity(255)
    end
    self.tHeadInfo[nLocalSeat].Image_Online:setVisible(msg.userData.offline)
    self.tHeadInfo[nLocalSeat].Panel:setVisible(true)
    
    -- 显示玩家信息
    self:showUserInfo(nLocalSeat)
end

-- 玩家离开
function M:handlePlayerLeaveAck(msg)
    local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nSeat)
    if _player == nil then
        return
    end
    
    local nLocalSeat = G_GamePlayer:getLocalSeat(_player.seat)
    -- 隐藏头像相关
    self.tHeadInfo[nLocalSeat].Panel:setVisible(false)
    -- 置空获取头像
    self.tGetHead[nLocalSeat] = false

    -- 删除玩家
    G_GamePlayer:removePlayerBySeat(msg.nSeat)
end

-- 进入游戏
function M:handleEnterGameAck(msg)
    for i = 1, G_GameDefine.player_count do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            -- 隐藏头像相关
            self.tHeadInfo[nLocalSeat].Panel:setVisible(false)
        else
            -- 显示头像相关
            if _player.offline then
                self.tHeadInfo[nLocalSeat].Panel:setOpacity(80)
            else
                self.tHeadInfo[nLocalSeat].Panel:setOpacity(255)
            end
            self.tHeadInfo[nLocalSeat].Image_Online:setVisible(_player.offline)
             -- 显示头像相关
            self.tHeadInfo[nLocalSeat].Panel:setVisible(true)
            dump(nLocalSeat)
            -- 显示玩家信息
            self:showUserInfo(nLocalSeat)
        end
    end
end

-- 断线重连消息
function M:handleSceneAck(msg)
    G_GameDefine.nGameStatus = msg.nGameStatus

    for i = 1, G_GameDefine.player_count do
        -- 显示分数
        self:setScore(G_GamePlayer:getLocalSeat(i), msg.nGameScore[i])
    end

    if EventConfig.CHECK_IOS then 
        self.Button_Share:setVisible(false)
    else 
        if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then
            self.Button_Share:setVisible(true)
        else
            self.Button_Share:setVisible(false)
        end
    end 
	local nGameCount = G_GameDefine.nGameCount ~= 0 and G_GameDefine.nGameCount or 1
    self.Text_JuShu:setString("第"..nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
	if G_GameDefine.nGameStatus == G_GameDefine.game_free then
        self:SetReadyBtn(msg.bReady[nSelfServerSeat], true)
        for i = 1, G_GameDefine.player_count do
            local nLocalSeat = G_GamePlayer:getLocalSeat(i)
            self:setReady(nLocalSeat, msg.bReady[i])
        end
		return
    end

    -- 当前叫分
    self.nCallScore = msg.nCallScore
    -- 当前得分
    self.nPickScore = msg.nPickScore

    if G_GameDefine.nGameStatus >= G_GameDefine.game_main_card and G_GameDefine.nGameStatus <= G_GameDefine.game_play then
        -- 显示庄家
        local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nBankerSeat)
        self:setBanker(nLocalSeat)

        -- 显示庄分
        self.TextAtlas_BankerScore:setString(205 - msg.nCallScore)
        self.TextAtlas_BankerScore:setVisible(true)
    end

    if G_GameDefine.nGameStatus >= G_GameDefine.game_bury_card and G_GameDefine.nGameStatus <= G_GameDefine.game_play then
        -- 设置主牌
        self:setMain(msg.nMainCard, false)
        -- 设置主牌
        G_DeskScene.GameLogic:setMainColor(msg.nMainCard)
    end

    -- 叫分
    if G_GameDefine.nGameStatus == G_GameDefine.game_score then
        local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
        if nCurrentLocalSeat == 1 then
            -- 显示叫分
            self:showCallScore(true)
        end
    -- 叫主
    elseif G_GameDefine.nGameStatus == G_GameDefine.game_main_card then
        local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
        if nCurrentLocalSeat == 1 then
            -- 显示叫主
            self:showCallMain(true)
        end
    -- 投降
    elseif G_GameDefine.nGameStatus == G_GameDefine.game_surrender then
        for k, v in pairs(msg.surrenderVote) do
            if k ~= msg.nBankerSeat and not v then
                local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
                if nCurrentLocalSeat ~= 1 then
                    local strInfo = "玩家申请投降,请问是否同意投降?"
                    local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nCurrentSeat)
                    if _player ~= nil then
                        strInfo = "玩家[".._player.nickname.."]申请投降,请问是否同意投降?"
                    end
                    G_DeskScene.SurrenderLayer:setContentText(strInfo)
                    G_DeskScene.SurrenderLayer:setConfirmCallback(handler(self, self.Click_SurrenderConfirm))
                    G_DeskScene.SurrenderLayer:setCancelCallback(handler(self, self.Click_SurrenderCancel))
                    G_DeskScene.SurrenderLayer:setVisible(true)
                end
            end
        end
    -- 埋牌
    elseif G_GameDefine.nGameStatus == G_GameDefine.game_bury_card then
        local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
        if nCurrentLocalSeat == 1 then
            -- 显示投降
            self.Button_Surrender:setVisible(true)
            -- 显示埋底
            self.Button_BuryCard:setVisible(true)
        end
        -- 显示埋底图片
        self.Image_BuryCard:setVisible(nCurrentLocalSeat ~= 1)
    -- 游戏中
    elseif G_GameDefine.nGameStatus == G_GameDefine.game_play then
        -- 得分
        if msg.nPickScore > 0 then
            self.TextAtlas_Score:setString(msg.nPickScore)
            self.TextAtlas_Score:setVisible(true)
        end
    end

    --[[
    -- 显示出牌
    local nOutCardSeat = G_GamePlayer:getLocalSeat(self.nLastOutSeat)
    local tTurnCardData = msg.nTurnCardData
    G_DeskScene.GameLogic:sortCard(tTurnCardData)
    G_DeskScene.GameCardManager:createShowOutCard(nOutCardSeat, tTurnCardData)
    ]]

    -- 自己牌处理
    local tCardData = msg.nCardData
    G_DeskScene.GameLogic:sortCard(tCardData)
    G_DeskScene.GameCardManager:createShowStandCard(1, tCardData)
    G_DeskScene.GameCardManager:setVisible(true)
end

-- 准备消息
function M:handleReadyAck(msg)
	local nReadyLocalSeat = G_GamePlayer:getLocalSeat(msg.nSeat)
    -- 设置玩家准备图片
    self:setReady(nReadyLocalSeat, msg.bReady)

    if nReadyLocalSeat == 1 then
        -- 清除出牌
        G_DeskScene.GameCardManager:clearShowOutCard(0)
        -- 清除牌数据
        G_DeskScene.GameCardManager:restore()
        -- 设置准备按钮
        self:SetReadyBtn(msg.bReady, true)

        -- 提示
        self.Button_Prompt:setVisible(false)
        -- 来分
        self.Button_Score:setVisible(false)
        -- 出牌
        self.Button_OutCard:setVisible(false)

        -- 埋牌提示
        self.Image_BuryCard:setVisible(false)

        for i = 1, G_GameDefine.player_count do
            -- 隐藏投票同意
            self.tHeadInfo[i].Image_Agree:setVisible(false)
        end
    end
end

-- 游戏开始
function M:handleGameStartAck(msg)
    -- 清除牌数据
    G_DeskScene.GameCardManager:restore()

    -- 隐藏分享
    self.Button_Share:setVisible(false)
    -- 隐藏准备,取消准备
    self:SetReadyBtn(false, false)
    -- 显示局数
    local nGameCount = G_GameDefine.nGameCount ~= 0 and G_GameDefine.nGameCount or 1
    self.Text_JuShu:setString("第"..nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

	for i = 1, G_GameDefine.player_count do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        --  隐藏准备图片
		self:setReady(nLocalSeat, false)
    end
    
    -- 叫分
    self.nCallScore = 0
    -- 当前选择分数
    self.nChooseScore = 0
    -- 当前得分
    self.nPickScore = 0

    -- 叫主
    self.ImageView_Main:setVisible(false)
    -- 庄分
    self.TextAtlas_BankerScore:setVisible(false)
    -- 得分
    self.TextAtlas_Score:setVisible(false)
	
	local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    -- 显示时间
    self:showOutTime(nLocalSeat, true)

    local tCardData = msg.nCardData
    G_DeskScene.GameLogic:sortCard(tCardData)
    -- 牌类处理
    G_DeskScene.GameCardManager:createShowStandCard(1, tCardData)
    G_DeskScene.GameCardManager:setVisible(true)

    -- 是自己叫分
    if nLocalSeat == 1 then
        -- 显示叫分
        self:showCallScore(true)
    end
end

-- 叫分消息
function M:handleCallScoreAck(msg)
    -- 隐藏叫分
    self:showCallScore(false)

    -- 设置叫分
    if msg.nCallScore ~= 0 then
        self.nCallScore = msg.nCallScore
    end
    -- 显示分
    self:showScore(G_GamePlayer:getLocalSeat(msg.nCurrentSeat), msg.nCallScore)

    if msg.nNextCallScore ~= G_GameDefine.invalid_seat then
        -- 下个叫分玩家
        local nNextSeat = G_GamePlayer:getLocalSeat(msg.nNextCallScore)
        if nNextSeat == 1 then
            -- 显示叫分
            self:showCallScore(true)
        end
    else
        -- 显示庄
        local nBankerSeat = G_GamePlayer:getLocalSeat(msg.nBankerSeat)
        self:setBanker(nBankerSeat)

        -- 显示庄分
        self.TextAtlas_BankerScore:setString(205 - msg.nBankerScore)
        self.TextAtlas_BankerScore:setVisible(true)

        -- 是自己叫主
        if nBankerSeat == 1 then
            -- 显示叫主
            self:showCallMain(true)
        end
    end
end

-- 叫主消息
function M:handleMainCardAck(msg)
    -- 隐藏叫主
    self:showCallMain(false)

    -- 设置主牌
    self:setMain(msg.nCardData, true)
    -- 设置主牌
    G_DeskScene.GameLogic:setMainColor(msg.nCardData)
    -- 设置主牌
    G_DeskScene.GameCardManager:setMain(1)

    -- 显示埋底图片
    self.Image_BuryCard:setVisible(G_GamePlayer:getLocalSeat(msg.nCurrentSeat) ~= 1)
end

-- 发送底牌消息
function M:handleSendBackCardAck(msg)
    -- 增加底牌
    G_DeskScene.GameCardManager:addBackCard(G_GamePlayer:getLocalSeat(msg.nCurrentSeat), msg.nCardData)

    -- 显示投降
    self.Button_Surrender:setVisible(true)
    -- 显示埋底
    self.Button_BuryCard:setVisible(true)
end

-- 投降消息
function M:handleSurrenderAck(msg)
    local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nCurrentLocalSeat ~= 1 then
        local strInfo = "玩家申请投降,请问是否同意投降?"
        local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nCurrentSeat)
        if _player ~= nil then
            strInfo = "玩家[".._player.nickname.."]申请投降,请问是否同意投降?"
        end
        G_DeskScene.SurrenderLayer:setContentText(strInfo)
        G_DeskScene.SurrenderLayer:setConfirmCallback(handler(self, self.Click_SurrenderConfirm))
        G_DeskScene.SurrenderLayer:setCancelCallback(handler(self, self.Click_SurrenderCancel))
        G_DeskScene.SurrenderLayer:setVisible(true)
    end
end

-- 投降投票消息
function M:handleSurrenderVoteAck(msg)
    local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    -- 显示投票同意
    self.tHeadInfo[nCurrentLocalSeat].Image_Agree:setVisible(msg.bAgree)
end

-- 投降结果投票消息
function M:handleSurrenderVoteResultAck(msg)
    -- 隐藏投票信息
    G_DeskScene.SurrenderLayer:setVisible(false)

    for i = 1, G_GameDefine.player_count do
        -- 隐藏投票同意
        self.tHeadInfo[i].Image_Agree:setVisible(false)
    end
    -- 同意投降
    if msg.nCurrentSeat == 0 then
        -- 隐藏投降
        self.Button_Surrender:setVisible(false)
        -- 隐藏埋底
        self.Button_BuryCard:setVisible(false)
    else
        local strInfo = "玩家不同意投降,投降失败！"
        local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nCurrentSeat)
        if _player ~= nil then
            strInfo = "玩家[".._player.nickname.."]不同意投降,投降失败！"
        end
        G_CommonFunc:showGeneralTips(GameConfigManager.tGameID.YZBP, strInfo, self,cc.p(display.cx,display.cy))
    end
end

-- 埋牌消息
function M:handleBuryCardAck(msg)
    -- 隐藏埋底图片
    self.Image_BuryCard:setVisible(false)
    -- 隐藏投降
    self.Button_Surrender:setVisible(false)
    -- 隐藏埋底
    self.Button_BuryCard:setVisible(false)

    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nLocalSeat == 1 then
        -- 埋底
        G_DeskScene.GameCardManager:buryCard(nLocalSeat, msg.nCardData)

        -- 显示提示
        self.Button_Prompt:setVisible(true)
        -- 显示出牌
        self.Button_OutCard:setVisible(true)
    end
end

-- 出牌消息
function M:handleOutCardAck(msg)
    -- 隐藏闹钟
    self:showOutTime(-1, false)

    -- 隐藏提示
    self.Button_Prompt:setVisible(false)
    -- 隐藏来分
    self.Button_Score:setVisible(false)
    -- 隐藏出牌
    self.Button_OutCard:setVisible(false)

    -- 显示出牌
    local nOutLocalSeat = G_GamePlayer:getLocalSeat(msg.nOutCardSeat)
    G_DeskScene.GameCardManager:createShowOutCard(nOutLocalSeat, msg.nCardData)

    local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    -- 出牌
    if msg.nType == G_GameDefine.out_card_out then
        -- 显示闹钟
        self:showOutTime(nCurrentLocalSeat, true)

        -- 是自己出牌
        if nCurrentLocalSeat == 1 then
            -- 显示提示
            self.Button_Prompt:setVisible(true)
            -- 显示出牌
            self.Button_OutCard:setVisible(true)
        end
    else
        -- 显示最大牌
        local nBigLocalSeat = G_GamePlayer:getLocalSeat(msg.nBigSeat)
        G_DeskScene.GameCardManager:showBigCard(nBigLocalSeat)
        -- 得分
        self:showPickScore(msg.nScore)
    end

    -- 新一轮
    if msg.nType == G_GameDefine.out_card_new_turn then
        self:runAction(
            cc.Sequence:create(cc.DelayTime:create(2.4),
                cc.CallFunc:create(function(sender)
                    -- 显示闹钟
                    self:showOutTime(nCurrentLocalSeat, true)
                    -- 清理玩家出牌
                    for i = 1, G_GameDefine.player_count do
                        G_DeskScene.GameCardManager:clearShowOutCard(i)
                    end
                    -- 显示玩家出牌
                    if nCurrentLocalSeat == 1 then
                        -- 获取手牌数量
                        local nCardCount = G_DeskScene.GameCardManager:getCardStandCount(1)
                        -- 显示提示
                        self.Button_Prompt:setVisible(nCardCount ~= 0)
                        -- 显示出牌
                        self.Button_OutCard:setVisible(nCardCount ~= 0)
                    end
                end)
            )
        )
    end
end

-- 游戏结束
function M:handleGameEndAck(msg)
    -- 隐藏闹钟
    self:showOutTime(-1, false)

    for i = 1, G_GameDefine.player_count do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        -- 显示分数
        self:setScore(nLocalSeat, msg.nTotalScore[i])
    end
end

-- 显示准备按钮
function M:SetReadyBtn(bReady, bShow)
    if bShow then
        self.Button_Ready:setVisible(not bReady)
        self.Button_CancelReady:setVisible(bReady)
    else
        self.Button_Ready:setVisible(false)
        self.Button_CancelReady:setVisible(false)
    end
end

function M:showLeftBtns()
    G_CommonFunc:addClickSound()
    if not self.selectLeft then 
        self.selectLeft = true
    else 
        self.selectLeft = not self.selectLeft
    end

    self.Node1:setVisible(true)
    if self.selectLeft then 
        self.Button_Setting1:loadTexture("left-2.png", ccui.TextureResType.plistType)
        local x = self.Button_Setting1:getPositionX()
        local y = self.Node1:getPositionY()
        local pos = cc.p(x,y)
        self.Node1:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end)))
    else 
        self.Button_Setting1:loadTexture("left-1.png", ccui.TextureResType.plistType)
        local x = self.Node1:getPositionX() - 300
        local y = self.Node1:getPositionY()
        local pos = cc.p(x,y)
        self.Node1:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end)))
    end
end

function M:showRightBtns()
    G_CommonFunc:addClickSound()
    if not self.selectRight then 
        self.selectRight = true
    else 
        self.selectRight = not self.selectRight
    end

    self.Node2:setVisible(true)
    if self.selectRight then 
        self.Button_Setting2:loadTexture("right-2.png", ccui.TextureResType.plistType)
        local x = self.Button_Setting2:getPositionX() - 60
        local y = self.Node2:getPositionY()
        local pos = cc.p(x,y)
        self.Node2:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end)))
    else
        self.Button_Setting2:loadTexture("right-1.png", ccui.TextureResType.plistType)
        local x = self.Node2:getPositionX() + 300
        local y = self.Node2:getPositionY()
        local pos = cc.p(x,y)
        self.Node2:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end)))
    end 
end

function M:Click_Help()
    G_CommonFunc:addClickSound()
    G_CommonFunc:startGame()
end

function M:showLocationMap(seat,player)
    if not EventConfig.CHECK_IOS then 
        return
    end
    local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
    if not self.locationMapLayer then
        local locationMapLayer = LocationMapLayer.new(player)        
        self.locationMapLayer = locationMapLayer
        self:addChild(self.locationMapLayer) 
    else 
           
    end
    self.locationMapLayer:setLocation(nLocalSeat, player)
    if self.isMaster then 
        if G_GamePlayer:getPlayerCount() > 1 then 
            self.locationMapLayer:setVisible(true)
        else 
            self.locationMapLayer:setVisible(false)
        end
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

function M:replayPrepare()
    local msg = G_Data.ReplayData
    for i = 1, G_GameDefine.player_count do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            -- 隐藏头像相关
            self.tHeadInfo[nLocalSeat].Panel:setVisible(false)
        else
             -- 显示头像相关
            self.tHeadInfo[nLocalSeat].Panel:setVisible(true)
            -- 显示玩家信息
            self:showUserInfo(nLocalSeat)
            -- 显示分数
            self:setScore(nLocalSeat, _player.score)
        end
    end

    -- 清除牌数据
    G_DeskScene.GameCardManager:restore()

    self.Button_Chat:setVisible(false)
    self.Button_Record:setVisible(false)
	self.Button_Share:setVisible(false)
    self:SetReadyBtn(false, false)
    self.ReplayBg:setVisible(true)

    self.Button_Setting1:setVisible(false)
    self.Button_Setting2:setVisible(false)

    self.Text_RommID:setString(msg.head.room_id)
    self.Text_JuShu:setString("第"..msg.head.count.."/"..G_GameDefine.nTotalGameCount.."局")

	for i = 1, G_GameDefine.player_count do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        --  隐藏准备图片
		self:setReady(nLocalSeat, false)
	end
	
	local nLocalSeat = G_GamePlayer:getLocalSeat(msg.game.prepare_data.nCurrentSeat)
    -- 设置庄家
	self:setBanker(nLocalSeat)
    -- 显示时间
    self:showOutTime(nLocalSeat, true)

    for i, tCardData in ipairs(msg.game.prepare_data.nCardData) do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        G_DeskScene.GameLogic:sortCard(tCardData)
        G_DeskScene.GameCardManager:createShowStandCard(nLocalSeat, tCardData)
	    G_DeskScene.GameCardManager:setVisible(true)
    end

    if self.scehdule_replay ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_replay)
		self.scehdule_replay = nil
	end
    self.scehdule_replay = scheduler:scheduleScriptFunc(handler(self, self.updateReplay), 1, false)
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

-- 显示叫分
function M:showCallScore(bShow)
    self.Node_Score:setVisible(bShow)
    if not bShow then
        return
    end

    if self.tButtonScore == nil or next(self.tButtonScore) == nil then
        self.tButtonScore = {}
        self.ImageView_Score:ignoreContentAdaptWithSize(true)
        local imgX = self.ImageView_Score:getContentSize().width
        local imgY = self.ImageView_Score:getContentSize().height
        local nCount = 0
        for i = 1, 4 do
            for j = 1, 7 do
                nCount = nCount + 1
                if nCount > 25 then
                    break
                end
                local Button = self.Button_CallScore:clone()
                Button:addClickEventListener(handler(self, self.Click_ChooseScore))
                local nTag = G_GameDefine.min_call_score + (i-1)*35 + (j-1)*5
                Button:setTag(nTag)
                Button:setAnchorPoint(cc.p(0.5, 0.5))
                Button:setPosition(cc.p(0.14*(j-1)*imgX+0.08*imgX, (0.76-(i-1)*0.16)*imgY))
                self.ImageView_Score:addChild(Button)

                local Image_ScoreBG = Button:getChildByName("Image_ScoreBG")
                Image_ScoreBG:setVisible(nTag <= self.nCallScore)

                local Image_Score = Button:getChildByName("Image_Score")
                Image_Score:loadTexture("yzbp_score_"..nTag..".png", ccui.TextureResType.plistType)

                local Image_ChooseScore = Button:getChildByName("Image_ChooseScore")
                Image_ChooseScore:setVisible(false)

                table.insert(self.tButtonScore, Button)
            end
        end
    else
        for _, v in pairs(self.tButtonScore) do
            local Image_ChooseScore = v:getChildByName("Image_ChooseScore")
            Image_ChooseScore:setVisible(false)
            local Image_ScoreBG = v:getChildByName("Image_ScoreBG")
            Image_ScoreBG:setVisible(v:getTag() <= self.nCallScore)
        end
    end
end

-- 选择分数
function M:Click_ChooseScore(sender, eventType)
    if G_Data.bReplay then
        return
    end

    local nTag = sender:getTag()
    if nTag <= self.nCallScore then
        return
    end

    -- 高亮选择分数
    for _, v in pairs(self.tButtonScore) do
        local Image_ChooseScore = v:getChildByName("Image_ChooseScore")
        Image_ChooseScore:setVisible(v:getTag() == nTag)
    end

    if self.nChooseScore ~= nTag then
        self.nChooseScore = nTag
    else
        -- 二次选择直接叫分
        G_CommonFunc:addClickSound()
        G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "yzbp.GAME_CallScoreReq", {nCallScore = nTag})
    end
end

-- 显示分
function M:showScore(nSeat, nScore)
    -- 停止动作
    self.tCallScore[nSeat].Node_CallScore:stopAllActions()
    -- 显示分
    self.tCallScore[nSeat].Node_CallScore:setVisible(true)
    self.tCallScore[nSeat].Image_BG:setVisible(true)
    -- 不要
    if nScore == 0 then
        self.tCallScore[nSeat].Image_Pass:setVisible(true)
        self.tCallScore[nSeat].AtlasLabel_Score:setVisible(false)
        self.tCallScore[nSeat].Image_Fen:setVisible(false)
    else
        self.tCallScore[nSeat].Image_Pass:setVisible(false)
        self.tCallScore[nSeat].AtlasLabel_Score:setString(nScore)
        self.tCallScore[nSeat].AtlasLabel_Score:setVisible(true)
        self.tCallScore[nSeat].Image_Fen:setVisible(true)
    end

    self.tCallScore[nSeat].Node_CallScore:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(4.0),
            cc.FadeTo:create(0.3, 100),
            cc.CallFunc:create(function()
                self.tCallScore[nSeat].Node_CallScore:setVisible(false)
            end)
        )
    )
end

-- 显示叫主
function M:showCallMain(bShow)
    self.ImageView_MainBG:setVisible(bShow)
end

-- 设置主牌
function M:setMain(nCardData, bAction)
	local strMain
	if nCardData == G_DeskScene.GameLogic.COLOR_FANG then
		strMain = "imgFang"
	elseif nCardData == G_DeskScene.GameLogic.COLOR_MEI then
		strMain = "imgMei"
	elseif nCardData == G_DeskScene.GameLogic.COLOR_HONG then
		strMain = "imgHao"
	elseif nCardData == G_DeskScene.GameLogic.COLOR_HEI then
		strMain = "imgHei"
	elseif nCardData == G_DeskScene.GameLogic.COLOR_CHANGEZHU then
		strMain = "imgZhu"
	end
	self.ImageView_Main:loadTexture("SDH_"..strMain..".png", ccui.TextureResType.plistType)
	self.ImageView_Main:ignoreContentAdaptWithSize(true)
	if bAction == false then
		self.ImageView_Main:setVisible(true)
		return
	end
	local size = cc.Director:getInstance():getWinSize()
	self.Image_TempMain:loadTexture("SDH_"..strMain..".png", ccui.TextureResType.plistType)
	self.Image_TempMain:setPosition(cc.p(size.width*0.5, size.height*0.6))
	self.Image_TempMain:setScale(1.2)
	self.Image_TempMain:setVisible(true)
	local startPos = self.ImageView_Main:convertToWorldSpaceAR(cc.p(0,0))
	self.Image_TempMain:runAction(
        cc.Sequence:create(
            cc.ScaleTo:create(0.4, 0.2),
            cc.Spawn:create(
                cc.ScaleTo:create(0.2, 1),
                cc.MoveTo:create(0.2, cc.p(startPos))
                ),
            cc.CallFunc:create(function(sender)
                sender:setVisible(false)
                self:showMain()
            end)
        )
    )
end

-- 显示主牌
function M:showMain()
	self.ImageView_Main:setVisible(true)
	self.ImageView_Main:setScale(1.2)
	self.ImageView_Main:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.1),
            cc.ScaleTo:create(0.1, 1)
        )
    )
end

-- 显示捡分
function M:showPickScore(nScore)
    if nScore <= 0 then
        return
    end
    self.nPickScore = self.nPickScore + nScore

    self.Text_TempScore:stopAllActions()
    self.TextAtlas_Score:stopAllActions()

    local winSize = cc.Director:getInstance():getWinSize()
    self.Text_TempScore:stopAllActions()
    self.Text_TempScore:setPosition(cc.p(winSize.width/2, winSize.height*0.6))
    self.Text_TempScore:setString("."..tostring(nScore))
    self.Text_TempScore:setVisible(true)
    self.Text_TempScore:setScale(1.5)
    self.Text_TempScore:runAction(
        cc.Sequence:create(cc.FadeIn:create(0.001),
            cc.MoveTo:create(0.3, cc.p(winSize.width/2, winSize.height*0.6+120)),
            cc.DelayTime:create(0.4),
            cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(winSize.width*0.85, winSize.height*0.9)),
                cc.FadeOut:create(0.3)
            )
        )
    )
    self.TextAtlas_Score:runAction(
        cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function(sender, v)
                sender:setVisible(true)
                sender:setScale(1.5)
                sender:setString(v.nPickScore)
            end, {nPickScore = self.nPickScore}),
            cc.ScaleTo:create(0.5, 1, 1)
        )
    )
end

return M
