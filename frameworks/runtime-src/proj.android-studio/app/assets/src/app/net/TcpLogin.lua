
local TcpLogin = class("TcpLogin", G_BaseTcp)

local scheduler =  cc.Director:getInstance():getScheduler()

local SocketTCP             = require("componentex.SocketTCP")
local ByteArray             = require("componentex.ByteArray")

function TcpLogin:onCreate()
	self.m_netType = NETTYPE_LOGIN
	self.bConnect = false
	self._socket:setNetType(NETTYPE_LOGIN)
end

function TcpLogin:connectServer(strIp,strPort,cbOk,cbFailed)
	release_print(strIp)
	release_print(strPort)
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

function TcpLogin:bConnect()
	return self.bConnect
end

function TcpLogin:connect()
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

function TcpLogin:disconnect()
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

function TcpLogin:netEvent_Connected(event)
	if event.nettype ~= self.m_netType then
		return
	end

	release_print("tcpLogin ok")
	G_CommonFunc:removeLockLayer()
	self.bConnect = true
	if self.m_cbOk then
		self.m_cbOk()
	end
	self.m_cbFailed = nil
	self.m_cbOk = nil

	if self.schedule_warn then
    	scheduler:unscheduleScriptEntry(self.schedule_warn)
    	self.schedule_warn = nil
    end
    self.schedule_warn = scheduler:scheduleScriptFunc(handler(self,self.sendHeart),3,false)
end

function TcpLogin:netEvent_getData(event)
	if event.nettype ~= self.m_netType then
		return
	end

    local name, msg = self:unPackProtoMsg(event.data)
    G_Event:dispatchEvent({name="receiveMsg", msgName=name, msgData=msg})
end

function TcpLogin:netEvent_Close(event)
	if event.nettype ~= self.m_netType then
		return
	end

	release_print("tcpLogin close")
	G_CommonFunc:removeLockLayer()
	self.bConnect = false
	if self.m_cbFailed then
		self.m_cbFailed()
	end
	self.m_cbFailed = nil
	self.m_cbOk = nil
	if self.schedule_warn then
    	scheduler:unscheduleScriptEntry(self.schedule_warn)
    	self.schedule_warn = nil
    end
end

-- 发送心跳
function TcpLogin:sendHeart()
    G_NetManager:sendMsg(NETTYPE_LOGIN,"protocol.CG_HeartBeatReq", {ullTime = os.time()})
end

return TcpLogin
