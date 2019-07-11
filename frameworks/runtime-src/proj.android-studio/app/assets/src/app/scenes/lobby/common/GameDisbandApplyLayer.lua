
local GameDisbandApplyLayer = class("GameDisbandApplyLayer", G_BaseLayer)

GameDisbandApplyLayer.RESOURCE_FILENAME = "GameDisbandApplyLayer.csb"

function GameDisbandApplyLayer:onCreate()

    self.ListView = self.resourceNode_.node["PanelMain"].node["ListView"]
    self.tPlayer = {}
    
    self.ContentText = self.resourceNode_.node["PanelMain"].node["ContentText"]
end

function GameDisbandApplyLayer:initView()

    for i=1, G_GameDefine.nMaxPlayerCount do
        local pText = ccui.Text:create("","Arial",20)
        pText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        pText:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        pText:setAnchorPoint(cc.p(0.5, 0.5))
        pText:setPosition(cc.p(0, 55))
        pText:setColor(cc.c3b(255, 255, 255))
        pText:setContentSize(cc.size(400,40))
        pText:ignoreContentAdaptWithSize(false)
        pText:setVisible(false)
        self.ListView:addChild(pText)

        self.tPlayer[i] = pText
    end

	local iCount = 0
	for i=1, G_GameDefine.nPlayerCount do
		local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i-1)
		if curPlayerInfo ~= nil then
			if G_GamePlayer:getLocalSeat(i-1) == 1 then
				local strInfo = string.format("玩家[%s]申请解散本局游戏,请等待其他玩家选择是否同意解散!(超过10分钟未选择,默认为其他玩家同意解散,未完成当局解散房间按当前分数结算!)",string.trim(curPlayerInfo["szNickName"]))
				self.ContentText:setString(strInfo)
			else
                iCount = iCount + 1
				local strInfo = string.format("玩家[%s] 等待选择",curPlayerInfo["szNickName"])
                self.tPlayer[iCount]:setString(strInfo)
                self.tPlayer[iCount]:setTag(i-1)
                self.tPlayer[iCount]:setVisible(true)
			end
		end
	end
end

function GameDisbandApplyLayer:initTouch()

end

function GameDisbandApplyLayer:DissolveGameVoteAck(tInfo)

	for i=1, G_GameDefine.nPlayerCount do
		if self.tPlayer[i]:getTag() == tInfo.wChairID then
			local curPlayer = G_GamePlayer:getPlayerBySeverSeat(tInfo.wChairID)
            if curPlayer ~= nil then
			    local strResult = (tInfo.bApprove == 0) and "拒绝" or "同意"
			    local strInfo = string.format("玩家[%s] %s", curPlayer["szNickName"], strResult)
                self.tPlayer[i]:setString(strInfo)
			    self.tPlayer[i]:setVisible(true)
			    break
            end
		end
	end
end

function GameDisbandApplyLayer:refreshUserName(szNickName, nServerSeat, bVoteStatus, bVoteNote)

	for i=1, G_GameDefine.nPlayerCount do
		if self.tPlayer[i]:getTag() == nServerSeat then

			local strInfo = string.format("玩家[%s] 等待选择",szNickName)
            local strResult = (bVoteNote == 0) and "拒绝" or "同意"
			if bVoteStatus ~= 0 then
				strInfo = string.format("玩家[%s] %s", szNickName, strResult)
			end
			
            self.tPlayer[i]:setString(strInfo)
			self.tPlayer[i]:setVisible(true)
		end
	end
end

function GameDisbandApplyLayer:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function GameDisbandApplyLayer:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameDisbandApplyLayer:onTouchBegin(touch, event)
	return true
end

function GameDisbandApplyLayer:onTouchMove()
	
end

function GameDisbandApplyLayer:onTouchEnded(touch, event)
	
end

return GameDisbandApplyLayer
