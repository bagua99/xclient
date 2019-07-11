--登录界面 游客 普通 两种
local M = class("LoginLayer", G_BaseLayer)

M.RESOURCE_FILENAME = "Login/LoginLayer.csb"

local targetPlatform            = cc.Application:getInstance():getTargetPlatform()
local EventConfig               = require ("app.config.EventConfig")
local GameConfig                = require "app.config.GameConfig"
local cjson 					= require("componentex.cjson")

-- 创建
function M:onCreate()
    self.GuestLoginBtn = self.resourceNode_.node["GuestLoginBtn"]
    self.WeChatLoginBtn = self.resourceNode_.node["WeChatLoginBtn"]
    self.AccountLoginBtn = self.resourceNode_.node["AccountLoginBtn"]
    
    self.ScrollView_1 = self.resourceNode_.node["ScrollView_1"]
    self.CloseScrollViewBtn = self.resourceNode_.node["CloseScrollViewBtn"]
    self.LoginAgreeText = self.resourceNode_.node["LoginAgreeText"]
    self.AgreeCheckBox = self.resourceNode_.node["AgreeCheckBox"]
    self.LoginVersionText = self.resourceNode_.node["LoginVersionText"]
end

-- 初始视图
function M:initView()
    self.AccountLoginBtn:setVisible(EventConfig.GAME_TEST)
    self.WeChatLoginBtn:setVisible(true)
	self.ScrollView_1:setVisible(false)
    self.CloseScrollViewBtn:setVisible(false)
	self.WeChatLoginBtn:setVisible(true)
	self.LoginAgreeText:setVisible(true)
    self.AgreeCheckBox:setVisible(true)
    if EventConfig.GAME_VERSION then
        self.LoginVersionText:setString("版本号："..EventConfig.GAME_VERSION)
    end
    self.LoginVersionText:setVisible(true)
    if EventConfig.CHECK_IOS then 
        self.WeChatLoginBtn:setVisible(false)
        self.GuestLoginBtn:setPositionX(display.cx)
    elseif targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
        self.GuestLoginBtn:setVisible(false)
        self.WeChatLoginBtn:setPositionX(display.cx)
    end 
end

-- 初始触摸
function M:initTouch()
    self.GuestLoginBtn:addClickEventListener(handler(self,self.Click_GuestLoginBtn))
    self.WeChatLoginBtn:addClickEventListener(handler(self,self.Click_WeChatLogin))
    self.AccountLoginBtn:addClickEventListener(handler(self,self.Click_AccountLogin))
    
    self.LoginAgreeText:addClickEventListener(handler(self,self.Click_AgreeText))
    self.CloseScrollViewBtn:addClickEventListener(handler(self,self.Click_CloseScrollView))

    -- 设置同意
    self.AgreeCheckBox:setSelected(true)
end

-- 进入场景
function M:onEnter()
    self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
    self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
    if cc.PLATFORM_OS_WINDOWS ~= targetPlatform then
        G_CommonFunc:addKeyReleased(self)
    end 

    local bChange = false
    local nMusic = cc.UserDefault:getInstance():getIntegerForKey("Music", 0)
    if nMusic == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("Music", 1)
        bChange = true
    end

    local nMusic = cc.UserDefault:getInstance():getIntegerForKey("Sound", 0)
    if nMusic == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("Sound", 1)
        bChange = true
    end

    local nMusic = cc.UserDefault:getInstance():getIntegerForKey("ChatSound", 0)
    if nMusic == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("ChatSound", 1)
        bChange = true
    end

    if bChange then
        cc.UserDefault:getInstance():flush()
    end

    if cc.PLATFORM_OS_IPHONE == targetPlatform then 
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "RootViewController"
        if EventConfig.CHECK_IOS then
            luaoc.callStaticMethod(className, "initLoctionSDK", {})
        end
        luaoc.callStaticMethod(className,"initSDK",{ } ) 
    end
    self:getNotice()
end

-- 退出场景
function M:onExit()
    if self.listener then
	    self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end

-- 触摸开始
function M:onTouchBegin(touch, event)
	return self:isVisible()
end

-- 触摸移动
function M:onTouchMove(touch, event)
	
end

-- 触摸结束
function M:onTouchEnded(touch, event)
	if not self.ScrollView_1:isVisible() then 
		return 
	end

	if not cc.rectContainsPoint(self.ScrollView_1:getBoundingBox(),touch:getLocation()) then
		self.ScrollView_1:setVisible(false)
	end
end

-- 游客登陆
function M:Click_GuestLoginBtn()
    G_CommonFunc:addClickSound()
    if not self:isAgreeLogin() then
        return
    end
	G_Event:dispatchEvent({name="requestGuestLogin"})
end

-- 帐号登录
function M:Click_AccountLogin()
    G_CommonFunc:addClickSound()
    if not self:isAgreeLogin() then
        return
    end
    G_Event:dispatchEvent({name="requestAccountLogin"})
end

-- 微信登录
function M:Click_WeChatLogin()
    G_CommonFunc:addClickSound()
    if not self:isAgreeLogin() then
        return
    end

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        self:Click_GuestLoginBtn()
    else
        ef.extensFunction:getInstance():wxlogin()
    end
end

-- 是否同意登陆
function M:isAgreeLogin()
    if not self.AgreeCheckBox:isSelected() then
        local curLayer = G_WarnLayer.create()
        curLayer:setTips("需要同意用户协议,才可进行游戏")
        curLayer:setTypes(1)
        self:addChild(curLayer)
        return false
    end

    return true
end

-- 关闭同意按钮
function M:Click_CloseScrollView()
    G_CommonFunc:addClickSound()
    self.ScrollView_1:setVisible(false)
    self.CloseScrollViewBtn:setVisible(false)
end

-- 同意文字
function M:Click_AgreeText()
    G_CommonFunc:addClickSound()
	self.ScrollView_1:setVisible(true)
    self.CloseScrollViewBtn:setVisible(true)
end

function M:getNotice()
    --模拟获取游戏公告
    local GameConfig = require "app.config.GameConfig"
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:setRequestHeader("Content-Type", "application/json")
    xhr.timeout = 3
    xhr:open("GET","http://"..G_Data.strProxy..":"..GameConfig.web_port..GameConfig.get_notice_content)
    local function reqCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local content = xhr.response
            local retMsg = cjson.decode(content)
            local retmsg = retMsg.retmsg
            G_Data.GonggaoNotice = retmsg
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(reqCallback)
    xhr:send()
end

return M
