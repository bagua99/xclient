local M = class("NetManager")

local TcpLobby = require ("app.net.TcpLobby")
local TcpGame = require ("app.net.TcpGame")

local EventConfig = require ("app.config.EventConfig")

function M:ctor()
	self.TcpLobby = nil
	self.TcpGame = nil
end

function M:connectLobby(strIp,strPort,cbOk,cbFailed)
	if self.TcpLobby ~= nil then
        self.TcpLobby:disconnect()
	end
    self.TcpLobby = TcpLobby.create()
    self.TcpLobby:connectServer(strIp,strPort,cbOk,cbFailed)
end

function M:connectGame(strIp,strPort,cbOk,cbFailed,reconnect)
	if self.TcpGame ~= nil then
        self.TcpGame:disconnect()
	end
    self.TcpGame = TcpGame.create()
	if reconnect then
		self.TcpGame:connectServer(strIp,strPort,0xFFFFFFFF,1,cbOk,cbFailed)
	else
		self.TcpGame:connectServer(strIp,strPort,1,1,cbOk,cbFailed)
	end
end

function M:disconnect(nType)
	if nType == EventConfig.NETTYPE_LOBBY then
		if self.TcpLobby then
			self.TcpLobby:disconnect()
            self.TcpLobby = nil
		end
	elseif nType == EventConfig.NETTYPE_GAME then
		if self.TcpGame then
			self.TcpGame:disconnect()
            self.TcpGame = nil
		end
	end
end

function M:sendMsg(nType, name, msg)
    if name ~= "protocol.HeartBeatReq" then
	    print(nType, name, msg)
    end
	if nType == EventConfig.NETTYPE_LOBBY then
		if self.TcpLobby then
			self.TcpLobby:sendProtoMsg(name, msg)
		end
	elseif nType == EventConfig.NETTYPE_GAME then
		if self.TcpGame then
			self.TcpGame:sendProtoMsg(name, msg)
		end
	end
end

return M
