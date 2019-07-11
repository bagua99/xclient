
local M = class("GameTotalEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.NXPHZ.."/GameTotalEndLayer.csb"

local scheduler                 = cc.Director:getInstance():getScheduler()
local EventConfig               = require ("app.config.EventConfig")
local GameTotalItemLayer        = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".game.GameTotalItemLayer")
local GameTotalScoreItemLayer   = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NXPHZ..".game.GameTotalScoreItemLayer")

-- 创建
function M:onCreate()
	self.Button_Share = self.resourceNode_.node["Button_Share"]
    self.Button_Close = self.resourceNode_.node["Button_Close"]

    self.ListView = self.resourceNode_.node["ListView"]

    self.shareFileName = "nxphz_result.png"
end

-- 初始化视图
function M:initView()
    self.Button_Close:setVisible(true)
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
    self.Button_Close:addClickEventListener(handler(self, self.Click_Quit))
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
function M:GameTotalEndAck(msg, bDisovleGame, master_id)
    local totalItemLayer = GameTotalItemLayer.new()
	self.ListView:setItemModel(totalItemLayer.Panel)

    for _ = 1, G_GameDefine.nPlayerCount do
        self.ListView:pushBackDefaultItem()
    end

    local nMaxScore = -1
    local nMaxWin = 0
    for i, nScore in ipairs(msg.tTotalScore) do
        if nScore > nMaxScore then
			nMaxWin = i
            nMaxScore = nScore
		end
    end

    local totalItems = self.ListView:getItems()
    -- totalItem == totalItemLayer.Panel
    for i, totalItem in ipairs(totalItems) do
        local _player = G_GamePlayer:getPlayerBySeverSeat(i)
        if _player == nil then
			totalItem:setVisible(false)
        else
            -- 头像
            local headimg_file = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
            if cc.FileUtils:getInstance():isFileExist(headimg_file) then
                local ImageView_Head = totalItem:getChildByName("ImageView_Head")
                ImageView_Head:setTexture(headimg_file)
                ImageView_Head:setScale(55/pNode_HeadSpr:getContentSize().width, 55/pNode_HeadSpr:getContentSize().height)
            end

            -- 名字
            local szNickName = _player.nickname
            if string.len(szNickName) > 12 then 
                szNickName = string.sub(szNickName, 1, 12).."..."
            end
            totalItem:getChildByName("ImageView_NameBG"):getChildByName("Text_Name"):setString(szNickName)

            -- 分数
            totalItem:getChildByName("ImageView_ScoreBG"):getChildByName("Text_Score"):setString(msg.tTotalScore[i])

            -- 大赢家
            totalItem:getChildByName("ImageView_MaxWin"):setVisible(nMaxWin == i)

            -- 房主
            totalItem:getChildByName("ImageView_HouseOwner"):setVisible(master_id == _player.userid)

            -- 显示每局分数
            local tScore = {}
            for _, gameScore in ipairs(msg.gameScore) do
                for nIndex, nScore in ipairs(gameScore.tGameScore) do
                    if i == nIndex then
                        table.insert(tScore, nScore)
                    end
                end
            end
            local ListView_Result = totalItem:getChildByName("ListView_Result")
            local totalScoreItemLayer = GameTotalScoreItemLayer.new()
	        ListView_Result:setItemModel(totalScoreItemLayer.Panel)

            for _ = 1, table.getn(tScore) do
                ListView_Result:pushBackDefaultItem()
            end
            local totalScoreItems = ListView_Result:getItems()
            -- totalScoreItem == totalScoreItemLayer.Panel
            for nIndex, totalScoreItem in ipairs(totalScoreItems) do
                totalScoreItem:getChildByName("Text_Count"):setString("第"..nIndex.."局")
                totalScoreItem:getChildByName("Text_Score"):setString(tScore[nIndex])
            end
        end
    end
end

-- 分享
function M:Click_Share()
    G_CommonFunc:addClickSound()
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡跑胡子，来战啊！", ImageFile, "")
    else
        self.scehdule = scheduler:scheduleScriptFunc(handler(self, self.checkIsFileExist), 0.1, false)
    end
end

function M:checkIsFileExist()
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        if self.scehdule ~= nil then
            scheduler:unscheduleScriptEntry(self.scehdule)
            self.scehdule = nil
        end

        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡跑胡子，来战啊！", ImageFile, "")
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
