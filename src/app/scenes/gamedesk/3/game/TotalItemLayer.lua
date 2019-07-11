local TotalItemLayer = class("TotalItemLayer",function()
	return display.newLayer()
end)

TotalItemLayer.panel = nil 
TotalItemLayer.root  = nil 

function TotalItemLayer:ctor( gameid )
	-- body
	 local node = cc.CSLoader:createNode("res/"..gameid.."/TotalItemLayer.csb");
	 node:addTo(self)
	 self.root = node 
	 self:initView()
end

function TotalItemLayer:initView()
	-- body
	self.panel = self.root:getChildByName("Panel")
end




return TotalItemLayer