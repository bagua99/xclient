
local utils             = require "utils"

local M = class("LotteryLayer",function()
	return display.newLayer()
end)

function M:ctor()
	local node = cc.CSLoader:createNode("Lobby/Lottery/LotteryLayer.csb");
	node:addTo(self)
	self.root = node

	self:initView()
end

function M:initView()
	self.BG = self.root:getChildByName("BG")
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    self.panel      = self.root:getChildByName("Panel")
    self.BTN_CLOSE  = self.panel:getChildByName("BTN_CLOSE")
    for i = 1, 9 do 
		local btn = self.panel:getChildByName("BTN_A"..i)
		btn.index = i  
		btn:addClickEventListener(handler(self, self.Click_Choose))	 		
 		local IMG_C = btn:getChildByName("IMG_C")
 		IMG_C:setVisible(false)	   	
 		local IMG_S = btn:getChildByName("IMG_S")
 		IMG_S:setVisible(false)	   	
    end
end

function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:removeFromParent()
end

function M:Click_Choose(e)
	G_CommonFunc:addClickSound()
	local index = e.index
	local msg = {
		userid = G_Data.UserBaseInfo.userid,
		sign = G_Data.UserBaseInfo.sign,
	}
	G_CommonFunc:httpForJsonLobby("/lottery_draw",5,msg,handler(self, self.LotteryResult),nil)
	self.c_index = index
end

function M:addCloseListener(call)
	self.BTN_CLOSE:addClickEventListener(call)
end

function M:LotteryResult(msg)
    if not msg or not msg.card or not msg.show_tbl then
        return
    end

	if msg.total_roomcard then 
		G_Event:dispatchEvent({name="UpdateCardForLottery", roomcard=msg.total_roomcard})
	end

    -- 移除抽中的
    for k, v in ipairs(msg.show_tbl) do
        if v == msg.card then
            table.remove(msg.show_tbl, k)
            break
        end
    end
	--随机打乱排序
	utils.rand_table(msg.show_tbl)

	self:showOpenAni(self.c_index, msg.card, msg.show_tbl)

	local str = "恭喜您抽到"..msg.card.."张卡"
	self:tips(str)

end

 function M:showOpenAni(index, card, show_tbl)
 	for i = 1, 9 do 
 		local BTN_A = self.panel:getChildByName("BTN_A"..i)
 		local Text_1 = BTN_A:getChildByName("Text_1")
 		local color = cc.c4b(255,255,255,255)
 		Text_1:setTextColor(color)
 		Text_1:setPositionY(Text_1:getPositionY()-62)
 		local IMG = BTN_A:getChildByName("IMG")
 		IMG:setVisible(false)

 		if i == index then 
 			local IMG_C = BTN_A:getChildByName("IMG_C")
 			IMG_C:setVisible(true)	
 			Text_1:setString(card.."张")   	
 		else
            local nShowCard = show_tbl[1]
            table.remove(show_tbl, 1)
 			local IMG_S = BTN_A:getChildByName("IMG_S")
 			IMG_S:setVisible(true)
 			Text_1:setString(nShowCard.."张")	   	
 		end
 		BTN_A:setTouchEnabled(false)
 	end
 end

 -- 提示信息
function M:tips(str)
    local curLayer = G_WarnLayer.create()
    curLayer:setTips(str)
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

return M