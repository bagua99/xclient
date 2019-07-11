local ResultItemLayer = class("ResultItemLayer",function()
	return display.newLayer()
end)

ResultItemLayer.panel = nil 
ResultItemLayer.root  = nil 

function ResultItemLayer:ctor( gameid )
	-- body
	 local node = cc.CSLoader:createNode("res/"..gameid.."/ResultItemLayer.csb");
	 node:addTo(self)
	 self.root = node 
	 self:initView()
end

function ResultItemLayer:initView()
	-- body
	self.panel = self.root:getChildByName("Panel")
end




return ResultItemLayer