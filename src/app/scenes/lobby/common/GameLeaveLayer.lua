
local M = class("GameLeaveLayer", G_BaseLayer)

M.RESOURCE_FILENAME = "Component/GameLeaveLayer.csb"

-- 创建
function M:onCreate()
	self.ConfirmBtn = self.resourceNode_.node["ConfirmBtn"]
    self.CancelBtn = self.resourceNode_.node["CancelBtn"]
    self.ContentText = self.resourceNode_.node["ContentText"]
end

-- 初始视图
function M:initView()

end

-- 初始触摸
function M:initTouch()
	self.ConfirmBtn:addClickEventListener(handler(self, self.Click_Confirm))
	self.CancelBtn:addClickEventListener(handler(self, self.Click_Cancel))
end

-- 进入场景
function M:onEnter()
	
end

-- 退出场景
function M:onExit()

end

-- 确定按键事件
function M:setConfirmCallback(handler)
	self.Confirm = handler
end

-- 取消按键事件
function M:setCancelCallback(handler)
	self.Cancel = handler
end

-- 点击确定
function M:Click_Confirm()
    G_CommonFunc:addClickSound()
    if self.Confirm ~= nil then
        self.Confirm()
    end
    self.Confirm = nil

    self:setVisible(false)
end

-- 点击取消
function M:Click_Cancel()
    G_CommonFunc:addClickSound()
    if self.Cancel ~= nil then
        self.Cancel()
    end
    self.Cancel = nil

	self:setVisible(false)
end

-- 设置文字
function M:setContentText(strInfo)
	self.ContentText:setString(strInfo)
end

return M
