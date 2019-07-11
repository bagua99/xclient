
local GameTotalEndLayer = class("GameTotalEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

GameTotalEndLayer.RESOURCE_FILENAME = GameConfigManager.tGameID.NN.."/GameTotalEndLayer.csb"

function GameTotalEndLayer:onCreate()

    self.ShareBtn = self.resourceNode_.node["ShareBtn"]
    self.QuitBtn = self.resourceNode_.node["QuitBtn"]

    self.MaxWinSprite = self.resourceNode_.node["ImageBg"].node["MaxWinSprite"]
    self.tEnd = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        local tData = {}
        tData.Image = self.resourceNode_.node["ImageBg"].node["Image_"..i]
        tData.IDText = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["IDText"]
        tData.NameText = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["NameText"]
        tData.AtlasLabel = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["AtlasLabel"]
        tData.NiuNiuAtlasLabel = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["NiuNiuAtlasLabel"]
        tData.NiuJiuAtlasLabel = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["NiuJiuAtlasLabel"]
        tData.NiuBaAtlasLabel = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["NiuBaAtlasLabel"]
        tData.NiuQiAtlasLabel = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["NiuQiAtlasLabel"]
        tData.NiuLiuAtlasLabel = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["NiuLiuAtlasLabel"]
        tData.WuNiuAtlasLabel = self.resourceNode_.node["ImageBg"].node["Image_"..i].node["WuNiuAtlasLabel"]

        self.tEnd[i] = tData
    end
end

function GameTotalEndLayer:initView()

	self.ShareBtn:setVisible(true)
    self.QuitBtn:setVisible(true)

    self.MaxWinSprite:setVisible(false)

    for i=1, G_GameDefine.nMaxPlayerCount do
	    self.tEnd[i].Image:setVisible(false)
    end
end
function GameTotalEndLayer:initTouch()

	self.ShareBtn:addClickEventListener(handler(self, self.Click_Share))
    self.QuitBtn:addClickEventListener(handler(self, self.Click_Quit))
end

function GameTotalEndLayer:Click_Share()

	ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡牛牛，来战啊！", "Icon-120.png", "http://www.abletele.com/xiaoyou/index.html")
end

function GameTotalEndLayer:Click_Quit()

	G_Data.CL_JoinGameAck.roomid = 0
	G_NetManager:disconnect(NETTYPE_GAME)
	G_SceneManager:enterScene(SCENE_LOBBY)
end

function GameTotalEndLayer:onEnter()
	
end

function GameTotalEndLayer:addTouch()

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function GameTotalEndLayer:GameTotalEndAck(tInfo)

    local nMaxScore = -1
    local nMaxWin = 0
    for i=1, G_GameDefine.nMaxPlayerCount do
        if tInfo.lTotalScore[i] > nMaxScore then
			nMaxWin = i
            nMaxScore = tInfo.lTotalScore[i]
		end
    end

    -- 最大赢家
    if nMaxWin > 0 then
        self.MaxWinSprite:setPosition(cc.p(60+130*(nMaxWin-1), 510))
        self.MaxWinSprite:setVisible(true)
    end
    
    for i=1, G_GameDefine.nMaxPlayerCount do

        local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i-1)
        if curPlayerInfo == nil then
            self.tEnd[i].Image:setVisible(false)
        else
            self.tEnd[i].Image:setVisible(true)

            -- ID
            self.tEnd[i].IDText:setString("ID:"..curPlayerInfo.ullUserID)
            self.tEnd[i].IDText:setVisible(true)

            -- Name
            self.tEnd[i].NameText:setString(curPlayerInfo.szNickName)
            self.tEnd[i].NameText:setVisible(true)

            -- 无牛
            local nWuNiuCount = tInfo.cbNiuCount[i][1]
            -- 牛1~牛6
            local nNiuLiuCount = 0
            for j=2, 7 do
                nNiuLiuCount = nNiuLiuCount + tInfo.cbNiuCount[i][j]
            end
            -- 牛7
            local nNiuQiCount = tInfo.cbNiuCount[i][8]
            -- 牛8
            local nNiuBaCount = tInfo.cbNiuCount[i][9]
            -- 牛9
            local nNiuJiuCount = tInfo.cbNiuCount[i][10]
            -- 牛牛
            local nNiuNiuCount = 0
            for j=11, 13 do
                nNiuNiuCount = nNiuNiuCount + tInfo.cbNiuCount[i][j]
            end

            self.tEnd[i].WuNiuAtlasLabel:setString(nWuNiuCount)
            self.tEnd[i].WuNiuAtlasLabel:setVisible(true)

            self.tEnd[i].NiuLiuAtlasLabel:setString(nNiuLiuCount)
            self.tEnd[i].NiuLiuAtlasLabel:setVisible(true)

            self.tEnd[i].NiuQiAtlasLabel:setString(nNiuQiCount)
            self.tEnd[i].NiuQiAtlasLabel:setVisible(true)

            self.tEnd[i].NiuBaAtlasLabel:setString(nNiuBaCount)
            self.tEnd[i].NiuBaAtlasLabel:setVisible(true)

            self.tEnd[i].NiuJiuAtlasLabel:setString(nNiuJiuCount)
            self.tEnd[i].NiuJiuAtlasLabel:setVisible(true)

            self.tEnd[i].NiuNiuAtlasLabel:setString(nNiuNiuCount)
            self.tEnd[i].NiuNiuAtlasLabel:setVisible(true)

            -- 总积分
            self.tEnd[i].AtlasLabel:setString(tInfo.lTotalScore[i])
            self.tEnd[i].AtlasLabel:setVisible(true)
        end
    end
end

function GameTotalEndLayer:onExit()
	if self.listener ~= nil then
		self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
	end
end

return GameTotalEndLayer
