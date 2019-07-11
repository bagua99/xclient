local M = class("SuccessLayer",function()
	return display.newLayer()
end)

M.panel = nil 
M.root  = nil
M.BTN_CLOSE = nil  
M.BTN_CONTINUE = nil 
M.ListView = nil 
M.BG = nil 

local bit = require("bit")
local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local logic                     = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".logic.logic")
local ResultItemLayer           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".game.ResultItemLayer")

local EventConfig               = require ("app.config.EventConfig")

function M:ctor(gameid,tInfo,isTotalConclude,isBanker,bankerId,isXiazhuang,isShangZhuang)
	local node = cc.CSLoader:createNode("res/"..gameid.."/SuccessEndLayer.csb");
	node:addTo(self)
	self.root = node 
	self:initView(gameid,tInfo,isTotalConclude,isBanker,bankerId,isXiazhuang,isShangZhuang)
end

function M:initView(gameid,tInfo,isTotalConclude,isBanker,bankerId,isXiazhuang,isShangZhuang)
	self.panel = self.root:getChildByName("Panel")
	self.BTN_CLOSE = self.root:getChildByName("BTN_CLOSE")
	self.BTN_CONTINUE = self.root:getChildByName("BTN_CONTINUE")
	self.Btn_goBanker = self.root:getChildByName("BTN_GOONBANKER")
    self.Btn_outBanker = self.root:getChildByName("BTN_XIAZHUANG")
    self.TIPS_TEXT = self.root:getChildByName("TIPS_TEXT")
    self.TIPS_TEXT:setVisible(false)
    self.Btn_goBanker:setVisible(false)
    self.Btn_outBanker:setVisible(false)
	self.BG = self.root:getChildByName("BG")

	self.BTN_CONTINUE:addClickEventListener(handler(self,self.Click_Continue))
    self.BTN_CLOSE:addClickEventListener(handler(self,self.Click_Close))
    self.Btn_goBanker:addClickEventListener(handler(self,self.goBanker))
    self.Btn_outBanker:addClickEventListener(handler(self,self.outBanker))

	self.list = self.root:getChildByName("ListView")

	local size = table.getn(tInfo.infos)
	local bank_count = tInfo.bank_count 
    if bank_count>=3 and isBanker then 
        self.Btn_goBanker:setVisible(true)
        self.Btn_outBanker:setVisible(true)
        self.BTN_CONTINUE:setVisible(false)
    end 
    self.bToOver = isTotalConclude 
    local tCardType = 
    {
        "无牛",
        "牛一",
        "牛二",
        "牛三",
        "牛四",
        "牛五",
        "牛六",
        "牛七",
        "牛八",
        "牛九",
        "牛牛",
        "牛牛",
        "牛牛",
    }
	local nServerSeat = G_GamePlayer:getServerSeat(1)
    local mainPlayer = G_GamePlayer:getMainPlayer()

    local layer = ResultItemLayer.new(gameid)
	self.list:setItemModel(layer.panel)
	for i=1,size do
		self.list:pushBackDefaultItem()
	end
	local items_count = table.getn(self.list:getItems())
    for i = 1,items_count do
        local item = self.list:getItem(i-1)
        --**设置图片**
        local Name = item:getChildByName("Name")
        local Yazhu = item:getChildByName("Yazhu")
        local TypeText = item:getChildByName("TypeText")
        local Score = item:getChildByName("Score")
        local IMG_ZHUANG = item:getChildByName("IMG_ZHUANG")
        IMG_ZHUANG:setVisible(false)
        local info = tInfo.infos[i]

        if info.stake and info.stake>0 then 
            Yazhu:setString(info.stake)
        else 
            Yazhu:setString("")
        end 


        local playerInfo = G_GamePlayer:getPlayerBySeverSeat(info.seat)
        local szNickName = playerInfo.nickname
        local len = string.len(szNickName)
        if len>12 then 
            szNickName = string.sub(szNickName,1,12).."..."
        end
        Name:setString(szNickName)
        TypeText:setString(tCardType[info.type+1])
        Score:setString(info.score)

        local hasNN = logic.getOxCard(info.cards)

        for j=1, 5 do
        	local cards = item:getChildByName("Card"..j)
            local byCard = info.cards[j]
            local szFileName = ""
            local nColor = bit.rshift(byCard, 4)
            local nNum = bit.band(byCard, 0x0F)
            if nNum ~= 0 then
                szFileName = nColor.."_"..nNum..".png"
	            cards:loadTexture(szFileName, ccui.TextureResType.plistType)
            end
            if hasNN and (j==4 or j==5 )  then
                local x = cards:getPositionX() 
                cards:setPositionX(x+20)                
            end 
        end

        if info.seat == bankerId then 
            IMG_ZHUANG:setVisible(true)
        end
    end

    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    local bank_count = tInfo.bank_count --已经当庄次数
    local bank_score = tInfo.bank_score --奖池分数
    if bank_count>=15 or bank_score <=0 then 
        if isShangZhuang == true then 
            --显示开始游戏
            self.BTN_CONTINUE:loadTexture("nn_startBanker_.png", ccui.TextureResType.plistType)
            self.BTN_CONTINUE:setVisible(true)
        end 
        if isXiazhuang == true then
            self.Btn_goBanker:setVisible(false)
            self.Btn_outBanker:setVisible(false)
            self.BTN_CONTINUE:setVisible(true)
        end 
    end

    if self.bToOver == false then 
        if bank_count>=15 then
            if isShangZhuang == true then 
                self.TIPS_TEXT:setVisible(true)  
                self.TIPS_TEXT:setString("上个庄已连续15把牌当庄，系统自动下庄，\n轮到您当庄")
            end
            if isXiazhuang == true then
                self.TIPS_TEXT:setVisible(true)  
                self.TIPS_TEXT:setString("您已连续15把牌当庄，系统自动下庄，\n下个玩家当庄")
            end  
        end
        if bank_score<=0 then 
            if isShangZhuang == true then 
                self.TIPS_TEXT:setVisible(true)  
                self.TIPS_TEXT:setString("上个庄庄底分为0，轮到您当庄")
            end
            if isXiazhuang == true then
                self.TIPS_TEXT:setVisible(true)  
                self.TIPS_TEXT:setString("您的庄底分为0，下个玩家当庄")
            end  
        end
    else 
        self.Btn_goBanker:setVisible(false)
        self.Btn_outBanker:setVisible(false)
        self.BTN_CONTINUE:setVisible(false)
    end 
end

function M:Click_Continue()
    G_CommonFunc:addClickSound()
	if self.bToOver then
		G_DeskScene:showOneOver()
	else
		G_DeskScene:Action_Restart(1)
	end
end

function M:Click_Close()
    G_CommonFunc:addClickSound()
	if self.bToOver then
		G_DeskScene:showOneOver()
	else
		G_DeskScene:Action_Restart(0)
	end
end

function M:goBanker()
    if self.bToOver then
        G_DeskScene:showOneOver()
    else
        G_DeskScene:Action_Restart(1)
    end
end

function M:outBanker()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME, "dgnn.GAME_XiaZhuang",{})
    G_DeskScene:closeConcludeLayer()
end

return M
