--[[
For quick-cocos2d-x
SocketTCP lua
@author zrong (zengrong.net)
Creation: 2013-11-12
Last Modification: 2013-12-05
@see http://cn.quick-x.com/?topic=quickkydsocketfzl
2016.6.28 merget Yue's change, add ipv6 support
]]

local M = class("SocketTCP")

local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

M.EVENT_DATA = "SOCKET_TCP_DATA"
M.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
M.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
M.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
M.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

local scheduler =  cc.Director:getInstance():getScheduler()

function M.getTime()
	return socket.gettime()
end

function M:ctor(__host, __port)
    self.host = __host
    self.port = __port
	self.name = 'SocketTCP'
	self.tcp = nil
	self.nettype = nil
    self.isConnected = false

	self.connectTimeTickScheduler = nil	-- timer for connect timeout
    self.tickScheduler = nil			-- timer for data

	self.last = ""
	self.packList = {}
end

function M:setName(__name)
	self.name = __name
	return self
end

function M:setReconnTime(__time)
	SOCKET_RECONNECT_TIME = __time
	return self
end

function M:setConnFailTime(__time)
	SOCKET_CONNECT_FAIL_TIMEOUT = __time
	return self
end

local function isIpv6(_domain)
    local result = socket.dns.getaddrinfo(_domain)
    if result then
        for k,v in pairs(result) do
            return v.family == "inet6"
        end
    end
    return false
end

function M:connect(__host, __port)
	local isIPv6_ = false 
	if __host then
        self.host = __host
    end
	if __port then
        self.port = __port
    end
	assert(self.host or self.port, "Host and port are necessary!")

	if isIpv6(self.host) then
		print("ipv6")
		isIPv6_ = true
		self.tcp = socket.tcp6()
	else
		print("ipv4")
		isIPv6_ = false 
		self.tcp = socket.tcp()
	end
	self.tcp:settimeout(0)

	if not self:_checkConnect() then
		if self.connectTimeTickScheduler then
            scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler)
        end
		self.connectTimeTickScheduler = scheduler:scheduleScriptFunc(handler(self, self._connectTimeTick), 0, false)
	end
	return isIPv6_
end

function M:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	self.tcp:send(__data)
end

function M:setNetType(__type)
	self.nettype = __type
end

function M:close( ... )
	self.tcp:close()

	if self.connectTimeTickScheduler then
        scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler)
        self.connectTimeTickScheduler = nil
    end

	if self.tickScheduler then
        scheduler:unscheduleScriptEntry(self.tickScheduler)
        self.tickScheduler = nil
    end

	G_Event:dispatchEvent({name=self.EVENT_CLOSE, nettype = self.nettype})
end

function M:_errClose()
	self:close()
    if self.isConnected then
    	self:_disconnect()
    else
    	self:_connectFailure()
    end
end

function M:isConnect()
	return self.isConnected
end

function M:_disconnect()
    if self.connectTimeTickScheduler then
        scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler)
        self.connectTimeTickScheduler = nil
    end

	if self.tickScheduler then
        scheduler:unscheduleScriptEntry(self.tickScheduler)
        self.tickScheduler = nil
    end

    self.isConnected = false
    G_Event:dispatchEvent({name=self.EVENT_CLOSED, nettype = self.nettype})

    self.tcp:shutdown()
end

function M:_checkConnect()
	local __succ = self:_connect()
	if __succ then
		self:_onConnected()
	end
	return __succ
end

function M:_connectTimeTick(dt)
	if self.isConnected then
        return
    end

	self.waitConnect = self.waitConnect or 0
	self.waitConnect = self.waitConnect + dt
	if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
		self.waitConnect = nil
		self:close()
		self:_connectFailure()
	end
	self:_checkConnect()
end

function M:_recvOnce()
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

function M:_splitPack()
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
        table.insert(self.packList, last:sub(3, 2 + len))
        last = last:sub(3 + len) or ""
    until(false)
	self.last = last
end

function M:_tick(dt)
	if not self:_recvOnce() then
		return
	end
	
	self:_splitPack()
	
	for i=1,#self.packList do
		local data = table.remove(self.packList, 1)
		G_Event:dispatchEvent({name=self.EVENT_DATA, data = data, nettype=self.nettype})
	end
end

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function M:_connect()
	local __succ, __status = self.tcp:connect(self.host, self.port)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

-- connecte success, cancel the connection timerout timer
function M:_onConnected()
	self.isConnected = true
	G_Event:dispatchEvent({name=self.EVENT_CONNECTED, nettype = self.nettype})
    -- 关闭连接超时
	if self.connectTimeTickScheduler then
        scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler)
        self.connectTimeTickScheduler = nil
    end	
	-- start to read TCP data
	self.tickScheduler = scheduler:scheduleScriptFunc(handler(self, self._tick), 0, false)
end

function M:_connectFailure(status)
	G_Event:dispatchEvent({name=self.EVENT_CONNECT_FAILURE, nettype = self.nettype})
end

return M
