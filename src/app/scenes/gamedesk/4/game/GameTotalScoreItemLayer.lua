
local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

local M = class("GameTotalScoreItemLayer", function()
	return display.newLayer()
end)

function M:ctor()
	 local node = cc.CSLoader:createNode("res/"..GameConfigManager.tGameID.NXPHZ.."/GameTotalScoreItemLayer.csb");
	 node:addTo(self)
	 self.root = node

	 self:initView()
end

function M:initView()
    self.Panel              = self.root:getChildByName("Panel")
    --[[
    self.Text_Count         = self.Panel:getChildByName("Text_Count")
    self.Text_Score         = self.Panel:getChildByName("Text_Score")
    --]]
end

return M