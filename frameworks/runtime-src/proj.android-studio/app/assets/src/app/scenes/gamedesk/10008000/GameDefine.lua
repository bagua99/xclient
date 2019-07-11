local GameDefine = class("GameDefine")

-- 最大玩家数量
GameDefine.nMaxPlayerCount = 8

-- 玩家数量
GameDefine.nPlayerCount = 8

-- 当前局数
GameDefine.nGameCount = 1

-- 最大局数
GameDefine.nTotalGameCount = 10

-- 游戏状态
GameDefine.nGameStatus = 0

-- 回放状态
GameDefine.bReplay = false

-- 最大牌数
GameDefine.nCardCount = 5

return GameDefine