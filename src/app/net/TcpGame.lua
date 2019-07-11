local M = class("TcpGame", G_BaseTcp)

-- 网络状态 
-- closed 
-- connecting
-- reconnecting
-- established
-- closing
local SocketTCP = require("componentex.SocketTCP")
local EventConfig = require ("app.config.EventConfig")
local scheduler =  cc.Director:getInstance():getScheduler()

function M:onCreate()
	self.nettype = EventConfig.NETTYPE_GAME
	self._socket:setNetType(EventConfig.NETTYPE_GAME)
	self.status = "closed"
	self.reconnect_count = 0
	self.reconnect_max_count = 0
	self.strIp = nil 
	self.strPort = nil 
	self:_add_event_handler()
	self.schedule_heartbeat = scheduler:scheduleScriptFunc(handler(self,self.sendHeart),3,false)
	self.schedule_check_heartbeat = scheduler:scheduleScriptFunc(handler(self,self.check_heartbeat),10,false)
end

-- 连接服务器
function M:connectServer(strIp, strPort, count, internal, cbOk, cbFailed)
	self:resetIndex()
	self.m_cbOk = cbOk
	self.m_cbFailed = cbFailed
	G_CommonFunc:addLockLayer()
	self.strIp = strIp
	self.strPort = strPort
	if self.status == "established" then
		self:on_connected({nettype = self.nettype})
		dump("重复连接服务器")
	else
		dump("开始连接服务器")
		if count > 1 then
			self.schedule_reconnect = scheduler:scheduleScriptFunc(handler(self,self.check_reconnect),internal,false)
			self.reconnect_count = 1
			self.reconnect_max_count = count
		end
		self.status = "connecting"
		self._socket:connect(strIp,strPort)
	end	
end

function M:check_reconnect()
	if self.status ~= "connecting" then
		return
	end
	self:resetIndex()
	self.reconnect_count = self.reconnect_count + 1
	dump("重连第"..self.reconnect_count.."次")
	self._socket:connect(self.strIp,self.strPort)
end

function M:_remove_reconnect_schedule()
	self.reconnect_count = 0
	self.reconnect_max_count = 0
	if self.schedule_reconnect then
    	scheduler:unscheduleScriptEntry(self.schedule_reconnect)
    	self.schedule_reconnect = nil
    end
end

-- 主动关闭连接
function M:disconnect()
	dump(debug.traceback())
	self.status = "closed"
	if self._socket:isConnect() then
		self._socket:_disconnect()
	end

    -- 移除重连
    self:_remove_reconnect_schedule()

    -- 移除事件
    self:_remove_event_handler()
end

function M:on_connected(event)
	if event.nettype ~= self.nettype then
		return
	end

	self:_remove_reconnect_schedule()

    G_GameDeskManager:netEvent_Connected(event)
	release_print("TcpGame ok")
	G_CommonFunc:removeLockLayer()
	self.status = "established"
	self.heartbeat = true
	if self.m_cbOk then
		self.m_cbOk()
	end
end

function M:on_connect_fail(event)
	if event.nettype ~= self.nettype then
		return
	end
	release_print("TcpGame failed")
	if self.reconnect_max_count == 0xFFFFFFFF or self.reconnect_count < self.reconnect_max_count then
		return
	end
	
	self.status = "closed"
	self:_remove_reconnect_schedule()
	self.m_cbFailed()
end

function M:netEvent_getData(event)
	if event.nettype ~= self.nettype then
		return
	end

    local name, msg = self:unPackProtoMsg(event.data)
	if name == "protocol.HeartBeatAck" then
		self.heartbeat = true
		return
	end
	G_GameDeskManager:netEvent_getMsg(name, msg)
end

function M:netEvent_Close(event)
	if event.nettype ~= self.nettype then
		return
	end
	
	if self.status == "connecting" then
		self:on_connect_fail(event)
		return
	end
	
	G_CommonFunc:removeLockLayer()
	if self.status == "closed" then
		return
	end
	
	self.status = "closed"
	print("sokcet断开---掉线了")
    self:_Offline()
end

-- 发送心跳
function M:sendHeart()
	if self.status ~= "established" then
		return
	end
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.HeartBeatReq", {time = os.time()})
end

-- 检查心跳
function M:check_heartbeat()
	if self.status ~= "established" then
		return
	end
	if self.heartbeat then
		self.heartbeat = false
		return
	end
	
	print("心跳检查---掉线了")
	self:disconnect()
	self:_Offline()
end

-- 掉线了
function M:_Offline()
	G_GameDeskManager:netEvent_offline()
end

function M:_add_event_handler()
	self.target, self.event_connect = G_Event:addEventListener(SocketTCP.EVENT_CONNECTED,handler(self,self.on_connected))
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

return M
