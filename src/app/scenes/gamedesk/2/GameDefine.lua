local M = class("GameDefine")

--不同游戏的游戏状态
-- 游戏休闲状态
M.game_free = 0
-- 游戏开始状态
M.game_play = 1
-- 游戏结束状态
M.game_end = 2

-- 最大玩家数量
M.nMaxPlayerCount = 8

-- 玩家数量
M.nPlayerCount = 8

-- 当前局数
M.nGameCount = 1

-- 最大局数
M.nTotalGameCount = 10

-- 游戏状态
M.nGameStatus = 0

-- 最大牌数
M.nCardCount = 5

return M