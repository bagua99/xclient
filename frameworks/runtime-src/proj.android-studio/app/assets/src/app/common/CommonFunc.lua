
local CommonFunc = class("CommonFunc")
local network = require("componentex.network")
local cjson = require("componentex.json")
local MsgLockLayer = require("app.common.MsgLockLayer")

function CommonFunc:addEvent(p_msg,p_func)
	local curCustom = cc.EventListenerCustom:create(p_msg,p_func)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(curCustom,-1)
    return curCustom
end

function CommonFunc:postEvent(p_msg)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local event = cc.EventCustom:new(p_msg)
    eventDispatcher:dispatchEvent(event) 
end

function CommonFunc:removeEvent(p_listenr)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:removeEventListener(p_listenr) 
end

---------界面相关-------------
function CommonFunc:addLockLayer()
	local curScene = display.getRunningScene()
	local curLayer = curScene:getChildByTag(ZORDER_LOCKLAYER)
	if curLayer then
		return
	else	
	   curLayer = MsgLockLayer.create()
	   curScene:addChild(curLayer,ZORDER_LOCKLAYER,ZORDER_LOCKLAYER)
	end
end

function CommonFunc:removeLockLayer()
	local curScene = display.getRunningScene()
	curScene:removeChildByTag(ZORDER_LOCKLAYER)
end

---------网络http请求---------
function CommonFunc:httpForUrl(strUrl,cb)
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", strUrl)
    release_print(strUrl)
    local function onReadyStateChanged()
    	
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local reponseTable = cjson.decode(xhr.response)
            if cb then
            	cb(reponseTable)
            end
        else
        	if cb then
        		cb(nil)
        	end
        end
        xhr:unregisterScriptHandler()
    end
	xhr:registerScriptHandler(onReadyStateChanged)
    xhr:send()
end

function CommonFunc:httpForImg(strUrl,cb)
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", strUrl)
    local function onReadyStateChanged2()
    	
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local headImg = cc.Image:new()
            headImg:initWithImageData(xhr.response,string.len(xhr.response))
            local strWritableFile = cc.FileUtils:getInstance():getWritablePath() + "myhead.png"
            headImg:saveToFile(strWritableFile)
            HEADIMG_HS = true
        else
        	if cb then
        		--cb(nil)
        	end
        end
        xhr:unregisterScriptHandler()
    end
	xhr:registerScriptHandler(onReadyStateChanged2)
    xhr:send()
end

return CommonFunc
