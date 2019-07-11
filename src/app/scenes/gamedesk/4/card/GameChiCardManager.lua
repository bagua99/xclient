
local M = class("GameChiCardManager", function()
    return ccui.Layout:create()
end)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameCard")

local bit = require ("bit")

function M:create()
    local view = M.new()
    view:onCreate()
    return view
end

function M:onCreate()
    -- 牌信息
    self.tCardData = {}

    self.tCardLayout = {}
    -- 创建3个Layout
    for i = 1, 3 do
        self.tCardLayout[i] = ccui.Layout:create()
        self:addChild(self.tCardLayout[i])
    end

    self.nButtonPointX = 100
    self.nButtonPointY = 500

    self.nCardPointX = 45
    self.nCardPointY = 200
    self.nCardWidth = 42
    self.nCardHeigh = 42
end

-- 是否有效扑克
function M:isValidCard(nCardData)
    return nCardData >= 1 and nCardData <= G_GameDefine.MAX_CARD
end

-- 吃牌判断
function M:getActionChiCard(tCardData, nCurrentCard)
    local r = {}
    -- 效验扑克
    if not self:isValidCard(nCurrentCard) then
        return r
    end

    -- 牌数判断
    if tCardData[nCurrentCard] >= 3 then
        return r
    end

    --大小搭吃
    local nReverseCard = nCurrentCard > 10 and nCurrentCard - 10 or nCurrentCard + 10
    if tCardData[nCurrentCard] >= 1 and tCardData[nReverseCard] >= 1 and tCardData[nReverseCard] <= 2 then
        -- 构造扑克
        local tTempCardData = {}
        for k, v in ipairs(tCardData) do
            tTempCardData[k] = v
        end

        --删除扑克
        tTempCardData[nCurrentCard] = tTempCardData[nCurrentCard] - 1
        tTempCardData[nReverseCard] = tTempCardData[nReverseCard] - 1

        --提取判断
        local data = {}
        table.insert(data, {
            nCenterCard = nCurrentCard,
            nChiKind = nCurrentCard <= 10 and G_GameDefine.CK_XXD or G_GameDefine.CK_XDD,
            tCardData =
            {
                nCurrentCard,
                nCurrentCard,
                nReverseCard,
            },
        })

        while tTempCardData[nCurrentCard] > 0 do
            local tTakeOut = self:takeOutChiCard(tTempCardData,nCurrentCard)
            if tTakeOut.nChiKind ~= G_GameDefine.CK_NULL then
                table.insert(data, tTakeOut)
            else
                break
            end
        end

        if tTempCardData[nCurrentCard] == 0 then
            for k, v in pairs(data) do
                table.insert(r, v)
            end
        end
    end

    -- 大小搭吃
    if tCardData[nReverseCard] == 2 then
        -- 构造扑克
        local tTempCardData = {}
        for k, v in ipairs(tCardData) do
            tTempCardData[k] = v
        end

        --删除扑克
        tTempCardData[nReverseCard] = tTempCardData[nReverseCard] - 2

        --提取判断
        local data = {}
        table.insert(data, {
            nCenterCard = nCurrentCard,
            nChiKind = nCurrentCard <= 10 and G_GameDefine.CK_XDD or G_GameDefine.CK_XXD,
            tCardData =
            {
                nCurrentCard,
                nReverseCard,
                nReverseCard,
            },
        })

        while tTempCardData[nCurrentCard] > 0 do
            local tTakeOut = self:takeOutChiCard(tTempCardData,nCurrentCard)
            if tTakeOut.nChiKind ~= G_GameDefine.CK_NULL then
                table.insert(data, tTakeOut)
            else
                break
            end
        end

        if tTempCardData[nCurrentCard] == 0 then
            for k, v in pairs(data) do
                table.insert(r, v)
            end
        end
    end

    -- 二七十吃
    local nCardValue = nCurrentCard
    if nCardValue > 10 then
        nCardValue = nCurrentCard - 10
    end
    if nCardValue == 2 or nCardValue == 7 or nCardValue == 10 then
        -- 变量定义
        local tExcursion = {2,7,10}
        local nInceptIndex = 0
        if nCurrentCard > 10 then
            nInceptIndex = 10
        end

        -- 类型判断
        local nExcursionIndex = 1
        for i=1, #tExcursion  do
            local nIndex = nInceptIndex + tExcursion[i]
            if nIndex ~= nCurrentCard and (tCardData[nIndex] == 0 or tCardData[nIndex] >= 3) then
                break
            end
            nExcursionIndex = i
        end

        -- 提取判断
        if nExcursionIndex == #tExcursion then
            -- 构造扑克
            local tTempCardData = {}
            for k, v in ipairs(tCardData) do
                tTempCardData[k] = v
            end

            --删除扑克
            for j=1 , #tExcursion do
                local nIndex = nInceptIndex + tExcursion[j]
                if nIndex ~= nCurrentCard then
                    tTempCardData[nIndex] = tTempCardData[nIndex] - 1
                end
            end

            --提取判断
            local data = {}
            table.insert(data, {
                nCenterCard = nCurrentCard,
                nChiKind = G_GameDefine.CK_EQS,
                tCardData =
                {
                    nInceptIndex+tExcursion[1],
                    nInceptIndex+tExcursion[2],
                    nInceptIndex+tExcursion[3],
                },
            })

            while tTempCardData[nCurrentCard] > 0 do
                local tTakeOut = self:takeOutChiCard(tTempCardData,nCurrentCard)
                if tTakeOut.nChiKind ~= G_GameDefine.CK_NULL then
                    table.insert(data, tTakeOut)
                else
                    break
                end
            end

            if tTempCardData[nCurrentCard] == 0 then
                for k, v in pairs(data) do
                    table.insert(r, v)
                end
            end
        end
    end

    --顺子类型
    local tExcursion = {1,2,3}
    for i=1, #tExcursion do
        local nValueIndex = nCurrentCard
        if nCurrentCard > 10 then
            nValueIndex = nCurrentCard - 10
        end

        if nValueIndex >= tExcursion[i] and nValueIndex - tExcursion[i] <= 7 then
            --索引定义
            local nFirstIndex = nCurrentCard - tExcursion[i]
            --吃牌判断
            local nExcursionIndex = 0
            for j=1, 3 do
                local nIndex = nFirstIndex + j
                if nIndex ~= nCurrentCard and (tCardData[nIndex] == 0 or tCardData[nIndex] >= 3) then
                    break
                end
                nExcursionIndex = j
            end

            --提取判断
            if nExcursionIndex == #tExcursion then
                -- 构造扑克
                local tTempCardData = {}
                for k, v in ipairs(tCardData) do
                    tTempCardData[k] = v
                end

                --删除扑克
                for j=1, 3 do
                    local nIndex = nFirstIndex + j
                    if nIndex ~= nCurrentCard then
                        tTempCardData[nIndex] = tTempCardData[nIndex] - 1
                    end
                end

                local nChiKind ={G_GameDefine.CK_LEFT, G_GameDefine.CK_CENTER, G_GameDefine.CK_RIGHT}
                --提取判断
                local data = {}
                table.insert(data, {
                    nCenterCard = nCurrentCard,
                    nChiKind = nChiKind[i],
                    tCardData =
                    {
                        nFirstIndex+1,
                        nFirstIndex+2,
                        nFirstIndex+3,
                    },
                })

                while tTempCardData[nCurrentCard] > 0 do
                    local tTakeOut = self:takeOutChiCard(tTempCardData,nCurrentCard)
                    if tTakeOut.nChiKind ~= G_GameDefine.CK_NULL then
                        table.insert(data, tTakeOut)
                    else
                        break
                    end
                end

                if tTempCardData[nCurrentCard] == 0 then
                    for k, v in pairs(data) do
                        table.insert(r, v)
                    end
                end
            end
        end
    end

    return r
end

-- 提取吃牌
function M:takeOutChiCard(tCardData, nCurrentCard)
    local r =
    {
        nChiKind = G_GameDefine.CK_NULL,
        nCenterCard = nCurrentCard,
        tCardData = {},
    }
    -- 效验扑克
    if not self:isValidCard(nCurrentCard) then
        return r
    end

    -- 三牌判断
    if tCardData[nCurrentCard] >= 3 then
        return r
    end

    -- 大小搭吃
    local nReverseCard = nCurrentCard > 10 and nCurrentCard - 10 or nCurrentCard + 10
    if tCardData[nCurrentCard] >= 2 and tCardData[nReverseCard] >= 1 and tCardData[nReverseCard] <= 2 then
        -- 删除扑克
        tCardData[nCurrentCard] = tCardData[nCurrentCard] - 2
        tCardData[nReverseCard] = tCardData[nReverseCard] - 1

        -- 设置结果
        r.nChiKind = nCurrentCard <= 10 and G_GameDefine.CK_XXD or G_GameDefine.CK_XDD
        r.tCardData =
        {
            nCurrentCard,
            nCurrentCard,
            nReverseCard,
        }
        return r
    end

    -- 大小搭吃
    if tCardData[nReverseCard] == 2 and tCardData[nCurrentCard] >= 1 and tCardData[nCurrentCard] <= 2 then
        --删除扑克
        tCardData[nCurrentCard] = tCardData[nCurrentCard] - 1
        tCardData[nReverseCard] = tCardData[nReverseCard] - 2

         -- 设置结果
        r.nChiKind = nCurrentCard <= 10 and G_GameDefine.CK_XDD or G_GameDefine.CK_XXD
        r.tCardData =
        {
            nCurrentCard,
            nReverseCard,
            nReverseCard,
        }
        return r
    end

    -- 二七十吃
    local nCardValue = nCurrentCard
    if nCardValue > 10 then
        nCardValue = nCurrentCard - 10
    end
    if nCardValue == 2 or nCardValue == 7 or nCardValue == 10 then
        --变量定义
        local tExcursion = {2,7,10}
        local nInceptIndex = 0
        if nCurrentCard > 10 then
            nInceptIndex = 10
        end

        --类型判断
        local nExcursionIndex = 1
        for i=1, #tExcursion  do
            local nIndex = nInceptIndex + tExcursion[i]
            if tCardData[nIndex] == 0 or (nIndex ~= nCurrentCard and tCardData[nIndex] >= 3) then
                break
            end
            nExcursionIndex = i
        end

        --成功判断
        if nExcursionIndex == #tExcursion then
            --删除扑克
            tCardData[nInceptIndex+tExcursion[1]] = tCardData[nInceptIndex+tExcursion[1]] - 1
            tCardData[nInceptIndex+tExcursion[2]] = tCardData[nInceptIndex+tExcursion[2]] - 1
            tCardData[nInceptIndex+tExcursion[3]] = tCardData[nInceptIndex+tExcursion[3]] - 1

            -- 设置结果
            r.nChiKind = G_GameDefine.CK_EQS
            r.tCardData =
            {
                nInceptIndex+tExcursion[1],
                nInceptIndex+tExcursion[2],
                nInceptIndex+tExcursion[3],
            }
            return r
        end
    end

    --顺子判断
    local tExcursion = {1,2,3}
    for i=1, #tExcursion do
        local nValueIndex = nCurrentCard
        if nCurrentCard > 10 then
            nValueIndex = nCurrentCard - 10
        end
        if nValueIndex >= tExcursion[i] and nValueIndex - tExcursion[i] <= 7 then
            --索引定义
            local nFirstIndex = nCurrentCard - tExcursion[i] + 1

            local bFind = true
            if tCardData[nFirstIndex] == 0 or (nFirstIndex ~= nCurrentCard and tCardData[nFirstIndex] >= 3) then
                bFind = false
            end
            if tCardData[nFirstIndex+1] == 0 or (nFirstIndex+1 ~= nCurrentCard and tCardData[nFirstIndex+1] >= 3) then
                bFind = false
            end
            if tCardData[nFirstIndex+2] == 0 or (nFirstIndex+2 ~= nCurrentCard and tCardData[nFirstIndex+2] >= 3) then
                bFind = false
            end

            if bFind then
                --删除扑克
                tCardData[nFirstIndex] = tCardData[nFirstIndex] - 1
                tCardData[nFirstIndex+1] = tCardData[nFirstIndex+1] - 1
                tCardData[nFirstIndex+2] = tCardData[nFirstIndex+2] - 1

                local nChiKind ={G_GameDefine.CK_LEFT, G_GameDefine.CK_CENTER, G_GameDefine.CK_RIGHT}
                -- 设置结果
                r.nChiKind = nChiKind[i]
                r.tCardData =
                {
                    nFirstIndex,
                    nFirstIndex+1,
                    nFirstIndex+2,
                }
                return r
            end
        end
    end

    return r
end

function M:initCard(tCardData, nCurrentCard)
    self.tChoose = {}
    for k, v in ipairs(tCardData) do
        self.tCardData[k] = v
    end
    
    for _, pCardLayout in ipairs(self.tCardLayout) do
        pCardLayout:removeAllChildren()
    end
    self:setCard(self.tCardData, nCurrentCard, 1)
end

function M:setCard(tCardData, nCurrentCard, nLayoutCount)
    local tChiCard = self:getActionChiCard(tCardData, nCurrentCard)
    if #tChiCard <= 0 or self.tCardData[nCurrentCard] < nLayoutCount - 1 then
        local nChooseCount = #self.tChoose
        if nChooseCount <= 0 then
            return
        end

        for _, pCardLayout in ipairs(self.tCardLayout) do
            pCardLayout:removeAllChildren()
        end
        
        local nChiKind = 0
        for nIndex, data in ipairs(self.tChoose) do
            nChiKind = nChiKind + bit.lshift(data.nChiKind, (nIndex - 1) * 8)
        end
        G_DeskScene.GameDeskLayer:OperateChi(nChiKind)
        return
    end

    for nChooseIndex = nLayoutCount, 3 do
        self.tCardLayout[nChooseIndex]:removeAllChildren()
    end

    local tCardInfo = {}
    for _, data in ipairs(tChiCard) do
        tCardInfo[data.nChiKind] = data
    end
    
    local nCount = 0
    for _, data in pairs(tCardInfo) do
        nCount = nCount + 1
        local szButtonFileName = "nxphz_OutCardBg.png"
        local pButton = ccui.Button:create(szButtonFileName, szButtonFileName, "", ccui.TextureResType.plistType)
        pButton:setTag(nCount)
        local nButtonPoint = cc.p((nLayoutCount-1)*300 + self.nButtonPointX + nCount * 100, self.nButtonPointY)
        pButton:setPosition(nButtonPoint)

        for n, nCard in ipairs(data.tCardData) do
            local szFileName = "s"..nCard..".png"
            local pGameCard = GameCard:create(szFileName)
            local nPoint = cc.p(self.nCardPointX, self.nCardPointY - n * self.nCardHeigh)
            pGameCard:setPosition(nPoint)
            pButton:addChild(pGameCard)
        end
        pButton:addTouchEventListener(function(sender, event) 
            if event == ccui.TouchEventType.ended then
                -- 设置颜色
                local nTag = sender:getTag()
                local tChildren = self.tCardLayout[nLayoutCount]:getChildren()
                for _, var in ipairs(tChildren) do
                    if nTag == var:getTag() then
                        var:setColor(cc.c3b(255, 0, 0))
                    else
                        var:setColor(cc.c3b(255, 255, 255))
                    end
                end
                
                local tTempCardData = {}
                for nCard, nCount in ipairs(self.tCardData) do
                    tTempCardData[nCard] = nCount
                end
                self.tChoose[nLayoutCount] = data
                for nChooseIndex = 1, 3 do
                    if nChooseIndex <= nLayoutCount then
                        -- 移除选择牌
                        for _, nCard in ipairs(self.tChoose[nChooseIndex].tCardData or {}) do
                            tTempCardData[nCard] = tTempCardData[nCard] - 1
                        end
                    else
                        -- 置空
                        self.tChoose[nChooseIndex] = nil
                    end
                end
                self:setCard(tTempCardData, nCurrentCard, nLayoutCount+1)
            end
        end)
        self.tCardLayout[nLayoutCount]:addChild(pButton)
    end
end

-- 清除选择牌
function M:clearChooseCard()
    for _, pCardLayout in ipairs(self.tCardLayout) do
        pCardLayout:removeAllChildren()
    end
end

return M