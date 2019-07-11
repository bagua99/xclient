local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

local M = class("GameTotalItemLayer", function()
	return display.newLayer()
end)

function M:ctor()
	 local node = cc.CSLoader:createNode("res/"..GameConfigManager.tGameID.NXPHZ.."/GameTotalItemLayer.csb");
	 node:addTo(self)
	 self.root = node

	 self:initView()
end

function M:initView()
    self.Panel                  = self.root:getChildByName("Panel")
    --[[
    self.ImageView_Head         = self.Panel:getChildByName("ImageView_Head")
	self.Text_Name              = self.Panel:getChildByName("ImageView_NameBG"):getChildByName("Text_Name")
    self.Text_Score             = self.Panel:getChildByName("ImageView_ScoreBG"):getChildByName("Text_Score")
    self.ImageView_MaxWin       = self.Panel:getChildByName("ImageView_MaxWin")
    self.ImageView_HouseOwner   = self.Panel:getChildByName("ImageView_HouseOwner")
    self.ListView_Result        = self.Panel:getChildByName("ListView_Result")
    --]]
end

return M