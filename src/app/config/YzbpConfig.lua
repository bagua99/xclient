
local GameConfig    = require "app.config.GameConfig"
local EventConfig   = require "app.config.EventConfig"

local M =
{
    nType = 1,          -- 选择类型(推荐0,1牌类,2麻将,3跑胡子)
    nGameID = 6,        -- 游戏ID
    bShow   = true,       -- 是否显示
    tDesc =
    {
        szDesc = 
[[1、去掉双王、3个2、1个A。
2、使用48张牌，每人16张。
3、炸弹可以压下任何牌型。
4、最大的单牌是2。
5、牌型的比较点数大。
]],
    },
    -- 选择信息
    tChoose = 
    {
        {
            szKey         = "room_card",
            szName        = "局数选择：",
            nType         = GameConfig.Choose_SingleSelect,
            tContent      = {"10局(房卡x2)", "20局(房卡x4)"},
			tValue 		  = {1, 2},
            nDefaultValue = 1,      --默认索引
            tCheckBox     =
            {
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaohuangdian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
            },
        },
        {
            szKey       = "player_count",
            szName      = "人数选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"4人", "3人"},
			tValue 		= {4, 3},
            nDefaultValue = 1,
            tCheckBox   =
            {
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaohuangdian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
            },
        },
        {
            -- 隐藏
            bHide       = true,
            szKey       = "pass_six",
            szName      = "去牌规则：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"去掉6"},
			tValue 		= {0},
            nDefaultValue = 1,
            tCheckBox   =
            {
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaohuangdian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
            },
        },
    }
}

if EventConfig.CHECK_IOS then
    M.tChoose[1].tContent = {"10局", "20局"}
end

return M
