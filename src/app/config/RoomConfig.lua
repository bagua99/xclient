
local M = class("RoomConfig")

M.tGame = 
{
	-- 跑得快
    [1] = require "app.config.PdkConfig",
	-- 牛牛
	[2] = require "app.config.NnConfig",
	-- 地锅子牛牛
	[3] = require "app.config.DgnnConfig",
    -- 宁乡跑胡子
	[4] = require "app.config.NxphzConfig",
	-- 长沙麻将
	--[5] = require "app.config.CsmjConfig",
	-- 永州包牌
	[6] = require "app.config.YzbpConfig",
}

return M