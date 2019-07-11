
local M = class("GameHandCardManager", function()
    return ccui.Layout:create()
end)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameCard")

local EventConfig               = require ("app.config.EventConfig")

function M:create(tipsXuXian)
    local view = M.new()
    view:onCreate(tipsXuXian)
    local function onEventHandler(eventType)  
        if eventType == "exit" then
            view:onExit()
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end

function M:onCreate(tipsXuXian)
    self.tCardInfo = {}

    self.nCardStackWidth = 11
    self.nCardHeigh = 90.0
    self.nCardWidth = 95.0
    
    self.nBasePositionX = 50.0
    self.nBasePositionY = 55.0

    self.nLeftAlignment = 1
    self.nCentreAlignment = 2
    self.nRightAlignment = 3
    self.nHandCardAlignment = 2

    self.pMoveSprite = nil
    self.fBaseStartPosx = 0
    self.fBaseEndPosx = 0
    self.beganPos = cc.p(0,0)
    
    self.bOutCard = false
    self.tCardNode = cc.Node:create()
    self:addChild(self.tCardNode)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
    
    --[[
    self.tipsXuXian = tipsXuXian
    self.tipsXuXian:setVisible(false)
    local winSize = cc.Director:getInstance():getWinSize()
    self.tipsXuXian:setPosition(winSize.width/2, winSize.height*0.5)
    --]]
    return true
end

function M:onExit()
    self:getEventDispatcher():removeEventListener(self.listener)
end

-- 还原数据
function M:restore()
    self.tCardInfo = {}
    self.bOutCard = false

    self:showCard()
end

function M:sortCard(tData)
    local tTempCardData = {}
    for k, v in ipairs(tData) do
        tTempCardData[k] = v
    end

    self.tCardInfo = {}
    -- 3,4张遍历
    for i = 1, 20 do
        if tTempCardData[i] >= 3 then
            local tCardData = {}
            for j = 1, tTempCardData[i] do 
                table.insert(tCardData, {nCardData = i, nPoint = cc.p(0,0)})
            end
            table.insert(self.tCardInfo, tCardData)
            tTempCardData[i] = 0
        end
    end

    -- 2张遍历
    for i = 1, 20 do
        if tTempCardData[i]==2 then
            local tCardData = {}
            for j= 1 , tTempCardData[i] do 
                table.insert(tCardData, {nCardData = i, nPoint = cc.p(0,0)})
            end
            table.insert(self.tCardInfo, tCardData)
            tTempCardData[i] = 0
        end
    end

    -- 红字遍历
    if tTempCardData[2] == 1 and tTempCardData[7] == 1 and tTempCardData[10] == 1 and #self.tCardInfo <= self.nCardStackWidth then
        local tCardData =
        {
            {nCardData = 2, nPoint = cc.p(0,0)},
            {nCardData = 7, nPoint = cc.p(0,0)},
            {nCardData = 10, nPoint = cc.p(0,0)},
        }
        table.insert(self.tCardInfo, tCardData)
        
        tTempCardData[2] = 0
        tTempCardData[7] = 0
        tTempCardData[10] = 0
    end
    if tTempCardData[12] == 1 and tTempCardData[17] == 1 and tTempCardData[20] == 1  and #self.tCardInfo <= self.nCardStackWidth then
        local tCardData =
        {
            {nCardData = 12, nPoint = cc.p(0,0)},
            {nCardData = 17, nPoint = cc.p(0,0)},
            {nCardData = 20, nPoint = cc.p(0,0)},
        }
        table.insert(self.tCardInfo, tCardData)
        
        tTempCardData[12] = 0
        tTempCardData[17] = 0
        tTempCardData[20] = 0
    end

    -- 12345678910遍历
    local i = 1 
    while i <= 18 do
        if tTempCardData[i] == 1 and tTempCardData[i+1] == 1 and tTempCardData[i+2] == 1 then
            local tCardData =
            {
                {nCardData = i, nPoint = cc.p(0,0)},
                {nCardData = i+1, nPoint = cc.p(0,0)},
                {nCardData = i+2, nPoint = cc.p(0,0)},
            }
            table.insert(self.tCardInfo, tCardData)

            tTempCardData[i] = 0
            tTempCardData[i+1] = 0
            tTempCardData[i+2] = 0
        end
        if i == 8 then
            i = 10
        end
        i = i + 1
    end

    -- 大小字遍历
    for i=1, 10 do
        if tTempCardData[i] == 1 and tTempCardData[i+10] == 1  and #self.tCardInfo <= self.nCardStackWidth then
            local tCardData =
            {
                {nCardData = i, nPoint = cc.p(0,0)},
                {nCardData = i+10, nPoint = cc.p(0,0)},
            }
            table.insert(self.tCardInfo, tCardData)
            
            tTempCardData[i] = 0
            tTempCardData[i+10] = 0
        end
    end

    -- 12345678910遍历
    local i = 1
    while i <= 19 do
        if tTempCardData[i] == 1 and tTempCardData[i+1] == 1 then
            local tCardData =
            {
                {nCardData = i, nPoint = cc.p(0,0)},
                {nCardData = i+1, nPoint = cc.p(0,0)},
            }
            table.insert(self.tCardInfo, tCardData)
            
            tTempCardData[i] = 0
            tTempCardData[i+1] = 0
        end
        if i == 9 then
            i = 10
        end
        i = i + 1
    end

    -- 1张遍历
    for i = 1, 20 do
        if tTempCardData[i] == 1 then
            -- 原有叠加
            for nIndex, tCardData in pairs(self.tCardInfo) do
                local nCardColor = i <= 10 and 0 or 1
                if #tCardData == 2 and (nCardColor == (tCardData[1].nCardData <= 10 and 0 or 1) or nCardColor == (tCardData[2].nCardData <= 10 and 0 or 1)) then
                    table.insert(tCardData, {nCardData = i, nPoint = cc.p(0,0)})
                    tTempCardData[i] = 0
                    break
                elseif #tCardData == 1 and #self.tCardInfo >= 10 then
                    table.insert(tCardData, {nCardData = i, nPoint = cc.p(0,0)})
                    tTempCardData[i] = 0
                    break
                elseif nIndex >= #self.tCardInfo and #self.tCardInfo < self.nCardStackWidth then
                    table.insert(self.tCardInfo, {{nCardData = i, nPoint = cc.p(0,0)}})
                    tTempCardData[i]=0
                    break
                end
            end
        end
    end

    -- 1张遍历
    for i = 1, 20 do
        if tTempCardData[i] == 1 then
            if #self.tCardInfo <= 0 then
                -- 如果一张牌都没有，则新建一列
                local tCardData = {}
                for j = 1, tTempCardData[i] do 
                    table.insert(tCardData, {nCardData = i, nPoint = cc.p(0,0)})
                end
                table.insert(self.tCardInfo, tCardData)
                tTempCardData[i] = 0
            else
                for j= #self.tCardInfo, 1 , -1 do
                    if #self.tCardInfo[j] < 3 then
                        table.insert(self.tCardInfo[j], {nCardData = i, nPoint = cc.p(0,0)})
                        tTempCardData[i] = 0
                        break
                    end
                end
            end
        end
    end

    self:showCard()
end

-- 移除一张牌
function M:removeOneCard(nCard)
    for i, tCardData in ipairs(self.tCardInfo) do
        for j, tData in ipairs(tCardData) do
            if nCard == tData.nCardData then
                table.remove(tCardData, j)
                if #tCardData <= 0 then
                    table.remove(self.tCardInfo, i)
                end

                if self.pMoveSprite ~= nil then
                    self.pMoveSprite:removeFromParent()
                    self.pMoveSprite = nil
                end
                self:showCard(true)
                return
            end
        end
    end
end

-- 增加一张牌
function M:addOneCard(nCard)
    --原有叠加
    for _, tCardData in ipairs(self.tCardInfo) do
        if #tCardData < 4 then
            table.insert(tCardData, {nCardData = nCard, nPoint = cc.p(0,0)})
            self:showCard(false)
            return
    	end
    end

    --另出一排
    print("另出一排", #self.tCardInfo)
    if #self.tCardInfo <= 0 then
        table.insert(self.tCardInfo, {{nCardData = nCard, nPoint = cc.p(0,0)}})
        self:showCard(false)
    else
        table.insert(self.tCardInfo, {{nCardData = nCard, nPoint = cc.p(0,0)}})
        self:showCard(true)
    end
end

-- 移除多张牌
function M:removeMoreCard(tCard)
    local nCount = #tCard
    if nCount <= 0 then
        return
    end

    for _, nCard in ipairs(tCard) do
        local bFind = false
        for i, tCardData in ipairs(self.tCardInfo) do
            if bFind then
                break
            end

            for j, tData in ipairs(tCardData) do
                if bFind then
                    break
                end

                if nCard == tData.nCardData then
                    table.remove(tCardData, j)
                    if #tCardData <= 0 then
                        table.remove(self.tCardInfo, i)
                    end
                    bFind = true
                end
            end
        end
    end

    if self.pMoveSprite ~= nil then
        self.pMoveSprite:removeFromParent()
        self.pMoveSprite = nil
    end
    self:showCard(true)
end

function M:showCardEffect()
    local winSize=cc.Director:getInstance():getWinSize()
    local nBasePointX = 0
    local nEndPointX = 0
    if self.nHandCardAlignment == self.nLeftAlignment then
        nBasePointX = winSize.width*0.45 - (#self.tCardInfo*self.nCardWidth)*0.5
        nEndPointX  = winSize.width*0.45 + (#self.tCardInfo*self.nCardWidth)*0.5
    elseif self.nHandCardAlignment == self.nCentreAlignment then
        nBasePointX = (winSize.width - #self.tCardInfo*self.nCardWidth)*0.5
        nEndPointX  = (winSize.width + #self.tCardInfo*self.nCardWidth)*0.5
    end
    self.fBaseStartPosx = nBasePointX - self.nCardWidth*0.5 + self.nBasePositionX                         -- 基准起点
    self.fBaseEndPosx   = nEndPointX  - self.nCardWidth*0.5 + self.nBasePositionX                         -- 基准终点

    self.tCardNode:removeAllChildren()
    for i, tCardData in ipairs(self.tCardInfo) do
        for j = #tCardData, 1, -1 do
            local szFileName = tCardData[j].nCardData..".png"
            local pGameCard = GameCard:create(szFileName)
            local ft = (j - 1) * 0.2
            local nPoint = cc.p(nBasePointX + (i - 1)*self.nCardWidth + self.nBasePositionX, self.nBasePositionY + self.nCardHeigh*(j - 1))
            pGameCard:setPosition(winSize.width*0.5, self.nBasePositionY + self.nCardHeigh*(j - 1))
            pGameCard:setOpacity(0)
            pGameCard:runAction(cc.Sequence:create(cc.DelayTime:create(ft), cc.Spawn:create(cc.FadeTo:create(0.2,255), cc.MoveTo:create(0.3, nPoint))))
            pGameCard:setTag(i*10+j)
            self.tCardNode:addChild(pGameCard)
        end
    end
end

function M:showCard(isMove)
    if isMove == nil then
    	isMove = false
    end
    local winSize = cc.Director:getInstance():getWinSize()

    local nBasePointX = 0
    local nEndPointX = 0
    if self.nHandCardAlignment == self.nLeftAlignment then
        nBasePointX = winSize.width*0.45 - (#self.tCardInfo*self.nCardWidth)*0.5
        nEndPointX  = winSize.width*0.45 + (#self.tCardInfo*self.nCardWidth)*0.5
    elseif self.nHandCardAlignment == self.nCentreAlignment then
        nBasePointX = (winSize.width - #self.tCardInfo*self.nCardWidth)*0.5
        nEndPointX  = (winSize.width + #self.tCardInfo*self.nCardWidth)*0.5
    end
    self.fBaseStartPosx = nBasePointX- self.nCardWidth*0.5 + self.nBasePositionX                      -- 基准起点
    self.fBaseEndPosx   = nEndPointX - self.nCardWidth*0.5 + self.nBasePositionX                      -- 基准终点

    self.tCardNode:removeAllChildren()
    for i, tCardData in ipairs(self.tCardInfo) do
        for j = #tCardData, 1, -1 do
            local szFileName = tCardData[j].nCardData..".png"
            local pGameCard = GameCard:create(szFileName)
            local nPoint = cc.p(nBasePointX + (i-1)*self.nCardWidth + self.nBasePositionX, self.nBasePositionY + self.nCardHeigh*(j-1))
            if isMove then
                pGameCard:setPosition(tCardData[j].nPoint)
                pGameCard:runAction(cc.MoveTo:create(0.2, nPoint))
            else
                pGameCard:setPosition(nPoint)
            end
            tCardData[j].nPoint = nPoint
            pGameCard:setTag(i*10+j)
            self.tCardNode:addChild(pGameCard)
        end
    end
end

function M:onTouchBegan(touch, event)
     local touchPoint = touch:getLocation()
     local tHardCardChildren = self.tCardNode:getChildren()
     for _, pGameCard in ipairs(tHardCardChildren) do
        if cc.rectContainsPoint(pGameCard:getBoundingBox(),touchPoint) then
            local nSameCount = 0
            local nTag = pGameCard:getTag()
            local i = math.floor(nTag/10)
            local j = math.floor(nTag%10)
            local tCardData = self.tCardInfo[i]
            local nCardData = tCardData[j].nCardData
            for k, v in ipairs(tCardData) do
                if v.nCardData == nCardData then
                    nSameCount = nSameCount + 1               
                end
            end

            -- 大于3张时不能移动
            if nSameCount >= 3 then
                return false
            else
                if self.pMoveSprite == nil then
                    self.beganPos = cc.p(pGameCard:getPosition())
                    pGameCard:setOpacity(100)
                    local szFileName = nCardData..".png"
                    self.pMoveSprite = GameCard:create(szFileName)
                    self.pMoveSprite:setTag(nTag)
                    self.pMoveSprite:setPosition(self.beganPos)
                    local _part = cc.ParticleSun:createWithTotalParticles(64)
                    _part:setPosition(cc.p(35,35))
                    self.pMoveSprite:addChild(_part)
                    self:addChild(self.pMoveSprite)
                 end
                 --self.tipsXuXian:setVisible(self.bOutCard) 
                 return true
            end
        end
     end
     return false
end

function M:onTouchMoved(touch, event)
    local touchPoint = touch:getLocation()
    if self.pMoveSprite then
        self.pMoveSprite:setPosition(touchPoint)
        --self.tipsXuXian:setVisible(self.bOutCard) 
    end
end

function M:onTouchEnded(touch, event)
    --self.tipsXuXian:setVisible(false)    
    if self.pMoveSprite == nil then
        return
    end

    local nTag = self.pMoveSprite:getTag()
    local nPosX = math.floor(nTag/10)
    local nPosY = math.floor(nTag%10)

    local tCardData = self.tCardInfo[nPosX]
    local nCardData = tCardData[nPosY].nCardData

    local bRplace =false
    local touchPoint = touch:getLocation()
    local winSize= cc.Director:getInstance():getWinSize()
    if touchPoint.y > winSize.height * 0.5 then
        -- 出牌
        if self.bOutCard and nCardData <= G_GameDefine.MAX_CARD then
            bRplace = true
            G_CommonFunc:addClickSound()
	        G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "nxphz.GAME_OutCardReq", {nCardData=nCardData})
        end
    else
        if ((touchPoint.x > self.fBaseEndPosx or touchPoint.x < self.fBaseStartPosx) and #self.tCardInfo < self.nCardStackWidth) then
            bRplace = true

            if #tCardData <= 1 then
                table.remove(self.tCardInfo, nPosX)
            else
                table.remove(tCardData, nPosY)
            end

            local tCardData = {{nCardData = nCardData, nPoint = cc.p(self.pMoveSprite:getPosition())}}
            if touchPoint.x > self.fBaseEndPosx then
                table.insert(self.tCardInfo, tCardData)
            else
                table.insert(self.tCardInfo, 1, tCardData)
            end
        elseif touchPoint.x < self.fBaseEndPosx and touchPoint.x > self.fBaseStartPosx then
            local tHardCardChildren = self.tCardNode:getChildren()
            for _, pGameCard in ipairs(tHardCardChildren) do
                local rect = pGameCard:getBoundingBox()
                if pGameCard:getLocalZOrder() == 0 and touchPoint.x >= cc.rectGetMinX(rect) and touchPoint.x <= cc.rectGetMaxX(rect) then
                    -- 4张以上不能拖动
                    local nNewX = math.floor(pGameCard:getTag()/10)
                    local tNewCardData = self.tCardInfo[nNewX]
                    if #tNewCardData >= 4 then
                        break
                    end
                    bRplace = true

                    -- 增加新的
                    table.insert(tNewCardData, {nCardData = nCardData, nPoint = cc.p(self.pMoveSprite:getPosition())})

                    -- 删掉原来的
                    if #tCardData <= 1 then
                        table.remove(self.tCardInfo, nPosX)
                    else
                        table.remove(tCardData, nPosY)
                    end
                    break
                end   
            end
        end
    end

    if bRplace then
        self.pMoveSprite:removeFromParent()
        self.pMoveSprite = nil
        self:showCard(true)
    else
        -- 隐藏掉原来的
        local tHardCardChildren = self.tCardNode:getChildren()
        for _, pGameCard in ipairs(tHardCardChildren) do
        	if pGameCard:getOpacity() == 100 then
        		pGameCard:setVisible(false)
        		break
        	end
        end

        self.pMoveSprite:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.3,cc.p(self.beganPos)),
            cc.CallFunc:create(function(sender, event) self:moveSptCallBack() end),
            cc.RemoveSelf:create()
            ))
        self.pMoveSprite = nil
    end
end

function M:moveSptCallBack()
    self:showCard()
end

-- 设置出牌
function M:setOutCard(bOutCard)
    self.bOutCard = bOutCard
end

return M