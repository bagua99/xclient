
local ShareLayer = class("ShareLayer", G_BaseLayer)

ShareLayer.RESOURCE_FILENAME = "ShareLayer.csb"

function ShareLayer:onCreate()

end

function ShareLayer:initView()
	
end
function ShareLayer:initTouch()
	self.resourceNode_.node["Button_1"]:addClickEventListener(handler(self,self.btn_haoyou))
	self.resourceNode_.node["Button_2"]:addClickEventListener(handler(self,self.btn_pengyouquan))
end

function ShareLayer:btn_haoyou()
	ef.extensFunction:getInstance():wxInviteFriend(0, "好友@你", "小友杭麻，来战啊！", "Icon-120.png", "http://www.abletele.com/xiaoyou/index.html")
end

function ShareLayer:btn_pengyouquan()
	ef.extensFunction:getInstance():wxInviteFriend(1, "好友@你", "小友杭麻，来战啊！", "Icon-120.png", "http://www.abletele.com/xiaoyou/index.html")
end


function ShareLayer:onEnter()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self) 
end
function ShareLayer:onExit()

	self:getEventDispatcher():removeEventListener(self.listener)
end

function ShareLayer:onTouchBegin(touch,event)


	return true
end

function ShareLayer:onTouchMove()
end

function ShareLayer:onTouchEnded(touch,event)
	if not cc.rectContainsPoint(self.resourceNode_.node["share_frame_1"]:getBoundingBox(),touch:getLocation()) then
		self:removeFromParent()
	end
end



return ShareLayer
