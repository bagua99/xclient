--[[
For quick-cocos2d-x
SocketTCP lua
@author zrong (zengrong.net)
Creation: 2013-11-12
Last Modification: 2013-12-05
@see http://cn.quick-x.com/?topic=quickkydsocketfzl
2016.6.28 merget Yue's change, add ipv6 support
]]
local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local scheduler =  cc.Director:getInstance():getScheduler()

local byteArray = require("componentex.ByteArray")
local SocketTCP = class("SocketTCP")

SocketTCP.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTCP.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTCP.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTCP.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

function SocketTCP.getTime()
	return socket.gettime()
end

function SocketTCP:ctor(__host, __port, __retryConnectWhenFailure)
	
    self.host = __host
    self.port = __port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.name = 'SocketTCP'
	self.tcp = nil
	self.isRetryConnect = __retryConnectWhenFailure
	self.isConnected = false
	self.m_netType = nil
	self.m_tbSend = {}
	self.last = ""
	self.m_packList = {}
end

function SocketTCP:setName( __name )
	self.name = __name
	return self
end

function SocketTCP:setReconnTime(__time)
	SOCKET_RECONNECT_TIME = __time
	return self
end

function SocketTCP:setConnFailTime(__time)
	SOCKET_CONNECT_FAIL_TIMEOUT = __time
	return self
end

local function isIpv6(_domain)
    local result = socket.dns.getaddrinfo(_domain)
    local ipv6 = false
    if result then
        for k,v in pairs(result) do
            if v.family == "inet6" then
                ipv6 = true
                break
            end
        end
    end
    return ipv6
end

function SocketTCP:connect(__host, __port, __retryConnectWhenFailure)

	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")
	if isIpv6(self.host) then
		self.tcp = socket.tcp6()
	else
		self.tcp = socket.tcp()
	end
	self.tcp:settimeout(0)

	if not self:_checkConnect() then
		if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end
		self.connectTimeTickScheduler = scheduler:scheduleScriptFunc(handler(self, self._connectTimeTick),0,false)
	end
end

function SocketTCP:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	self.tcp:send(__data)
end

function SocketTCP:setNetType(__type)
	self.m_netType = __type
end

function SocketTCP:close( ... )
	self.tcp:close()
	if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler:unscheduleScriptEntry(self.tickScheduler) end
	G_Event:dispatchEvent({name=SocketTCP.EVENT_CLOSE,nettype = self.m_netType})
end

function SocketTCP:_errClose()
	self:close()
    if self.isConnected then
    	self:_onDisconnect()
    else
    	self:_connectFailure()
    end
end

function SocketTCP:isConnect()
	return self.isConnected
end

-- disconnect on user's own initiative.
function SocketTCP:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

function SocketTCP:_checkConnect()
	local __succ = self:_connect()
	if __succ then
		self:_onConnected()
	end
	return __succ
end

function SocketTCP:getFlagLen(strFlag)
	if strFlag == "p" or strFlag == "P" then
		return 1
	elseif strFlag == "i" or strFlag == "I" then
		return 4
    elseif strFlag == "l" or strFlag == "L" then
		return 8
	elseif strFlag == "a" then
		return 1
	elseif strFlag == "h" or strFlag == "H" then
		return 2
	elseif strFlag == "b" then
		return 1
	elseif strFlag == "c" or strFlag == "C" then
		return 1
	elseif strFlag == "s" then
		return 1
	else
		release_print("no find flag "..strFlag)
	end
end

function SocketTCP:_connectTimeTick(dt)

	if self.isConnected then return end
	self.waitConnect = self.waitConnect or 0
	self.waitConnect = self.waitConnect + dt
	if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
		self.waitConnect = nil
		self:close()
		self:_connectFailure()
	end
	self:_checkConnect()
end

function SocketTCP:_recv()
	local __body, __status, __partial = self.tcp:receive(self.m_iNeedRecvLen - self.m_iLen)	-- read the package body
    if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
    	
   		return false
	end
	
	return true
end

function SocketTCP:_recvOnce()
	-- 读包头,两字节长度
	if #self.last < 2 then
		local r, s = self.tcp:receive(2 - #self.last)
		if s == STATUS_CLOSED or s == STATUS_NOT_CONNECTED then
			self:_errClose()
			return false
		end
			
		if not r then
			return false
		end
		
		self.last = self.last .. r
		if #self.last < 2 then
			return
		end
	end
	
	local len = self.last:byte(1) * 256 + self.last:byte(2)
	
	local r, s = self.tcp:receive(len + 2 - #self.last)
	if s == STATUS_CLOSED or s == STATUS_NOT_CONNECTED then
		self:_errClose()
		return false
	end
	
	if not r then
		return false
	end
	
	self.last = self.last .. r
	if #self.last < 2 then
		return false
	end
	
	return true
end

function SocketTCP:_splitPack()
	local last = self.last
    local len
    repeat
        if #last < 2 then
            break
        end
        len = last:byte(1) * 256 + last:byte(2)
        if #last < len + 2 then
            break
        end
        table.insert(self.m_packList, last:sub(3, 2 + len))
        last = last:sub(3 + len) or ""
    until(false)
	self.last = last
end

function SocketTCP:_tick(dt)
	if #self.m_tbSend  > 0 then
		self.tcp:send(self.m_tbSend[1])
		table.remove(self.m_tbSend,1)
	end

	if not self:_recvOnce() then
		return
	end
	
	self:_splitPack()
	
	for i=1,#self.m_packList do
		local data = table.remove(self.m_packList, 1)
		G_Event:dispatchEvent({name=SocketTCP.EVENT_DATA, data = data, nettype=self.m_netType})
	end
end

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function SocketTCP:_connect()

	local __succ, __status = self.tcp:connect(self.host, self.port)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function SocketTCP:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	G_Event:dispatchEvent({name=SocketTCP.EVENT_CLOSED,nettype = self.m_netType})
end

function SocketTCP:_onDisconnect()
	self.isConnected = false
	G_Event:dispatchEvent({name=SocketTCP.EVENT_CLOSED,nettype = self.m_netType})
	self:_reconnect()
end

-- connecte success, cancel the connection timerout timer
function SocketTCP:_onConnected()
	self.isConnected = true
	G_Event:dispatchEvent({name=SocketTCP.EVENT_CONNECTED,nettype = self.m_netType})
	if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end	
	-- start to read TCP data
	self.tickScheduler = scheduler:scheduleScriptFunc(handler(self, self._tick),0,false)
end

function SocketTCP:_connectFailure(status)
	G_Event:dispatchEvent({name=SocketTCP.EVENT_CONNECT_FAILURE,nettype = self.m_netType})
	self:_reconnect()
end

-- if connection is initiative, do not reconnect
function SocketTCP:_reconnect(__immediately)
	if not self.isRetryConnect then return end
	if __immediately then self:connect() return end
	if self.reconnectScheduler then scheduler:unscheduleScriptEntry(self.reconnectScheduler) end
	local __doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler:scheduleScriptFunc(__doReConnect, SOCKET_RECONNECT_TIME,false)
end

return SocketTCP