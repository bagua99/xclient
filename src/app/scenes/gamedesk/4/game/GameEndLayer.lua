
local M = class("GameEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.NXPHZ.."/GameEndLayer.csb"

local GameEndCardManager            = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".card.GameEndCardManager")

-- 创建
function M:onCreate()
	self.bToOver = false

    self.Button_Continue    = self.resourceNode_.node["Button_Continue"]
    self.Button_Close       = self.resourceNode_.node["Button_Close"]

    self.Panel_End              = self.resourceNode_.node["Panel_End"]
    self.AtlasLabel_HuXi        = self.resourceNode_.node["Panel_End"].node["AtlasLabel_HuXi"]
    self.AtlasLabel_TunShu      = self.resourceNode_.node["Panel_End"].node["AtlasLabel_TunShu"]
    self.AtlasLabel_FanShu      = self.resourceNode_.node["Panel_End"].node["AtlasLabel_FanShu"]
    self.AtlasLabel_TotalTunShu = self.resourceNode_.node["Panel_End"].node["AtlasLabel_TotalTunShu"]

    self.Text_WinName               = self.resourceNode_.node["Panel_End"].node["Text_WinName"]
    self.Text_WinScore              = self.resourceNode_.node["Panel_End"].node["Text_WinScore"]
    
    self.Text_LostName = {}
    self.Text_LostScore = {}
    for i = 1, (G_GameDefine.GAME_PLAYER - 1) do
        self.Text_LostName[i]       = self.resourceNode_.node["Panel_End"].node["Text_LostName"..i]
        self.Text_LostScore[i]      = self.resourceNode_.node["Panel_End"].node["Text_LostScore"..i]
    end
end

-- 初始化视图
function M:initView()
	self.Button_Continue:setVisible(true)
    self.Button_Close:setVisible(true)

    self.AtlasLabel_HuXi:setString(0)
    self.AtlasLabel_TunShu:setString(0)
    self.AtlasLabel_FanShu:setString(0)
    self.AtlasLabel_TotalTunShu:setString(0)
end

-- 初始化触摸
function M:initTouch()
	self.Button_Continue:addClickEventListener(handler(self, self.Click_Continue))
    self.Button_Close:addClickEventListener(handler(self, self.Click_Close))
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

    -- 设置玩家信息
    if msg.nWinSeat ~= G_GameDefine.INVALID_SEAT then
        local nIndex = 1
        for i = 1, G_GameDefine.GAME_PLAYER do
            local p = G_GamePlayer:getPlayerBySeverSeat(i)
            if i == msg.nWinSeat then
                if p then
                    self.Text_WinName:setString(p.nickname)
                    self.Text_WinName:setVisible(true)

                    self.Text_WinScore:setString(msg.tGameScore[i])
                    self.Text_WinScore:setVisible(true)
                else
                    self.Text_WinName:setVisible(false)

                    self.Text_WinScore:setVisible(false)
                end
            else
                if p then
                    self.Text_LostName[nIndex]:setString(p.nickname)
                    self.Text_LostName[nIndex]:setVisible(true)

                    self.Text_LostScore[nIndex]:setString(msg.tGameScore[i])
                    self.Text_LostScore[nIndex]:setVisible(true)
                else
                    self.Text_LostName[nIndex]:setVisible(false)

                    self.Text_LostScore[nIndex]:setVisible(false)
                end
                nIndex = nIndex + 1
            end
        end
    else
        local nIndex = 1
        for i = 1, G_GameDefine.GAME_PLAYER do
            local p = G_GamePlayer:getPlayerBySeverSeat(i)
            if i == msg.nBankSeat then
                if p then
                    self.Text_WinName:setString(p.nickname)
                    self.Text_WinName:setVisible(true)

                    self.Text_WinScore:setString(msg.tGameScore[i])
                    self.Text_WinScore:setVisible(true)
                else
                    self.Text_WinName:setVisible(false)

                    self.Text_WinScore:setVisible(false)
                end
            else
                if p then
                    self.Text_LostName[nIndex]:setString(p.nickname)
                    self.Text_LostName[nIndex]:setVisible(true)

                    self.Text_LostScore[nIndex]:setString(msg.tGameScore[i])
                    self.Text_LostScore[nIndex]:setVisible(true)
                else
                    self.Text_LostName[nIndex]:setVisible(false)

                    self.Text_LostScore[nIndex]:setVisible(false)
                end
                nIndex = nIndex + 1
            end
        end
    end

    -- 设置胡牌类型
    local tHuPaiType =
    {
	    ["TianHu"] = "天胡",
	    ["DiHu"] = "地胡",
	    ["PengPengHu"] = "碰碰胡",
	    ["HeiHu"] = "黑胡",
	    ["ShiHong"] = "十红",
	    ["YiDianHong"] = "一点红", 
	    ["ShiBaDa"] = "十八大", 
	    ["ShiBaXiao"] = "十八小",
	    ["ErBi"] = "二比",
	    ["SanBi"] = "三比",
	    ["SiBi"] = "四比",
	    ["ShuangPiao"] = "双飘",
    }
    local nBase = 0
    for nIndex, tData in pairs(msg.huPaiInfo.options) do
        local szName = tHuPaiType[tData.key]
        local nTextPoint = cc.p(100, 300 + (nIndex - 1) * 50)
        local pText = ccui.Text:create()
        pText:setString(szName)
        pText:setFontSize(24)
        pText:setPosition(nTextPoint)
        self.Panel_End:addChild(pText)

        local nTempBase = tData.nValue
        nBase = nBase + nTempBase
        local nAtlasLabelPoint = cc.p(200, 300 + (nIndex - 1) * 50)
        local pAtlasLabel = ccui.TextAtlas:create(nBase,"Common/clock_font.png",20,28,"0")
        pAtlasLabel:setString(nTempBase)
        pAtlasLabel:setPosition(nAtlasLabelPoint)
        self.Panel_End:addChild(pAtlasLabel)
    end
    if msg.nWinSeat ~= G_GameDefine.INVALID_SEAT and nBase == 0 then
        nBase = 1
    end
    
    -- 游戏结束牌处理
    self.GameEndCardManager = GameEndCardManager:create()
	self.Panel_End:addChild(self.GameEndCardManager)
    if msg.nWinSeat ~= G_GameDefine.INVALID_SEAT then
        -- 显示组合
        self.GameEndCardManager:showCard(msg.weaveInfo[msg.nWinSeat].options)
    end
    -- 显示底牌
    self.GameEndCardManager:showRepertoryCard(msg.tRepertoryCard)

    -- 总胡息
    local nHuXi = 0
    if msg.nWinSeat ~= G_GameDefine.INVALID_SEAT then
        for _, tWeave in ipairs(msg.weaveInfo[msg.nWinSeat].options) do
            local nTempHuXi = self.GameEndCardManager:getCardHuXi(tWeave)
            if nTempHuXi then
                nHuXi = nHuXi + nTempHuXi
            end
        end
    end
    self.AtlasLabel_HuXi:setString(nHuXi)

    -- 囤数
    local nTunShu = 0
    if msg.nWinSeat ~= G_GameDefine.INVALID_SEAT then
        nTunShu = math.floor((nHuXi - G_GameDefine.MIN_HU_XI) / 3 + 1)
    end
    self.AtlasLabel_TunShu:setString(nTunShu)

    -- 番数
    self.AtlasLabel_FanShu:setString(nBase)

    -- 总囤数
    local nTotal = nBase * nTunShu
    self.AtlasLabel_TotalTunShu:setString(nTotal)
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
