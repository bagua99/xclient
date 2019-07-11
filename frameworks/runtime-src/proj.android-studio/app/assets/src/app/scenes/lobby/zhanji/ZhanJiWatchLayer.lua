
local ZhanJiWatchLayer = class("ZhanJiWatchLayer", G_BaseLayer)

ZhanJiWatchLayer.RESOURCE_FILENAME = "ZhanJiWatchLayer.csb"

local SearchLayer               = require("app.scenes.lobby.zhanji.SearchLayer")
local ZhanJiWatchCellLayer      = require("app.scenes.lobby.zhanji.ZhanJiWatchCellLayer")

function ZhanJiWatchLayer:onCreate()

end

function ZhanJiWatchLayer:initView()
	self.SearchLayer = SearchLayer.create()
	self.SearchLayer:setVisible(false)
	self:addChild(self.SearchLayer)

	for i = 1,4 do
		self.resourceNode_.node["playname"..i]:setString("")
	end

	self:showItems(G_Data.CL_ReplayDetailAck)

end
function ZhanJiWatchLayer:initTouch()
	self.resourceNode_.node["watchFriendZJ_btn"]:addClickEventListener(handler(self,self.watchOther))
	self.resourceNode_.node["Button_2"]:addClickEventListener(handler(self,self.btnClose))
end

function ZhanJiWatchLayer:watchOther()
	self.SearchLayer:setVisible(true)
end
function ZhanJiWatchLayer:btnClose()
	self:removeFromParent()
end

function ZhanJiWatchLayer:onEnter()


	self.target, self.event_handlermsg = G_Event:addEventListener("receiveMsg",handler(self,self.handleMsg))

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self) 
end
function ZhanJiWatchLayer:onExit()
	G_Event:removeEventListener(self.event_handlermsg)
	self:getEventDispatcher():removeEventListener(self.listener)
end

function ZhanJiWatchLayer:showItems(tbInfo)
	self.m_pListView = ccui.ListView:create()
	self.m_pListView:setAnchorPoint(cc.p(0.5,0.5))
	self.m_pListView:setDirection(ccui.ScrollViewDir.vertical)
    self.m_pListView:setTouchEnabled(true)
    self.m_pListView:setBounceEnabled(false)
    self.m_pListView:setContentSize(cc.size(1010, 400))
    self.m_pListView:setPosition(cc.p(display.width / 2 - 5,display.height / 2 - 45))
    self.m_pListView:setBackGroundColor(cc.c3b(0,0,255))

    self:addChild(self.m_pListView)

    dump(G_Data.CL_ReplayDetailAck)
    for i = 1,G_Data.CL_ReplayDetailAck.count do
    	local iNum = (i-1) % 2 + 1
    	local imageViewTemp = ccui.ImageView:create("ZhanJi/zhanji_img_line"..iNum..".png")
    	imageViewTemp:setName("listView")
    	self.m_pListView:addChild(imageViewTemp)

    	if i == 1 then
    		for j = 1,4 do
    			if string.len(G_Data.CL_ReplayDetailAck.ReplayDetailInfo[i].ReplayWinLose[j].nickname) > 0 then
    				local username = ef.extensFunction:getInstance():safeCopyNumStr(mime.unb64(G_Data.CL_ReplayDetailAck.ReplayDetailInfo[i].ReplayWinLose[j].nickname),5)
    				self.resourceNode_.node["playname"..j]:setString(username)
    			end

    		end

    	end


    	local curCell = ZhanJiWatchCellLayer.new(G_Data.CL_ReplayDetailAck.ReplayDetailInfo[i],i)
    	imageViewTemp:addChild(curCell)

    end
end

function ZhanJiWatchLayer:doImageView(sender)
end

function ZhanJiWatchLayer:handleMsg(event)

end

function ZhanJiWatchLayer:onTouchBegin(touch,event)
	return true
end

function ZhanJiWatchLayer:onTouchMove()
end

function ZhanJiWatchLayer:onTouchEnded(touch,event)
end



return ZhanJiWatchLayer
