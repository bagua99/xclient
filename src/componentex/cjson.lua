local M = {}

local cjson
local function safeLoad()
    cjson = require("cjson")
end

if not pcall(safeLoad) then 
    cjson = nil
end

function M.encode(var)
    local status, result = pcall(cjson.encode, var)
    if status then return result end
    if DEBUG > 1 then
        printError("cjson.encode() - encoding failed: %s", tostring(result))
    end
end

function M.decode(text)
    local status, result = pcall(cjson.decode, text)
    if status then return result end
    if DEBUG > 1 then
        printError("cjson.decode() - decoding failed: %s", tostring(result))
    end
end

if cjson then
    M.null = cjson.null
else
    M = nil
end

return M
