
local M = class("GameEndLayer", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")

M.RESOURCE_FILENAME = GameConfigManager.tGameID.YZBP.."/GameEndLayer.csb"

-- 创建
function M:onCreate()
	self.bToOver = false

    self.Button_Continue = self.resourceNode_.node["Button_Continue"]

    self:setScale(G_DeskScene.GameDeskLayer.tScale.width, G_DeskScene.GameDeskLayer.tScale.height)
end

-- 初始化视图
function M:initView()
	self.Button_Continue:setVisible(true)
end

-- 初始化触摸
function M:initTouch()
	self.Button_Continue:addClickEventListener(handler(self, self.Click_Continue))
end

-- 进入场景
function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self)
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
    
    local nIndex = 1
    for i = 1, G_GameDefine.player_count do
        if i == msg.nBankerSeat then
            local Panel = self.resourceNode_.node["ImageBG"].node["Panel_4"]
            local _player = G_GamePlayer:getPlayerBySeverSeat(i)
            if _player == nil then
                Panel:setVisible(false)
            else
                local headimg_file = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
                if cc.FileUtils:getInstance():isFileExist(headimg_file) then
                    local Image_Head = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["Image_Head"]
                    Image_Head:setTexture(headimg_file)
                end

                local Text_Name = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["Text_Name"]
                local szNickName = _player.nickname
                local nLen = string.len(szNickName)
                if nLen > 12 then 
                    szNickName = string.sub(szNickName, 1, 12).."..."
                end
                Text_Name:setString(szNickName)

                local strMain
                if msg.nMainCard == G_DeskScene.GameLogic.COLOR_FANG then
                    strMain = "imgFang"
                elseif msg.nMainCard == G_DeskScene.GameLogic.COLOR_MEI then
                    strMain = "imgMei"
                elseif msg.nMainCard == G_DeskScene.GameLogic.COLOR_HONG then
                    strMain = "imgHao"
                elseif msg.nMainCard == G_DeskScene.GameLogic.COLOR_HEI then
                    strMain = "imgHei"
                elseif msg.nMainCard == G_DeskScene.GameLogic.COLOR_CHANGEZHU then
                    strMain = "imgZhu"
                end
                local Image_Main = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["Image_Main"]
                Image_Main:ignoreContentAdaptWithSize(true)
                Image_Main:loadTexture("SDH_"..strMain..".png", ccui.TextureResType.plistType)

                local Text_BankerScore = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["Text_BankerScore"]
                Text_BankerScore:setString("庄分："..(205 - msg.nCallScore))

                local Text_PickScore = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["Text_PickScore"]
                Text_PickScore:setString("得分："..msg.nPickScore)

                local strScore = msg.nGameScore[i]
                if msg.nGameScore[i] < 0 then
                    strScore = "."..math.abs(msg.nGameScore[i])
                else
                    strScore = "/"..msg.nGameScore[i]
                end
                local AtlasLabel_Score = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["AtlasLabel_Score"]
                AtlasLabel_Score:setString(strScore)

                local Image_Result = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["Image_Result"]
                Image_Result:ignoreContentAdaptWithSize(true)
                local nScore = math.modf(msg.nGameScore[i] / (G_GameDefine.player_count - 1))
                local strResult = "SDH_winlose_label_chouzhuang.png"
                if msg.bSurrender then
                    strResult = "SDH_winlose_label_he.png"
                else
                    if nScore > 0 and nScore <= 3 then
                        strResult = "SDH_winlose_label_"..nScore..".png"
                    elseif nScore < 0 and nScore >= -3 then
                        strResult = "SDH_winlose_label_"..(3 + math.abs(nScore))..".png"
                    elseif nScore < -3 then
                        strResult = "SDH_winlose_label_6.png"
                    end
                    Image_Result:setPositionX(Image_Result:getPositionX()*0.61)
                end
                Image_Result:loadTexture(strResult, ccui.TextureResType.plistType)

                local AtlasLabel_Result = self.resourceNode_.node["ImageBG"].node["Panel_4"].node["AtlasLabel_Result"]
                if nScore < -3 then
                    AtlasLabel_Result:setString("/"..math.abs(nScore) - 3)
                end
                AtlasLabel_Result:setVisible(nScore < -3)
            end
        else
            local Panel = self.resourceNode_.node["ImageBG"].node["Panel_"..nIndex]
            local _player = G_GamePlayer:getPlayerBySeverSeat(i)
            if _player == nil then
                Panel:setVisible(false)
            else
                local headimg_file = cc.FileUtils:getInstance():getWritablePath().."avatarHead".._player.userid..".png"
                if cc.FileUtils:getInstance():isFileExist(headimg_file) then
                    local Image_Head = self.resourceNode_.node["ImageBG"].node["Panel_"..nIndex].node["Image_Head"]
                    Image_Head:setTexture(headimg_file)
                end

                local Text_Name = self.resourceNode_.node["ImageBG"].node["Panel_"..nIndex].node["Text_Name"]
                local szNickName = _player.nickname
                local nLen = string.len(szNickName)
                if nLen > 12 then 
                    szNickName = string.sub(szNickName, 1, 12).."..."
                end
                Text_Name:setString(szNickName)

                local strScore = msg.nGameScore[i]
                if msg.nGameScore[i] < 0 then
                    strScore = "."..math.abs(msg.nGameScore[i])
                else
                    strScore = "/"..msg.nGameScore[i]
                end
                local AtlasLabel_Score = self.resourceNode_.node["ImageBG"].node["Panel_"..nIndex].node["AtlasLabel_Score"]
                AtlasLabel_Score:setString(strScore)
            end

            nIndex = nIndex + 1
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

return M
