local EventConfig       = require ("app.config.EventConfig")
local targetPlatform    = cc.Application:getInstance():getTargetPlatform()

local M = class("ShowMapLayer", function()
	return display.newLayer()
end)

function M:ctor()
	local node = cc.CSLoader:createNode("Component/ShowMap/ShowMapLayer.csb");
    node:addTo(self)
    self.root = node

    self:initView()
end

function M:initView()
	self.BG = self.root:getChildByName("BG")
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,100))
    self.BG:addChild(curColorLayer)

    self.BTN_ENDGAME = self.root:getChildByName("BTN_ENDGAME")
    self.BTN_CONTINUE = self.root:getChildByName("BTN_CONTINUE")
    self.BTN_ENDGAME:addClickEventListener(handler(self,self.click_endgame))

    --显示各个的距离
    self.list = self.root:getChildByName("ListView")
    local node = cc.CSLoader:createNode("Component/ShowMap/LocationItemLayer.csb")
    local panel = node:getChildByName("Panel")
    self.list:setItemModel(panel)

    local count = G_GamePlayer:getPlayerCount()
    for i = 1, count do 
        self.list:pushBackDefaultItem()
    end
    local items_count = table.getn(self.list:getItems())
    local index = 0 
    local me = G_GamePlayer:getMainPlayer()
    for k, player in pairs(G_GamePlayer.players) do 
        --if me.userid == player.userid then 
        --    return 
        --end
        local item = self.list:getItem(index)
        local Text_NAME = item:getChildByName("Text_NAME")
        local Text_ID = item:getChildByName("Text_ID")
        local Text_ADDS = item:getChildByName("Text_ADDS")
        local szNickName = player.nickname
        local len = string.len(szNickName)
        if len>12 then 
            szNickName = string.sub(szNickName,1,12).."..."
        end
        Text_NAME:setString(szNickName)
        Text_ID:setString("ID:"..player.userid)
        local adds = player.adds or ""
        if player.distance then 
            Text_ADDS:setString(adds.."("..player.distance..")")
        else 
            Text_ADDS:setString(adds)
        end
        index = index + 1
    end
end

function M:click_endgame()
    G_CommonFunc:addClickSound()
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameLBSVoteReq", {})
end

function M:add_clickContinue(call)
    G_CommonFunc:addClickSound()
    self.BTN_CONTINUE:addClickEventListener(call)
end

return M
