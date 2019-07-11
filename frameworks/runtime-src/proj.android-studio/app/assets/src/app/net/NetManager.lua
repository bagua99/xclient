
local NetManager = class("NetManager")

local TcpLink = require("app.net.TcpLink")
local TcpLogin = require("app.net.TcpLogin")
local TcpGame = require("app.net.TcpGame")

function NetManager:ctor()

	self.TcpLink = nil
	self.TcpLogin = nil
	self.TcpGame = nil
end

function NetManager:connectLink(cbOk,cbFailed)
	if self.TcpLink == nil then
		self.TcpLink = TcpLink.create()
	end
	self.TcpLink:connect()
	self.TcpLink:connectServer(cbOk,cbFailed)
end

function NetManager:connectLogin(strIp,strPort,cbOk,cbFailed)
	if  self.TcpLogin == nil then
		self.TcpLogin = TcpLogin.create()
	end
	self.TcpLogin:connect()
	self.TcpLogin:connectServer(strIp,strPort,cbOk,cbFailed)
end

function NetManager:connectGame(strIp,strPort,cbOk,cbFailed)
	if self.TcpGame == nil then
		self.TcpGame = TcpGame.create()
	end
	self.TcpGame:connect()
	self.TcpGame:connectServer(strIp,strPort,cbOk,cbFailed)
end

function NetManager:disconnect(nType)
	if nType == NETTYPE_FENPEI then
		if self.TcpLink then
			self.TcpLink:disconnect()
		end
	elseif nType == NETTYPE_LOGIN then
		if self.TcpLogin then
			self.TcpLogin:disconnect()
		end
	elseif nType == NETTYPE_GAME then
		if self.TcpGame then
			self.TcpGame:disconnect()
		end
	end
end

function NetManager:isLinkConnect()
	return self.TcpLink:bConnect()
end

function NetManager:sendMsg(nType, name, msg)
	if nType == NETTYPE_FENPEI then
		if self.TcpLink then
			self.TcpLink:sendProtoMsg(name, msg)
		end
	elseif nType == NETTYPE_LOGIN then
		if self.TcpLogin then
			self.TcpLogin:sendProtoMsg(name, msg)
		end
	elseif nType == NETTYPE_GAME then
		if self.TcpGame then
			self.TcpGame:sendProtoMsg(name, msg)
		end
	end
end

function NetManager:sendGameProtoclMsg(nType, __strSendData)
	if nType ~= NETTYPE_GAME then
		return
	end

    if self.TcpGame then
        self.TcpGame:sendGameProtoclMsg(__strSendData)
    end
end

return NetManager
