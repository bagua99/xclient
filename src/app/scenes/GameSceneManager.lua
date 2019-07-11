
local M = class("GameSceneManager")

local EventConfig               = require ("app.config.EventConfig")

function M:ctor( )
	self._scenes = 
	{
		"app.scenes.login.LoginScene",   	 --1
		"app.scenes.lobby.LobbyScene",       --2
	}
end

function M:start()
	self:enterScene(EventConfig.SCENE_LOGIN)
end

function M:enterScene(nSceneID)
	display.runScene(require(self._scenes[nSceneID]).create(),nil,0.3,display.COLOR_WHITE)
end

return M
