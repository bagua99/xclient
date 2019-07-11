local name_tbl = {}
local id_tbl = {}

local M = {}

function M.register_mod(mod)
	local m = require(mod)
	m.register()
end

function M.register(id, name)
	name_tbl[name] = id
	id_tbl[id] = name
end

function M.name_2_id(name)
    return name_tbl[name]
end

function M.id_2_name(id)
    return id_tbl[id]
end

return M
