local M = {}

------------用于连接的返回类型检测--------------
M.NETTYPE_LOBBY = "LOBBY"
M.NETTYPE_GAME = "GAME"

M.RESTART_GAME = "RESTART_GAME"

-----所有的场景
M.SCENE_LOGIN = 1
M.SCENE_LOBBY = 2

-- 游戏版本
M.GAME_VERSION = "1.0.0"

-- IOS过审标志
M.CHECK_IOS = false

-- 测试版本
M.GAME_TEST = false

return M