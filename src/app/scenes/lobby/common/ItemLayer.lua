
local M = class("ItemLayer",function()
	return display.newLayer()
end)

function M:ctor()
	 local node = cc.CSLoader:createNode("Lobby/Choice/ItemLayer.csb");
	 node:addTo(self)
	 self.root = node
	 
	 self:initView()
end

function M:initView()
	self.panel = self.root:getChildByName("Panel")
end

return M
