local utils             = require "utils"
local crc               = require "rcc"
local Product           = require("app.config.Product")
local SPConfig          = require("app.config.SPConfig")
local targetPlatform    = cc.Application:getInstance():getTargetPlatform()

local M = class("BeProxyLayer",function()
	return display.newLayer()
end)

function M:ctor()
	local node = cc.CSLoader:createNode("Lobby/National_profit/BeProxyLayer.csb");
	node:addTo(self)
	self.root = node

    self.NATION_PRODUCE_INDEX = 12
    self.bPaying = false

	self:initView()
end

function M:initView()
	self.BTN_CLOSE = self.root:getChildByName("BTN_CLOSE")
	self.BTN_PROFIT_ALL = self.root:getChildByName("BTN_PROFIT_ALL")
	self.BTN_CHARGE = self.root:getChildByName("BTN_CHARGE")
	self.BG = self.root:getChildByName("BG")

	self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))
	self.BTN_CHARGE:addClickEventListener(handler(self, self.Click_Charge))

	local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)
end

function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:removeFromParent()
end

function M:Click_Charge()
	G_CommonFunc:addClickSound()
    local index = self.NATION_PRODUCE_INDEX
	local product_id = index
	self:showPayChoiceLayer(product_id)
end

function M:addCloseListener(call)
	if call then 
		self.BTN_CLOSE:addClickEventListener(call)
	end 
end

function M:getPayUrl(product_id, way, call)
	local msg = {
		userid = G_Data.UserBaseInfo.userid,
		sign = G_Data.UserBaseInfo.sign,
		product_id = product_id,
		ptype = way  
	}
	G_CommonFunc:httpForJsonLobby("/create_ipay", 5, msg, call)
end

function M:queryOrder(order)
    if not self.bPaying then
        return
    end
    self.bPaying = false

	local msg = {
		transid = order,
		userid = G_Data.UserBaseInfo.userid,
		sign = G_Data.UserBaseInfo.sign
	}
	G_CommonFunc:httpForJsonLobby("/get_ipay_result", 5, msg, handler(self, self.response), handler(self, self.failed))
end

function M:response(msg)
	local result = msg.result 
	if result == "SUCCESS" then 
		--刷新大厅数据
		local roomcard = msg.roomcard
		local waresid = msg.waresid 
		local productName = PayConfig[waresid].name or "房卡"
		local isActivity = false
		G_Event:dispatchEvent({name="UpdateCardForRoom", msg="恭喜您购买"..productName.."充值成功,成为代理!", flag=true, waresid=waresid, isActivity=isActivity, roomcard=roomcard})
		G_Data.hasPostApply = true
        G_Data.isProxy = true 
	end
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    	local args = {"setStatus"}
   		local sigs = "(Ljava/lang/String;)V"
   		local luaj = require "cocos.cocos2d.luaj"
   		local className = "com/hnqp/pdkgame/AppActivity"
   		local ok = luaj.callStaticMethod(className,"setStatus", args, sigs)
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then
   		local luaoc = require "cocos.cocos2d.luaoc"
   		local className1 = "AppController"
   		luaoc.callStaticMethod(className1, "setHandler", {resume=0})
	end

    self.bPaying = false
	self:removeFromParent()
end

function M:failed()
    self.bPaying = false
	self:removeFromParent()
end

function M:showPayChoiceLayer(product_id)
	local node_ = cc.CSLoader:createNode("Lobby/Choice/ChoiceLayer.csb");
	node_:addTo(self)
	local Panel_ = node_:getChildByName("Panel")
	local BTN_CLOSE = Panel_:getChildByName("BTN_CLOSE")
	local BTN_ZHIFUBAO = Panel_:getChildByName("BTN_ZHIFUBAO")
	local BTN_WEIXIN = Panel_:getChildByName("BTN_WEIXIN")
	BTN_CLOSE:addClickEventListener(function()
		G_CommonFunc:addClickSound()
		node_:removeFromParent()
	end)
	BTN_ZHIFUBAO:addClickEventListener(function()
		if self.clicktime1 == nil then 
        	self.clicktime1 = os.time()
        	G_CommonFunc:addClickSound()
			self:choicePayWay(product_id, SPConfig.ZFB_PAY)
        else
        	local t = os.time()
        	local dur =  t-self.clicktime1  
        	if dur<3 and t>0  then
            	return 
        	end
        	self.clicktime1 = t
        	G_CommonFunc:addClickSound()
			self:choicePayWay(product_id, SPConfig.ZFB_PAY)
        end 
	end)
	BTN_WEIXIN:addClickEventListener(function()
		if self.clicktime2 == nil then 
			self.clicktime2 = os.time()
			G_CommonFunc:addClickSound()
			self:choicePayWay(product_id, SPConfig.WX_PAY)
		else 
			local t = os.time()
        	local dur =  t-self.clicktime2  
        	if dur<3 and t>0  then
            	return 
        	end
        	self.clicktime2 = t
			G_CommonFunc:addClickSound()
			self:choicePayWay(product_id, SPConfig.WX_PAY)
		end
	end)
end

function M:choicePayWay(product_id, way)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        if not self.product_id then
            self.product_id = product_id
        end
        if not self.way then
            self.way = way
        end
        local canPay = function(params)
            if params == "success" then
                self:startPayWay(self.product_id, self.way)
            end
            self.product_id = nil
            self.way = nil
	    end
        local args = {canPay}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/hnqp/pdkgame/AppActivity"
        if way == SPConfig.ZFB_PAY then
            local ok = luaj.callStaticMethod(className, "checkAliPayInstalled", args, sigs)
        elseif way == SPConfig.WX_PAY then
            local ok = luaj.callStaticMethod(className, "checkWXPayInstalled", args, sigs)
        end
    else
        self:startPayWay(product_id, way)
        self.product_id = nil
        self.way = nil
    end
end

function M:startPayWay(product_id, way)
	if self.bPaying then
        return
    end
    self.bPaying = true
	self:getPayUrl(product_id, way, function(retMsg)
		local result1 = retMsg.result 
		if result1 == "SUCCESS" then
			local transid = retMsg.transid
			local url = utils.base64decode(retMsg.url)
			if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
				local function payFinish()
					self:queryOrder(transid)
				end
				local sigs = "(Ljava/lang/String;I)V"
				local luaj = require "cocos.cocos2d.luaj"
				local className = "com/hnqp/pdkgame/AppActivity"
				local args = {url,payFinish}
	        	local ok = luaj.callStaticMethod(className, "pay", args, sigs)
			elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then
                local luaoc = require "cocos.cocos2d.luaoc"
                local className = "RootViewController"
                luaoc.callStaticMethod(className, "openUIWebView", {url=url})
                local function payFinish()
                    self:queryOrder(transid)
                end
                local className1 = "AppController"
                luaoc.callStaticMethod(className1, "setHandler", {resume=payFinish})
			end
		else
			G_Event:dispatchEvent({name="UpdateCardForRoom", msg="玩家购买代理出现异常", flag=false})
			self:removeFromParent()
		end
	end)
end

return M
