
local M = class("MailLayer", G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/Mail/MailLayer.csb"

local EventConfig       = require ("app.config.EventConfig")

-- 创建
function M:onCreate()
    self.BG         = self.resourceNode_.node["BG"]
    self.Text       = self.resourceNode_.node["Bg"].node["Text"]
    self.CloseBtn   = self.resourceNode_.node["CloseBtn"]
end

-- 初始视图
function M:initView()
	self.CloseBtn:setVisible(true)
    if EventConfig.CHECK_IOS then
        local str = [[亲爱的玩家：
           本游戏安全，便捷，稳定！为宁乡乡亲们定制开发的特色游戏。绝无任何外挂，请各位玩家放心使用。
           抵制不良游戏，严禁利用本游戏软件赌博，拒绝盗版游戏。注意自我保护谨防上当受骗，适度游戏有益身心，沉迷游戏伤身。合理安排时间，享受健康生活。]]
        self.Text:setString(str)
    end
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)
end

-- 初始触摸
function M:initTouch()
	self.CloseBtn:addClickEventListener(handler(self, self.Click_Close))
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

-- 点击关闭
function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:setVisible(false)
    -- 关闭回调
    if self.call then
        self.call()
    end
end

-- 关闭回调
function M:addCloseListener(call)
    self.call = call
end

return M
