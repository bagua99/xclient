local M = class("GameDefine")

-- 游戏休闲状态
M.game_free = 0
-- 游戏开始状态
M.game_play = 1

-- 最大玩家数量
M.nMaxPlayerCount = 3

-- 玩家数量
M.nPlayerCount = 3

-- 当前局数
M.nGameCount = 0

-- 最大局数
M.nTotalGameCount = 10

-- 游戏状态
M.nGameStatus = 0

-- 最大牌数
M.nCardCount = 16

-- 无效
M.invalid_seat = 0xFF

return M