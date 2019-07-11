local M = class("JoinRoomLayer",G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/JoinRoom/JoinRoomLayer.csb"

-- 创建
function M:onCreate()
    self.ResetBtn = self.resourceNode_.node["ResetBtn"]
    self.DeleteBtn = self.resourceNode_.node["DeleteBtn"]
    self.CloseBtn = self.resourceNode_.node["CloseBtn"]
    self.BG = self.resourceNode_.node["BG1"]

    self.AtlasLabel = self.resourceNode_.node["AtlasLabel"]
    self.strRoomId = ""

    self.tbl_Button = {}
    for i=0, 9 do
		self.tbl_Button[i] = self.resourceNode_.node["Button_"..i]
	end
end

-- 初始视图
function M:initView()
    self.ResetBtn:setVisible(true)
    self.DeleteBtn:setVisible(true)
    self.CloseBtn:setVisible(true)
	self.AtlasLabel:setString(self.strRoomId)
    self.AtlasLabel:setVisible(true)
end

-- 初始触摸
function M:initTouch()
    self.ResetBtn:addClickEventListener(handler(self,self.Click_Reset))
    self.DeleteBtn:addClickEventListener(handler(self,self.Click_Delete))
    self.CloseBtn:addClickEventListener(handler(self,self.Click_Close))

	for index, pButton in pairs(self.tbl_Button) do
		pButton:setTouchEnabled(true)
		pButton:setTag(index)
		pButton:addClickEventListener(handler(self, self.Click_Num))
	end
end

-- 进入场景
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self) 

    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    self.target, self.event_clearInputNumber = G_Event:addEventListener("sendMsg_clearInputNumber", handler(self,self.clearInputNumber))
end

-- 退出场景
function M:onExit()
    if self.listener then
	    self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
    if self.event_clearInputNumber then
	    G_Event:removeEventListener(self.event_clearInputNumber)
        self.event_clearInputNumber = nil
    end
end

-- 触摸开始
function M:onTouchBegin(touch, event)
	return self:isVisible()
end

-- 触摸移动
function M:onTouchMove(touch, event)

end

-- 触摸结束
function M:onTouchEnded(touch, event)

end

-- 点击数字
function M:Click_Num(sender)
	G_CommonFunc:addClickSound()
	local nTag = sender:getTag()
	if nTag < 10 then
		if string.len(self.strRoomId) >= 6 then
			return
		end
		self.strRoomId = self.strRoomId..tostring(nTag)
		self.AtlasLabel:setString(self.strRoomId)
		if string.len(self.strRoomId) >= 6 then
			local msg = {
				roomid = tonumber(self.strRoomId),
				userid = G_Data.UserBaseInfo.userid,
				sign = G_Data.UserBaseInfo.sign,
				account = G_Data.UserBaseInfo.account,
				nickname = G_Data.UserBaseInfo.nickname,
				headimgurl = G_Data.UserBaseInfo.headimgurl,
				sex = G_Data.UserBaseInfo.sex,
			}
			G_Event:dispatchEvent({name="sendMsg_JoinRoom", msg=msg})
			return
		end
	end
	self.AtlasLabel:setString(self.strRoomId)
end

-- 重置
function M:Click_Reset()
	G_CommonFunc:addClickSound()
	self.strRoomId = ""
    self.AtlasLabel:setString(self.strRoomId)
end

-- 删除
function M:Click_Delete()
	G_CommonFunc:addClickSound()
	self.strRoomId = string.sub(self.strRoomId, 1, -2)
    self.AtlasLabel:setString(self.strRoomId)
end

-- 关闭
function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:setVisible(false)
    -- 关闭回调
    if self.call then
        self.call()
    end
end

-- 关闭回调
function M:addCloseListener(call)
    self.call = call
end

function M:clearInputNumber( )
	-- body
	self.strRoomId = ""
    self.AtlasLabel:setString(self.strRoomId)
end

return M
