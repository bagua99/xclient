
local M = class("GameSetLayer", G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/GameSet/GameSetLayer.csb"

local EventConfig               = require ("app.config.EventConfig")

-- 创建
function M:onCreate(isShowLogout)
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

    self.BG      = self.resourceNode_.node["BG"]
    
    if isShowLogout == nil then 
        self.isShowLogout = true
    else 
        self.isShowLogout = isShowLogout    
    end 
end

-- 初始视图
function M:initView()
    self.CloseBtn:setVisible(true)
    self.LogoutBtn:setVisible(self.isShowLogout)

    self.MusicCloseBtn:setVisible(false)
    self.SoundCloseBtn:setVisible(false)
    self.ScreenCloseBtn:setVisible(false)
    self.MusicOpenBtn:setVisible(false)
    self.SoundOpenBtn:setVisible(false)
    self.ScreenOpenBtn:setVisible(false)
end

-- 初始触摸
function M:initTouch()
    self.CloseBtn:addClickEventListener(handler(self,self.Click_Close))
    self.LogoutBtn:addClickEventListener(handler(self,self.Click_Logout))

	self.nMusic = cc.UserDefault:getInstance():getIntegerForKey("Music", 0)
	self.nSound = cc.UserDefault:getInstance():getIntegerForKey("Sound", 0)
    self.nChatSound = cc.UserDefault:getInstance():getIntegerForKey("ChatSound", 0)
    
	self.MusicCloseBtn:addClickEventListener(handler(self,self.Click_SetMusic))
	self.SoundCloseBtn:addClickEventListener(handler(self,self.Click_SetSound))
    self.ScreenCloseBtn:addClickEventListener(handler(self,self.Click_SetScreen))
    self.MusicOpenBtn:addClickEventListener(handler(self,self.Click_SetMusic))
	self.SoundOpenBtn:addClickEventListener(handler(self,self.Click_SetSound))
    self.ScreenOpenBtn:addClickEventListener(handler(self,self.Click_SetScreen))

    self:ShowSetMusic()
    self:ShowSetSound()
    self:ShowSetScreen()
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

-- 关闭按钮
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

-- 登出
function M:Click_Logout()
    G_CommonFunc:addClickSound()
	cc.UserDefault:getInstance():setStringForKey("openid","")
	cc.UserDefault:getInstance():flush()
	G_SceneManager:enterScene(EventConfig.SCENE_LOGIN)
end

-- 设置音乐
function M:Click_SetMusic()
    G_CommonFunc:addClickSound()
    if self.nMusic == 1 then
        self.nMusic =  2
    else
        self.nMusic = 1 
    end
    cc.UserDefault:getInstance():setIntegerForKey("Music", self.nMusic)
	cc.UserDefault:getInstance():flush()
    -- 设置音乐
    self:ShowSetMusic()
    if self.nMusic == 1 then
        G_GameDeskManager.Music:resumeBackMusic()    
    else 
        G_GameDeskManager.Music:pauseBackMusic() 
    end 
end

-- 设置声音
function M:Click_SetSound()
    G_CommonFunc:addClickSound()
    if self.nSound == 1 then
        self.nSound = 2
    else
        self.nSound = 1
    end
	cc.UserDefault:getInstance():setIntegerForKey("Sound", self.nSound)
	cc.UserDefault:getInstance():flush()
    -- 设置声音
    self:ShowSetSound()
end

-- 设置屏蔽
function M:Click_SetScreen()
    G_CommonFunc:addClickSound()
    if self.nChatSound == 1 then
        self.nChatSound = 2
    else
        self.nChatSound = 1
    end
	cc.UserDefault:getInstance():setIntegerForKey("ChatSound", self.nChatSound)
	cc.UserDefault:getInstance():flush()

    -- 设置屏蔽
    self:ShowSetScreen()
end

-- 设置音乐
function M:ShowSetMusic()
    if self.nMusic == 1 then
        self.MusicCloseBtn:setVisible(true)
        self.MusicOpenBtn:setVisible(false)
    else
        self.MusicCloseBtn:setVisible(false)
        self.MusicOpenBtn:setVisible(true)
    end
end

-- 设置声音
function M:ShowSetSound()
    if self.nSound == 1 then
        self.SoundCloseBtn:setVisible(true)
        self.SoundOpenBtn:setVisible(false)
    else
        self.SoundCloseBtn:setVisible(false)
        self.SoundOpenBtn:setVisible(true)
    end
end

-- 设置屏蔽
function M:ShowSetScreen()
    if self.nChatSound == 1 then
        self.ScreenCloseBtn:setVisible(true)
        self.ScreenOpenBtn:setVisible(false)
    else
        self.ScreenCloseBtn:setVisible(false)
        self.ScreenOpenBtn:setVisible(true)
    end
end

return M
