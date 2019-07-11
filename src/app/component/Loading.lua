local M = class("Loading",function()
	return display.newLayer()
end)

function M:ctor(info)
    local node = cc.CSLoader:createNode("Component/LoadingLayer.csb");
    node:addTo(self)
    self.root = node

    self:initView(info)
end

function M:initView(info)
    self.Text = self.root:getChildByName("Text")
    self.Text:setString(info)

    self.BG = self.root:getChildByName("BG")
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,90))
    self.BG:addChild(curColorLayer)

    self.IMG = self.root:getChildByName("IMG")
    local seq1 = cc.Sequence:create(cc.RotateTo:create(0.5,180.0),cc.RotateTo:create(0.5,360.0),nil)
    local seq2 = cc.Sequence:create(cc.RotateTo:create(0.5,180.0),cc.RotateTo:create(0.5,360.0),nil)
    self.IMG:runAction(cc.RepeatForever:create(seq1))
end

return M
