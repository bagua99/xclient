
local GameChatLayer = class("GameChatLayer",G_BaseLayer)

local GameChatBubbleLayer       = require("app.scenes.lobby.common.GameChatBubbleLayer")
local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

GameChatLayer.RESOURCE_FILENAME = "GameChatLayer.csb"

function GameChatLayer:onCreate()

    -- 发送按钮
    self.SendBtn            = self.resourceNode_.node["SendBtn"]
    -- 表情按钮
    self.FaceBtn            = self.resourceNode_.node["FaceBtn"]
    -- 聊天按钮
    self.ChatBtn            = self.resourceNode_.node["ChatBtn"]
    -- 聊天记录
    self.ChatListBtn        = self.resourceNode_.node["ChatListBtn"]
    -- 关闭按钮
    self.CloseBtn           = self.resourceNode_.node["CloseBtn"]

    -- 图片表情
    self.tImageFace = {}
    for i=1, 9 do
        self.tImageFace[i]     = self.resourceNode_.node["ScrollView_Face"].node["Image_Face_"..i]
    end

    -- 聊天文字
    self.tTextChat = {}
    for i=1, 7 do
		self.tTextChat[i]       = self.resourceNode_.node["ScrollView_Chat"].node["Text_Chat_"..i]
    end

    -- 表情卷轴页
    self.ScrollView_Face        = self.resourceNode_.node["ScrollView_Face"]
    -- 聊天卷轴页
    self.ScrollView_Chat        = self.resourceNode_.node["ScrollView_Chat"]
    -- 聊天记录表
    self.ListView_Chat_List     = self.resourceNode_.node["ListView_Chat_List"]

    -- 聊天输入
    self.ChatInput              = self.resourceNode_.node["ChatInput"]
end

function GameChatLayer:initView()

    self.SendBtn:setVisible(true)
    self.FaceBtn:setVisible(true)
    self.ChatBtn:setVisible(true)
    self.ChatListBtn:setVisible(true)
    self.CloseBtn:setVisible(true)

    for i=1, 9 do
        self.tImageFace[i]:setVisible(true)
    end

    for i=1, 7 do
		self.tTextChat[i]:setVisible(true)
    end

    self.ScrollView_Face:setVisible(true)
    self.ScrollView_Chat:setVisible(true)
    self.ListView_Chat_List:setVisible(false)

    self.ChatInput:setVisible(true)
end

function GameChatLayer:initTouch()

    self.SendBtn:addClickEventListener(handler(self,self.Click_Send))
    self.FaceBtn:addClickEventListener(handler(self,self.Click_Face))
    self.ChatBtn:addClickEventListener(handler(self,self.Click_Chat))
    self.ChatListBtn:addClickEventListener(handler(self,self.Click_ChatList))
    self.CloseBtn:addClickEventListener(handler(self,self.Click_Close))

    for i=1, 9 do
		self.tImageFace[i]:setTag(i)
	    self.tImageFace[i]:addClickEventListener(handler(self,self.Click_EventFace))
    end

    for i=1, 7 do
		self.tTextChat[i]:setTag(i)
		self.tTextChat[i]:addClickEventListener(handler(self, self.Click_EventChat))
    end
    
	self.ChatInput:setTouchEnabled(false)
	local curWidth = self.ChatInput:getBoundingBox().width
	local curHeight = self.ChatInput:getBoundingBox().height
	self.curEdit = ccui.EditBox:create(cc.size(curWidth,35), "")
	self.curEdit:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
	self.curEdit:setInputMode(cc.EDITBOX_INPUT_MODE_ANY )
	self.curEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	self.curEdit:setPosition(self.ChatInput:getPosition())
	self.curEdit:setColor(cc.c3b(128,128,128))
	self.curEdit:setMaxLength(24)
	self:addChild(self.curEdit)
	self.curEdit:registerScriptEditBoxHandler(handler(self,self.Touch_ChatText))
end

-- 发送聊天
function GameChatLayer:Click_Send()

end

-- 表情按钮
function GameChatLayer:Click_Face()
    
    self.ScrollView_Face:setVisible(true)
end

-- 聊天按钮
function GameChatLayer:Click_Chat()
    
    self.ScrollView_Chat:setVisible(true)
    self.ListView_Chat_List:setVisible(false)
end

-- 聊天记录
function GameChatLayer:Click_ChatList()
    
    self.ScrollView_Chat:setVisible(false)
    self.ListView_Chat_List:setVisible(true)
end

-- 关闭
function GameChatLayer:Click_Close()
    
    self:setVisible(false)
end

-- 图片表情
function GameChatLayer:Click_EventFace(sender)

    self:setVisible(false)

    local nTag = sender:getTag()

    -- 发送表情消息
 	G_Data.GAME_DefaultChatReq = {}
	G_Data.GAME_DefaultChatReq.dwMsgID = nTag
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_DefaultChatReq")

    self:ShowChatInfo(1, nTag)
end

-- 聊天文字
function GameChatLayer:Click_EventChat(sender)

    self:setVisible(false)

    local nSex = cc.UserDefault:getInstance():getIntegerForKey("sex", 1)
    local nTag = sender:getTag() + nSex*10000

    -- 发送表情消息
 	G_Data.GAME_DefaultChatReq = {}
	G_Data.GAME_DefaultChatReq.dwMsgID = nTag
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_DefaultChatReq")

    self:ShowChatInfo(1, nTag)
end

-- 聊天输入
function GameChatLayer:Touch_ChatText(eventName, sender)

	if eventName == "return" then
		G_GameDeskManager:sendUserChat(self.curEdit:getText(), 999)

		local curLayer = GameChatBubbleLayer:create()
        if curLayer ~= nil then
            curLayer:setChat(1, self.curEdit:getText())
            G_DeskScene:addChild(curLayer, 10)
        end

		self.curEdit:setText("")
		self:setVisible(false)
	end
end

-- 显示聊天相关
function GameChatLayer:ShowChatInfo(LocalSeat, nTag)

    if nTag < 10000 then
        local curLayer = GameChatBubbleLayer:create()
        if curLayer ~= nil then
            curLayer:setFace(LocalSeat, nTag)
            G_DeskScene:addChild(curLayer, 10)
        end
    else
        local nSex = math.modf(nTag/10000)
        local nIndex = math.fmod(nTag, 10000)
        local curLayer = GameChatBubbleLayer:create()
        if curLayer ~= nil then
            curLayer:setChat(LocalSeat, self.tTextChat[nIndex]:getString())
            G_DeskScene:addChild(curLayer, 10)
        end

        local strName = ""
        if nSex == 1 then
            strName = "sound/GameChat/man_"..nIndex..".mp3"
        else
            strName = "sound/GameChat/woman_"..nIndex..".mp3"
        end
        G_GameDeskManager.Music:playSound(strName, false)
    end
end

function GameChatLayer:onEnter()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function GameChatLayer:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameChatLayer:onTouchBegin()
	return true
end

function GameChatLayer:onTouchMove()

end

function GameChatLayer:onTouchEnded()

end

return GameChatLayer
