
local EventConfig = require("app.config.EventConfig")

local M = { }

if not EventConfig.GAME_TEST then
    -- 正式服
    M.tDNSList =
    {
        {
            "127.0.0.1",
        },
    }
    M.login_port = "8888"
    M.lobby_port = "7701"
else
    -- 本地测试
    M.tDNSList =
    {
        {
            "127.0.0.1",
        },
    }
    M.login_port = "8080"
    M.lobby_port = "7701"
end

M.web_port = 4888
-- 反馈接口
M.feed_back_url                 = "/nxqp/nx/feedback.htm"
-- 消息内容
M.get_notice_content            = "/nxqp/nx/getnotice.htm"
--申请代理接口
M.applyDL_url                   = "/nxqp/nx/applydl.htm"
--代理收益接口
M.profit_get_url                = "/nxqp/nx/dlprofit.htm"
--是否是代理查询
M.be_proxy_player_url           = "/nxqp/nx/isdl.htm"
--代理收益详情地址
M.proxyer_desc_url              = "/nxqp/ht/home.htm"
--分享链接的下载地址
M.download_url          = "http://www.59iwan.cn/nxqp/nx/share.htm"
--游戏下载地址
M.game_downLoad_url     = "http://www.59iwan.cn/nxqp"

M.get_record_room_list  = "http://127.0.0.1:9101/get_record_room_list"
M.get_record_list       = "http://127.0.0.1:9101/get_record_list"
M.get_record_game       = "http://127.0.0.1:9101/get_record_game"

-- 开房单选
M.Choose_SingleSelect = 1
-- 开房多选
M.Choose_MultiSelect = 2

return M