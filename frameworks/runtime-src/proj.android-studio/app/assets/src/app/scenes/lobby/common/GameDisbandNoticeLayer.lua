local scheduler =  cc.Director:getInstance():getScheduler()

local GameDisbandNoticeLayer = class("GameDisbandNoticeLayer",G_BaseLayer)

GameDisbandNoticeLayer.RESOURCE_FILENAME = "GameDisbandNoticeLayer.csb"

function GameDisbandNoticeLayer:onCreate()
	
    self.OkBtn = self.resourceNode_.node["PanelMain"].node["OkBtn"]
    self.CancelBtn = self.resourceNode_.node["PanelMain"].node["CancelBtn"]
    self.ContentText = self.resourceNode_.node["PanelMain"].node["ContentText"]
    self.AlarmClockImage = self.resourceNode_.node["PanelMain"].node["AlarmClockImage"]
    self.AlarmClockAtlasLabel = self.resourceNode_.node["PanelMain"].node["AlarmClockImage"].node["AlarmClockAtlasLabel"]

    self.nTime = 599
end

function GameDisbandNoticeLayer:initView()

    self.OkBtn:setVisible(true)
    self.CancelBtn:setVisible(true)
    self.ContentText:setVisible(true)
    self.AlarmClockImage:setVisible(true)
    self.AlarmClockAtlasLabel:setVisible(true)
end

function GameDisbandNoticeLayer:initTouch()

	self.OkBtn:addClickEventListener(handler(self,self.Click_Ok))
	self.CancelBtn:addClickEventListener(handler(self,self.dClick_Cancle))
end

function GameDisbandNoticeLayer:setUserName(strName)

	local strInfo = "玩家["..strName.."]申请解散本局游戏,请等待其他玩家选择是否同意解散!(超过10分钟未选择,默认为其他玩家同意解散,未完成当局解散房间按当前分数结算!)"
	self.ContentText:setString(strInfo)
end

function GameDisbandNoticeLayer:Click_Ok()

    self:removeFromParent()

	G_Data.GAME_DissolveGameVoteReq = {}
    G_Data.GAME_DissolveGameVoteReq.bApprove = true
    G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_DissolveGameVoteReq")
end

function GameDisbandNoticeLayer:dClick_Cancle()

    self:removeFromParent()

	G_Data.GAME_DissolveGameVoteReq = {}
    G_Data.GAME_DissolveGameVoteReq.bApprove = false
    G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_DissolveGameVoteReq")
end

function GameDisbandNoticeLayer:updateText()

	self.nTime = self.nTime - 1
	if self.nTime < 0 then
		G_Data.GAME_DissolveGameVoteReq = {}
    	G_Data.GAME_DissolveGameVoteReq.bApprove = 1
    	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME,"GAME_DissolveGameVoteReq")
		scheduler:unscheduleScriptEntry(self.schedule_warn)
		self.schedule_update = nil
		self:removeFromParent()
	end
	self.AlarmClockAtlasLabel:setString(self.nTime)
end

function GameDisbandNoticeLayer:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
	self.schedule_update = scheduler:scheduleScriptFunc(handler(self, self.updateText),1,false)
end

function GameDisbandNoticeLayer:onExit()

	self:getEventDispatcher():removeEventListener(self.listener)
	if self.schedule_update then
		scheduler:unscheduleScriptEntry(self.schedule_update)
		self.schedule_update = nil
	end
end

function GameDisbandNoticeLayer:onTouchBegin(touch, event)
	return true
end

function GameDisbandNoticeLayer:onTouchMove()
	
end

function GameDisbandNoticeLayer:onTouchEnded(touch, event)

end

return GameDisbandNoticeLayer
