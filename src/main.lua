
cc.FileUtils:getInstance():setPopupNotify(false)

local writePath = cc.FileUtils:getInstance():getWritablePath()
local resSearchPaths = {
    writePath .. "update/",
	writePath .. "update/src/",
    writePath .. "update/res/",
	"src/",
	"res/",
}
cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)

require "config"
require "cocos.init"

local function main()
	cc.Device:setKeepScreenOn(true)
	display.runScene(require("UpdateScene"):create(),nil,0.3,display.COLOR_WHITE)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
