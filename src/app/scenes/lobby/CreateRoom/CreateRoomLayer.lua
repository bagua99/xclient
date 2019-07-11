
local RoomConfig        = require "app.config.RoomConfig"
local GameConfig        = require "app.config.GameConfig"

local M = class("CreateRoomLayer",function()
	return display.newLayer()
end)

function M:ctor(nChooseID)
	local node = cc.CSLoader:createNode("Lobby/CreateRoom/CreateRoomLayer.csb");
	node:addTo(self)
	self.root = node 
	self:initView(nChooseID)
end

function M:initView(nChooseID)
	-- 选择ID
    self.nChooseID = 0
    -- 选择信息
    self.tChoose = {}

	self.panel = self.root:getChildByName("Panel")
	self.BG = self.root:getChildByName("BG")
	self.BTN_CLOSE = self.panel:getChildByName("BTN_CLOSE")
	self.BTN_COMMIT = self.panel:getChildByName("BTN_COMMIT")
    -- 选择列表
    self.NodeChoose           = self.panel:getChildByName("NodeChoose")

	self.BTN_CLOSE:addClickEventListener(handler(self, self.Click_Close))
    self.BTN_COMMIT:addClickEventListener(handler(self, self.Click_Create))

    local curColorLayer = display.newLayer(cc.c4b(0,0,0,30))
    self.BG:addChild(curColorLayer)

    self:setRoomInfo(nChooseID)
end

function M:Click_Close()
    G_CommonFunc:addClickSound()
	self:removeFromParent()
end

-- 退出场景
function M:onExit()
	
end

-- 设置房间信息
function M:setRoomInfo(nChooseID)
    local tInfo = RoomConfig.tGame[nChooseID]
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

    local nOffIndex = 0
    for nIndex, tChooseInfo in ipairs(tInfo.tChoose) do
        if self.tChoose[nIndex] == nil then
            if not tChooseInfo.bHide then
                nOffIndex = nOffIndex + 1
            end

            local tData = {}

            -- 名字
            local nPosX = 610
            local nPosY = 450 - (nOffIndex-1)*50
            tData.Name = ccui.Text:create("","res/commonfont/ZYUANSJ.TTF",36)
            tData.Name:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            tData.Name:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            tData.Name:setAnchorPoint(cc.p(0.5, 0.5))
            tData.Name:setPosition(cc.p(nPosX, nPosY))
            tData.Name:setColor(cc.c3b(255, 255, 255))
            tData.Name:setContentSize(cc.size(200,36))
            tData.Name:ignoreContentAdaptWithSize(false)
            tData.Name:setString(tChooseInfo.szName)
            -- 不隐藏就显示
            tData.Name:setVisible(not tChooseInfo.bHide)
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
                local nPosX = 705 + nChooseValue*240
                local nPosY = 450 - (nOffIndex-1)*50
                
                local nType = tChooseInfo.nType                 
                if nType == GameConfig.Choose_SingleSelect then
                    tData.tCheckBox[i] = ccui.RadioButton:create(tChooseInfo.tCheckBox[1],tChooseInfo.tCheckBox[3])
                -- 复选框
                elseif nType == GameConfig.Choose_MultiSelect then
                    tData.tCheckBox[i] = ccui.CheckBox:create(tChooseInfo.tCheckBox[1], tChooseInfo.tCheckBox[2], tChooseInfo.tCheckBox[3], tChooseInfo.tCheckBox[4], tChooseInfo.tCheckBox[5])
                end
                tData.tCheckBox[i]:setAnchorPoint(cc.p(0.5, 0.5))
                tData.tCheckBox[i]:setPosition(cc.p(nPosX, nPosY))
                tData.tCheckBox[i]:setContentSize(cc.size(120,36))
                tData.tCheckBox[i]:setSelected(i==tChooseInfo.nDefaultValue)
                tData.tCheckBox[i]:setEnabled(true)
                tData.tCheckBox[i]:setTag(nIndex*10000+i)
                tData.tCheckBox[i]:addClickEventListener(handler(self, self.Click_Choose))
                tData.tCheckBox[i]:setScale(1.5)
                -- 不隐藏就显示
                tData.tCheckBox[i]:setVisible(not tChooseInfo.bHide)
                self.NodeChoose:addChild(tData.tCheckBox[i])

                nPosX = 845 + nChooseValue*240
                nPosY = 450 - (nOffIndex-1)*50
                tData.tContent[i] = ccui.Text:create("","res/commonfont/ZYUANSJ.TTF",32)
                tData.tContent[i]:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                tData.tContent[i]:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                tData.tContent[i]:setAnchorPoint(cc.p(0.5, 0.5))
                tData.tContent[i]:setPosition(cc.p(nPosX, nPosY))
                tData.tContent[i]:setColor(cc.c3b(255, 255, 255))
                tData.tContent[i]:setContentSize(cc.size(220, 32))
                tData.tContent[i]:ignoreContentAdaptWithSize(false)
                tData.tContent[i]:setString(tChooseInfo.tContent[i])
                tData.tContent[i]:setTag(nIndex*10000+100+i)
                tData.tContent[i]:setTouchEnabled(true)
                tData.tContent[i]:addClickEventListener(handler(self, self.Click_Choose))
                -- 不隐藏就显示
                tData.tContent[i]:setVisible(not tChooseInfo.bHide)
                self.NodeChoose:addChild(tData.tContent[i])
            end

            self.tChoose[nIndex] = tData
        end
    end

    -- 设置描述
    if tInfo.tTip ~= nil and tInfo.tTip.szDesc ~= nil then
        -- 名字
        local nPosX = 796
        local nPosY = 440 - #self.tChoose*55

        if self.TipDescText == nil then
            self.TipDescText = ccui.Text:create(tInfo.tTip.szDesc, "res/commonfont/ZYUANSJ.TTF",28)
            self.TipDescText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            self.TipDescText:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            self.TipDescText:setAnchorPoint(cc.p(0.5, 0.5))
            self.TipDescText:setPosition(cc.p(nPosX, nPosY))
            self.TipDescText:setColor(cc.c3b(255, 255, 255))
            self.TipDescText:setContentSize(cc.size(580,120))
            self.TipDescText:ignoreContentAdaptWithSize(false)
            self.NodeChoose:addChild(self.TipDescText)
        else
            self.TipDescText:setPosition(cc.p(nPosX, nPosY))
            self.TipDescText:setString(tInfo.tTip.szDesc)
            self.TipDescText:setVisible(true)
        end
    else
        if self.TipDescText ~= nil then
            self.TipDescText:setVisible(false)
        end
    end
    -- 更新房间信息
    self:updateRoomInfo()
end

-- 更新房间信息
function M:updateRoomInfo()
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
function M:Click_Create()
    G_CommonFunc:addClickSound()
    if self.nChooseID == nil then
        return
    end

    local tGame = RoomConfig.tGame[self.nChooseID]
    if tGame == nil then
        return
    end

    local tRoomConfig = {}
    for nIndex, tData in ipairs(self.tChoose) do
        -- 取得配置信息
        local tInfo = tGame.tChoose[nIndex]
        local value
        for nCheckBoxIndex, pCheckBox in ipairs(tData.tCheckBox) do
            local bSelect = tData.tCheckBox[nCheckBoxIndex]:isSelected()
            -- 如果是单选框，只需要找到选择那个，然后跳出
            if tInfo.nType == GameConfig.Choose_SingleSelect then
                if bSelect == true then
                    value = tInfo.tValue[nCheckBoxIndex]
                    break
                end

            -- 复选框
            elseif tInfo.nType == GameConfig.Choose_MultiSelect then
                if bSelect == true then
                    value = value or {}
                    table.insert(value, tInfo.tValue[nCheckBoxIndex])
                end
            end
        end

        local t = {key = tInfo.szKey}
        if type(value) == "number" then
            t.snvalue = value
        elseif type(value) == "string" then
            t.ssvalue = value
        elseif type(value) == "table" then
            t.mvalue = value
        end
        table.insert(tRoomConfig, t)
    end

    local msg = {
        userid = G_Data.UserBaseInfo.userid,
        sign = G_Data.UserBaseInfo.sign,
        account = G_Data.UserBaseInfo.account,
        nickname = G_Data.UserBaseInfo.nickname,
        headimgurl = G_Data.UserBaseInfo.headimgurl,
        sex = G_Data.UserBaseInfo.sex,
        gameid = tGame.nGameID,
        options = tRoomConfig
    }
    
    G_Event:dispatchEvent({name="sendMsg_CreateRoom", msg=msg})
end

-- 游戏局数选择
function M:Click_Choose(sender)
    G_CommonFunc:addClickSound()
	local nTag = sender:getTag()
    self:Choose(nTag)
end

function M:Choose(nTag)
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
    if RoomConfig.tGame[self.nChooseID] == nil then
        return
    end
    local tInfo = RoomConfig.tGame[self.nChooseID].tChoose[nIndex]
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
                if tInfo.nType == GameConfig.Choose_SingleSelect then
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
                if tInfo.nType == GameConfig.Choose_SingleSelect then
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

return M
