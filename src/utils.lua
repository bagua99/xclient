local bit = require "bit"
local M = {}

local function serialize (obj)
	local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{"
    	for k, v in pairs(obj) do  
        	lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ","  
    	end  
    	local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        	for k, v in pairs(metatable.__index) do  
            	lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ","  
        	end
		end
        lua = lua .. "}"  
    elseif t == "nil" then  
        return "nil"  
    elseif t == "userdata" then
		return "userdata"
	elseif t == "function" then
		return "function"
	else  
        error("can not serialize a " .. t .. " type.")
    end  
    return lua
end

M.table_2_str = serialize

function M.print(o)
	local str = serialize(o)
	print(str)
end

function M.str_2_table(str)
	local func_str = "return "..str
    local func = load(func_str)
	return func()
end

function M.int16_2_bytes(num)
	local high = math.floor(num/256)
	local low = num % 256
	return string.char(high) .. string.char(low)
end

function M.bytes_2_int16(bytes)
	local high = math.byte(bytes,1)
	local low = math.byte(bytes,2)
	return high*256 + low
end

local b64chars = 'srqponml-_9876543YXWVUTSRQPONMLKJI210kjiCBAhgfedcbaZHGFzyxwvutED'
function M.base64encode(source_str)
    local s64 = ''  
    local str = source_str  
  
    while #str > 0 do  
        local bytes_num = 0  
        local buf = 0  
  
        for byte_cnt=1,3 do  
            buf = (buf * 256)  
            if #str > 0 then  
                buf = buf + string.byte(str, 1, 1)  
                str = string.sub(str, 2)  
                bytes_num = bytes_num + 1  
            end  
        end  
  
        for group_cnt=1,(bytes_num+1) do  
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1  
            s64 = s64 .. string.sub(b64chars, b64char, b64char)  
            buf = buf * 64  
        end  
  
        for fill_cnt=1,(3-bytes_num) do  
            s64 = s64 .. '.'  
        end  
    end  
  
    return s64 
end

function M.base64decode(str64)
	if not str64 then return nil end
	if #str64 < 3 then return "" end
    local temp={}  
    for i=1,64 do  
        temp[string.sub(b64chars,i,i)] = i  
    end  
    temp['.']=0  
    local str=""  
    for i=1,#str64,4 do  
        if i>#str64 then  
            break  
        end  
        local data = 0  
        local str_count=0  
        for j=0,3 do  
            local str1=string.sub(str64,i+j,i+j)  
            if not temp[str1] then  
                return  
            end  
            if temp[str1] < 1 then  
                data = data * 64  
            else  
                data = data * 64 + temp[str1]-1  
                str_count = str_count + 1  
            end  
        end  
        for j=16,0,-8 do  
            if str_count > 0 then  
                str=str..string.char(math.floor(data/math.pow(2,j)))  
                data=math.mod(data,math.pow(2,j))  
                str_count = str_count - 1  
            end  
        end  
    end  
  
    local last = tonumber(string.byte(str, string.len(str), string.len(str)))  
    if last == 0 then  
        str = string.sub(str, 1, string.len(str) - 1)  
    end  
    return str
end

function M.xor(str, key)
    local ret = ""                                                                                                                                                                                                      
    local key = key or "magic"                                                                                                                                                            
    for i=1,#str do                                                                                                                                                                                                       
       local data = string.byte(str, i)                                                                                                                                                                      
       local temp = bit.bxor(data, string.byte(string.sub(key, 1, 1)))                                                                                                                                                                               
       for i = 2, string.len(key) do                                                                                                                                                                                                      
           temp = bit.bxor(temp, string.byte(string.sub(key, i, i)))                                                                                                                                                                                 
       end                                                                                                                                                                                                                                
       ret = ret .. string.char(temp)                                                                                                                                                                                                       
    end
    return ret                                                                                                                                                                                                                          
end

function M.rand_table(t)
    local n = #t
    for i = 1, n do
        local j = math.random(i, n)
        if j > i then
            t[i], t[j] = t[j], t[i]
        end
    end
end

return M