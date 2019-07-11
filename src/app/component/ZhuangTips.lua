local M = class("ZhuangTips",function()
	return display.newLayer()
end)

M.BG = nil 
M.number = nil 

function M:ctor()
	-- body
    local imageView = ccui.ImageView:create()
    imageView:loadTexture("nnResult_zhuangTips.png", ccui.TextureResType.plistType)
    imageView:setPosition(cc.p(0,0))
    self.BG = imageView
    self.BG:addTo(self)

    local number = ccui.Text:create(str,"res/commonfont/ZYUANSJ.TTF",22)    
    number:setFontSize(16)
    number:setColor(cc.c3b(159, 168, 176))
    number:setPosition(cc.p(0,0))

    self.number = number
    self.number:addTo(self)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1.1),cc.CallFunc:create(function()
        -- body
        if call then call() end 
        self:removeFromParent()
    end)))

end

function M:initView( ... )
	-- body

end

function M:setString( str )
	-- body
	self.number:setString(str)	 
end


return M