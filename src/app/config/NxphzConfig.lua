local GameConfig = require "app.config.GameConfig"

-- 宁乡跑胡子
return {
    nType = 3,          -- 选择类型(推荐0,1牌类,2麻将,3跑胡子)
    nGameID = 4,        -- 游戏ID
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
            tContent      = {"6局(房卡x2)", "12局(房卡x4)"},
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
    }
}