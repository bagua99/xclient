
local JoinRoomLayer = class("JoinRoomLayer",G_BaseLayer)
JoinRoomLayer.RESOURCE_FILENAME = "JoinRoomLayer.csb"

function JoinRoomLayer:onCreate()
	self.m_strRoomId = ""
end

function JoinRoomLayer:initView()

	self.m_textAlas = self.resourceNode_.node["AtlasLabel"]
	self.m_textAlas:setString(self.m_strRoomId)
end
function JoinRoomLayer:initTouch()

	self.resourceNode_.node["closeBtn"]:addClickEventListener(handler(self,self.Click_Close))
    self.resourceNode_.node["reset_btn"]:addClickEventListener(handler(self,self.Click_Reset))
    self.resourceNode_.node["delete_btn"]:addClickEventListener(handler(self,self.Click_delete))

	self.tb_numText = {}
	for i=0,9 do
		self.tb_numText[i] = self.resourceNode_.node["Button_"..i]
		self.tb_numText[i]:setTouchEnabled(true)
		self.tb_numText[i]:setTag(i)
		self.tb_numText[i]:addClickEventListener(handler(self,self.btnNum))
	end
end

function JoinRoomLayer:btnNum(sender)

	local iTag = sender:getTag()
	if iTag < 10 then

		if string.len(self.m_strRoomId) >= 6 then
			return
		end

		self.m_strRoomId = self.m_strRoomId..tostring(iTag)
		self.m_textAlas:setString(self.m_strRoomId)
		if string.len(self.m_strRoomId) >= 6 then
			G_Data.CL_JoinGameReq = {}
			G_Data.CL_JoinGameReq.roomid = tonumber(self.m_strRoomId)
			G_Data.CL_JoinGameReq.mode = 1
			G_NetManager:sendMsg(NETTYPE_LOGIN,"CL_JoinGameReq")
			return
		end
	end
	self.m_textAlas:setString(self.m_strRoomId)
end

-- 关闭
function JoinRoomLayer:Click_Close()

	self:setVisible(false)
end

-- 重置
function JoinRoomLayer:Click_Reset()

	self.m_strRoomId = ""
    self.m_textAlas:setString(self.m_strRoomId)
end

-- 删除
function JoinRoomLayer:Click_delete()

	self.m_strRoomId = string.sub(self.m_strRoomId,1,-2)
    self.m_textAlas:setString(self.m_strRoomId)
end

function JoinRoomLayer:onEnter()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self) 
end
function JoinRoomLayer:onExit()

	self:getEventDispatcher():removeEventListener(self.listener)
end

function JoinRoomLayer:onTouchBegin()

	if self:isVisible() then
		return true
	else
		return false
	end
end

function JoinRoomLayer:onTouchMove()
end

function JoinRoomLayer:onTouchEnded()
end

return JoinRoomLayer
