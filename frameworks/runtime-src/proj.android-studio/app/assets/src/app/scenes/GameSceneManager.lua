
local GameSceneManager = class("GameSceneManager")

function GameSceneManager:ctor( )
	self._scenes = 
	{
		"app.scenes.login.LoginScene",   	 --1
		"app.scenes.lobby.LobbyScene",       --2
	}
end
function GameSceneManager:start()
	display.runScene(require(self._scenes[SCENE_LOGIN]):create(),nil,0.3,display.COLOR_WHITE)
end

function GameSceneManager:enterScene(p_type)
	display.runScene(require(self._scenes[p_type]).create(),nil,0.3,display.COLOR_WHITE)
end

return GameSceneManager
