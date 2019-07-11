
local GameLeaveRoomLayer = class("GameLeaveRoomLayer", G_BaseLayer)

GameLeaveRoomLayer.RESOURCE_FILENAME = "GameLeaveRoomLayer.csb"

local scheduler =  cc.Director:getInstance():getScheduler()

function GameLeaveRoomLayer:onCreate()
	
end

function GameLeaveRoomLayer:initView()

end

function GameLeaveRoomLayer:initTouch()
	self.resourceNode_.node["Button_1"]:addClickEventListener(handler(self,self.btnDoOk))
	self.resourceNode_.node["Button_2"]:addClickEventListener(handler(self,self.btnDoCancle))
end

function GameLeaveRoomLayer:btnDoOk()
	G_Data.roomid = 0
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_DissolveGameReq")
	if self.schedule_count == nil then
        self.schedule_count = scheduler:scheduleScriptFunc(handler(self,self.scheduleLeave),0.5,false)
	end

end

function GameLeaveRoomLayer:scheduleLeave()
	if self.schedule_count ~= nil then
		scheduler:unscheduleScriptEntry(self.schedule_count)
		self.schedule_count = nil
	end
	G_NetManager:disconnect(NETTYPE_GAME)
	G_SceneManager:enterScene(SCENE_LOBBY)
end

function GameLeaveRoomLayer:btnDoCancle()
	self:removeFromParent()
end

function GameLeaveRoomLayer:onEnter()
	
end

function GameLeaveRoomLayer:addTouch()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function GameLeaveRoomLayer:onTouchBegin()
	return true
end

function GameLeaveRoomLayer:onTouchMove()

end

function GameLeaveRoomLayer:onTouchEnded()

end

function GameLeaveRoomLayer:onExit()
	if self.listener then
		self:getEventDispatcher():removeEventListener(self.listener)
	end
	if self.schedule_count ~= nil then
		scheduler:unscheduleScriptEntry(self.schedule_count)
		self.schedule_count = nil
	end
end

return GameLeaveRoomLayer
