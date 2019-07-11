local GameDefine = class("GameDefine")

-- 最大玩家数量
GameDefine.nMaxPlayerCount = 3

-- 玩家数量
GameDefine.nPlayerCount = 3

-- 当前局数
GameDefine.nGameCount = 0

-- 最大局数
GameDefine.nTotalGameCount = 10

-- 游戏状态
GameDefine.nGameStatus = 0

-- 回放状态
GameDefine.bReplay = false

-- 最大牌数
GameDefine.nCardCount = 16

return GameDefine