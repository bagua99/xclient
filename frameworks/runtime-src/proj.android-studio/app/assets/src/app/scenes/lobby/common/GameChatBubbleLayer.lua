
local GameChatBubbleLayer = class("GameChatBubbleLayer", G_BaseLayer)

GameChatBubbleLayer.RESOURCE_FILENAME = "GameChatBubbleLayer.csb"

function GameChatBubbleLayer:onCreate()
	self.nType = -1
	self.nRow = 1
	self.ImageView = nil

    -- 背景
    self.Image_Bg            = self.resourceNode_.node["Image_Bg"]

    -- 文字
    self.Text_Content        = self.resourceNode_.node["ScrollView_Content"].node["Text_Content"]
end

function GameChatBubbleLayer:initView()

    self.Image_Bg:setVisible(false)
end

function GameChatBubbleLayer:initTouch()
	
end

function GameChatBubbleLayer:setFace(nLocalSeat, nFaceID)

	self.nType = 0

	local strName = "Chat/LT_BQ_"..nFaceID..".png"
	self.ImageView = ccui.ImageView:create(strName)

	local tPoint = {cc.p(123, 164), cc.p(123, 455), cc.p(600, 455)}
	self.ImageView:setPosition(tPoint[nLocalSeat])
    self.resourceNode_:setVisible(false)
	self:addChild(self.ImageView)
end

function GameChatBubbleLayer:setChat(nLocalSeat, strContent)

    local tPoint = {cc.p(123, 164), cc.p(123, 455), cc.p(600, 455)}
	self:setPosition(tPoint[nLocalSeat])

	if nLocalSeat == 1 then
		self.Image_Bg:setScaleX(1)
		self.Image_Bg:setScaleY(1)
	elseif nLocalSeat == 2 then
		self.Image_Bg:setScaleX(1)
		self.Image_Bg:setScaleY(1)
	elseif nLocalSeat == 3 then
		self.Image_Bg:setScaleX(1)
		self.Image_Bg:setScaleY(-1)
	end

	self.nType = 1

	local nLength = ef.extensFunction:getInstance():getStrLen(strContent)
	self.nRow = math.floor(nLength / 10) + 1
	self.Text_Content:setTextAreaSize(cc.size(320,30*self.nRow))
	self.Text_Content:setString(strContent)
end

function GameChatBubbleLayer:onEnter()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)

	if self.nType == 0 then
		self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,5)),cc.MoveBy:create(0.5,cc.p(0,-5)))))
		self.ImageView:runAction(cc.Sequence:create(cc.FadeOut:create(4), cc.CallFunc:create(handler(self,self.onRemove))))					        
	elseif self.nType == 1 then
		self.Text_Content:runAction(cc.Sequence:create(cc.MoveBy:create(self.nRow*2,cc.p(0,40*self.nRow)),cc.CallFunc:create(handler(self,self.onRemove))))
    else
        self:onRemove()
	end
end

function GameChatBubbleLayer:onExit()

	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameChatBubbleLayer:onRemove()

	self:removeFromParent()
end

function GameChatBubbleLayer:onTouchBegin()
	return true
end

function GameChatBubbleLayer:onTouchMove()

end

function GameChatBubbleLayer:onTouchEnded()

end

return GameChatBubbleLayer
