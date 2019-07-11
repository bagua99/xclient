
local M = class("GameEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.NN.."/GameEndLayer.csb"

local bit = require("bit")

function M:onCreate()
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

function M:initView()
    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tEnd[i].Panel:setVisible(false)
    end

	self.ContinueBtn:setVisible(true)
    self.CloseBtn:setVisible(true)
    self.WinImage:setVisible(false)
    self.LostImage:setVisible(false)
end

function M:initTouch()
	self.ContinueBtn:addClickEventListener(handler(self,self.Click_Continue))
    self.CloseBtn:addClickEventListener(handler(self,self.Click_Close))
end

function M:Click_Continue()
	if self.bToOver then
		G_DeskScene:showGameTotalEnd()
	else
		G_DeskScene:Action_Restart(1)
	end
end

function M:Click_Close()
	if self.bToOver then
		G_DeskScene:showGameTotalEnd()
	else
		G_DeskScene:Action_Restart(0)
	end
end

function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)

    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.resourceNode_.node["BG"]:addChild(curColorLayer)
end

function M:onExit()
    if self.listener then
	    self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end

function M:onTouchBegin()
	return self:isVisible()
end

function M:onTouchMove()

end

function M:onTouchEnded()

end

function M:GameEndAck(nGameCount, nTotalCount, tInfo,isTotalConclude)
    self.bToOver = isTotalConclude 
    
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
	local nServerSeat = G_GamePlayer:getServerSeat(1)
    for _, info in ipairs(tInfo.infos) do
		local i = info.seat
        local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(info.seat)
        if curPlayerInfo == nil then
            self.tEnd[i].Panel:setVisible(false)
        else
            self.tEnd[i].Panel:setVisible(true)
            -- 名字
            local szNickName = curPlayerInfo.nickname
            local len = string.len(szNickName)
            if len>12 then 
                szNickName = string.sub(szNickName,1,12).."..."
            end
            self.tEnd[i].NameText:setString(szNickName)
            self.tEnd[i].NameText:setVisible(true)

            -- 牌型
            self.tEnd[i].CardTypeText:setString(tCardType[info.type+1])
            self.tEnd[i].CardTypeText:setVisible(true)

            -- 分数
            self.tEnd[i].ScoreText:setString(info.score)
            self.tEnd[i].ScoreText:setVisible(true)

            -- 显示牌
            for j=1, 5 do
                local byCard = info.cards[j]
                local szFileName = ""
                local nColor = bit.rshift(byCard, 4)
                local nNum = bit.band(byCard, 0x0F)
                if nNum ~= 0 then
                    szFileName = nColor.."_"..nNum..".png"
	                self.tEnd[i].tCard[j]:setSpriteFrame(szFileName)
                    self.tEnd[i].tCard[j]:setVisible(true)
                end
            end
			
			-- 是自己,显示输赢
			if nServerSeat == info.seat then
				if info.score >= 0 then
					self.LostImage:setVisible(false)
					self.WinImage:setVisible(true)
				else
					self.LostImage:setVisible(true)
					self.WinImage:setVisible(false)
				end
			end
        end
    end
end

return M
