
local M = class("GameWeaveCardManager", function()
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
        {nPonX = 25,    nPonY = 175},
        {nPonX = 25,    nPonY = 465},
        {nPonX = 1115,  nPonY = 465},
    }
    -- 牌方向点
    self.tCardDir =
    {
        {nWidth = 45,   nHegiht = 45},
        {nWidth = 45,   nHegiht = -45},
        {nWidth = -45,  nHegiht = -45},
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

--[[
-- 设置组合
local tWeave =
{
    nWeaveKind = define.ACK_PAO,
    nCenterCard = nCenterCard,
    tCardData = {nCenterCard, nCenterCard, nCenterCard, nCenterCard},
}
--]]
-- 增加牌
function M:addCardInfo(tWeave)
    -- 插入组合
    table.insert(self.tCardInfo, tWeave)
    -- 显示牌
    self:showCard()
end

-- 偎变提
function M:onWeiToTi(nCard)
    -- 从偎牌中找出变提
    local bFind = false
    for nIndex, tWeave in ipairs(self.tCardInfo) do
        if tWeave.nWeaveKind == G_GameDefine.ACK_WEI and tWeave.nCenterCard == nCard then
            self.tCardInfo[nIndex].nWeaveKind = G_GameDefine.ACK_TI
            table.insert(self.tCardInfo[nIndex].tCardData, nCard)
            bFind = true
            break
        end
    end

    -- 没找到,找一个为0的偎牌变提
    if not bFind then
        for nIndex, tWeave in ipairs(self.tCardInfo) do
            if tWeave.nWeaveKind == G_GameDefine.ACK_WEI and tWeave.nCenterCard == 0 then
                self.tCardInfo[nIndex].nWeaveKind = G_GameDefine.ACK_TI
                self.tCardInfo[nIndex].tCardData = {0, 0, 0, 0}
                bFind = true
                break
            end
        end
    end

    -- 显示牌
    self:showCard()
end

-- 偎变跑
function M:onWeiToPao(nCard)
    -- 从偎牌中找变跑
    local bFind = false
    for nIndex, tWeave in ipairs(self.tCardInfo) do
        if tWeave.nWeaveKind == G_GameDefine.ACK_WEI and tWeave.nCenterCard == nCard then
            self.tCardInfo[nIndex].nWeaveKind = G_GameDefine.ACK_PAO
            table.insert(self.tCardInfo[nIndex].tCardData, nCard)
            bFind = true
            break
        end
    end

    -- 没找到,找一个为0的偎牌变跑
    if not bFind then
        for nIndex, tWeave in ipairs(self.tCardInfo) do
            if tWeave.nWeaveKind == G_GameDefine.ACK_WEI and tWeave.nCenterCard == 0 then
                self.tCardInfo[nIndex].nWeaveKind = G_GameDefine.ACK_PAO
                self.tCardInfo[nIndex].tCardData = {nCard, nCard, nCard, nCard}
                bFind = true
                break
            end
        end
    end

    -- 显示牌
    self:showCard()
end

-- 碰变跑
function M:onPengToPao(nCard)
    -- 从碰牌中找变跑
    for nIndex, tWeave in ipairs(self.tCardInfo) do
        if tWeave.nWeaveKind == G_GameDefine.ACK_PENG and tWeave.nCenterCard == nCard then
            self.tCardInfo[nIndex].nWeaveKind = G_GameDefine.ACK_PAO
            table.insert(self.tCardInfo[nIndex].tCardData , nCard)
            break
        end
    end

    -- 显示牌
    self:showCard()
end

-- 显示牌
function M:showCard()
    local nCardPoint = self.tCardPoint[self.nLocalSeat]
    local nCardDir = self.tCardDir[self.nLocalSeat]
    self.tCardNode:removeAllChildren()
    for nLine, tWeave in ipairs(self.tCardInfo) do
        for nCol, nCenterCard in ipairs(tWeave.tCardData) do 
            local szFileName = "s"..nCenterCard..".png"
            local pGameCard = GameCard:create(szFileName)
            local nPoint = cc.p(nCardPoint.nPonX + (nLine - 1) * nCardDir.nWidth, nCardPoint.nPonY + (nCol - 1) * nCardDir.nHegiht)
            pGameCard:setPosition(nPoint)
            self.tCardNode:addChild(pGameCard)
        end
    end
end

-- 获取胡息
function M:getCardHuXi()
    local nHuXi = 0
    for _, tWeave in ipairs(self.tCardInfo) do
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
        end
    end

    return nHuXi
end

return M