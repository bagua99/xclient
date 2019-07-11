
local M = class("GameCardManager", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".card.GameCard")
local EventConfig               = require ("app.config.EventConfig")

local scheduler = cc.Director:getInstance():getScheduler()

-- 创建函数
function M:onCreate()
    -- 出牌点
    self.ptOutCard = {}
    self.ptOutCard[1] = cc.p(568,280)
    self.ptOutCard[2] = cc.p(300,390)
    self.ptOutCard[3] = cc.p(860,390)

    -- 手牌点
    self.ptStandCard = {}
    self.ptStandCard[1] = cc.p(120,95)
    self.ptStandCard[2] = cc.p(100,500)
    self.ptStandCard[3] = cc.p(660,500)

    -- 手牌点偏移
    self.ptStandOff = {}
    self.ptStandOff[1] = cc.p(55,0)
    self.ptStandOff[2] = cc.p(25,0)
    self.ptStandOff[3] = cc.p(25,0)

	self:init()
end

-- 初始化视图
function M:initView()
    self.tStandCardsBatchNode = {}
    self.tOutCardsBatchNode = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tStandCardsBatchNode[i] = cc.Node:create()
	    self:addChild(self.tStandCardsBatchNode[i])

        self.tOutCardsBatchNode[i] = cc.Node:create()
        self:addChild(self.tOutCardsBatchNode[i])
    end
end

-- 初始化触摸
function M:initTouch()

end

-- 进入
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
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

    for i=self.nCardCount[1], 1, -1 do
        self.tCardsArrayStand[1][i]:caluteTouch()
    end
end

-- 初始化
function M:init()
	self.tCardsArrayStand = {}
	self.tCardsArrayOut = {}

    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tCardsArrayStand[i] = {}
    end

    self.nCardCount = {}
    self.nCardCount[1] = 0
    self.nCardCount[2] = 0
    self.nCardCount[3] = 0

    self.nStartTouchTime = 0
    self.nPromptCount = 1

    if self.schedule_outcard then
    	scheduler:unscheduleScriptEntry(self.schedule_outcard)
    	self.schedule_outcard = nil
    end
end

-- 还原
function M:restore()
    for i=1, G_GameDefine.nMaxPlayerCount do
	    self.tStandCardsBatchNode[i]:removeAllChildren()
        self.tOutCardsBatchNode[i]:removeAllChildren()
    end

	self:init()
end

-- 选择牌
function M:touchSelectCard(touchPoint, bBeginTouch)
    local bFind = false
    for i=self.nCardCount[1], 1, -1 do
        if self.tCardsArrayStand[1][i] ~= nil and cc.rectContainsPoint(self.tCardsArrayStand[1][i]:getBoundingBox(), touchPoint) then
            self.tCardsArrayStand[1][i]:setTouchFlag()
            bFind = true
            break
         end
    end
end

-- 创建显示手牌
function M:createShowStandCard(nLocalSeat, nCardData)
    local nCardCount = #nCardData

    self.tCardsArrayStand[nLocalSeat] = {}
    self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()

    local nAdd = (G_GameDefine.nCardCount - nCardCount) / 2
    for i=1, nCardCount do
         local pGameCard = GameCard:create(nCardData[i], nLocalSeat)
         local curPoint = self:caluteCardPoint(0, i+nAdd, nLocalSeat)
         pGameCard:setPosition(curPoint)
         pGameCard:setVisible(true)
         self.tCardsArrayStand[nLocalSeat][i] = pGameCard
         self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
    end

    self.nCardCount[nLocalSeat] = nCardCount
end

-- 创建显示出牌
function M:createShowOutCard(nLocalSeat, nCardData)
    local nCardCount = #nCardData
    self.tCardsArrayOut[nLocalSeat] = {}
    self.tOutCardsBatchNode[nLocalSeat]:removeAllChildren()

    local nOutOff = 30
    local nStartX = self.ptOutCard[nLocalSeat].x - nCardCount*nOutOff/2
    local nStartY = self.ptOutCard[nLocalSeat].y
    if nLocalSeat == 2 then
        nStartX = self.ptOutCard[nLocalSeat].x
    elseif nLocalSeat == 3 then
        nStartX = self.ptOutCard[nLocalSeat].x - nCardCount*nOutOff
    end

    if nLocalSeat == 1 or G_Data.bReplay then
        for i=1, nCardCount do
            for nIndex, pGameCard in pairs(self.tCardsArrayStand[nLocalSeat]) do
                if pGameCard:getCardData(GameCard.Card_All) == nCardData[i] then
                    -- 移除牌
                    self.tStandCardsBatchNode[nLocalSeat]:removeChild(pGameCard)
                    -- 移除元素
                    table.remove(self.tCardsArrayStand[nLocalSeat], nIndex)
                    break
                end
            end
        end

        -- 重置牌
        local nAdd = (G_GameDefine.nCardCount - self.nCardCount[nLocalSeat]) / 2
        for nIndex, pGameCard in pairs(self.tCardsArrayStand[nLocalSeat]) do
            local curPoint = self:caluteCardPoint(0, nIndex+nAdd, nLocalSeat)
            pGameCard:setPosition(curPoint)
            pGameCard:setVisible(true)
        end

        -- 重新排序
        self.tStandCardsBatchNode[nLocalSeat]:sortAllChildren()
    end

    for i=1, nCardCount do
        local pGameCard = GameCard:create(nCardData[i], nLocalSeat)
        pGameCard:setPosition(cc.p(nStartX+i*nOutOff, nStartY))
        pGameCard:setScale(0.5)
        pGameCard:setVisible(true)
        self.tOutCardsBatchNode[nLocalSeat][i] = pGameCard
        self.tOutCardsBatchNode[nLocalSeat]:addChild(pGameCard)
    end
end

-- 清除显示出牌
function M:clearShowOutCard(nLocalSeat)
    if nLocalSeat == 0 then
        for i=1, G_GameDefine.nMaxPlayerCount do
            self.tCardsArrayOut[i] = {}
            self.tOutCardsBatchNode[i]:removeAllChildren()
        end
    else
        self.tCardsArrayOut[nLocalSeat] = {}
        self.tOutCardsBatchNode[nLocalSeat]:removeAllChildren()
    end
end

-- 创建显示结束牌
function M:createShowEndCard(nLocalSeat, nCardData)
    local nCardCount = #nCardData
    -- 自己不用显示了
    if nLocalSeat == 1 then
        return
    end

    self.tCardsArrayStand[nLocalSeat] = {}
    self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()

    local nOffX = 0
    local nOffY = 0
    
    local nChangeOffX = 0
    local nChangeOffY = 0
    if nLocalSeat == 2 then
        nChangeOffX = 240
        nChangeOffY = 445
	elseif nLocalSeat == 3 then
        nChangeOffX = 660
        nChangeOffY = 445
    end
    local nOffEndX = 32
    
    for i=1, nCardCount do
        if nCardData[i] ~= 0 then
            local pGameCard = GameCard:create(nCardData[i], nLocalSeat)
            pGameCard:setScale(0.5)
            pGameCard:setVisible(true)
            if nCardCount >= 8 then
                if i <= 8 then
                    nOffX = nChangeOffX
                    nOffY = nChangeOffY
                    pGameCard:setPosition(cc.p(nOffX + nOffEndX*(i-1), nOffY))
                else
                    nOffX = nChangeOffX
                    if nLocalSeat == 3 then
                        nOffX = nChangeOffX + (G_GameDefine.nCardCount - nCardCount) * nOffEndX
                    end
                    nOffY = -45 + nChangeOffY
                    pGameCard:setPosition(cc.p(nOffX + nOffEndX*((i-1)%8), nOffY))
                end
            else
                nOffX = nChangeOffX
                nOffY = nChangeOffY
                pGameCard:setPosition(cc.p(nOffX + nOffEndX*(i-1), nOffY))
            end
            self.tCardsArrayStand[nLocalSeat][i] = pGameCard
            self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
        end
    end
end

-- 设置玩家牌数
function M:setUserCardCount(nLocalSeat, nCardCount)
    self.nCardCount[nLocalSeat] = nCardCount
end

-- 增加玩家牌数
function M:addUserCardCount(nLocalSeat, nCardCount)
    self.nCardCount[nLocalSeat] = self.nCardCount[nLocalSeat] - nCardCount
end

-- 取得牌数
function M:getUserCardCount(nLocalSeat)
    return self.nCardCount[nLocalSeat]
end

-- 计算牌点
function M:caluteCardPoint(nStart, nNum, nLocalSeat)
    local nOffX = 0
    local nOffY = 0
    if nStart ~= 0 then
        nOffX = ptStandOff[nLocalSeat].x * nStart / 2
        nOffY = ptStandOff[nLocalSeat].y * nStart / 2
    end
    
    return cc.p(self.ptStandCard[nLocalSeat].x + self.ptStandOff[nLocalSeat].x * nNum + nOffX, self.ptStandCard[nLocalSeat].y + self.ptStandOff[nLocalSeat].y * nNum + nOffY)
end

-- 获取指定类型牌
function M:getCardArray(nLocalSeat, nCardType)
    local tCardData = {}
	for i=1, self.nCardCount[nLocalSeat] do
        local pGameCard = self.tCardsArrayStand[nLocalSeat][i]
        if pGameCard ~= nil then
            -- 取得牌值
            local nCardData = pGameCard:getCardData(nCardType)
            if nCardData > 0 then
                table.insert(tCardData, nCardData)
            end
        end
    end

    return tCardData
end

-- 获取手牌
function M:getCardStandArray(nLocalSeat)
	return self.tCardsArrayStand[nLocalSeat]
end

-- 获取出牌
function M:getCardOutArray(nLocalSeat)
    return self.tCardsArrayOut[nLocalSeat]
end

-- 提示
function M:prompt(tOutCardData)
    local nAllChooseCount = 0
    local nCardCount = 0
    local tCardData = {}
    for i=1, self.nCardCount[1] do
        local pGameCard = self.tCardsArrayStand[1][i]
        if pGameCard ~= nil then
            local nChooseCardData = pGameCard:getCardData(GameCard.Card_Selected)
            if nChooseCardData > 0 then
                nAllChooseCount = nAllChooseCount + 1
            end

            -- 设置牌
            local nCardData = pGameCard:getCardData(GameCard.Card_All)
            if nCardData > 0 then
                nCardCount = nCardCount + 1
                tCardData[nCardCount] = nCardData
            end
        end
    end

    -- 都没有选择,提示从第一个开始
    if nAllChooseCount == 0 then
        self.nPromptCount = 1
    end
    
    local tSearchCardResult = {}
    local nResultCount = G_DeskScene.GameLogic.searchOutCard(tCardData, tOutCardData, tSearchCardResult)
    
    if nResultCount > 0 then
        self.nPromptCount = math.fmod(self.nPromptCount, nResultCount+1)
        if self.nPromptCount <= 0 then
            self.nPromptCount = 1
        end

        -- 重置牌
        local nAdd = (G_GameDefine.nCardCount - self.nCardCount[1]) / 2
        for nIndex, pGameCard in pairs(self.tCardsArrayStand[1]) do
            local curPoint = self:caluteCardPoint(0, nIndex+nAdd, 1, true)
            pGameCard:onTouchOut()
            pGameCard:setVisible(true)
        end

        for i=1, tSearchCardResult.tCardCount[self.nPromptCount] do
            for j=1, self.nCardCount[1] do
                local pGameCard = self.tCardsArrayStand[1][j]
                if pGameCard ~= nil then
                    -- 取没有选择的牌
                    local nCardData = pGameCard:getCardData(GameCard.Card_None)
                    if nCardData > 0 and nCardData == tSearchCardResult.tResultCard[self.nPromptCount][i] then
                        -- 选择牌
                        pGameCard:onTouchIn()
                        break
                    end
                end
            end
        end

        self.nPromptCount = self.nPromptCount + 1

        return true
    end

    return false
end

-- 压牌
function M:pressCard(tOutCardData)
    local nCardCount = 0
    local tCardData = {}
    for i=1, self.nCardCount[1] do
        local pGameCard = self.tCardsArrayStand[1][i]
        if pGameCard ~= nil then
            -- 设置牌
            local nCardData = pGameCard:getCardData(GameCard.Card_All)
            if nCardData > 0 then
                nCardCount = nCardCount + 1
                tCardData[nCardCount] = nCardData
            end
        end
    end
    
    local tSearchCardResult = {}
    local nResultCount = G_DeskScene.GameLogic.searchOutCard(tCardData, tOutCardData, tSearchCardResult)
    if nResultCount > 0 then
        local bFindThreeAnd = false
        for i=1, nResultCount do
            for j=1, tSearchCardResult.tCardCount[i] do
                -- 取得类型
                local nType = G_DeskScene.GameLogic.getCardType(tSearchCardResult.tResultCard[i])
                if nType == G_DeskScene.GameLogic.CT_THREE_TAKE_ONE or nType == G_DeskScene.GameLogic.CT_THREE_TAKE_TWO then
                    bFindThreeAnd = true
                    break
                end
                if bFindThreeAnd then
                    break
                end
            end
        end
        
        -- 3带1和3带2类型，所有牌全亮,因为带牌是可以选择的
        if bFindThreeAnd then
            for i=1, self.nCardCount[1] do
                local pGameCard = self.tCardsArrayStand[1][i]
                if pGameCard ~= nil then
                    -- 设置牌
                    local nCardData = pGameCard:getCardData(GameCard.Card_All)
                    if nCardData > 0 then
                        -- 设置选择状态
                        pGameCard:setTouchState(true)
                    end
                end
            end
        else
            local tChooseCard = {}
            for i=1, nResultCount do
                for j=1, tSearchCardResult.tCardCount[i] do
                    local nCardData = tSearchCardResult.tResultCard[i][j]
                    tChooseCard[G_DeskScene.GameLogic.getCardValue(nCardData)] = true
                end
            end

            for i=1, self.nCardCount[1] do
                local pGameCard = self.tCardsArrayStand[1][i]
                if pGameCard ~= nil then
                    -- 设置牌
                    local nCardData = pGameCard:getCardData(GameCard.Card_All)
                    if nCardData > 0 then
                        local bChooseTouch = tChooseCard[G_DeskScene.GameLogic.getCardValue(nCardData)]
                        -- 设置选择状态
                        pGameCard:setTouchState(bChooseTouch)
                    end
                end
            end

            -- 因为玩家可能提前弹起了几张牌,但目前不能出,要弹回去
            for i=1, self.nCardCount[1] do
                local pGameCard = self.tCardsArrayStand[1][i]
                if pGameCard ~= nil then
                    local nCardData = pGameCard:getCardData(GameCard.Card_Selected)
                    if nCardData > 0 and not tChooseCard[G_DeskScene.GameLogic.getCardValue(nCardData)] then
                        pGameCard:onTouchOut()
                    end
                end
            end
        end

        return true
    end

    return false
end

-- 自动出牌
function M:autoOutCard(bFirstOutCard, tOutCardData)
    local tCardData = self:getCardArray(1, GameCard.Card_All)
    local nCardCount = #tCardData

    if not bFirstOutCard then
        -- 不可出完牌
        if not G_DeskScene.GameLogic.compareCard(tOutCardData, tCardData) then
            return
        end
    else
        -- 取得牌型
        local nCardType = G_DeskScene.GameLogic.getCardType(tCardData)
        if nCardType == G_DeskScene.GameLogic.CT_ERROR then
	        -- 是否错误牌型
	        local bError = true
            while bError do
                -- 分析扑克
		        local tAnalyseResult = {}
		        G_DeskScene.GameLogic.analysebCardData(tCardData, tAnalyseResult)
		        -- 不是连牌
		        if tAnalyseResult.tBlockCount[3] == nil or tAnalyseResult.tBlockCount[3] <= 1 then
			        break
		        end

                -- 变量定义
		        local nCardData = tAnalyseResult.tCardData[3][1]
		        local nFirstLogicValue = G_DeskScene.GameLogic.getCardLogicValue(nCardData)
		        local nLianPaiCount = 0
                local nLianPaiMaxCount = 0
		        -- 连牌判断
		        for i=1, tAnalyseResult.tBlockCount[3] do
			        local nCardData1 = tAnalyseResult.tCardData[3][i * 3]
			        if (nFirstLogicValue ~= (G_DeskScene.GameLogic.getCardLogicValue(nCardData1) + nLianPaiCount)) then
                
                        if nLianPaiCount > nLianPaiMaxCount then
                            nLianPaiMaxCount = nLianPaiCount
                        end

                        local nCardData2 = tAnalyseResult.tCardData[3][i * 3]
                        nFirstLogicValue = G_DeskScene.GameLogic.getCardLogicValue(nCardData2)
                        nLianPaiCount = 1
			        else
                        nLianPaiCount = nLianPaiCount + 1

                        -- 错误过虑
		                if nFirstLogicValue >= 15 then
                            if nLianPaiCount > nLianPaiMaxCount then
                                nLianPaiMaxCount = nLianPaiCount
                            end
                            local nCardData2 = tAnalyseResult.tCardData[3][i * 3]
                            nFirstLogicValue = G_DeskScene.GameLogic.getCardLogicValue(nCardData2)
                            nLianPaiCount = 1
                        end
			        end
		        end
                if nLianPaiCount > nLianPaiMaxCount then
                    nLianPaiMaxCount = nLianPaiCount
                end
		        if nLianPaiMaxCount == 0 then
			        break
		        end

		        -- 出的牌比连牌都少
		        if (nCardCount <= nLianPaiMaxCount * 3) then
			        break
		        end

		        -- 比如555，666 带1,2,3张都可以出
		        if (nCardCount - nLianPaiMaxCount * 3 > nLianPaiMaxCount * 2) then
			        break
		        end

		        -- 设置未错误类型
		        bError = false
            end

            -- 错误牌型
		    if bError then
			    return
            end
        end
    end

    if self.schedule_outcard then
    	scheduler:unscheduleScriptEntry(self.schedule_outcard)
    	self.schedule_outcard = nil
    end
    self.schedule_outcard = scheduler:scheduleScriptFunc(handler(self, self.sendOutCard), 1, false)
end

-- 发送出牌
function M:sendOutCard()
    if G_Data.bReplay then
        return
    end

    if self.schedule_outcard then
    	scheduler:unscheduleScriptEntry(self.schedule_outcard)
    	self.schedule_outcard = nil
    end

    -- 获取选择牌
    local tCardData = self:getCardArray(1, GameCard.Card_All)
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "pdk.GAME_OutCardReq", {nCardData = tCardData})
end

-- 设置选择状态
function M:recoverTouchState(bTouchState)
    for i=1, self.nCardCount[1] do
        local pGameCard = self.tCardsArrayStand[1][i]
        if pGameCard ~= nil then
            -- 设置选择状态
            pGameCard:setTouchState(bTouchState)
        end
    end
end

return M
