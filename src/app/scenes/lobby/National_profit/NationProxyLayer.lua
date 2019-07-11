local M = class("NationProxyLayer",function()
	return display.newLayer()
end)

function M:ctor()
	local node = cc.CSLoader:createNode("Lobby/National_profit/NationProxyLayer.csb");
	node:addTo(self)
	self.root = node

	self:initView()
end

function M:initView()
	self.BTN_CLOSE  = self.root:getChildByName("BTN_CLOSE")
	self.BTN_PROFIT_ALL  = self.root:getChildByName("BTN_PROFIT_ALL")
	self.BTN_BE_PROXY  = self.root:getChildByName("BTN_BE_PROXY")
	self.Node = self.root:getChildByName("Node_1")
	self.BG = self.root:getChildByName("BG")

	self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))
	self.BTN_PROFIT_ALL:addClickEventListener(handler(self, self.Click_Profit_All))
	self.BTN_BE_PROXY:addClickEventListener(handler(self, self.Click_Be_Proxy))

	local curColorLayer = display.newLayer(cc.c4b(0,0,0,50))
    self.BG:addChild(curColorLayer)

    self:addProfitLayer()
end

function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:removeFromParent()
end

function M:Click_Profit_All()
	G_CommonFunc:addClickSound()
	self.BTN_PROFIT_ALL:loadTexture("nationalproxy_quanmin_btn1.png", ccui.TextureResType.plistType)
	self.BTN_BE_PROXY:loadTexture("nationalproxy_be_proxy_btn2.png", ccui.TextureResType.plistType)
	self.Node:removeAllChildren()
	self:addProfitLayer()
end

function M:addProfitLayer()
	local node = cc.CSLoader:createNode("Lobby/National_profit/Profit_All_Layer.csb")
	node:addTo(self.Node)
end

function M:Click_Be_Proxy()
	G_CommonFunc:addClickSound()
	self.BTN_PROFIT_ALL:loadTexture("nationalproxy_quanmin_btn2.png", ccui.TextureResType.plistType)
	self.BTN_BE_PROXY:loadTexture("nationalproxy_be_proxy_btn1.png", ccui.TextureResType.plistType)
	self.Node:removeAllChildren()

	local node = cc.CSLoader:createNode("Lobby/National_profit/Be_Proxy_Layer.csb")
	node:addTo(self.Node)
end

return M
