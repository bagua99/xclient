
local utils         = require "utils"
local crc           = require "rcc"
local SPConfig      = require("app.config.SPConfig")
local ItemLayer     = require("app.scenes.lobby.common.ItemLayer")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local M = class("SPayLayer", function()
    return display.newLayer()
end)

function M:ctor()
    local node = cc.CSLoader:createNode("Lobby/Choice/SPLayer.csb");
    node:addTo(self)
    self.root = node

    self.bPaying = false
    
    self:initView()
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

function M:response(msg)
    dump("response")
    local result = msg.result
    if result == "SUCCESS" then
        -- 刷新大厅数据
        local roomcard = msg.roomcard or 0
        local waresid = msg.waresid
        -- show tips
        local isActivity = false
        if waresid > 4 then
            isActivity = true
        end
        local productName = SPConfig.tPay[waresid].name or "房卡"
        G_Event:dispatchEvent({ name = "UpdateCardForRoom", msg = "恭喜您购买" .. productName .. "充值成功!", roomcard = roomcard, flag = true, isActivity = isActivity })
    end
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = { "setStatus" }
        local sigs = "(Ljava/lang/String;)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/hnqp/pdkgame/AppActivity"
        local ok = luaj.callStaticMethod(className, "setStatus", args, sigs)
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local className1 = "AppController"
        luaoc.callStaticMethod(className1, "setHandler", { resume = 0 })
    end

    self.bPaying = false
    if result == "SUCCESS" then
        self:removeFromParent()
    end
end

function M:failed()
    dump("failed")
    self.bPaying = false
    self:removeFromParent()
end

function M:queryOrder(order)
    dump("queryOrder")
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

function M:initView()
    self.panel          = self.root:getChildByName("Panel")
    self.BG             = self.root:getChildByName("BG")
    self.BTN_CLOSE      = self.panel:getChildByName("BTN_CLOSE")
    self.list           = self.panel:getChildByName("ListView")
    local layer = ItemLayer.new()
    local panel = layer.panel
    panel:setScale(0.8)
    self.list:setItemModel(layer.panel)
    local payCount = 4
    for i = 1, payCount do
        self.list:pushBackDefaultItem()
    end
    local items_count = table.getn(self.list:getItems())
    for i = 1, items_count do
        local item = self.list:getItem(i - 1)
        -- **设置图片**
        local pconfig = SPConfig.tPay[i]
        local Text_Price = item:getChildByName("Text_Price")
        local Text_FangKa = item:getChildByName("Text_FangKa")
        local Text_SEND = item:getChildByName("Text_SEND")
        Text_FangKa:setString(pconfig.name)
        Text_Price:setString(pconfig.value .. "元")
        Text_SEND:setString(pconfig.send or "")
    end

    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
            G_CommonFunc:addClickSound()
            local product_id = sender:getCurSelectedIndex() + 1
            self:showPayChoiceLayer(product_id)
        end
    end
    self.list:addEventListener(listViewEvent)

    local curColorLayer = display.newLayer(cc.c4b(0, 0, 0, 30))
    self.BG:addChild(curColorLayer)

    self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))
end

function M:Click_Close()
    G_CommonFunc:addClickSound()
    self:removeFromParent()
end

function M:showPayChoiceLayer(product_id)
    local node_ = cc.CSLoader:createNode("Lobby/Choice/ChoiceLayer.csb")
    node_:addTo(self)
    local Panel_            = node_:getChildByName("Panel")
    local BTN_CLOSE         = Panel_:getChildByName("BTN_CLOSE")
    local BTN_ZHIFUBAO      = Panel_:getChildByName("BTN_ZHIFUBAO")
    local BTN_WEIXIN        = Panel_:getChildByName("BTN_WEIXIN")
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
    end
end

function M:startPayWay(product_id, way)
    dump("startPayWay")
    if self.bPaying then
        return
    end
    self.bPaying = true
    self:getPayUrl(product_id, way, function(retMsg)
        dump(retMsg)
        local transid = retMsg.transid
        local url = utils.base64decode(retMsg.url)
        if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
            local function payFinish()
                self:queryOrder(transid)
            end
            local sigs = "(Ljava/lang/String;I)V"
            local luaj = require "cocos.cocos2d.luaj"
            local className = "com/hnqp/pdkgame/AppActivity"
            local args = { url, payFinish }
            local ok = luaj.callStaticMethod(className, "pay", args, sigs)
        elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "RootViewController"
            luaoc.callStaticMethod(className, "openUIWebView", { url = url })

            local function payFinish()
                self:queryOrder(transid)
            end
            local className1 = "AppController"
            luaoc.callStaticMethod(className1, "setHandler", { resume = payFinish })
        end
    end)
end

return M
