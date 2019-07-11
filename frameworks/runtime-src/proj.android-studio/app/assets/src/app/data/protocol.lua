
ID_REQ = 0
ID_ACK = 0x80000000
ID_COMPRESS= 0x40000000

ID_BASEREGISTER = 0
ID_BASELINK = 0x00010000
ID_BASECOMMON = 0x00020000
ID_BASELOGIN = 0x00030000
ID_BASEDB = 0x00040000
ID_BASEBI = 0x00050000
ID_BASEGAMELOGIC = 0x00060000

SEX_FEMALE = 2
SEX_MALE = 1

protocol = {}
--类似c++的结构体
protocol.struct = 
{
	WeChatInfo = 
    {
        params = {"openid","nickname","sex","province","city","country","headimgurl","unionid"},
		protocol = {"50p","50p","i","20p","20p","20p","200p","50p"}
    },

	UserBaseInfo = 
    {
        params = {"userid","nickname","headimgurl","score","roomcard"},
		protocol = {"l","50p","200p","L","l"}
    },

	UserGameData = 
    {
        params = {"ullUserID","szNickName","ullRoomCard","sex","imgurl","ip"},
		protocol = {"L","50p","L","i","200p","40p"}
    },

	ReplayWinLose = 
    {
        params = {"nickname","deltascore"},
		protocol = {"50p","L"}
    },

	ReplaListInfo = 
    {
        params = {"gameresult","roomid","tableid","#4|$ReplayWinLose","datetime"},
		{"i","L","L","#4|$ReplayWinLose","25p"}
    },
}

protocol.req_protocol = 
{
	CL_LoginReq = 
    {
        ID = ID_BASELOGIN + 0x0001,
        params = {"ticket","$WeChatInfo","channel"},
        protocol = {"30p","$WeChatInfo","i"}
    },

    CL_ReplayListReq = 
    {
        ID = ID_BASELOGIN + 0x0005,
        params = {},
		protocol = {}
    },

	CL_ReplayDetailReq = 
    {
        ID = ID_BASELOGIN + 0x0007,
        params = {"roomid"},
		protocol = {"L"}
    },

	CL_CreateGameReq = 
    {
        ID = ID_BASELOGIN + 0x000C,
        params = {"nGameID","#20|nRoomConfig"},
		protocol = {"i","#20|i"}
    },

	CL_JoinGameReq = 
    {
        ID = ID_BASELOGIN + 0x000E,
        params = {"roomid","mode"},
		protocol = {"L","i"}
    },

	CL_AddUserRoomCardReq = 
    {
        ID = ID_BASELOGIN + 0x0019,
        params = {"userid","deltacard","type"},
		protocol = {"L","i","i"}
    },
}

protocol.res_protocol = 
{
	[ID_BASELINK + 0x0002] = 
    {
        MsgName = "CL_LinkInfoAck",
        params = {"dwResult","szTicket","szIp","dwPort"},
		protocol = {"i","30p","40p","i"},
        name="link服返回，结果，ticket,ip和端口"
    },

    [ID_BASECOMMON + 0x0001] = 
    {
        MsgName = "CG_HeartBeatAck",
        params = {"ullTime"},
		protocol = {"L"},
        name = "大厅心跳"
    },

	[ID_BASELOGIN + 0x0002] = 
    {
        MsgName = "CL_LoginAck",
        params = {"dwResult","$UserBaseInfo","roomid"},
		protocol = {"i","$UserBaseInfo","L"},
        name="登录返回"
    },

    [ID_BASELOGIN + 0x0006] = 
    {
        MsgName = "CL_ReplayListAck",
        params = {"count"},
		protocol = {"i"},
        name = "回放"
    },

	[ID_BASELOGIN + 0x0008] = 
    {
        MsgName = "CL_ReplayDetailAck",
        params = {},
		protocol = {},
        name = "回放"
    },

    [ID_BASELOGIN + 0x000D] = 
    {
        MsgName = "CL_CreateGameAck",
        params = {"dwResult","roomid", "nGameID"},
		protocol = {"i","L", "i"},
        name="创建房间返回"
    },

    [ID_BASELOGIN + 0x000F] = 
    {
        MsgName = "CL_JoinGameAck",
        params = {"dwResult","roomid","ip","port","ticket","nGameID"},
		protocol = {"i","L","40p","i","30p","i"},
        name="更新人物信息返回"
    },

	[ID_BASELOGIN + 0x0011] = 
    {
        MsgName = "CL_BroadCastAck",
        params = {"count"},
		protocol = {"i"},
        name="登录返回"
    },

	[ID_BASELOGIN + 0x0016] = 
    {
        MsgName = "CL_UpdateUserDataAck",
        params = {"$UserBaseInfo"},
		protocol = {"$UserBaseInfo"},
        name="更新人物信息返回"
    },
}