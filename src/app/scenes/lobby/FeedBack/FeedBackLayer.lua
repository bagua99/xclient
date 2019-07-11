local cjson = require("componentex.cjson")

local M = class("FeedBackLayer", function()
	return display.newLayer()
end)

function M:ctor()
	local node = cc.CSLoader:createNode("Lobby/FeedBack/FeedBackLayer.csb");
	node:addTo(self)
	self.root = node

	self:initView()
end

function M:initView()
	self.BG = self.root:getChildByName("BG")
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)
    self.BTN_COMMIT = self.root:getChildByName("BTN_COMMIT")
    self.CloseBtn   = self.root:getChildByName("CloseBtn")
    self.INPUT_CONTENT = self.root:getChildByName("INPUT_CONTENT")
    self.BTN_COMMIT:addClickEventListener(handler(self,self.submit))
    self.CloseBtn:addClickEventListener(handler(self,self.cancel))
end

function M:submit()
	G_CommonFunc:addClickSound()
    local str = self.INPUT_CONTENT:getString()
	local GameConfig = require "app.config.GameConfig"
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:setRequestHeader("Content-Type", "application/json")
    xhr.timeout = 3
    xhr:open("POST","http://"..G_Data.strProxy..":"..GameConfig.web_port..GameConfig.feed_back_url)
    local function reqCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local content = xhr.response
            local retMsg = cjson.decode(content)
            local retcode = retMsg.retcode
            if retcode == "1" then 
                dump("feeback success***")
            else 
                dump("feeback faild**")
            end
            self:Click_Close() 
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(reqCallback)
    local msg = {
        uid = G_Data.UserBaseInfo.unionid,
        info = str,
        contact = "QQ12352632" 
    }
    xhr:send(cjson.encode(msg))
end 

function M:cancel()
    G_CommonFunc:addClickSound()
	self:Click_Close()
end

function M:Click_Close()
	self:setVisible(false)
    if self.call then
        self.call()
    end
end

function M:addCloseListener(call)
    self.call = call
end

return M