local BeProxyLayer      = require("app.scenes.lobby.National_profit.BeProxyLayer")
local cjson 			= require("componentex.cjson")

local M = class("ApplyBeProxyLayer",function()
	return display.newLayer()
end)

function M:ctor()
	local node = cc.CSLoader:createNode("Lobby/National_profit/ApplyBeProxyLayer.csb");
	node:addTo(self)
	self.root = node

	self:initView()
end

function M:initView()
	self.BTN_CLOSE  = self.root:getChildByName("BTN_CLOSE")
	self.BTN_APPLY  = self.root:getChildByName("BTN_APPLY")
	self.INPUT_NAME  = self.root:getChildByName("INPUT_NAME")
	self.INPUT_IHONE_NUMBER  = self.root:getChildByName("INPUT_IHONE_NUMBER")
	self.BG = self.root:getChildByName("BG")

	self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))
	self.BTN_APPLY:addClickEventListener(handler(self, self.Click_Apply))

	local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)
end

function M:Click_Close()
    G_CommonFunc:addClickSound()
	self:removeFromParent()
end

function M:CheckIsMobile(str)
    return string.match(str,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == str
end

function M:Click_Apply()
    G_CommonFunc:addClickSound()
    local iphone_number = self.INPUT_IHONE_NUMBER:getString()    
    local isMobile = self:CheckIsMobile(iphone_number)
    if isMobile == false then 
        dump("**手机号码错误**")
        self:tips("您输入的手机号码有误,请重新输入!")
        return
    end
    local name = self.INPUT_NAME:getString()
    local str = "您的姓名是:"..name.."\n您的手机号码是:"..iphone_number
    local curLayer = G_WarnLayer.create()
	curLayer:setTips(str)
	curLayer:setTypes(3)
	self:addChild(curLayer)
	curLayer:setOkCallback(function()
		curLayer:removeFromParent()
		self:applyDL(name,iphone_number)
    end)
end

--代理申请接口
function M:applyDL(name, iphone_number)
    local GameConfig = require "app.config.GameConfig"
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:setRequestHeader("Content-Type", "application/json")
    xhr.timeout = 3
    xhr:open("POST","http://"..G_Data.strProxy..":"..GameConfig.web_port..GameConfig.applyDL_url)
    local function reqCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local content = xhr.response
            local retMsg = cjson.decode(content)
            local retcode = retMsg.retcode
            if retcode == "1" then 
                self:addBeProxyLayer()
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(reqCallback)
    local msg = {
        uid = G_Data.UserBaseInfo.unionid,
        phn = iphone_number,
        name = name 
    }
    dump(msg)
    xhr:send(cjson.encode(msg))
end

function M:addBeProxyLayer()
    G_Data.hasPostApply = true
    G_Data.isProxy = false 
	local layer = BeProxyLayer.new()
    self:addChild(layer)
    layer:addCloseListener(function()
    	layer:removeFromParent()
    	self:removeFromParent()
    end)
end

-- 提示信息
function M:tips(str)
    local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

return M
