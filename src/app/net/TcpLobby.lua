local scheduler =  cc.Director:getInstance():getScheduler()
local SocketTCP             = require("componentex.SocketTCP")

local M = class("TcpLobby", G_BaseTcp)

function M:onCreate()
	self.nettype = NETTYPE_LOGIN
	self.bConnect = false
	self._socket:setNetType(NETTYPE_LOGIN)
end

function M:connectServer(strIp,strPort,cbOk,cbFailed)
	release_print(strIp)
	release_print(strPort)
	self.m_cbOk = cbOk
	self.m_cbFailed = cbFailed
	G_CommonFunc:addLockLayer()
	self:_remove_event_handler()
	self:_add_event_handler()
	if self.bConnect then
		local curEvent = {}
		curEvent.nettype = self.nettype
		self:netEvent_Connected(curEvent)
	else
		print("**connect**")
		self._socket:connect(strIp,strPort)
	end
end

function M:_add_event_handler()
	self.target, self.event_connect = G_Event:addEventListener(SocketTCP.EVENT_CONNECTED,handler(self,self.netEvent_Connected))
	self.target, self.event_getdata = G_Event:addEventListener(SocketTCP.EVENT_DATA ,handler(self,self.netEvent_getData))
	self.target, self.event_close = G_Event:addEventListener(SocketTCP.EVENT_CLOSED,handler(self,self.netEvent_Close))
end

function M:_remove_event_handler()
	if self.event_connect ~= nil then
        G_Event:removeEventListener(self.event_connect)
		self.event_connect = nil
    end
    if self.event_getdata ~= nil then
        G_Event:removeEventListener(self.event_getdata)
		self.event_getdata = nil
    end
    if self.event_close ~= nil then
        G_Event:removeEventListener(self.event_close)
		self.event_close = nil
    end
end

function M:disconnect()
	if self._socket:isConnect() then
		self._socket:_disconnect()
	end

	self:_remove_event_handler()
end

function M:netEvent_Connected(event)
	if event.nettype ~= self.nettype then
		return
	end

	release_print("tcpLobby ok")
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

function M:netEvent_getData(event)
	if event.nettype ~= self.nettype then
		return
	end

    local name, msg = self:unPackProtoMsg(event.data)
    G_Event:dispatchEvent({name="receiveLobbyMsg", msgName=name, msgData=msg})
end

function M:netEvent_Close(event)
	if event.nettype ~= self.nettype then
		return
	end

	release_print("tcpLobby close")
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
function M:sendHeart()
    G_NetManager:sendMsg(NETTYPE_LOGIN,"protocol.HeartBeatReq", {time = os.time()})
end

return M
