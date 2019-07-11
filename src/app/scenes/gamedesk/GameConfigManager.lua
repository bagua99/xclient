
local M = class("GameConfigManager")

M.tGameID =
{
    PDK = 1,         -- 跑得快
    NN = 2,          -- 普通牛牛
    DGNN = 3,        -- 地锅牛牛
    NXPHZ = 4,       -- 宁乡跑胡子
    CSMJ = 5,        -- 长沙麻将
    YZBP = 6,        -- 永州包牌
}

M.tPlist = 
{
    -- 跑得快
    [1] =
    {
        {img = "res/plist/Card.png", plist = "res/plist/Card.plist"},
        {img = "res/Component/ShowMap/ShowMap.png", plist = "res/Component/ShowMap/ShowMap.plist"},
        {img = "res/1/GameEnd/pdk_end.png", plist = "res/1/GameEnd/pdk_end.plist"},
        {img = "res/1/GameDesk/pdk_desk.png", plist = "res/1/GameDesk/pdk_desk.plist"},
        {img = "res/1/GameTotalEnd/pdk_totalend.png", plist = "res/1/GameTotalEnd/pdk_totalend.plist"},
    },
    -- 普通牛牛
    [2] =
    {
        {img = "res/plist/Card.png", plist = "res/plist/Card.plist"},
        {img = "res/plist/niuniu.png", plist = "res/plist/niuniu.plist"},
        {img = "res/plist/nnResult.png", plist = "res/plist/nnResult.plist"},
    },
    -- 地锅牛牛
    [3] =
    {
        {img = "res/plist/Card.png", plist = "res/plist/Card.plist"},
        {img = "res/plist/niuniu.png", plist = "res/plist/niuniu.plist"},
        {img = "res/plist/nnResult.png", plist = "res/plist/nnResult.plist"},
    },
    -- 宁乡跑胡子
    [4] =
    {
        {img = "res/plist/phz_Card.png", plist = "res/plist/phz_Card.plist"},
        {img = "res/4/nxphz_desk.png", plist = "res/4/nxphz_desk.plist"},
        {img = "res/4/nxphz_end.png", plist = "res/4/nxphz_end.plist"},
        {img = "res/4/nxphz_totalend.png", plist = "res/4/nxphz_totalend.plist"},
    },
    -- 长沙麻将
    [5] =
    {
    },
    -- 永州包牌
    [6] =
    {
        {img = "res/plist/res_poker_cards.png", plist = "res/plist/res_poker_cards.plist"},
    },
}

M.actionsID = {
    SHUNZI = 1,
    FEIJI  = 2,
    DOUBLE_LINE = 3,
    THREE_TAKE_ONE = 4, 
    THREE_TAKE_TWO = 5, 
    SHENGLI = 10,
}

M.actions = {
    [1]=65,
    [2]=70,
    [3]=70,
    [4]=70,
    [5]=70,
    [10]=95
}

return M