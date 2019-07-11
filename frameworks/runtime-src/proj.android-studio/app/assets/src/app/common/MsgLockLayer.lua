
local scheduler = cc.Director:getInstance():getScheduler()

local MsgLockLayer = class("MsgLockLayer",function()

	return display.newLayer()
end)

function MsgLockLayer:ctor()

	self:enableNodeEvents()
	self:initTouch()
	self:initData()
end

function MsgLockLayer:initTouch()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener,TOUCHPRIORITY_ALL)
end

function MsgLockLayer:initData( )
	self.schedule_warn = scheduler:scheduleScriptFunc(handler(self,self.showNetWaiting),TIME_NET_SHOWARN,false)
end

function MsgLockLayer:initView()

end

function MsgLockLayer:onEnter()

end

function MsgLockLayer:onExit()

	if self.schedule_warn then
		scheduler:unscheduleScriptEntry(self.schedule_warn)
	end

	cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
end

function MsgLockLayer:showNetWaiting()

	if self.schedule_warn then
		scheduler:unscheduleScriptEntry(self.schedule_warn)
		self.schedule_warn = nil
	end
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,80))
	self:addChild(curColorLayer)
end

function MsgLockLayer:onTouchBegin(touch,event)
	return true
end

function MsgLockLayer:onTouchMove()
	
end

function MsgLockLayer:onTouchEnded()
	
end

return MsgLockLayer
