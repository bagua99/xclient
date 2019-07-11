
local ShowMapLayer      = require("app.component.ShowMapLayer")
local targetPlatform    = cc.Application:getInstance():getTargetPlatform()

local M = class("LocationMapLayer", function()
	return display.newLayer()
end)

function M:ctor(player)
	local node = cc.CSLoader:createNode("Component/ShowMap/LocationMapLayer.csb");
    node:addTo(self)
    self.root = node

    self:initView(player)
end

function M:setLocation(nLocation, player)
    local head = self.Node_Head:getChildByName("Node_Head_"..nLocation)
    local szNickName = player.nickname
    local len = string.len(szNickName)
    if len>12 then 
        szNickName = string.sub(szNickName,1,12).."..."
    end
    head:getChildByName("NameText_"..nLocation):setString(szNickName)
    head:setVisible(true)
    --计算自己和该玩家之间的距离
    local me = G_GamePlayer:getMainPlayer()
    if me.userid == player.userid then 
        return
    end 

    local player = player 
    local longitude1 = me.longitude or 0  
    local latitude1  = me.latitude or 0 
    local longitude2 = player.longitude or 0 
    local latitude2  = player.latitude or 0 

    local getDistanceFinish = function(params)
        local d = math.floor(tonumber(params))
        local fmt = '%.' .. 1 .. 'f'
        local nRet = tonumber(string.format(fmt,d))
        local distance = string.format("相距约%d米",d)
        head:getChildByName("Text_Location"):setString(distance)
        player.distance = distance
    end
    
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {longitude1,latitude1,longitude2,latitude2,getDistanceFinish}
        local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/hnqp/pdkgame/AppActivity"
        local ok,ret = luaj.callStaticMethod(className,"getDistance",args,sigs)
        if not ok then

        else 
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform ) then 
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "RootViewController"
        luaoc.callStaticMethod(className,"getDistance", {longitude11 = longitude1,latitude11=latitude1,longitude21=longitude2,latitude21=latitude2,getDistanceFinish = getDistanceFinish } ) 
    end
end

function M:initView(player)
	self.BG = self.root:getChildByName("BG")
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,100))
    self.BG:addChild(curColorLayer)

    self.BTN_COMMIT = self.root:getChildByName("BTN_COMMIT")
    self.BTN_COMMIT:addClickEventListener(handler(self,self.click_commit))

    self.Node_Head = self.root:getChildByName("Node_Head")
    for i = 2,5 do 
        local head = self.Node_Head:getChildByName("Node_Head_"..i)
        head:setVisible(false)
    end 
    self.NameText_1 = self.Node_Head:getChildByName("Node_Head_1"):getChildByName("NameText_1")
    local szNickName = player.nickname
    local len = string.len(szNickName)
    if len>12 then 
        szNickName = string.sub(szNickName,1,12).."..."
    end
    self.NameText_1:setString(szNickName)
end

function M:click_commit()
    G_CommonFunc:addClickSound()
    local showMapLayer = ShowMapLayer.new(player)        
    self:addChild(showMapLayer)
    showMapLayer:add_clickContinue(function()
        showMapLayer:removeFromParent()
        self:setVisible(false)
    end)
end

return M
