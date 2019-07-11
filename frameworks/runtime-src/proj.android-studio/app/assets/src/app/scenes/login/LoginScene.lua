require("cocos/cocos2d/json")
require("cocos/network/NetworkConstants")
local LoginLayer = require("app.scenes.login.LoginLayer")

local LoginScene = class("LoginScene",G_BaseScene)

-- 创建
function LoginScene:onCreate()
    cc.Device:setKeepScreenOn(true)
    local curLayer = LoginLayer.create()
    self:addChild(curLayer)

    self.bWaitWxLogin = false
	math.randomseed(os.time())
end

-- 进入场景
function LoginScene:onEnter()
	self.target, self.event_requestLogin = G_Event:addEventListener("requestLogin", handler(self,self.requestLogin))
    self.wxCode = G_CommonFunc:addEvent("CUSTOMMSG_WXCODE", handler(self, self.sendwxCode))
end

-- 退出场景
function LoginScene:onExit()
    G_Event:removeEventListener(self.event_requestLogin)
    G_CommonFunc:removeEvent(self.wxCode)
end

-- 请求登陆
function LoginScene:requestLogin()
    local strHeadImg = cc.UserDefault:getInstance():getStringForKey("headimgurl","")
    ef.extensFunction:getInstance():httpForImg(strHeadImg, G_HeadImg, CUSTOMMSG_USERHEAD)
	
	self:sendLogin()
end

-- 帐号登陆(游客登陆)
function LoginScene:sendLogin()
	-- post json
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr:open("POST", "http://222.73.139.48:8080/login")
	local function loginCallback()
        if xhr.status == 200 then
		    local retMsg = json.decode(xhr.response)
            dump(retMsg, "sendLogin")
		    G_Data.UserBaseInfo = {
			    userid = 100,
			    nickname = "nickname",
			    headimgurl = "headimgurl",
			    sex = 1,
			    score = 50,
			    roomcard = 100,
		    }
		    G_Data.roomid = 0
		    G_SceneManager:enterScene(SCENE_LOBBY)
        else
            -- 登陆失败
		    local curLayer = G_WarnLayer.create()
            curLayer:setTips("登录失败")
            curLayer:setTypes(1)
            self:addChild(curLayer)
        end
	end
	xhr:registerScriptHandler(loginCallback)
	
	local msg = {
		account = "auto"..os.time()..math.random(),
		password = "password"..math.random(),
		nickname = "游客"..os.time()
	}
    dump(msg, "sendLogin")
	xhr:send(json.encode(msg))
end

-- 发送微信登陆code
function LoginScene:sendwxCode()
    -- 取得微信登陆code
    local code = cc.UserDefault:getInstance():getStringForKey("wx_code")
    local tCode = 
    {
        code = code
    }
    dump(tCode, "sendwxCode")
    -- post json
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr:open("POST", "http://222.73.139.48:8080/wx_login")
	local function reqCallback()
        if xhr.status == 200 then
            local retMsg = json.decode(xhr.response)
            dump(retMsg, "sendwxCode")
            G_Data.UserBaseInfo = 
            {
			    userid = 100,
			    nickname = retMsg.nickname,
			    headimgurl = retMsg.headimgurl,
			    sex = retMsg.sex,
			    score = 50,
			    roomcard = 100,
		    }
		    G_Data.roomid = 0
		    G_SceneManager:enterScene(SCENE_LOBBY)
        else
        end
	end
	xhr:registerScriptHandler(reqCallback)
	xhr:send(json.encode(tCode))
end

return LoginScene
