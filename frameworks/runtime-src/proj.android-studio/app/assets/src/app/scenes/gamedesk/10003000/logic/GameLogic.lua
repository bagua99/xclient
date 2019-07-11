
local GameLogic = class("GameLogic")

local bit = require("bit")

--[[
//扑克数据
const BYTE	CGameLogic::m_cbCardData[FULL_COUNT] =
{
    0x01,     0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,		//方块 A - K
    0x11,	  0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,		//梅花 A - K
    0x21,	  0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,		//红桃 A - K
		 0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,		//黑桃 A - K
};
--]]

-- 数值掩码
local MASK_COLOR =              0xF0							    -- 花色掩码
local MASK_VALUE =				0x0F							    -- 数值掩码

-- 逻辑类型
CT_ERROR =				0									-- 错误类型
CT_SINGLE =				1									-- 单牌类型
CT_DOUBLE =				2									-- 对牌类型
CT_THREE =				3									-- 三条类型
CT_SINGLE_LINE =		4									-- 单连类型
CT_DOUBLE_LINE =		5									-- 对连类型
CT_THREE_LINE =			6									-- 三连类型
CT_THREE_TAKE_ONE =		7									-- 三带一单
CT_THREE_TAKE_TWO =		8									-- 三带一对,三带2
CT_BOMB_CARD =			9									-- 炸弹类型

local byIndexCount =            5                                   -- 分析数量索引

-- 构造函数
function GameLogic:ctor()

end

-- 获取数值
function GameLogic:getCardValue(byCardData)
    return bit.band(byCardData, MASK_VALUE)
end

-- 获取花色
function GameLogic:getCardColor(byCardData)
    return bit.band(byCardData, MASK_COLOR)
end

-- 逻辑数值
function GameLogic:getCardLogicValue(byCardData)

    -- 扑克属性
    local byCardColor = self:getCardColor(byCardData)
    local byCardValue = self:getCardValue(byCardData)
    
    if byCardValue <= 0 then
        return 0
    end
    
    -- 转换数值
    if byCardColor == 0x40 then
        return byCardValue+2
    end

    if byCardValue <= 2 then
        return byCardValue+13
    end

    return byCardValue
end

-- 排列扑克
function GameLogic:sortCardList(tCardData, byCardCount)

    -- 数目过虑
    if byCardCount == 0 then
        return
    end
    
    -- 转换数值
    local tSortValue = {}
    for i=1, byCardCount do
		tSortValue[i] = self:getCardLogicValue(tCardData[i])
    end
    
    -- 排序操作
    local bSorted = true
    local bySwitchData = 0
    local byLast = byCardCount-1
    while (bSorted)
    do
        bSorted = false
        for i=1, byLast do
            if ((tSortValue[i]<tSortValue[i+1]) or ((tSortValue[i]==tSortValue[i+1]) and (tCardData[i]<tCardData[i+1]))) then
                -- 设置标志
                bSorted = true
                
                -- 扑克数据
                bySwitchData = tCardData[i]
                tCardData[i] = tCardData[i+1]
                tCardData[i+1] = bySwitchData
                
                -- 排序权位
                bySwitchData = tSortValue[i]
                tSortValue[i] = tSortValue[i+1]
                tSortValue[i+1] = bySwitchData
            end
        end
        byLast = byLast - 1
    end
end

-- 删除扑克
function GameLogic:removeCard(tCardData, byCardCount, tRemoveCard, byRemoveCount)

    -- 检验数据
    if byCardCount < byRemoveCount then
        return false, nil
    end
    
    -- 定义变量
    local byDeleteCount = 0
    local tTempCardData = tCardData     -- 浅拷贝
    
    -- 置零扑克
    for i=1, byRemoveCount do
        for j=1, byCardCount do
            if tRemoveCard[i] == tTempCardData[j] then
                byDeleteCount = byDeleteCount + 1
                tTempCardData[j] = 0
                break
            end
        end
    end
    if byDeleteCount ~= byRemoveCount then
        return false, nil
    end
    
    -- 清理扑克
    local tEndCardData = {}
    local byEndCardIndex = 1
    for i=1, byCardCount do
        if tTempCardData[i] ~= 0 then
            tEndCardData[byEndCardIndex] = tTempCardData[i]
            byEndCardIndex = byEndCardIndex + 1
        end
    end
    
    return true, tEndCardData
end

-- 获取类型
function GameLogic:getCardType(tCardData, byCardCount)

	-- 排列扑克
	self:sortCardList(tCardData, byCardCount)

    -- 简单牌型
    if byCardCount == 0 then
        return CT_ERROR
    elseif byCardCount == 1 then
        return CT_SINGLE
    elseif byCardCount == 2 then
        if (self:getCardLogicValue(tCardData[1]) == self:getCardLogicValue(tCardData[2])) then
            return CT_DOUBLE
        end
        
        return CT_ERROR
    end
    
    -- 分析扑克
    local tAnalyseResult = {}
    self:analysebCardData(tCardData, byCardCount, tAnalyseResult)
    
    -- 四牌判断
    if tAnalyseResult.byBlockCount[4] ~= nil and tAnalyseResult.byBlockCount[4] > 0 then
        -- 牌型判断
        if tAnalyseResult.byBlockCount[4] == 1 and byCardCount == 4 then
            return CT_BOMB_CARD
        end
        
        return CT_ERROR
    end
    
    -- 三牌判断
    if tAnalyseResult.byBlockCount[3] ~= nil and tAnalyseResult.byBlockCount[3] > 0 then

        local byMaxLineCount = 1
		local byLineCount = 1
        -- 连牌判断
        if tAnalyseResult.byBlockCount[3] > 1 then
            -- 连牌判断
            for i=1, tAnalyseResult.byBlockCount[3] do
				-- 变量定义
				local byCardData = tAnalyseResult.tCardData[3][i*3]
				local byFirstLogicValue = self:getCardLogicValue(byCardData)

				-- 错误过虑
				if byFirstLogicValue >= 15 then
					local byCardData = tAnalyseResult.tCardData[3][i*3]
					byFirstLogicValue = self:getCardLogicValue(byCardData)
					byLineCount = 1
                else
                    local byNextIndex = i+1
                    if byNextIndex > tAnalyseResult.byBlockCount[3] then
                        break
                    end

                    byCardData = tAnalyseResult.tCardData[3][byNextIndex*3];
                    if byFirstLogicValue == self:getCardLogicValue(byCardData) + 1 then
                        byLineCount = byLineCount + 1
                        -- 设置最大
                        if byLineCount >= byMaxLineCount then
                            byMaxLineCount = byLineCount
                        end
                    else
                        local byCardData = tAnalyseResult.tCardData[3][i*3]
                        byFirstLogicValue = self:getCardLogicValue(byCardData)
                        byLineCount = 1
                    end
				end
            end

			if byMaxLineCount == 1 then
				return CT_ERROR
            end

			-- 牌形判断
			if byMaxLineCount * 3 == byCardCount then
				return CT_THREE_LINE
            elseif byMaxLineCount * 4 == byCardCount then
				return CT_THREE_TAKE_ONE
			elseif byMaxLineCount * 5 == byCardCount then
				return CT_THREE_TAKE_TWO
			else
				-- 比如3个777，888，999，带个单，可以当888，999带4个出，严谨还要判断-2，-3，这种先不处理
				if (byMaxLineCount - 1) * 5 == byCardCount then
					return CT_THREE_TAKE_TWO
                else
                    return CT_ERROR
				end
			end
        elseif byCardCount == 3 then
			return CT_THREE
        end
        
        -- 牌形判断
        if byMaxLineCount*3 == byCardCount then
            return CT_THREE_LINE
        elseif byMaxLineCount*4==byCardCount then
            return CT_THREE_TAKE_ONE
        elseif byMaxLineCount*5==byCardCount then
            return CT_THREE_TAKE_TWO
        end
        
        return CT_ERROR
    end
    
    -- 两张类型
    if tAnalyseResult.byBlockCount[2] ~= nil and tAnalyseResult.byBlockCount[2] >= 2 then
        -- 变量定义
        local byCardData = tAnalyseResult.tCardData[2][1]
        local byFirstLogicValue = self:getCardLogicValue(byCardData)
        
        -- 错误过虑
        if byFirstLogicValue >= 15 then
            return CT_ERROR
        end
        
        -- 连牌判断
        for i=1, tAnalyseResult.byBlockCount[2] do
            local byCardData = tAnalyseResult.tCardData[2][(i-1)*2+1]
			if byFirstLogicValue ~= self:getCardLogicValue(byCardData) + (i-1) then
				return CT_ERROR
            end
        end
        
        -- 二连判断
        if tAnalyseResult.byBlockCount[2]*2 == byCardCount then
            return CT_DOUBLE_LINE
        end
        
        return CT_ERROR
    end
    
    -- 单张判断
    if tAnalyseResult.byBlockCount[1] ~= nil and tAnalyseResult.byBlockCount[1] >= 5 and tAnalyseResult.byBlockCount[1] == byCardCount then
        -- 变量定义
        local byCardData = tAnalyseResult.tCardData[1][1]
        local byFirstLogicValue = self:getCardLogicValue(byCardData)
        
        -- 错误过虑
        if byFirstLogicValue >= 15 then
            return CT_ERROR
        end
        
        -- 连牌判断
        for i=1, tAnalyseResult.byBlockCount[1] do
            local byCardData=tAnalyseResult.tCardData[1][i]
			if byFirstLogicValue ~= self:getCardLogicValue(byCardData) + (i-1) then
				return CT_ERROR
            end
        end
        
        return CT_SINGLE_LINE
    end
    
    return CT_ERROR
end

-- 分析扑克
function GameLogic:analysebCardData(tCardData, byCardCount, tAnalyseResult)
    
    -- 扑克分析
    local byCardCountIndex = 1
    for i=1, byCardCount do

        if byCardCountIndex > byCardCount then
            break
        end
        -- 变量定义
        local bySameCount = 1
        local byLogicValue = self:getCardLogicValue(tCardData[byCardCountIndex])
        
        -- 搜索同牌
        for j=byCardCountIndex+1, byCardCount do
            -- 获取扑克
            if self:getCardLogicValue(tCardData[j]) ~= byLogicValue then
                break
            end
            
            -- 设置变量
            bySameCount = bySameCount + 1
        end
        
        -- 设置结果
        if tAnalyseResult.byBlockCount == nil then
            tAnalyseResult.byBlockCount = {}
        end
        if tAnalyseResult.tCardData == nil then
            tAnalyseResult.tCardData = {}
        end
        if tAnalyseResult.tCardData[bySameCount] == nil then
            tAnalyseResult.tCardData[bySameCount] = {}
        end
        if tAnalyseResult.byBlockCount[bySameCount] == nil then
            tAnalyseResult.byBlockCount[bySameCount] = 1
        else
            tAnalyseResult.byBlockCount[bySameCount] = tAnalyseResult.byBlockCount[bySameCount] + 1
        end
        local byIndex = tAnalyseResult.byBlockCount[bySameCount] - 1
		for j=1, bySameCount do
			tAnalyseResult.tCardData[bySameCount][byIndex*bySameCount+j] = tCardData[byCardCountIndex+j-1]
		end
        
        -- 设置索引
        byCardCountIndex = byCardCountIndex + bySameCount
    end
end

-- 对比扑克
function GameLogic:compareCard(tFirstCard, byFirstCount, tNextCard, byNextCount)

    -- 获取类型
    local byNextType = self:getCardType(tNextCard, byNextCount)
    local byFirstType = self:getCardType(tFirstCard, byNextCount)
    
    -- 类型判断
    if byNextType == CT_ERROR then
        return false
    end
    
    -- 炸弹判断
    if byFirstType ~= CT_BOMB_CARD and byNextType == CT_BOMB_CARD then
        return true
    end
    if byFirstType == CT_BOMB_CARD and byNextType ~= CT_BOMB_CARD then
        return false
    end
    
    -- 规则判断
    if byFirstType ~= byNextType or cbFirstCount ~= cbNextCount then
        return false
    end

    local compare1 = (function(tFirstCard, tNextCard, byFirstCount, byNextCount)
        -- 获取数值
        local byFirstLogicValue = self:getCardLogicValue(tFirstCard[1])
        local byNextLogicValue = self:getCardLogicValue(tNextCard[1])
        
        -- 对比扑克
        return byFirstLogicValue < byNextLogicValue
    end)

    local compare2 = (function(tFirstCard, tNextCard, byFirstCount, byNextCount)
        -- 分析扑克
        local tFirstResult = {}
        local tNextResult = {}
        self:analysebCardData(tFirstCard, byFirstCount, tFirstResult)
        self:analysebCardData(tNextCard, byNextCount, tNextResult)

        if tFirstResult.tCardData[3][1] == nil or tNextResult.tCardData[3][1] == nil then
            return false
        end

        -- 获取数值
        local byFirstLogicValue = self:getCardLogicValue(tFirstResult.tCardData[3][1])
        local byNextLogicValue = self:getCardLogicValue(tNextResult.tCardData[3][1])

        -- 对比扑克
        return byFirstLogicValue < byNextLogicValue
    end)
    
    local compareWwitch = 
    {
        [CT_SINGLE]             = compare1,
        [CT_DOUBLE]             = compare1,
        [CT_THREE]              = compare1,
        [CT_SINGLE_LINE]        = compare1,
        [CT_DOUBLE_LINE]        = compare1,
        [CT_THREE_LINE]         = compare1,
        [CT_BOMB_CARD]          = compare1,
        [CT_THREE_TAKE_ONE]     = compare2,
        [CT_THREE_TAKE_TWO]     = compare2,
    }
    local func = compareWwitch[byNextType]
    if func ~= nil then
        local nResult = func(tFirstCard, tNextCard, byFirstCount, byNextCount)
        return nResult
    end
    
    return false
end

-- 构造扑克
function GameLogic:makeCardData(byValueIndex, byColorIndex)
    return bit.lshift(byColorIndex, 4) + byValueIndex
end

-- 分析分布
function GameLogic:analysebDistributing(tCardData, byCardCount, tDistributing)
    
    -- 设置变量
    for i=1, byCardCount do
        if tCardData[i] ~= 0 then

            -- 获取属性
            local byCardColor = self:getCardColor(tCardData[i])
            local byCardValue = self:getCardValue(tCardData[i])
        
            if tDistributing.byCardCount == nil then
                tDistributing.byCardCount = 0
            end
            -- 分布信息
            tDistributing.byCardCount = tDistributing.byCardCount + 1;

            if tDistributing.byDistributing == nil then
                tDistributing.byDistributing = {}
            end
            if tDistributing.byDistributing[byCardValue] == nil then
                tDistributing.byDistributing[byCardValue] = {}
            end
            if tDistributing.byDistributing[byCardValue][byIndexCount] == nil then
                tDistributing.byDistributing[byCardValue][byIndexCount] = 0
            end
            tDistributing.byDistributing[byCardValue][byIndexCount] = tDistributing.byDistributing[byCardValue][byIndexCount] + 1
            -- 从1开始
            local byColorIndex = bit.rshift(byCardColor,4) + 1
             if tDistributing.byDistributing[byCardValue][byColorIndex] == nil then
                tDistributing.byDistributing[byCardValue][byColorIndex] = 0
            end
            tDistributing.byDistributing[byCardValue][byColorIndex] = tDistributing.byDistributing[byCardValue][byColorIndex] + 1
        end
    end
end

-- 出牌搜索
function GameLogic:searchOutCard(tCardData, byCardCount, tTurnCardData, byTurnCardCount, tSearchCardResult)

    -- 变量定义
    local byResultCount = 0
    -- 临时结果数组
    local tTempSearchCardResult = {}
    
    -- 排列扑克
    self:sortCardList(tCardData, byCardCount)
	-- 排列扑克
	self:sortCardList(tTurnCardData, byTurnCardCount)
    
    -- 获取类型
    local byTurnOutType = self:getCardType(tTurnCardData, byTurnCardCount)
    
    -- 出牌分析
    -- 错误类型
    if byTurnOutType == CT_ERROR then
    
        -- 是否一手出完
        if self:getCardType(tCardData, byCardCount) ~= CT_ERROR then

            byResultCount = byResultCount + 1

            if tSearchCardResult.byCardCount == nil then
                tSearchCardResult.byCardCount = {}
            end
            tSearchCardResult.byCardCount[byResultCount] = byCardCount

            if tSearchCardResult.byResultCard == nil then
                tSearchCardResult.byResultCard = {}
            end
            for i=1, byCardCount do
                tSearchCardResult.byResultCard[i] = tCardData[i]
            end
        end
            
        tSearchCardResult.bySearchCount = byResultCount
        return byResultCount
    -- 单牌类型,对牌类型,三条类型
    elseif byTurnOutType == CT_SINGLE or byTurnOutType == CT_DOUBLE or byTurnOutType == CT_THREE then 

        -- 变量定义
        local byReferCard = tTurnCardData[1]
        local bySameCount = 1
        if byTurnOutType == CT_DOUBLE then
            bySameCount = 2
        elseif byTurnOutType == CT_THREE then
            bySameCount = 3
        end
            
        -- 搜索相同牌
        byResultCount = self:searchSameCard(tCardData, byCardCount, byReferCard, bySameCount, tSearchCardResult)
    -- 单连类型,对连类型,三连类型
    elseif byTurnOutType == CT_SINGLE_LINE or byTurnOutType == CT_DOUBLE_LINE or byTurnOutType == CT_THREE_LINE then

        -- 变量定义
        local byBlockCount = 1
        if byTurnOutType == CT_DOUBLE_LINE then
            byBlockCount = 2
        elseif byTurnOutType == CT_THREE_LINE then
            byBlockCount = 3
        end
            
        local byLineCount = byTurnCardCount/byBlockCount
        -- 搜索边牌
        byResultCount = self:searchLineCardType(tCardData, byCardCount, tTurnCardData[1], byBlockCount, byLineCount, tSearchCardResult)
    -- 三带一单,三带一对
    elseif byTurnOutType == CT_THREE_TAKE_ONE or byTurnOutType == CT_THREE_TAKE_TWO then
        
        if byCardCount >= byTurnCardCount then
            -- 如果是三带一或三带二
            if byTurnCardCount == 4 or byTurnCardCount == 5 then
                local byTakeCardCount = (byTurnOutType == CT_THREE_TAKE_ONE) and 1 or 2
                
                -- 搜索三带牌型
                byResultCount = self:searchTakeCardType(tCardData, byCardCount, tTurnCardData[3], 3, byTakeCardCount, tSearchCardResult)
            else
                -- 变量定义
                local byLineCount = byTurnCardCount / ((byTurnOutType == CT_THREE_TAKE_ONE) and 4 or 5)
                local byTakeCardCount = byTurnOutType == CT_THREE_TAKE_ONE and 1 or 2
                
                -- 搜索连牌
                byResultCount = self:searchLineCardType(tCardData, byCardCount, tTurnCardData[1], 3, byLineCount, tSearchCardResult)
                
                -- 提取带牌
                local bAllDistill = true
                for i=1, byResultCount do
                    local byResultIndex = byResultCount - i + 1
                    
                    -- 变量定义
                    local tTempCardData = tCardData     -- 浅拷贝
                    local byTempCardCount = byCardCount
                
                    local bRemove = false
                    -- 删除连牌
                    bRemove,tTempCardData =  self:removeCard(tTempCardData, byTempCardCount, tSearchCardResult.byResultCard[byResultIndex], tSearchCardResult.byCardCount[byResultIndex])
                    byTempCardCount = byTempCardCount - tSearchCardResult.byCardCount[byResultIndex]
                    
                    -- 分析牌
                    local tTempResult = {}
                    self:analysebCardData(tTempCardData, byTempCardCount, tTempResult)
                    
                    -- 提取牌
                    local tDistillCard = {}
                    local byDistillCount = 0
                    for j = 1, 4 do
                        if tTempResult.byBlockCount[j] ~= nil then
					        for k=1, tTempResult.byBlockCount[j] do
						        -- 从小到大
						        local byIndex = (tTempResult.byBlockCount[j] - k)*j

						        -- 这里j==1是单牌,j==2是对,j==3是3个,j==4是4个
						        if byDistillCount + j <= byTakeCardCount*byLineCount then
                                    for n=1, tTempResult.byBlockCount[j] do
                                        byDistillCount = byDistillCount + 1
                                        tDistillCard[byDistillCount] = tTempResult.tCardData[j][byIndex + n]
                                    end
						        else
							        local byMustCount = byDistillCount + j - byTakeCardCount*byLineCount
                                    for n=1, byIndex+byMustCount do
                                        byDistillCount = byDistillCount + 1
                                        tDistillCard[byDistillCount] = tTempResult.tCardData[j][byIndex+n]
                                    end
						        end

						        -- 提取完成
						        if byDistillCount == byTakeCardCount*byLineCount then
							        break
                                end
					        end
                        
                            -- 提取完成
                            if byDistillCount == byTakeCardCount*byLineCount then
                                break
                            end
                        end
                    end
                    
                    -- 提取完成
                    if byDistillCount == byTakeCardCount*byLineCount then
                        -- 复制带牌
                        local byCount = tSearchCardResult.byCardCount[byResultIndex]
                        for n=1,byDistillCount do
                            tSearchCardResult.byResultCard[byResultIndex][byCount+n] = tDistillCard[i]
                        end
                        tSearchCardResult.byCardCount[byResultIndex] = tSearchCardResult.byCardCount[byResultIndex] + byDistillCount
                    -- 否则删除连牌
                    else
                        bAllDistill = false
                        tSearchCardResult.byCardCount[byResultIndex] = 0
                    end
                end
                
                -- 整理组合
                if not bAllDistill then
                    tSearchCardResult.bySearchCount = byResultCount
                    byResultCount = 0
                    for i=1, tSearchCardResult.bySearchCount do
                        if tSearchCardResult.byCardCount[i] ~= 0 then

                            byResultCount = byResultCount + 1
                            tTempSearchCardResult.byCardCount[byResultCount] = tSearchCardResult.byCardCount[i]
                            tTempSearchCardResult.byResultCard[byResultCount] = tSearchCardResult.byResultCard[i]
                        end
                    end
                    tTempSearchCardResult.bySearchCount = byResultCount
                    tSearchCardResult = tTempSearchCardResult
                end
            end
        end
    end
    
    -- 搜索炸弹
    if byCardCount >= 4 then
        -- 变量定义
        local byReferCard = 0
        if byTurnOutType == CT_BOMB_CARD then
            byReferCard = tTurnCardData[1]
        end
        
        -- 搜索炸弹
        local byTempResultCount = self:searchSameCard(tCardData, byCardCount, byReferCard, 4, tTempSearchCardResult)
        for i=1, byTempResultCount do

            byResultCount = byResultCount + 1
            if tSearchCardResult.byCardCount == nil then
                tSearchCardResult.byCardCount = {}
            end
            if tSearchCardResult.byResultCard == nil then
                tSearchCardResult.byResultCard = {}
            end
            tSearchCardResult.byCardCount[byResultCount] = tTempSearchCardResult.byCardCount[i];
            tSearchCardResult.byResultCard[byResultCount] = tTempSearchCardResult.byResultCard[i]
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount;
    return byResultCount
end

-- 同牌搜索
function GameLogic:searchSameCard(tHandCardData, byHandCardCount, byReferCard, bySameCardCount, tSearchCardResult)

    -- 设置结果
    local byResultCount = 0
    
    -- 构造扑克
    local tCardData = tHandCardData
    local byCardCount = byHandCardCount
    
    -- 排列扑克
    self:sortCardList(tCardData, byCardCount)
    
    -- 分析扑克
    local tAnalyseResult = {}
    self:analysebCardData(tCardData, byCardCount, tAnalyseResult)
    
    local byReferLogicValue = (byReferCard == 0) and 0 or self:getCardLogicValue(byReferCard)
    for byBlockIndex=bySameCardCount, 4 do
        if tAnalyseResult.byBlockCount ~= nil and tAnalyseResult.byBlockCount[byBlockIndex] ~= nil then
            for i=1, tAnalyseResult.byBlockCount[byBlockIndex] do

                local byIndex = (tAnalyseResult.byBlockCount[byBlockIndex] - i)*byBlockIndex
                if self:getCardLogicValue(tAnalyseResult.tCardData[byBlockIndex][byIndex+1]) > byReferLogicValue then
                    -- 复制扑克
                    byResultCount = byResultCount + 1;

                    if tSearchCardResult.byResultCard == nil then
                        tSearchCardResult.byResultCard = {}
                    end
                    if tSearchCardResult.byCardCount == nil then
                        tSearchCardResult.byCardCount = {}
                    end
                    if tSearchCardResult.byResultCard[byResultCount] == nil then
                        tSearchCardResult.byResultCard[byResultCount] = {}
                    end
                    for n=1, bySameCardCount do
                        tSearchCardResult.byResultCard[byResultCount][n] = tAnalyseResult.tCardData[byBlockIndex][byIndex+n]
                    end
                    tSearchCardResult.byCardCount[byResultCount] = bySameCardCount
                end
            end
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount
    return byResultCount
end

-- 带牌类型搜索(三带一，四带一等)
function GameLogic:searchTakeCardType(tHandCardData, byHandCardCount, byReferCard, bySameCardCount, byTakeCardCount, tSearchCardResult)

    -- 设置结果
    local byResultCount = 0
    
    -- 效验
    if bySameCardCount ~= 3 and bySameCardCount ~= 4 then
        return byResultCount
    end
    if byTakeCardCount ~= 1 and byTakeCardCount ~= 2 then
        return byResultCount
    end
    
    -- 长度判断
    if (bySameCardCount == 4 and byHandCardCount < bySameCardCount + byTakeCardCount*2) or byHandCardCount < bySameCardCount + byTakeCardCount then
        return byResultCount
    end
    
    -- 构造扑克
    local tCardData = tHandCardData
    local byCardCount = byHandCardCount
    
    -- 排列扑克
    self:sortCardList(tCardData, byCardCount)
    
    -- 搜索同张
    local tSameCardResult = {};
    local bySameCardResultCount = self:searchSameCard(tCardData, byCardCount, byReferCard, bySameCardCount, tSameCardResult)
    
    if bySameCardResultCount > 0 then

        -- 分析扑克
        local tAnalyseResult = {}
        self:analysebCardData(tCardData, byCardCount, tAnalyseResult)
        
        -- 需要牌数
        local byNeedCount = bySameCardCount + byTakeCardCount;
        if bySameCardCount == 4 then
            byNeedCount = byNeedCount + byTakeCardCount
        end
        
        -- 提取带牌
        for i=1, bySameCardResultCount do

            local bMerge = false
            
            for j=1, 4 do
                if tAnalyseResult.byBlockCount[j] ~= nil then
                    for k=1, tAnalyseResult.byBlockCount[j] do
                        -- 从小到大
                        local byIndex = (tAnalyseResult.byBlockCount[j] - k)*j
                    
                        -- 过滤相同牌
                        if self:getCardValue(tSameCardResult.byResultCard[i][1]) ~= self:getCardValue(tAnalyseResult.tCardData[j][byIndex+1]) then

                            -- 复制带牌
                            local byCount = tSameCardResult.byCardCount[i]
					        --  这里j==1是单牌,j==2是对,j==3是3个,j==4是4个
					        if byCount + j <= byNeedCount then
                                for n=1,j  do
                                    tSameCardResult.byResultCard[i][byCount+n] = tAnalyseResult.tCardData[j][byIndex+n]
                                end
                                tSameCardResult.byCardCount[i] = tSameCardResult.byCardCount[i] + j;
					        else
						        local byMustCount = byCount + j - byNeedCount;
                                for n=1,byMustCount  do
                                    tSameCardResult.byResultCard[i][byCount+n] = tAnalyseResult.tCardData[j][byIndex+n]
                                end
                                tSameCardResult.byCardCount[i] = tSameCardResult.byCardCount[i] + byMustCount
					        end
                    
                            if tSameCardResult.byCardCount[i] >= byNeedCount then

                                byResultCount = byResultCount + 1

                                if tSearchCardResult.byResultCard == nil then
                                    tSearchCardResult.byResultCard = {}
                                end
                                if tSearchCardResult.byCardCount == nil then
                                    tSearchCardResult.byCardCount = {}
                                end
                                tSearchCardResult.byResultCard[byResultCount] = tSameCardResult.byResultCard[i]
                                tSearchCardResult.byCardCount[byResultCount] = tSameCardResult.byCardCount[i]
                    
                                bMerge = true
                                break;
                            end
                        end
                    end
                
                    if bMerge then
                        break
                    end
                end
            end
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount
    return byResultCount
end

-- 连牌搜索
function GameLogic:searchLineCardType(tHandCardData, byHandCardCount, byReferCard, byBlockCount, byLineCount, tSearchCardResult)

    -- 设置结果
    local byResultCount = 0
    
    -- 定义变量
    local byLessLineCount = 0
    if byLineCount == 0 then
        if byBlockCount == 1 then
            byLessLineCount = 5
        else
            byLessLineCount = 2
        end
    else
        byLessLineCount = byLineCount
    end
    
    local byReferIndex = 2
    if byReferCard ~= 0 then
        byReferIndex = self:getCardLogicValue(byReferCard) - byLessLineCount + 2
    end
    -- 超过A
    if byReferIndex + byLessLineCount > 14 then
        return byResultCount
    end
    
    -- 长度判断
    if byHandCardCount < byLessLineCount*byBlockCount then
        return byResultCount
    end
    
    -- 构造扑克
    local tCardData = tHandCardData
    local byCardCount = byHandCardCount
    
    -- 排列扑克
    self:sortCardList(tCardData, byCardCount)
    
    -- 分析扑克
    local tDistributing = {}
    self:analysebDistributing(tCardData, byCardCount, tDistributing)
    
    -- 搜索顺子
    local byTempLinkCount = 0
    -- 这里有个坑byValueIndex是属于for里面的变量,所有byLastValueIndex要重新赋值
    local byLastValueIndex = byReferIndex
    for byValueIndex=byReferIndex,13 do

        byLastValueIndex = byValueIndex

        local bContinue = true
        if tDistributing.byDistributing[byValueIndex] == nil then
            byTempLinkCount = 0
        elseif tDistributing.byDistributing[byValueIndex][byIndexCount] ~= nil then
            -- 继续判断
            if tDistributing.byDistributing[byValueIndex][byIndexCount] < byBlockCount then
                if byTempLinkCount < byLessLineCount then
                    byTempLinkCount = 0
                    bContinue = false
                else
                    byValueIndex = byValueIndex - 1 
                end
            else
                byTempLinkCount = byTempLinkCount + 1
                -- 寻找最长连
                if byLineCount == 0 then
                    bContinue = false
                end
            end
        
            if bContinue then
                if byTempLinkCount >= byLessLineCount then
            
                    byResultCount = byResultCount + 1

                    -- 复制扑克
                    local byCount = 0
                    local byTmpCount = 0
                    for byIndex = byValueIndex+1-byTempLinkCount, byValueIndex do
                        byTmpCount = 0
                        for byColorIndex=1, 4 do
                            if tDistributing.byDistributing[byValueIndex] == nil then
                                byTempLinkCount = 0
                            elseif tDistributing.byDistributing[byIndex][byColorIndex] ~= nil then
                                for byColorCount=1, tDistributing.byDistributing[byIndex][byColorIndex] do

                                    byCount = byCount + 1

                                    if tSearchCardResult.byResultCard == nil then
                                        tSearchCardResult.byResultCard = {}
                                    end
                                    if tSearchCardResult.byResultCard[byResultCount] == nil then
                                        tSearchCardResult.byResultCard[byResultCount] = {}
                                    end
                                    tSearchCardResult.byResultCard[byResultCount][byCount] = self:makeCardData(byIndex, byColorIndex-1)
                        
                                    byTmpCount = byTmpCount + 1
                                    if byTmpCount == byBlockCount then
                                        break
                                    end
                                end
                                if byTmpCount == byBlockCount then
                                    break
                                end
                            end
                        end
                    end
            
                    if tSearchCardResult.byCardCount == nil then
                        tSearchCardResult.byCardCount = {}
                    end
                    -- 设置变量
                    tSearchCardResult.byCardCount[byResultCount] = byCount
            
                    if byLineCount ~= 0 then
                        byTempLinkCount = byTempLinkCount - 1
                    else
                        byTempLinkCount = 0
                    end
                end
            end
        end
    end
    
    -- 特殊顺子
    if byTempLinkCount >= byLessLineCount-1 and byLastValueIndex == 13 then
        if (tDistributing.byDistributing[1] ~= nil and tDistributing.byDistributing[1][byIndexCount] >= byBlockCount) or byTempLinkCount >= byLessLineCount then
            byResultCount = byResultCount + 1
            if tSearchCardResult.byResultCard == nil then
                tSearchCardResult.byResultCard = {}
            end
            if tSearchCardResult.byResultCard[byResultCount] == nil then
                tSearchCardResult.byResultCard[byResultCount] = {}
            end

            -- 复制扑克
            local byCount = 0
            local byTmpCount = 0
            for byIndex=byLastValueIndex-byTempLinkCount+1, 13 do
                byTmpCount = 0
                for byColorIndex=1, 4 do
                    if tDistributing.byDistributing[byIndex] == nil then
                        byTempLinkCount = 0
                    elseif tDistributing.byDistributing[byIndex][byColorIndex] ~= nil then
                        for byColorCount=1, tDistributing.byDistributing[byIndex][byColorIndex] do
                            byCount = byCount + 1
                            tSearchCardResult.byResultCard[byResultCount][byCount] = self:makeCardData(byIndex, byColorIndex-1)
                        
                            byTmpCount = byTmpCount + 1
                            if byTmpCount == byBlockCount then
                                break
                            end
                        end
                        if byTmpCount == byBlockCount then
                            break
                        end
                    end
                end
            end
            -- 复制A
            if tDistributing.byDistributing[1][byIndexCount] >= byBlockCount then
                byTmpCount = 0
                for byColorIndex=1, 4 do
                    if tDistributing.byDistributing[1] == nil then
                        byTempLinkCount = 0
                    elseif tDistributing.byDistributing[1][byColorIndex] ~= nil then
                        for byColorCount=1, tDistributing.byDistributing[1][byColorIndex] do
                            byCount = byCount + 1
                            tSearchCardResult.byResultCard[byResultCount][byCount] = self:makeCardData(1, byColorIndex-1)
                        
                            byTmpCount = byTmpCount + 1
                            if byTmpCount == byBlockCount then
                                break
                            end
                        end
                        if byTmpCount == byBlockCount then
                            break
                        end
                    end
                end
            end
            
            if tSearchCardResult.byCardCount == nil then
                tSearchCardResult.byCardCount = {}
            end
            tSearchCardResult.byCardCount[byResultCount] = byCount
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount
    return byResultCount;
end

return GameLogic
