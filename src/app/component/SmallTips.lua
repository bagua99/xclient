local M = class("SmallTips",function()
	return display.newLayer()
end)

M.BG = nil 
M.number = nil 

function M:ctor(call)
	-- body
	local imageView = ccui.ImageView:create()
    imageView:loadTexture("nnResult_smallTips.png", ccui.TextureResType.plistType)
    imageView:setOpacity(90)
    imageView:setPosition(cc.p(0,0))
    self.BG = imageView
    self.BG:addTo(self)

    local number = ccui.Text:create("","res/commonfont/ZYUANSJ.TTF",30)
    number:setString("")
    number:setFontSize(30)
    number:setColor(cc.c4b(255,228,131,255))
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

function M:setString( number )
	-- body
	if number>0 then 
		self.number:setString("+"..tostring(number))	 
	else 
		self.number:setString(tostring(number))	 
	end 
end


return M