
local GameCardManager = class("GameCardManager", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".card.GameCard")

local scheduler = cc.Director:getInstance():getScheduler()

GameCardManager.emptyCard = nil 
GameCardManager.speedOtherPlayer = 0.2 
GameCardManager.speedMe = 0.4 

-- ´´½¨º¯Êý
function GameCardManager:onCreate()

    -- ÊÖÅÆµã
    self.ptStandCard = {}
    self.ptStandCard[1] = cc.p(400, 50)
    self.ptStandCard[2] = cc.p(560, 402)
    self.ptStandCard[3] = cc.p(358, 402)
    self.ptStandCard[4] = cc.p(758, 402)
    self.ptStandCard[5] = cc.p(60, 219)
    self.ptStandCard[6] = cc.p(993, 219)
    self.ptStandCard[7] = cc.p(191, 365)
    self.ptStandCard[8] = cc.p(937, 365)
end

-- ³õÊ¼»¯ÊÓÍ¼
function GameCardManager:initView()
	
    self.tStandCardsBatchNode = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tStandCardsBatchNode[i] = cc.Node:create()
        self:addChild(self.tStandCardsBatchNode[i])
    end
end

-- ³õÊ¼»¯´¥Ãþ
function GameCardManager:initTouch()

end

-- ½øÈë
function GameCardManager:onEnter()

end

-- ÍË³ö
function GameCardManager:onExit()

end

-- »¹Ô­
function GameCardManager:restore()
    
    for i=1, G_GameDefine.nMaxPlayerCount do
	    self.tStandCardsBatchNode[i]:removeAllChildren()
    end
end

-- Çå³ýÏÔÊ¾½áÊøÅÆ
function GameCardManager:clearShowEndCard(nLocalSeat)

    if nLocalSeat == G_GameDefine.nMaxPlayerCount then
        for i=1, G_GameDefine.nMaxPlayerCount do
            self.tStandCardsBatchNode[i]:removeAllChildren()
        end
    else
        self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()
    end
end

function GameCardManager:animalCards(  i,call )
    -- body
    local nLocalSeat = self.players_[i]
    self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()
    local nOffX = self.ptStandCard[nLocalSeat].x
    local nOffY = self.ptStandCard[nLocalSeat].y + 10
    local pGameCard = GameCard:create() 
    local nOffEndX = pGameCard:getContentSize().width/2 + 2 
    local i = 1
    local scale = 0.5 
    if nLocalSeat ~= 1 then 
        nOffEndX = 32 
        scale = 0.3
    end 
    local createCard
    local cbCardCount = 5 
    createCard = function( i )
        -- body
        local pGameCard = GameCard:create()
        pGameCard:setScale(scale)
        pGameCard:setVisible(true)
        pGameCard:setPosition(cc.p(display.cx,display.cy))
        self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard) 
        pGameCard:runAction(cc.Sequence:create(cc.MoveTo:create(0.08,cc.p(nOffX + nOffEndX*(i-1), nOffY)),cc.CallFunc:create(function()
            if i >=cbCardCount then
                --ÏÔÊ¾×Ü½áËã
                if call then call() end 
                return 
            end
            i = i + 1 
            createCard(i)
        end)))
    end
    createCard(1)

end

function GameCardManager:showEmptyCard( )
    -- body
    if self.emptyCard == nil then
        local pGameCard = GameCard:create()
        pGameCard:setScale(0.5)
        pGameCard:setVisible(true)
        pGameCard:setPosition(cc.p(display.cx,display.cy))
        self:addChild(pGameCard)
        self.emptyCard = pGameCard
    end

    local players_ = { }
    for _,v in pairs(G_GamePlayer.players) do
        if v.seat ~= 0 then 
            players_[#players_+1] = G_GamePlayer:getLocalSeat(v.seat)
        end 
    end
    self.players_ = players_
    table.sort(self.players_,function( a,b )
        -- body
        return a < b 
    end)
    local func1 
    func1 = function(i)
        -- body
        if i>#players_ then 
            return 
        end
        --Ö´ÐÐ
        self:animalCards(i,function()
            -- body
            func1(i)
        end)
        i = i + 1 
    end
    func1(1)
end

-- ´´½¨ÏÔÊ¾½áÊøÅÆ
function GameCardManager:createShowEndCard(nLocalSeat, cbCardData, cbCardCount,type,seat,callFinish,call)

    local i = 1
    local children = self.tStandCardsBatchNode[nLocalSeat]:getChildren()
    local size = table.getn(children)
    local scale = 0.5 
    if nLocalSeat ~= 1 then 
        scale = 0.3
    end
    local func1 
    func1 = function( i )
        -- body
        if nLocalSeat ~= 1 then 
            local v = children[i]
            local pGameCard = GameCard:create(cbCardData[i],nLocalSeat)
            local orbit1 = cc.OrbitCamera:create(self.speedOtherPlayer,1, 0, 0, 90, 0, 0)
            pGameCard:setPosition(cc.p(v:getPosition()))
            self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
            pGameCard:setVisible(false)
            local action = cc.Sequence:create(orbit1,cc.CallFunc:create(function(  )
                -- body
                pGameCard:setVisible(true)
                v:removeFromParent()
                i = i  + 1 
                if i == size+1 then
                    self:showNiuReultImg(nLocalSeat,type,seat)
                    if callFinish then callFinish() end  
                    if call then call() end
                else 
                    func1(i)
                end
            end))
            v:runAction(action)
            pGameCard:setScale(scale)
        else

            if i>=size then
                local v = children[i]
                v:setLocalZOrder(1000)
                local pGameCard = GameCard:create(cbCardData[i],nLocalSeat)
                pGameCard:setScale(scale)
                local x = v:getPositionX()
                local y = v:getPositionY()
                pGameCard:setPosition(cc.p(v:getPosition()))
                self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
                local action = cc.Sequence:create(cc.MoveTo:create(2.0,cc.p(x+pGameCard:getContentSize().width/2,y)),cc.CallFunc:create(function(  )
                    -- body
                    -- ½¥Òþ
                    v:runAction(cc.Sequence:create(cc.FadeOut:create(1.0),cc.CallFunc:create(function()
                        -- body
                        v:removeFromParent()
                    end)))
                    i = i  + 1 
                    if i == size+1 then
                        self:showNiuReultImg(nLocalSeat,type,seat)
                        if callFinish then callFinish() end  
                        if call then call() end
                    else 
                        func1(i)
                    end
                end)) 
                v:runAction(action)
            else 
                local v = children[i]
                local pGameCard = GameCard:create(cbCardData[i],nLocalSeat)
                local orbit1 = cc.OrbitCamera:create(self.speedMe,1, 0, 0, 90, 0, 0)
                pGameCard:setPosition(cc.p(v:getPosition()))
                self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
                pGameCard:setVisible(false)
                local action = cc.Sequence:create(orbit1,cc.CallFunc:create(function(  )
                    -- body
                    pGameCard:setVisible(true)
                    v:removeFromParent()
                    i = i  + 1 
                    if i == size+1 then
                        self:showNiuReultImg(nLocalSeat,type,seat)
                        if callFinish then callFinish() end  
                        if call then call() end
                    else 
                        func1(i)
                    end
                end))
                v:runAction(action)
                pGameCard:setScale(scale)
            end 
        end 
    end
    func1(1)
end

function GameCardManager:showNiuReultImg( nLocalSeat,type,seat )
    local children = self.tStandCardsBatchNode[nLocalSeat]:getChildren()
    local result = ccui.ImageView:create()
    local img = string.format("nnResult_niu%d.png",type)    
    result:loadTexture(img, ccui.TextureResType.plistType)
    result:setVisible(true)
    local offy = 15
    if nLocalSeat~=1 then 
        offy = 10 
    end 
    local sound     
    local player = G_GamePlayer:getPlayerBySeverSeat(seat)
    if player.sex == 1 then
        local sound_ = string.format("n%d.mp3",type)
        sound = "Music/"..GameConfigManager.tGameID.NN.."/man/"..sound_
    else
        local sound_fe = string.format("f1_nn%d_2.mp3",type)
        sound = "Music/"..GameConfigManager.tGameID.NN.."/woman/"..sound_fe
    end
    G_GameDeskManager.Music:playSound(sound,false)
    result:setPosition(cc.p(children[3]:getPositionX(),children[3]:getPositionY()+offy))
    self.tStandCardsBatchNode[nLocalSeat]:addChild(result)
end

return GameCardManager
