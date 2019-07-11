
local M = class("GameCardManager", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.YZBP..".card.GameCard")
local EventConfig               = require ("app.config.EventConfig")

local scheduler = cc.Director:getInstance():getScheduler()

-- 创建函数
function M:onCreate()
	self:init()
end

-- 初始化视图
function M:initView()
    self.tHandCard = {}
    self.tOutCard = {}
    for i=1, G_GameDefine.player_count do
        self.tHandCard[i] = cc.Node:create()
	    self:addChild(self.tHandCard[i])

        self.tOutCard[i] = cc.Node:create()
        self:addChild(self.tOutCard[i])
    end
end

-- 初始化触摸
function M:initTouch()

end

-- 进入
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
end

-- 退出
function M:onExit()
    if self.listener then
	    self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end

-- 触摸开始
function M:onTouchBegin(touch, event)
    local location = touch:getLocationInView()
    local touchPoint = cc.Director:getInstance():convertToGL(location)
    self:touchSelectCard(touchPoint, true)

	return self:isVisible()
end

-- 触摸移动
function M:onTouchMove(touch, event)
    local location = touch:getLocationInView()
    local touchPoint = cc.Director:getInstance():convertToGL(location)
    self:touchSelectCard(touchPoint, true)
end

-- 触摸结束
function M:onTouchEnded(touch, event)
    local location = touch:getLocationInView()
    local touchPoint = cc.Director:getInstance():convertToGL(location)
    self:touchSelectCard(touchPoint, true)

    for i = #self.tCardsArrayStand[1], 1, -1 do
        self.tCardsArrayStand[1][i]:caluteTouch()
    end
end

-- 初始化
function M:init()
	self.tCardsArrayStand = {}
	self.tCardsArrayOut = {}

    for i = 1, G_GameDefine.player_count do
        self.tCardsArrayStand[i] = {}
        self.tCardsArrayOut[i] = {}
    end
end

-- 还原
function M:restore()
    for i=1, G_GameDefine.player_count do
	    self.tHandCard[i]:removeAllChildren()
        self.tOutCard[i]:removeAllChildren()
    end

	self:init()
end

-- 选择牌
function M:touchSelectCard(touchPoint, bBeginTouch)
    local bFind = false
    for i = #self.tCardsArrayStand[1], 1, -1 do
        if self.tCardsArrayStand[1][i] ~= nil and cc.rectContainsPoint(self.tCardsArrayStand[1][i]:getBoundingBox(), touchPoint) then
            self.tCardsArrayStand[1][i]:setTouchFlag()
            bFind = true
            break
         end
    end
end

-- 创建显示手牌
function M:createShowStandCard(nLocalSeat, tCardData)
    self.tCardsArrayStand[nLocalSeat] = {}
    self.tHandCard[nLocalSeat]:removeAllChildren()

    -- 显示牌
    self:showHandCard(nLocalSeat, tCardData)
end

-- 设置主牌
function M:setMain(nLocalSeat)
    local tTempCard = {}
    for _, pGameCard in ipairs(self.tCardsArrayStand[nLocalSeat]) do
        table.insert(tTempCard, pGameCard:getCardData(GameCard.Card_All))
    end
    -- 排序
    G_DeskScene.GameLogic:sortCard(tTempCard)

    self.tCardsArrayStand[nLocalSeat] = {}
    self.tHandCard[nLocalSeat]:removeAllChildren()

    -- 显示牌
    self:showHandCard(nLocalSeat, tTempCard)
end


-- 增加底牌
function M:addBackCard(nLocalSeat, tCardData)
    local tTempCard = {}
    for _, pGameCard in ipairs(self.tCardsArrayStand[nLocalSeat]) do
        table.insert(tTempCard, pGameCard:getCardData(GameCard.Card_All))
    end
    -- 增加底牌
    for _, v in ipairs(tCardData) do
        table.insert(tTempCard, v)
    end
    -- 排序
    G_DeskScene.GameLogic:sortCard(tTempCard)

    self.tCardsArrayStand[nLocalSeat] = {}
    self.tHandCard[nLocalSeat]:removeAllChildren()

    -- 显示牌
    self:showHandCard(nLocalSeat, tTempCard)
end

-- 埋底
function M:buryCard(nLocalSeat, tCardData)
    local tTempCard = {}
    for _, pGameCard in ipairs(self.tCardsArrayStand[nLocalSeat]) do
        table.insert(tTempCard, pGameCard:getCardData(GameCard.Card_All))
    end
    -- 移除底牌
    G_DeskScene.GameLogic:removeCard(tTempCard, tCardData)

    self.tCardsArrayStand[nLocalSeat] = {}
    self.tHandCard[nLocalSeat]:removeAllChildren()

    -- 显示牌
    self:showHandCard(nLocalSeat, tTempCard)
end

-- 显示手牌
function M:showHandCard(nLocalSeat, tCardData)
    local nCardCount = #tCardData

    local nMaxCardCount
    if G_GameDefine.player_count == 4 then
        nMaxCardCount = 19
        if nCardCount > nMaxCardCount then
            -- 加上底牌
            nMaxCardCount = nMaxCardCount + 8
        end
    else
        nMaxCardCount = 25
        if nCardCount > nMaxCardCount then
            -- 加上底牌
            nMaxCardCount = nMaxCardCount + 9
        end
    end

    local nAdd = (nMaxCardCount - nCardCount) / 2
    for i = 1, nCardCount do
         local pGameCard = GameCard:create(tCardData[i])
         local curPoint = self:caluteCardPoint(nCardCount, i, nAdd, nLocalSeat)
         pGameCard:setPosition(curPoint)
         pGameCard:setVisible(true)
         self.tCardsArrayStand[nLocalSeat][i] = pGameCard
         self.tHandCard[nLocalSeat]:addChild(pGameCard)
    end
end

-- 创建显示出牌
function M:createShowOutCard(nLocalSeat, tCardData)
    local nCardCount = #tCardData
    self.tCardsArrayOut[nLocalSeat] = {}
    self.tOutCard[nLocalSeat]:removeAllChildren()

    -- 出牌点
    local ptOutCard = {}
    ptOutCard[1] = cc.p(600, 280)
    ptOutCard[2] = cc.p(756, 425)
    ptOutCard[3] = cc.p(600, 467)
    ptOutCard[4] = cc.p(338, 425)

    local nOutOff = 30
    local nStartX = ptOutCard[nLocalSeat].x - nCardCount*nOutOff/2
    local nStartY = ptOutCard[nLocalSeat].y
    if nLocalSeat == 2 or nLocalSeat == 4 then
        nStartX = ptOutCard[nLocalSeat].x
    end
    for i = 1, nCardCount do
        local pGameCard = GameCard:create(tCardData[i])
        pGameCard:setPosition(cc.p(nStartX+i*nOutOff, nStartY))
        pGameCard:setScale(0.5)
        pGameCard:setVisible(true)
        self.tCardsArrayOut[nLocalSeat][i] = pGameCard
        self.tOutCard[nLocalSeat]:addChild(pGameCard)
    end

    if nLocalSeat == 1 or G_Data.bReplay then
        for i = 1, nCardCount do
            for nIndex, pGameCard in pairs(self.tCardsArrayStand[nLocalSeat]) do
                if pGameCard:getCardData(GameCard.Card_All) == tCardData[i] then
                    -- 移除牌
                    self.tHandCard[nLocalSeat]:removeChild(pGameCard)
                    -- 移除元素
                    table.remove(self.tCardsArrayStand[nLocalSeat], nIndex)
                    break
                end
            end
        end
        nCardCount = #self.tCardsArrayStand[nLocalSeat]

        local nMaxCardCount
        if G_GameDefine.player_count == 4 then
            nMaxCardCount = 19
        else
            nMaxCardCount = 25
        end
        -- 重置牌
        local nAdd = (nMaxCardCount - nCardCount) / 2
        for nIndex, pGameCard in pairs(self.tCardsArrayStand[nLocalSeat]) do
            local curPoint = self:caluteCardPoint(nCardCount, nIndex, nAdd, nLocalSeat)
            pGameCard:setPosition(curPoint)
            pGameCard:setVisible(true)
        end

        -- 重新排序
        self.tHandCard[nLocalSeat]:sortAllChildren()
    end
end

-- 清除显示出牌
function M:clearShowOutCard(nLocalSeat)
    if nLocalSeat == 0 then
        for i=1, G_GameDefine.player_count do
            self.tCardsArrayOut[i] = {}
            self.tOutCard[i]:removeAllChildren()
        end
    else
        self.tCardsArrayOut[nLocalSeat] = {}
        self.tOutCard[nLocalSeat]:removeAllChildren()
    end
end

-- 显示大牌
function M:showBigCard(nLocalSeat)
	for _, pGameCard in pairs(self.tCardsArrayOut[nLocalSeat]) do
        pGameCard:runAction(
            cc.Sequence:create(cc.DelayTime:create(0.4),
                cc.CallFunc:create(function(sender, v)
                    if v.value == false then
                        v.value = true
                        pGameCard:showDa(true)
                    end
                end, {value = false}),
                cc.ScaleTo:create(0.1, 0.65),
                cc.DelayTime:create(0.1),
                cc.ScaleTo:create(0.1, 0.6),
                cc.DelayTime:create(0.1)
            )
        )
	end
end

-- 计算牌点
function M:caluteCardPoint(nCardCount, nNum, nAdd, nLocalSeat)
    -- 手牌点
    local ptStandCard = {
        cc.p(40, 100),
        cc.p(100, 500),
        cc.p(660, 500),
        cc.p(660, 500),
    }

    -- 手牌点偏移
    local ptStandOff = {
        cc.p(55, 0),
        cc.p(25, 0),
        cc.p(25, 0),
        cc.p(25, 0),
    }

    -- 四人加底牌
    if nCardCount == 19 + 8 then
        ptStandOff = {
            cc.p(40, 0),
            cc.p(20, 0),
            cc.p(20, 0),
            cc.p(20, 0),
        }
    -- 3人加底
    elseif nCardCount == 25 + 9 then
        ptStandOff = {
            cc.p(40, 0),
            cc.p(20, 0),
            cc.p(20, 0),
            cc.p(20, 0),
        }
    end

    -- 位置
    local nTemp = nNum + nAdd
    local nOffY = 0
    -- 3人加底，分2层
    if nCardCount == 25 + 9 then
        if nNum <= 9 then
            nTemp = (25 - 9) + nNum
            nOffY = 170
        else
            nTemp = nTemp - 9
        end
    end
    
    return cc.p(ptStandCard[nLocalSeat].x + ptStandOff[nLocalSeat].x * nTemp, ptStandCard[nLocalSeat].y + ptStandOff[nLocalSeat].y * nTemp + nOffY)
end

-- 获取指定类型牌
function M:getCardArray(nLocalSeat, nCardType)
    local tCardData = {}
	for _, pGameCard in pairs(self.tCardsArrayStand[nLocalSeat]) do
        -- 取得牌值
        local nCardData = pGameCard:getCardData(nCardType)
        if nCardData > 0 then
            table.insert(tCardData, nCardData)
        end
    end

    return tCardData
end

-- 获取手牌
function M:getCardStandArray(nLocalSeat)
	return self.tCardsArrayStand[nLocalSeat]
end

-- 获取手牌数量
function M:getCardStandCount(nLocalSeat)
	return #self.tCardsArrayStand[nLocalSeat]
end

-- 获取出牌
function M:getCardOutArray(nLocalSeat)
    return self.tCardsArrayOut[nLocalSeat]
end

-- 设置选择状态
function M:recoverTouchState(bTouchState)
    for _, pGameCard in pairs(self.tCardsArrayStand[1]) do
        -- 设置选择状态
        pGameCard:setTouchState(bTouchState)
    end
end

return M
