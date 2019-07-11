
local M = class("SearchLayer",G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/ZhanJi/SearchLayer.csb"

local utils                     = require "utils"
local GameConfig                = require "app.config.GameConfig"
local cjson 					= require("componentex.cjson")

-- 创建
function M:onCreate()
    self.Layout = self.resourceNode_.node["Layout"]
    self.CloseBtn = self.resourceNode_.node["CloseBtn"]
    self.CommitBtn = self.resourceNode_.node["CommitBtn"]
	self.CancelBtn = self.resourceNode_.node["CancelBtn"]

    self.Input = self.resourceNode_.node["InputBg"].node["Input"]
end

-- 初始化视图
function M:initView()
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.Layout:addChild(curColorLayer)
end

-- 初始化触摸
function M:initTouch()
    self.CloseBtn:addClickEventListener(handler(self, self.Click_Close))
    self.CommitBtn:addClickEventListener(handler(self, self.Click_Commit))
    self.CancelBtn:addClickEventListener(handler(self, self.Click_Cancel))
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

function M:onTouchBegin(touch, event)
	return self:isVisible()
end

function M:onTouchMove(touch, event)

end

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

function M:Click_Commit()
    G_CommonFunc:addClickSound()
	self:setVisible(false)
    self:Click_Watch()
end

function M:Click_Cancel()
    G_CommonFunc:addClickSound()
	self:setVisible(false)
    -- 关闭回调
    if self.call then
        self.call()
    end
end

-- 点击输入框
function M:EditTouch(eventName, sender)

end

-- 关闭回调
function M:addCloseListener(call)
    self.call = call
end

function M:Click_Watch()
    -- 取得输入框ID
    G_CommonFunc:addClickSound()
    local str = self.Input:getString()
    local nLen = string.len(str)
    if nLen == 0 or nLen >= 10 then
        -- 关闭回调
        if self.call then
            self.call()
        end
        return
    end
	local msg = {id = tonumber(str)}
	self:postRecordList(GameConfig.get_record_game, msg)
end

function M:postRecordList(url, msg)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr.timeout = 4
	xhr:open("POST", url)
	local function reqCallback()
        if xhr.status == 200 then
		    local retMsg = cjson.decode(utils.base64decode(xhr.response))
            self:showRecordGame(retMsg)
        end
		xhr:unregisterScriptHandler()

        -- 关闭回调
        if self.call then
            self.call()
        end
	end
	xhr:registerScriptHandler(reqCallback)
	xhr:send(utils.base64encode(cjson.encode(msg)))
end

function M:showRecordGame(msg)
    G_Data.bReplay = true
    G_Data.bReplayPause = false
    G_Data.gameid = msg.head.game_id
    G_Data.ReplayData = msg

    if G_GameDeskManager ~= nil then
	    G_GameDeskManager:initGame()
    end
end

return M
