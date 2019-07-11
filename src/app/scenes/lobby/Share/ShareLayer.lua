
local M = class("ShareLayer", G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/Share/ShareLayer.csb"

local GameConfig = require "app.config.GameConfig"

-- 创建
function M:onCreate()
    self.HailFellowBtn = self.resourceNode_.node["HailFellowBtn"]
    self.CircleOfFriendsBtn = self.resourceNode_.node["CircleOfFriendsBtn"]
    self.BG = self.resourceNode_.node["BG"]
    self.IMG_BG = self.resourceNode_.node["IMG_BG"]
end

-- 初始视图
function M:initView()
	
end

-- 初始触摸
function M:initTouch()
	self.HailFellowBtn:addClickEventListener(handler(self, self.Click_HailFellow))
	self.CircleOfFriendsBtn:addClickEventListener(handler(self, self.Click_CircleOfFriends))
	self.BG:addClickEventListener(function()
		self:Click_Close()
	end)
end

-- 进入场景
function M:onEnter()
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,90))
    self.BG:addChild(curColorLayer)
end

-- 退出场景
function M:onExit()

end

-- 分享好友
function M:Click_HailFellow()
	G_CommonFunc:addClickSound()
	ef.extensFunction:getInstance():wxInviteFriend(0, "【宁乡棋牌】地锅子，跑得快，最地道的宁乡味。亲友约战，随时随地嗨起来。安全!便捷!稳定!", "地锅子，跑得快，最地道的宁乡味。亲友约战，随时随地嗨起来。安全!便捷!稳定!", "icon.png",GameConfig.download_url.."?u="..G_Data.UserBaseInfo.userid)
end

-- 分享朋友圈
function M:Click_CircleOfFriends()
	G_CommonFunc:addClickSound()
	ef.extensFunction:getInstance():wxInviteFriend(1, "【宁乡棋牌】地锅子，跑得快，最地道的宁乡味。亲友约战，随时随地嗨起来。安全!便捷!稳定!", "地锅子，跑得快，最地道的宁乡味。亲友约战，随时随地嗨起来。安全!便捷!稳定!", "icon.png", GameConfig.download_url.."?u="..G_Data.UserBaseInfo.userid)
end

-- 点击关闭
function M:Click_Close()
	G_CommonFunc:addClickSound()
	self:setVisible(false)
    -- 关闭回调
    if self.call then
        self.call()
    end
end

-- 关闭回调
function M:addCloseListener(call)
    self.call = call
end

return M
