local BaseTcp = class("BaseTcp")

local SocketTCP = require("componentex.SocketTCP")
local ByteArray = require("componentex.ByteArray")
local Utils = require("utils")
local MsgDefine = require("msg_define")

function BaseTcp:ctor()
	self._socket = SocketTCP.create()
	self.m_iLen = 0
	self.m_iWriteLen = 1

    if self.onCreate then 
        self:onCreate()
    end
end

function BaseTcp:sendProtoMsg(name, msg)
	print(name,msg)
	local proto_id = MsgDefine.name_2_id(name)
	local buf = G_Pbc:encode(name, msg)
	local len = 2 + #buf
	
	local data = Utils.int16_2_bytes(len)
	data = data .. Utils.int16_2_bytes(proto_id)
	data = data .. buf
	self._socket:send(data)

    release_print("sendMsg: "..name)
end

function BaseTcp:unPackProtoMsg(data)
	local proto_id = data:byte(1) * 256 + data:byte(2)
	local buf = data:sub(3)
	local proto_name = MsgDefine.id_2_name(proto_id)
	local msg = G_Pbc:decode(proto_name, buf)(buf)
	return proto_name, msg
end

function BaseTcp:sendGameProtoclMsg(__strSendData)
	self._socket:send(__strSendData:getBytes())
end

function BaseTcp:getHTEMP(param)
	if param == "H" then
		return true
	else 
		return false
	end
end

function BaseTcp:writeRecvMsg(bytes, tData, mapMess)

	for i=1,#mapMess["params"] do
		local strParam = mapMess["params"][i]
		if string.sub(strParam,1,1) == "$" then
			local strS = string.sub(strParam,2)
			tData[strS] = {}
			self:writeRecvMsg(bytes,tData[strS],protocol.struct[strS])
		elseif string.sub(strParam,1,1) == "#" then
			local tbMsg = string.split(strParam,"|")
			if #tbMsg < 2 then
				assert("param is error,no |")
				return
			end
			local iNum = tonumber(string.sub(tbMsg[1],2))
			local iNum2 = 1
			if #tbMsg == 3 then
				iNum2 = tonumber(tbMsg[2])
			end

			local strS = string.sub(tbMsg[2],1,1)
			if #tbMsg == 3 then
				strS = string.sub(tbMsg[3],1,1)
			end

			local ayName = tbMsg[2]
			if #tbMsg == 3 then
				ayName = tbMsg[3]
			end

			if strS == "$" then
				ayName = string.sub(ayName,2)
			end
			tData[ayName] = {}

			local tbProtocol = string.split(mapMess["protocol"][i],"|")
			if #tbProtocol ~= #tbMsg then
				assert("protocol is error,no |")
				return
			end
		
			local ayNameProtocol = tbProtocol[2]
			if #tbMsg == 3 then
				ayNameProtocol = tbProtocol[3]
			end

			local iOneTotal = 1
			if strS == "$" then
				ayNameProtocol = string.sub(tbProtocol[2],2)
				if #tbMsg == 3 then
					ayNameProtocol = string.sub(tbProtocol[3],2)
				end
			else
                local strFlag = string.sub(ayNameProtocol,-1)
				local iNum = 1
				if string.len(ayNameProtocol) ~= 1 then
					iNum = tonumber(string.sub(ayNameProtocol,1,-2))
				end
				iOneTotal = iNum * self._socket:getFlagLen(strFlag)
			end

			for j=1,iNum do
				
				if strS == "$" then
					tData[ayName][j] = {}
					if #tbMsg == 3 then
						for z=1,iNum2 do
							tData[ayName][j][z] = {}
							self:writeRecvMsg(bytes,tData[ayName][j][z],protocol.struct[ayName])
						end
					else
						
						self:writeRecvMsg(bytes,tData[ayName][j],protocol.struct[ayName])
					
					end
				else
					if #tbMsg == 3 then
						tData[ayName][j] = {}
						for z=1,iNum2 do
							self.m_iWriteLen = self.m_iWriteLen + iOneTotal
							local strInfo = bytes:rawUnPack(ayNameProtocol)
							tData[ayName][j][z] = strInfo
							bytes:setPos(self.m_iWriteLen)
						end
					else
						self.m_iWriteLen = self.m_iWriteLen + iOneTotal
						local strInfo = bytes:rawUnPack(ayNameProtocol)
						tData[ayName][j] = strInfo
						bytes:setPos(self.m_iWriteLen)
					end
				end
			end
		else
            local strFlag = string.sub(mapMess["protocol"][i],-1)
			local iNum = 1
			if string.len(mapMess["protocol"][i]) ~= 1 then
				iNum = tonumber(string.sub(mapMess["protocol"][i],1,-2))
			end
			self.m_iWriteLen = self.m_iWriteLen + iNum * self._socket:getFlagLen(strFlag)
			local strInfo = bytes:rawUnPack(mapMess["protocol"][i])
			tData[strParam] = strInfo
			bytes:setPos(self.m_iWriteLen)
		end
	end
end

return BaseTcp
