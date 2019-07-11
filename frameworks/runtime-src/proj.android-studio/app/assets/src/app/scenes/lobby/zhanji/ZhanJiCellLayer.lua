
local ZhanJiLayercell = class("ZhanJiLayercell",G_BaseLayer)

function ZhanJiLayercell:ctor(pdata,inum)
	local pTextNum = ccui.Text:create(inum,"Arial",30)
	pTextNum:setPosition(cc.p(38, 195))
	pTextNum:setColor(cc.c3b(149,95,80))
	self:addChild(pTextNum)

	local pText = ccui.Text:create(string.format("%d号房间",pdata.tableid),"Arial",30)
	pText:setPosition(cc.p(238, 195))
	pText:setColor(cc.c3b(149,95,80))
	self:addChild(pText)
	for i=1,4 do
		if string.len(pdata.ReplayWinLose[i].nickname) ~= 0 then
			local username = mime.unb64(pdata.ReplayWinLose[i].nickname)
			local pScoreName = ccui.Text:create(string.format("%s\n\n%d",username,pdata.ReplayWinLose[i].deltascore),"Arial",30)
			pScoreName:setPosition(cc.p(132+(i-1)*248, 100))
			pScoreName:setContentSize(cc.size(200,125))
			pScoreName:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			pScoreName:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			pScoreName:setColor(cc.c3b(149,95,80))
			self:addChild(pScoreName)
		end
	end
	local pTextTim3 = ccui.Text:create(string.format("对战时间:%s",pdata.datetime),"Arial",30)
	pTextTim3:setPosition(cc.p(700, 195))
	pTextTim3:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	pTextTim3:setColor(cc.c3b(149,95,80))
	self:addChild(pTextTim3)
end

function ZhanJiLayercell:initView()

end

function ZhanJiLayercell:initTouch()

end

function ZhanJiLayercell:onEnter()

end

function ZhanJiLayercell:onExit()

end

return ZhanJiLayercell
