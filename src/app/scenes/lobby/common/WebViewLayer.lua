
local SPConfig              = require("app.config.SPConfig")
local targetPlatform        = cc.Application:getInstance():getTargetPlatform()

local M = class("WebViewLayer", function()
	return display.newLayer()
end)

function M:ctor(url, transid, way)
	local node = cc.CSLoader:createNode("Lobby/WebView/WebViewLayer.csb");
	node:addTo(self)
	self.root = node
	self.transid = transid
	self.way = way

    self.NATION_PRODUCE_INDEX = 12
    self.bPaying = false

	self:initView(url)
end

function M:initView(url)
	self.BTN_CLOSE = self.root:getChildByName("BTN_CLOSE")	
    self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Quit))

    self.BG = self.root:getChildByName("BG")
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    self.WebViewBG = self.root:getChildByName("WebViewBG")
    local winSize = self.WebViewBG:getContentSize()
    self._webView = ccexp.WebView:create()
	self._webView:setPosition(winSize.width / 2, winSize.height / 2)
	self._webView:setContentSize(winSize.width,winSize.height)
		
	self._webView:loadURL(url)
	self._webView:setScalesPageToFit(true)
	-- G_CommonFunc:loading("支付请求中...",self)
	if self.way == SPConfig.WX_PAY then 
		self._webView:setVisible(false)
	end
	self._webView:setOnShouldStartLoading(function(sender, url)
		-- print("onWebViewShouldStartLoading, url is ", url)
		return true
	end)
	self._webView:setOnDidFinishLoading(function(sender, url)
		-- print("onWebViewDidFinishLoading, url is ", url)
		-- G_CommonFunc:dismissLoading()
	end)
	self._webView:setOnDidFailLoading(function(sender, url)
		-- print("onWebViewDidFinishLoading, url is ", url)
		-- G_CommonFunc:dismissLoading()
	end)
	self.WebViewBG:addChild(self._webView)
end

-- 点击退出
function M:Click_Quit()
	G_CommonFunc:addClickSound()
	--此处发送Http请求
	local msg = {
		transid = self.transid,
		userid = G_Data.UserBaseInfo.userid,
		sign = G_Data.UserBaseInfo.sign
	}
	G_CommonFunc:httpForJsonLobby("/get_ipay_result" ,5, msg, handler(self, self.response), handler(self, self.failed))
end

function M:response(msg)
	local result = msg.result 
	if result == "SUCCESS" then 
		--刷新大厅数据
		local roomcard = msg.roomcard
		local waresid = msg.waresid 
		--show tips
		local isActivity = false
		if waresid > 4 and waresid ~= self.NATION_PRODUCE_INDEX then 
			isActivity = true 
		end 
		local productName = SPConfig.tPay[waresid].name or "房卡"
		G_Event:dispatchEvent({name="UpdateCardForRoom", msg="恭喜您购买"..productName.."充值成功!", roomcard=roomcard, flag=true, waresid=waresid, isActivity=isActivity})
	else 
		--充值失败
		G_Event:dispatchEvent({name="UpdateCardForRoom", msg="充值失败", flag=false})
	end

	self.bPaying = false
    self:removeFromParent()
end

function M:failed()
	self.bPaying = false
    self:removeFromParent()
end

return M
