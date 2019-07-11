local GameManager = class(GameManager, cc.load("mvc").AppBase)

function GameManager:onCreate()
	math.randomseed(os.time())
	self:initGloblClass()   --注册一些全局的类,例如CommonFunc
	self:initPbc()
end

function GameManager:initGloblClass()
	cc.exports.G_CommonFunc = require("app.common.CommonFunc"):create()
	cc.exports.G_BaseScene = require("app.base.BaseScene")
	cc.exports.G_BaseLayer = require("app.base.BaseLayer")
	cc.exports.G_BaseTcp = require("app.net.BaseTcp")

	cc.exports.G_NetManager = require("app.net.NetManager"):create()
	require("cocos.framework.components.event"):bind(self)
	cc.exports.G_Event = self
	cc.exports.G_SceneManager = require("app.scenes.GameSceneManager"):create()
    cc.exports.G_GameDeskManager = require("app.scenes.gamedesk.GameDeskManager"):create()
    cc.exports.G_Data = require("app.data.DataManager")
	cc.exports.G_WarnLayer = require("app.common.WarnLayer")
	cc.exports.G_UIEvent = require("app.common.UIEvent").new()
    G_CommonFunc:getProxyIP()
end

function GameManager:initPbc()
	cc.exports.G_MsgDefine = require("app.net.msg_define")
	G_MsgDefine.register_mod("app.net.protocol_msg")

	cc.exports.G_Pbc = require("app.net.pbc")
	G_Pbc:init()
end

function GameManager:start()
	G_SceneManager:start()
end

return GameManager
