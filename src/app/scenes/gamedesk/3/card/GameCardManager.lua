
local GameCardManager = class("GameCardManager", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".card.GameCard")
local logic                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".logic.logic")

local scheduler = cc.Director:getInstance():getScheduler()

GameCardManager.emptyCard = nil 
GameCardManager.speedOtherPlayer = 0.02 
GameCardManager.speedMe = 0.01

local bit = require("bit")

-- ´´½¨º¯Êý
function GameCardManager:onCreate()

    -- ÊÖÅÆµã
    self.ptStandCard = {}
    self.ptStandCard[1] = cc.p(400,60)
    self.ptStandCard[4] = cc.p(268,380)
    self.ptStandCard[3] = cc.p(788,380)
    self.ptStandCard[5] = cc.p(160,240)
    self.ptStandCard[2] = cc.p(883,185)
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

function GameCardManager:animalCards(  i,call ,me )
    -- body
    local nLocalSeat = self.players_[i]
    self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()
    local nOffX = self.ptStandCard[nLocalSeat].x
    local nOffY = self.ptStandCard[nLocalSeat].y + 10
    local pGameCard = GameCard:create() 
    local nOffEndX = pGameCard:getContentSize().width/2 + 2 
    local i = 1
    local scale = 0.60
    if nLocalSeat ~= 1 then 
        nOffEndX = 32 
        scale = 0.60
        nOffX = self.ptStandCard[nLocalSeat].x - 5
        nOffY = self.ptStandCard[nLocalSeat].y - 5 
    end 
    local createCard
    local cbCardCount = 5 
    createCard = function( i )
        -- body
        local pGameCard = GameCard:create()
        pGameCard:setScale(scale)
        pGameCard:setVisible(true)
        pGameCard:setPosition(cc.p(display.cx,display.cy+150))
        self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard) 
        pGameCard:runAction(cc.Sequence:create(cc.MoveTo:create(0.005,cc.p(nOffX + nOffEndX*(i-1), nOffY)),cc.CallFunc:create(function()
            if i >=cbCardCount then
                --ÏÔÊ¾×Ü½áËã
                if call then
                    call() 
                end 
                return 
            end
            i = i + 1 
            createCard(i)
        end)))
    end
    if me then 
        createCard(2)
    else 
        createCard(1)
    end
end

function GameCardManager:showEmptyCard( call , me )
    -- body
    if self.emptyCard == nil then
        local pGameCard = GameCard:create()
        pGameCard:setScale(0.8)
        pGameCard:setVisible(true)
        pGameCard:setPosition(cc.p(display.cx,display.cy+150))
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
            if self.emptyCard  then 
                self.emptyCard:removeFromParent()
                self.emptyCard = nil
                if call then
                    self.players_ = { } 
                    call()
                end  
            end  
            return 
        end
        --Ö´ÐÐ
        self:animalCards(i,function()
            -- body
            func1(i)
        end,me)
        i = i + 1 
    end
    func1(1)
    local sound = "Music/3/score/fapai.mp3"
    G_GameDeskManager.Music:playSound(sound,false)
end

-- ´´½¨ÏÔÊ¾½áÊøÅÆ
function GameCardManager:createShowEndCard(nLocalSeat, cbCardData, cbCardCount,type,seat,callFinish,call)

    local i = 1
    local children = self.tStandCardsBatchNode[nLocalSeat]:getChildren()
    local size = table.getn(children)
    local scale = 0.8
    if nLocalSeat ~= 1 then 
        scale = 0.6
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
                local action = cc.Sequence:create(cc.MoveTo:create(0.03,cc.p(x+pGameCard:getContentSize().width/2,y)),cc.CallFunc:create(function(  )
                    -- body
                    -- ½¥Òþ
                    v:runAction(cc.Sequence:create(cc.FadeOut:create(0.02),cc.CallFunc:create(function()
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
    -- body
    local children = self.tStandCardsBatchNode[nLocalSeat]:getChildren() 
    local result = ccui.ImageView:create()
    local img = string.format("nnResult_niu%d.png",type)    
    result:loadTexture(img, ccui.TextureResType.plistType)
    result:setVisible(true)
    result:setScale(1.0)
    local offy = 15
    if nLocalSeat~=1 then 
        offy = 10 
    end 
    local sound     
    local player = G_GamePlayer:getPlayerBySeverSeat(seat)
    if player.sex == 1 then
        local sound_ = string.format("n%d.mp3",type)
        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/man/"..sound_
    else
        local sound_fe = string.format("f1_nn%d_2.mp3",type)
        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/woman/"..sound_fe
    end
    G_GameDeskManager.Music:playSound(sound,false)
    result:setPosition(cc.p(children[3]:getPositionX(),children[3]:getPositionY()+offy))
    self.tStandCardsBatchNode[nLocalSeat]:addChild(result)
end

function GameCardManager:ShowEndCardSimple(nLocalSeat,cbCardData,call)
    local children = self.tStandCardsBatchNode[nLocalSeat]:getChildren()
    local size = table.getn(children)
    local scale = 0.6
    local func1
    func1 = function( i )
        -- body
        if i>=size and nLocalSeat==1 then
            local v = children[i]
            v:setLocalZOrder(1000)
            local pGameCard = GameCard:create(cbCardData[i],nLocalSeat)
            pGameCard:setScale(scale)
            local x = v:getPositionX()
            local y = v:getPositionY()
            pGameCard:setPosition(cc.p(v:getPosition()))
            self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
            local action = cc.Sequence:create(cc.MoveTo:create(0.05,cc.p(x+pGameCard:getContentSize().width/2,y)),cc.CallFunc:create(function(  )
                -- body
                -- ½¥Òþ
                v:runAction(cc.Sequence:create(cc.FadeOut:create(0.02),cc.CallFunc:create(function()
                    -- body
                    v:removeFromParent()
                    if call then call() end 
                end)))
                i = i  + 1
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
                    if call then call() end 
                else 
                    func1(i)
                end
            end))
            v:runAction(action)
            pGameCard:setScale(scale)
        end 
    end
    func1(1)
end 


function GameCardManager:ShowEndCardAuto(nLocalSeat,cbCardData,type,seat)
    local hasNN = logic.getOxCard(cbCardData)
    local children = self.tStandCardsBatchNode[nLocalSeat]:getChildren()
    local size1 = table.getn(children)
    for i=1,#cbCardData  do 
        local data = cbCardData[i]
        local nColor = bit.rshift(data,4)
        local nNum = bit.band(data,0x0F)
        local szFileName = nColor.."_"..nNum..".png"
        children[i]:setSpriteFrame(szFileName)
        if hasNN and (i==1 or i==2 or i==3)  then
            local x = children[i]:getPositionX() 
            children[i]:setPositionX(x-20)                
        end
        if nLocalSeat~=1 then 
            children[i]:setScale(0.6)
        end  
    end
    local result = ccui.ImageView:create()
    local img = string.format("nnResult_niu%d.png",type)    
    result:loadTexture(img, ccui.TextureResType.plistType)
    result:setVisible(true)
    result:setScale(0.6)
    local offy = 0
    if nLocalSeat~=1 then 
        offy = 0 
    end 

    local sound     
    local player = G_GamePlayer:getPlayerBySeverSeat(seat)
    if player.sex == 1 then
        local sound_ = string.format("n%d.mp3",type)
        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/man/"..sound_
    else
        local sound_fe = string.format("f1_nn%d_2.mp3",type)
        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/woman/"..sound_fe
    end
    G_GameDeskManager.Music:playSound(sound,false)
    result:setPosition(cc.p(children[3]:getPositionX(),children[3]:getPositionY()+offy))
    self.tStandCardsBatchNode[nLocalSeat]:addChild(result)
    --移动牌的位置
end

return GameCardManager
