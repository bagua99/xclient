
local M = class("GameTotalEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.NN.."/GameTotalEndLayer.csb"

local targetPlatform            = cc.Application:getInstance():getTargetPlatform()
local EventConfig               = require ("app.config.EventConfig")

-- 创建
function M:onCreate()
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

    if EventConfig.CHECK_IOS then 
        self.ShareBtn:setVisible(false)
    else 
        self.ShareBtn:setVisible(true)
    end
end

-- 初始视图
function M:initView()
	self.ShareBtn:setVisible(true)
    self.QuitBtn:setVisible(true)
    self.MaxWinSprite:setVisible(false)

    for i=1, G_GameDefine.nMaxPlayerCount do
	    self.tEnd[i].Image:setVisible(false)
    end
end

-- 初始触摸
function M:initTouch()
	self.ShareBtn:addClickEventListener(handler(self, self.Click_Share))
    self.QuitBtn:addClickEventListener(handler(self, self.Click_Quit))
end

-- 进入场景
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self, self.onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
end

-- 退出场景
function M:onExit()
	if self.listener then
		self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
	end
end

function M:onTouchBegin()
	return self:isVisible()
end

function M:onTouchMove()

end

function M:onTouchEnded()

end

-- 点击分享
function M:Click_Share()
    local fileName = "nn_result.png"
    G_CommonFunc:captureScreen(self.resourceNode_,  fileName)

    function callShare()
        local ImageFile = cc.FileUtils:getInstance():getWritablePath()..fileName
        if cc.FileUtils:getInstance():isFileExist(ImageFile) then
            ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡牛牛，来战啊！", ImageFile, "")
        end  
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(callShare)))
end

-- 点击退出
function M:Click_Quit()
	G_Data.roomid = 0
	G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
	G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end

local function get_niu_info(tInfo)
	local ret = {}
	for _,info in ipairs(tInfo.infos) do
		local niu_info = {
			nWuNiuCount = 0,
			nNiuLiuCount = 0,
			nNiuQiCount = 0,
			nNiuBaCount = 0,
			nNiuJiuCount = 0,
			nNiuNiuCount = 0,
		}
        for _,niu in ipairs(info.niu_array) do
			if niu == 0 then
				niu_info.nWuNiuCount = niu_info.nWuNiuCount + 1
			elseif niu >= 2 and niu <= 6 then
				niu_info.nNiuLiuCount = niu_info.nNiuLiuCount + 1
			elseif niu == 7 then
				niu_info.nNiuQiCount = niu_info.nNiuQiCount + 1
			elseif niu == 8 then
				niu_info.nNiuBaCount = niu_info.nNiuBaCount + 1
			elseif niu == 9 then
				niu_info.nNiuJiuCount = niu_info.nNiuJiuCount + 1
			elseif niu >= 10 then
				niu_info.nNiuNiuCount = niu_info.nNiuNiuCount + 1
			end
		end
		ret[info.seat] = niu_info
    end
	
	return ret
end

-- 游戏总结束
function M:GameTotalEndAck(tInfo)
    local nMaxScore = -1
    local nMaxWin = 0
    for _,info in ipairs(tInfo.infos) do
        if info.total_count > nMaxScore then
			nMaxWin = info.seat
            nMaxScore = info.total_count
		end
    end

    -- 最大赢家
    if nMaxWin > 0 then
        self.MaxWinSprite:setPosition(cc.p(60+130*(nMaxWin-1), 510))
        self.MaxWinSprite:setVisible(true)
    end
    
	for i=1,8 do
        self.tEnd[i].Image:setVisible(false)
    end
	
	local niu_infos = get_niu_info(tInfo)
	if G_GamePlayer.main_player.seat == 1 then
	end
    for _, info in ipairs(tInfo.infos) do
		local i = info.seat
        local curPlayerInfo = G_GamePlayer:getPlayerBySeverSeat(i)
		self.tEnd[i].Image:setVisible(true)
		print("大结束1")
		-- ID
		self.tEnd[i].IDText:setString("ID:"..curPlayerInfo.userid)
		self.tEnd[i].IDText:setVisible(true)

		-- Name
		local szNickName = curPlayerInfo.nickname
        local len = string.len(szNickName)
        if len>12 then 
            szNickName = string.sub(szNickName,1,12).."..."
        end
		self.tEnd[i].NameText:setString(szNickName)
		self.tEnd[i].NameText:setVisible(true)

		local niu_info = niu_infos[i]
		print("大结束2")
		self.tEnd[i].WuNiuAtlasLabel:setString(niu_info.nWuNiuCount)
		self.tEnd[i].WuNiuAtlasLabel:setVisible(true)

		self.tEnd[i].NiuLiuAtlasLabel:setString(niu_info.nNiuLiuCount)
		self.tEnd[i].NiuLiuAtlasLabel:setVisible(true)

		self.tEnd[i].NiuQiAtlasLabel:setString(niu_info.nNiuQiCount)
		self.tEnd[i].NiuQiAtlasLabel:setVisible(true)

		self.tEnd[i].NiuBaAtlasLabel:setString(niu_info.nNiuBaCount)
		self.tEnd[i].NiuBaAtlasLabel:setVisible(true)

		self.tEnd[i].NiuJiuAtlasLabel:setString(niu_info.nNiuJiuCount)
		self.tEnd[i].NiuJiuAtlasLabel:setVisible(true)

		self.tEnd[i].NiuNiuAtlasLabel:setString(niu_info.nNiuNiuCount)
		self.tEnd[i].NiuNiuAtlasLabel:setVisible(true)

		-- 总积分
		self.tEnd[i].AtlasLabel:setString(info.total_count)
		self.tEnd[i].AtlasLabel:setVisible(true)
		print("大结束3")
    end
end

return M
