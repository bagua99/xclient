
local WarnLayer = class("WarnLayer",function()
	return display.newLayer()
end)

function WarnLayer:ctor()

	self:enableNodeEvents()
	self:initTouch()
	self:initView()

	self.m_touchOk = nil
	self.m_touchCancle = nil
end

function WarnLayer:initTouch()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function WarnLayer:initData()
	
end

function WarnLayer:initView()

	local curColorLayer = display.newLayer(cc.c4b(0,0,0,80))
	self:addChild(curColorLayer)

	local BgSprite = cc.Sprite:create("TiShi/TS_BJ.png")
	BgSprite:setPosition(display.width/2, display.height/2)
	self:addChild(BgSprite)

    local TishiSprite = cc.Sprite:create("TiShi/TS_TT.png")
	TishiSprite:setPosition(display.width/2, display.height/2 + 130)
	self:addChild(TishiSprite)

	self.btnOk = ccui.Button:create("TiShi/TS_AN_03.png", "TiShi/TS_AN_04.png")
	self.btnOk:setName("确定")
	self.btnOk:addClickEventListener(handler(self,self.btn_doOk))
	self.btnOk:setPosition(display.width/2 - 130, display.height/2 - 90)
	self:addChild(self.btnOk)

	self.btnCancle = ccui.Button:create("TiShi/TS_AN_05.png", "TiShi/TS_AN_06.png")
	self.btnOk:setName("取消")
	self.btnCancle:addClickEventListener(handler(self,self.btn_doCancle))
	self.btnCancle:setPosition(display.width/2 + 130, display.height/2 - 90)
	self:addChild(self.btnCancle)
	
	self.labelStr = cc.Label:createWithSystemFont("","Arial",30)
	self.labelStr:setDimensions(400,140)
	self.labelStr:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.labelStr:setColor(cc.c3b(149, 90, 43))
	self.labelStr:setPosition(display.width/2, display.height/2 - 20)
	self:addChild(self.labelStr)
end

function WarnLayer:setOkCallback(p_handler)

	self.m_touchOk = p_handler
end
function WarnLayer:setCancleCallback(p_handler)

	self.m_touchCancle = p_handler
end
function WarnLayer:setTips(strInfo)

	self.labelStr:setString(strInfo)
end

function WarnLayer:setTypes(iType)

	if iType == 1 then
		self.btnOk:setPositionX(display.width/2)
		self.btnCancle:setVisible(false)
	end
end

function WarnLayer:btn_doOk()

	if self.m_touchOk then
		self.m_touchOk()
	end
	self:removeFromParent()
end

function WarnLayer:btn_doCancle()

	if self.m_touchCancle then
		self.m_touchCancle()
	end
	self:removeFromParent()
end

function WarnLayer:onEnter()

end

function WarnLayer:onExit()

	self:getEventDispatcher():removeEventListener(self.listener)
end


function WarnLayer:onTouchBegin(touch,event)

	return true
end

function WarnLayer:onTouchMove()
	
end

function WarnLayer:onTouchEnded()
	
end

return WarnLayer
