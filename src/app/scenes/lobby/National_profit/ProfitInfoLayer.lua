
local DownLoadWebViewLayer      = require("app.scenes.lobby.common.DownLoadWebViewLayer")
local SendCardLayey             = require("app.scenes.lobby.National_profit.SendCardLayey")
local GameConfig                = require "app.config.GameConfig"
local targetPlatform            = cc.Application:getInstance():getTargetPlatform()

local M = class("ProfitInfoLayer", function()
	return display.newLayer()
end)

function M:ctor(params)
	local node = cc.CSLoader:createNode("Lobby/National_profit/ProfitInfoLayer.csb");
	node:addTo(self)
	self.root = node

	self:initView(params)
end

function M:initView(params)
	self.BTN_CLOSE  = self.root:getChildByName("BTN_CLOSE")
	self.BTN_DESC   = self.root:getChildByName("BTN_DESC")
	self.BTN_SHARED = self.root:getChildByName("BTN_SHARED")
	self.BTN_CONCLUDE = self.root:getChildByName("BTN_CONCLUDE")
	self.BTN_SEND_CARD = self.root:getChildByName("BTN_SEND_CARD")
	
	self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))
	self.BTN_DESC:addClickEventListener(handler(self, self.Click_Desc))
	self.BTN_SHARED:addClickEventListener(handler(self, self.Click_Shared))
	self.BTN_CONCLUDE:addClickEventListener(handler(self, self.Click_Conclude))
	self.BTN_SEND_CARD:addClickEventListener(handler(self, self.Click_SendCard))

    self.BG = self.root:getChildByName("BG")
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    self.Text_XJDL = self.root:getChildByName("Text_XJDL")
    -- self.Text_XJDL_TOTAL = self.root:getChildByName("Text_XJDL_TOTAL")
    self.Text_XJDL_PROFIT = self.root:getChildByName("Text_XJDL_PROFIT")
    self.Text_PT = self.root:getChildByName("Text_PT")
    -- self.Text_PTTOAL = self.root:getChildByName("Text_PTTOAL")
    self.Text_PTPROFIT = self.root:getChildByName("Text_PTPROFIT")
    self.Text_TOALPROFIT = self.root:getChildByName("Text_TOALPROFIT")
   
    self.Text_YJSPROFIT = self.root:getChildByName("Text_YJSPROFIT")
    -- self.Text_CLZPROFIT = self.root:getChildByName("Text_CLZPROFIT")
    self.Text_WJSPROFIT = self.root:getChildByName("Text_WJSPROFIT")
    self.Text_ZDTIQU = self.root:getChildByName("Text_ZDTIQU")
    self.root:getChildByName("Text_6"):setVisible(false)
    self.Text_ZDTIQU:setVisible(false)
    self:showProfit(params)
end

--展示收益
function M:showProfit(params)
	self.Text_XJDL:setString(params.xjdlnum or "0")
	-- self.Text_XJDL_TOTAL:setString(params.xjdltotal or "0")
	self.Text_XJDL_PROFIT:setString(params.xjdlprofit or "0")
	self.Text_PT:setString(params.xjptnum or "0")
	-- self.Text_PTTOAL:setString(params.xjpttotal or "0")
	self.Text_PTPROFIT:setString(params.xjptprofit or "0")
	self.Text_TOALPROFIT:setString(params.totalprofit or "0")
	self.Text_YJSPROFIT:setString(params.yjsprofit or "0")
	-- self.Text_CLZPROFIT:setString(params.clzprofit or "0")
	self.Text_WJSPROFIT:setString(params.wjsprofit or "0")
	-- self.Text_ZDTIQU:setString(params.limitdraw or "0")
end

function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:removeFromParent()
end

function M:Click_Desc()
	G_CommonFunc:addClickSound()
	local url = "http://"..G_Data.strProxy..":"..GameConfig.web_port..GameConfig.proxyer_desc_url.."?uid="..G_Data.UserBaseInfo.unionid
	local downLoadWebViewLayer = DownLoadWebViewLayer.new(url)
	self.root:addChild(downLoadWebViewLayer)
end

function M:Click_Conclude()
	G_CommonFunc:addClickSound()
	local str = "请添加微信号：pdk888999 \n进行结算！"
	self:tips(str)
end

function M:Click_Shared()
	G_CommonFunc:addClickSound()
	ef.extensFunction:getInstance():wxInviteFriend(0,"【宁乡棋牌】地锅子，跑得快，最地道的宁乡味。亲友约战，随时随地嗨起来。安全!便捷!稳定!","【宁乡棋牌】地锅子，跑得快，最地道的宁乡味。亲友约战，随时随地嗨起来。安全!便捷!稳定!","",GameConfig.download_url.."?u="..G_Data.UserBaseInfo.userid)
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
	local layer = SendCardLayey.new()
    self:addChild(layer)
end

return M
