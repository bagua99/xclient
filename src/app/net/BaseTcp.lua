local SocketTCP = require("componentex.SocketTCP")
local Utils = require("utils")
local crc32 = require "rcc"

local M = class("BaseTcp")

function M:ctor()
	self._socket = SocketTCP.create()
    if self.onCreate then 
        self:onCreate()
    end
	self.index = 1
end

function M:resetIndex()
	self.index = 1
end

function M:sendStr(str)
	local len = #str
	local data = Utils.int16_2_bytes(len)..str
	dump("host info")
	dump(len)
	dump(str)
	self._socket:send(data)
end

function M:sendProtoMsg(name, msg)
	--[[
	-- 反向用的，现在已去掉
	if self.index == 1 then
		self:sendStr(G_Data.room_host)
	end
	--]]

	local proto_id = G_MsgDefine.name_2_id(name)
    if name ~= "protocol.HeartBeatReq" then
	    release_print("send msg:", proto_id, name)
    end

	local buf = G_Pbc:encode(name, msg)
	local len = 2 + #buf + 2 + 8
	dump("发送包"..len)
	
	local data_len = Utils.int16_2_bytes(len)
	local data = Utils.int16_2_bytes(proto_id)
	data = data .. buf
	data = data .. Utils.int16_2_bytes(self.index)
	local crcData = crc32.hash(data) 	
	 
	data = data .. crcData
	data = Utils.xor(data)
	self._socket:send(data_len..data)
	self.index = self.index + 1
end

function M:unPackProtoMsg(data)
	local proto_id = data:byte(1) * 256 + data:byte(2)
	local buf = data:sub(3)
	local proto_name = G_MsgDefine.id_2_name(proto_id)
	local msg = G_Pbc:decode(proto_name, buf)
    if proto_name ~= "protocol.HeartBeatAck" then
        print("recv msg:", proto_id, proto_name)
    end
	return proto_name, msg
end

return M
