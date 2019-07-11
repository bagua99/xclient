
local M = class("GameOutCardManager", function()
    return ccui.Layout:create()
end)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameCard")

function M:create(nLocalSeat)
    local view = M.new()
    view:onCreate(nLocalSeat)
    return view
end

function M:onCreate(nLocalSeat)
    self.nLocalSeat = nLocalSeat

    -- 牌点
    self.tCardPoint =
    {
        {nPonX = 1115,   nPonY = 200},
        {nPonX = 135,    nPonY = 515},
        {nPonX = 1003,   nPonY = 515},
    }
    -- 牌方向点
    self.tCardDir =
    {
        {nWidth = -45,  nHegiht = 45},
        {nWidth = 45,   nHegiht = 45},
        {nWidth = -45,  nHegiht = 45},
    }

    self.tCardNode = cc.Node:create()
    self:addChild(self.tCardNode)
    -- 牌信息
    self.tCardInfo = {}
end

-- 还原数据
function M:restore()
    self.tCardInfo = {}

    self:showCard()
end

-- 增加一张牌
function M:addOneCard(nCard)
    -- 插入牌
    table.insert(self.tCardInfo, nCard)
    -- 显示牌
    self:showCard()
end

-- 增加一张牌
function M:addCard(tCard)
    for _, nCardData in ipairs(tCard) do
        -- 插入牌
        table.insert(self.tCardInfo, nCardData)
    end
    -- 显示牌
    self:showCard()
end

-- 显示牌
function M:showCard()
    local nCardPoint = self.tCardPoint[self.nLocalSeat]
    local nCardDir = self.tCardDir[self.nLocalSeat]
    self.tCardNode:removeAllChildren()
    for nIndex, nCard in ipairs(self.tCardInfo) do
        local nLine = math.modf(nIndex/6)
        local nCol = math.fmod(nIndex - 1, 5)
        local szFileName = "s"..nCard..".png"
        local pGameCard = GameCard:create(szFileName)
        local nPoint = cc.p(nCardPoint.nPonX + nCol * nCardDir.nWidth, nCardPoint.nPonY + nLine * nCardDir.nHegiht)
        pGameCard:setPosition(nPoint)
        self.tCardNode:addChild(pGameCard)
    end
end

return M