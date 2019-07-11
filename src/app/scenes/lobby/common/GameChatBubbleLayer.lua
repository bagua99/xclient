
local M = class("GameChatBubbleLayer", G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/GameChat/GameChatBubbleLayer.csb"

-- 创建
function M:onCreate()
	self.nType = -1
	self.nRow = 1
	self.ImageView = nil

    -- 背景
    self.Image_Bg            = self.resourceNode_.node["Image_Bg"]

    -- 文字
    self.Text_Content        = self.resourceNode_.node["ScrollView_Content"].node["Text_Content"]
end

-- 初始视图
function M:initView()
    self.Image_Bg:setVisible(true)
end

-- 初始触摸
function M:initTouch()
	
end

-- 进入场景
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)

	if self.nType == 0 then
		self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,5)),cc.MoveBy:create(0.5,cc.p(0,-5)))))
		self.ImageView:runAction(cc.Sequence:create(cc.FadeOut:create(2), cc.CallFunc:create(handler(self, self.Remove))))					        
	elseif self.nType == 1 then
		self.Text_Content:runAction(cc.Sequence:create(cc.MoveBy:create(self.nRow*1.0,cc.p(0,18*self.nRow)), cc.CallFunc:create(handler(self, self.Remove))))
    else
        self:Remove()
	end
end

-- 退出场景
function M:onExit()
    if self.listener then
	    self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end

-- 触摸开始
function M:onTouchBegin()
	return self:isVisible()
end

-- 触摸移动
function M:onTouchMove()

end

-- 触摸结束
function M:onTouchEnded()

end

-- 移除
function M:Remove()
	self:removeFromParent()
end

-- 设置表情
function M:setFace(nLocalSeat, nFaceID,isNN)
	self.nType = 0

	local strName = "LT_BQ_"..nFaceID..".png"
	self.ImageView = ccui.ImageView:create()
	self.ImageView:loadTexture(strName, ccui.TextureResType.plistType)

	local tPoint = {cc.p(123, 164), cc.p(143, 255), cc.p(960,255)}
	if isNN == true then
    	tPoint = {cc.p(123, 164), cc.p(953,240), cc.p(630,435),cc.p(200,435),cc.p(100,255)}
    end
    
	self.ImageView:setPosition(tPoint[nLocalSeat])
    self.resourceNode_:setVisible(false)
	self:addChild(self.ImageView)
end

-- 设置聊天
function M:setChat(nLocalSeat, strContent, isNN)
    local tPoint = {cc.p(123, 154), cc.p(133, 255), cc.p(620,255)}
    if isNN == true then 
    	tPoint = {cc.p(123, 164), cc.p(593,240), cc.p(530,335),cc.p(200,345),cc.p(100,255)}
    end
	self:setPosition(tPoint[nLocalSeat])
	if isNN == false or isNN == nil  then
		if nLocalSeat == 1 then
		
		elseif nLocalSeat == 2 then		
			
		elseif nLocalSeat == 3 then
			self.Image_Bg:setFlipX(true)
		end
	else
		if nLocalSeat == 1 then
		
		elseif nLocalSeat == 2 then
			self.Image_Bg:setFlipX(true)
		elseif nLocalSeat == 3 then
			self.Image_Bg:setFlipX(true)
			self.Image_Bg:setFlipY(true)
		elseif nLocalSeat == 4 then 
			self.Image_Bg:setFlipY(true)
		elseif nLocalSeat == 5 then 
		
		end
	end 
	self.nType = 1
	local nLength = ef.extensFunction:getInstance():getStrLen(strContent)
	self.nRow = math.floor(nLength / 10) + 1
	self.Text_Content:setTextAreaSize(cc.size(320,30*self.nRow))
	dump(strContent)
	self.Text_Content:setString(strContent)
end

return M
