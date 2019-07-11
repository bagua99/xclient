
local MainLayer = class("MainLayer",G_BaseLayer)

MainLayer.RESOURCE_FILENAME = "MainLayer.csb"

local GameSetLayer      = require("app.scenes.lobby.common.GameSetLayer")
local GameHelpLayer     = require("app.scenes.lobby.common.GameHelpLayer")
local CreateRoomLayer   = require("app.scenes.lobby.CreateRoomLayer")
local ShareLayer        = require("app.scenes.lobby.ShareLayer")
local MailLayer         = require("app.scenes.lobby.MailLayer")
local ZhanJiLayer       = require("app.scenes.lobby.zhanji.ZhanJiLayer")

function MainLayer:onCreate()

    -- 创建房间
    self.CreateRoomBtn  = self.resourceNode_.node["CreateRoomBtn"]
    -- 加入房间
    self.JoinRoomBtn    = self.resourceNode_.node["JoinRoomBtn"]
    -- 购买房卡
	self.BuyBtn         = self.resourceNode_.node["BuyBtn"]
	-- 实名认证
    self.CertificationBtn         = self.resourceNode_.node["CertificationBtn"]

    -- 战绩回顾
    self.LookBackBtn    = self.resourceNode_.node["BgImage"].node["LookBackBtn"]
    -- 好友分享
    self.ShareBtn       = self.resourceNode_.node["BgImage"].node["ShareBtn"]
    -- 问题回顾
    self.FeedbackBtn    = self.resourceNode_.node["BgImage"].node["FeedbackBtn"]
    -- 更多游戏
    self.MoreGameBtn    = self.resourceNode_.node["BgImage"].node["MoreGameBtn"]

    -- 喇叭文字
    self.LaBaView       = self.resourceNode_.node["LaBaBg"].node["Panel_View"]

    -- 头像图片
    self.HeadSprite     = self.resourceNode_.node["LogoCenter"].node["HeadSpriteBg"].node["HeadSprite"]
    -- 玩家名字
    self.UserNameText   = self.resourceNode_.node["LogoCenter"].node["UserNameText"]
    -- 玩家ID
    self.UserIDText     = self.resourceNode_.node["LogoCenter"].node["UserIDText"]
    -- 房卡数量
    self.RoomCardText   = self.resourceNode_.node["LogoCenter"].node["RoomCardBg"].node["RoomCardText"]
    -- 购买房卡
    self.RoomCardBuyBtn = self.resourceNode_.node["LogoCenter"].node["RoomCardBuyBtn"]
    -- 消息
    self.MailBtn        = self.resourceNode_.node["LogoCenter"].node["MailBtn"]
    -- 帮助
    self.HelpBtn        = self.resourceNode_.node["LogoCenter"].node["HelpBtn"]
    -- 游戏设置
    self.GameSetBtn     = self.resourceNode_.node["LogoCenter"].node["GameSetBtn"]

    -- 创建房间层
    self.CreateRoomLayer = nil

    if EVENT_GETUSERHEAD then
		self:getUserHead()
	end
end

function MainLayer:initView()

    self.CreateRoomBtn:setVisible(true)
    self.JoinRoomBtn:setVisible(true)
    self.BuyBtn:setVisible(true)
    self.CertificationBtn:setVisible(true)

    self.ShareBtn:setVisible(true)
    self.LookBackBtn:setVisible(true)
    self.FeedbackBtn:setVisible(true)
    self.MoreGameBtn:setVisible(true)

    self.LaBaView:setVisible(true)

	self.UserNameText:setString(G_Data.UserBaseInfo.nickname)
    self.UserNameText:setVisible(true)
	self.UserIDText:setString(string.format("账号:%06d", G_Data.UserBaseInfo.userid))
    self.UserIDText:setVisible(true)
	self.RoomCardText:setString(G_Data.UserBaseInfo.roomcard)
    self.RoomCardText:setVisible(true)
    self.RoomCardBuyBtn:setVisible(true)
    self.MailBtn:setVisible(true)
    self.HelpBtn:setVisible(true)
    self.GameSetBtn:setVisible(true)
end

function MainLayer:initTouch()

    -- 创建房间
	self.CreateRoomBtn:addClickEventListener(handler(self,self.Click_CreateRoom))
	-- 加入房间
	self.JoinRoomBtn:addClickEventListener(handler(self,self.Click_JoinRoom))
    -- 购买房卡
	self.BuyBtn:addClickEventListener(handler(self,self.Click_Buy))
	-- 实名认证
	self.CertificationBtn:addClickEventListener(handler(self,self.Click_Certification))

    -- 战绩回顾
	self.LookBackBtn:addClickEventListener(handler(self,self.Click_LookBack))
    -- 好友分享
	self.ShareBtn:addClickEventListener(handler(self,self.Click_Share))
    -- 问题回顾
	self.FeedbackBtn:addClickEventListener(handler(self,self.Click_Feedback))
    -- 更多游戏
	self.MoreGameBtn:addClickEventListener(handler(self,self.Click_MoreGame))
	
    -- 购买房卡
	self.RoomCardBuyBtn:addClickEventListener(handler(self,self.Click_Buy))
	-- 消息
	self.MailBtn:addClickEventListener(handler(self,self.Click_Mail))
	-- 帮助
	self.HelpBtn:addClickEventListener(handler(self,self.Click_Help))
	-- 游戏设置
	self.GameSetBtn:addClickEventListener(handler(self,self.Click_GameSet))
end

-- 创建房间
function MainLayer:Click_CreateRoom()

    if self.CreateRoomLayer == nil then
	    self.CreateRoomLayer = CreateRoomLayer:create()
        self.CreateRoomLayer:setVisible(true)
	    self:addChild(self.CreateRoomLayer)
    else
        -- 设置房间信息
        self.CreateRoomLayer:setRoomInfo(self.CreateRoomLayer.nChooseID)
        self.CreateRoomLayer:setVisible(true)
    end
end

-- 加入房间
function MainLayer:Click_JoinRoom()

	G_Event:dispatchEvent({name="showJoinRoom"})
end

-- 购买房卡
function MainLayer:Click_Buy()

	local curLayer = G_WarnLayer.create()
    curLayer:setTips("公众号：888888.\n客服微信号：888888.")
    curLayer:setTypes(1)
    self:addChild(curLayer)
end

-- 实名认证
function MainLayer:Click_Certification()

end

-- 战绩回顾
function MainLayer:Click_LookBack()

	local curlayer = ZhanJiLayer:create(1)
	self:addChild(curlayer)
end

-- 好友分享
function MainLayer:Click_Share()

	local curlayer = ShareLayer:create(1)
	self:addChild(curlayer)
end

-- 问题反馈
function MainLayer:Click_Feedback()

end

-- 更多游戏
function MainLayer:Click_MoreGame()

end

-- 消息
function MainLayer:Click_Mail()

	local curlayer = MailLayer:create(1)
	self:addChild(curlayer)
end

-- 帮助
function MainLayer:Click_Help()

	local curlayer = GameHelpLayer:create(1)
	self:addChild(curlayer)
end

-- 游戏设置
function MainLayer:Click_GameSet()

	local curlayer = GameSetLayer:create(1)
	self:addChild(curlayer)
end

-- 玩家头像
function MainLayer:getUserHead()

	self.HeadSprite:setTexture(G_HeadImg)
	self.HeadSprite:setScale(33/self.HeadSprite:getBoundingBox().width,33/self.HeadSprite:getBoundingBox().height)
end

-- 进入场景
function MainLayer:onEnter()

	self.msg_uheadListener = G_CommonFunc:addEvent(CUSTOMMSG_USERHEAD,handler(self,self.getUserHead))    
end

-- 退出场景
function MainLayer:onExit()

	G_CommonFunc:removeEvent(self.msg_uheadListener)
end

return MainLayer
