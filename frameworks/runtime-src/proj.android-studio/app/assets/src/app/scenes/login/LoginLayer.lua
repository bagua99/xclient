--登录界面 游客 普通 两种
local LoginLayer = class("LoginLayer", G_BaseLayer)
LoginLayer.RESOURCE_FILENAME = "LoginLayer.csb"

-- 创建
function LoginLayer:onCreate()
    self.AccountLoginBtn = self.resourceNode_.node["AccountLoginBtn"]
    self.WeChatLoginBtn = self.resourceNode_.node["WeChatLoginBtn"]
    self.ScrollView_1 = self.resourceNode_.node["ScrollView_1"]
    self.CloseScrollViewBtn = self.resourceNode_.node["CloseScrollViewBtn"]
    self.LoginAgreeText = self.resourceNode_.node["LoginAgreeText"]
    self.AgreeCheckBox = self.resourceNode_.node["AgreeCheckBox"]
end

-- 初始视图
function LoginLayer:initView()
    self.AccountLoginBtn:setVisible(true)
    self.WeChatLoginBtn:setVisible(true)
	self.ScrollView_1:setVisible(false)
    self.CloseScrollViewBtn:setVisible(false)
	self.WeChatLoginBtn:setVisible(true)
	self.LoginAgreeText:setVisible(true)
    self.AgreeCheckBox:setVisible(true)
end

 -- 初始触摸
function LoginLayer:initTouch()
    self.AccountLoginBtn:addClickEventListener(handler(self,self.Click_AccountLogin))
    self.WeChatLoginBtn:addClickEventListener(handler(self,self.Click_WeChatLogin))
    self.LoginAgreeText:addClickEventListener(handler(self,self.Click_AgreeText))
    self.CloseScrollViewBtn:addClickEventListener(handler(self,self.Click_CloseScrollView))

    -- 设置同意
    self.AgreeCheckBox:setSelected(true)
end

-- 触摸开始
function LoginLayer:onTouchBegin(touch,event)
	return true
end

-- 触摸移动
function LoginLayer:onTouchMove()
	
end

-- 触摸结束
function LoginLayer:onTouchEnded(touch,event)
	if not self.ScrollView_1:isVisible() then 
		return 
	end

	if not cc.rectContainsPoint(self.ScrollView_1:getBoundingBox(),touch:getLocation()) then
		self.ScrollView_1:setVisible(false)
	end
end

-- 进入场景
function LoginLayer:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

-- 退出场景
function LoginLayer:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

-- 直接登录
function LoginLayer:LoginBtn()
	G_Event:dispatchEvent({name="requestLogin"})
end

-- 帐号登录(游客登陆)
function LoginLayer:Click_AccountLogin()
    if not self.AgreeCheckBox:isSelected() then
        local curLayer = G_WarnLayer.create()
        curLayer:setTips("需要同意用户协议,才可进行游戏")
        curLayer:setTypes(1)
        self:addChild(curLayer)
        return
    end

	dump("8888888888888888888888")
	ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡牛牛，来战啊！", "Icon-120.png", "http://www.abletele.com/xiaoyou/index.html")
	--[[
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        self:LoginBtn()
    else
        local strOpenid = cc.UserDefault:getInstance():getStringForKey("openid","")
        if string.len(strOpenid) == 0 then
            ef.extensFunction:getInstance():wxlogin()
        else
            G_Event:dispatchEvent({name="requestLink"})
        end
    end
	--]]
end

-- 微信登录
function LoginLayer:Click_WeChatLogin()
    if not self.AgreeCheckBox:isSelected() then
        local curLayer = G_WarnLayer.create()
        curLayer:setTips("需要同意用户协议,才可进行游戏")
        curLayer:setTypes(1)
        self:addChild(curLayer)
        return
    end

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        self:LoginBtn()
    else
        local strOpenid = cc.UserDefault:getInstance():getStringForKey("openid","")
        if string.len(strOpenid) == 0 then
            ef.extensFunction:getInstance():wxlogin()
        else
            G_Event:dispatchEvent({name="requestLink"})
        end
    end
end

-- 关闭同意按钮
function LoginLayer:Click_CloseScrollView()

    self.ScrollView_1:setVisible(false)
    self.CloseScrollViewBtn:setVisible(false)
end

-- 同意文字
function LoginLayer:Click_AgreeText()
	self.ScrollView_1:setVisible(true)
    self.CloseScrollViewBtn:setVisible(true)
end

return LoginLayer
