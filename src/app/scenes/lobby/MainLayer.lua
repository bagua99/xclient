
local M = class("MainLayer",G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/GameScene/MainLayer.csb"

local cjson 			= require("componentex.cjson")
local GameSetLayer      = require("app.scenes.lobby.GameSet.GameSetLayer")
local GameHelpLayer     = require("app.scenes.lobby.GameHelp.GameHelpLayer")
local MailLayer         = require("app.scenes.lobby.Mai.MailLayer")
local ShareLayer        = require("app.scenes.lobby.Share.ShareLayer")
local ZhanJiLayer       = require("app.scenes.lobby.zhanji.ZhanJiLayer")
local CreateRoomLayer   = require("app.scenes.lobby.CreateRoom.CreateRoomLayer")
local JoinRoomLayer     = require("app.scenes.lobby.JoinRoom.JoinRoomLayer")
local FeedBackLayer     = require("app.scenes.lobby.FeedBack.FeedBackLayer")
local ActivityLayer     = require("app.scenes.lobby.Activity.ActivityLayer")
local LotteryLayer      = require("app.scenes.lobby.Lottery.LotteryLayer")
local NationProxyLayer  = require("app.scenes.lobby.National_profit.NationProxyLayer")
local ApplyBeProxyLayer = require("app.scenes.lobby.National_profit.ApplyBeProxyLayer")
local ProfitInfoLayer   = require("app.scenes.lobby.National_profit.ProfitInfoLayer")
local BeProxyLayer      = require("app.scenes.lobby.National_profit.BeProxyLayer")

local SPLayer           = require("app.scenes.lobby.common.SPLayer")
local EventConfig       = require ("app.config.EventConfig")
local GameConfig        = require "app.config.GameConfig"

local targetPlatform    = cc.Application:getInstance():getTargetPlatform()

local scheduler         = cc.Director:getInstance():getScheduler()

-- 创建
function M:onCreate()
    self.CreateRoomBtn1  = self.resourceNode_.node["DiguoziBtn"]
    self.CreateRoomBtn2  = self.resourceNode_.node["PaodekuaiBtn"]
    -- 加入房间
    self.JoinRoomBtn    = self.resourceNode_.node["JoinBtn"]
    -- 购买房卡
	self.BuyBtn         = self.resourceNode_.node["BuyBtn"]

    -- 战绩回顾
    self.LookBackBtn    = self.resourceNode_.node["BgImage"].node["LookBackBtn"]
    -- 好友分享
    self.ShareBtn       = self.resourceNode_.node["BgImage"].node["ShareBtn"]
    -- 问题回顾
    self.FeedbackBtn    = self.resourceNode_.node["BgImage"].node["FeedbackBtn"]

    -- 头像图片
    self.HeadSprite     = self.resourceNode_.node["LogoCenter"].node["HeadSpriteBg"].node["IMG_HEAD"]
    -- 玩家名字
    self.UserNameText   = self.resourceNode_.node["LogoCenter"].node["UserNameText"]
    -- 玩家ID
    self.UserIDText     = self.resourceNode_.node["LogoCenter"].node["UserIDText"]
    -- 房卡数量
    self.RoomCardText   = self.resourceNode_.node["LogoCenter"].node["RoomCardBg"].node["RoomCardText"]
    -- 房卡背景
    self.RoomCardBg   = self.resourceNode_.node["LogoCenter"].node["RoomCardBg"]
    -- 购买房卡
    self.RoomCardBuyBtn = self.resourceNode_.node["LogoCenter"].node["RoomCardBuyBtn"]
    -- 消息
    self.MailBtn        = self.resourceNode_.node["LogoCenter"].node["MailBtn"]
    -- 帮助
    self.HelpBtn        = self.resourceNode_.node["BgImage"].node["HelpBtn"]
    -- 游戏设置
    self.GameSetBtn     = self.resourceNode_.node["LogoCenter"].node["GameSetBtn"]
    --幸运抽奖
    self.BTN_ACTIVITY   = self.resourceNode_.node["BTN_ACTIVITY"]
    self.GongGaoText    = self.resourceNode_.node["GongGaoText"]
    --全民赚钱
    self.BTN_NATIONAL_ACTIVITY = self.resourceNode_.node["BTN_NATIONAL_ACTIVITY"]
    --刷新房卡接口
    self.BTN_FRESHEN    = self.resourceNode_.node["home_icon_card"]
    self.BTN_FRESHEN:addClickEventListener(handler(self, self.Click_FreshenCards))
end

-- 初始视图
function M:initView()
    self.CreateRoomBtn1:setVisible(true)
    self.CreateRoomBtn2:setVisible(true)
    self.JoinRoomBtn:setVisible(true)
    self.BuyBtn:setVisible(true)

    self.ShareBtn:setVisible(true)
    self.LookBackBtn:setVisible(true)
    self.FeedbackBtn:setVisible(true)

	self.UserNameText:setString(G_Data.UserBaseInfo.nickname)
    self.UserNameText:setVisible(true)
    
    if G_Data.UserBaseInfo.userid~=nil then 
        self.UserIDText:setString(string.format("账号:%06d", G_Data.UserBaseInfo.userid or ""))
    end 
    self.UserIDText:setVisible(true)
	self.RoomCardText:setString(G_Data.UserBaseInfo.roomcard)

    self.RoomCardBuyBtn:setVisible(true)
    self.MailBtn:setVisible(true)
    self.HelpBtn:setVisible(true)
    self.GameSetBtn:setVisible(true)

    if cc.PLATFORM_OS_WINDOWS ~= targetPlatform then
        G_CommonFunc:addKeyReleased(self)
    end 
    
    if EventConfig.CHECK_IOS then 
        self.RoomCardBg:setVisible(false)
        self.BuyBtn:setVisible(false)
        self.RoomCardBuyBtn:setVisible(false)
        self.BTN_ACTIVITY:setVisible(false)
        self.JoinRoomBtn:setPositionY(display.cy)
        self.resourceNode_.node["home_icon_card"]:setVisible(false)
        self.ShareBtn:setVisible(false)
        self.resourceNode_.node["Line3"]:setVisible(false)        
        self.FeedbackBtn:setPositionX(display.cx+40)
    end

    if EventConfig.CHECK_IOS then 
        self.BTN_NATIONAL_ACTIVITY:setVisible(false)
        self.BTN_ACTIVITY:setPositionX(self.BTN_ACTIVITY:getPositionX()+35)
        self.BuyBtn:setPositionX(self.BuyBtn:getPositionX()+35)
        self.JoinRoomBtn:setPositionX(self.JoinRoomBtn:getPositionX()+35)
    end

    self:lamp(G_Data.GonggaoNotice,500,380,527)
    if not EventConfig.CHECK_IOS then
        self:beProxyPlayer()
    end
    self.BTN_NATIONAL_ACTIVITY:setVisible(false)

    --是返回记录返回的
    if G_Data.recordType then
        if self.ZhanJiLayer == nil then
            self.ZhanJiLayer = ZhanJiLayer.create()
            self:addChild(self.ZhanJiLayer)
            self.ZhanJiLayer:setGameChoose(G_Data.recordType,true)
            self:runAction(cc.Sequence:create(move1,cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                self.ZhanJiLayer:requestGame(G_Data.recordType)
            end)))
            self.ZhanJiLayer:addCloseListener(function()
                self.ZhanJiLayer:removeFromParent()
                self.ZhanJiLayer = nil 
            end)
        end
    end
end

function M:lamp(str, length, posx, posy)
    local braodWidth = length
    local ttfConfig = {}
    ttfConfig.fontFilePath="res/commonfont/ZYUANSJ.TTF"
    ttfConfig.fontSize = 20
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 0
    local s = cc.Director:getInstance():getWinSize()
    local label = cc.Label:createWithTTF(ttfConfig,str,cc.TEXT_ALIGNMENT_CENTER,s.width)
    label:setAnchorPoint(cc.p(0.0, 0.0))
    label:setPosition(cc.p(0, 0)) 
    label:setTextColor(cc.c4b(255,255,255,255))

    local labelWidth = label:getContentSize().width 
    local scrollViewLayer = cc.Layer:create():setPosition(cc.p(0,0)) 
    scrollViewLayer:setContentSize(label:getContentSize()) 
    local scrollView1 = cc.ScrollView:create() 
    if nil ~= scrollView1 then 
        scrollView1:setViewSize(cc.size(braodWidth, 100)) 
        scrollView1:setPosition(cc.p(posx,posy)) 
        scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_NONE ) 
        scrollView1:setClippingToBounds(true) 
        scrollView1:setBounceable(true)
        scrollView1:setTouchEnabled(false) 
    end 
    scrollView1:addChild(label) 
    self:addChild(scrollView1) 
    if nil ~= scrollViewLayer_ then 
        scrollView1:setContainer(scrollViewLayer) 
        scrollView1:updateInset() 
    end
    local x = label:getPositionX()
    local func = nil 
    local funcNext = nil 
    funcNext = function()
        local x = label:getPositionX()
        if x <= -labelWidth then 
            label:setPositionX(length)
            x = label:getPositionX()
            local time = (length+labelWidth)/labelWidth
            func(x,time*10)
        end 
    end
    local callfunc = cc.CallFunc:create(funcNext)
    func = function(x, time)
        if x > -labelWidth  then
            local rightAction = cc.MoveTo:create(time,cc.p(-labelWidth,0)) 
            local seqAction = cc.Sequence:create(rightAction,callfunc) 
            label:runAction(seqAction)
        end 
    end
    func(x,10)
end

function M:_onInterval(dt)
    -- body
    local w = self.lab_text:getContentSize().width  
    local x = self.lab_text:getPositionX()  
    if x <= -w then  
        scheduler:unscheduleScriptEntry(self.handleScrollText)  
    return  
    end  
    self.lab_text:setPositionX(x - 10)  
end

 -- 初始触摸
function M:initTouch()
    -- 创建房间
    self.CreateRoomBtn1.call = handler(self,self.Click_CreateRoom1)
    G_UIEvent:add(self.CreateRoomBtn1,"MainLayer")

    self.CreateRoomBtn2.call = handler(self,self.Click_CreateRoom2)
    G_UIEvent:add(self.CreateRoomBtn2,"MainLayer")

    -- 加入房间
    self.JoinRoomBtn.call = handler(self,self.Click_JoinRoom)
    G_UIEvent:add(self.JoinRoomBtn,"MainLayer")

    -- 购买房卡
    self.BuyBtn.call = handler(self,self.Click_Buy)
    G_UIEvent:add(self.BuyBtn,"MainLayer")

    -- 战绩回顾
    self.LookBackBtn.call = handler(self,self.Click_LookBack)
    G_UIEvent:add(self.LookBackBtn,"MainLayer")

    -- 好友分享
    self.ShareBtn.call = handler(self,self.Click_Share)
    G_UIEvent:add(self.ShareBtn,"MainLayer")

    -- 问题回顾
    self.FeedbackBtn.call = handler(self,self.Click_Feedback)
    G_UIEvent:add(self.FeedbackBtn,"MainLayer")
	
    -- 购买房卡
	self.RoomCardBuyBtn.call = handler(self,self.Click_Buy)
    G_UIEvent:add(self.RoomCardBuyBtn,"MainLayer")

    -- 消息
    self.MailBtn.call = handler(self,self.Click_Mail)
    G_UIEvent:add(self.MailBtn,"MainLayer")

	-- 帮助
	self.HelpBtn.call = handler(self,self.Click_Help)
    G_UIEvent:add(self.HelpBtn,"MainLayer")

    -- 游戏设置
    self.GameSetBtn.call = handler(self,self.Click_GameSet)
    G_UIEvent:add(self.GameSetBtn,"MainLayer")

    --用户赚钱
    self.BTN_NATIONAL_ACTIVITY.call = handler(self,self.Click_NATIONAL_ACTIVITY)
    G_UIEvent:add(self.BTN_NATIONAL_ACTIVITY,"MainLayer")  

    --幸运抽奖
    self.BTN_ACTIVITY.call = handler(self,self.Click_Choujiang)
    G_UIEvent:add(self.BTN_ACTIVITY,"MainLayer")
end

-- 进入场景
function M:onEnter()
    -- 先显示头像
    if G_Data.UserBaseInfo.userid~=nil then 
        local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead"..G_Data.UserBaseInfo.userid..".png"
        local msg = {saveName = saveName}
        if cc.FileUtils:getInstance():isFileExist(saveName) then
            self:getUserHead(msg, true)
        end
        -- 请求头像(微新未设置图片为"\0")
        local url = G_Data.UserBaseInfo.headimgurl
        if url and  string.len(url) > 1 then
            G_CommonFunc:httpForImg(url, saveName, handler(self, self.getUserHead), msg)
        end
    end
    self.target, self.event_handlermsg = G_Event:addEventListener("receiveLobbyMsg", handler(self, self.handleMsg))
    self.target, self.event_UserBaseInfo = G_Event:addEventListener("Update_UserBaseInfo", handler(self, self.UserBaseInfo))
    --添加修改房卡数据消息
    self.target, self.event_UpdateCardForRoom = G_Event:addEventListener("UpdateCardForRoom", handler(self, self.UpdateCardForRoom))
    self.target, self.event_UpdateCardForLottery = G_Event:addEventListener("UpdateCardForLottery", handler(self, self.UpdateCardForLottery))
end

-- 退出场景
function M:onExit()
    G_Event:removeEventListener(self.event_handlermsg)
    G_Event:removeEventListener(self.event_UserBaseInfo)
    G_Event:removeEventListener(self.event_UpdateCardForRoom)
    G_Event:removeEventListener(self.event_UpdateCardForLottery)
    G_UIEvent:del("MainLayer")
end

-- 创建房间
function M:Click_CreateRoom1()
    G_CommonFunc:addClickSound()
    self.CreateRoomLayer = CreateRoomLayer.new(3)
    self:addChild(self.CreateRoomLayer)
end

-- 创建房间
function M:Click_CreateRoom2()
    G_CommonFunc:addClickSound()
    self.CreateRoomLayer = CreateRoomLayer.new(1)
    self:addChild(self.CreateRoomLayer)
end

-- 加入房间
function M:Click_JoinRoom()
    G_CommonFunc:addClickSound()
	if G_Data.roomid and G_Data.roomid ~= 0 then
        local msg =
        {
			roomid = tonumber(G_Data.roomid),
			userid = G_Data.UserBaseInfo.userid,
            sign = G_Data.UserBaseInfo.sign,
            account = G_Data.UserBaseInfo.account,
            nickname = G_Data.UserBaseInfo.nickname,
            headimgurl = G_Data.UserBaseInfo.headimgurl,
            sex = G_Data.UserBaseInfo.sex,
		}
		G_Event:dispatchEvent({name="sendMsg_JoinRoom", msg = msg})
		return
	end

    if self.JoinRoomLayer == nil then
	    self.JoinRoomLayer = JoinRoomLayer:create()
	    self:addChild(self.JoinRoomLayer)
        self.JoinRoomLayer:addCloseListener(function()
            self.JoinRoomLayer:removeFromParent()
            self.JoinRoomLayer = nil 
        end)
    end
end

-- 购买房卡
function M:Click_Buy()
    G_CommonFunc:addClickSound()
    local curLayer = SPLayer.new()
    self:addChild(curLayer)
end

-- 战绩回顾
function M:Click_LookBack()
    G_CommonFunc:addClickSound()
    if self.ZhanJiLayer == nil then
        self.ZhanJiLayer = ZhanJiLayer.create()
	    self:addChild(self.ZhanJiLayer)
        self.ZhanJiLayer:addCloseListener(function()
            self.ZhanJiLayer:removeFromParent()
            self.ZhanJiLayer = nil 
        end)
    end
end

-- 好友分享
function M:Click_Share()
    G_CommonFunc:addClickSound()
    if self.ShareLayer == nil then
        self.ShareLayer = ShareLayer.create()
	    self:addChild(self.ShareLayer)
        self.ShareLayer:addCloseListener(function()
            self.ShareLayer:removeFromParent()
            self.ShareLayer = nil 
        end)
    end
end

-- 问题反馈
function M:Click_Feedback()
    G_CommonFunc:addClickSound()
    if self.FeedBackLayer == nil then
        self.FeedBackLayer = FeedBackLayer.create()
	    self:addChild(self.FeedBackLayer)
        self.FeedBackLayer:addCloseListener(function()
            self.FeedBackLayer:removeFromParent()
            self.FeedBackLayer = nil 
        end)
    end
end

-- 更多游戏
function M:Click_MoreGame()

end

-- 消息
function M:Click_Mail()
    G_CommonFunc:addClickSound()
    if self.MailLayer == nil then
        self.MailLayer = MailLayer.create()
	    self:addChild(self.MailLayer)
        self.MailLayer:addCloseListener(function()
            self.MailLayer:removeFromParent()
            self.MailLayer = nil 
        end)
    end
end

-- 帮助
function M:Click_Help()
    G_CommonFunc:addClickSound()
    if self.GameHelpLayer == nil then
        self.GameHelpLayer = GameHelpLayer.create()
	    self:addChild(self.GameHelpLayer)
        self.GameHelpLayer:addCloseListener(function()
            self.GameHelpLayer:removeFromParent()
            self.GameHelpLayer = nil 
        end)
    end
    
end

-- 游戏设置
function M:Click_GameSet()
    G_CommonFunc:addClickSound()
    if self.GameSetLayer == nil then
        self.GameSetLayer = GameSetLayer.create()
	    self:addChild(self.GameSetLayer)
        self.GameSetLayer:addCloseListener(function()
            self.GameSetLayer:removeFromParent()
            self.GameSetLayer = nil 
        end)
    end
end

-- 玩家头像
function M:getUserHead(msg, bSuccess)
    if not bSuccess then
        return
    end
    local nHeadSize = 49.5
    local saveName = msg.saveName
	self.HeadSprite:loadTexture(saveName)
    local width = self.HeadSprite:getContentSize().width
    local height = self.HeadSprite:getContentSize().height
	self.HeadSprite:setScale(nHeadSize/width, nHeadSize/height)
end

function M:handleMsg(event)
	if event.msgName == "protocol.CL_UpdateUserDataAck" then
		table.merge(G_Data.UserBaseInfo, msg.UserBaseInfo)
	end
end

function M:UserBaseInfo(event)
    local nickname = G_Data.UserBaseInfo.nickname
    if string.len(nickname) > 12 then 
        nickname = string.sub(nickname,1,12).."..."
    end
    self.UserNameText:setString(nickname)
	self.UserIDText:setString(string.format("账号:%06d", G_Data.UserBaseInfo.userid))
	self.RoomCardText:setString(G_Data.UserBaseInfo.roomcard)
end

function M:Click_UserInfo()
    G_CommonFunc:addClickSound()
    G_CommonFunc:showUserInfo(G_Data.UserBaseInfo,self)
end

function M:Click_Choujiang()
    G_CommonFunc:addClickSound()
    local layer = ActivityLayer.new()
    self:addChild(layer)
end

function M:UpdateCardForRoom(event)
    local roomcard = event.roomcard or 0 
    local msg = event.msg
    local flag = event.flag 
    local waresid = event.waresid or 0 
    local isActivity = event.isActivity 
    if flag == true and isActivity == false then
        G_Data.UserBaseInfo.roomcard = roomcard 
        self.RoomCardText:setString(G_Data.UserBaseInfo.roomcard)
    end
    if flag == true and waresid > 4 and isActivity == true then 
        --展示抽奖活动
        local layer = LotteryLayer.new()
        self:addChild(layer)
        layer:addCloseListener(function()
            layer:removeFromParent()
        end)
    else 
        self:tips(msg)
    end 
end

-- 提示信息
function M:tips(str)
    local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

function M:UpdateCardForLottery(event)
    local roomcard = event.roomcard or 0 
    G_Data.UserBaseInfo.roomcard = roomcard 
    self.RoomCardText:setString(G_Data.UserBaseInfo.roomcard)
end

--代理收益情况查询
function M:getProfit()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:setRequestHeader("Content-Type", "application/json")
    xhr.timeout = 3
    xhr:open("POST","http://"..G_Data.strProxy..":"..GameConfig.web_port..GameConfig.profit_get_url)
    local function reqCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local content = xhr.response
            local retMsg = cjson.decode(content)
            local retcode = retMsg.retcode
            if retcode == "1" then 
                local layer = ProfitInfoLayer.new(retMsg)
                self:addChild(layer)
            else 
                dump("get faild**")
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(reqCallback)
    local msg = {
        uid = G_Data.UserBaseInfo.unionid,
        token = "52665522ef2efa3fef2e3ef" 
    }
    xhr:send(cjson.encode(msg))
end

function M:Click_NATIONAL_ACTIVITY()
    G_CommonFunc:addClickSound()
    if G_Data.isProxy then
        self:getProfit()
    else
        if G_Data.hasPostApply then 
            local layer = BeProxyLayer.new()
            self:addChild(layer)  
        else
            local layer = ApplyBeProxyLayer.new()
            self:addChild(layer)  
        end   
    end 
end

--查询是否是代理
function M:beProxyPlayer()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:setRequestHeader("Content-Type", "application/json")
    xhr.timeout = 3
    xhr:open("POST","http://"..G_Data.strProxy..":"..GameConfig.web_port..GameConfig.be_proxy_player_url)
    local function reqCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local content = xhr.response
            local retMsg = cjson.decode(content)
            local retcode = retMsg.retcode
            self.BTN_NATIONAL_ACTIVITY:setVisible(true)
            if retcode == "0" then 
                G_Data.hasPostApply = false
                G_Data.isProxy = false
                --提供外部测试的包
                if G_Data.showNationProxy== nil and EventConfig.CHECK_IOS==false  then 
                    self:runAction(cc.Sequence:create(move1,cc.DelayTime:create(0.3),cc.CallFunc:create(function()
                        local layer = NationProxyLayer.new()
                        G_Data.showNationProxy = true
                        self:addChild(layer)
                    end)))
                end
            elseif retcode == "1" then 
                G_Data.isProxy = true
                G_Data.hasPostApply = true   
            elseif retcode == "2" then 
                G_Data.hasPostApply = true
                G_Data.isProxy = false 
                if G_Data.showNationProxy== nil and EventConfig.CHECK_IOS==false  then 
                    self:runAction(cc.Sequence:create(move1,cc.DelayTime:create(0.3),cc.CallFunc:create(function()
                        local layer = NationProxyLayer.new()
                        G_Data.showNationProxy = true
                        self:addChild(layer)
                    end)))
                end
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(reqCallback)
    local msg = {
        uid = G_Data.UserBaseInfo.unionid
    }
    xhr:send(cjson.encode(msg))
end

function M:Click_FreshenCards()
    local msg = {
        userid = G_Data.UserBaseInfo.userid,
        sign = G_Data.UserBaseInfo.sign,
    }
    G_CommonFunc:httpForJsonLobby("/update_userinfo",5, msg, handler(self, self.update_userinfo))
end

function M:update_userinfo(msg)
    if msg.result == "success" then
        G_Data.UserBaseInfo.score = msg.score
        G_Data.UserBaseInfo.roomcard = msg.roomcard
        G_Event:dispatchEvent({name="Update_UserBaseInfo"})
    end
end

return M
