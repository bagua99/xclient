
local MailLayer = class("MailLayer", G_BaseLayer)

MailLayer.RESOURCE_FILENAME = "MailLayer.csb"

function MailLayer:onCreate()

end

function MailLayer:initView()
	
end

function MailLayer:initTouch()
	self.resourceNode_.node["Btn_close"]:addClickEventListener(handler(self,self.btn_haoyou))
end

function MailLayer:btn_haoyou()
	self:removeFromParent()
end

function MailLayer:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self) 
end

function MailLayer:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function MailLayer:onTouchBegin(touch,event)
	return true
end

function MailLayer:onTouchMove()

end

function MailLayer:onTouchEnded(touch,event)

end

return MailLayer
