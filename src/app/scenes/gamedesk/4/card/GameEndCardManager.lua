
local M = class("GameEndCardManager", function()
    return ccui.Layout:create()
end)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameCard")

function M:create()
    local view = M.new()
    view:onCreate()
    return view
end

function M:onCreate()
    -- 牌点
    self.tCardPoint =
    {
        nPonX = 350,
        nPonY = 143,
    }
    -- 底牌点
    self.tRepertoryCardPoint =
    {
        nPonX = 58,
        nPonY = 410,
    }
end

-- 显示牌
function M:showCard(tWeaveItemArray)
    for nCol, tWeave in ipairs(tWeaveItemArray) do
        local nHuXi = self:getCardHuXi(tWeave)
        if nHuXi then
            local nPoint = cc.p(self.tCardPoint.nPonX + (nCol - 1) * 50, self.tCardPoint.nPonY - 50)
            local pHuXi = ccui.Text:create()
            pHuXi:setString(nHuXi)
            pHuXi:setFontSize(24)
            pHuXi:setPosition(nPoint)
            self:addChild(pHuXi)
        end

        for nLine, nCard in ipairs(tWeave.tCardData) do
            local nPoint = cc.p(self.tCardPoint.nPonX + (nCol - 1) * 50, self.tCardPoint.nPonY + (nLine - 1) * 50)
            local szFileName = "s"..nCard..".png"
            local pGameCard = GameCard:create(szFileName)
            pGameCard:setPosition(nPoint)
            self:addChild(pGameCard)
        end

        -- 类型
        local szKind = nil
        if tWeave.nWeaveKind == G_GameDefine.ACK_TI then
            szKind = "nxphz_end_ti.png"
        elseif tWeave.nWeaveKind == G_GameDefine.ACK_PAO then
            szKind = "nxphz_end_pao.png"
        elseif tWeave.nWeaveKind == G_GameDefine.ACK_WEI then
            szKind = "nxphz_end_wei.png"
        elseif tWeave.nWeaveKind == G_GameDefine.ACK_PENG then
            szKind = "nxphz_end_peng.png"
        elseif tWeave.nWeaveKind == G_GameDefine.ACK_CHI then
            szKind = "nxphz_end_chi.png"
        end
        if szKind then
            local nPoint = cc.p(self.tCardPoint.nPonX + (nCol - 1) * 50, self.tCardPoint.nPonY + 200)
            local pKindSprite = cc.Sprite:createWithSpriteFrameName(szKind)
            pKindSprite:setPosition(nPoint)
            self:addChild(pKindSprite)
        end
    end
end

-- 显示底牌
function M:showRepertoryCard(tCardData)
    for nIndex, nCard in ipairs(tCardData) do
        local szFileName = "s"..nCard..".png"
        local pGameCard = GameCard:create(szFileName)
        local nPoint = cc.p(self.tRepertoryCardPoint.nPonX + nIndex * 50, self.tRepertoryCardPoint.nPonY)
        pGameCard:setPosition(nPoint)
        self:addChild(pGameCard)
    end
end

-- 获取胡息
function M:getCardHuXi(tWeave)
    local nHuXi = 0
    if tWeave.nWeaveKind == G_GameDefine.ACK_TI then
        if tWeave.nCenterCard ~= 0 then
            if tWeave.nCenterCard > 10 then
                nHuXi = nHuXi + G_GameDefine.HUXI_TI_B
            else
                nHuXi = nHuXi + G_GameDefine.HUXI_TI_S
            end
        end
    elseif tWeave.nWeaveKind == G_GameDefine.ACK_PAO then
        if tWeave.nCenterCard ~= 0 then
            if tWeave.nCenterCard > 10 then
                nHuXi = nHuXi + G_GameDefine.HUXI_PAO_B
            else
                nHuXi = nHuXi + G_GameDefine.HUXI_PAO_S
            end
        end
    elseif tWeave.nWeaveKind == G_GameDefine.ACK_WEI then
        if tWeave.nCenterCard ~= 0 then
            if tWeave.nCenterCard > 10 then
                nHuXi = nHuXi + G_GameDefine.HUXI_WEI_B
            else
                nHuXi = nHuXi + G_GameDefine.HUXI_WEI_S
            end
        end
    elseif tWeave.nWeaveKind == G_GameDefine.ACK_PENG then
        if tWeave.nCenterCard ~= 0 then
            if tWeave.nCenterCard > 10 then
                nHuXi = nHuXi + G_GameDefine.HUXI_PENG_B
            else
                nHuXi = nHuXi + G_GameDefine.HUXI_PENG_S
            end
        end
    elseif tWeave.nWeaveKind == G_GameDefine.ACK_CHI then
        -- 获取数值
        local nValue1 = tWeave.tCardData[1] > 10 and tWeave.tCardData[1] - 10 or tWeave.tCardData[1]
        local nValue2 = tWeave.tCardData[2] > 10 and tWeave.tCardData[2] - 10 or tWeave.tCardData[2]
        local nValue3 = tWeave.tCardData[3] > 10 and tWeave.tCardData[3] - 10 or tWeave.tCardData[3]

        local tCardData =
        {
            [nValue1] = true,
            [nValue2] = true,
            [nValue3] = true,
        }
        -- 一二三吃
        if tCardData[1] and tCardData[2] and tCardData[3] then
            local nCount = tWeave.tCardData[1] > 10 and G_GameDefine.HUXI_123_B or G_GameDefine.HUXI_123_S
            nHuXi = nHuXi + nCount
        end

        -- 二七十吃
        if tCardData[2] and tCardData[7] and tCardData[10] then
            local nCount = tWeave.tCardData[1] > 10 and G_GameDefine.HUXI_27A_B or G_GameDefine.HUXI_27A_S
            nHuXi = nHuXi + nCount
        end
    else
        nHuXi = nil
    end

    return nHuXi
end

return M
