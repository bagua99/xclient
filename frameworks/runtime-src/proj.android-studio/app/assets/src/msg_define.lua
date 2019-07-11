local M = {}

local id_tbl = {
    -- µÇÂ½Ð­Òé
    {name = "protocol.CL_LinkInfoReq"},
	{name = "protocol.CL_LinkInfoAck"},
	{name = "protocol.CG_HeartBeatReq"},
	{name = "protocol.CG_HeartBeatAck"},
	{name = "protocol.CL_LoginReq"},
	{name = "protocol.CL_LoginAck"},
	{name = "protocol.CL_ReplayListReq"},
	{name = "protocol.CL_ReplayListAck"},
	{name = "protocol.CL_ReplayDetailReq"},
	{name = "protocol.CL_ReplayDetailAck"},
	{name = "protocol.CL_CreateGameReq"},
	{name = "protocol.CL_CreateGameAck"},
	{name = "protocol.CL_JoinGameReq"},
	
	{name = "protocol.CL_JoinGameAck"},
	{name = "protocol.CL_AddUserRoomCardReq"},
	{name = "protocol.CL_BroadCastAck"},
	{name = "protocol.CL_UpdateUserDataAck"},
}

local name_tbl = {}

for id,v in ipairs(id_tbl) do
    name_tbl[v.name] = id
end

function M.name_2_id(name)
    return name_tbl[name]
end

function M.id_2_name(id)
    local v = id_tbl[id]
    if not v then
        return
    end

    return v.name
end

function M.get_by_id(id)
    return id_tbl[id]
end

function M.get_by_name(name)
    local id = name_tbl[name]
    return id_tbl[id]
end

return M