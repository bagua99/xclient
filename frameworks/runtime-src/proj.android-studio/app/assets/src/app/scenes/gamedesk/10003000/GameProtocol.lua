local GameProtocol = class("GameProtocol")

local GameConfigManager       = require("app.scenes.gamedesk.GameConfigManager")
local GameDefine              = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".GameDefine")

--类似c++的结构体
GameProtocol.struct =
{
	WeChatInfo = 
    {
        params = {"openid","nickname","sex","province","city","country","headimgurl","unionid"},
		protocol = {"50p","50p","i","20p","20p","20p","200p","50p"}
    },

	UserBaseInfo = 
    {
        params = {"userid","nickname","headimgurl","score","roomcard"},
		protocol = {"l","50p","200p","L","l"},
    },

	UserGameData = 
    {
        params = {"ullUserID","szNickName","ullRoomCard","sex","imgurl","ip"},
		protocol = {"L","50p","L","i","200p","40p"},
    },

    RoomInfo = 
    {
        params = {"bShowCard","bOutBankerCard","bMustPressCard","bHongTen"},
		protocol = {"b","b","b","b"},
    },
}

GameProtocol.req_protocol =
{
    -- 游戏常用固定
    -- 心跳请求
	GAME_HeartBeatReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x1000,
        params = {"ullTime"},
        protocol = {"L"},
    },

    -- 聊天
	GAME_ChatReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x1001,
        params = {},
        protocol = {},
    },

    -- 点击发送默认客户端聊天消息
	GAME_DefaultChatReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x1002,
        params = {"dwMsgID"},
        protocol = {"I"},
    },

    -- 房主点击解散请求
    GAME_DissolveGameReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x1004,
        params = {},
		protocol = {},
    },

    -- 投票请求
	GAME_DissolveGameVoteReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x1005,
        params = {"bApprove"},
		protocol = {"b"},
    },

    -- 准备
    GAME_ReadyReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x1007,
        params = {"bAgree"},
		protocol = {"b"},
    },


    -- 游戏请求消息码
    GAME_EnterGameReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x0001,
        params = {"ullUserID","ullRoomID","szTicket","bReconnect"},
	    protocol = {"L","L","30p","b"},
    },

	GAME_OutCardReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x0005,
        params = {"cbCardCount","#"..G_GameDefine.nCardCount.."|cbCardData"},
		protocol = {"C","#"..G_GameDefine.nCardCount.."|C"},
    },

    GAME_PassCardReq = 
    {
        ID = ID_BASEGAMELOGIC + 0x0006,
        params = {},
		protocol = {},
        name = "请求过牌",
    },
}

GameProtocol.res_protocol = 
{
    -- 游戏常用固定
    [ID_BASEGAMELOGIC + 0x1000] = 
    {
        MsgName = "GAME_HeartBeatAck",
        params = {"ullTime"},
		protocol = {"L"},
        name="心跳回复",
    },

    [ID_BASEGAMELOGIC + 0x1001] = 
    {
        MsgName = "GAME_ChatAck",
        params = {"wChairID"},
		protocol = {"H"},
        name="聊天回复",
    },

    [ID_BASEGAMELOGIC + 0x1002] = 
    {
        MsgName = "GAME_DefaultChatAck",
        params = {"wChairID", "dwMsgID"},
		protocol = {"H", "I"},
        name="服务器广播",
    },

    [ID_BASEGAMELOGIC + 0x1003] = 
    {
        MsgName = "GAME_LeaveGameAck",
        params = {"wChairID", "dwMsgID"},
		protocol = {"H", "I"},
        name="玩家退出消息",
    },

    [ID_BASEGAMELOGIC + 0x1004] = 
    {
        MsgName = "GAME_DissolveGameAck",
        params = {"wChairID", "dwResult"},
		protocol = {"H", "i"},
        name="玩家投票结果",
    },

    [ID_BASEGAMELOGIC + 0x1005] = 
    {
        MsgName = "GAME_DissolveGameVoteAck",
        params = {"wChairID", "bApprove"},
		protocol = {"H", "b"},
        name="玩家投票结果",
    },

    [ID_BASEGAMELOGIC + 0x1006] = 
    {
        MsgName = "GAME_DissolveGameVoteResultAck",
        params = {"dwResult", "#"..G_GameDefine.nMaxPlayerCount.."|bApprove", "#"..G_GameDefine.nMaxPlayerCount.."bVoteStatus"},
		protocol = {"i", "#"..G_GameDefine.nMaxPlayerCount.."|b", "#"..G_GameDefine.nMaxPlayerCount.."|b"},
        name="玩家投票结果",
    },

    [ID_BASEGAMELOGIC + 0x1007] = 
    {
        MsgName = "GAME_ReadyAck",
        params = {"wChairID", "bAgree"},
		protocol = {"H", "b"},
        name="准备消息回复",
    },

    [ID_BASEGAMELOGIC + 0x1009] = 
    {
        MsgName = "GAME_PromptAck",
        params = {"#256|szPrompt"},
		protocol = {"#256|c"},
        name="提示信息",
    },


    -- 游戏回复消息码
    [ID_BASEGAMELOGIC + 0x0001] = 
    {
        MsgName = "GAME_EnterGameAck",
        params = {"dwResult","dwErrorCode","nPlayerCount","nTableType","nGameStatus","lCellScore","nCurGameCount","nTotalGameCount","wChairID","ullMasterID","#"..G_GameDefine.nMaxPlayerCount.."|$UserGameData","$RoomInfo"},
		protocol = {"i","i","i","i","i","i","i","i","h","L","#"..G_GameDefine.nMaxPlayerCount.."|$UserGameData","$RoomInfo"},
        name="玩家进入游戏",
    },

	[ID_BASEGAMELOGIC + 0x0002] = 
    {
        MsgName = "GAME_NewPlayerAck",
        params = {"$UserGameData","wChairID"},
		protocol = {"$UserGameData","H"},
        name="新人进入",
    },

	[ID_BASEGAMELOGIC + 0x0003] = 	
    {
        MsgName = "GAME_GameSceneAck",
        params = {"dwGameStatus","dwGameStatusBeforeVote","lCellScore","#"..G_GameDefine.nMaxPlayerCount.."|dwGameScore","#"..G_GameDefine.nMaxPlayerCount.."|bReadyStatus",
                  "#"..G_GameDefine.nMaxPlayerCount.."|bVoteStatus","#"..G_GameDefine.nMaxPlayerCount.."|bVoteNote","wDissoveUser","#"..G_GameDefine.nMaxPlayerCount.."|arrNickName","#"..G_GameDefine.nMaxPlayerCount.."|arrImgUrl",
                  "#"..G_GameDefine.nMaxPlayerCount.."|arrUserID","wBankerUser","wLastOutUser","wCurrentUser",
                  "#"..G_GameDefine.nCardCount.."|cbCardData","#"..G_GameDefine.nMaxPlayerCount.."|cbCardCount","cbTurnCardCount","#"..G_GameDefine.nCardCount.."|cbTurnCardData","$RoomInfo"},
        protocol = {"i","i","i","#"..G_GameDefine.nMaxPlayerCount.."|i","#"..G_GameDefine.nMaxPlayerCount.."|C",
                  "#"..G_GameDefine.nMaxPlayerCount.."|b","#"..G_GameDefine.nMaxPlayerCount.."|b","H","#"..G_GameDefine.nMaxPlayerCount.."|50p","#"..G_GameDefine.nMaxPlayerCount.."|200p",
                  "#"..G_GameDefine.nMaxPlayerCount.."|L","H","H","H",
                  "#"..G_GameDefine.nCardCount.."|C","#"..G_GameDefine.nMaxPlayerCount.."|C","C","#"..G_GameDefine.nCardCount.."|C","$RoomInfo"},
        name="断线重连结构体",
    },

    [ID_BASEGAMELOGIC + 0x0004] = 
    {
        MsgName = "GAME_GameStartAck",
        params = {"wCurrentUser","cbCardCount","#"..G_GameDefine.nCardCount.."|cbCardData"},
		protocol = {"H","C","#"..G_GameDefine.nCardCount.."|C"},
        name="游戏开始消息",
    },
    
    [ID_BASEGAMELOGIC + 0x0005] = 
    {
        MsgName = "GAME_OutCardAck",
        params = {"wCurrentUser","wOutCardUser","cbCardCount","#"..G_GameDefine.nCardCount.."|cbCardData"},
		protocol = {"H","H","C","#"..G_GameDefine.nCardCount.."|C"},
        name = "玩家打牌",
    },

    [ID_BASEGAMELOGIC + 0x0006] = 
    {
        MsgName = "GAME_PassCardAck",
        params = {"bNewTurn","wPassUser","wCurrentUser"},
		protocol = {"b","H","H"},
        name = "过牌结果",
    },
    
    [ID_BASEGAMELOGIC + 0x0007] = 
    {
        MsgName = "GAME_GameEndAck",
        params = {"#"..G_GameDefine.nMaxPlayerCount.."|lGameScore","#"..G_GameDefine.nMaxPlayerCount.."|lTotalScore","#"..G_GameDefine.nMaxPlayerCount.."|cbBombCount",
                  "#"..G_GameDefine.nMaxPlayerCount.."|cbCardCount","#"..G_GameDefine.nMaxPlayerCount.."|"..G_GameDefine.nCardCount.."|cbCardData"},
		protocol = {"#"..G_GameDefine.nMaxPlayerCount.."|i","#"..G_GameDefine.nMaxPlayerCount.."|l","#"..G_GameDefine.nMaxPlayerCount.."|C",
                    "#"..G_GameDefine.nMaxPlayerCount.."|C","#"..G_GameDefine.nMaxPlayerCount.."|"..G_GameDefine.nCardCount.."|C"},
        name = "游戏结束",
    },

    [ID_BASEGAMELOGIC + 0x0008] = 
    {
        MsgName = "GAME_GameTotalEndAck",
        params = {"#"..G_GameDefine.nMaxPlayerCount.."|lTotalScore","#"..G_GameDefine.nMaxPlayerCount.."|nMaxScore","#"..G_GameDefine.nMaxPlayerCount.."|cbAllBombCount","#"..G_GameDefine.nMaxPlayerCount.."|cbWinCount"},
		protocol = {"#"..G_GameDefine.nMaxPlayerCount.."|l","#"..G_GameDefine.nMaxPlayerCount.."|i","#"..G_GameDefine.nMaxPlayerCount.."|C","#"..G_GameDefine.nMaxPlayerCount.."|C"},
        name = "游戏总结算",
    },
}

return GameProtocol