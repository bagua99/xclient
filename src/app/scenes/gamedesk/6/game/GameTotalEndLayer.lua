
local M = class("GameTotalEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.YZBP.."/GameTotalEndLayer.csb"

local EventConfig               = require ("app.config.EventConfig")
local targetPlatform            = cc.Application:getInstance():getTargetPlatform()
local scheduler                 = cc.Director:getInstance():getScheduler()

-- 创建
function M:onCreate()
	self.Button_Back        = self.resourceNode_.node["Button_Back"]
    self.Button_Share       = self.resourceNode_.node["Button_Share"]

    self:setScale(G_DeskScene.GameDeskLayer.tScale.width, G_DeskScene.GameDeskLayer.tScale.height)

    self.shareFileName = "yzbp_result.png"
end

-- 初始化视图
function M:initView()
    self.Button_Back:setVisible(true)
    if EventConfig.CHECK_IOS then 
        self.Button_Share:setVisible(false)
    else 
        self.Button_Share:setVisible(true)
    end
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        cc.FileUtils:getInstance():removeFile(ImageFile)
    end
end

-- 初始化触摸
function M:initTouch()
	self.Button_Share:addClickEventListener(handler(self, self.Click_Share))
    self.Button_Back:addClickEventListener(handler(self, self.Click_Quit))
end

-- 进入场景
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)

    G_CommonFunc:captureScreen(self.resourceNode_, self.shareFileName)
end

-- 退出场景
function M:onExit()
	if self.listener then
		self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
	end

    if self.scehdule then
        scheduler:unscheduleScriptEntry(self.scehdule)
        self.scehdule = nil
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

-- 总结算消息
function M:GameTotalEndAck(msg, bDisovleGame, nMasterID, nRoomID)
    -- 找出最大贏分
    local nMaxScore = 0
    for _, v in pairs(msg.nTotalScore) do
        if v >= nMaxScore then
            nMaxScore = v
        end
    end

    for i = 1, G_GameDefine.player_count do
        local Image = self.resourceNode_.node["Image_BG"].node["Image_"..i]
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
		if _player == nil then
			Image:setVisible(false)
        else
            local Node = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["Node"]
            local headimg_file = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
            if cc.FileUtils:getInstance():isFileExist(headimg_file) then
                local ImageView_Head = ccui.ImageView:create()
                ImageView_Head:loadTexture(headimg_file)
                ImageView_Head:setVisible(true)
                self:addChild(Node)
            end
            local Text_Name = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["Text_Name"]
            if Text_Name ~= nil then
                local szNickName = _player.nickname
                local nLen = string.len(szNickName)
                if nLen > 12 then 
                    szNickName = string.sub(szNickName, 1, 12).."..."
                end
                Text_Name:setString(szNickName)
            end

            local Text_ID = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["Text_ID"]
            if Text_ID ~= nil then
                Text_ID:setString(_player.userid)
            end

            local AtlasLabel_BankerCount = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["AtlasLabel_BankerCount"]
            if AtlasLabel_BankerCount ~= nil then
                AtlasLabel_BankerCount:setString(msg.nBankerCount[i])
            end

            local AtlasLabel_MaxScore = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["AtlasLabel_MaxScore"]
            if AtlasLabel_MaxScore ~= nil then
                AtlasLabel_MaxScore:setString(msg.nMaxScore[i])
            end

            local AtlasLabel_MaxBankerScore = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["AtlasLabel_MaxBankerScore"]
            if AtlasLabel_MaxBankerScore ~= nil then
                AtlasLabel_MaxBankerScore:setString(msg.nMaxBankerScore[i])
            end

            local AtlasLabel_WinCount = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["AtlasLabel_WinCount"]
            if AtlasLabel_WinCount ~= nil then
                AtlasLabel_WinCount:setString(msg.nWinCount[i])
            end

            local nLostCount = G_GameDefine.nGameCount - msg.nWinCount[i]
            if bDisovleGame and G_GameDefine.nGameStatus == G_GameDefine.game_play then
                nLostCount = G_GameDefine.nGameCount - 1 - msg.nWinCount[i]
            end
            if nLostCount < 0 then
                nLostCount = 0
            end
            local AtlasLabel_LoseCount = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["AtlasLabel_LoseCount"]
            if AtlasLabel_LoseCount ~= nil then
                AtlasLabel_LoseCount:setString(nLostCount)
            end

            local AtlasLabel_TotalScore = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["AtlasLabel_TotalScore"]
            if AtlasLabel_TotalScore ~= nil then
                local strScore = msg.nTotalScore[i]
                if msg.nTotalScore[i] > 0 then
                    strScore = "/"..msg.nTotalScore[i]
                elseif msg.nTotalScore[i] < 0 then
                    strScore = "."..msg.nTotalScore[i]
                end
                AtlasLabel_TotalScore:setString(strScore)
            end

            local Image_BigWinner = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["Image_BigWinner"]
            if Image_BigWinner ~= nil then
                Image_BigWinner:setVisible(msg.nTotalScore[i] == nMaxScore)
            end

            local Image_FangZhu = self.resourceNode_.node["Image_BG"].node["Image_"..i].node["Image_FangZhu"]
            if Image_FangZhu ~= nil then
                Image_FangZhu:setVisible(nMasterID == _player.userid)
            end
        end
    end

    local Text_GameName = self.resourceNode_.node["Panel"].node["Text_GameName"]
    if Text_GameName ~= nil then
        Text_GameName:setString("永州包牌")
    end

    local Text_GameInfo = self.resourceNode_.node["Panel"].node["Text_GameInfo"]
    if Text_GameInfo ~= nil then
        Text_GameInfo:setString("房号:"..nRoomID.." 局数:"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")
    end

    local Text_GameTime = self.resourceNode_.node["Panel"].node["Text_GameTime"]
    if Text_GameTime ~= nil then
        Text_GameTime:setString(os.date("%Y-%m-%d   %H:%M:%S",os.time()))
    end
end

-- 分享
function M:Click_Share()
    G_CommonFunc:addClickSound()
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "永州包牌，来战啊！", ImageFile, "")
    else
        self.scehdule = scheduler:scheduleScriptFunc(handler(self, self.checkIsFileExist),0.1,false)
    end
end

function M:checkIsFileExist()
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "永州包牌，来战啊！", ImageFile, "")
        if self.scehdule ~= nil then
            scheduler:unscheduleScriptEntry(self.scehdule)
            self.scehdule = nil
        end
    end 
end

-- 退出
function M:Click_Quit()
    G_CommonFunc:addClickSound()
	G_Data.roomid = 0
	G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
	G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end

return M
