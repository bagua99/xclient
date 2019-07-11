
local M = class("GameTotalEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.PDK.."/GameTotalEndLayer.csb"

local EventConfig               = require ("app.config.EventConfig")
local targetPlatform            = cc.Application:getInstance():getTargetPlatform()
local scheduler                 = cc.Director:getInstance():getScheduler()

-- 创建
function M:onCreate()
	self.ShareBtn = self.resourceNode_.node["ShareBtn"]
    self.QuitBtn = self.resourceNode_.node["QuitBtn"]
    self.BG = self.resourceNode_.node["BG"]
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)
    self.Conclude_Score = 0

    self.shareFileName = "pdk_result.png"
end

-- 初始化视图
function M:initView()
    self.QuitBtn:setVisible(true)
    if EventConfig.CHECK_IOS then 
        self.ShareBtn:setVisible(false)
    else 
        self.ShareBtn:setVisible(true)
    end
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        cc.FileUtils:getInstance():removeFile(ImageFile)
    end
end

-- 初始化触摸
function M:initTouch()
	self.ShareBtn:addClickEventListener(handler(self, self.Click_Share))
    self.QuitBtn:addClickEventListener(handler(self, self.Click_Quit))
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
function M:GameTotalEndAck(msg, bDisovleGame, master_id)
    for i=1, G_GameDefine.nMaxPlayerCount do
		local _player = G_GamePlayer:getPlayerBySeverSeat(i)
		local pNode = self.resourceNode_.node["Node_"..i]
		if _player == nil then
			pNode:setVisible(false)
		else
            local headimg_file = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
            if cc.FileUtils:getInstance():isFileExist(headimg_file) then
                local pNode_HeadSpr = self.resourceNode_.node["Node_"..i].node["headSpr"..i]
                pNode_HeadSpr:setTexture(headimg_file)
                pNode_HeadSpr:setScale(59/pNode_HeadSpr:getContentSize().width, 59/pNode_HeadSpr:getContentSize().height)
            end
            local pNode_PlayName = self.resourceNode_.node["Node_"..i].node["playname"..i]
            if pNode_PlayName ~= nil then
                local szNickName = _player.nickname
                local len = string.len(szNickName)
                if len>12 then 
                    szNickName = string.sub(szNickName,1,12).."..."
                end
                pNode_PlayName:setString(szNickName)
            end

            local pNode_PlayID = self.resourceNode_.node["Node_"..i].node["playid"..i]
            if pNode_PlayID ~= nil then
                pNode_PlayID:setString(_player.userid)
            end

            local pNode_TotalScore = self.resourceNode_.node["Node_"..i].node["totalscore"..i]
            if pNode_TotalScore ~= nil then
                if msg.nTotalScore[i] > 0 then 
                    msg.nTotalScore[i] = "+"..msg.nTotalScore[i]
                end 
                pNode_TotalScore:setString(msg.nTotalScore[i])
            end

            local pNode_Score = self.resourceNode_.node["Node_"..i].node["score"..i]
            if pNode_Score ~= nil then
                pNode_Score:setString(msg.nMaxScore[i])
            end

            local pNode_ZhaDan = self.resourceNode_.node["Node_"..i].node["zhadan"..i]
            if pNode_ZhaDan ~= nil then
                pNode_ZhaDan:setString(msg.nAllBombCount[i])
            end

            local LostCount = G_GameDefine.nGameCount - msg.nWinCount[i]
            if bDisovleGame and G_GameDefine.nGameStatus == G_GameDefine.game_play then
                LostCount = G_GameDefine.nGameCount - 1 - msg.nWinCount[i]
            end
            if LostCount < 0 then
                LostCount = 0
            end
            local pNode_JuShu = self.resourceNode_.node["Node_"..i].node["jushu"..i]
            if pNode_JuShu ~= nil then
                local str = msg.nWinCount[i].."胜"..LostCount.."负"
                pNode_JuShu:setString(str)
            end
            local pNode_Conclude = self.resourceNode_.node["Node_"..i].node["Text_CONCLUDE"]
            local conclude = msg.nTotalScore[i] - self.Conclude_Score
            if conclude>0 then 
                conclude = "+"..conclude
            elseif conclude<0 then 
                
            else 
                conclude = 0 
            end 
            pNode_Conclude:setString(conclude)
            pNode_Conclude:setVisible(false)

            --local pNode_Fangzhu =  self.resourceNode_.node["Node_"..i].node["IMG_FANGZHU"]
            --pNode_Fangzhu:setVisible(master_id == _player.userid)
        end
    end
end

-- 分享
function M:Click_Share()
    G_CommonFunc:addClickSound()
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡跑得快，来战啊！", ImageFile, "")
    else
        self.scehdule = scheduler:scheduleScriptFunc(handler(self,self.checkIsFileExist),0.1,false)
    end
end

function M:checkIsFileExist()
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..self.shareFileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡跑得快，来战啊！", ImageFile, "")
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
