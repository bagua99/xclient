local M = class("UserInfoTips",function()
	return display.newLayer()
end)

function M:ctor(info)
    local node = cc.CSLoader:createNode("Lobby/GameScene/UserinfoLayer.csb")
    node:addTo(self)
    self.root = node 
    self:initView(info)
end

function M:initView(info)
    self.BG = self.root:getChildByName("BG")
    local curColorLayer = display.newLayer(cc.c4b(0,0,0,90))
    self.BG:addChild(curColorLayer)
    self.BG:addClickEventListener(function()
        self:removeFromParent()
    end)

    self.Text_NAME = self.root:getChildByName("Text_NAME")
    self.Text_ID = self.root:getChildByName("Text_ID")
    self.Text_IP = self.root:getChildByName("Text_IP")
    self.IMG_HEAD_ICON = self.root:getChildByName("IMG_HEAD")

    local szNickName = info.nickname
    local len = string.len(szNickName)
    if len > 12 then 
        szNickName = string.sub(szNickName,1,12).."..."
    end
    local nickName = szNickName
    local ip = info.ip
    local adds = info.adds or ""
    local id = info.userid
    self.Text_NAME:setString(nickName)
    self.Text_ID:setString("ID:"..id)
    self.Text_IP:setString(adds)

    local saveName = cc.FileUtils:getInstance():getWritablePath().."avatarHead"..info.userid..".png"
    local f = cc.FileUtils:getInstance():isFileExist(saveName) 
    if f == true then
        local nHeadSize = 120
        if self.IMG_HEAD_ICON ~= nil then
            self.IMG_HEAD_ICON:loadTexture(saveName)
            local width = self.IMG_HEAD_ICON:getContentSize().width
            local height = self.IMG_HEAD_ICON:getContentSize().height
            self.IMG_HEAD_ICON:setScale(nHeadSize/width, nHeadSize/height)
        end
    else 
        --恢复默认头像
        self.IMG_HEAD_ICON:loadTexture("img_head.png", ccui.TextureResType.plistType)
    end
end

return M
