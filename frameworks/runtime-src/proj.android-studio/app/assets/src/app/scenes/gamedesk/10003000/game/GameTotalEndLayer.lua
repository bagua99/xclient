
local GameTotalEndLayer = class("GameTotalEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

GameTotalEndLayer.RESOURCE_FILENAME = GameConfigManager.tGameID.PDK.."/GameTotalEndLayer.csb"

function GameTotalEndLayer:onCreate()
	self.ShareBtn = self.resourceNode_.node["ShareBtn"]
    self.QuitBtn = self.resourceNode_.node["QuitBtn"]
end

function GameTotalEndLayer:initView()
	self.ShareBtn:setVisible(true)
    self.QuitBtn:setVisible(true)
end

function GameTotalEndLayer:initTouch()
	self.ShareBtn:addClickEventListener(handler(self,self.Click_Share))
    self.QuitBtn:addClickEventListener(handler(self,self.Click_Quit))
end

function GameTotalEndLayer:Click_Share()
	ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡跑得快，来战啊！", "Icon-120.png", "http://www.abletele.com/xiaoyou/index.html")
end

function GameTotalEndLayer:Click_Quit()
	G_Data.CL_JoinGameAck.roomid = 0
	G_NetManager:disconnect(NETTYPE_GAME)
	G_SceneManager:enterScene(SCENE_LOBBY)
end

function GameTotalEndLayer:onEnter()
	
end

function GameTotalEndLayer:addTouch()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function GameTotalEndLayer:GameTotalEndAck(tInfo, bDisovleGame)
    
    for i=1, G_GameDefine.nMaxPlayerCount do
		local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i-1)
		local pNode = self.resourceNode_.node["Node_"..i]
		if curPlayerInfo == nil then
			pNode:setVisible(false)
		else
            local pNode_HeadSpr = self.resourceNode_.node["Node_"..i].node["headSpr"..i]
            --pNode_HeadSpr:setTexture(pGameDesk->m_pAvatar->getHeadSpr(i)->getTexture())
            --pNode_HeadSpr:setScale(80 / headSpr->getBoundingBox().size.width, 80/headSpr->getBoundingBox().size.height)

            local pNode_PlayName = self.resourceNode_.node["Node_"..i].node["playname"..i]
            if pNode_PlayName ~= nil then
                pNode_PlayName:setString(curPlayerInfo.szNickName)
            end

            local pNode_PlayID = self.resourceNode_.node["Node_"..i].node["playid"..i]
            if pNode_PlayID ~= nil then
                pNode_PlayID:setString(curPlayerInfo.ullUserID)
            end

            local pNode_TotalScore = self.resourceNode_.node["Node_"..i].node["totalscore"..i]
            if pNode_TotalScore ~= nil then
                pNode_TotalScore:setString(tInfo.lTotalScore[i])
            end

            local pNode_Score = self.resourceNode_.node["Node_"..i].node["score"..i]
            if pNode_Score ~= nil then
                pNode_Score:setString(tInfo.nMaxScore[i])
            end

            local pNode_ZhaDan = self.resourceNode_.node["Node_"..i].node["zhadan"..i]
            if pNode_ZhaDan ~= nil then
                pNode_ZhaDan:setString(tInfo.cbAllBombCount[i])
            end

            local LostCount = G_GameDefine.nGameCount - tInfo.cbWinCount[i]
            if bDisovleGame then
                LostCount = G_GameDefine.nGameCount - 1 - tInfo.cbWinCount[i]
            end
            if LostCount < 0 then
                LostCount = 0
            end
            local pNode_ZhaDan = self.resourceNode_.node["Node_"..i].node["jushu"..i]
            if pNode_ZhaDan ~= nil then
                local str = tInfo.cbWinCount[i].."胜"..LostCount.."负"
                pNode_ZhaDan:setString(str)
            end
        end
    end
end

function GameTotalEndLayer:onExit()
	if self.listener then
		self:getEventDispatcher():removeEventListener(self.listener)
	end
end

return GameTotalEndLayer
