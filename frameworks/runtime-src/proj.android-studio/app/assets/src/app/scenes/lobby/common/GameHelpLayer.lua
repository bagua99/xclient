
local GameHelpLayer = class("GameHelpLayer",G_BaseLayer)

GameHelpLayer.RESOURCE_FILENAME = "GameHelpLayer.csb"

function GameHelpLayer:onCreate()

end

function GameHelpLayer:initView()
	
end
function GameHelpLayer:initTouch()
	self.resourceNode_.node["Btn_close"]:addClickEventListener(handler(self,self.btn_haoyou))
end

function GameHelpLayer:btn_haoyou()
	self:removeFromParent()
end

function GameHelpLayer:onEnter()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self) 
end

function GameHelpLayer:onExit()

	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameHelpLayer:onTouchBegin(touch,event)
	return true
end

function GameHelpLayer:onTouchMove()
end

function GameHelpLayer:onTouchEnded(touch,event)

end

return GameHelpLayer
