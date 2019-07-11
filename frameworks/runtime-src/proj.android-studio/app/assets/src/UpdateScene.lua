
-- 原理：每次登陆游戏利用cocos的AssetsManagerEx从服务器拉去当前最新的两个文件。 
-- 一个是version.mainifest,一个project.mainifest. 这两个文件都是xml的描述文件。
-- 一个包含了版本信息，第二个包含了游戏所有资源的MD5码。首先通过version文件对比本地的版本是否相同，
-- 如果不相同，再通过跟本地的project文件对比MD5码来判断哪些文件需要重新下载，替换资源。 

local UpdateScene = class("UpdateScene",function()
	return display.newScene("UpdateScene")
end)

function UpdateScene:ctor()
    self:onNodeEvent("exit", handler(self, self.onExitCallback))
    self:initUI()
    self:setAssetsManage()
end

function UpdateScene:onExitCallback()
    self.assetsManagerEx:release()
end

function UpdateScene:initUI()
    --背景图
    local bg = display.newSprite("Login/DL_BJ.png")
    bg:setPosition(display.center)
    self:addChild(bg)

    --进度条背景
    local progressbg = display.newSprite("Login/updateLoadingBg.png")
    progressbg:setAnchorPoint(cc.p(0.5,0.5)) 
    progressbg:setPosition(cc.p(display.center.x, 100))
    self:addChild(progressbg)  
    progressbg:setTag(10)
    local progressBgSize = progressbg:getContentSize() 

     --创建进度条  
    self.updateProgress = cc.ProgressTimer:create(cc.Sprite:create("Login/updateLoadingProgress.png"))  
    self.updateProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL  
    self.updateProgress:setMidpoint(cc.p(0,1)) --设置起点 从左到右
    self.updateProgress:setBarChangeRate(cc.p(1,0))  --设置为方向 水平 
    self.updateProgress:setPercentage(0) -- 设置初始进度为30  
    self.updateProgress:setPosition(cc.p(progressBgSize.width/2,progressBgSize.height/2))  
    progressbg:addChild(self.updateProgress)

    --更新资源文件提示
    self.implyLabel = cc.Label:createWithSystemFont("正在下载中...", "Arial", 30)
    self.implyLabel:setAnchorPoint(cc.p(0,0))
    self.implyLabel:setPosition(progressbg:getPositionX()-progressBgSize.width/2,
        progressbg:getPositionY()+progressBgSize.height/2+10)
    self:addChild(self.implyLabel)

    self.updateProgress:setVisible(false)
    self.implyLabel:setVisible(false)
    progressbg:setVisible(false)
end

function UpdateScene:setAssetsManage()
    --创建可写目录与设置搜索路径
    local storagePath = cc.FileUtils:getInstance():getWritablePath() .. "update" 
    print("storagePath->",storagePath)
    local resPath = storagePath.. '/res/'
    local srcPath = storagePath.. '/src/'
    if not (cc.FileUtils:getInstance():isDirectoryExist(storagePath)) then         
        cc.FileUtils:getInstance():createDirectory(storagePath)
        cc.FileUtils:getInstance():createDirectory(resPath)
        cc.FileUtils:getInstance():createDirectory(srcPath)
    end
    local searchPaths = cc.FileUtils:getInstance():getSearchPaths() 
    table.insert(searchPaths, 1, storagePath)  
    table.insert(searchPaths, 2, resPath)
    table.insert(searchPaths, 3, srcPath)
    cc.FileUtils:getInstance():setSearchPaths(searchPaths)

    self.assetsManagerEx = cc.AssetsManagerEx:create("res/version/project.manifest", storagePath)    
    self.assetsManagerEx:retain()

    local eventListenerAssetsManagerEx = cc.EventListenerAssetsManagerEx:create(self.assetsManagerEx, 
       function (event)
           self:handleAssetsManagerEvent(event)
       end)

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithFixedPriority(eventListenerAssetsManagerEx, 1)

    --检查版本并升级
    self.assetsManagerEx:update()
end

function UpdateScene:handleAssetsManagerEvent(event)    
    local eventCodeList = cc.EventAssetsManagerEx.EventCode    

    local eventCodeHand = {

        [eventCodeList.ERROR_NO_LOCAL_MANIFEST] = function ()
            print("发生错误:本地资源清单文件未找到")
        end,

        [eventCodeList.ERROR_DOWNLOAD_MANIFEST] = function ()
            print("发生错误:远程资源清单文件下载失败")
            self:downloadManifestError()
        end,

        [eventCodeList.ERROR_PARSE_MANIFEST] = function ()
             print("发生错误:资源清单文件解析失败")
        end,

        [eventCodeList.NEW_VERSION_FOUND] = function ()
            print("发现找到新版本")
        end,

        [eventCodeList.ALREADY_UP_TO_DATE] = function ()
            print("已经更新到服务器最新版本")            
            self:updateFinished()
        end,

        [eventCodeList.UPDATE_PROGRESSION]= function ()
            print("更新过程的进度事件->",event:getPercentByFile())
            --self.progress:setPercentage(event:getPercentByFile())

            local assetId = event:getAssetId()  
            local percent = event:getPercent()  
            local strInfo = ""  
            if assetId == cc.AssetsManagerExStatic.VERSION_ID then  
                strInfo = string.format("Version file: %d%%", percent)  
            elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then  
                strInfo = string.format("Manifest file: %d%%", percent)  
            else  
                percent = event:getPercentByFile()
                strInfo = string.format("%d%%", percent) 
                self.updateProgress:setPercentage(percent)
                if percent > 0 then
                    if not self.updateProgress:isVisible() then
                        self.updateProgress:setVisible(true)
                        self.implyLabel:setVisible(true)
                        local progressbg = self:getChildByTag(10)
                        if progressbg ~= nil then
                            progressbg:setVisible(true)
                        end
                    end
                end

            end  
            print("strInfo->",strInfo)
            
        end,

        [eventCodeList.ASSET_UPDATED] = function ()
            print("单个资源被更新事件")
        end,

        [eventCodeList.ERROR_UPDATING] = function ()
            print("发生错误:更新过程中遇到错误")
        end,

        [eventCodeList.UPDATE_FINISHED] = function ()
            print("更新成功事件")
            self:updateFinished()
        end,

        [eventCodeList.UPDATE_FAILED] = function ()
            print("更新失败事件")
            self:downloadManifestError()
        end,

        [eventCodeList.ERROR_DECOMPRESS] = function ()
            print("解压缩失败")
        end
    }
    local eventCode = event:getEventCode()    
    if eventCodeHand[eventCode] ~= nil then
        eventCodeHand[eventCode]()
    end  
end

function UpdateScene:updateFinished()
    self:enterLoginScene()
end

function UpdateScene:downloadManifestError()
    self:enterLoginScene()
end

function UpdateScene:enterLoginScene()
    require("GameManager").create():start()
end

return UpdateScene