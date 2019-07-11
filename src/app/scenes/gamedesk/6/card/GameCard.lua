
local M = class("GameCard", cc.Sprite)

-- 未选择
M.Card_None = 0
-- 选择
M.Card_Selected = 1
-- 所有(未选择,选择)
M.Card_All = 2

function M:ctor(nCard)
    self.nState = M.Card_None
	self.nCard = nCard
    self.bTouch = false
    self.bChooseTouch = true

	self:setDisplayFrameName(nCard)
end

function M:setDisplayFrameName(nCard)
    local szFileName =  string.format("res_poker_cards_card_%02x.png", nCard)
    self:setSpriteFrame(szFileName)
    self:setVisible(true)

    self.ImageView_Da = ccui.ImageView:create()
    self.ImageView_Da:loadTexture("SDH_imgDa.png", ccui.TextureResType.plistType)
	self.ImageView_Da:setPosition(cc.p(124, 188))
	self.ImageView_Da:setVisible(false)
    self:addChild(self.ImageView_Da)

    self.ImageView_Main = ccui.ImageView:create()
    self.ImageView_Main:loadTexture("SDH_zhu_2.png", ccui.TextureResType.plistType)
	self.ImageView_Main:setPosition(cc.p(31, 32))
	self.ImageView_Main:setVisible(false)
    self:addChild(self.ImageView_Main)

    self:setScale(G_DeskScene.GameDeskLayer.tScale.width, G_DeskScene.GameDeskLayer.tScale.height)
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

function M:showMain(bShow)
	self.ImageView_Main:setVisible(bShow)
end

function M:showDa(bShow)
	self.ImageView_Da:setVisible(bShow)
end

return M
