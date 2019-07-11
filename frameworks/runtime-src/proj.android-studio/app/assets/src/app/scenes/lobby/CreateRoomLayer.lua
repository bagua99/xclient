
local CreateRoomLayer = class("CreateRoomLayer",G_BaseLayer)

CreateRoomLayer.RESOURCE_FILENAME = "CreateRoomLayer.csb"

local roomConfig       = require("app.config.roomConfig")

local bit = require("bit")

function CreateRoomLayer:onCreate()
    
    -- 选择ID
    self.nChooseID = 0
    -- 选择信息
    self.tChoose = {}
    -- 选择标志
    self.tChooseTag = {}

    -- 描述文字
	self.DescText             = self.resourceNode_.node["NodeDesc"].node["DescText"]
    -- 选择列表
    self.NodeChoose           = self.resourceNode_.node["NodeChoose"]
    -- 创建按钮
    self.CreateRoomBtn        = self.resourceNode_.node["NodeChoose"].node["CreateRoomBtn"]
    -- 关闭按钮
    self.CloseBtn             = self.resourceNode_.node["CloseBtn"]
end

function CreateRoomLayer:initView()

    for nIndex, tInfo in ipairs(roomConfig.tGame) do

        SpriteTag = cc.Sprite:create(tInfo.tTag.Tag)
        SpriteTag:setAnchorPoint(cc.p(0.5, 0.5))
        SpriteTag:setPosition(cc.p(165, 450-(nIndex-1)*100))
        SpriteTag:setVisible(true)
        SpriteTag:setTag(nIndex)

        self.tChooseTag[nIndex] = SpriteTag

        Sprite = cc.Sprite:create(tInfo.tTag.Sprite)
        Sprite:setAnchorPoint(cc.p(0.5, 0.5))
        Sprite:setPosition(cc.p(104, 60))
        Sprite:setVisible(true)

        -- 插入标志里面
        SpriteTag:addChild(Sprite)

        self:addChild(SpriteTag)
    end

    -- 设置房间信息
    self:setRoomInfo(1)
end

function CreateRoomLayer:initTouch()

    self.CreateRoomBtn:addClickEventListener(handler(self, self.Click_Create))
	self.CloseBtn:addClickEventListener(handler(self, self.Click_Close))
end

-- 设置房间信息
function CreateRoomLayer:setRoomInfo(nChooseID)

    if nChooseID == nil then
        return
    end

    local tInfo = roomConfig.tGame[nChooseID]
    if tInfo == nil then
        return
    end

    if self.nChooseID ~= nChooseID then
        for nIndex, tData in ipairs(self.tChoose) do

            tData.Name:setVisible(false)

            for nCheckBoxIndex, pCheckBox in ipairs(tData.tCheckBox) do
	            pCheckBox:setVisible(false)
            end

            for nContentIndex, pContent in ipairs(tData.tContent) do
	            pContent:setVisible(false)
            end
        end
        -- 选择信息
        self.tChoose = {}
    else
        return
    end
    self.nChooseID = nChooseID

    for nIndex, pChooseTag in ipairs(self.tChooseTag) do
        if self.nChooseID ~= nIndex then
            pChooseTag:setTexture("CreateRoom/lanse_anniu.png")
        else
            pChooseTag:setTexture("CreateRoom/huangse_anniu.png")
        end
    end
    

    -- 设置描述
    self.DescText:setString(tInfo.tDesc.szDesc)

    local nOffIndex = 0
    for nIndex, tChooseInfo in ipairs(tInfo.tChoose) do

        if self.tChoose[nIndex] == nil then

            nOffIndex = nOffIndex + 1

            local tData = {}

            -- 名字
            local nPosX = 600
            local nPosY = 450 - (nOffIndex-1)*50
            tData.Name = ccui.Text:create("","Arial",28)
            tData.Name:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            tData.Name:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            tData.Name:setAnchorPoint(cc.p(0.5, 0.5))
            tData.Name:setPosition(cc.p(nPosX, nPosY))
            tData.Name:setColor(cc.c3b(255, 255, 255))
            tData.Name:setContentSize(cc.size(140, 28))
            tData.Name:ignoreContentAdaptWithSize(false)
            tData.Name:setString(tChooseInfo.szName)
            self.NodeChoose:addChild(tData.Name)

            -- 选择框
            if tData.tCheckBox == nil then
                tData.tCheckBox = {}
            end
            if tData.tContent == nil then
                tData.tContent = {}
            end
            local nChooseOff = nOffIndex
            for i=1, #tChooseInfo.tContent do 

                local nChooseIndex = math.modf((i-1) / 2)
                local nChooseValue = math.fmod((i-1), 2)
                nOffIndex = nChooseOff + nChooseIndex
                local nPosX = 715 + nChooseValue*200
                local nPosY = 450 - (nOffIndex-1)*50
                tData.tCheckBox[i] = ccui.CheckBox:create(tChooseInfo.tCheckBox[1], tChooseInfo.tCheckBox[2], tChooseInfo.tCheckBox[3], tChooseInfo.tCheckBox[4], tChooseInfo.tCheckBox[5])
                tData.tCheckBox[i]:setAnchorPoint(cc.p(0.5, 0.5))
                tData.tCheckBox[i]:setPosition(cc.p(nPosX, nPosY))
                tData.tCheckBox[i]:setContentSize(cc.size(120, 32))
                tData.tCheckBox[i]:setSelected(i==tChooseInfo.nDefaultValue)
                tData.tCheckBox[i]:setEnabled(true)
                tData.tCheckBox[i]:setTag(nIndex*10000+i)
                tData.tCheckBox[i]:addClickEventListener(handler(self, self.Click_Choose))
                self.NodeChoose:addChild(tData.tCheckBox[i])

                nPosX = 775 + nChooseValue*200
                nPosY = 450 - (nOffIndex-1)*50
                tData.tContent[i] = ccui.Text:create("","Arial",20)
                tData.tContent[i]:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                tData.tContent[i]:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                tData.tContent[i]:setAnchorPoint(cc.p(0.5, 0.5))
                tData.tContent[i]:setPosition(cc.p(nPosX, nPosY))
                tData.tContent[i]:setColor(cc.c3b(255, 255, 255))
                tData.tContent[i]:setContentSize(cc.size(140, 20))
                tData.tContent[i]:ignoreContentAdaptWithSize(false)
                tData.tContent[i]:setString(tChooseInfo.tContent[i])
                tData.tContent[i]:setTag(nIndex*10000+100+i)
                tData.tContent[i]:setTouchEnabled(true)
                tData.tContent[i]:addClickEventListener(handler(self, self.Click_Choose))
                self.NodeChoose:addChild(tData.tContent[i])
            end

            self.tChoose[nIndex] = tData
        end
    end

    -- 更新房间信息
    self:updateRoomInfo()
end

-- 更新房间信息
function CreateRoomLayer:updateRoomInfo()

    for nIndex, tData in ipairs(self.tChoose) do
        for nCheckBoxIndex, pCheckBox in ipairs(tData.tCheckBox) do
            local bSelect = tData.tCheckBox[nCheckBoxIndex]:isSelected()
            -- 根据选择设置
            if bSelect == true then
                tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 190, 0, 255))
            else
                tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 255, 255, 255))
            end
	        tData.tCheckBox[nCheckBoxIndex]:setSelected(bSelect)
        end
    end
end

-- 创建房间
function CreateRoomLayer:Click_Create()

    if self.nChooseID == nil then
        return
    end

    local tGame = roomConfig.tGame[self.nChooseID]
    if tGame == nil then
        return
    end

    local tRoomConfig = {}
    for i=1, 20 do
        tRoomConfig[i] = 0
    end
    for nIndex, tData in ipairs(self.tChoose) do

        local nValue = 0
        for nCheckBoxIndex, pCheckBox in ipairs(tData.tCheckBox) do
            local bSelect = tData.tCheckBox[nCheckBoxIndex]:isSelected()
            
            -- 复选框的时候，勾选了多个按位处理
            local tInfo = tGame.tChoose[nIndex]
            -- 如果是单选框，只需要找到选择那个，然后跳出
            if tInfo.nType == Choose_SingleSelect then
                if bSelect == true then
                    nValue = nCheckBoxIndex
                    break
                end

            -- 复选框
            elseif tInfo.nType == Choose_MultiSelect then
                if bSelect == true then
                    nValue = nValue + bit.lshift(1, (nCheckBoxIndex-1))
                end
            end
        end

        -- 连接字符串
        tRoomConfig[nIndex] = nValue
    end

	G_Data.CL_CreateGameReq = {}
    G_Data.CL_CreateGameReq.nGameID = tGame.nGameID
    G_Data.CL_CreateGameReq.nRoomConfig = tRoomConfig

    dump(G_Data.CL_CreateGameReq)
	
	G_NetManager:sendMsg(NETTYPE_LOGIN, "CL_CreateGameReq")
end

-- 关闭
function CreateRoomLayer:Click_Close()

	self:setVisible(false)
end

-- 游戏局数选择
function CreateRoomLayer:Click_Choose(sender)

	local nTag = sender:getTag()
    self:Choose(nTag)
end

function CreateRoomLayer:Choose(nTag)

    if nTag == nil then
        return
    end

    local nIndex = math.modf(nTag / 10000)
    local nValue = math.fmod(nTag, 10000)

    local tData = self.tChoose[nIndex]
    if tData == nil then
        return
    end

    if self.nChooseID == nil then
        return
    end
    if roomConfig.tGame[self.nChooseID] == nil then
        return
    end
    local tInfo = roomConfig.tGame[self.nChooseID].tChoose[nIndex]
    if tInfo == nil then
        return
    end

    -- tCheckBox
    if nValue < 100 then
        
        -- 选择索引
        local nChooseIndex = nValue

        for nCheckBoxIndex, pCheckBox in ipairs(tData.tCheckBox) do

            if nChooseIndex == nCheckBoxIndex then 
                local bSelect = tData.tCheckBox[nCheckBoxIndex]:isSelected()

                -- 如果是单选框，已选择状态，再点还设置为true
                if tInfo.nType == Choose_SingleSelect then
                    bSelect = true
                end
                -- 根据选择设置
                if bSelect == true then
                    tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 190, 0, 255))
                else
                    tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 255, 255, 255))
                end
	            tData.tCheckBox[nCheckBoxIndex]:setSelected(bSelect)
            else
                tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 255, 255, 255))
	            tData.tCheckBox[nCheckBoxIndex]:setSelected(false)
            end
        end
    -- tContent
    elseif nValue >= 100 and nValue <= 200 then

        local nChooseIndex = nValue - 100

        for nCheckBoxIndex, pCheckBox in ipairs(tData.tCheckBox) do

            if nChooseIndex == nCheckBoxIndex then 
                local bSelect = tData.tCheckBox[nCheckBoxIndex]:isSelected()
                
                -- 如果是单选框，已选择状态，再点还设置为true
                if tInfo.nType == Choose_SingleSelect then
                    bSelect = true
                else
                    -- 取反
                    bSelect = not bSelect
                end
                -- 根据选择设置
                if bSelect == true then
                    tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 190, 0, 255))
                else
                    tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 255, 255, 255))
                end
                tData.tCheckBox[nCheckBoxIndex]:setSelected(bSelect)
            else
                tData.tContent[nCheckBoxIndex]:setTextColor(cc.c4b(255, 255, 255, 255))
	            tData.tCheckBox[nCheckBoxIndex]:setSelected(false)
            end
        end
    end
end

-- 选择标志
function CreateRoomLayer:Click_ChooseSpriteTag(nTag)
    if nTag == nil then
        return
    end

    self:setRoomInfo(nTag)
end

function CreateRoomLayer:handleMsg(event)
	if event.msgName == "CL_CreateGameAck" then
		if G_Data.CL_CreateGameAck.dwResult == 1 then
			G_Data.roomid = G_Data.CL_CreateGameAck.roomid
		else
			if G_Data.roomid == 0 then
				local curLayer = G_WarnLayer.create()
            	curLayer:setTips("创建房间失败")
            	curLayer:setTypes(1)
            	self:addChild(curLayer)
			else
				local curLayer = G_WarnLayer.create()
            	curLayer:setTips("当前正在房间中，请点击加入房间")
            	curLayer:setTypes(1)
            	self:addChild(curLayer)
			end
		end
	elseif event.msgName == "CL_UpdateUserDataAck" then
		table.merge(G_Data.UserBaseInfo,G_Data.CL_UpdateUserDataAck.UserBaseInfo)
	end
end

function CreateRoomLayer:onEnter()

	self.target, self.event_handlermsg = G_Event:addEventListener("receiveMsg",handler(self,self.handleMsg))
    
    self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)  
end

function CreateRoomLayer:onExit()

	G_Event:removeEventListener(self.event_handlermsg)

    self:getEventDispatcher():removeEventListener(self.listener)
end

function CreateRoomLayer:onTouchBegin(touch, event)

	if self:isVisible() then
		return true
	else
		return false
	end
end

function CreateRoomLayer:onTouchMove(touch, event)
end

function CreateRoomLayer:onTouchEnded(touch, event)

    local location = touch:getLocationInView()
    local touchPoint = cc.Director:getInstance():convertToGL(location)

    for nIndex, pSpriteTag in ipairs(self.tChooseTag) do
        if cc.rectContainsPoint(pSpriteTag:getBoundingBox(), touchPoint) then
            self:Click_ChooseSpriteTag(pSpriteTag:getTag())
        end
    end
end

return CreateRoomLayer
