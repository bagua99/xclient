
local M = class("ZhanJiLayer",G_BaseLayer)

M.RESOURCE_FILENAME = "Lobby/ZhanJi/ZhanJiLayer.csb"

local SearchLayer           = require("app.scenes.lobby.zhanji.SearchLayer")
local ZhanJiCellLayer       = require("app.scenes.lobby.zhanji.ZhanJiCellLayer")
local ZhanJiWatchCellLayer      = require("app.scenes.lobby.zhanji.ZhanJiWatchCellLayer")

local utils                 = require "utils"
local cjson 				= require("componentex.cjson")
local GameConfig            = require "app.config.GameConfig"
local ZhanJiConfig          = require "app.scenes.lobby.zhanji.ZhanJiConfig"


function M:onCreate()
    self.WatchFriendBtn         = self.resourceNode_.node["WatchFriendBtn"]
    self.CloseBtn               = self.resourceNode_.node["CloseBtn"]

    self.ButtonPanel            = self.resourceNode_.node["ButtonPanel"]
    self.RecordPanel            = self.resourceNode_.node["RecordPanel"]

    self.tButton = {}
    self.NomalButtonX = 120
    self.ChooseButtonX = 125
end

function M:initView()
    local nChooseIndex = 0
    local nIndex = 1
    for i, config in ipairs(ZhanJiConfig.Config) do
        if config.Button ~= nil then
            local PointY = 305 - (nIndex-1)*80
            local pButton = ccui.Button:create(config.Button.nomal, config.Button.nomal, "", ccui.TextureResType.plistType)
	        pButton:setPosition(cc.p(self.NomalButtonX, PointY))
            pButton:setTag(i)
            pButton:addClickEventListener(handler(self, self.Click_GameButton))
            pButton:setVisible(true)
	        self.ButtonPanel:addChild(pButton)

            table.insert(self.tButton, pButton)

            if nChooseIndex == 0 then
                nChooseIndex = nIndex
            end

            nIndex = nIndex + 1
        end
    end

    -- ��Ϸѡ��
    self:setGameChoose(nChooseIndex)
end

function M:initTouch()
	self.WatchFriendBtn:addClickEventListener(handler(self, self.Click_WatchFriend))
	self.CloseBtn:addClickEventListener(handler(self, self.Click_Close))
end

function M:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

function M:onExit()
    if self.listener then
	    self:getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end

function M:onTouchBegin(touch, event)
	return self:isVisible()
end

function M:onTouchMove(touch, event)

end

function M:onTouchEnded(touch, event)

end

-- �����Ϸ��ť
function M:Click_GameButton(sender)
    G_CommonFunc:addClickSound()
    self:setGameChoose(sender:getTag())
end

-- �����Ϸ��ť
function M:requestGame(nTag)
    local msg = {userid = G_Data.UserBaseInfo.userid, gameid = nTag}
	self:postRecordRoomList(GameConfig.get_record_room_list, msg)
end

-- ������Ϸѡ��
function M:setGameChoose(nChooseID,isunClick)
    local Config = ZhanJiConfig.Config[nChooseID]
    if Config == nil then
        return
    end

    if self.nChooseID == nChooseID then
        return
    end
    self.nChooseID = nChooseID

    for nIndex, pButton in ipairs(self.tButton) do
        local nTag = pButton:getTag()
        local PointY = 305 - (nIndex-1)*80
        local TagConfig = ZhanJiConfig.Config[nTag]
        if self.nChooseID ~= nTag then
            pButton:setPosition(cc.p(self.NomalButtonX, PointY))
            pButton:loadTextures(TagConfig.Button.nomal, TagConfig.Button.nomal, "", ccui.TextureResType.plistType)
        else
            pButton:setPosition(cc.p(self.ChooseButtonX, PointY))
            pButton:loadTextures(TagConfig.Button.choose, TagConfig.Button.choose, "", ccui.TextureResType.plistType)
        end
        pButton:setVisible(true)
    end
    if isunClick then 
        --����click�Ͳ�������
    else 
        self:requestGame(nChooseID)
    end
end

function M:Click_WatchFriend()
    G_CommonFunc:addClickSound()
    if self.SearchLayer == nil then
	    self.SearchLayer = SearchLayer:create()
	    self:addChild(self.SearchLayer)
        self.SearchLayer:addCloseListener(function()
            self.SearchLayer:removeFromParent()
            self.SearchLayer = nil 
        end)
    end
end

-- ����ر�
function M:Click_Close()
    G_CommonFunc:addClickSound()
	self:setVisible(false)
    -- �رջص�
    if self.call then
        self.call()
    end
end

-- �رջص�
function M:addCloseListener(call)
    self.call = call
end

function M:postRecordRoomList(url, msg)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr.timeout = 4
	xhr:open("POST", url)
	local function reqCallback()
        if xhr.status == 200 then
		    local retMsg = cjson.decode(utils.base64decode(xhr.response))
            self:showRecordRoomList(retMsg)
        end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(reqCallback)
	xhr:send(utils.base64encode(cjson.encode(msg)))
end

function M:showRecordRoomList(msg)
    self.tImageView = {}

    if self.pRecordRoomListView then
        self.pRecordRoomListView:removeFromParent()
        self.pRecordRoomListView = nil
    end

    if self.pRecordListView ~= nil then
        self.pRecordListView:removeFromParent()
        self.pRecordListView = nil
    end

    self.pRecordRoomListView = ccui.ListView:create()
	self.pRecordRoomListView:setAnchorPoint(cc.p(0.5,0.5))
	self.pRecordRoomListView:setDirection(ccui.ScrollViewDir.vertical)
    self.pRecordRoomListView:setTouchEnabled(true)
    self.pRecordRoomListView:setBounceEnabled(true)
    self.pRecordRoomListView:setContentSize(cc.size(700, 360))
    self.pRecordRoomListView:setPosition(cc.p(351, 164))
    self.pRecordRoomListView:setItemsMargin(5)
    self.pRecordRoomListView:setVisible(true)
    self.RecordPanel:addChild(self.pRecordRoomListView)

    for i, info in ipairs(msg) do
        local pImageView = ccui.ImageView:create("ZhanJi_FirstDi.png", ccui.TextureResType.plistType)
    	pImageView:setName("listView")
    	pImageView:setTouchEnabled(true)
    	pImageView:addClickEventListener(handler(self, self.Click_ImageView))
    	pImageView:setTag(info.head.room_id)
        pImageView:setVisible(true)
    	self.pRecordRoomListView:addChild(pImageView)

        self.tImageView[i] = pImageView

    	local curLayer = ZhanJiCellLayer.new(info)
    	self.tImageView[i]:addChild(curLayer)
    end
end

function M:Click_ImageView(sender)
    G_CommonFunc:addClickSound()
    local msg = {userid = G_Data.UserBaseInfo.userid, roomid = sender:getTag()}
	self:postRecordList(GameConfig.get_record_list, msg)
end

function M:postRecordList(url, msg)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr.timeout = 4
	xhr:open("POST", url)
	local function reqCallback()
        if xhr.status == 200 then
		    local retMsg = cjson.decode(utils.base64decode(xhr.response))
            self:showRecordList(retMsg)
        end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(reqCallback)
	xhr:send(utils.base64encode(cjson.encode(msg)))
end

function M:showRecordList(msg)
    self.tRecordImageView = {}

    if self.pRecordRoomListView then
        self.pRecordRoomListView:removeFromParent()
        self.pRecordRoomListView = nil
    end

    if self.pRecordListView ~= nil then
        self.pRecordListView:removeFromParent()
        self.pRecordListView = nil
    end

    self.pRecordListView = ccui.ListView:create()
	self.pRecordListView:setAnchorPoint(cc.p(0.5,0.5))
	self.pRecordListView:setDirection(ccui.ScrollViewDir.vertical)
    self.pRecordListView:setTouchEnabled(true)
    self.pRecordListView:setBounceEnabled(true)
    self.pRecordListView:setContentSize(cc.size(700, 360))
    self.pRecordListView:setPosition(cc.p(351, 164))
    self.pRecordListView:setItemsMargin(5)
    self.pRecordListView:setVisible(true)
    self.RecordPanel:addChild(self.pRecordListView)

    for i, info in ipairs(msg) do
        local pImageView = ccui.ImageView:create("ZhanJi_FirstDi.png", ccui.TextureResType.plistType)
    	pImageView:setName("listView")
        pImageView:setVisible(true)
    	self.pRecordListView:addChild(pImageView)

        self.tRecordImageView[i] = pImageView

    	local curLayer = ZhanJiWatchCellLayer.new(info, i)
    	self.tRecordImageView[i]:addChild(curLayer)
    end
end

return M
