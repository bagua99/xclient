local M = class("ScoreTips",function()
	return display.newLayer()
end)

M.BG = nil 
M.number = nil 

function M:ctor()
	-- body
	local imageView = ccui.ImageView:create()
    imageView:loadTexture("nnResult_scoreTips.png", ccui.TextureResType.plistType)
    imageView:setPosition(cc.p(0,0))
    self.BG = imageView
    self.BG:addTo(self)

    local number = ccui.Text:create()
    number:setString("")
    number:setFontSize(25)
    number:setColor(cc.c4b(255,228,131,255))
    number:setPosition(cc.p(0,0))

    self.number = number
    self.number:addTo(self)

end

function M:initView( ... )
	-- body

end

function M:setString( number )
	-- body
	self.number:setString(tostring(number))	 
end


return M