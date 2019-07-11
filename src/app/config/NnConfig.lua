
local GameConfig = require "app.config.GameConfig"

-- 牛牛
return {
    nType   = 1,          -- 选择类型(推荐0,1牌类,2麻将,3跑胡子)
    nGameID = 2,          -- 游戏ID
    bShow   = false,      -- 是否显示
    tDesc =
    {
        szDesc = "1.牌型大小:牛牛>牛9>牛8>牛7>牛6…>无牛。\n2.牌型相同比较牌数字大小：K>Q>J>10>9>8>7>6>5>4>3>2>A \n3.数字相同比较花色大小：黑桃>红桃>梅花>方块 \n4.赔率:牛牛3倍，牛7、牛8、牛9是2倍，牛1到牛6，无牛是1倍。\n",
    },
    -- 选择信息
    tChoose = 
    {
        {
            szKey       = "room_card",
            szName      = "局数选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"10局(房卡x1)","20局(房卡x2)"},
			tValue 		= {1, 2},
            nDefaultValue      = 1,      --默认索引
            tCheckBox   =
            {
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaohuangdian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
            },
        },
        {
            szKey       = "player_count",
            szName      = "人数选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"8人"},
			tValue		= {8},
            nDefaultValue      = 1,
            tCheckBox   =
            {
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaohuangdian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
            },
        },
        {
            szKey       = "face_card",
            szName      = "花牌选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"有花牌", "无花牌"},
			tValue    	= {1, 0},
            nDefaultValue      = 1,
            tCheckBox   =
            {
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaohuangdian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
            },
        },
        {
            szKey       = "banker_type",
            szName      = "玩法选择：",
            nType       = GameConfig.Choose_SingleSelect,
            tContent    = {"玩家抢庄","房主坐庄","牛牛坐庄","牌大坐庄","轮庄斗牛"},
			tValue      = {"玩家抢庄","房主坐庄","牛牛坐庄","牌大坐庄","轮庄斗牛"},
            nDefaultValue      = 1,
            tCheckBox   =
            {
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaohuangdian.png",
                "CreateRoom/xiaolandian.png",
                "CreateRoom/xiaolandian.png",
            },
        },
    },
}