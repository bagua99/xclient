
local M = class("GameEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.PDK.."/GameEndLayer.csb"

-- 创建
function M:onCreate()
	self.bToOver = false

    self.ContinueBtn = self.resourceNode_.node["ContinueBtn"]
    self.CloseBtn = self.resourceNode_.node["CloseBtn"]

    self.WinImage = self.resourceNode_.node["WinImage"]
    self.LostImage = self.resourceNode_.node["LostImage"]

    self.BG = self.resourceNode_.node["BG"]
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)
end

-- 初始化视图
function M:initView()
	self.ContinueBtn:setVisible(true)
    self.CloseBtn:setVisible(true)
    self.WinImage:setVisible(false)
    self.LostImage:setVisible(false)
end

-- 初始化触摸
function M:initTouch()
	self.ContinueBtn:addClickEventListener(handler(self, self.Click_Continue))
    self.CloseBtn:addClickEventListener(handler(self, self.Click_Close))
end

-- 进入场景
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
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

-- 结束信息
function M:GameEndAck(nGameCount, nTotalCount, msg)
	if nGameCount >= nTotalCount then
		self.bToOver = true
	else
		self.bToOver = false
	end
    
    for i=1, G_GameDefine.nMaxPlayerCount do
        local pNode = self.resourceNode_.node["Node_name"..i]

        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
            pNode:setVisible(false)
        else
            local pNode_NameText = self.resourceNode_.node["Node_name"..i].node["name"..i]
            if pNode_NameText ~= nil then
                local szNickName = _player.nickname
                local len = string.len(szNickName)
                if len>12 then 
                    szNickName = string.sub(szNickName,1,12).."..."
                end
                pNode_NameText:setString(szNickName)
            end
            
            local pNode_ScoreText = self.resourceNode_.node["Node_name"..i].node["score"..i]
            if pNode_ScoreText ~= nil then
                pNode_ScoreText:setString(msg.nGameScore[i])
            end

            local pNode_PaiText = self.resourceNode_.node["Node_name"..i].node["pai"..i]
            if pNode_PaiText ~= nil then
                if msg.card[i] ~= nil then
                    pNode_PaiText:setString(#msg.card[i].nCardData)
                end
            end
            
            local pNode_ZhaDanText = self.resourceNode_.node["Node_name"..i].node["zhadan"..i]
            if pNode_ZhaDanText ~= nil then
                pNode_ZhaDanText:setString(msg.nBombCount[i])
            end
        end
    end

    -- 是自己,显示输赢
    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if msg.nGameScore[nServerSeat] > 0 then
        self.LostImage:setVisible(false)
        self.WinImage:setVisible(true)
    else
        -- 积分等于0，手牌剩余0，别人剩余一张，自己出完，也是0分，这时候要显示胜利
        if msg.nGameScore[nServerSeat] == 0 and msg.card[nServerSeat] ~= nil and #msg.card[nServerSeat].nCardData == 0 then
            self.LostImage:setVisible(false)
            self.WinImage:setVisible(true)
        else
            self.LostImage:setVisible(true)
            self.WinImage:setVisible(false)
        end
    end
end

-- 继续
function M:Click_Continue()
    G_CommonFunc:addClickSound()
	if self.bToOver then
		G_DeskScene:showGameTotalEnd()
	else
		G_DeskScene:Action_Restart(true)
	end
end

-- 关闭
function M:Click_Close()
    G_CommonFunc:addClickSound()
	if self.bToOver then
		G_DeskScene:showGameTotalEnd()
	else
		G_DeskScene:Action_Restart(false)
	end
end

return M
