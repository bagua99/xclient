
local GameSetLayer = class("GameSetLayer", G_BaseLayer)

GameSetLayer.RESOURCE_FILENAME = "GameSetLayer.csb"

function GameSetLayer:onCreate()

    -- 关闭按钮
    self.CloseBtn           = self.resourceNode_.node["CloseBtn"]
    -- 登出按钮
    self.LogoutBtn          = self.resourceNode_.node["LogoutBtn"]

    -- 音乐关闭
    self.MusicCloseBtn      = self.resourceNode_.node["MusicCloseBtn"]
    -- 声音关闭
    self.SoundCloseBtn      = self.resourceNode_.node["SoundCloseBtn"]
    -- 屏蔽关闭
    self.ScreenCloseBtn     = self.resourceNode_.node["ScreenCloseBtn"]
    -- 音乐开启
    self.MusicOpenBtn       = self.resourceNode_.node["MusicOpenBtn"]
    -- 声音开启
    self.SoundOpenBtn       = self.resourceNode_.node["SoundOpenBtn"]
    -- 屏蔽开启
    self.ScreenOpenBtn      = self.resourceNode_.node["ScreenOpenBtn"]

    self.bMusic = false
    self.bSound = false
    self.bChatSound = false
end

function GameSetLayer:initView()

    self.CloseBtn:setVisible(true)
    self.LogoutBtn:setVisible(true)

    self.MusicCloseBtn:setVisible(false)
    self.SoundCloseBtn:setVisible(false)
    self.ScreenCloseBtn:setVisible(false)
    self.MusicOpenBtn:setVisible(false)
    self.SoundOpenBtn:setVisible(false)
    self.ScreenOpenBtn:setVisible(false)
end

function GameSetLayer:initTouch()

    self.CloseBtn:addClickEventListener(handler(self,self.Click_Close))
    self.LogoutBtn:addClickEventListener(handler(self,self.Click_Logout))

	self.bMusic = cc.UserDefault:getInstance():getBoolForKey("Music", false)
	self.bSound = cc.UserDefault:getInstance():getBoolForKey("Sound", false)
    self.bChatSound = cc.UserDefault:getInstance():getBoolForKey("ChatSound", false)

    -- 设置音乐
    self:ShowSetMusic()
    -- 设置声音
    self:ShowSetSound()
    -- 设置屏蔽
    self:ShowSetScreen()
    
	self.MusicCloseBtn:addClickEventListener(handler(self,self.Click_SetMusic))
	self.SoundCloseBtn:addClickEventListener(handler(self,self.Click_SetSound))
    self.ScreenCloseBtn:addClickEventListener(handler(self,self.Click_SetScreen))
    self.MusicOpenBtn:addClickEventListener(handler(self,self.Click_SetMusic))
	self.SoundOpenBtn:addClickEventListener(handler(self,self.Click_SetSound))
    self.ScreenOpenBtn:addClickEventListener(handler(self,self.Click_SetScreen))
end

-- 关闭按钮
function GameSetLayer:Click_Close()

	self:removeFromParent()
end

-- 登出
function GameSetLayer:Click_Logout()

	cc.UserDefault:getInstance():setStringForKey("openid","")
	cc.UserDefault:getInstance():flush()
	G_NetManager:disconnect(NETTYPE_LOGIN)
	G_SceneManager:enterScene(SCENE_LOGIN)
end

-- 设置音乐
function GameSetLayer:Click_SetMusic()

    if self.bMusic then
        self.bMusic = false
    else
        self.bMusic = true
    end

    cc.UserDefault:getInstance():setBoolForKey("Music", self.bMusic)
	cc.UserDefault:getInstance():flush()

    if not self.bMusic then
        G_GameDeskManager.Music:pauseBackMusic()
    else
        G_GameDeskManager.Music:resumeBackMusic()
    end

    -- 设置音乐
    self:ShowSetMusic()
end

-- 设置声音
function GameSetLayer:Click_SetSound()

    if self.bSound then
        self.bSound = false
    else
        self.bSound = true
    end

	cc.UserDefault:getInstance():setBoolForKey("Sound", self.bSound)
	cc.UserDefault:getInstance():flush()

    -- 设置声音
    self:ShowSetSound()
end

-- 设置屏蔽
function GameSetLayer:Click_SetScreen()

    if self.bChatSound then
        self.bChatSound = false
    else
        self.bChatSound = true
    end

	cc.UserDefault:getInstance():setBoolForKey("ChatSound", self.bChatSound)
	cc.UserDefault:getInstance():flush()

    -- 设置屏蔽
    self:ShowSetScreen()
end

-- 设置音乐
function GameSetLayer:ShowSetMusic()

    if self.bMusic then
        self.MusicCloseBtn:setVisible(true)
        self.MusicOpenBtn:setVisible(false)
    else
        self.MusicCloseBtn:setVisible(false)
        self.MusicOpenBtn:setVisible(true)
    end
end

-- 设置声音
function GameSetLayer:ShowSetSound()

    if self.bSound then
        self.SoundCloseBtn:setVisible(true)
        self.SoundOpenBtn:setVisible(false)
    else
        self.SoundCloseBtn:setVisible(false)
        self.SoundOpenBtn:setVisible(true)
    end
end

-- 设置屏蔽
function GameSetLayer:ShowSetScreen()

    if self.bChatSound then
        self.ScreenCloseBtn:setVisible(true)
        self.ScreenOpenBtn:setVisible(false)
    else
        self.ScreenCloseBtn:setVisible(false)
        self.ScreenOpenBtn:setVisible(true)
    end
end

function GameSetLayer:onEnter()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self) 
end

function GameSetLayer:onExit()

	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameSetLayer:onTouchBegin()
	return true
end

function GameSetLayer:onTouchMove()

end

function GameSetLayer:onTouchEnded()

end

return GameSetLayer
