
local Product           = require("app.config.Product")
local SPConfig          = require("app.config.SPConfig")
local utils             = require "utils"
local crc               = require "rcc"
local targetPlatform    = cc.Application:getInstance():getTargetPlatform()

local M = class("ActivityLayer", function()
	return display.newLayer()
end)

function M:ctor()
	local node = cc.CSLoader:createNode("Lobby/Activity/ActivityLayer.csb");
	node:addTo(self)
	self.root = node

    self.bPaying = false

	self:initView()
end

function M:initView()
	self.BG = self.root:getChildByName("BG")
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)
    
    self.panel      = self.root:getChildByName("Panel")

    self.BTN_CLOSE  = self.panel:getChildByName("BTN_CLOSE")
    self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))

    for i = 1, 6 do
		local btn = self.panel:getChildByName("BTN_A"..i)
		btn.index = i
		btn:addClickEventListener(handler(self, self.Click_Choose))
    end
end

function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:removeFromParent()
end

function M:Click_Choose(e)
	G_CommonFunc:addClickSound()
	local index = e.index
	local name = Product[index+5]
	local product_id = index+5
	
	--跳往支付页面
	local value = SPConfig.tPay[product_id].value
	local curLayer = G_WarnLayer.create()
	curLayer:setTips(string.format("充%d元开始抽奖",value))
	curLayer:setTypes(3)
	self:addChild(curLayer)
	curLayer:setOkCallback(function()
		curLayer:removeFromParent()
		self:showPayChoiceLayer(product_id)
	end)
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
		-- local roomcard = msg.roomcard
		local waresid = msg.waresid 
		local productName = SPConfig.tPay[waresid].name or "房卡"
		local isActivity = false
		if waresid > 4 then 
			isActivity = true 
		end 
		G_Event:dispatchEvent({name="UpdateCardForRoom",msg="恭喜您购买"..productName.."充值成功!",flag=true,waresid=waresid,isActivity=isActivity})
	end
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = {"setStatus"}
	    local sigs = "(Ljava/lang/String;)V"
	    local luaj = require "cocos.cocos2d.luaj"
	    local className = "com/hnqp/pdkgame/AppActivity"
	    local ok = luaj.callStaticMethod(className,"setStatus",args,sigs)
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local className1 = "AppController"
        luaoc.callStaticMethod(className1,"setHandler",{resume=0})
    end

    self.bPaying = false
end

function M:failed()
    self.bPaying = false
	self:removeFromParent()
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
    end
end

function M:startPayWay(product_id, way)
	if self.bPaying then
        return
    end
    self.bPaying = true

	self:getPayUrl(product_id,way,function(retMsg)
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
				local args = {url, payFinish}
	        	local ok = luaj.callStaticMethod(className, "pay", args, sigs)
			elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then
                local luaoc = require "cocos.cocos2d.luaoc"
                local className = "RootViewController"
                luaoc.callStaticMethod(className, "openUIWebView", {url = url})
                local function payFinish()
                   self:queryOrder(transid)
                end
                local className1 = "AppController"
                luaoc.callStaticMethod(className1, "setHandler", {resume = payFinish})
			end
		elseif result1=="have lottery draw" then
			local waresid = retMsg.waresid 
			local isActivity = false
			if waresid > 4 then 
				isActivity = true 
			end 
			G_Event:dispatchEvent({name="UpdateCardForRoom", msg="恭喜您购买房卡充值成功!", flag=true, waresid=waresid, isActivity=isActivity}) 
			self:removeFromParent()
		elseif result1=="count limit 2" then 
			G_Event:dispatchEvent({name="UpdateCardForRoom", msg="活动充值次数已经达到上限", flag=false})
			self:removeFromParent()
		end
	end)
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
			self:choicePayWay(product_id,SPConfig.ZFB_PAY)
        else
        	local t = os.time()
            local dur =  t-self.clicktime1  
            if dur<3 and t>0  then
                return 
            end
            self.clicktime1 = t
        	G_CommonFunc:addClickSound()
			self:choicePayWay(product_id,SPConfig.ZFB_PAY)
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

-- 提示信息
function M:tips(str)
    local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

return M
