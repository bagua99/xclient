
local M = class("DownLoadWebViewLayer",function()
	return display.newLayer()
end)

function M:ctor(url)
	local node = cc.CSLoader:createNode("Lobby/WebView/WebViewLayer.csb");
	node:addTo(self)
	self.root = node

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
	self._webView:setOnShouldStartLoading(function(sender, url)
		-- print("onWebViewShouldStartLoading, url is ", url)
		return true
	end)
	self._webView:setOnDidFinishLoading(function(sender, url)
		-- print("onWebViewDidFinishLoading, url is ", url)
	end)
	self._webView:setOnDidFailLoading(function(sender, url)
		-- print("onWebViewDidFinishLoading, url is ", url)
	end)
	self.WebViewBG:addChild(self._webView)
end

-- 点击退出
function M:Click_Quit()
	G_CommonFunc:addClickSound()
	self:removeFromParent()
end

return M
