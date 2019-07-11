
local GameConfig    = require "app.config.GameConfig"
local EventConfig   = require "app.config.EventConfig"

local M =
{
    nType = 1,          -- 选择类型(推荐0,1牌类,2麻将,3跑胡子)
    nGameID = 1,        -- 游戏ID
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
            tContent    = {"3人", "2人"},
			tValue 		= {3, 2},
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
            szKey       = "show_card",
            szName      = "功能选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"显示牌", "不显示牌"},
			tValue 		= {1, 0},
            nDefaultValue = 2,
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
            szKey       = "first_out",
            szName      = "首局选择：",
            nType       = GameConfig.Choose_MultiSelect,
            tContent    = {"首局先出黑桃3"},
			tValue 		= {1},
            nDefaultValue = 1,
            tCheckBox   =
            {
                "Lobby/CreateRoom/xiaofangkuai.png",
                "Lobby/CreateRoom/xiaofangkuai.png",
                "Lobby/CreateRoom/duigou.png",
                "Lobby/CreateRoom/xiaofangkuai.png",
                "Lobby/CreateRoom/xiaofangkuai.png",
            },
        },
        {
            szKey       = "press_card",
            szName      = "玩法选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"必须管","可以不管"},
			tValue      = {1, 0},
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
            szKey       = "code_card",
            szName      = "码牌选择：",
            nType       = GameConfig.Choose_MultiSelect,
            tContent    = {"红桃10扎鸟"},
			tValue 		= {1},
            nDefaultValue = 0,
            tCheckBox   =
            {
                "Lobby/CreateRoom/xiaofangkuai.png",
                "Lobby/CreateRoom/xiaofangkuai.png",
                "Lobby/CreateRoom/duigou.png",
                "Lobby/CreateRoom/xiaofangkuai.png",
                "Lobby/CreateRoom/xiaofangkuai.png",
            },
        },
    }
}

if EventConfig.CHECK_IOS then
    M.tChoose[1].tContent = {"10局", "20局"}
end

return M
