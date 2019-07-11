
local M = class("GameCard", cc.Sprite)

local bit = require("bit")

-- 未选择
M.Card_None = 0
-- 选择
M.Card_Selected = 1
-- 所有(未选择,选择)
M.Card_All = 2

function M:ctor(nCard, nLocalSeat)
    self.nState = M.Card_None
	self.nCard = nCard
    self.bTouch = false
    self.bChooseTouch = true

	self:setDisplayFrameName(nCard, nLocalSeat)
end

function M:setDisplayFrameName(nCard, nLocalSeat)
    local szFileName = ""

    local nColor = bit.rshift(nCard, 4)
    local nNum = bit.band(nCard, 0x0F)
    if nNum ~= 0 then

        szFileName = nColor.."_"..nNum..".png"

        -- 设置缩放
        local fScale = 0.5
        local nRotation = 0
        if nLocalSeat == 1 then
            fScale = 0.8
        elseif nLocalSeat == 2 then
            fScale = 0.5
        elseif nLocalSeat == 3 then
            fScale = 0.5
        end
        self:setScale(fScale)
	    self:setSpriteFrame(szFileName)
        self:setVisible(true)
    end
end

function M:setState(nState)
	self.nState = nState
end

function M:getState()
	return self.nState
end

function M:onTouched(bTouch)
	if bTouch then
		self:onTouchIn()
	else
		self:onTouchOut()
	end
end

function M:onTouchIn()
	if self.nState == M.Card_Selected then
		return
	end
	self:setPosition(self:getPositionX(), self:getPositionY() + 20)
	self.nState = M.Card_Selected
end

function M:onTouchOut()
    if self.nState == M.Card_None then
		return
	end

	self:setPosition(self:getPositionX(), self:getPositionY() - 20)
	self.nState = M.Card_None
end

-- 选择颜色
function M:setTouchFlag()
    self.bTouch = true
    self:setColor(cc.c3b(125, 125, 125))
end

-- 设置选择状态
function M:setTouchState(bChooseTouch)
    self.bChooseTouch = bChooseTouch

    if bChooseTouch then
        self:setColor(cc.c3b(255, 255, 255))
    else
        self:setColor(cc.c3b(125, 125, 125))
    end
end

function M:caluteTouch()
    if not self.bChooseTouch then
        return
    end

    self:setColor(cc.c3b(255, 255, 255))

    if self.bTouch then
        if self.nState == M.Card_None then
            self:onTouchIn()
        else
            self:onTouchOut()
        end
    end
    self.bTouch = false
end

function M:setCardData(nCard)
	self.nCard = nCard
end

function M:getCardData(nCardType)
    -- 不是选所有牌，要匹配类型
    if nCardType ~= M.Card_All then
        if self.nState ~= nCardType then
            return 0
        end
    end

	return self.nCard
end

return M
