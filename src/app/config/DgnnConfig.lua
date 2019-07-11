
local GameConfig    = require "app.config.GameConfig"
local EventConfig   = require "app.config.EventConfig"

local M =
{
    nType   = 1,          -- 选择类型(推荐0,1牌类,2麻将,3跑胡子)
    nGameID = 3,          -- 游戏ID
    bShow   = true,       -- 是否显示
    tDesc =
    {
        szDesc = 
[[1、牌型大小:牛牛>牛9>牛8>牛7>牛6…>无牛。
2、牌型相同比较牌数字大小:K>Q>J>10>9>8>7>6>5>4>3>2>A。
3、数字相同比较花色大小：黑桃>红桃>梅花>方块。
4、赔率:牛牛3倍，牛7、牛8、牛9是2倍，牛1到牛6，无牛是1倍。
]],
    },
    tTip =
    {
        szDesc = [[宁乡地锅子轮庄说明：第1个创建房间的玩家当首庄，首庄下庄后，接着他右边的人当庄，以此类推。参与的玩家都当1次庄后，牌局结束。]],
    },
    -- 选择信息
    tChoose = 
    {
        {
            szKey       = "face_card",
            szName      = "花牌选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"有花牌", "无花牌"},
			tValue    	= {1, 0},
            nDefaultValue      = 1,
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
            szKey       = "room_card",
            szName      = "房卡消耗：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"4张"},
            tValue      = {1},
            nDefaultValue      = 1,
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
            szKey       = "difen_choice",
            szName      = "庄底分数：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"50分"},
            tValue      = {50},
            nDefaultValue      = 1,
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
            szKey       = "player_count",
            szName      = "人数选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"5人"},
            tValue      = {5},
            nDefaultValue      = 1,
            tCheckBox   =
            {
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaohuangdian.png",
                "Lobby/CreateRoom/xiaolandian.png",
                "Lobby/CreateRoom/xiaolandian.png",
            },
        },
    },
}

if EventConfig.CHECK_IOS then
    M.tChoose[2].szName = "最低局数"
    M.tChoose[2].tContent = {"15局"}
end

return M