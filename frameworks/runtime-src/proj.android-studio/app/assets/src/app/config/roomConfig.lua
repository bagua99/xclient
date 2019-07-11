
local roomConfig = class("roomConfig")

-- 单选
Choose_SingleSelect = 1
-- 多选
Choose_MultiSelect = 2

roomConfig.tGame = 
{
    -- 跑得快
    {
        nType                           = 1,          -- 选择类型(推荐0,1牌类,2麻将,3跑胡子)
        nGameID                         = 10003000,   -- 游戏ID
        -- 标签
        tTag = 
        {
            Tag         = "CreateRoom/lanse_anniu.png",
            Sprite      = "CreateRoom/paodekuai.png",
        },
        tDesc =
        {
            szDesc                      = "1.去掉双王、3个2、1个A. \n2.使用48张牌，每人16张.\n3.炸弹可以压下任何牌型.\n4.最大的单牌是2.\n5.牌型的比较点数大.\n",
        },
        -- 选择信息
        tChoose = 
        {
            {
                szName      = "局数选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "10局(房卡x1)",
                    "20局(房卡x2)",
                },
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
                szName      = "人数选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "3人",
                    "2人",
                },
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
                szName      = "功能选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "显示牌",
                    "不显示牌",
                },
                nDefaultValue      = 2,
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
                szName      = "首局选择：",
                nType       = Choose_MultiSelect,
                tContent    =  
                {
                    "首局先出黑桃3",
                },
                nDefaultValue      = 1,
                tCheckBox   =
                {
                    "CreateRoom/xiaofangkuai.png",
                    "CreateRoom/xiaofangkuai.png",
                    "CreateRoom/duigou.png",
                    "CreateRoom/xiaofangkuai.png",
                    "CreateRoom/xiaofangkuai.png",
                },
            },
            {
                szName      = "玩法选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "必须管",
                    "可以不管",
                },
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
                szName      = "码牌选择：",
                nType       = Choose_MultiSelect,
                tContent    = 
                {
                    "红桃10扎鸟",
                },
                nDefaultValue      = 0,
                tCheckBox   =
                {
                    "CreateRoom/xiaofangkuai.png",
                    "CreateRoom/xiaofangkuai.png",
                    "CreateRoom/duigou.png",
                    "CreateRoom/xiaofangkuai.png",
                    "CreateRoom/xiaofangkuai.png",
                },
            },
        },
    },

    -- 牛牛
    {
        nType                           = 1,          -- 选择类型(推荐0,1牌类,2麻将,3跑胡子)
        nGameID                         = 10008000,   -- 游戏ID
        -- 标签
        tTag = 
        {
            Tag         = "CreateRoom/lanse_anniu.png",
            Sprite      = "CreateRoom/niuniu.png",
        },
        tDesc =
        {
            szDesc                      = "1.牌型大小:牛牛>牛9>牛8>牛7>牛6…>无牛。\n2.牌型相同比较牌数字大小：K>Q>J>10>9>8>7>6>5>4>3>2>A \n3.数字相同比较花色大小：黑桃>红桃>梅花>方块 \n4.赔率:牛牛3倍，牛7、牛8、牛9是2倍，牛1到牛6，无牛是1倍。\n",
        },
        -- 选择信息
        tChoose = 
        {
            {
                szName      = "局数选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "10局(房卡x1)",
                    "20局(房卡x2)",
                },
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
                szName      = "人数选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "8人",
                },
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
                szName      = "花牌选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "有花牌",
                    "无花牌",
                },
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
                szName      = "玩法选择：",
                nType       = Choose_SingleSelect,
                tContent    = 
                {
                    "玩家抢庄",
                    "房主坐庄",
                    "牛牛坐庄",
                    "牌大坐庄",
                    "轮庄斗牛",
                },
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
    },
}

return roomConfig