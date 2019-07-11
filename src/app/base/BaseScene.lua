local BaseScene = class("BaseScene", cc.Scene)

function BaseScene:ctor()
    self:enableNodeEvents()

    if self.onCreate then self:onCreate() end
end

return BaseScene
