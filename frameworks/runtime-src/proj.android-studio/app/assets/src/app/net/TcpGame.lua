
local TcpGame = class("TcpGame", G_BaseTcp)

local SocketTCP             = require("componentex.SocketTCP")
local ByteArray             = require("componentex.ByteArray")

function TcpGame:onCreate()

	self.m_netType = NETTYPE_GAME
	self.bConnect = false
	self._socket:setNetType(NETTYPE_GAME)
end

function TcpGame:connectServer(strIp,strPort,cbOk,cbFailed)
	self.m_cbOk = cbOk
	self.m_cbFailed = cbFailed
	G_CommonFunc:addLockLayer()
	if self.bConnect then
		local curEvent = {}
		curEvent.nettype = self.m_netType
		self:netEvent_Connected(curEvent)
	else
		self._socket:connect(strIp,strPort)
	end	
end

function TcpGame:bConnect()
	return self.bConnect
end

function TcpGame:connect()

    if self.event_connect ~= nil then
        G_Event:removeEventListener(self.event_connect)
    end
    if self.event_getdata ~= nil then
        G_Event:removeEventListener(self.event_getdata)
    end
    if self.event_close ~= nil then
        G_Event:removeEventListener(self.event_close)
    end

	self.target, self.event_connect = G_Event:addEventListener(SocketTCP.EVENT_CONNECTED,handler(self,self.netEvent_Connected))
	self.target, self.event_getdata = G_Event:addEventListener(SocketTCP.EVENT_DATA ,handler(self,self.netEvent_getData))
	self.target, self.event_close = G_Event:addEventListener(SocketTCP.EVENT_CLOSED,handler(self,self.netEvent_Close))
end

function TcpGame:disconnect()
	if self._socket:isConnect() then
		self._socket:disconnect()
	end

    if self.event_connect ~= nil then
        G_Event:removeEventListener(self.event_connect)
    end
    if self.event_getdata ~= nil then
        G_Event:removeEventListener(self.event_getdata)
    end
    if self.event_close ~= nil then
        G_Event:removeEventListener(self.event_close)
    end
end

function TcpGame:netEvent_Connected(event)

	if event.nettype ~= self.m_netType then
		return
	end

    G_GameDeskManager:netEvent_Connected(event)

	release_print("TcpGame ok")
	G_CommonFunc:removeLockLayer()
	self.bConnect = true
	if self.m_cbOk then
		self.m_cbOk()
	end
	self.m_cbFailed = nil
	self.m_cbOk = nil
end

function TcpGame:netEvent_getData(event)

	if event.nettype ~= self.m_netType then
		return
	end

    G_GameDeskManager:netEvent_getData(event)
end

function TcpGame:netEvent_Close(event)

	if event.nettype ~= self.m_netType then
		return
	end

    G_GameDeskManager:netEvent_Close(event)

	release_print("TcpGame close")
	G_CommonFunc:removeLockLayer()
	self.bConnect = false
	if self.m_cbFailed then
		self.m_cbFailed()
	end
	self.m_cbFailed = nil
	self.m_cbOk = nil
end

return TcpGame
