
local GameConfig        = require "app.config.GameConfig"
local targetPlatform    = cc.Application:getInstance():getTargetPlatform()

local M = class("SendCardLayey",function()
	return display.newLayer()
end)

function M:ctor(params)
	local node = cc.CSLoader:createNode("Lobby/National_profit/SendCardLayer.csb");
	node:addTo(self)
	self.root = node

	self:initView(params)
end

function M:initView(params)
	self.BTN_CLOSE  = self.root:getChildByName("BTN_CLOSE")
	self.BTN_SEND_CARD   = self.root:getChildByName("BTN_SEND_CARD")
	self.INPUT_ACCOUNT = self.root:getChildByName("INPUT_ACCOUNT")
	self.INPUT_ROOMCARD_NUMBER = self.root:getChildByName("INPUT_ROOMCARD_NUMBER")

	self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))
	self.BTN_SEND_CARD:addClickEventListener(handler(self, self.Click_SendCard))

    self.BG = self.root:getChildByName("BG")
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    self.Text_XJDL = self.root:getChildByName("Text_XJDL")
    self.Text_XJDL_TOTAL = self.root:getChildByName("Text_XJDL_TOTAL")
end

function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:removeFromParent()
end

-- 提示信息
function M:tips(str)
    local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    curLayer:addOthers("res/Lobby/National_profit/wxicon.png")
    self:addChild(curLayer)
end

function M:Click_SendCard()
	local account = self.INPUT_ACCOUNT:getString()
	local number = self.INPUT_ROOMCARD_NUMBER:getString()
	local msg = {
		userid = G_Data.UserBaseInfo.userid,
        getid = tonumber(account),
        count = tonumber(number),
		sign = G_Data.UserBaseInfo.sign,
	}
	G_CommonFunc:httpForJsonLobby("/send_card", 5, msg, handler(self, self.update_userinfo), handler(self, self.failed))
end

function M:failed()
	local str = "赠送房卡出现异常"
	local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

function M:update_userinfo(msg)
    if msg == nil then
        return
    end

    local str = "赠送房卡成功"
	if msg.result == "success" then
    	local count = msg.count or 0 
    	G_Data.UserBaseInfo.roomcard = G_Data.UserBaseInfo.roomcard - count
        G_Event:dispatchEvent({name="Update_UserBaseInfo"})
    elseif msg.result == "send self fail" then
        str = "不能给自己赠送房卡"
    elseif msg.result == "count fial" then
        str = "赠送房卡至少1张以上"
    elseif msg.result == "count less fail" then
        str = "您没有足够的房卡，赠送失败"
    else
   		str = "赠送房卡出现异常" 	 
    end
    local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

return M
