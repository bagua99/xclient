
local GameManager = class(GameManager, cc.load("mvc").AppBase)

function GameManager:onCreate()
	
	math.randomseed(os.time())
	self:initGloblClass()   --注册一些全局的类,例如CommonFunc
	self:initGloblVariant()
	self:initGloblEvent()
	self:initPbc()
end

function GameManager:initGloblClass()

	cc.exports.G_CommonFunc = require("app.common.CommonFunc"):create()
	cc.exports.G_BaseScene = require("app.base.BaseScene")
	cc.exports.G_BaseLayer = require("app.base.BaseLayer")
	cc.exports.G_BaseTcp = require("app.base.BaseTcp")

	cc.exports.G_NetManager = require("app.net.NetManager"):create()
	require("cocos.framework.components.event"):bind(self)
	cc.exports.G_Event = self
	cc.exports.G_SceneManager = require("app.scenes.GameSceneManager"):create()
    cc.exports.G_GameDeskManager = require("app.scenes.gamedesk.GameDeskManager"):create()
    cc.exports.G_Data = require("app.data.DataManager")
	cc.exports.G_WarnLayer = require("app.common.WarnLayer")
end

function GameManager:initPbc()
	cc.exports.G_Pbc = require("app.net.pbc")
	G_Pbc:init()
end

function GameManager:initGloblVariant()
	cc.exports.G_HeadImg = cc.FileUtils:getInstance():getWritablePath().."myhead.png"
end

function GameManager:initGloblEvent()

	G_CommonFunc:addEvent(CUSTOMMSG_USERHEAD,handler(self,self.getUserHead))
end

function GameManager:getUserHead()

	EVENT_GETUSERHEAD = true
end

function GameManager:start()

	G_SceneManager:start()
end

return GameManager
