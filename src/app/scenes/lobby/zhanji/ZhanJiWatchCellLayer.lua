
local M = class("ZhanJiWatchCellLayer", G_BaseLayer)

local utils 		= require "utils"
local cjson 		= require("componentex.cjson")
local GameConfig 	= require "app.config.GameConfig"

function M:ctor(info, num)
	self.id = info.id

	local pTextNum = ccui.Text:create(num, "res/commonfont/ZYUANSJ.TTF", 24)
	pTextNum:setPosition(cc.p(20, 43))
	self:addChild(pTextNum)

    local t = os.date("*t", info.head.start_time)
    local strTime = t.month.."-"..t.day.." "..t.hour..":"..t.min
	local pTextTime = ccui.Text:create(strTime, "res/commonfont/ZYUANSJ.TTF", 24)
	pTextTime:setPosition(cc.p(110, 43))
	pTextTime:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self:addChild(pTextTime)

	for i, p in ipairs(info.players) do
		if string.len(p.nickname) ~= 0 then
			local pScoreName = ccui.Text:create(p.score, "res/commonfont/ZYUANSJ.TTF", 24)
			pScoreName:setPosition(cc.p(210+(i-1)*100, 43))
			self:addChild(pScoreName)
		end
	end

    local pButtonFX = ccui.Button:create("ZhanJi_FenXiang.png", "ZhanJi_FenXiang.png", "", ccui.TextureResType.plistType)
	pButtonFX:setPosition(cc.p(510, 43))
    pButtonFX:addClickEventListener(handler(self, self.Click_Share))
	self:addChild(pButtonFX)

    local pButtonWatch = ccui.Button:create("ZhanJi_Watch.png", "ZhanJi_Watch.png", "", ccui.TextureResType.plistType)
	pButtonWatch:setPosition(cc.p(620, 43))
    pButtonWatch:addClickEventListener(handler(self, self.Click_Watch))
	self:addChild(pButtonWatch)
end

function M:Click_Share(sender)
	G_CommonFunc:addClickSound()
	local strInfo = string.format("玩家[%s]分享一个回放码：%d，在大厅内点击战绩进入战绩页面，然后点击查看回放按钮，输入回放码点击确定后即可查看", G_Data.UserBaseInfo.nickname, self.id)
	ef.extensFunction:getInstance():wxshareZhanJi(0, strInfo)
end

function M:Click_Watch(sender)
	G_CommonFunc:addClickSound()
	local msg = {id = self.id}
	self:postRecordList(GameConfig.get_record_game, msg)
end

function M:postRecordList(url, msg)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr.timeout = 4
	xhr:open("POST", url)
	local function reqCallback()
        if xhr.status == 200 then
		    local retMsg = cjson.decode(utils.base64decode(xhr.response))
            self:showRecordGame(retMsg)
        end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(reqCallback)
	xhr:send(utils.base64encode(cjson.encode(msg)))
end

function M:showRecordGame(msg)
    G_Data.bReplay = true
    G_Data.bReplayPause = false
    G_Data.gameid = msg.head.game_id
    G_Data.ReplayData = msg

    if G_GameDeskManager ~= nil then
	    G_GameDeskManager:initGame()
    end
end

return M
