local M = {}

function M:init()
	self.protobuf = require "app.net.protobuf"

	self:register_file("app.net.protocol_pb")
end

function M:register_file(file)
	self.protobuf:register_file(file)
end

function M:encode(name, msg)
	return self.protobuf:encode(name, msg)
end

function M:decode(name, data)
	return self.protobuf:decode(name, data)
end

return M