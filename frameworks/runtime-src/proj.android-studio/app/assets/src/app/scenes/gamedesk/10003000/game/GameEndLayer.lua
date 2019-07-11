
local GameEndLayer = class("GameEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

GameEndLayer.RESOURCE_FILENAME = GameConfigManager.tGameID.PDK.."/GameEndLayer.csb"

function GameEndLayer:onCreate()
	self.bToOver = false

    self.ContinueBtn = self.resourceNode_.node["ContinueBtn"]
    self.CloseBtn = self.resourceNode_.node["CloseBtn"]

    self.WinImage = self.resourceNode_.node["WinImage"]
    self.LostImage = self.resourceNode_.node["LostImage"]
end

function GameEndLayer:initView()
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
    
    for i=1, G_GameDefine.nMaxPlayerCount do

        local pNode = self.resourceNode_.node["Node_name"..i]

        local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i-1)
        if curPlayerInfo == nil then
            pNode:setVisible(false)
        else

            local pNode_NameText = self.resourceNode_.node["Node_name"..i].node["name"..i]
            if pNode_NameText ~= nil then
                pNode_NameText:setString(curPlayerInfo.szNickName)
            end
            
            local pNode_ScoreText = self.resourceNode_.node["Node_name"..i].node["score"..i]
            if pNode_ScoreText ~= nil then
                pNode_ScoreText:setString(tInfo.lGameScore[i])
            end

            local pNode_PaiText = self.resourceNode_.node["Node_name"..i].node["pai"..i]
            if pNode_PaiText ~= nil then
                pNode_PaiText:setString(tInfo.cbCardCount[i])
            end
            
            local pNode_ZhaDanText = self.resourceNode_.node["Node_name"..i].node["zhadan"..i]
            if pNode_ZhaDanText ~= nil then
                pNode_ZhaDanText:setString(tInfo.cbBombCount[i])
            end
        end
    end

    -- 是自己,显示输赢
    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if tInfo.lGameScore[nServerSeat+1] > 0 then
        self.LostImage:setVisible(false)
        self.WinImage:setVisible(true)
    else
        -- 等于0，手牌剩余0，别人剩余一张，自己出完，也是0分，这时候要显示胜利
        if tInfo.lGameScore[nServerSeat+1] == 0 and tInfo.cbCardCount[nServerSeat+1] == 0 then
            self.LostImage:setVisible(false)
            self.WinImage:setVisible(true)
        else
            self.LostImage:setVisible(true)
            self.WinImage:setVisible(false)
        end
    end
end

return GameEndLayer
