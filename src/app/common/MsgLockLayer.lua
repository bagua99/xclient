
local scheduler = cc.Director:getInstance():getScheduler()

local MsgLockLayer = class("MsgLockLayer",function()
	return display.newLayer()
end)

local TIME_NET_SHOWARN = 1.5  --多少时间之后显示提示框
local TOUCHPRIORITY_ALL = -999   --最低优先级，阻断一切点击

function MsgLockLayer:ctor()
	self:enableNodeEvents()
    self:initView()
	self:initTouch()
end

-- 初始视图
function MsgLockLayer:initView()

end

-- 初始触摸
function MsgLockLayer:initTouch()
    self.schedule_warn = scheduler:scheduleScriptFunc(handler(self,self.showWaiting), TIME_NET_SHOWARN, false)
end

-- 进入场景
function MsgLockLayer:onEnter()
    self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener,TOUCHPRIORITY_ALL)
end

-- 退出场景
function MsgLockLayer:onExit()
	if self.schedule_warn then
		scheduler:unscheduleScriptEntry(self.schedule_warn)
        self.schedule_warn = nil
	end
    if self.listener then
	    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end

-- 触摸开始
function MsgLockLayer:onTouchBegin(touch, event)
	return self:isVisible()
end

-- 触摸移动
function MsgLockLayer:onTouchMove(touch, event)
	
end

-- 触摸结束
function MsgLockLayer:onTouchEnded(touch, event)
	
end

-- 显示等待
function MsgLockLayer:showWaiting()
	if self.schedule_warn ~= nil then
		scheduler:unscheduleScriptEntry(self.schedule_warn)
		self.schedule_warn = nil
	end
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,90))
	self:addChild(curColorLayer)
end

return MsgLockLayer
