
local GameDeskLayer = class("GameDeskLayer", G_BaseLayer)

local GameConfigManager             = require("app.scenes.gamedesk.GameConfigManager")

GameDeskLayer.RESOURCE_FILENAME = GameConfigManager.tGameID.PDK.."/GameDeskLayer.csb"

local GameLeaveRoomLayer            = require("app.scenes.lobby.common.GameLeaveRoomLayer")
local GameSetLayer                  = require("app.scenes.lobby.common.GameSetLayer")
local GameChatLayer                 = require("app.scenes.lobby.common.GameChatLayer")
local GameDisbandApplyLayer         = require("app.scenes.lobby.common.GameDisbandApplyLayer")

local GameConfigManager             = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                      = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".card.GameCard")

local scheduler = cc.Director:getInstance():getScheduler()

function GameDeskLayer:onCreate()
    -- 邀请按钮
	self.YaoQingBtn             = self.resourceNode_.node["YaoQingBtn"]
    -- 房间规则文本
    self.GameRuleText           = self.resourceNode_.node["GameRuleText"]
    -- 准备按钮
    self.ReadyBtn               = self.resourceNode_.node["ReadyBtn"]
    -- 取消准备按钮
    self.CancelReadyBtn         = self.resourceNode_.node["CancelReadyBtn"]
    -- 房号文本
    self.RoomNumberText         = self.resourceNode_.node["RoomNumberText"]
    -- 游戏局数文本
    self.GameNumText            = self.resourceNode_.node["GameNumText"]

    self.setBtn                 = self.resourceNode_.node["SetBtn"]
    self.LeaveBtn               = self.resourceNode_.node["LeaveBtn"]
    self.LuYinBtn               = self.resourceNode_.node["LuYinBtn"]
	self.ChatBtn                = self.resourceNode_.node["ChatBtn"]

    self.ReplayBg               = self.resourceNode_.node["ReplayBg"]
    self.Node1                  = self.resourceNode_.node["Node1"]
    self.Node2                  = self.resourceNode_.node["Node2"]

    self.PassBtn                = self.resourceNode_.node["Node1"].node["PassBtn"]
    self.PromptBtn              = self.resourceNode_.node["Node1"].node["PromptBtn"]
    self.OutCardBtn             = self.resourceNode_.node["Node1"].node["OutCardBtn"]

    self.PromptBtn2             = self.resourceNode_.node["Node2"].node["PromptBtn"]
    self.OutCardBtn2            = self.resourceNode_.node["Node2"].node["OutCardBtn"]

    self.SpriteLuyin1 = nil
	self.nStartTime = 0
end

function GameDeskLayer:initView()

	self.YaoQingBtn:setVisible(false)
	self.GameRuleText:setVisible(false)
    self.ReadyBtn:setVisible(false)
    self.CancelReadyBtn:setVisible(false)
    self.RoomNumberText:setVisible(true)
    self.GameNumText:setVisible(true)

    self.SpriteLuyin1 = cc.Sprite:create("Voice/record_0.png")
	self.SpriteLuyin1:setPosition(cc.p(display.width/2,display.height/2))
	self.SpriteLuyin1:setVisible(false)
	self:addChild(self.SpriteLuyin1)

	local actSpr = cc.Sprite:create("Voice/p1.png")
	actSpr:setPosition(cc.p(self.SpriteLuyin1:getBoundingBox().width/2 + 50, self.SpriteLuyin1:getBoundingBox().height/2 + 30))
	local curAnimate = cc.Animation:create()
	for i=1,6 do
		curAnimate:addSpriteFrameWithFile("Voice/p"..i..".png")
	end
	curAnimate:setDelayPerUnit(1/3)
	curAnimate:setRestoreOriginalFrame(true)
	local curAction = cc.Animate:create(curAnimate)
	actSpr:runAction(cc.RepeatForever:create(curAction))
	self.SpriteLuyin1:addChild(actSpr)

    self.setBtn:setVisible(true)
	self.LeaveBtn:setVisible(true)
	if G_GameDefine.bReplay then
		self.LuYinBtn:setVisible(false)
		self.ChatBtn:setVisible(false)
	else
		self.ReplayBg:setVisible(false)
        self.Node1:setVisible(false)
        self.Node2:setVisible(false)
	end

	self.GameChatLayer = GameChatLayer.create()
	self.GameChatLayer:setVisible(false)
	self:addChild(self.GameChatLayer)

	if G_GameDefine.bReplay then
	else
		self.RoomNumberText:setString(G_Data.CL_JoinGameAck.roomid)
	end
end
function GameDeskLayer:initTouch()

	self.YaoQingBtn:addClickEventListener(handler(self,self.Click_YaoQing))
    self.ReadyBtn:addClickEventListener(handler(self,self.Click_Ready))
    self.CancelReadyBtn:addClickEventListener(handler(self,self.Click_CancelReady))

    self.setBtn:addClickEventListener(handler(self,self.Click_Set))
    self.LeaveBtn:addClickEventListener(handler(self,self.Click_Leave))
    self.LuYinBtn:addTouchEventListener(handler(self,self.Click_LuYin))
	self.ChatBtn:addClickEventListener(handler(self,self.Click_Chat))

    self.PassBtn:addTouchEventListener(handler(self,self.Click_PassCard))
    self.PromptBtn:addTouchEventListener(handler(self,self.Click_Prompt))
    self.OutCardBtn:addTouchEventListener(handler(self,self.Click_OutCard))

    self.PromptBtn2:addTouchEventListener(handler(self,self.Click_Prompt))
    self.OutCardBtn2:addTouchEventListener(handler(self,self.Click_OutCard))
end

function GameDeskLayer:Click_YaoQing()

	local strContent = string.format("宁乡跑得快，房间号：%06d,%d人,%d局,%s，来战啊！",G_GameDeskManager.nGameID,G_GameDefine.nPlayerCount,G_GameDefine.nGameCount,self.GameRuleText:getString())
	ef.extensFunction:getInstance():wxInviteFriend(0, "好友@你", strContent, "Icon-120.png", "http://www.abletele.com/xiaoyou/index.html")
end

function GameDeskLayer:Click_Leave()

	if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == GS_GAME_FREE then

        local tPlayer = G_GamePlayer:getMainPlayer()
        if tPlayer.ullUserID == G_DeskScene.ullMasterID then
		    local curLayer = GameLeaveRoomLayer:create()
		    G_DeskScene:addChild(curLayer)
        else
            G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME,"GAME_DissolveGameReq")

            G_NetManager:disconnect(NETTYPE_GAME)
	        G_SceneManager:enterScene(SCENE_LOBBY)
        end
	else
		G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME,"GAME_DissolveGameReq")

        local curLayer = GameDisbandApplyLayer.create()
	    G_DeskScene:addChild(curLayer, 10, G_DeskScene.nGameDisbandApplyTAG)
	end
end

function GameDeskLayer:Click_Chat()

	self.GameChatLayer:setVisible(true)
end

function GameDeskLayer:Click_Set()

	local curlayer = GameSetLayer.create()
	G_DeskScene:addChild(curlayer,10)
end

function GameDeskLayer:Click_LuYin(sender, eventType)

	if eventType == ccui.TouchEventType.began then
		self.nStartTime = os.time()
		self.SpriteLuyin1:setVisible(true)
		ef.extensFunction:getInstance():startRecording(true)
	elseif eventType == ccui.TouchEventType.moved then
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self.SpriteLuyin1:setVisible(false)
		if os.time() - self.nStartTime < 1 then
			ef.extensFunction:getInstance():stopReording()
			return
		end
		
		ef.extensFunction:getInstance():startRecording(false)
		ef.extensFunction:getInstance():stopReording()
	end
end

-- 点击准备
function GameDeskLayer:Click_Ready()

	G_Data.GAME_ReadyReq = {}
    G_Data.GAME_ReadyReq.bAgree = true
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_ReadyReq")
end

-- 取消准备
function GameDeskLayer:Click_CancelReady()

    G_Data.GAME_ReadyReq = {}
    G_Data.GAME_ReadyReq.bAgree = false
	G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_ReadyReq")
end

-- 过牌
function GameDeskLayer:Click_PassCard(sender, eventType)

    -- 回放不处理
    if G_GameDefine.bReplay then
        return   
    end

    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    -- 过牌
	self:passCard()
end

-- 出牌
function GameDeskLayer:Click_OutCard(sender, eventType)

    -- 回放不处理
    if G_GameDefine.bReplay then
        return   
    end

    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    -- 获取选择牌
    local tCardData,nCardCount = G_DeskScene.GameCardManager:getCardArray(1, GameCard.Card_Selected)
    G_Data.GAME_OutCardReq = {}
    G_Data.GAME_OutCardReq.cbCardData = tCardData
    G_Data.GAME_OutCardReq.cbCardCount = nCardCount
    G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_OutCardReq")
end

-- 提示点击
function GameDeskLayer:Click_Prompt(sender, eventType)

    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    self:prompt()
end

function GameDeskLayer:handleEnterGameAck(tInfo)

	if G_GameDefine.nGameCount == 1 and G_GameDefine.nGameStatus == GS_GAME_FREE then
		self.YaoQingBtn:setVisible(true)
	else
		self.YaoQingBtn:setVisible(false)
	end
	self.GameNumText:setString("对局:"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount)
end

function GameDeskLayer:handleGameStartAck(tInfo)
	self.YaoQingBtn:setVisible(false)
    self:SetReadyBtn(0, false)
	self.GameNumText:setString("对局:"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount)
end

function GameDeskLayer:onEnter()

end

function GameDeskLayer:onExit()

end

-- 显示准备按钮
function GameDeskLayer:SetReadyBtn(byReady, bShow)

    local bReady = false
    if byReady == 1 then
        bReady = true
    end

    if bShow then
        self.ReadyBtn:setVisible(not bReady)
        self.CancelReadyBtn:setVisible(bReady)
    else
        self.ReadyBtn:setVisible(false)
        self.CancelReadyBtn:setVisible(false)
    end
end

-- 显示房间信息
function GameDeskLayer:showRoomInfo(strInfo)
    
    self.GameRuleText:setString(strInfo)
    self.GameRuleText:setVisible(true)
end

-- 设置不出、出牌、提示
function GameDeskLayer:setNodeShow1(bVisible)

	self.Node1:setVisible(bVisible)
end

-- 设置出牌、提示
function GameDeskLayer:setNodeShow2(bVisible)

	self.Node2:setVisible(bVisible)
end

-- 过牌
function GameDeskLayer:passCard()

    G_Data.GAME_PassCardReq = {}
    G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_PassCardReq")
end

-- 提示
function GameDeskLayer:prompt()

    -- 没有提示
    if not G_DeskScene:prompt() then
        -- 直接pass
	    self:passCard()
    end
end

return GameDeskLayer
