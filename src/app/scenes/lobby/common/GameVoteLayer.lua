
local M = class("GameVoteLayer",G_BaseLayer)

M.RESOURCE_FILENAME = "Component/GameVoteLayer.csb"

local scheduler =  cc.Director:getInstance():getScheduler()

-- 创建
function M:onCreate()
    self.ConfirmBtn         = self.resourceNode_.node["PanelMain"].node["ConfirmBtn"]
    self.CancelBtn          = self.resourceNode_.node["PanelMain"].node["CancelBtn"]
    self.ContentText        = self.resourceNode_.node["PanelMain"].node["ContentText"]
    self.ClockNum           = self.resourceNode_.node["PanelMain"].node["ClockBg"].node["ClockNum"]

    self.nClockTime = 299
end

-- 初始化视图
function M:initView()
    self.ConfirmBtn:setVisible(true)
    self.CancelBtn:setVisible(true)
    self.ContentText:setVisible(true)
    self.ClockNum:setVisible(true)
end

-- 初始化触摸
function M:initTouch()
	self.ConfirmBtn:addClickEventListener(handler(self, self.Click_Confirm))
	self.CancelBtn:addClickEventListener(handler(self, self.Click_Cancel))
end

-- 进入场景
function M:onEnter()

end

-- 退出场景
function M:onExit()
	if self.schedule_update ~= nil then
		scheduler:unscheduleScriptEntry(self.schedule_update)
		self.schedule_update = nil
    end

    self:setVisible(false)
end

-- 设置确定按钮事件
function M:setConfirmCallback(handler)
	self.Confirm = handler
end

-- 设置取消按钮事件
function M:setCancelCallback(handler)
	self.Cancel = handler
end

-- 设置时间结束事件
function M:setEndTimeCallback(handler)
	self.EndTime = handler
end

-- 点击确定
function M:Click_Confirm()
    G_CommonFunc:addClickSound()
    if self.Confirm ~= nil then
        self.Confirm()
    end
    self.Confirm = nil

    self:onExit()
end

-- 点击取消
function M:Click_Cancel()
    G_CommonFunc:addClickSound()
    if self.Cancel ~= nil then
        self.Cancel()
    end
    self.Cancel = nil

    self:onExit()
end

-- 设置时间结束事件
function M:setEndTimeCallback(handler)
	self.EndTime = handler
end

-- 更新闹钟时间
function M:updateClockNum()
	self.nClockTime = self.nClockTime - 1
	if self.nClockTime < 0 then
        if self.EndTime ~= nil then
            self.EndTime()
        end
        self.EndTime = nil

        if self.schedule_update ~= nil then
		    scheduler:unscheduleScriptEntry(self.schedule_update)
		    self.schedule_update = nil
        end

		self:setVisible(false)
	end
	self.ClockNum:setString(self.nClockTime)
end

-- 设置时间
function M:setClockTime(nClockTime)
	self.nClockTime = nClockTime
    self.ClockNum:setString(self.nClockTime)

    if self.schedule_update ~= nil then
		scheduler:unscheduleScriptEntry(self.schedule_update)
		self.schedule_update = nil
    end
    self.schedule_update = scheduler:scheduleScriptFunc(handler(self, self.updateClockNum), 1, false)
end

-- 设置文字
function M:setContentText(strInfo)
	self.ContentText:setString(strInfo)
end

return M
