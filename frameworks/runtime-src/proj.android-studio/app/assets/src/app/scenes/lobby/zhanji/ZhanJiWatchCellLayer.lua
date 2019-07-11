
local ZhanJiWatchCellLayer = class("ZhanJiWatchCellLayer", G_BaseLayer)

function ZhanJiWatchCellLayer:ctor(pdata,inum)

	self.m_iGameId = pdata.gameid
	local pTextNum = ccui.Text:create(inum,"Arial",24)
	pTextNum:setPosition(cc.p(87, 25))
	pTextNum:setColor(cc.c3b(149,95,80))
	self:addChild(pTextNum)

	for i=1,4 do
		if string.len(pdata.ReplayWinLose[i].nickname) ~= 0 then
			local username = mime.unb64(pdata.ReplayWinLose[i].nickname)
			local pScoreName = ccui.Text:create(pdata.ReplayWinLose[i].deltascore,"Arial",24)
			pScoreName:setPosition(cc.p(392+(i-1)*140, 25))
			pScoreName:setColor(cc.c3b(149,95,80))
			self:addChild(pScoreName)
		end
	end
	local pTextTim3 = ccui.Text:create(pdata.datetime,"Arial",24)
	pTextTim3:setPosition(cc.p(224, 25))
	pTextTim3:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	pTextTim3:setColor(cc.c3b(149,95,80))
	self:addChild(pTextTim3)
end

function ZhanJiWatchCellLayer:doShare(sender)
	local strInfo = string.format("玩家[%s]分享一个回放码：%d，在大厅内点击战绩进入战绩页面，然后点击查看回放按钮，输入回放码点击确定后即可查看", G_Data.UserBaseInfo.nickname, self.m_iGameId)
	ef.extensFunction:getInstance():wxshareZhanJi(0, strInfo);
end

function ZhanJiWatchCellLayer:doreview( )

end

function ZhanJiWatchCellLayer:initView()

end

function ZhanJiWatchCellLayer:initTouch()

end

function ZhanJiWatchCellLayer:onEnter()

end

function ZhanJiWatchCellLayer:onExit()

end

return ZhanJiWatchCellLayer
