
local M = class("GameHelpLayer",G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/GameHelp/GameHelpLayer.csb"

local HelpConfig = require("app.config.HelpConfig")

-- 创建
function M:onCreate()
    self.ScrollView = self.resourceNode_.node["ScrollView"]
    self.ButtonScrollView = self.resourceNode_.node["ButtonScrollView"]
    self.CloseBtn = self.resourceNode_.node["CloseBtn"]
    self.BG = self.resourceNode_.node["BG"]

    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    -- 描述文字
	self.DescText = self.resourceNode_.node["ScrollView"].node["DescText"]

    -- 选择ID
    self.nChooseID = 0
    -- 选择标志
    self.tChooseTag = {}
    -- 正常位置
    self.nomalX = 105
    -- 选择位置
    self.chooseX = 110
end

-- 初始视图
function M:initView()
    self.ScrollView:setVisible(true)
	self.ButtonScrollView:setVisible(true)
    self.CloseBtn:setVisible(true)
    for nIndex, tInfo in ipairs(HelpConfig.tGame) do
        local strImage = tInfo.tTag.Tag
        local pButton = ccui.Button:create(strImage, strImage)
        pButton:setAnchorPoint(cc.p(0.5, 0.5))
        pButton:setPosition(cc.p(self.nomalX, 375-(nIndex-1)*100))
        pButton:setTag(nIndex)
        pButton:setVisible(true)
        self.tChooseTag[nIndex] = pButton

        self.ButtonScrollView:addChild(pButton)
    end
    -- 设置房间信息
    self:setRoomInfo(1)
end

-- 初始视图
function M:initTouch()
    for nIndex, pButton in ipairs(self.tChooseTag) do
        pButton:addClickEventListener(handler(self, self.Click_ChooseButtonTag))
    end

	self.CloseBtn:addClickEventListener(handler(self, self.Click_Close))
end

-- 进入场景
function M:onEnter()

end

-- 退出场景
function M:onExit()

end

-- 设置房间信息
function M:setRoomInfo(nChooseID)
    if nChooseID == nil then
        return
    end

    local tInfo = HelpConfig.tGame[nChooseID]
    if tInfo == nil then
        return
    end

    if self.nChooseID == nChooseID then
        return
    end
    self.nChooseID = nChooseID
    for nIndex, tInfo1 in ipairs(HelpConfig.tGame) do
        self.tChooseTag[nIndex]:loadTextures(tInfo1.tTag.Tag,tInfo1.tTag.Tag)
    end 
    for nIndex, pButton in ipairs(self.tChooseTag) do
        if self.nChooseID == nIndex then
            pButton:loadTextures(tInfo.tTag.Sprite,tInfo.tTag.Sprite)
            pButton:setPosition(cc.p(self.chooseX, 375-(nIndex-1)*100))
        else
            pButton:setPosition(cc.p(self.nomalX, 375-(nIndex-1)*100))
        end
    end

    -- 设置描述
    self.DescText:setString(tInfo.tDesc.szDesc)
    -- 跳到描述头部
    self.ScrollView:jumpToTop()
end

-- 选择标志
function M:Click_ChooseButtonTag(sender)
    G_CommonFunc:addClickSound()
    self:setRoomInfo(sender:getTag())
end

-- 点击关闭
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

return M
