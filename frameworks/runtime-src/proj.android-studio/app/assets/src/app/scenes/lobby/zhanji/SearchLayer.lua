
local SearchLayer = class("SearchLayer",G_BaseLayer)

-- 创建
function SearchLayer:onCreate()

end

-- 初始化视图
function SearchLayer:initView()

	local curSprite = cc.Sprite:create("Share/share_frame.png")
	curSprite:setPosition(cc.p(display.width / 2,display.height / 2))
	self:addChild(curSprite)

	self.Confirm = ccui.Button:create("Common/btn_green.png", "Common/btn_green01.png")
	self.Confirm:setTitleText("确定")
	self.Confirm:setTitleFontSize(30)
	self.Confirm:addClickEventListener(handler(self, self.Click_Confirm))
	self.Confirm:setPosition(display.width/2 - 130,display.height / 2 - 90)
    self.Confirm:setTouchEnabled(true)
	self:addChild(self.Confirm)

	self.Cancle = ccui.Button:create("Common/btn_yellow.png", "Common/btn_yellow01.png")
	self.Cancle:setTitleText("取消")
	self.Cancle:setTitleFontSize(30)
	self.Cancle:addClickEventListener(handler(self, self.Click_Cancle))
	self.Cancle:setPosition(display.width/2 + 130,display.height / 2 - 90)
    self.Cancle:setTouchEnabled(true)
	self:addChild(self.Cancle)

	local Title = ccui.Text:create("查看好友回放","Arial",30)
	Title:setPosition(cc.p(display.width / 2, 420))
	Title:setColor(cc.c3b(149,95,80))
	self:addChild(Title)

	self.curEdit = ccui.EditBox:create(cc.size(curSprite:getBoundingBox().width / 2,45), "")
	self.curEdit:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
	self.curEdit:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	self.curEdit:setPosition(display.width / 2,display.height / 2)
	self.curEdit:setColor(cc.c3b(149,95,80))
	self.curEdit:setMaxLength(24)
	self:addChild(self.curEdit)
	self.curEdit:registerScriptEditBoxHandler(handler(self, self.EditTouch))
end

-- 初始化触摸
function SearchLayer:initTouch()
end

-- 进入场景
function SearchLayer:onEnter()
end

-- 退出场景
function SearchLayer:onExit()
end

-- 点击确定
function SearchLayer:Click_Confirm()
end

-- 点击取消
function SearchLayer:Click_Cancle()
	self:removeFromParent()
end

-- 点击输入框
function SearchLayer:EditTouch(eventName, sender)

end

return SearchLayer
