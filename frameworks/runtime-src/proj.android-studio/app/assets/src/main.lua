
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("res/Music/")

require "config"
require "cocos.init"

require "app.config.eventConfig"
require "app.config.otherConfig"
require "app.data.protocol"

local function main()

    IS_UPDATE_VERSION = false
    if IS_UPDATE_VERSION == true then
	    cc.Device:setKeepScreenOn(true)
	    display.runScene(require("UpdateScene"):create(),nil,0.3,display.COLOR_WHITE)
    else
        require("GameManager").create():start()
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
