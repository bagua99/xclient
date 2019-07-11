local utils = require "utils"
local M = class("CommonFunc")
local network = require("componentex.network")
local cjson = require("componentex.cjson")
local crc = require "rcc"
local MsgLockLayer = require("app.common.MsgLockLayer")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local SmallTips = require("app.component.SmallTips")
local ScoreTips = require("app.component.ScoreTips")
local ZhuangTips = require("app.component.ZhuangTips")
local UserInfoTips = require("app.component.UserInfoTips")
local GeneralTips = require("app.component.GeneralTips")
local Loading = require("app.component.Loading")

local GameConfig                = require "app.config.GameConfig"
local EventConfig               = require ("app.config.EventConfig")

---------全局child的order和tag值，这个两个值全局对象会设置为相同的--------
local ZORDER_LOCKLAYER = 9999   --锁屏layer的优先级，锁屏layer一般用于发送消息在收到回的消息锁闭屏幕

function M:addEvent(p_msg,p_func)
	local curCustom = cc.EventListenerCustom:create(p_msg,p_func)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(curCustom,-1)
    return curCustom
end

function M:postEvent(p_msg)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local event = cc.EventCustom:new(p_msg)
    eventDispatcher:dispatchEvent(event) 
end

function M:removeEvent(p_listenr)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:removeEventListener(p_listenr) 
end

---------界面相关-------------
function M:addLockLayer()
	local curScene = display.getRunningScene()
	local curLayer = curScene:getChildByTag(ZORDER_LOCKLAYER)
	if curLayer then
		return
	else	
	   curLayer = MsgLockLayer.create()
	   curScene:addChild(curLayer,ZORDER_LOCKLAYER,ZORDER_LOCKLAYER)
	end
end

function M:removeLockLayer()
	local curScene = display.getRunningScene()
	curScene:removeChildByTag(ZORDER_LOCKLAYER)
end

---------网络http请求---------
function M:httpForUrl(strUrl,cb)
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

function M:httpForImg(strUrl, saveFileName, callBack, callBackData)
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", strUrl)
    local function onResult()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local file = io.open(saveFileName,"wb")
            file:write(xhr.response)
            file:close()

            if callBack then
        		callBack(callBackData,true)
        	end
        else
        	if callBack then
        		callBack(callBackData,false)
        	end
        end
        xhr:unregisterScriptHandler()
    end
	xhr:registerScriptHandler(onResult)
    xhr:send()
end

function M:httpForJsonPost(url, timeout, msg, callback, callfail, callnum)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr.timeout = timeout
	xhr:open("POST", url)
	local function reqCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
		    local retMsg = cjson.decode(utils.base64decode(xhr.response))
            callback(retMsg)
            xhr:unregisterScriptHandler()
        else
            xhr:unregisterScriptHandler()
            local nNum = callnum - 1
            if nNum > 0 then
                self:httpForJsonPost(url, timeout, msg, callback, callfail, nNum)
            else
                if callfail then
                    callfail()
                end
            end
        end
	end
	xhr:registerScriptHandler(reqCallback)
	
	local content = utils.base64encode(cjson.encode(msg))
	xhr:send(crc.hashhttp(content)..content)
end

function M:httpForJsonLobby(path, timeout, msg, callback, callfail)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr.timeout = timeout
	local content = utils.base64encode(cjson.encode(msg))
	xhr:open("GET", G_Data.lobby_host..path.."?data="..crc.hashhttp(content)..content)
	local function reqCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
		    local retMsg = cjson.decode(utils.base64decode(xhr.response))
            if callback then
                callback(retMsg)
            end
            xhr:unregisterScriptHandler()
        else
            xhr:unregisterScriptHandler()
            if callfail then
                callfail()
            end
        end
	end
	xhr:registerScriptHandler(reqCallback)
	xhr:send()
end

-- 截屏
function M:captureScreen(node, fileName)
    if node == nil or fileName == nil then
        return
    end

    local size = cc.Director:getInstance():getWinSize()
    local renderTexture = cc.RenderTexture:create(size.width, size.height)
    renderTexture:beginWithClear(0,0,0,0)
    node:visit()
    renderTexture:endToLua()
    renderTexture:saveToFile(fileName, cc.IMAGE_FORMAT_PNG ,true)
end

-- 获取IP
function M:getProxyIP()
    local nIndex = cc.UserDefault:getInstance():getIntegerForKey("DNS_index", 0)
    local nListCount = #GameConfig.tDNSList
    if (nIndex == 0 or nIndex > nListCount) and nListCount > 0 then
        nIndex = math.random(1, nListCount)
        cc.UserDefault:getInstance():setIntegerForKey("DNS_index", nIndex)
        cc.UserDefault:getInstance():flush()
        G_Data.DNS_Index = nIndex
    else
        G_Data.DNS_Index = nIndex
    end
    if EventConfig.CHECK_IOS then
        if nIndex > 0 then
            local tDNSList = GameConfig.tDNSList[nIndex]
            local nStrIndex = math.random(1, #tDNSList)
            G_Data.strProxy = tDNSList[nStrIndex]
        end
    else
        if nIndex > 0 then
            local tDNSList = GameConfig.tDNSList[nIndex]
            local nStrIndex = math.random(1, #tDNSList)
            local result = socket.dns.getaddrinfo(tDNSList[nStrIndex])
            if result ~= nil then
                for k, v in ipairs(result) do
                    G_Data.strProxy = v.addr
                    break
                end
            end
        end
    end
end

function M:addKeyReleased(node)
    -- body
    local function onKeyReleased(keyCode, event)    
        if keyCode == cc.KeyCode.KEY_BACK then
            if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
                local args = {1}
                local sigs = "(I)V"
                local luaj = require "cocos.cocos2d.luaj"
                local className = "com/hnqp/pdkgame/AppActivity"
                local ok = luaj.callStaticMethod(className,"exit",args,sigs)
            end
        elseif keyCode == cc.KeyCode.KEY_BACKSPACE  then
            cc.Director:getInstance():endToLua()
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,node)
end

function M:resAsyncLoad(resouces,overCall)
    local number = #resouces
    local count = 0
    local function onComplete()
        count = count + 1 
        local res = resouces[count]
        if res.plist then cc.SpriteFrameCache:getInstance():addSpriteFrames(res.plist, res.img) end
        -- print("resloader complete ", res.img)
        if count >= number and overCall then
            overCall()
        end
    end
    for k,v in ipairs(resouces) do
        cc.Director:getInstance():getTextureCache():addImageAsync(v.img, onComplete)
    end
end

function M:showTips(str,node)
    local strShow = string.format(str,strInfo)
    local curLayer = G_WarnLayer.create()
    curLayer:setTips(strShow)
    curLayer:setTypes(2)
    node:addChild(curLayer)
end

function M:showSmallTips(number,node,pos,call)
    local tips = SmallTips.new(call)
    node:addChild(tips)
    tips:setPosition(pos)
    tips:setString(number)
end

function M:showScoreTips(number,node,pos)
    local tips = ScoreTips.new()
    node:addChild(tips)
    tips:setPosition(pos)
    tips:setString(number)
    return tips 
end

function M:showZhuangTips(str,node,pos,call)
    local tips = ZhuangTips.new(call)
    node:addChild(tips)
    tips:setPosition(pos)
    tips:setString(str)
    tips:setLocalZOrder(999)
end

function M:showUserInfo(info,node)
    local tips = UserInfoTips.new(info)
    node:addChild(tips)
    tips:setLocalZOrder(999)
end

function M:loading(info,node)
    local tips = Loading.new(info)
    node:addChild(tips)
    tips:setLocalZOrder(999)
    self.loading_ = tips
end

function M:dismissLoading()
    if self.loading_ then 
        self.loading_:removeFromParent()
        self.loading_ = nil 
    end
end

function M:showGeneralTips(gameId,str,node,pos)
    -- body
    local tips = GeneralTips.new(gameId,str)
    node:addChild(tips)
    tips:setLocalZOrder(999)
    tips:setPosition(pos)
end

function M:addClickSound()
    -- body
    local sound = "Music/btn_click.mp3"
    G_GameDeskManager.Music:playSound(sound,false)
end

function M:getHost()
    -- body
    dump("getHost")
    local socket = require("socket")
    function GetAdd(hostname)
        -- print(hostname)
        local ip, resolved = socket.dns.toip(hostname)
        local ListTab = {}
        if resolved.ip==nil then 
            return ListTab
        end 
        for k, v in ipairs(resolved.ip) do
            table.insert(ListTab, v)
        end
        return ListTab
    end
    local localhost = unpack(GetAdd('localhost'))
    local dnsName   = unpack(GetAdd(socket.dns.gethostname()))
    dump(localhost)
    return localhost,dnsName
end

function M:isIpv6(_domain)
    -- body
    if _domain==nil then 
        return false
    end 
    local socket = require("socket")
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

function M:runAction(endFrame,ActionID,gameId,baseNode,call)
    -- body
    local csb = string.format("res/%d/GameDesk/animation/Animation%d.csb",gameId,ActionID)
    local node = cc.CSLoader:createNode(csb)
    if node == nil then 
        return 
    end 
    node:addTo(baseNode)
    local action = cc.CSLoader:createTimeline(csb)
    if action == nil then 
        node:removeFromParent()
        return 
    end
    if call then 
        node:runAction(action)     
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end
            local str = frame:getEvent()
            if str == "finish" then 
                dump("call")
                call()
                node:removeFromParent()
            end 
        end
        action:setFrameEventCallFunc(onFrameEvent) 
    else 
        node:runAction(action)
    end
    dump(endFrame) 
    action:gotoFrameAndPlay(0,endFrame,false)
    --[[
    local endFrame = GameConfigManager.actions[GameConfigManager.actionsID.SHUNZI]
    G_CommonFunc:runAction(endFrame,GameConfigManager.actionsID.SHUNZI,self)
    --]]
end

function M:playAnimals(number,name,gameId,node)
    local cache = cc.SpriteFrameCache:getInstance()
    local plist = "res/"..gameId.."/GameDesk/animation/baozha.plist"
    cache:addSpriteFrames(plist)
    local img1 = string.format("%s%d.png",name,1)
    local sp = cc.Sprite:createWithSpriteFrameName(img1)
    sp:setPosition(display.cx,display.cy)
    local animFrames = {}
    for i = 1,number do 
        local frame = cache:getSpriteFrame( string.format("%s%d.png",name,i) )
        animFrames[i] = frame
    end
    local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.3)
    local seq = cc.Sequence:create(cc.Repeat:create(cc.Animate:create(animation),1),cc.CallFunc:create(function()
        -- body
        sp:removeFromParent()
        cache:removeSpriteFramesFromFile(plist)
    end))
    sp:runAction(seq)
    sp:addTo(node)
end

function M:showSuccessAnimas(node,call)
    local cache = cc.SpriteFrameCache:getInstance()
    local plist = "res/plist/successAnimas.plist"
    cache:addSpriteFrames(plist)
    local img1 = "success1.png"
    local sp = cc.Sprite:createWithSpriteFrameName(img1)
    sp:setPosition(display.cx,display.cy)
    local animFrames = {}
    local number = 5 
    for i = 1,number do 
        local frame = cache:getSpriteFrame( string.format("%s%d.png","success",i) )
        animFrames[i] = frame
    end
    local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.3)
    local seq = cc.Sequence:create(cc.Repeat:create(cc.Animate:create(animation),1),cc.CallFunc:create(function()
        -- body
        sp:removeFromParent()
        cache:removeSpriteFramesFromFile(plist)
        if call then 
            call()
        end 
    end))
    sp:runAction(seq)
    sp:addTo(node)
end

-- 重启游戏
function M:startGame()
    G_SceneManager:start()
end

return M
