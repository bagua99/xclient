
local GameAvatarLayer = class("GameAvatarLayer", G_BaseLayer)

local GameConfigManager       = require("app.scenes.gamedesk.GameConfigManager")
local GameAvatarItemLayer     = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".avatar.GameAvatarItemLayer")
local GameDefine              = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".GameDefine")

local scheduler =  cc.Director:getInstance():getScheduler()

function GameAvatarLayer:onCreate()

    self.Banker = nil
	self.ClockBg = nil
	self.ClockTime = nil
	self.scehdule_updateClockTime = nil
    self.nTimeCount = 0
end

function GameAvatarLayer:initView()

	self.tGameAvatar = {}
    local ptAvatar = {cc.p(50, 80), cc.p(73, 415), cc.p(1047, 415)}
	for i=1, G_GameDefine.nMaxPlayerCount do
		self.tGameAvatar[i] = GameAvatarItemLayer.create()
		self.tGameAvatar[i]:initAll(i-1)
        self.tGameAvatar[i]:setPosition(ptAvatar[i])
		self.tGameAvatar[i]:setVisible(false)
		self:addChild(self.tGameAvatar[i])
	end

	self.Banker = cc.Sprite:create(GameConfigManager.tGameID.PDK.."/GameDesk/zhuang.png")
	self.Banker:setPosition(cc.p(0,0))
    self.Banker:setVisible(false)
	self:addChild(self.Banker)

    self.ClockBg = cc.Sprite:create("Common/clock.png")
	self.ClockBg:setOpacity(150)
	self.ClockBg:setScale(0.8)
    self.ClockBg:setVisible(false)
	self:addChild(self.ClockBg)

	self.ClockTime = ccui.TextAtlas:create("15","Common/clock_font.png",20,28,"0")
    self.ClockTime:setVisible(false)
	self:addChild(self.ClockTime)
end

function GameAvatarLayer:initTouch()

end

function GameAvatarLayer:showAvatar(nServerSeat, szImageURL, szNickName, nUserID, nScore, byStatus, szIP)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    
    if szImageURL ~= nil then
        --self.tGameAvatar[nLocalSeat]:requestImgWithHeader(szImageURL)
    end

    if szNickName ~= nil then
        self.tGameAvatar[nLocalSeat]:setNickname(szNickName)
    end

    if nUserID ~= nil then
        --self.tGameAvatar[nLocalSeat]:setUserID(nUserID)
    end
    
    if nScore ~= nil then
        self.tGameAvatar[nLocalSeat]:setCurScore(nScore)
    end
    
    if szIP ~= nil then
        --self.tGameAvatar[nLocalSeat]:setIP(szIP)
    end

    if byStatus ~= nil then
        self.tGameAvatar[nLocalSeat]:setReady(byStatus)
    end
    
    self.tGameAvatar[nLocalSeat]:removeColorGray()
end

function GameAvatarLayer:getHeadImg(nServerSeat)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.tGameAvatar[nLocalSeat]:getHeadImg()
end

function GameAvatarLayer:resetPos()

	for i=1, G_GameDefine.nMaxPlayerCount do
		self.tGameAvatar[i]:setVisible(true)
	end
end

function GameAvatarLayer:setGameAvatar(nSeverSeat, bVisible)

	local nLocalSeat = G_GamePlayer:getLocalSeat(nSeverSeat)
    self.tGameAvatar[nLocalSeat]:setVisible(bVisible)
end

function GameAvatarLayer:setReady(nSeverSeat, byReady)

	local nLocalSeat = G_GamePlayer:getLocalSeat(nSeverSeat)
    self.tGameAvatar[nLocalSeat]:setReady(byReady)
end

function GameAvatarLayer:setCurScore(nSeverSeat, nScore)

	local nLocalSeat = G_GamePlayer:getLocalSeat(nSeverSeat)
	self.tGameAvatar[nLocalSeat]:setCurScore(nScore)
end

-- œ‘ æ≈∆ ˝
function GameAvatarLayer:setCardCount(nSeverSeat, nCount)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nSeverSeat)
	self.tGameAvatar[nLocalSeat]:setCardCount(nCount)
end

-- œ‘ æ”Ô“Ù
function GameAvatarLayer:showYuyin(nSeverSeat)

	local nLocalSeat = G_GamePlayer:getLocalSeat(nSeverSeat)
	self.tGameAvatar[nLocalSeat]:showYuyin()
end

-- “˛≤ÿ”Ô“Ù
function GameAvatarLayer:hideYuyin(nSeverSeat)

	local nLocalSeat = G_GamePlayer:getLocalSeat(nSeverSeat)
	self.tGameAvatar[nLocalSeat]:hideYuyin()
end

function GameAvatarLayer:showAvatarBySeverSeat(nSeverSeat)

	local nLocalSeat = G_GamePlayer:getLocalSeat(nSeverSeat)
	self.tGameAvatar[nLocalSeat]:showInfo()
end

-- œ‘ æ◊Ø
function GameAvatarLayer:showBanker(bShow)

    self.Banker:setVisible(bShow)
end

-- œ‘ æ◊Ø
function GameAvatarLayer:setBankerBySeat(nLocalSeat)

    local tPoint = {cc.p(50 + 46, 80 + 85), cc.p(73 + 46, 415 + 85), cc.p(1047 - 46, 415 + 85)}
    self.Banker:setPosition(tPoint[nLocalSeat])
    self:showBanker(true)
end

-- œ‘ æƒ÷÷”
function GameAvatarLayer:showOutTime(nLocalSeat, bShow)

	 if self.scehdule_updateClockTime ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
		self.scehdule_updateClockTime = nil
	end

    self.ClockTime:setVisible(bShow)
    self.ClockBg:setVisible(bShow)

    if not bShow then
        return
    end

    local tPoint = {cc.p(270, 245), cc.p(220, 490), cc.p(900, 490)}
    self.ClockBg:setPosition(tPoint[nLocalSeat])
    self.ClockTime:setPosition(cc.pSub(tPoint[nLocalSeat], cc.p(0,2)))
    self.nTimeCount = 15
    self.scehdule_updateClockTime = scheduler:scheduleScriptFunc(handler(self, self.updateClockTime), 1, false)
end

-- ∏¸–¬ƒ÷÷”
function GameAvatarLayer:updateClockTime()

	self.nTimeCount = self.nTimeCount - 1
	if self.nTimeCount <= 0 then
        self.ClockBg:setVisible(false)
        self.ClockTime:setVisible(false)
		if self.scehdule_updateClockTime ~= nil then
			scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
			self.scehdule_updateClockTime = nil
		end
	else
		self.ClockTime:setString(string.format("%d", self.nTimeCount))
	end
end

function GameAvatarLayer:onEnter()

end

function GameAvatarLayer:onExit()

	if self.scehdule_updateClockTime ~= nil then
		scheduler:unscheduleScriptEntry(self.scehdule_updateClockTime)
		self.scehdule_updateClockTime = nil
	end
end

return GameAvatarLayer
