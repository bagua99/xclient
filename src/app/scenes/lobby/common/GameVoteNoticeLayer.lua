
local M = class("GameVoteNoticeLayer", G_BaseLayer)

M.RESOURCE_FILENAME = "Component/GameVoteNoticeLayer.csb"

local scheduler =  cc.Director:getInstance():getScheduler()

-- 创建
function M:onCreate()
    self.ListView       = self.resourceNode_.node["PanelMain"].node["ListView"]
    self.ContentText    = self.resourceNode_.node["PanelMain"].node["ContentText"]
    self.ClockNum           = self.resourceNode_.node["PanelMain"].node["ClockBg"].node["ClockNum"]
    self.tPlayer = {}
    self.nClockTime = 299
end

-- 初始化视图
function M:initView()
    self.ClockNum:setVisible(true)
end

-- 初始化触摸
function M:initTouch()

end

-- 进入场景
function M:onEnter()

end

-- 退出场景
function M:onExit()
    if self.schedule_update ~= nil then
        scheduler:unscheduleScriptEntry(self.schedule_update)
        self.schedule_update = nil
    end
    self:setVisible(false)
end

-- 设置游戏投票信息
function M:setGameVoteAck(nDissoveSeat, voteResult)
    local nCount = #voteResult
    for i=1, nCount do
    	if self.tPlayer[i] == nil then 
    		local pText = ccui.Text:create("","res/commonfont/ZYUANSJ.TTF",20)
	        pText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	        pText:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	        pText:setAnchorPoint(cc.p(0.5, 0.5))
	        pText:setPosition(cc.p(0, 55))
	        pText:setColor(cc.c3b(255, 255, 255))
	        pText:setContentSize(cc.size(400,40))
	        pText:ignoreContentAdaptWithSize(false)
	        pText:setVisible(false)
	        self.ListView:addChild(pText)
	        self.tPlayer[i] = pText
    	end 
    end

    -- 隐藏多出的
    if #self.tPlayer > nCount then
        for i = nCount + 1, #self.tPlayer do
            self.tPlayer[i]:setVisible(false)
        end
    end

    local strChooseInfo = {"等待选择", "同意", "拒绝"}
	for nIndex, tInfo in ipairs(voteResult) do
		local _player = G_GamePlayer:getPlayerBySeverSeat(tInfo.nSeat)
		if _player ~= nil then
			if tInfo.nSeat == nDissoveSeat then
				local strInfo = string.format("玩家[%s]申请解散房间,请等待其他玩家选择(超过5分钟未选择,则默认同意!)", string.trim(_player.nickname))
				self.ContentText:setString(strInfo)
			end

            local strInfo = "玩家[".._player.nickname.."] "..strChooseInfo[tInfo.nVoteState + 1]
            self.tPlayer[nIndex]:setString(strInfo)
            self.tPlayer[nIndex]:setVisible(true)
		end
	end
end

-- 更新闹钟时间
function M:updateClockNum()
    self.nClockTime = self.nClockTime - 1
    if self.nClockTime < 0 then
        if self.EndTime ~= nil then
            self.EndTime()
        end
        self.EndTime = nil

        if self.schedule_update ~= nil then
            scheduler:unscheduleScriptEntry(self.schedule_update)
            self.schedule_update = nil
        end

        self:setVisible(false)
    end
    self.ClockNum:setString(self.nClockTime)
end

-- 设置时间
function M:setClockTime(nClockTime)
    self.nClockTime = nClockTime
    self.ClockNum:setString(self.nClockTime)
    if self.schedule_update ~= nil then
        scheduler:unscheduleScriptEntry(self.schedule_update)
        self.schedule_update = nil
    end
    self.schedule_update = scheduler:scheduleScriptFunc(handler(self, self.updateClockNum), 1, false)
end

return M
