
-- 原理：每次登陆游戏利用cocos的AssetsManagerEx从服务器拉去当前最新的两个文件。
-- 一个是version.mainifest,一个project.mainifest. 这两个文件都是xml的描述文件。
-- 一个包含了版本信息，第二个包含了游戏所有资源的MD5码。首先通过version文件对比本地的版本是否相同，
-- 如果不相同，再通过跟本地的project文件对比MD5码来判断哪些文件需要重新下载，替换资源。

local dispatcher                = cc.Director:getInstance():getEventDispatcher()
local targetPlatform            = cc.Application:getInstance():getTargetPlatform()

local M = class("UpdateScene",function()
	return display.newScene("UpdateScene")
end)

function M:ctor()
    -- 文件下载错误数量
    self.nErrorCount = 0
    -- 文件下载成功数量
    self.nSucceedCount = 0
    -- 总文件数量
    self.nAllCount = 0
    -- 失败重现下载次数
    self.nDownloadErrorCount = 0
    self:onNodeEvent("enter", handler(self, self.onEnterCallback))
    self:onNodeEvent("exit", handler(self, self.onExitCallback))
end

function M:onEnterCallback()
    self:initUI()
    self:setSearchPaths()
    self:checkNeedUpdate()
end

function M:onExitCallback()
    if self.assetsManagerEx then
        self.assetsManagerEx:release()
        self.assetsManagerEx = nil
    end

    if self.eventListenerAssetsManagerEx then
        dispatcher:removeEventListener(self.eventListenerAssetsManagerEx)
        self.eventListenerAssetsManagerEx = nil
    end
end

function M:initUI()
    --背景图
    if self.bg == nil then
        self.bg = display.newSprite("Login/DL_BJ.png")
        self.bg:setPosition(display.center)
        self:addChild(self.bg)
    end

    --进度条背景
    if self.progressbg == nil then
        self.progressbg = display.newSprite("Common/updateLoadingBg.png")
        self.progressbg:setAnchorPoint(cc.p(0.5,0.5))
        self.progressbg:setPosition(cc.p(display.center.x, 100))
        self:addChild(self.progressbg)
    end
    local progressBgSize = self.progressbg:getContentSize()
     --创建进度条
    if self.updateProgress == nil then
        self.updateProgress = cc.ProgressTimer:create(cc.Sprite:create("Common/updateLoadingProgress.png"))
        self.updateProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL
        self.updateProgress:setMidpoint(cc.p(0,1)) --设置起点 从左到右
        self.updateProgress:setBarChangeRate(cc.p(1,0))  --设置为方向 水平
        self.updateProgress:setPercentage(0) -- 设置初始进度为30
        self.updateProgress:setPosition(cc.p(progressBgSize.width/2,progressBgSize.height/2))
        self.progressbg:addChild(self.updateProgress)
    end

    --更新资源文件提示
    if self.implyLabel == nil then
        self.implyLabel = cc.Label:createWithSystemFont("更新资源中...", "res/commonfont/ZYUANSJ.TTF", 30)
        self.implyLabel:setAnchorPoint(cc.p(0,0))
        self.implyLabel:setPosition(self.progressbg:getPositionX()-progressBgSize.width/2,
            self.progressbg:getPositionY()+progressBgSize.height/2+10)
        self:addChild(self.implyLabel)
    end

    self.updateProgress:setVisible(false)
    self.implyLabel:setVisible(false)
    self.progressbg:setVisible(false)
end

function M:setSearchPaths()
    self.storagePath = cc.FileUtils:getInstance():getWritablePath() .. "update"
    local resPath = self.storagePath.. '/res/'
    local srcPath = self.storagePath.. '/src/'
    if not (cc.FileUtils:getInstance():isDirectoryExist(self.storagePath)) then
        cc.FileUtils:getInstance():createDirectory(self.storagePath)
        cc.FileUtils:getInstance():createDirectory(resPath)
        cc.FileUtils:getInstance():createDirectory(srcPath)
    end
end

function M:checkNeedUpdate()
    local checkFunc = function(versoinFile)
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
        xhr:setRequestHeader("Content-Type", "application/json")
        xhr.timeout = 3
        xhr:open("POST", versoinFile)
        local function reqCallback()
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local retMsg = json.decode(xhr.response)
                local isNeed = retMsg.isNeed
                if isNeed == 1 then
                    self:setAssetsManage()
                else
                    self:enterLoginScene()
                end
            else
                self:enterLoginScene()
            end
            xhr:unregisterScriptHandler()
        end
        xhr:registerScriptHandler(reqCallback)
        xhr:send()
    end

    if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform or cc.PLATFORM_OS_MAC == targetPlatform then
        local versoinFile = "http://hotfix.59iwan.cn/update/ios/assets/version/update.manifest"
        checkFunc(versoinFile)
    elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
        local versoinFile = "http://hotfix.59iwan.cn/update/android/assets/version/update.manifest"
        checkFunc(versoinFile)
    else
        --直接进入
        self:enterLoginScene()
    end
end

function M:setAssetsManage()
    if self.assetsManagerEx then
        self.assetsManagerEx:release()
        self.assetsManagerEx = nil
    end
    self.assetsManagerEx = cc.AssetsManagerEx:create("project.manifest", self.storagePath)
    self.assetsManagerEx:retain()

    if self.eventListenerAssetsManagerEx then
        dispatcher:removeEventListener(self.eventListenerAssetsManagerEx)
        self.eventListenerAssetsManagerEx = nil
    end
    self.eventListenerAssetsManagerEx = cc.EventListenerAssetsManagerEx:create(self.assetsManagerEx, 
       function (event)
           self:handleAssetsManagerEvent(event)
       end)
    dispatcher:addEventListenerWithFixedPriority(self.eventListenerAssetsManagerEx, 1)

    --检查版本并升级
    self.assetsManagerEx:update()
end

function M:handleAssetsManagerEvent(event)
    local eventCodeList = cc.EventAssetsManagerEx.EventCode

    local eventCodeHand = {

        [eventCodeList.ERROR_NO_LOCAL_MANIFEST] = function ()
            print("error ERROR_NO_LOCAL_MANIFEST")
        end,

        [eventCodeList.ERROR_DOWNLOAD_MANIFEST] = function ()
            print("error ERROR_DOWNLOAD_MANIFEST")
        end,

        [eventCodeList.ERROR_PARSE_MANIFEST] = function ()
             print("error ERROR_PARSE_MANIFEST")
        end,

        [eventCodeList.NEW_VERSION_FOUND] = function ()
            print("NEW_VERSION_FOUND")
        end,

        [eventCodeList.ALREADY_UP_TO_DATE] = function ()
            print("ALREADY_UP_TO_DATE")
            self:updateFinished()
        end,

        [eventCodeList.UPDATE_PROGRESSION] = function ()
            local assetId = event:getAssetId()
            local strInfo = ""
            if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                strInfo = string.format("Version file: %d%%", event:getPercent())
            elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then  
                strInfo = string.format("Manifest file: %d%%", event:getPercent())
            else
                self.nSucceedCount = self.nSucceedCount + 1

                if self.nAllCount == 0 then
                    local percent = event:getPercentByFile()
                    if percent > 0 then
                        local nAllCount = (self.nSucceedCount + self.nErrorCount) * 100 / percent
                        if nAllCount > 0 then
                            local nCurrentPercent = self.nSucceedCount / nAllCount * 100
                            self.updateProgress:setPercentage(nCurrentPercent)
                            strInfo = "UPDATE_PROGRESSION->"..nCurrentPercent.."%"
                        end
                    end
                else
                    if self.nAllCount > 0 then
                        local nCurrentPercent = self.nSucceedCount / self.nAllCount * 100
                        self.updateProgress:setPercentage(nCurrentPercent)
                        strInfo = "UPDATE_PROGRESSION->"..nCurrentPercent.."%"
                    end
                end
                if not self.updateProgress:isVisible() then
                    self.updateProgress:setVisible(true)
                    self.implyLabel:setVisible(true)
                    self.progressbg:setVisible(true)
                end
            end
            print(strInfo)
        end,

        [eventCodeList.ASSET_UPDATED] = function ()
            print("ASSET_UPDATED")
        end,

        [eventCodeList.ERROR_UPDATING] = function ()
            print("error ERROR_UPDATING")
            self.nErrorCount = self.nErrorCount + 1
        end,

        [eventCodeList.UPDATE_FINISHED] = function ()
            print("UPDATE_FINISHED")
            self:updateFinished()
        end,

        [eventCodeList.UPDATE_FAILED] = function ()
            print("error UPDATE_FAILED")
            self:downloadUpdateError()
        end,

        [eventCodeList.ERROR_DECOMPRESS] = function ()
            print("error ERROR_DECOMPRESS")
        end
    }
    local eventCode = event:getEventCode()
    if eventCodeHand[eventCode] ~= nil then
        eventCodeHand[eventCode]()
    end
end

function M:updateFinished()
    self:enterLoginScene()
end

function M:downloadUpdateError()
    if self.nDownloadErrorCount == 0 then
        self.nAllCount = self.nSucceedCount + self.nErrorCount
    end
    self.nDownloadErrorCount = self.nDownloadErrorCount + 1
    self.nErrorCount = 0
    self.assetsManagerEx:downloadFailedAssets()
end

function M:enterLoginScene()
    require("GameManager").create():start()
end

return M
