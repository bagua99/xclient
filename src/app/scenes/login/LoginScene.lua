require("cocos/network/NetworkConstants")
local crc                       = require "rcc"
local utils                     = require "utils"
local cjson 					= require("componentex.cjson")
local GameConfig                = require "app.config.GameConfig"
local EventConfig               = require ("app.config.EventConfig")
local LoginLayer                = require("app.scenes.login.LoginLayer")

local M = class("LoginScene", G_BaseScene)

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- 自动登陆
local bAutoLoginLogin = true

-- 创建
function M:onCreate()
    cc.Device:setKeepScreenOn(true)
    local curLayer = LoginLayer.create()
    self:addChild(curLayer)
end

-- 进入场景
function M:onEnter()
	self.target, self.event_GuestLogin = G_Event:addEventListener("requestGuestLogin", handler(self,self.requestGuestLogin))
    self.target, self.event_AccountLogin = G_Event:addEventListener("requestAccountLogin", handler(self,self.requestAccountLogin))
    self.wxCode = G_CommonFunc:addEvent("CUSTOMMSG_WXCODE", handler(self, self.wxCodeLogin))

    local refresh_time = cc.UserDefault:getInstance():getIntegerForKey("refresh_time", 0)
    local wx_account = cc.UserDefault:getInstance():getStringForKey("wx_account","")
    if bAutoLoginLogin and refresh_time >= os.time() and string.len(wx_account) ~= 0 then
        self:requestWxTmpLogin()
        G_CommonFunc:loading("游戏登录中...",self)
    end
end

-- 退出场景
function M:onExit()
    G_Event:removeEventListener(self.event_GuestLogin)
    G_Event:removeEventListener(self.event_AccountLogin)
    G_CommonFunc:removeEvent(self.wxCode)
end

-- 游客登陆
function M:requestGuestLogin()
    local account = cc.UserDefault:getInstance():getStringForKey("GuestLogin_account", "")
    local password = cc.UserDefault:getInstance():getStringForKey("GuestLogin_password", "")
    if #account == 0 or targetPlatform == cc.PLATFORM_OS_WINDOWS then
	    local msg = {time=os.time()}
	    self:requestLogin("http://"..G_Data.strProxy..":"..GameConfig.login_port.."/guest", msg)
    else
        local msg = {
		    account = account,
		    password = password,
	    }
	    self:requestLogin("http://"..G_Data.strProxy..":"..GameConfig.login_port.."/login", msg)
    end
end

-- 帐号登陆
function M:requestAccountLogin()
    local account = cc.UserDefault:getInstance():getStringForKey("AccountLogin_account", "")
    local password = cc.UserDefault:getInstance():getStringForKey("AccountLogin_password", "")
    if #account == 0 then
        self:sendRegister()
    else
	    local msg = {
		    account = account,
		    password = password,
	    }
	    self:requestLogin("http://"..G_Data.strProxy..":"..GameConfig.login_port.."/login", msg)
    end
end

-- 注册
function M:sendRegister()
	local msg = {
		account = "Test1000",
		password = "password",
		nickname = "云哥哥",
		sex = 1,
		headimgurl = ""
	}
	self:requestLogin("http://"..G_Data.strProxy..":"..GameConfig.login_port.."/register", msg)
end

-- 微信请求
function M:wxCodeLogin()
    local code = cc.UserDefault:getInstance():getStringForKey("wx_code")
    local msg = {code = code}
	self:requestLogin("http://"..G_Data.strProxy..":"..GameConfig.login_port.."/wx_login", msg)
end

-- 微信临时登陆请求
function M:requestWxTmpLogin()
    local account = cc.UserDefault:getInstance():getStringForKey("wx_account")
    local msg = {account = account}
	self:requestLogin("http://"..G_Data.strProxy..":"..GameConfig.login_port.."/wx_tmp_login", msg)
end

function M:requestLogin(url, msg)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
	xhr.timeout = 4
	local content = utils.base64encode(cjson.encode(msg))
	xhr:open("GET", url.."?data="..crc.hashhttp(content)..content)
	local function reqCallback()
        G_CommonFunc:dismissLoading()
        if xhr.status == 200 then
		    local retMsg = cjson.decode(utils.base64decode(xhr.response))
            self:onLoginResult(retMsg)
        end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(reqCallback)
	xhr:send()
end

function M:onLoginResult(msg)
    -- 帐号登陆
    if msg.openid == "0" then
        cc.UserDefault:getInstance():setStringForKey("AccountLogin_account", msg.account)
        cc.UserDefault:getInstance():setStringForKey("AccountLogin_password", msg.password)
        cc.UserDefault:getInstance():flush()
    elseif msg.openid == "1" then
        cc.UserDefault:getInstance():setStringForKey("GuestLogin_account", msg.account)
        cc.UserDefault:getInstance():setStringForKey("GuestLogin_password", msg.password)
        cc.UserDefault:getInstance():flush()
    -- 微信登陆
    elseif msg.refresh_time ~= nil then
        cc.UserDefault:getInstance():setIntegerForKey("refresh_time", msg.refresh_time)
        cc.UserDefault:getInstance():setStringForKey("wx_account", msg.account)
        cc.UserDefault:getInstance():flush()
    end
	G_Data.lobby_host = "http://"..G_Data.strProxy..":"..GameConfig.lobby_port
    G_Data.UserBaseInfo = msg
	G_Data.UserBaseInfo.headimgurl = utils.base64decode(msg.headimgurl)
	G_Data.roomid = 0
	G_Data.UserBaseInfo.userid = msg.userid
    G_Data.UserBaseInfo.unionid = msg.unionid
	G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end

return M
