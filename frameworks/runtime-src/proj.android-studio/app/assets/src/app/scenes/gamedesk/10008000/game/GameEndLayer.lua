
local GameEndLayer = class("GameEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

GameEndLayer.RESOURCE_FILENAME = GameConfigManager.tGameID.NN.."/GameEndLayer.csb"

local bit = require("bit")

function GameEndLayer:onCreate()

	self.bToOver = false

    self.ContinueBtn = self.resourceNode_.node["ContinueBtn"]
    self.CloseBtn = self.resourceNode_.node["CloseBtn"]

    self.WinImage = self.resourceNode_.node["WinImage"]
    self.LostImage = self.resourceNode_.node["LostImage"]

    self.tEnd = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        local tData = {}
        tData.Panel = self.resourceNode_.node["Panel_"..i]
        tData.HeadSprite = self.resourceNode_.node["Panel_"..i].node["HeadSprite"]
        tData.NameText = self.resourceNode_.node["Panel_"..i].node["NameText"]
        tData.CardTypeText = self.resourceNode_.node["Panel_"..i].node["CardTypeText"]
        tData.ScoreText = self.resourceNode_.node["Panel_"..i].node["ScoreText"]
        local tCard = {}
        for j=1, 5 do
            tCard[j] = self.resourceNode_.node["Panel_"..i].node["Sprite_"..j]
        end
        tData.tCard = tCard

        self.tEnd[i] = tData
    end
end

function GameEndLayer:initView()

    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tEnd[i].Panel:setVisible(false)
    end

	self.ContinueBtn:setVisible(true)
    self.CloseBtn:setVisible(true)
    self.WinImage:setVisible(false)
    self.LostImage:setVisible(false)
end

function GameEndLayer:initTouch()

	self.ContinueBtn:addClickEventListener(handler(self,self.Click_Continue))
    self.CloseBtn:addClickEventListener(handler(self,self.Click_Close))
end

function GameEndLayer:Click_Continue()

	if self.bToOver then
		G_DeskScene:showOneOver()
	else
		G_DeskScene:Action_Restart(1)
	end
end

function GameEndLayer:Click_Close()

	if self.bToOver then
		G_DeskScene:showOneOver()
	else
		G_DeskScene:Action_Restart(0)
	end
end

function GameEndLayer:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function GameEndLayer:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameEndLayer:onTouchBegin()
	return true
end

function GameEndLayer:onTouchMove()

end

function GameEndLayer:onTouchEnded()

end

function GameEndLayer:GameEndAck(nGameCount, nTotalCount, tInfo)

	if nGameCount >= nTotalCount then
		self.bToOver = true
	else
		self.bToOver = false
	end
    
    local tCardType = 
    {
        "无牛",
        "牛一",
        "牛二",
        "牛三",
        "牛四",
        "牛五",
        "牛六",
        "牛七",
        "牛八",
        "牛九",
        "牛牛",
        "四花牛",
        "五花牛",
    }
    for i=1, G_GameDefine.nMaxPlayerCount do

        local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i-1)
        if curPlayerInfo == nil then
            self.tEnd[i].Panel:setVisible(false)
        else
            self.tEnd[i].Panel:setVisible(true)
            
            -- 名字
            self.tEnd[i].NameText:setString(curPlayerInfo.szNickName)
            self.tEnd[i].NameText:setVisible(true)

            -- 牌型
            self.tEnd[i].CardTypeText:setString(tCardType[tInfo.cbCardType[i]+1])
            self.tEnd[i].CardTypeText:setVisible(true)

            -- 分数
            self.tEnd[i].ScoreText:setString(tInfo.nGameScore[i])
            self.tEnd[i].ScoreText:setVisible(true)

            -- 显示牌
            for j=1, 5 do
                local byCard = tInfo.cbCardData[i][j]
                local szFileName = ""
                local nColor = bit.rshift(byCard, 4)
                local nNum = bit.band(byCard, 0x0F)
                if nNum ~= 0 then
                    szFileName = nColor.."_"..nNum..".png"
	                self.tEnd[i].tCard[j]:setSpriteFrame(szFileName)
                    self.tEnd[i].tCard[j]:setVisible(true)
                end
            end
        end
    end

    -- 是自己,显示输赢
    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if tInfo.nGameScore[nServerSeat+1] >= 0 then
        self.LostImage:setVisible(false)
        self.WinImage:setVisible(true)
    else
        self.LostImage:setVisible(true)
        self.WinImage:setVisible(false)
    end
end

return GameEndLayer
