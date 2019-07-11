
local M = class("ZhanJiLayercell", G_BaseLayer)

function M:ctor(info)
	local pText = ccui.Text:create(string.format("房间号:%d", info.head.room_id), "res/commonfont/ZYUANSJ.TTF", 20)
    pText:setContentSize(cc.size(200,20))
    pText:setPosition(cc.p(80, 60))
	pText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	pText:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self:addChild(pText)

    local t = os.date("*t", info.head.start_time)
    local strTime = "对战时间:"..t.year.."-"..t.month.."-"..t.day.." "..t.hour..":"..t.min..":"..t.sec
	local pTextTime = ccui.Text:create(strTime, "res/commonfont/ZYUANSJ.TTF", 20)
    pTextTime:setContentSize(cc.size(200,20))
	pTextTime:setPosition(cc.p(280, 60))
	pTextTime:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    pTextTime:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self:addChild(pTextTime)

	for i, p in ipairs(info.players) do
		if string.len(p.nickname) ~= 0 then
			local pScoreName = ccui.Text:create(string.format("%s:%d", p.nickname, p.total_score), "res/commonfont/ZYUANSJ.TTF", 20)
			pScoreName:setContentSize(cc.size(200,20))
            pScoreName:setPosition(cc.p(75+(i-1)*200, 30))
			pScoreName:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			pScoreName:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			self:addChild(pScoreName)
		end
	end
end

return M
