
local GameConfigManager = class("GameConfigManager")

-- 游戏配置管理
GameConfigManager.tGameID =
{
    PDK = 10003000,         -- 经典跑得快
    NN = 10008000,          -- 8人牛牛
}

-- 上次进入游戏ID
GameConfigManager.nLastGameID = 0

return GameConfigManager