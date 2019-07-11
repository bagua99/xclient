
local M = class("GameDeskScene", G_BaseScene)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameDeskLayer             = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".game.GameDeskLayer")
local GameCardManager           = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".card.GameCardManager")
local SuccessLayer              = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".game.SuccessLayer")
local FailedLayer               = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".game.FailedLayer")
local TotalLayer                = require("app.scenes.gamedesk."..GameConfigManager.tGameID.DGNN..".game.TotalLayer")

local GameSetLayer              = require("app.scenes.lobby.GameSet.GameSetLayer")
local GameHelpLayer             = require("app.scenes.lobby.GameHelp.GameHelpLayer")
local GameChatLayer             = require("app.scenes.lobby.common.GameChatLayer")

local GameLeaveLayer            = require("app.scenes.lobby.common.GameLeaveLayer")
local GameVoteLayer             = require("app.scenes.lobby.common.GameVoteLayer")
local GameVoteNoticeLayer       = require("app.scenes.lobby.common.GameVoteNoticeLayer")

local EventConfig               = require ("app.config.EventConfig")

-- 创建
function M:onCreate()
	self.map_music = {}
    self.nTotalGameCount = 0
    self.nCurGameCount = 0
    self.nRoomID = 0
    self.pGameBalance = nil
    self.pGameOneOver = nil
	self.bDisovleGame = false
    self.nUserCount = G_GameDefine.nMaxPlayerCount
    self.wLastOutUser = 0
    self.wCurrentUser = 0
    self.tOutCardData = {}
    self.nOutCardCount = 0
    self.bEnd = false
    self.ullMasterID = 0
    self.tRoomInfo = {}
    self.isTotalConclude = false
    self.isShow = false  
    G_GameDefine.nGameStatus = G_GameDefine.game_free
	self.m_pGameEnd = nil
	self.m_pGameGameTotalEnd = nil
	cc.exports.G_DeskScene = self
    self:initView()
    G_GameDefine.nPlayerCount = 0
    G_GameDefine.nMaxPlayerCount = 5 

    G_Data.UserBaseInfo.isPlaying = false
    G_Data.UserBaseInfo.isOffLine = false

    self.shangZhuangBankerFlag = nil  --上庄BankerID
    self.xiaZhuangBankerFlag = nil    --下庄BankerID
    self.totalConcludeInfo = nil      --大结算的数据
    self.showSingleFlag = false       --单局结算
end

-- 初始视图
function M:initView()
	--桌面
	self.GameDeskLayer = GameDeskLayer.create()
	self:addChild(self.GameDeskLayer)

	--游戏牌管理类
	self.GameCardManager = GameCardManager.create()
	self:addChild(self.GameCardManager)

	self.GameChatLayer = GameChatLayer.create()
	self.GameChatLayer:setVisible(false)
	self:addChild(self.GameChatLayer)

    -- 离开
    self.GameLeaveLayer = GameLeaveLayer.create()
    self.GameLeaveLayer:setVisible(false)
    self:addChild(self.GameLeaveLayer, 100)

    -- 投票
    self.GameVoteLayer = GameVoteLayer.create()
    self.GameVoteLayer:setVisible(false)
    self:addChild(self.GameVoteLayer, 100)

    -- 投票信息
    self.GameVoteNoticeLayer = GameVoteNoticeLayer.create()
    self.GameVoteNoticeLayer:setVisible(false)
    self:addChild(self.GameVoteNoticeLayer, 110)
end

-- 场景进入
function M:onEnter()
	local music = "Music/"..GameConfigManager.tGameID.DGNN.."/nn_bg.mp3"
    G_Data.music = music
    G_GameDeskManager.Music:playBackMusic(music, true)

    if not G_Data.bReplay then
        -- 进入游戏请求
        G_GameDeskManager:EnterGameReq(G_Data.reconnect)
    else
        -- 回放准备数据
        self:replayPrepare()
    end
end

-- 场景退出
function M:onExit()
    -- 停止音乐
    G_GameDeskManager.Music:unloadSound()
	G_Data.roomid = 0
	G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
    G_Data.UserBaseInfo.isPlaying = false
    cc.exports.G_DeskScene = nil
    --remove图集
    local tPlist = GameConfigManager.tPlist[G_Data.gameid]
    local cache = cc.SpriteFrameCache:getInstance()
    for k,v in pairs(tPlist) do 
        local img = v.img 
        local plist = v.plist
        -- dump(plist)
        cache:removeSpriteFramesFromFile(plist)
    end 
end

-- 进入房间错误
function M:handleEnterError(iError)
	local curLayer = G_WarnLayer.create()
   	curLayer:setTypes(1)
    self:addChild(curLayer)
    if iError == 1 then
        curLayer:setTips("人数已满,加入房间失败!")
    elseif iError == 2 then
        curLayer:setTips("未找到该房间!")
    elseif iError == 3 then
        curLayer:setTips("此房间已经开始游戏!")
    elseif iError == 4 then
        curLayer:setTips("该房间座位已满!")
    else
        curLayer:setTips("未知的错误"..iError)
    end
end

function M:netEvent_Close(event)

end

-- 掉线了
function M:handle_Offline()
    if G_Data.roomid == 0 then
        return
    end
    -- 游戏状态执行 否则不执行
    G_Data.UserBaseInfo.isOffLine = true
    G_NetManager:connectGame(G_Data.room_ip,G_Data.room_port,handler(self,self.on_reconnect_success),handler(self,self.on_reconnect_fail),true)
end

-- 断线重连socket连上了
function M:on_reconnect_success()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
        G_GameDeskManager:EnterGameReq(true)
    end)))

end

-- 断线重连socket失败
function M:on_reconnect_fail()
    dump("重新连接上socket失败了")
end

-- 处理消息
function M:handleMessage(name, msg)
	if name == "protocol.ChatAck" then
        self:handleChatAck(msg)
    elseif name == "protocol.HeartBeatAck" then
    elseif name == "protocol.GameLeaveAck" then
		self:handleGameLeaveAck(msg)
	elseif name == "protocol.GameVoteAck" then
		self:handleGameVoteAck(msg)
	elseif name == "protocol.GameVoteResultAck" then
		self:handleGameVoteResultAck(msg)
    elseif name == "dgnn.GAME_PlayerEnterAck" then
        self:handlePlayerEnterAck(msg)
    elseif name == "dgnn.GAME_PlayerLeaveAck" then
		self:handlePlayerLeaveAck(msg)
    elseif name == "dgnn.EnterGameAck" then
		self:handleEnterGameAck(msg)
	elseif name == "dgnn.GAME_GameSceneAck" then
		self:handleSceneAck(msg)
    elseif name == "dgnn.GAME_ReadyAck" then
		self:handleReadyAck(msg)
	elseif name == "dgnn.GAME_GameStartAck" then
		self:handleGameStartAck(msg)
    elseif name == "dgnn.GAME_CallScoreAck" then
        self:handleCallScoreAck(msg)
    elseif name == "dgnn.GAME_BeginBankAck" then
        self:handleBeginBankAck(msg)
    elseif name == "dgnn.GAME_GameBankAck" then
        self:handleGameBankAck(msg) 
	elseif name == "dgnn.GAME_GameEndAck" then
		self:handleGameEndAck(msg)
    elseif name == "dgnn.GAME_GameTotalEndAck" then
		self:handleGameTotalEndAck(msg)
    elseif name == "dgnn.GAME_GameShangZhuangAck" then
		self:handleGameShangZhuangAck(msg)
	elseif name == "dgnn.GAME_GameXiaZhuangAck" then
		self:handleGameXiaZhuangAck(msg)
    elseif name == "protocol.VoiceChatAck" then
        self:handleVoiceChatAck(msg)
    elseif name == "dgnn.GAME_GameSuanNiuBeginAck" then 
        self:handleGameSuanNiuBeginAck(msg)
    elseif name == "dgnn.GAME_GameSuanNiuAck" then 
        self:handleGameSuanNiuAck(msg)
    elseif name == "protocol.UserOfflineAck" then 
        self:handleUserOfflineAck(msg)
    elseif name == "protocol.GameLBSVoteAck" then 
        self:handlerGameLBSVoteAck()
    elseif name == "dgnn.GAME_GameOutAck" then
        self:handlerGameOutAck(msg)
    else
        print("error reve="..name)
	end
end

-- 默认聊天回复
function M:handleChatAck(tInfo)
    -- 桌子层消息处理
    self.GameDeskLayer:handleChatAck(tInfo)
end

-- 解散
function M:handleGameLeaveAck(msg)
    if msg.nResult == 1 then
		local nLocalSeat = G_GamePlayer:getLocalSeat(msg.nSeat)
        if nLocalSeat == 1 then
		    self:LeaveRoom()
        end
    elseif msg.nResult == 2 then
        -- 清空房间ID,不会重连
        G_Data.roomid = 0

        local strInfo = "房间已被解散!"
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strInfo)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self, self.LeaveRoom))
        self:addChild(curLayer)
	end
end

-- 解散结果
function M:handleGameVoteResultAck(msg)
    if msg.nResult == 1 then
		local strInfo = ""
		for nIndex, tInfo in ipairs(msg.voteResult) do
			local _player = G_GamePlayer:getPlayerBySeverSeat(tInfo.nSeat)
			if _player and tInfo.nVoteState == 1 then
				strInfo = strInfo.."[".._player["nickname"].."]"
			end
		end
        local strShow = string.format("经玩家%s同意，房间解散成功", strInfo)
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self, self.showGameTotalEnd))
        self:addChild(curLayer)

        self.bDisovleGame = true
        G_Data.roomid = 0
    elseif msg.nResult == 2 then
        local strShow = ""
        local _player = G_GamePlayer:getPlayerByUserId(self.tRoomInfo.master_id)
        if _player ~= nil then
            strShow = string.format("房主[%s]解散房间", _player.nickname)
        else
            strShow = string.format("房主解散房间")
        end
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self, self.LeaveRoom))
        self:addChild(curLayer)

        self.bDisovleGame = true
        G_Data.roomid = 0
    elseif msg.nResult == 3 then
        local strShow = "玩家同意解散,房间解散成功"
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self, self.LeaveRoom))
        self:addChild(curLayer)

        self.bDisovleGame = true
        G_Data.roomid = 0
    elseif msg.nResult == 4 then
        local strShow = "使用房间超时,房间解散成功"
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        curLayer:setOkCallback(handler(self, self.LeaveRoom))
        self:addChild(curLayer)

        self.bDisovleGame = true
        G_Data.roomid = 0
	else
		local strInfo = ""
        for nIndex, tInfo in ipairs(msg.voteResult) do
			local _player = G_GamePlayer:getPlayerBySeverSeat(tInfo.nSeat)
			if _player and tInfo.nVoteState == 2 then
				strInfo = strInfo.."[".._player["nickname"].."]"
			end
		end
		local strShow = string.format("由于玩家%s拒绝，房间解散失败，游戏继续", strInfo)
		local curLayer = G_WarnLayer.create()
        curLayer:setTips(strShow)
        curLayer:setTypes(1)
        self:addChild(curLayer)
	end
    self:handleGameVoteResultAck_()
end

-- 新玩家
function M:handlePlayerEnterAck(msg)
    -- 增加玩家
	G_GamePlayer:addPlayerInfo(msg.userData)
    G_GameDefine.nPlayerCount = G_GamePlayer:getPlayerCount()
    -- 桌子层处理
    self.GameDeskLayer:handlePlayerEnterAck(msg)
end

-- 玩家离开
function M:handlePlayerLeaveAck(msg)
    -- 桌子层处理
    self.GameDeskLayer:handlePlayerLeaveAck(msg)
end

-- 进入游戏消息
function M:handleEnterGameAck(msg)
    -- 进入房间失败
	if msg.err ~= 0 then
		self:handleEnterError(msg.err)
		return
	end
    self.nUserCount = #msg.players
	-- G_GameDefine.nGameCount = 0
	G_GameDefine.nGameStatus = G_GameDefine.game_free
	G_GameDefine.nTotalGameCount = 15
    self.ullMasterID = 1
	for _,p in ipairs(msg.players) do
		G_GamePlayer:addPlayerInfo(p, p.userid == G_GamePlayer:getMainPlayer().userid)
	end
    G_GameDefine.nPlayerCount = G_GamePlayer:getPlayerCount()
    -- 设置房间信息
    for nIndex, tData in pairs(msg.room.options) do
        self.tRoomInfo[tData.key] = tData.nValue
    end
    -- 桌子层消息处理
    self.GameDeskLayer:handleEnterGameAck(msg)
	for _,p in ipairs(msg.players) do
		self.GameDeskLayer:showPlayer(p.seat,p,p.ready)
    end
    G_Data.UserBaseInfo.isPlaying = true
end

-- 场景消息
function M:handleSceneAck(msg)
    local room = msg.room
    local status  = msg.status
    local players = msg.players 
    local bank_seat = msg.bank_seat
    local bank_score = msg.bank_score 
    
    if msg.err ~= 0 then
        self:handleEnterError(msg.err)
        return
    end
    self.nUserCount = #msg.players
    G_GameDefine.nGameCount = msg.bank_count or 0 
    dump("msg.bank_count:"..msg.bank_count)
    G_GameDefine.nGameStatus = G_GameDefine.game_free
    G_GameDefine.nTotalGameCount = 15
    self.ullMasterID = 1
    for _,p in pairs(msg.players) do
        G_GamePlayer:addPlayerInfo(p, p.userid == G_GamePlayer:getMainPlayer().userid)
    end
    G_GameDefine.nPlayerCount = G_GamePlayer:getPlayerCount()
    -- 设置房间信息
    for nIndex, tData in pairs(msg.room.options) do
        self.tRoomInfo[tData.key] = tData.nValue
    end
    
    -- 桌子层消息处理
    self.GameDeskLayer:handleEnterGameAck(msg)
    for _,p in pairs(msg.players) do
        self.GameDeskLayer:showPlayer(p.seat,p,p.ready)
    end
    local mainPlayer = G_GamePlayer:getMainPlayer()
    --房主显示开始
    if mainPlayer.seat == bank_seat then 
        self.GameDeskLayer.isBanker_ = true 
        self.GameDeskLayer.wBankerUser = mainPlayer.seat
    else 
        self.GameDeskLayer.isBanker_ = false 
    end
    self.GameDeskLayer.wBankerUser =  bank_seat

    -- 非开房玩家当庄,第一局时,游戏局数设置为0
    local bankPlayer = nil
    for _,p in pairs(msg.players) do
        if p.seat == bank_seat then
            bankPlayer = p
        end
    end
    if bankPlayer then
        if bankPlayer.userid ~= self.tRoomInfo.master_id then
            G_GameDefine.nGameCount = G_GameDefine.nGameCount - 1
            self.GameDeskLayer.Text_Ju_V:setString( "第"..G_GameDefine.nGameCount.."/"..G_GameDefine.nTotalGameCount.."局")

            -- 设置游戏状态
            G_GameDefine.nGameStatus = G_GameDefine.game_play
        end
    else
        if G_GameDefine.nGameCount > 0 then
             -- 设置游戏状态
            G_GameDefine.nGameStatus = G_GameDefine.game_play
        end
    end

    if status == "ready" then
        -- 清除结束牌
        self.GameCardManager:clearShowEndCard(G_GameDefine.nMaxPlayerCount)
        -- 清除下分
        for i=1, G_GameDefine.nPlayerCount do
            self.GameDeskLayer.tScore[i]:setVisible(false)
        end

        --也有可能是下一局了所以必须设置庄主
        self.GameDeskLayer:showZhuangzhu(msg)
        self.GameDeskLayer:initRoomInfo(msg, true)
        if not bankPlayer and mainPlayer.userid == self.tRoomInfo.master_id and G_GameDefine.nGameCount <= 0 then
            self.GameDeskLayer:showBeginBtn(true)   --开始游戏
        else
            self.GameDeskLayer:showReadyBtn(msg,self.tRoomInfo.master_id)   --准备按钮/取消准备
        end
    elseif status == "callscore" then 
        self.GameDeskLayer:initRoomInfo(msg, false) 
        self.GameDeskLayer:showCathecticBtn(msg)
    elseif status == "suanniu" then
        self.GameDeskLayer:initRoomInfo(msg, false)  
        self.GameDeskLayer:showAutoBtn(msg)
    else 

    end
    self.GameDeskLayer:initRoomTitle()

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if msg.nDissoveSeat > 0 then
        local bVote = true
        for _, vote in ipairs(msg.vote) do
            if vote.nSeat == nSelfServerSeat then
                bVote = vote.nVoteState ~= 0
                break
            end
        end
        if not bVote then
            local strInfo ="玩家申请解散房间,请问是否同意?(超过5分钟未选择,默认同意)"
            local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nDissoveSeat)
            if _player ~= nil then
                strInfo = "玩家[".._player.nickname.."]申请解散房间,请问是否同意?(超过5分钟未选择,默认同意)"
            end
            self.GameVoteLayer:setContentText(strInfo)
            self.GameVoteLayer:setClockTime(msg.nDissoveTime)
            self.GameVoteLayer:setConfirmCallback(handler(self, self.GameVote_Confirm))
            self.GameVoteLayer:setCancelCallback(handler(self, self.GameVote_Cancel))
            self.GameVoteLayer:setEndTimeCallback(handler(self, self.GameVote_Confirm))
            -- 显示投票框
            self.GameVoteLayer:setVisible(true)
        else
            -- 显示投票信息
            self.GameVoteNoticeLayer:setGameVoteAck(msg.nDissoveSeat, msg.vote)
	        self.GameVoteNoticeLayer:setVisible(true)
            self.GameVoteNoticeLayer:setClockTime(msg.nDissoveTime)
        end
    else
        -- 隐藏投票框
        self.GameVoteLayer:setVisible(false)
        -- 隐藏投票信息
        self.GameVoteNoticeLayer:setVisible(false)
	end
    --判断此人是否进入了观看模式
    local out = mainPlayer.out 
    self.GameDeskLayer:showOutMode(out)
    
end

-- 准备消息
function M:handleReadyAck(msg)
    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if nServerSeat == msg.wChairID then
        -- 清除结束牌
        self.GameCardManager:clearShowEndCard(G_GameDefine.nMaxPlayerCount)
    end

    -- 桌子层消息处理
    self.GameDeskLayer:handleReadyAck(msg)
end

function M:handleGameStartAck(tInfo)
    -- 更新游戏状态
    G_GameDefine.nGameStatus = G_GameDefine.game_play
    G_GameDefine.nGameCount = G_GameDefine.nGameCount + 1
    -- 清除牌数据
    -- self.GameCardManager:restore()
    -- 隐藏结算界面
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
        self.showSingleFlag = false 
    end
    self.m_pGameEnd = nil
    -- 桌子层消息处理
    self.GameDeskLayer:handleGameStartAck(tInfo)
    G_Data.UserBaseInfo.isPlaying = true
end

function M:clodeGameEnd(  )
	-- body
	if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
        self.showSingleFlag = false 
    end
    self.m_pGameEnd = nil
end

-- 下注消息
function M:handleCallScoreAck(tInfo)
    -- 桌子层消息处理
    self.GameDeskLayer:handleCallScoreAck(tInfo)
end

-- 开始抢庄消息
function M:handleBeginBankAck(tInfo)
    -- 桌子层消息处理
    self.GameDeskLayer:handleBeginBankAck(tInfo)
end

-- 抢庄消息
function M:handleGameBankAck(tInfo)
    -- 桌子层消息处理
    self.GameDeskLayer:handleGameBankAck(tInfo)
end

function M:handleGameEndAck(tInfo)
	self.tInfo = tInfo
    self:showConclude()
end

function M:showConclude(  )
	-- body
    --**展示动画**
    local tInfo = self.tInfo
    -- 不是解散，显示结算
    -- 自己是否是庄家
    local isBanker = self.GameDeskLayer:isBanker()
    local bankerId = self.GameDeskLayer:bankerId()
    self.showSingleFlag = true
    self.GameDeskLayer:setAllScore(tInfo.bank_score,tInfo)  
    -- 桌子层消息处理
    self.GameDeskLayer:handleGameEndAck(tInfo)      
    self.GameDeskLayer:handleAnimas(tInfo,function()
        -- body
        local tInfo = self.tInfo
        if not self.bDisovleGame then
            if self.m_pGameEnd == nil then
                --延时5s播放
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                    -- body
                    local mainPlayer = G_GamePlayer:getMainPlayer()
                    local isWin = false 
                    for _, info in ipairs(tInfo.infos) do
                        if mainPlayer.seat == info.seat then
                            if info.score >= 0 then
                                isWin = true 
                            else
                                isWin = false
                            end
                        end
                    end

                    local isNewBanker = self.GameDeskLayer:isBanker()   --新的庄家
                    local newBankerId = self.GameDeskLayer:bankerId()   --新的庄家ID

                    local isXiazhuang = self.xiaZhuangBankerFlag 
                    local isShangZhuang = self.shangZhuangBankerFlag 

                    self.m_pGameEnd = SuccessLayer.new(GameConfigManager.tGameID.DGNN,tInfo,self.isTotalConclude,isBanker,bankerId,isXiazhuang,isShangZhuang)
                    if isWin == true then 
                    
                    else 
                        self.m_pGameEnd = FailedLayer.new(GameConfigManager.tGameID.DGNN,tInfo,self.isTotalConclude,isBanker,bankerId,isXiazhuang,isShangZhuang)
                    end  
                    self.GameDeskLayer:clearDeak()
                    local sound = "Music/"..GameConfigManager.tGameID.DGNN.."/win.mp3"
                    if isWin then
                        --[[ 
                        local actionsID_ = GameConfigManager.actionsID.SHENGLI
                        local endFrame = GameConfigManager.actions[actionsID_]
                        self:addChild(self.m_pGameEnd)
                        self.m_pGameEnd:setVisible(false)
                        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/win.mp3"
                        G_CommonFunc:runAction(endFrame,actionsID_,GameConfigManager.tGameID.DGNN,self,function()
                            -- body
                            self.m_pGameEnd:setVisible(true)
                        end)
                        --]]
                        self:addChild(self.m_pGameEnd)
                        self.m_pGameEnd:setVisible(false)
                        G_CommonFunc:showSuccessAnimas(self,function()
                            -- body
                            self.m_pGameEnd:setVisible(true)
                        end)
                    else
                        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/lose.mp3"
                        self:addChild(self.m_pGameEnd)
                    end
                    G_GameDeskManager.Music:playSound(sound,false)  
                end)))
            else
                self.m_pGameEnd:GameEndAck(G_GameDefine.nGameCount,G_GameDefine.nTotalGameCount,tInfo)
            end
        end
    end)
end

-- 总结算信息
function M:handleGameTotalEndAck(tInfo)
	G_Data.roomid = 0
    self.totalConcludeInfo = tInfo
    self.isTotalConclude = true
    dump(self.showSingleFlag)
    if self.showSingleFlag == true then
        if self.m_pGameEnd ~= nil then 
            self:showTotalEndLayer()
        end  
    else
        self:showTotalEndLayer()    
    end
end

function M:showTotalEndLayer()
    -- body
    if self.m_pGameGameTotalEnd == nil then
        --设置总结算的标示  true
        self.m_pGameGameTotalEnd = TotalLayer.new(GameConfigManager.tGameID.DGNN,self.totalConcludeInfo,self.tRoomInfo.master_id)
        self.m_pGameGameTotalEnd:setVisible(true)
        self:addChild(self.m_pGameGameTotalEnd)
        self.isTotalConclude = true 
    end
end

-- 显示总结算
function M:showOneOver()
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
        self.showSingleFlag = false 
    end
	self.m_pGameEnd = nil
    self:showTotalEndLayer()
	if self.m_pGameGameTotalEnd then
		
	else
		G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
		G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
	end
end

-- 游戏重置
function M:Action_Restart(byAgree)
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
        self.showSingleFlag = false 
    end
	self.m_pGameEnd = nil

    if G_Data.bReplay then
        return
    end

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if byAgree == 1 then
        -- 发送准备
        self.GameDeskLayer:Click_Ready()
    else
        -- 设置准备按钮
        self.GameDeskLayer:SetReadyBtn(false,true)
    end
end

function M:showEmptyCard(call,me)
	-- body
	self.GameCardManager:showEmptyCard(call,me)
end

--上庄
function M:handleGameShangZhuangAck( msg )
	-- body
    self.shangZhuangBankerFlag =  (G_GamePlayer:getMainPlayer().seat == msg.bank_user_seat)
	self.GameDeskLayer:handleGameShangZhuangAck(msg)
end

--下庄
function M:handleGameXiaZhuangAck(  msg )
	-- body
    self.xiaZhuangBankerFlag = (G_GamePlayer:getMainPlayer().seat == msg.old_bank_user_seat)
	self.GameDeskLayer:handleGameXiaZhuangAck(msg)
end

function M:closeConcludeLayer(  )
	-- body
	if self.m_pGameEnd then 
		self.m_pGameEnd:removeFromParent()
		self.m_pGameEnd = nil
	    self.showSingleFlag = false  
    end
end

function M:showSetLayer(  )
	-- body
	local curayer = GameSetLayer:create(false)
    curayer:setVisible(true)
	self:addChild(curayer, 10)
end

function M:setChatLayerVisible( isVisible )
	-- body
	self.GameChatLayer:setVisible(true)
end

function M:ShowChatInfo(nLocalSeat,dwMsgID,text)
	-- body
	self.GameChatLayer:ShowChatInfo(nLocalSeat,dwMsgID,text,true)
end

function M:handleVoiceChatAck( msg )
    -- body
    self.GameDeskLayer:handleVoiceChatAck(msg)
end

function M:ShowEndCardSimple(nLocalSeat,cbCardData,call)
    -- body
    self.GameCardManager:ShowEndCardSimple(nLocalSeat,cbCardData,call)
end

--开始算牛
function M:handleGameSuanNiuBeginAck()
    -- body
    self.GameDeskLayer:handleGameSuanNiuBeginAck()
end

--**自动算牛的结果**
function M:handleGameSuanNiuAck( msg )
    -- body
    self.GameDeskLayer:handleGameSuanNiuAck(msg)
end


--自动算牛效果
function M:ShowEndCardAuto( nLocalSeat,cbCardData,type,seat )
    -- body
    self.GameCardManager:ShowEndCardAuto(nLocalSeat,cbCardData,type,seat)
end

-- 离开
function M:Click_Leave()
    if G_GameDefine.nGameCount == 0 and G_GameDefine.nGameStatus == G_GameDefine.game_free then
        local _player = G_GamePlayer:getMainPlayer()
        if _player.userid == self.tRoomInfo.master_id then
            self.GameLeaveLayer:setConfirmCallback(handler(self, self.GameLeave_Confirm))
            self.GameLeaveLayer:setVisible(true)
        else
            self:GameLeave_Confirm()
        end
    else
        local strInfo ="申请解散房间!"
        self.GameLeaveLayer:setContentText(strInfo)
        self.GameLeaveLayer:setConfirmCallback(handler(self, self.GameVote_Confirm))
        self.GameLeaveLayer:setVisible(true)
    end
end

-- 点击解散
function M:Click_Vote()
    local strInfo ="申请解散房间!"
    self.GameLeaveLayer:setContentText(strInfo)
    self.GameLeaveLayer:setConfirmCallback(handler(self, self.GameVote_Confirm))
	self.GameLeaveLayer:setVisible(true)
end

--- 游戏离开
function M:GameLeave_Confirm()
    -- 发送解散消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameLeaveReq", {})
end

-- 游戏投票结果
function M:handleGameVoteAck(msg)
    -- 已投票数量
    local nVoteCount = 0
    for nIndex, tInfo in ipairs(msg.vote) do
        if tInfo.nVoteState ~= 0 then
            nVoteCount = nVoteCount + 1
        end
    end
    local bFind = false
    local nSelfServerSeat = G_GamePlayer:getMainPlayer().seat
    for nIndex, tInfo in ipairs(msg.vote) do
        -- 玩家还未投票
        if tInfo.nSeat == nSelfServerSeat and tInfo.nVoteState == 0 then
            if nVoteCount == 1 then
                local strInfo ="玩家申请解散房间,请问是否同意?(超过5分钟未选择,默认同意)"
                local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nDissoveSeat)
                if _player ~= nil then
                    strInfo = "玩家[".._player.nickname.."]申请解散房间,请问是否同意?(超过5分钟未选择,默认同意)"
                end
                self.GameVoteLayer:setContentText(strInfo)
                self.GameVoteLayer:setClockTime(300)
                self.GameVoteLayer:setConfirmCallback(handler(self, self.GameVote_Confirm))
                self.GameVoteLayer:setCancelCallback(handler(self, self.GameVote_Cancel))
                self.GameVoteLayer:setEndTimeCallback(handler(self, self.GameVote_Confirm))
            end
            -- 显示投票框
            self.GameVoteLayer:setVisible(true)
            bFind = true
            break
        end
    end
    -- 已投票就显示投票信息
    if not bFind then
        -- 显示投票信息
        self.GameVoteNoticeLayer:setGameVoteAck(msg.nDissoveSeat, msg.vote)
        self.GameVoteNoticeLayer:setVisible(true)
        self.GameVoteNoticeLayer:setClockTime(300)
    end
end

-- 游戏投票结果
function M:handleGameVoteResultAck_(msg)
    -- 隐藏投票框
    self.GameVoteLayer:onExit()
    -- 隐藏投票信息
    self.GameVoteNoticeLayer:setVisible(false)
end

-- 游戏离开
function M:LeaveRoom(tGameID)
    -- 清理数据
    if self.GameDeskLayer~=nil then 
        self.GameDeskLayer:removeFromParent()
    end
    self.GameDeskLayer  = nil 
    G_Data.roomid = 0
    G_Data.recordType = tGameID 
    G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
    G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end

-- 投票-同意
function M:GameVote_Confirm()
    -- 发送解散消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameVoteReq", {bAgree = true})
end

-- 投票-取消
function M:GameVote_Cancel()
    -- 发送解散消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameVoteReq", {bAgree = false})
end

-- 显示总结算
function M:showGameTotalEnd()
    -- 隐藏结算界面
    if self.m_pGameEnd ~= nil then
        self.m_pGameEnd:removeFromParent()
        self.showSingleFlag = false 
    end
    self.m_pGameEnd = nil
    if self.m_pGameGameTotalEnd ~= nil then
        self.m_pGameGameTotalEnd:removeFromParent()
    end
    self.m_pGameGameTotalEnd = nil
    self.GameDeskLayer:removeFromParent()
    self.GameDeskLayer  = nil 
    G_Data.roomid = 0
    G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
    G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end

function M:handleUserOfflineAck(msg)
    -- body
    self.GameDeskLayer:handleUserOfflineAck(msg)
end

function M:showHelpLayer( )
    -- body
    if self.GameHelpLayer == nil then
        self.GameHelpLayer = GameHelpLayer.create()
        self:addChild(self.GameHelpLayer)
        self.GameHelpLayer:addCloseListener(function()
            self.GameHelpLayer:removeFromParent()
            self.GameHelpLayer = nil 
        end)
    end
end

function M:handlerGameLBSVoteAck()
    self.GameDeskLayer:removeFromParent()
    self.GameDeskLayer  = nil 
    G_Data.roomid = 0
    G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
    G_SceneManager:enterScene(EventConfig.SCENE_LOBBY)
end


function M:handlerClose(iError)
    local curLayer = G_WarnLayer.create()
    curLayer:setTypes(1)
    self:addChild(curLayer)
    if iError == 1 then
        curLayer:setTips("人数已满,加入房间失败!")
    elseif iError == 2 then
        curLayer:setTips("房间已结束或者不存在!")
    elseif iError == 4 then
        curLayer:setTips("此房间已经开始游戏!")
    elseif iError == 3 then
        curLayer:setTips("该房间座位已满!")
    else
        curLayer:setTips("未知的错误")
    end
    curLayer:setOkCallback(handler(self,self.LeaveRoom))
end

-- 回放准备数据
function M:replayPrepare()
    local msg = G_Data.ReplayData
    -- 设置房间信息
    for nIndex, tData in pairs(msg.game.room) do
        self.tRoomInfo[tData.key] = tData.nValue
    end
    -- 玩家人数
    G_GameDefine.nPlayerCount = #msg.game.players

    local bFind = false
    for _, _player in ipairs(msg.game.players) do
        if _player.userid == G_Data.UserBaseInfo.userid then
            bFind = true
            break
        end
	end

    if bFind then
        for i, _player in ipairs(msg.game.players) do
		    G_GamePlayer:addPlayerInfo(_player, _player.userid == G_Data.UserBaseInfo.userid)
	    end
    else
        for i, _player in ipairs(msg.game.players) do
            local bMain = false
            if not bFind and i == 1 then
                bMain = true
            end
		    G_GamePlayer:addPlayerInfo(_player, bMain)
	    end
    end
    -- 桌子层处理
    self.GameDeskLayer:replayPrepare()
end

function M:handlerGameOutAck( msg )
    -- body
    dump("handlerGameOutAck")
    dump(msg)
end

function M:Click_User_Info( e )
    -- body
    local info = e.info 
    if info == nil then 
        return 
    end 
    G_CommonFunc:showUserInfo(info,self)
end

return M
