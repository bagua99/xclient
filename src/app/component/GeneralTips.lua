local M = class("GeneralTips",function()
	return display.newLayer()
end)

M.BG = nil 
M.number = nil 

function M:ctor(gameId,str)
    local imageView = ccui.ImageView:create()
    imageView:loadTexture("res/GameScene/laba_dikuang.png")
    imageView:setPosition(cc.p(0,0))
    self.BG = imageView
    self.BG:addTo(self)

    local number = ccui.Text:create(str,"res/commonfont/ZYUANSJ.TTF",22)    
    number:setColor(cc.c3b(255,255,255))
    number:setPosition(cc.p(0,0))
    self.number = number
    self.number:addTo(self)
    
    local posx = display.cx
    local posy = display.cy
    local move1 = cc.MoveTo:create(0.5,cc.p(posx,posy+150))
    self:runAction(cc.Sequence:create(move1,cc.DelayTime:create(0.5),cc.FadeOut:create(0.5),cc.CallFunc:create(function()
        self:removeFromParent()
    end)))
end

function M:initView(...)
end


return M