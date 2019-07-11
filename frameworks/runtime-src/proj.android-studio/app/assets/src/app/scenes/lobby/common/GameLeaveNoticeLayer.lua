
local GameLeaveNoticeLayer = class("GameLeaveNoticeLayer", G_BaseLayer)

local scheduler =  cc.Director:getInstance():getScheduler()

function GameLeaveNoticeLayer:onCreate()

	self.pLabelCount = nil
    self.pSpriteBg = nil

    self.m_iType = -1
    self.m_bShow = true
	self.m_iPeople = 0
end

function GameLeaveNoticeLayer:initView()

	self.pSpriteBg = cc.Sprite:create("Common/leaveBg.png")
	self.pSpriteBg:setPosition(cc.p(display.width / 2, display.height / 2))
	self:addChild(self.pSpriteBg)

	local pLabelTiShi1 = cc.Label:createWithSystemFont("系统提示","Arail",25)
	pLabelTiShi1:setPosition(cc.p(self.pSpriteBg:getBoundingBox().width / 2, self.pSpriteBg:getBoundingBox().height - 20))
	self.pSpriteBg:addChild(pLabelTiShi1)

	local pLabelTiShi2 = cc.Label:createWithSystemFont("同桌有牌友暂时离开游戏","Arail",18)
	pLabelTiShi2:setPosition(cc.p(self.pSpriteBg:getBoundingBox().width / 2, self.pSpriteBg:getBoundingBox().height - 70))
	self.pSpriteBg:addChild(pLabelTiShi2)

	self.pLabelCount = cc.Label:createWithSystemFont("请等待牌友返回，游戏将继续！","Arail",18)
	self.pLabelCount:setPosition(cc.p(self.pSpriteBg:getBoundingBox().width / 2, self.pSpriteBg:getBoundingBox().height - 100))
	self.pSpriteBg:addChild(self.pLabelCount)

	self.pSpriteBg:setVisible(false)
end

function GameLeaveNoticeLayer:LeaveNotice(strName, iType)

	self:setVisible(true)

	if iType == nil then
		iType = 0
	end

	if iType == 0 then
		self.m_iPeople = self.m_iPeople + 1

		local pSpriteBar = cc.Sprite:create("Common/leaveBarBg.png")
		pSpriteBar:setPosition(cc.p(display.width / 2,display.height + 20))
		self:addChild(pSpriteBar)

		local pStr = string.format("玩家[%s]断线", strName)
		local plabel = cc.Label:createWithSystemFont(pStr,"Arail",20)
		plabel:setPosition(cc.p(pSpriteBar:getBoundingBox().width / 2, pSpriteBar:getBoundingBox().height / 2))
		pSpriteBar:addChild(plabel)

		pSpriteBar:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(320,display.height - 10)),cc.DelayTime:create(10),
											cc.MoveTo:create(1,cc.p(320,display.height + 30)),cc.RemoveSelf:create()))
	end

	if self.m_iType == -1 then
		self.m_iType = iType
	end

    if self.pSpriteBg ~= nil then
	    self.pSpriteBg:setVisible(true)
    end
end


function GameLeaveNoticeLayer:outCardUser()

    if self.m_iType ~= 1 then
        return
    end

    if self.m_iPeople ~= 0 then
        return
    end

    self:setVisible(false)
    if self.pSpriteBg ~= nil then
        self.pSpriteBg:setVisible(false)
    end
    self:resetData()
end

function GameLeaveNoticeLayer:showOnline(strName)

	self.m_iPeople = self.m_iPeople - 1

	local pSpriteBar = cc.Sprite:create("Common/leaveBarBg.png")
	pSpriteBar:setPosition(cc.p(display.width / 2, display.height + 20))
	self:addChild(pSpriteBar)

	local pStr = string.format("玩家[%s]断线", strName)
	local plabel = cc.Label:createWithSystemFont(pStr, "Arail", 20)
	plabel:setPosition(cc.p(pSpriteBar:getBoundingBox().width / 2, pSpriteBar:getBoundingBox().height / 2))
	pSpriteBar:addChild(plabel)

	pSpriteBar:runAction(cc.Sequence:create(cc.MoveTo:create(1,cc.p(320,display.height - 10)),cc.DelayTime:create(10),
											cc.MoveTo:create(1,cc.p(320,display.height + 30)),cc.RemoveSelf:create()))

	if self.m_iPeople <= 0 then
        if self.pSpriteBg ~= nil then
		    self.pSpriteBg:setVisible(false)
        end
		self:resetData()
	end
end


function GameLeaveNoticeLayer:resetData()

	self.m_iType = -1
    if self.pSpriteBg ~= nil then
	    self.pSpriteBg:setVisible(false)
    end
	self.m_bShow = true
end

function GameLeaveNoticeLayer:initTouch()

end

function GameLeaveNoticeLayer:getPeopleOffline()
	return self.m_iPeople
end

function GameLeaveNoticeLayer:onEnter()

end

function GameLeaveNoticeLayer:onExit()
end

return GameLeaveNoticeLayer
