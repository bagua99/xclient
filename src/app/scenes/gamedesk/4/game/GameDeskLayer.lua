
local M = class("GameDeskLayer", G_BaseLayer)

local GameConfigManager             = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.NXPHZ.."/GameDeskLayer.csb"

local scheduler                     = cc.Director:getInstance():getScheduler()
local targetPlatform                = cc.Application:getInstance():getTargetPlatform()

local GameHandCardManager           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameHandCardManager")
local GameWeaveCardManager          = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameWeaveCardManager")
local GameOutCardManager            = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameOutCardManager")
local GameChiCardManager            = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameChiCardManager")

local EventConfig                   = require ("app.config.EventConfig")

local bit = require("bit")

-- 创建
function M:onCreate()
    -- 邀请按钮
	self.Button_YaoQing             = self.resourceNode_.node["Button_YaoQing"]
    -- 准备按钮
    self.Button_Ready               = self.resourceNode_.node["Button_Ready"]
    -- 取消准备按钮
    self.Button_CancelReady         = self.resourceNode_.node["Button_CancelReady"]

    -- 录音
    self.Button_LuYin               = self.resourceNode_.node["Button_LuYin"]
    -- 聊天
	self.Button_Chat                = self.resourceNode_.node["Button_Chat"]

    -- 回放
    self.Sprite_ReplayBG            = self.resourceNode_.node["Sprite_ReplayBG"]
    -- 暂停
    self.Button_Pause               = self.resourceNode_.node["Sprite_ReplayBG"].node["Button_Pause"]
    -- 退出
    self.Button_Exit                = self.resourceNode_.node["Sprite_ReplayBG"].node["Button_Exit"]

    -- 返回
    self.Button_Back                = self.resourceNode_.node["Button_Back"]
    -- 解散
    self.Button_Vote                = self.resourceNode_.node["Button_Vote"]
    -- 重启
    self.Button_Restart             = self.resourceNode_.node["Button_Restart"]
    -- 设置
    self.Button_Set                 = self.resourceNode_.node["Button_Set"]

    -- 房间ID
    self.Text_Fang_V    = self.resourceNode_.node["ImageView_RuleBG"].node["Text_Fang_V"]
    -- 游戏局数
    self.Text_Ju_V      = self.resourceNode_.node["ImageView_RuleBG"].node["Text_Ju_V"]

    -- 头像相关
    self.tHeadInfo = {}
    for i = 1, G_GameDefine.nPlayerCount do
        local tInfo = {}
        tInfo.ImageView_HeadBG      = self.resourceNode_.node["Node_Head"..i].node["ImageView_HeadBG"]
        tInfo.Sprite_Head           = self.resourceNode_.node["Node_Head"..i].node["ImageView_HeadBG"].node["Sprite_Head"]
        tInfo.Text_Name             = self.resourceNode_.node["Node_Head"..i].node["ImageView_HeadBG"].node["Text_Name"]
        tInfo.Text_Score            = self.resourceNode_.node["Node_Head"..i].node["ImageView_HeadBG"].node["Text_Score"]
        tInfo.ImageView_Offline     = self.resourceNode_.node["Node_Offline"].node["ImageView_Offline"..i]
        self.tHeadInfo[i] = tInfo
    end

    -- 其他
    self.Node_Other             = self.resourceNode_.node["Node_Other"]
    self.tSpriteReady = {}
    self.tSpriteBanker = {}
    for i = 1, G_GameDefine.nPlayerCount do
        self.tSpriteReady[i]    = self.resourceNode_.node["Node_Other"].node["Sprite_Ready"..i]
        self.tSpriteBanker[i]   = self.resourceNode_.node["Node_Other"].node["Sprite_Banker"..i]
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
    for i = 1, G_GameDefine.nPlayerCount do
        self.tGetHead[i] = false
    end

    -- 牌墩信息
    self.nLeftCardCount = G_GameDefine.MAX_LEFT
    self.Sprite_CardDunBG   = self.resourceNode_.node["Node_CardDun"].node["Sprite_CardDunBG"]
    self.Sprite_CardDun     = self.resourceNode_.node["Node_CardDun"].node["Sprite_CardDun"]
    self.TextAtlas_CardDun  = self.resourceNode_.node["Node_CardDun"].node["Sprite_CardDun"].node["TextAtlas_CardDun"]

    -- 发牌,出牌信息
    self.Sprite_CardBG   = self.resourceNode_.node["Node_Card"].node["Sprite_CardBG"]
    self.Sprite_Card     = self.resourceNode_.node["Node_Card"].node["Sprite_Card"]
    self.tSendOutCardPoint =
    {
        cc.p(564, 378),
        cc.p(310, 450),
        cc.p(800, 450),
    }

    -- 操作信息
    self.Node_Operate    = self.resourceNode_.node["Node_Operate"]
    self.Button_Chi      = self.resourceNode_.node["Node_Operate"].node["Button_Chi"]
    self.Button_Peng     = self.resourceNode_.node["Node_Operate"].node["Button_Peng"]
    self.Button_Hu       = self.resourceNode_.node["Node_Operate"].node["Button_Hu"]
    self.Button_Pass     = self.resourceNode_.node["Node_Operate"].node["Button_Pass"]
    self.tOperatePoint = 
    {
        [1] = {cc.p(470, 360)},
        [2] = {cc.p(470, 360), cc.p(620, 360)},
        [3] = {cc.p(470, 360), cc.p(620, 360), cc.p(770, 360)},
        [4] = {cc.p(320, 360), cc.p(470, 360), cc.p(620, 360), cc.p(770, 360)},
    }
    self.nOperateCardData  = 0
end

-- 初始化视图
function M:initView()
	self.Button_YaoQing:setVisible(false)
    self.Button_Ready:setVisible(false)
    self.Button_CancelReady:setVisible(false)

    self.SpriteLuyin1 = cc.Sprite:create("Voice/record_0.png")
	self.SpriteLuyin1:setPosition(cc.p(display.width/2,display.height/2))
	self.SpriteLuyin1:setVisible(false)
	self:addChild(self.SpriteLuyin1)

	local actSpr = cc.Sprite:create("Voice/p1.png")
	actSpr:setPosition(cc.p(self.SpriteLuyin1:getBoundingBox().width/2 + 50, self.SpriteLuyin1:getBoundingBox().height/2 + 30))
	local curAnimate = cc.Animation:create()
	for i = 1, 6 do
		curAnimate:addSpriteFrameWithFile("Voice/p"..i..".png")
	end
	curAnimate:setDelayPerUnit(1/3)
	curAnimate:setRestoreOriginalFrame(true)
    
	local curAction = cc.Animate:create(curAnimate)
	actSpr:runAction(cc.RepeatForever:create(curAction))
	self.SpriteLuyin1:addChild(actSpr)

    self.Sprite_ReplayBG:setVisible(false)

    for nIndex, tInfo in pairs(self.tHeadInfo) do
        tInfo.ImageView_HeadBG:setVisible(false)
        tInfo.ImageView_Offline:setVisible(false)
        tInfo.Text_Name:setContentSize(cc.size(100,40))
        tInfo.Text_Score:setContentSize(cc.size(100,40))
    end

    self.Node_Other:setVisible(true)
    for _, pSprite in pairs(self.tSpriteReady) do
        pSprite:setVisible(false)
    end
    for _, pSprite in pairs(self.tSpriteBanker) do
        pSprite:setVisible(false)
    end

    -- 闹钟相关
    self.ClockBg = cc.Sprite:create("Common/clock.png")
	self.ClockBg:setScale(0.8)
    self.ClockBg:setVisible(false)
	self:addChild(self.ClockBg)

    -- 游戏手牌管理类
	self.GameHandCardManager = GameHandCardManager:create()
	self:addChild(self.GameHandCardManager)

    -- 游戏组合牌管理类
    self.GameWeaveCardManager = {}
    for i = 1, G_GameDefine.nPlayerCount do
	    self.GameWeaveCardManager[i] = GameWeaveCardManager:create(i)
	    self:addChild(self.GameWeaveCardManager[i])
    end

    -- 游戏出牌管理类
    self.GameOutCardManager = {}
    for i = 1, G_GameDefine.nPlayerCount do
	    self.GameOutCardManager[i] = GameOutCardManager:create(i)
	    self:addChild(self.GameOutCardManager[i])
    end

    -- 游戏吃牌处理
    self.GameChiCardManager = GameChiCardManager:create()
	self:addChild(self.GameChiCardManager)

	self.ClockTime = ccui.TextAtlas:create("15","Common/clock_font.png",20,28,"0")
    self.ClockTime:setVisible(false)
	self:addChild(self.ClockTime)

    self.Text_Fang_V:setString(G_Data.roomid)

    -- 牌墩信息
    self.Sprite_CardDunBG:setVisible(false)
    self.Sprite_CardDun:setVisible(false)

    -- 发牌,出牌信息
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    -- 操作信息
    self.Node_Operate:setVisible(false)
end

-- 初始化触摸
function M:initTouch()
	self.Button_YaoQing:addClickEventListener(handler(self,self.Click_YaoQing))
    self.Button_Ready:addClickEventListener(handler(self,self.Click_Ready))
    self.Button_CancelReady:addClickEventListener(handler(self,self.Click_CancelReady))

    self.Button_LuYin:addTouchEventListener(handler(self,self.Click_LuYin))
	self.Button_Chat:addClickEventListener(handler(self,self.Click_Chat))

    self.Button_Pause:addClickEventListener(handler(self,self.Click_Pause))
    self.Button_Exit:addClickEventListener(handler(self,self.Click_Exit))

    self.Button_Back:addClickEventListener(handler(self,self.Click_Leave))
    self.Button_Vote:addClickEventListener(handler(self,self.Click_Vote))

    self.Button_Restart:addClickEventListener(handler(self,self.Click_Restart))
    self.Button_Set:addClickEventListener(handler(self,self.Click_Set))

    self.Button_Chi:addClickEventListener(handler(self,self.Click_OperateChi))
    self.Button_Peng:addClickEventListener(handler(self,self.Click_OperatePeng))
    self.Button_Hu:addClickEventListener(handler(self,self.Click_OperateHu))
    self.Button_Pass:addClickEventListener(handler(self,self.Click_OperatePass))
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
    local strContent = string.format("宁乡跑胡子，房间号：%06d,%d人,%d局,来战啊！",G_Data.roomid, G_GameDefine.nPlayerCount, G_GameDefine.nTotalGameCount)
    ef.extensFunction:getInstance():wxInviteFriend(0, "好友@你", strContent, "", GameConfig.download_url)
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

-- 重启
function M:Click_Restart()
    G_CommonFunc:addClickSound()
    G_CommonFunc:startGame()
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

                    local userid = G_GamePlayer:getMainPlayer().userid

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
                        self.tHeadInfo[nLocalSeat].ImageView_HeadBG:addChild(self.playRecordSp)
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
                    luaj.callStaticMethod(className, "playRecordByFile", args, sigs)
                end
            end

            local args = {callbackLu }
            local sigs = "(I)V"
            local luaj = require "cocos.cocos2d.luaj"
            local className = "com/hnqp/pdkgame/AppActivity"
            luaj.callStaticMethod(className,"record",args,sigs)

        elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then 
            local function callbackLua(url)
                if url then
                    G_GameDeskManager.Music:resumeBackMusic()
                    self:stopRecord()
                    
                    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "protocol.VoiceChatReq",{voice=url})
                    
                    local userid = G_GamePlayer:getMainPlayer().userid

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
                        self.tHeadInfo[nLocalSeat].ImageView_HeadBG:addChild(self.playRecordSp)
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
    elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        self.SpriteLuyin1:setVisible(false)
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
        luaj.callStaticMethod(className,"stopRecord",args,sigs)
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then 
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "RootViewController"
        luaoc.callStaticMethod(className,"stopRecord", {}) 
    end 
end

-- 聊天
function M:Click_Chat(sender, eventType)
    G_CommonFunc:addClickSound()
    G_DeskScene:setChatLayerVisible(true)
end

-- 点击准备
function M:Click_Ready()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nxphz.GAME_ReadyReq", {bReady=true})
end

-- 取消准备
function M:Click_CancelReady()
    G_CommonFunc:addClickSound()
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nxphz.GAME_ReadyReq", {bReady=false})
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
    G_DeskScene:LeaveRoom()
end

-- 显示玩家信息
function M:showUserInfo(nLocalSeat)
    if nLocalSeat == 0 then
        for i = 1, G_GameDefine.nPlayerCount do
            local nSeat = G_GamePlayer:getLocalSeat(i)
            if not self.tGetHead[nSeat] then
	            local _player = G_GamePlayer:getPlayerBySeat(nSeat)
                if _player ~= nil then
                    local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
                    local msg = {seat = nSeat, saveName = saveName}
                    if cc.FileUtils:getInstance():isFileExist(saveName) then
                        self:getHeadImg(msg)
                    end

                    local url = _player.headimgurl
	                if string.len(url) > 0 then
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
                    self:getHeadImg(msg)
                end

                local url = _player.headimgurl
	            if string.len(url) > 0 then
			        G_CommonFunc:httpForImg(url, saveName, handler(self, self.getHeadImg), msg)
	            end
	            self:setNickname(nLocalSeat, _player.nickname)
            end
        end
    end
end

-- 取得头像
function M:getHeadImg(msg)
    if msg == nil then
        return
    end

    local nLocalSeat = msg.seat
    self.tGetHead[nLocalSeat] = true
    local nHeadSize = 82.5
    if self.tHeadInfo[nLocalSeat].Sprite_Head ~= nil then
	    self.tHeadInfo[nLocalSeat].Sprite_Head:setTexture(msg.saveName)
        local width = self.tHeadInfo[nLocalSeat].Sprite_Head:getContentSize().width
        local height = self.tHeadInfo[nLocalSeat].Sprite_Head:getContentSize().height
	    self.tHeadInfo[nLocalSeat].Sprite_Head:setScale(nHeadSize/width, nHeadSize/height)
    end	
end

-- 设置名字
function M:setNickname(nLocalSeat, szNickName)
    local len = string.len(szNickName)
    if len > 12 then 
        szNickName = string.sub(szNickName,1,12).."..."
    end
    self.tHeadInfo[nLocalSeat].Text_Name:setString(szNickName)
end

-- 设置分数
function M:setScore(nLocalSeat, nScore)
	self.tHeadInfo[nLocalSeat].Text_Score:setString(nScore)
end

-- 设置准备
function M:setReady(nLocalSeat, bReady)
   self.tSpriteReady[nLocalSeat]:setVisible(bReady)
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
    local tPoint = {cc.p(240, 285), cc.p(220, 370), cc.p(900, 370)}
    self.ClockBg:setPosition(tPoint[nLocalSeat])
    self.ClockTime:setString(self.nTimeCount)
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
        if self.nTimeCount<=3 then 
            local sound = "res/Music/timeup_alarm.mp3"
            G_GameDeskManager.Music:playSound(sound,false)
        end 
		self.ClockTime:setString(self.nTimeCount)
	end
end

-- 显示庄
function M:setBankerBySeat(nLocalSeat)
    for i = 1, G_GameDefine.nPlayerCount do
        if i == nLocalSeat then
            self.tSpriteBanker[i]:setVisible(true)
        else
            self.tSpriteBanker[i]:setVisible(false)
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
            self.tHeadInfo[nLocalSeat].ImageView_HeadBG:addChild(self.playRecordSp)
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
        luaj.callStaticMethod(className, "playRecord", args, sigs)
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then 
         local recordStart = function(params)
            G_GameDeskManager.Music:pauseBackMusic()
            if self.playRecordSp then 
                self.playRecordSp:removeFromParent()
            end 
            self.playRecordSp = nil 

            local actSpr = cc.Sprite:create("Voice/voice0.png")
            local curAnimate = cc.Animation:create()
            for i = 0, 3 do
                curAnimate:addSpriteFrameWithFile("Voice/voice"..i..".png")
            end
            curAnimate:setDelayPerUnit(1/3)
            curAnimate:setRestoreOriginalFrame(true)

            local curAction = cc.Animate:create(curAnimate)
            actSpr:runAction(cc.RepeatForever:create(curAction)) 
            self.playRecordSp = actSpr 

            local seat = G_GamePlayer:getPlayerByUserId(userid).seat
            local nLocalSeat = G_GamePlayer:getLocalSeat(seat)
            self.tHeadInfo[nLocalSeat].ImageView_HeadBG:addChild(self.playRecordSp)
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
        luaoc.callStaticMethod(className,"playRecord", {recordStart = recordStart, recordFinish = recordFinish, url = url}) 
    end
end

-- 玩家断线
function M:handleUserOfflineAck(msg)
    local player = G_GamePlayer:getPlayerByUserId(msg.userid)
    if player == nil then 
        return 
    end 
    local nLocalSeat = G_GamePlayer:getLocalSeat(player.seat)
    self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setOpacity(80)
    self.tHeadInfo[nLocalSeat].ImageView_Offline:setVisible(true)
end

-- 新玩家
function M:handlePlayerEnterAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.userData.seat)
    -- 显示头像相关
    if msg.userData.offline then
        self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setOpacity(80)
    else
        self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setOpacity(255)
    end
    self.tHeadInfo[nLocalSeat].ImageView_Offline:setVisible(msg.userData.offline)
    self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setVisible(true)
    
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
    self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setVisible(false)
    -- 隐藏准备
    self.tSpriteReady[nLocalSeat]:setVisible(false)
    -- 隐藏庄
    self.tSpriteBanker[nLocalSeat]:setVisible(false)
    -- 置空获取头像
    self.tGetHead[nLocalSeat] = false

    -- 删除玩家
    G_GamePlayer:removePlayerBySeat(msg.nSeat)
end

-- 进入游戏
function M:handleEnterGameAck(msg)
    for i = 1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            -- 隐藏头像相关
            self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setVisible(false)
            -- 隐藏准备
            self.tSpriteReady[nLocalSeat]:setVisible(false)
            -- 隐藏庄
            self.tSpriteBanker[nLocalSeat]:setVisible(false)
        else
            -- 显示头像相关
            if _player.offline then
                self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setOpacity(80)
            else
                self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setOpacity(255)
            end
            self.tHeadInfo[nLocalSeat].ImageView_Offline:setVisible(_player.offline)
             -- 显示头像相关
            self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setVisible(true)
            -- 显示玩家信息
            self:showUserInfo(nLocalSeat)
        end
    end
end

-- 断线重连消息
function M:handleSceneAck(msg)
    for i = 1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        -- 显示分数
        self:setScore(nLocalSeat, msg.tGameScore[i])
    end

    if EventConfig.CHECK_IOS then
        self.Button_YaoQing:setVisible(false)
    else 
        if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.GAME_FREE then
            self.Button_YaoQing:setVisible(true)
        else
            self.Button_YaoQing:setVisible(false)
        end
    end 
	local nGameCount = G_GameDefine.nGameCount ~= 0 and G_GameDefine.nGameCount or 1
    self.Text_Ju_V:setString("第"..nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
	if msg.nGameStatus == G_GameDefine.GAME_FREE then
        self:SetReadyBtn(msg.bReady[nSelfServerSeat], true)
        for i = 1, G_GameDefine.player_count do
            local nLocalSeat = G_GamePlayer:getLocalSeat(i)
            self:setReady(nLocalSeat, msg.bReady[i])
        end
		return
	else
		G_GameDefine.nGameStatus = G_GameDefine.GAME_PLAY
	end
end

-- 准备消息
function M:handleReadyAck(msg)
	local nReadyLocalSeat = G_GamePlayer:getLocalSeat(msg.nSeat)
    -- 设置玩家准备图片
    self:setReady(nReadyLocalSeat, msg.bReady)

    if nReadyLocalSeat == 1 then
        -- 设置准备按钮
        self:SetReadyBtn(msg.bReady, true)

        -- 还原数据
        self.GameHandCardManager:restore()
        for i = 1, G_GameDefine.nPlayerCount do
            self.GameWeaveCardManager[i]:restore()
            self.GameOutCardManager[i]:restore()
        end
    end
end

-- 游戏开始
function M:handleGameStartAck(msg)
	self.Button_YaoQing:setVisible(false)
    self:SetReadyBtn(false, false)
    local nGameCount = G_GameDefine.nGameCount ~= 0 and G_GameDefine.nGameCount or 1
    self.Text_Ju_V:setString("第"..nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

	for i = 1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        --  隐藏准备图片
		self:setReady(nLocalSeat, false)
	end

    -- 发牌,出牌信息
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    -- 隐藏操作
    self.Node_Operate:setVisible(false)

    -- 还原数据
    self.GameHandCardManager:restore()
    for i = 1, G_GameDefine.nPlayerCount do
        self.GameWeaveCardManager[i]:restore()
        self.GameOutCardManager[i]:restore()
    end
	
	local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    -- 设置庄家
	self:setBankerBySeat(nLocalSeat)
    -- 显示时间
    self:showOutTime(nLocalSeat, true)

    -- 显示牌墩信息
    self.nLeftCardCount = G_GameDefine.MAX_LEFT
    self.Sprite_CardDunBG:setVisible(true)
    self.Sprite_CardDun:setVisible(true)
    self.TextAtlas_CardDun:setString(self.nLeftCardCount)

    -- 设置玩家手牌
    self.GameHandCardManager:sortCard(msg.nCardData)
    self.GameHandCardManager:setOutCard(nLocalSeat == 1)
end

-- 出牌消息
function M:handleOutCardAck(msg)
    -- 移除打出去的牌
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nLocalSeat == 1 then
        self.GameHandCardManager:removeOneCard(msg.nCardData)
    end

    -- 显示打出去的牌
    local nPoint = self.tSendOutCardPoint[nLocalSeat]
    self.Sprite_CardBG:setTexture("nxphz_OutCardBg.png")
    self.Sprite_CardBG:setPosition(nPoint)
    self.Sprite_CardBG:setVisible(true)
    self.Sprite_Card:setSpriteFrame("d"..msg.nCardData..".png")
    self.Sprite_Card:setPosition(nPoint)
    self.Sprite_Card:setVisible(true)
end

-- 出牌提示
function M:handleOutCardNotifyAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    -- 隐藏出牌或发牌
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    -- 隐藏操作信息
    self.Node_Operate:setVisible(false)

    if msg.bOutCard then
        -- 设置出牌
        self.GameHandCardManager:setOutCard(nLocalSeat == 1)
    else
        -- 设置出牌
        self.GameHandCardManager:setOutCard(false)
    end
end

-- 发牌消息
function M:handleSendCardAck(msg)
    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)

    -- 设置牌数
    self.nLeftCardCount = self.nLeftCardCount - 1
    self.TextAtlas_CardDun:setString(self.nLeftCardCount)
    if self.nLeftCardCount == 0 then
        self.Sprite_CardDun:setVisible(false)
    end

    if msg.nCardData > 0 then
        -- 显示发的牌
        local nPoint = self.tSendOutCardPoint[nLocalSeat]
        self.Sprite_CardBG:setTexture("nxphz_SendCardBg.png")
        self.Sprite_CardBG:setPosition(nPoint)
        self.Sprite_CardBG:setVisible(true)
        self.Sprite_Card:setSpriteFrame("d"..msg.nCardData..".png")
        self.Sprite_Card:setPosition(nPoint)
        self.Sprite_Card:setVisible(true)
    end

    -- 增加玩家出牌
    if msg.nOutCardSeat ~= G_GameDefine.INVALID_SEAT and msg.nOutCardData ~= 0 then
        local nLocalOutCardSeat = G_GamePlayer:getLocalSeat(msg.nOutCardSeat)
        self.GameOutCardManager[nLocalOutCardSeat]:addOneCard(msg.nOutCardData)
    end
end

-- 操作消息
function M:handleOperateCardAck(msg)
    self.nOperateCardData = msg.nCardData

    local tOperate = {}
    if bit.band(msg.nOperate, G_GameDefine.ACK_CHI) == G_GameDefine.ACK_CHI then
        table.insert(tOperate, self.Button_Chi)
    end
    if bit.band(msg.nOperate, G_GameDefine.ACK_PENG) == G_GameDefine.ACK_PENG then
        table.insert(tOperate, self.Button_Peng)
    end
    if bit.band(msg.nOperate, G_GameDefine.ACK_CHIHU) == G_GameDefine.ACK_CHIHU then
        table.insert(tOperate, self.Button_Hu)
    end
    if #tOperate > 0 then
        table.insert(tOperate, self.Button_Pass)
    end

    local nCount = #tOperate
    local tPoint = self.tOperatePoint[nCount]
    if nCount > 0 and tPoint then
        self.Node_Operate:setVisible(true)
        self.Button_Chi:setVisible(false)
        self.Button_Peng:setVisible(false)
        self.Button_Hu:setVisible(false)
        self.Button_Pass:setVisible(false)

        for nIndex, pButton in ipairs(tOperate) do
            pButton:setPosition(tPoint[nIndex])
            pButton:setVisible(true)
        end
    else
        self.Node_Operate:setVisible(false)
    end
end

-- 提牌
function M:handleTiCardAck(msg)
    -- 隐藏出牌或发牌
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nLocalSeat == 1 then
        -- 移除手上牌
        local tRemoveCard = {}
        for i = 1, msg.nRemoveCount do
            table.insert(tRemoveCard, msg.nCardData)
        end
        self.GameHandCardManager:removeMoreCard(tRemoveCard)
    end

    -- 偎变提
    if msg.bWeiToTi then
        self.GameWeaveCardManager[nLocalSeat]:onWeiToTi(msg.nCardData)
    else
        local tWeave =
        {
            nWeaveKind = G_GameDefine.ACK_TI,
            nCenterCard = msg.nCardData,
            tCardData = {msg.nCardData, msg.nCardData, msg.nCardData, msg.nCardData}
        }
        self.GameWeaveCardManager[nLocalSeat]:addCardInfo(tWeave)
    end
end

-- 偎牌
function M:handleWeiCardAck(msg)
    -- 隐藏出牌或发牌
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nLocalSeat == 1 then
        -- 移除手上牌
        local tRemoveCard = {msg.nCardData, msg.nCardData}
        self.GameHandCardManager:removeMoreCard(tRemoveCard)

        local tWeave =
        {
            nWeaveKind = G_GameDefine.ACK_WEI,
            nCenterCard = msg.nCardData,
            tCardData = {msg.nCardData, msg.nCardData, msg.nCardData}
        }
        self.GameWeaveCardManager[nLocalSeat]:addCardInfo(tWeave)
    else
        local tWeave =
        {
            nWeaveKind = G_GameDefine.ACK_WEI,
            nCenterCard = msg.nCardData,
            tCardData = {msg.nCardData, msg.nCardData, msg.nCardData}
        }
        if msg.bChouWei then
            tWeave.tCardData = {0, 0, msg.nCardData}
        end
        self.GameWeaveCardManager[nLocalSeat]:addCardInfo(tWeave)
    end
end

-- 跑牌
function M:handlePaoCardAck(msg)
    -- 隐藏出牌或发牌
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    dump(msg)

    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nLocalSeat == 1 then
        -- 移除手上牌
        local tRemoveCard = {}
        for i = 1, msg.nRemoveCount do
            table.insert(tRemoveCard, msg.nCardData)
        end
        self.GameHandCardManager:removeMoreCard(tRemoveCard)
    end

    -- 偎变跑
    if msg.bWeiToPao then
        self.GameWeaveCardManager[nLocalSeat]:onWeiToPao(msg.nCardData)
    else
        -- 手上牌变跑
        if msg.nRemoveCount > 0 then
            local tWeave =
            {
                nWeaveKind = G_GameDefine.ACK_PAO,
                nCenterCard = msg.nCardData,
                tCardData = {msg.nCardData, msg.nCardData, msg.nCardData, msg.nCardData}
            }
            self.GameWeaveCardManager[nLocalSeat]:addCardInfo(tWeave)
        else
            -- 牌墩碰变跑
            self.GameWeaveCardManager[nLocalSeat]:onPengToPao(msg.nCardData)
        end
    end
end

-- 吃牌
function M:handleChiCardAck(msg)
    -- 隐藏出牌或发牌
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nLocalSeat == 1 then
        -- 移除手上牌
        local tRemoveCard = {}
        for k, v in ipairs(msg.tCardData) do
            -- 第一张是吃的牌,不加入
            if k ~= 1 then
                table.insert(tRemoveCard, v)
            end
        end
        self.GameHandCardManager:removeMoreCard(tRemoveCard)
    end

    local nWeaveCount = #msg.tCardData / 3
    for i = 1, nWeaveCount do
        -- 吃
        local tWeave =
        {
            nWeaveKind = G_GameDefine.ACK_CHI,
            nCenterCard = msg.tCardData[1],
            tCardData = {msg.tCardData[(i-1)*3 + 1], msg.tCardData[(i-1)*3 + 2], msg.tCardData[(i-1)*3 + 3]}
        }
        self.GameWeaveCardManager[nLocalSeat]:addCardInfo(tWeave)
    end
end

-- 碰牌
function M:handlePengCardAck(msg)
    -- 隐藏出牌或发牌
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nCurrentSeat)
    if nLocalSeat == 1 then
        -- 移除手上牌
        local tRemoveCard = {msg.nCardData, msg.nCardData}
        self.GameHandCardManager:removeMoreCard(tRemoveCard)
    end

    -- 碰
    local tWeave =
    {
        nWeaveKind = G_GameDefine.ACK_PENG,
        nCenterCard = msg.nCardData,
        tCardData = {msg.nCardData, msg.nCardData, msg.nCardData}
    }
    self.GameWeaveCardManager[nLocalSeat]:addCardInfo(tWeave)
end

-- 游戏结束
function M:handleGameEndAck(msg)
    -- 发牌,出牌信息
    self.Sprite_CardBG:setVisible(false)
    self.Sprite_Card:setVisible(false)

    -- 隐藏操作
    self.Node_Operate:setVisible(false)

    -- 隐藏闹钟
    self:showOutTime(-1, false)

    for i = 1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        -- 显示分数
        self:setScore(nLocalSeat, msg.tTotalScore[i])
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
    for i = 1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            -- 隐藏头像相关
            self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setVisible(false)
            -- 隐藏准备
            self.tSpriteReady[nLocalSeat]:setVisible(false)
            -- 隐藏庄
            self.tSpriteBanker[nLocalSeat]:setVisible(false)
        else
             -- 显示头像相关
            self.tHeadInfo[nLocalSeat].ImageView_HeadBG:setVisible(true)
            -- 显示玩家信息
            self:showUserInfo(nLocalSeat)
            -- 显示分数
            self:setScore(nLocalSeat, _player.score)
        end
    end

    self.Button_LuYin:setVisible(false)
	self.Button_Chat:setVisible(false)
	self.Button_YaoQing:setVisible(false)
    self:SetReadyBtn(false, false)
    self.Sprite_ReplayBG:setVisible(true)

    self.Text_Ju_V:setString("第"..msg.head.count.."/"..G_GameDefine.nTotalGameCount.."局")
    self.Text_Fang_V:setString(msg.head.room_id)

	for i=1, G_GameDefine.nPlayerCount do
        local nLocalSeat = G_GamePlayer:getLocalSeat(i)
        --  隐藏准备图片
		self:setReady(nLocalSeat, false)
	end
	
	local nLocalSeat = G_GamePlayer:getLocalSeat(msg.game.prepare_data.nCurrentSeat)
    -- 设置庄家
	self:setBankerBySeat(nLocalSeat)
    -- 显示时间
    self:showOutTime(nLocalSeat, true)

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

-- 操作吃
function M:Click_OperateChi()
    G_CommonFunc:addClickSound()
    local tCardData = {}
    for i = 1, G_GameDefine.MAX_CARD do
        tCardData[i] = 0
    end
    for _, tCardInfo in ipairs(self.GameHandCardManager.tCardInfo) do
        for _, tInfo in ipairs(tCardInfo) do
            local nCardData = tInfo.nCardData
            tCardData[nCardData] = tCardData[nCardData] + 1
        end
    end
    self.GameChiCardManager:initCard(tCardData, self.nOperateCardData)
end

-- 操作吃
function M:OperateChi(nChiKind)
    G_CommonFunc:addClickSound()
    self.Node_Operate:setVisible(false)
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nxphz.GAME_OperateCardReq", {nOperate = G_GameDefine.ACK_CHI, nChiKind = nChiKind})
end

-- 操作碰
function M:Click_OperatePeng()
    G_CommonFunc:addClickSound()
    self.Node_Operate:setVisible(false)
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nxphz.GAME_OperateCardReq", {nOperate = G_GameDefine.ACK_PENG, nChiKind = 0})
end

-- 操作胡
function M:Click_OperateHu()
    G_CommonFunc:addClickSound()
    self.Node_Operate:setVisible(false)
	G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nxphz.GAME_OperateCardReq", {nOperate = G_GameDefine.ACK_CHIHU, nChiKind = 0})
end

-- 操作过
function M:Click_OperatePass()
    G_CommonFunc:addClickSound()
    self.Node_Operate:setVisible(false)
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nxphz.GAME_OperateCardReq", {nOperate = G_GameDefine.ACK_NULL, nChiKind = 0})

    -- 清除选择牌
    self.GameChiCardManager:clearChooseCard()
end

return M
