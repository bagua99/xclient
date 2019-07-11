
local M = class("GameCard", cc.Sprite)

function M:ctor(szFileName)
	self:setSpriteFrame(szFileName)
    self:setVisible(true)
end

return M
