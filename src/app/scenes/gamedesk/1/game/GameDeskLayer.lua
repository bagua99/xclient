
local M = class("GameDeskLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.PDK.."/GameDeskLayer.csb"

local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".card.GameCard")
local GameCardManager           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".card.GameCardManager")

local scheduler = cc.Director:getInstance():getScheduler()
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local LocationMapLayer          = require("app.component.LocationMapLayer")

local GameConfig                = require ("app.config.GameConfig")
local EventConfig               = require ("app.config.EventConfig")

-- 创建
function M:onCreate()
    -- 邀请按钮
	self.YaoQingBtn             = self.resourceNode_.node["YaoQingBtn"]
    -- 房间规则文本
    self.GameRuleText           = self.resourceNode_.node["GameRuleText"]
    -- 准备按钮
    self.ReadyBtn               = self.resourceNode_.node["ReadyBtn"]
    -- 取消准备按钮
    self.CancelReadyBtn         = self.resourceNode_.node["CancelReadyBtn"]

    self.LuYinBtn               = self.resourceNode_.node["LuYinBtn"]
	self.ChatBtn                = self.resourceNode_.node["ChatBtn"]

    self.ReplayBg               = self.resourceNode_.node["ReplayBg"]
    self.PauseBtn               = self.resourceNode_.node["ReplayBg"].node["PauseBtn"]
    self.ExitBtn                = self.resourceNode_.node["ReplayBg"].node["ExitBtn"]

    self.Node1                  = self.resourceNode_.node["Node1"]
    self.Node2                  = self.resourceNode_.node["Node2"]

    self.PassBtn                = self.resourceNode_.node["Node1"].node["PassBtn"]
    self.PromptBtn              = self.resourceNode_.node["Node1"].node["PromptBtn"]
    self.OutCardBtn             = self.resourceNode_.node["Node1"].node["OutCardBtn"]

    self.PromptBtn2             = self.resourceNode_.node["Node2"].node["PromptBtn"]
    self.OutCardBtn2            = self.resourceNode_.node["Node2"].node["OutCardBtn"]

     --Left Btns
    self.BTN_BTS1 = self.resourceNode_.node["BTN_BTS1"]
    self.BTN_BACK               = self.resourceNode_.node["BTN_BACK"]
    self.BTN_DISMISS            = self.resourceNode_.node["BTN_DISMISS"]

    --Right Btns
    self.BTN_BTS2 = self.resourceNode_.node["BTN_BTS2"]
    self.BTN_HELP               = self.resourceNode_.node["BTN_HELP"]
    self.BTN_SETTING            = self.resourceNode_.node["BTN_SETTING"]

    --Node1
    self.Node1_0 = self.resourceNode_.node["Node1_0"]
    --Node2
    self.Node2_0 = self.resourceNode_.node["Node2_0"]

    self.Text_Fang_V = self.resourceNode_.node["Sprite_Top"].node["Text_Fang_V"]
    self.Text_Ju_V = self.resourceNode_.node["Sprite_Top"].node["Text_Ju_V"]

    -- 头像相关
    self.Head_Node              = self.resourceNode_.node["Head_Node"]
    self.tHeadInfo = {}
    for i = 1, G_GameDefine.nMaxPlayerCount do
        local tInfo = {}
        tInfo.Node = self.resourceNode_.node["Head_Node"..i].node["HeadBg"]
        tInfo.HeadBg = self.resourceNode_.node["Head_Node"..i].node["HeadBg"]
        tInfo.HeadSprite = self.resourceNode_.node["Head_Node"..i].node["HeadBg"].node["HeadSprite"]
        tInfo.NameText = self.resourceNode_.node["Head_Node"..i].node["HeadBg"].node["NameText"]
        tInfo.ScoreText = self.resourceNode_.node["Head_Node"..i].node["HeadBg"].node["ScoreText"]
        tInfo.OfflineSprite  = self.resourceNode_.node["Node_OFFLINE"].node["IMG_OFF"..i]
        self.tHeadInfo[i] = tInfo
    end

    -- 其他
    self.Other_Node             = self.resourceNode_.node["Other_Node"]
    self.tReadySprite = {}
    self.tBankerSprite = {}
    self.tShowCardCount = {}
    self.tOneCardSprite = {}
    for i = 1, G_GameDefine.nMaxPlayerCount do
        self.tReadySprite[i] = self.resourceNode_.node["Other_Node"].node["ReadySprite_"..i]
        self.tBankerSprite[i] = self.resourceNode_.node["Other_Node"].node["BankerSprite_"..i]
        self.tOneCardSprite[i] = self.resourceNode_.node["Other_Node"].node["OneCardSprite_"..i]

        local tInfo = {}
        tInfo.Sprite = self.resourceNode_.node["Other_Node"].node["CardCountSprite_"..i]
        tInfo.Text = self.resourceNode_.node["Other_Node"].node["CardCountSprite_"..i].node["CardCountText"]
        self.tShowCardCount[i] = tInfo
    end

    -- 语音相关
    self.SpriteLuyin1 = nil
	self.nStartTime = 0

    -- 闹钟相关
    self.ClockBg = nil
	self.ClockTime = nil
	self.scehdule_updateClockTime = nil
    self.nTimeCount = 0

    self.tGetHead = {}
    for i = 1, G_GameDefine.nMaxPlayerCount do
        self.tGetHead[i] = false
    end

    self.passCard_schedule = nil
    self.nLastOutSeat = 0
    self.nCurrentSeat = 0
    self.tOutCardData = {}

    self.tCardCount = {}
end

-- 初始化视图
function M:initView()
	self.YaoQingBtn:setVisible(false)
	-- self.GameRuleText:setVisible(false)
    self.ReadyBtn:setVisible(false)
    self.CancelReadyBtn:setVisible(false)

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

    self.Node1:setVisible(false)
    self.Node2:setVisible(false)
    self.ReplayBg:setVisible(false)

    for nIndex, tInfo in pairs(self.tHeadInfo) do
        tInfo.Node:setVisible(false)
        tInfo.OfflineSprite:setVisible(false)
        tInfo.NameText:setContentSize(cc.size(100,40))
        tInfo.ScoreText:setContentSize(cc.size(100,40))
    end

    self.Other_Node:setVisible(true)
    for _, pSprite in pairs(self.tReadySprite) do
        pSprite:setVisible(false)
    end
    for _, pSprite in pairs(self.tBankerSprite) do
        pSprite:setVisible(false)
    end
    for _, tInfo in pairs(self.tShowCardCount) do
        tInfo.Sprite:setVisible(false)
        tInfo.Text:setVisible(false)
    end
    for _, pSprite in pairs(self.tOneCardSprite) do
        pSprite:setVisible(false)
    end

    -- 闹钟相关
    self.ClockBg = cc.Sprite:create("Common/clock.png")
	self.ClockBg:setScale(0.8)
    self.ClockBg:setVisible(false)
	self:addChild(self.ClockBg)

	self.ClockTime = ccui.TextAtlas:create("15","Common/clock_font.png",20,28,"0")
    self.ClockTime:setVisible(false)
	self:addChild(self.ClockTime)

    --游戏牌管理类
	self.GameCardManager = GameCardManager.create()
	self:addChild(self.GameCardManager)

    -- 过牌图片
    self.PassCardSprite = cc.Sprite:createWithSpriteFrameName("pdk_passcard.png")
    self.PassCardSprite:setPosition(cc.p(536, 68))
    self.PassCardSprite:setVisible(false)
    self:addChild(self.PassCardSprite)

    self.Text_Fang_V:setString(G_Data.roomid)

    local x1 = self.Node1_0:getPositionX()
    local x2 = self.Node2_0:getPositionX()
    self.Node1_0:setPositionX(x1-300)
    self.Node2_0:setPositionX(x2+300)

    self.head_bg_btn = {}
    for i=1,3 do 
        self.head_bg_btn[i] = self.resourceNode_.node["Head_Node"..i].node["HeadBg"].node["IMG_HEAD_BG"]
    end 
end

-- 初始化触摸
function M:initTouch()
	self.YaoQingBtn:addClickEventListener(handler(self,self.Click_YaoQing))
    self.ReadyBtn:addClickEventListener(handler(self,self.Click_Ready))
    self.CancelReadyBtn:addClickEventListener(handler(self,self.Click_CancelReady))

    self.LuYinBtn:addTouchEventListener(handler(self,self.Click_LuYin))
	self.ChatBtn:addClickEventListener(handler(self,self.Click_Chat))

    self.PassBtn:addTouchEventListener(handler(self,self.Click_PassCard))
    self.PromptBtn:addTouchEventListener(handler(self,self.Click_Prompt))
    self.OutCardBtn:addTouchEventListener(handler(self,self.Click_OutCard))

    self.PromptBtn2:addTouchEventListener(handler(self,self.Click_Prompt))
    self.OutCardBtn2:addTouchEventListener(handler(self,self.Click_OutCard))

    self.PauseBtn:addClickEventListener(handler(self,self.Click_Pause))
    self.ExitBtn:addClickEventListener(handler(self,self.Click_Exit))

    self.BTN_BTS1:addClickEventListener(handler(self,self.showLeftBtns))
    self.BTN_BACK:addClickEventListener(handler(self,self.Click_Leave))
    self.BTN_DISMISS:addClickEventListener(handler(self,self.Click_Vote))

    self.BTN_BTS2:addClickEventListener(handler(self,self.showRightBtns))
    self.BTN_HELP:addClickEventListener(handler(self,self.Click_Help))
    self.BTN_SETTING:addClickEventListener(handler(self,self.Click_Set))
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

function M:Click_YaoQing()
    G_CommonFunc:addClickSound()
    local strContent = string.format("宁乡跑得快，房间号：%06d,%d人,%d局,来战啊！",G_Data.roomid, G_GameDefine.nPlayerCount, G_GameDefine.nTotalGameCount)
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

function M:Click_LuYin(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.nStartTime = os.time()
        self.SpriteLuyin1:setVisible(true)
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
        self.SpriteLuyin1:setVisible(false)
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
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "pdk.GAME_ReadyReq", {bReady=true})
end

-- 取消准备
function M:Click_CancelReady()
     G_CommonFunc:addClickSound()
     G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "pdk.GAME_ReadyReq", {bReady=false})
end

-- 过牌
function M:Click_PassCard(sender, eventType)
    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    -- 过牌
	self:passCard()
end

-- 出牌
function M:Click_OutCard(sender, eventType)
    if G_Data.bReplay then
        return
    end

    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    -- 获取选择牌
    local tCardData = self.GameCardManager:getCardArray(1, GameCard.Card_Selected)
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "pdk.GAME_OutCardReq", {nCardData = tCardData})
end

-- 提示点击
function M:Click_Prompt(sender, eventType)
    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    self:prompt()
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
    G_DeskScene:LeaveRoom(GameConfigManager.tGameID.PDK)
end

-- 显示玩家信息
function M:showUserInfo(nLocalSeat)
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
                -- 微新未设置图片为"\0"
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
    if len>12 then 
        szNickName = string.sub(szNickName,1,12).."..."
    end
    self.tHeadInfo[nLocalSeat].NameText:setString(szNickName)
end

-- 设置分数
function M:setScore(nLocalSeat, nScore)
	self.tHeadInfo[nLocalSeat].ScoreText:setString(nScore)
end

-- 设置准备
function M:setReady(nLocalSeat, bReady)
   self.tReadySprite[nLocalSeat]:setVisible(bReady)
end

-- 设置牌数
function M:setCardCount(nLocalSeat, nCount)
   self.tShowCardCount[nLocalSeat].Text:setString(nCount)
   if G_DeskScene.tRoomInfo.show_card == 0 then
        self.tShowCardCount[nLocalSeat].Text:setVisible(false)
        self.tShowCardCount[nLocalSeat].Sprite:setVisible(false)
   else
        if nLocalSeat == 1 then 
            return 
        end 
        self.tShowCardCount[nLocalSeat].Text:setVisible(true)
        self.tShowCardCount[nLocalSeat].Sprite:setVisible(true)
   end
end

-- 设置牌数
function M:addCardCount(nLocalSeat, nCount)
    self.tCardCount[nLocalSeat] = self.tCardCount[nLocalSeat] + nCount
    self:setCardCount(nLocalSeat, self.tCardCount[nLocalSeat])
end

-- 显示闹钟
function M:showOutTime(nLocalSeat, bShow)
	if self.scehdule_updateClockTime ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
		self.scehdule_updateClockTime = nil
	end

    self.ClockTime:setVisible(bShow)
    self.ClockBg:setVisible(bShow)

    if not bShow then
        return
    end

    self.nTimeCount = 15
    local tPoint = {cc.p(110,200),cc.p(110,400),cc.p(1000,400)}
    self.ClockBg:setPosition(tPoint[nLocalSeat])
    self.ClockTime:setString(self.nTimeCount)
    self.scehdule_updateClockTime = scheduler:scheduleScriptFunc(handler(self, self.updateClockTime), 1, false)
end

-- 更新闹钟
function M:updateClockTime()
	self.nTimeCount = self.nTimeCount - 1
	if self.nTimeCount <= 0 then
        self.ClockTime:setString("0")
        --self.ClockBg:setVisible(false)
        --self.ClockTime:setVisible(false)
		if self.scehdule_updateClockTime ~= nil then
			scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
			self.scehdule_updateClockTime = nil
		end 
	else
        if self.nTimeCount<=3 then 
            local sound = "Music/timeup_alarm.mp3"
            G_GameDeskManager.Music:playSound(sound,false)
        end 
		self.ClockTime:setString(self.nTimeCount)
	end
end

-- 显示庄
function M:setBankerBySeat(nLocalSeat)
    for i = 1, G_GameDefine.nMaxPlayerCount do
        if i == nLocalSeat then
            self.tBankerSprite[i]:setVisible(true)
        else
            self.tBankerSprite[i]:setVisible(false)
        end
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
    self.tHeadInfo[nLocalSeat].Node:setOpacity(80)
    self.tHeadInfo[nLocalSeat].OfflineSprite:setVisible(true)
end

-- 新玩家
function M:handlePlayerEnterAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.userData.seat)
    -- 显示头像相关
    if msg.userData.offline then
        self.tHeadInfo[nLocalSeat].Node:setOpacity(80)
    else
        self.tHeadInfo[nLocalSeat].Node:setOpacity(255)
    end
    self.tHeadInfo[nLocalSeat].OfflineSprite:setVisible(msg.userData.offline)
    self.tHeadInfo[nLocalSeat].Node:setVisible(true)
    
    -- 显示玩家信息
    self:showUserInfo(nLocalSeat)
    -- 是否显示牌数
    local bShow = G_DeskScene.tRoomInfo.show_card == 1
    self.tShowCardCount[nLocalSeat].Sprite:setVisible(bShow)
    self.tShowCardCount[nLocalSeat].Text:setVisible(bShow)
    --展示地理位置
    if G_GameDefine.nPlayerCount == 3 and G_GameDefine.nGameCount == 0 then 
        self:showLocationMap(msg.userData.seat,msg.userData)
    end 
end

-- 玩家离开
function M:handlePlayerLeaveAck(msg)
    local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nSeat)
    if _player == nil then
        return
    end
    
    local nLocalSeat = G_GamePlayer:getLocalSeat(_player.seat)
    -- 隐藏头像相关
    self.tHeadInfo[nLocalSeat].Node:setVisible(false)
    -- 隐藏准备
    self.tReadySprite[nLocalSeat]:setVisible(false)
    -- 隐藏庄
    self.tBankerSprite[nLocalSeat]:setVisible(false)
    -- 隐藏牌数
    self.tShowCardCount[nLocalSeat].Sprite:setVisible(false)
    -- 置空获取头像
    self.tGetHead[nLocalSeat] = false

    -- 删除玩家
    G_GamePlayer:removePlayerBySeat(msg.nSeat)
end

-- 进入游戏
function M:handleEnterGameAck(msg)
    for i = 1, G_GameDefine.nMaxPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            -- 隐藏头像相关
            self.tHeadInfo[nLocalSeat].Node:setVisible(false)
            -- 隐藏准备
            self.tReadySprite[nLocalSeat]:setVisible(false)
            -- 隐藏庄
            self.tBankerSprite[nLocalSeat]:setVisible(false)
            -- 隐藏牌数
            self.tShowCardCount[nLocalSeat].Sprite:setVisible(false)
        else
            -- 显示头像相关
            if _player.offline then
                self.tHeadInfo[nLocalSeat].Node:setOpacity(80)
            else
                self.tHeadInfo[nLocalSeat].Node:setOpacity(255)
            end
            self.tHeadInfo[nLocalSeat].OfflineSprite:setVisible(_player.offline)
             -- 显示头像相关
            self.tHeadInfo[nLocalSeat].Node:setVisible(true)
            -- 显示玩家信息
            self:showUserInfo(nLocalSeat)
        end
    end
end

-- 断线重连消息
function M:handleSceneAck(msg)
    self.nLastOutSeat = msg.nLastOutSeat
    self.nCurrentSeat = msg.nCurrentSeat
    self.tOutCardData = msg.nTurnCardData

    for i = 1, G_GameDefine.nMaxPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            -- 隐藏牌数
            self.tShowCardCount[nLocalSeat].Sprite:setVisible(false)
        else
            self.tCardCount[nLocalSeat] = msg.nCardCount[i]
            -- 设置玩家牌数
            self:setCardCount(nLocalSeat, self.tCardCount[nLocalSeat])

            -- 未开始前，显示地理信息
            if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then
                if G_GameDefine.nPlayerCount == 3 then
                    self:showLocationMap(_player.seat,_player)
                end
            end
        end
    end

    for i = 1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        -- 显示分数
        self:setScore(nLocalSeat, msg.nGameScore[i])
    end

    if EventConfig.CHECK_IOS then 
        self.YaoQingBtn:setVisible(false)
    else 
        if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then
            self.YaoQingBtn:setVisible(true)
        else
            self.YaoQingBtn:setVisible(false)
        end
    end 
	local nGameCount = G_GameDefine.nGameCount ~= 0 and G_GameDefine.nGameCount or 1
    self.Text_Ju_V:setString("第"..nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
	if msg.nGameStatus == G_GameDefine.game_free then
        self:SetReadyBtn(msg.bReady[nSelfServerSeat], true)
        for i = 1, G_GameDefine.player_count do
            local nLocalSeat = G_GamePlayer:getLocalSeat(i)
            self:setReady(nLocalSeat, msg.bReady[i])
        end
		return
	else
		G_GameDefine.nGameStatus = G_GameDefine.game_play
	end

    for i=1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        -- 设置玩家牌数
        self.GameCardManager:setUserCardCount(nLocalSeat, msg.nCardCount[i])
    end

    -- 显示出牌
    local nOutCardSeat = G_GamePlayer:getLocalSeat(self.nLastOutSeat)
    local tTurnCardData = msg.nTurnCardData
    G_DeskScene.GameLogic.sortCard(tTurnCardData)
    self.GameCardManager:createShowOutCard(nOutCardSeat, tTurnCardData)

    -- 自己牌处理
    local tCardData = msg.nCardData
    G_DeskScene.GameLogic.sortCard(tCardData)
    self.GameCardManager:createShowStandCard(1, tCardData)
    self.GameCardManager:setVisible(true)

    -- 游戏状态,显示出牌相关
    if G_GameDefine.nGameStatus == G_GameDefine.game_play then
        if nSelfServerSeat == self.nCurrentSeat then
            if self.nLastOutSeat == self.nCurrentSeat then
                self:setNodeShow2(true)

                -- 是自己，尝试自动出完牌
                self.GameCardManager:autoOutCard(true, {})
            else
                local bPressCard = self.GameCardManager:pressCard(self.tOutCardData)
                -- 过牌图片
                self:SetPassCardSprite(not bPressCard)
                -- 必须管
                if G_DeskScene.tRoomInfo.press_card == 1 then
                    self:setNodeShow2(true)

                    -- 大得起
                    if bPressCard then
                        -- 是自己，尝试自动出完牌
                        self.GameCardManager:autoOutCard(false, self.tOutCardData)
                    else
                        -- 设置不可选择状态
                        self.GameCardManager:recoverTouchState(false)
                        -- 延时过牌
                        self:delayedPassCard()
                    end
                else
                    self:setNodeShow1(true)

                     -- 大得起
                    if bPressCard then
                        -- 是自己，尝试自动出完牌
                        self.GameCardManager:autoOutCard(false, self.tOutCardData)
                    else
                        -- 设置不可选择状态
                        self.GameCardManager:recoverTouchState(false)
                    end
                end
            end
        end
    end
end

-- 准备消息
function M:handleReadyAck(msg)
	local nReadyLocalSeat = G_GamePlayer:getLocalSeat(msg.nSeat)
    -- 设置玩家准备图片
    self:setReady(nReadyLocalSeat, msg.bReady)

    if nReadyLocalSeat == 1 then
        -- 清除出牌
        self.GameCardManager:clearShowOutCard(0)
        -- 清除牌数据
        self.GameCardManager:restore()
        -- 设置准备按钮
        self:SetReadyBtn(msg.bReady, true)

        for i=1, G_GameDefine.nPlayerCount do
            local nLocalSeat = G_GamePlayer:getLocalSeat(i)
            -- 隐藏报单图片
            self:SetOneCardSprite(nLocalSeat, false)
        end
    end
end

-- 游戏开始
function M:handleGameStartAck(msg)
    -- 清除牌数据
    self.GameCardManager:restore()

	self.YaoQingBtn:setVisible(false)
    self:SetReadyBtn(false, false)
    local nGameCount = G_GameDefine.nGameCount ~= 0 and G_GameDefine.nGameCount or 1
    self.Text_Ju_V:setString("第"..nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

	for i=1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        --  隐藏准备图片
		self:setReady(nLocalSeat, false)
        -- 设置牌数
        self.tCardCount[nLocalSeat] = G_GameDefine.nCardCount
        self:setCardCount(nLocalSeat, self.tCardCount[nLocalSeat])
        -- 隐藏报单图片
        self:SetOneCardSprite(nLocalSeat, false)
        local v = G_GamePlayer:getPlayerBySeat(nLocalSeat)
        local head_bg_btn_ =  self.head_bg_btn[nLocalSeat]
        if head_bg_btn_.info then 

        else 
            head_bg_btn_.info = v
            head_bg_btn_:addClickEventListener(handler(self,self.Click_User_Info))                                 
        end 
	end
	
	local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    -- 设置庄家
	self:setBankerBySeat(nLocalSeat)
    -- 显示时间
    self:showOutTime(nLocalSeat, true)

    -- 显示操作等
    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if nSelfServerSeat == msg.nCurrentSeat then
        self:setNodeShow2(true)
    else
        self:setNodeShow1(false)
        self:setNodeShow2(false)
    end

    local tCardData = msg.nCardData
    G_DeskScene.GameLogic.sortCard(tCardData)
    -- 牌类处理
    self.GameCardManager:createShowStandCard(1, tCardData)
	self.GameCardManager:setVisible(true)
end

-- 出牌消息
function M:handleOutCardAck(msg)
    self.nLastOutSeat = msg.nOutCardSeat
    self.nCurrentSeat = msg.nCurrentSeat
    self.tOutCardData = msg.nCardData

     -- 隐藏按钮
    self:setNodeShow1(false)
    self:setNodeShow2(false)

    if msg.nCurrentSeat == G_GameDefine.invalid_seat then
        -- 隐藏闹钟
        self:showOutTime(-1, false)
    else
        local nCurrentLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
	    self:showOutTime(nCurrentLocalSeat, true)

        -- 清除自己显示出牌
        self.GameCardManager:clearShowOutCard(nCurrentLocalSeat)

        -- 操作玩家是自己
        if nCurrentLocalSeat == 1 then
            local bPressCard = self.GameCardManager:pressCard(msg.nCardData)
            -- 过牌图片
            self:SetPassCardSprite(not bPressCard)
            -- 必须管
            if G_DeskScene.tRoomInfo.press_card == 1 then
                -- 大得起，才显示出牌按钮等
                self:setNodeShow2(bPressCard)
                -- 大得起
                if bPressCard then
                    -- 是自己，尝试自动出完牌
                    self.GameCardManager:autoOutCard(false, msg.nCardData)
                else
                    -- 设置不可选择状态
                    self.GameCardManager:recoverTouchState(false)
                    -- 延时过牌
                    self:delayedPassCard()
                end
            else
                self:setNodeShow1(true)
                 -- 大得起
                if bPressCard then
                    -- 是自己，尝试自动出完牌
                    self.GameCardManager:autoOutCard(false, msg.nCardData)
                else
                    -- 设置不可选择状态
                    self.GameCardManager:recoverTouchState(false)
                end
            end
        end
    end

    local nLastOutLocalSeat = G_GamePlayer:getLocalSeat(self.nLastOutSeat)
    local nOutCardCount = #self.tOutCardData
    -- 增加玩家牌数
    self.GameCardManager:addUserCardCount(nLastOutLocalSeat, nOutCardCount)
    -- 牌数
    self:addCardCount(nLastOutLocalSeat, -nOutCardCount)

    -- 设置报单图片
    self:SetOneCardSprite(nLastOutLocalSeat, msg.bLeftOne)

    -- 显示出牌
    self.GameCardManager:createShowOutCard(nLastOutLocalSeat, msg.nCardData)

    -- 自己是出牌玩家
    if nLastOutLocalSeat == 1 then
        -- 设置自己牌可选择状态,移除牌在createShowOutCard,需要在这后面
        self.GameCardManager:recoverTouchState(true)
        -- 过牌图片
        self:SetPassCardSprite(false)
    end
end

-- 过牌消息
function M:handlePassCardAck(msg)
    -- 删除过牌定时器
    if self.passCard_schedule ~= nil then
		scheduler:unscheduleScriptEntry(self.passCard_schedule)
		self.passCard_schedule = nil
    end

    -- 隐藏按钮
    self:setNodeShow1(false)
    self:setNodeShow2(false)

    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    -- 新一轮
    if msg.bNewTurn then
        -- 清除显示出牌
        self.GameCardManager:clearShowOutCard(0)
        -- 过牌图片
        self:SetPassCardSprite(false)

        -- 不是自己,隐藏按钮等
        if nLocalSeat ~= 1 then
            -- 必须管
            if G_DeskScene.tRoomInfo.press_card == 1 then
                self:setNodeShow2(false)
            else
                self:setNodeShow1(false)
            end
        else
            -- 是自己，尝试自动出完牌
            self.GameCardManager:autoOutCard(true, {})

            -- 显示出牌按钮
            self:setNodeShow2(true)
        end

        -- 设置可选择状态
        self.GameCardManager:recoverTouchState(true)

        self.tOutCardData = {}
    else
        -- 必须管
        if G_DeskScene.tRoomInfo.press_card == 1 then
            self:setNodeShow2(false)
        else
            self:setNodeShow1(false)
        end

        if nLocalSeat == 1 then
            -- 清除自己显示出牌
            self.GameCardManager:clearShowOutCard(1)

            local bPressCard = self.GameCardManager:pressCard(self.tOutCardData)
            -- 过牌图片
            self:SetPassCardSprite(not bPressCard)
            -- 必须管
            if G_DeskScene.tRoomInfo.press_card == 1 then
                -- 大得起，才显示出牌按钮等
                self:setNodeShow2(bPressCard)
                -- 大得起
                if bPressCard then
                    -- 是自己，尝试自动出完牌
                    self.GameCardManager:autoOutCard(false, self.tOutCardData)
                else
                    -- 设置不可选择状态
                    self.GameCardManager:recoverTouchState(false)
                    -- 延时过牌
                    self:delayedPassCard()
                end
            else
                self:setNodeShow1(true)
                 -- 大得起
                if bPressCard then
                    -- 是自己，尝试自动出完牌
                    self.GameCardManager:autoOutCard(false, self.tOutCardData)
                else
                    -- 设置不可选择状态
                    self.GameCardManager:recoverTouchState(false)
                end
            end
        end
    end

    -- 显示时钟
    self:showOutTime(nLocalSeat, true)
end

-- 游戏结束
function M:handleGameEndAck(msg)
    -- 隐藏按钮
    self:setNodeShow1(false)
    self:setNodeShow2(false)

    -- 隐藏闹钟
    self:showOutTime(-1, false)

    local nWinSeat = 0
    for i=1, G_GameDefine.nMaxPlayerCount do
        if msg.card[i] ~= nil then
            -- 创建显示结束牌
            local nLocalSeat = G_GamePlayer:getLocalSeat(i)
            local nCardData = msg.card[i].nCardData
            G_DeskScene.GameLogic.sortCard(nCardData)
            self.GameCardManager:createShowEndCard(nLocalSeat, nCardData)

            if #msg.card[i].nCardData == 0 then
                nWinSeat = i
            else
                -- 清除非胜利玩家出牌
                self.GameCardManager:clearShowOutCard(nLocalSeat)
            end
        end
    end

    for i = 1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        -- 显示分数
        self:setScore(nLocalSeat, msg.nTotalScore[i])
    end

    -- 隐藏赢家报单图片
    local nWinLocalSeat = G_GamePlayer:getLocalSeat(nWinSeat)
    self:SetOneCardSprite(nWinLocalSeat, false)
end

-- 显示准备按钮
function M:SetReadyBtn(bReady, bShow)
    if bShow then
        self.ReadyBtn:setVisible(not bReady)
        self.CancelReadyBtn:setVisible(bReady)
    else
        self.ReadyBtn:setVisible(false)
        self.CancelReadyBtn:setVisible(false)
    end
end

-- 显示房间信息
function M:showRoomInfo(strInfo)
    -- self.GameRuleText:setString(strInfo)
    -- self.GameRuleText:setVisible(true)
end

-- 显示过牌图片
function M:SetPassCardSprite(bShow)
    self.PassCardSprite:setVisible(bShow)
end

-- 显示报单图片
function M:SetOneCardSprite(nLocalSeat, bShow)
    self.tOneCardSprite[nLocalSeat]:setVisible(bShow)
end

-- 设置不出、出牌、提示
function M:setNodeShow1(bVisible)
	self.Node1:setVisible(bVisible)
end

-- 设置出牌、提示
function M:setNodeShow2(bVisible)
	self.Node2:setVisible(bVisible)
end

-- 过牌
function M:passCard()
    if G_Data.bReplay then
        return
    end

    if self.passCard_schedule ~= nil then
		scheduler:unscheduleScriptEntry(self.passCard_schedule)
		self.passCard_schedule = nil
    end

    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "pdk.GAME_PassCardReq", {})
end

-- 提示
function M:prompt()
    -- 没有提示
    if not self.GameCardManager:prompt(self.tOutCardData) then
        -- 直接pass
	    self:passCard()
    end
end

-- 延时过牌
function M:delayedPassCard()
    if self.passCard_schedule ~= nil then
		scheduler:unscheduleScriptEntry(self.passCard_schedule)
		self.passCard_schedule = nil
    end
    self.passCard_schedule = scheduler:scheduleScriptFunc(handler(self, self.passCard), 1, false)
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
        self.Node1_0:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end))) 

    else 
        self.BTN_BTS1:loadTexture("left-1.png", ccui.TextureResType.plistType)
        local x = self.Node1_0:getPositionX() - 300
        local y = 537 
        local pos = cc.p(x,y)
        self.Node1_0:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

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
    if self.selectRight then 
        self.BTN_BTS2:loadTexture("right-2.png", ccui.TextureResType.plistType)
        local x = 1030
        local y = 537
        local pos = cc.p(x,y)
        self.Node2_0:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

        end)))
    else
        self.BTN_BTS2:loadTexture("right-1.png", ccui.TextureResType.plistType)
        local x = self.Node2_0:getPositionX() + 300
        local y = 537 
        local pos = cc.p(x,y)
        self.Node2_0:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,pos),cc.CallFunc:create(function()

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
    self.locationMapLayer:setLocation(nLocalSeat,player)
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
    for i = 1, G_GameDefine.nMaxPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            -- 隐藏头像相关
            self.tHeadInfo[nLocalSeat].Node:setVisible(false)
            -- 隐藏准备
            self.tReadySprite[nLocalSeat]:setVisible(false)
            -- 隐藏庄
            self.tBankerSprite[nLocalSeat]:setVisible(false)
            -- 隐藏牌数
            self.tShowCardCount[nLocalSeat].Sprite:setVisible(false)
        else
             -- 显示头像相关
            self.tHeadInfo[nLocalSeat].Node:setVisible(true)
            -- 显示玩家信息
            self:showUserInfo(nLocalSeat)
            -- 显示分数
            self:setScore(nLocalSeat, _player.score)
        end
    end

    -- 清除牌数据
    self.GameCardManager:restore()

    self.LuYinBtn:setVisible(false)
	self.ChatBtn:setVisible(false)
	self.YaoQingBtn:setVisible(false)
    self:SetReadyBtn(false, false)
    self.ReplayBg:setVisible(true)

    self.BTN_BTS1:setVisible(false)
    self.BTN_BTS2:setVisible(false)

    self.Text_Ju_V:setString("第"..msg.head.count.."/"..G_GameDefine.nTotalGameCount.."局")
    self.Text_Fang_V:setString(msg.head.room_id)

	for i=1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        --  隐藏准备图片
		self:setReady(nLocalSeat, false)
        
        -- 设置牌数
        self.tCardCount[nLocalSeat] = G_GameDefine.nCardCount
        self:setCardCount(nLocalSeat, self.tCardCount[nLocalSeat])
        -- 隐藏报单图片
        self:SetOneCardSprite(nLocalSeat, false)
	end
	
	local nLocalSeat = G_GamePlayer:getLocalSeat(msg.game.prepare_data.nCurrentSeat)
    -- 设置庄家
	self:setBankerBySeat(nLocalSeat)
    -- 显示时间
    self:showOutTime(nLocalSeat, true)

    -- 显示操作等
    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if nSelfServerSeat == msg.nCurrentSeat then
        self:setNodeShow2(true)
    else
        self:setNodeShow1(false)
        self:setNodeShow2(false)
    end

    for i, tCardData in ipairs(msg.game.prepare_data.nCardData) do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        G_DeskScene.GameLogic.sortCard(tCardData)
        self.GameCardManager:createShowStandCard(nLocalSeat, tCardData)
	    self.GameCardManager:setVisible(true)
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

function M:Click_User_Info(e)
    -- body
    G_CommonFunc:addClickSound()
    G_DeskScene:Click_User_Info(e)
end

return M
