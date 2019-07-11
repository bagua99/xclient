local M = class("TotalLayer",function()
	return display.newLayer()
end)

M.panel = nil 
M.root  = nil 
M.list = nil 
M.base_score = 200

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local TotalItemLayer            = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".game.TotalItemLayer")
local targetPlatform            = cc.Application:getInstance():getTargetPlatform()
local scheduler                 = cc.Director:getInstance():getScheduler()
local EventConfig               = require ("app.config.EventConfig")

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
			score = 0 , 
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
		niu_info.score = info.total_count 
		table.insert(ret, niu_info)
    end
	
	return ret
end

function M:ctor(gameid, tInfo, master_id)
	self:enableNodeEvents()
	local node = cc.CSLoader:createNode("res/"..gameid.."/TotalLayer.csb");
	node:addTo(self)
	self.root = node 
	self:initView(gameid,tInfo,master_id)
end

function M:initView(gameid,tInfo,master_id)
	self.panel = self.root:getChildByName("Panel")
	self.list = self.panel:getChildByName("ListView")
	self.BG = self.root:getChildByName("BG")
	self.BTN_CLOSE = self.panel:getChildByName("BTN_CLOSE")
	self.BTN_CONTINUE = self.panel:getChildByName("BTN_CONTINUE")
	self.BTN_SHARED = self.panel:getChildByName("BTN_SHARED")

	if EventConfig.CHECK_IOS then 
        self.BTN_SHARED:setVisible(false)
    else 
        self.BTN_SHARED:setVisible(true)
    end

	self.BTN_SHARED:addClickEventListener(handler(self, self.Click_Share))
    self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Quit))

	local layer = TotalItemLayer.new(gameid)
	self.list:setItemModel(layer.panel)
	local nMaxScore = -1
    local nMaxWin = 0
    for _,info in ipairs(tInfo.infos) do
        if info.total_count > nMaxScore then
			nMaxWin = info.seat
            nMaxScore = info.total_count
		end
    end
    local niu_infos = get_niu_info(tInfo)
    for _, info in ipairs(tInfo.infos) do
    	self.list:pushBackDefaultItem()
    end 
    local items_count = table.getn(self.list:getItems())
    for i = 1,items_count do
        local item = self.list:getItem(i-1)
        local Name = item:getChildByName("IMG_NAME_BG"):getChildByName("Name")
        local ID = item:getChildByName("IMG_ID_BG"):getChildByName("ID")
        local TEXT_NN = item:getChildByName("TEXT_NN")
        local TEXT_N9 = item:getChildByName("TEXT_N9")
        local TEXT_N8 = item:getChildByName("TEXT_N8")
        local TEXT_N7 = item:getChildByName("TEXT_N7")
        local TEXT_N1_6 = item:getChildByName("TEXT_N1_6")
        local TEXT_N0 = item:getChildByName("TEXT_N0")
        local TEXT_ALL_SCORE = item:getChildByName("TEXT_ALL_SCORE")
        local IMG_MAX_WIN = item:getChildByName("IMG_MAX_WIN")
        local IMG_HEAD = item:getChildByName("IMG_HEAD")
        local TEXT_CONCLUDE = item:getChildByName("TEXT_CONCLUDE")
        --local IMG_FANGZHU   = item:getChildByName("IMG_FANGZHU")
        --IMG_FANGZHU:setVisible(false)

        IMG_MAX_WIN:setVisible(false)

        local info = tInfo.infos[i]
		local seat = info.seat
        local playerInfo = G_GamePlayer:getPlayerBySeverSeat(seat)
		
        --ID
		ID:setString("ID:"..playerInfo.userid)
		-- Name
		local szNickName = playerInfo.nickname
        local len = string.len(szNickName)
        if len>12 then 
            szNickName = string.sub(szNickName,1,12).."..."
        end
		Name:setString(szNickName)

		--[[
		if playerInfo.userid == master_id then 
			IMG_FANGZHU:setVisible(true)
		end
		]]

		local niu_info = niu_infos[i]
		TEXT_NN:setString(niu_info.nNiuNiuCount)
		TEXT_N9:setString(niu_info.nNiuJiuCount)
		TEXT_N8:setString(niu_info.nNiuBaCount)
		TEXT_N7:setString(niu_info.nNiuQiCount)
		TEXT_N1_6:setString(niu_info.nNiuLiuCount)
		TEXT_N0:setString(niu_info.nWuNiuCount)
		TEXT_ALL_SCORE:setString(info.total_count)
		local include = 0 
		if info.total_count-self.base_score>0 then 
			include = "+"..(info.total_count-self.base_score)
		elseif info.total_count-self.base_score==0 then 
		
		else 
			include = (info.total_count-self.base_score)
		end 
		TEXT_CONCLUDE:setString(include)

		if nMaxWin == seat then 
			IMG_MAX_WIN:setVisible(true)
		end
		
		local nSeat = G_GamePlayer:getLocalSeat(seat)
        if playerInfo ~= nil then
            local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead"..playerInfo.userid..".png"
            local f = cc.FileUtils:getInstance():isFileExist(saveName) 
            if f == true then
            	dump("isFileExist") 
            	local nHeadSize = 55
		    	if IMG_HEAD ~= nil then
		        	IMG_HEAD:loadTexture(saveName)
		        	local width = IMG_HEAD:getContentSize().width
		        	local height = IMG_HEAD:getContentSize().height
		        	IMG_HEAD:setScale(nHeadSize/width, nHeadSize/height)
		    	end
            end 
        end
    end

    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    local fileName = "dgnn_result.png"
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..fileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
    	cc.FileUtils:getInstance():removeFile(ImageFile)
    end
end

function M:onEnter()
	local action = cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
	local fileName = "dgnn_result.png"
    	G_CommonFunc:captureScreen(self.root,fileName)
    end))
    self:runAction(action) 
end

-- 点击分享
function M:Click_Share()
	G_CommonFunc:addClickSound()
    local fileName = "dgnn_result.png"
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..fileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡地锅子，来战啊！", ImageFile, "")
    else 
        self.scehdule = scheduler:scheduleScriptFunc(handler(self,self.checkIsFileExist),0.1,false)
    end
end

function M:checkIsFileExist()
	local fileName = "dgnn_result.png"
    local ImageFile = cc.FileUtils:getInstance():getWritablePath()..fileName
    if cc.FileUtils:getInstance():isFileExist(ImageFile) then
        ef.extensFunction:getInstance():wxshareResult(0, "好友@你", "宁乡地锅子，来战啊！", ImageFile, "")
        if self.scehdule then
			scheduler:unscheduleScriptEntry(self.scehdule)
			self.scehdule = nil
		end
    end 
end

-- 点击退出
function M:Click_Quit()
	G_CommonFunc:addClickSound()
	G_Data.roomid = 0
	G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
	G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end

-- 退出场景
function M:onExit()
    if self.scehdule then
        scheduler:unscheduleScriptEntry(self.scehdule)
        self.scehdule = nil
    end
end

return M
