
local GameAvatarItemLayer = class("GameAvatarItemLayer", G_BaseLayer)

local GameConfigManager             = require("app.scenes.gamedesk.GameConfigManager")

GameAvatarItemLayer.headSize = 88

function GameAvatarItemLayer:onCreate()

	self.bLoadHead = false
	self.loadHeadListener = nil
	self.nScore = 0
    self.nLocalSeat = 1
end

function GameAvatarItemLayer:initAll(nServerSeat)

	self.nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)

    -- 人物头像
    self.sprSpriteBg = cc.Sprite:create(GameConfigManager.tGameID.PDK.."/GameDesk/kuang_paizhuo_renwu.png")
	self:addChild(self.sprSpriteBg)

    -- 默认头像
	self.SpriteAvatar = cc.Sprite:create("avatar_boy0.png")
    if self.SpriteAvatar ~= nil then
	    self:addChild(self.SpriteAvatar)
    end

    -- 昵称
	self.labelStr = ccui.Text:create("","Arial",20)
    self.labelStr:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.labelStr:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.labelStr:setAnchorPoint(cc.p(0.5, 0.5))
    self.labelStr:setPosition(cc.p(0, 55))
    self.labelStr:setColor(cc.c3b(255, 255, 255))
    self.labelStr:setContentSize(cc.size(100,40))
    self.labelStr:ignoreContentAdaptWithSize(false)
    self:addChild(self.labelStr)

    -- 分数
	self.labelGold = cc.Label:createWithSystemFont("1000", "Arial", 20)
    self.labelGold:setAnchorPoint(cc.p(0.5, 0.5))
    self.labelGold:setColor(cc.c3b(255, 238, 148))
    self.labelGold:setPosition(cc.p(0, -55))
    self.labelGold:setVisible(true)
	self:addChild(self.labelGold)

    -- 准备
    self.SpriteReady = cc.Sprite:create(GameConfigManager.tGameID.PDK.."/GameDesk/ready.png")
    self.SpriteReady:setAnchorPoint(cc.p(0.5, 0.5))
    local tReadyPos = {cc.p(200, -40), cc.p(200, -40), cc.p(-200, -40)}
    self.SpriteReady:setPosition(tReadyPos[self.nLocalSeat])
    self.SpriteReady:setVisible(false)
    self:addChild(self.SpriteReady)

	local tYuyinPoint = {cc.p(100,100), cc.p(100,60), cc.p(-60,60)}
	self.SpriteYuyinBg = cc.Sprite:create(string.format("Voice/a%d.png",self.nLocalSeat))
	self.SpriteYuyinBg:setPosition(tYuyinPoint[self.nLocalSeat])
	self.SpriteYuyinBg:setVisible(false)
	self:addChild(self.SpriteYuyinBg)

    -- 牌背
    self.SpriteCardBg = cc.Sprite:create(GameConfigManager.tGameID.PDK.."/GameDesk/pukebeimian.png")
    self.SpriteCardBg:setAnchorPoint(cc.p(0.5, 0.5))
    if self.nLocalSeat == 1 then
        self.SpriteCardBg:setVisible(false)
    elseif self.nLocalSeat == 2 then
        self.SpriteCardBg:setPosition(cc.p(80, -45))
    elseif self.nLocalSeat == 3 then
        self.SpriteCardBg:setPosition(cc.p(-80, -45))
    end
    self:addChild(self.SpriteCardBg)

    -- 牌数
    self.labelCardNum = cc.Label:createWithSystemFont("?", "Arial", 28)
    self.labelCardNum:setColor(cc.c3b(182,212,236))
    if self.nLocalSeat == 1 then
        self.labelCardNum:setVisible(false)
    elseif self.nLocalSeat == 2 then
        self.labelCardNum:setPosition(cc.p(80, -45))
    elseif self.nLocalSeat == 3 then
        self.labelCardNum:setPosition(cc.p(-80, -45))
    end
    self:addChild(self.labelCardNum)

    self:showInfo()

	local actSpr = cc.Sprite:create("Voice/voice0.png")
	actSpr:setPosition(cc.p(self.SpriteYuyinBg:getBoundingBox().width / 2, self.SpriteYuyinBg:getBoundingBox().height / 2))
	local curAnimate = cc.Animation:create()
	for i=1,3 do
		curAnimate:addSpriteFrameWithFile("Voice/voice"..i..".png")
	end
	curAnimate:setDelayPerUnit(1/3)
	curAnimate:setRestoreOriginalFrame(true)
	local curAction = cc.Animate:create(curAnimate)
	actSpr:runAction(cc.RepeatForever:create(curAction))
	self.SpriteYuyinBg:addChild(actSpr)
end

function GameAvatarItemLayer:initView()

end

function GameAvatarItemLayer:setNickname(szNickName)
    self.labelStr:setString(szNickName)
end

function GameAvatarItemLayer:setCurScore(nScore)

	self.nScore = nScore
	self.labelGold:setString(self.nScore)
end

function GameAvatarItemLayer:setCardCount(nCount)
   self.labelCardNum:setString(nCount)
   if G_DeskScene.tRoomInfo.bShowCard == 0 then
        self.labelCardNum:setVisible(false)
        self.SpriteCardBg:setVisible(false)
   else
        self.labelCardNum:setVisible(true)
        self.SpriteCardBg:setVisible(true)
   end
end

function GameAvatarItemLayer:setAddScore(nScore)

	self.nScore = tonumber(self.nScore) + tonumber(nScore)
	self.labelGold:setString(self.nScore)
end

function GameAvatarItemLayer:setReady(byReady)

    local bReady = false
    if byReady == 1 then
        bReady = true
    end
    self.SpriteReady:setVisible(bReady)
end

function GameAvatarItemLayer:addSprColorGray()
    if self.SpriteAvatar ~= nil then
        self.SpriteAvatar:setColor(cc.c3b(150, 150, 150))
    end
end

function GameAvatarItemLayer:removeColorGray()
    if self.SpriteAvatar ~= nil then
        self.SpriteAvatar:setColor(cc.c3b(255, 255, 255))
    end
end

function GameAvatarItemLayer:initTouch()

end

function GameAvatarItemLayer:showInfo()

	local curTable = G_GamePlayer:getPlayerBySeverSeat(G_GamePlayer:getServerSeat(self.nLocalSeat))
    if curTable == nil then
        return
    end
	if string.len(curTable["imgurl"]) > 0 then
		if not self.bLoadHead then
			self.loadHeadListener = G_CommonFunc:addEvent("getAvaHead"..self.nLocalSeat,handler(self,self.getHeadImg))
			self.bLoadHead = true
			local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead"..self.nLocalSeat..".png"
			local msgName = "getAvaHead"..self.nLocalSeat
			ef.extensFunction:getInstance():httpForImg(curTable["imgurl"],saveName,msgName)
		end
	end
	self.labelStr:setString(curTable["szNickName"])
	self:setCurScore(curTable["gold"])
end

function GameAvatarItemLayer:getHeadImg()

	local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead"..self.nLocalSeat..".png"
    if self.SpriteAvatar ~= nil then
	    self.SpriteAvatar:setTexture(saveName)
	    self.SpriteAvatar:setScale(GameAvatarItemLayer.headSize/self.SpriteAvatar:getBoundingBox().width,GameAvatarItemLayer.headSize/self.SpriteAvatar:getBoundingBox().height)
    end	
end

function GameAvatarItemLayer:onEnter()

end

function GameAvatarItemLayer:showYuyin()

	self.SpriteYuyinBg:setVisible(true)
end

function GameAvatarItemLayer:hideYuyin()

	self.SpriteYuyinBg:setVisible(false)
end

function GameAvatarItemLayer:onExit()

	if self.loadHeadListener then
		G_CommonFunc:removeEvent(self.loadHeadListener)
	end
end

return GameAvatarItemLayer
