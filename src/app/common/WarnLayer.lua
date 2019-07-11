
local M = class("WarnLayer",function()
	return display.newLayer()
end)

function M:ctor()
	self:enableNodeEvents()
	self:initView()
    self:initTouch()

	self.touchOk = nil
	self.touchCancel = nil
end

-- 初始视图
function M:initView()
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,90))
	self:addChild(curColorLayer)

	self.curColorLayer = curColorLayer

	local BgSprite = cc.Sprite:create("Component/TiShi/TS_BJ.png")
	BgSprite:setPosition(display.width/2, display.height/2)
	self:addChild(BgSprite)
	self.BgSprite = BgSprite

	self.btnOk = ccui.Button:create("Component/TiShi/TS_AN_03.png", "Component/TiShi/TS_AN_03.png")
	self.btnOk:setName("确定")
	self.btnOk:addClickEventListener(handler(self,self.btn_doOk))
	self.btnOk:setPosition(display.width/2 - 130, display.height/2 - 90)
	self:addChild(self.btnOk)

	self.btnCancel = ccui.Button:create("Component/TiShi/TS_AN_05.png", "Component/TiShi/TS_AN_05.png")
	self.btnOk:setName("取消")
	self.btnCancel:addClickEventListener(handler(self,self.btn_doCancel))
	self.btnCancel:setPosition(display.width/2 + 130, display.height/2 - 90)
	self:addChild(self.btnCancel)
	
	self.labelStr = cc.Label:createWithSystemFont("","res/commonfont/ZYUANSJ.TTF",30)
	self.labelStr:setDimensions(400,140)
	self.labelStr:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.labelStr:setColor(cc.c3b(255,255,255))
	self.labelStr:setPosition(display.width/2, display.height/2 - 20)
	self:addChild(self.labelStr)
end

-- 初始触摸
function M:initTouch()

end

-- 进入场景
function M:onEnter()
    self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
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
	
end

-- 设置确定按钮事件
function M:setOkCallback(handler)
	self.touchOk = handler
end

-- 设置取消按钮事件
function M:setCancelCallback(handler)
	self.touchCancel = handler
end

-- 设置提示
function M:setTips(strInfo)
	self.labelStr:setString(strInfo)
end

-- 设置类型
function M:setTypes(nType)
	if nType == 1 then
		self.btnOk:setPositionX(display.width/2)
		self.btnCancel:setVisible(false)
	elseif nType == 2 then 
		self.btnOk:setVisible(false)
		self.btnCancel:setVisible(false)
		self.curColorLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1.1),cc.CallFunc:create(function()
			self:removeFromParent()
		end)))
	elseif nType==3 then 
		self.btnOk:setVisible(true)
		self.btnCancel:setVisible(true)
	end
end

-- 点击确定
function M:btn_doOk()
	G_CommonFunc:addClickSound()
	if self.touchOk then
		self.touchOk()
	else
		self:removeFromParent() 
	end
end

-- 点击取消
function M:btn_doCancel()
	G_CommonFunc:addClickSound()
	if self.touchCancel then
		self.touchCancel()
	end
	self:removeFromParent()
end

--添加其他图片
function M:addOthers(img)
	local TishiSprite = cc.Sprite:create(img)
	TishiSprite:setPosition(display.width/2, display.height/2-25)
	TishiSprite:setScale(0.43)
	self:addChild(TishiSprite)
	self.btnOk:setPositionY(self.btnOk:getPositionY()-45)
	self.labelStr:setPositionY(self.labelStr:getPositionY()+70)
	self.labelStr:setScale(0.65)
	self.btnOk:setScale(0.8)

	local labelStr = cc.Label:createWithSystemFont("","res/commonfont/ZYUANSJ.TTF",30)
	labelStr:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
	labelStr:setColor(cc.c3b(255,255,255))
	labelStr:setPosition(display.width/2+100, display.height/2-20)
	self:addChild(labelStr)
	labelStr:setString("扫\n一\n扫")
	labelStr:setScale(0.8)
end

return M
