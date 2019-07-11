
local M = class("GameDeskScene", G_BaseScene)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameDeskLayer             = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".game.GameDeskLayer")
local GameEndLayer              = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".game.GameEndLayer")
local GameTotalEndLayer         = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".game.GameTotalEndLayer")
local logic                     = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".logic.logic")

local GameChatLayer             = require("app.scenes.lobby.common.GameChatLayer")
local GameLeaveLayer            = require("app.scenes.lobby.common.GameLeaveLayer")
local GameVoteLayer             = require("app.scenes.lobby.common.GameVoteLayer")
local GameVoteNoticeLayer       = require("app.scenes.lobby.common.GameVoteNoticeLayer")
local GameChatBubbleLayer       = require("app.scenes.lobby.common.GameChatBubbleLayer")

local GameSetLayer              = require("app.scenes.lobby.GameSet.GameSetLayer")
local GameHelpLayer             = require("app.scenes.lobby.GameHelp.GameHelpLayer")

local EventConfig               = require ("app.config.EventConfig")

local scheduler = cc.Director:getInstance():getScheduler()

-- 创建
function M:onCreate()
    self.nTotalGameCount = 0
    self.nCurGameCount = 0
    self.nRoomID = 0
    self.pGameBalance = nil
    self.pGameOneOver = nil
	self.bDisovleGame = false
    self.bEnd = false
    self.tRoomInfo = {}

    G_GameDefine.nGameStatus = G_GameDefine.game_free

	self.m_pGameEnd = nil
	self.m_pGameGameTotalEnd = nil

    self.GameLogic = logic

	cc.exports.G_DeskScene = self

    self:initView()
end

-- 初始视图
function M:initView()
	--桌面
	self.GameDeskLayer = GameDeskLayer.create()
	self:addChild(self.GameDeskLayer)

    -- 离开
    self.GameLeaveLayer = GameLeaveLayer.create()
    self.GameLeaveLayer:setVisible(false)
    self:addChild(self.GameLeaveLayer)

    -- 投票
    self.GameVoteLayer = GameVoteLayer.create()
    self.GameVoteLayer:setVisible(false)
    self:addChild(self.GameVoteLayer)

    -- 投票信息
    self.GameVoteNoticeLayer = GameVoteNoticeLayer.create()
    self.GameVoteNoticeLayer:setVisible(false)
    self:addChild(self.GameVoteNoticeLayer)

    -- 聊天信息
    self.GameChatLayer = GameChatLayer.create()
    self.GameChatLayer:setVisible(false)
    self:addChild(self.GameChatLayer)

end

-- 场景进入
function M:onEnter()
    local music = "Music/BACK_MUSIC.mp3"
    G_Data.music = music
    -- 播放音乐
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
    G_GameDeskManager.Music:stopBackMusic()
	G_Data.roomid = 0
	G_NetManager:disconnect(EventConfig.NETTYPE_GAME)
    cc.exports.G_DeskScene = nil
    local tPlist = GameConfigManager.tPlist[G_Data.gameid]
    local cache = cc.SpriteFrameCache:getInstance()
    for k,v in pairs(tPlist) do 
        local img = v.img 
        local plist = v.plist
        dump(plist)
        cache:removeSpriteFramesFromFile(plist)
    end 

end

-- 处理消息
function M:handleMessage(name, msg)
    if name == "protocol.ChatAck" then
        self:handleChatAck(msg)
    elseif name == "protocol.VoiceChatAck" then
        self:handleVoiceChatAck(msg)
    elseif name == "protocol.UserOfflineAck" then
        self:handleUserOfflineAck(msg)
    elseif name == "protocol.HeartBeatAck" then
    elseif name == "protocol.GameLeaveAck" then
		self:handleGameLeaveAck(msg)
	elseif name == "protocol.GameVoteAck" then
		self:handleGameVoteAck(msg)
	elseif name == "protocol.GameVoteResultAck" then
		self:handleGameVoteResultAck(msg)
    elseif name == "pdk.GAME_PlayerEnterAck" then
		self:handlePlayerEnterAck(msg)
    elseif name == "pdk.GAME_PlayerLeaveAck" then
		self:handlePlayerLeaveAck(msg)
    elseif name == "pdk.GAME_EnterGameAck" then
		self:handleEnterGameAck(msg)
	elseif name == "pdk.GAME_GameSceneAck" then
		self:handleSceneAck(msg)
    elseif name == "pdk.GAME_ReadyAck" then
		self:handleReadyAck(msg)
	elseif name == "pdk.GAME_GameStartAck" then
		self:handleGameStartAck(msg)
	elseif name == "pdk.GAME_OutCardAck" then
		self:handleOutCardAck(msg)
    elseif name == "pdk.GAME_PassCardAck" then
		self:handlePassCardAck(msg)
	elseif name == "pdk.GAME_GameEndAck" then
		self:handleGameEndAck(msg)
    elseif name == "pdk.GAME_GameTotalEndAck" then
		self:handleGameTotalEndAck(msg)
    elseif name == "pdk.GAME_PromptAck" then
		self:handlePromptAck(msg)
    elseif name == "protocol.GameLBSVoteAck" then 
        self:handlerGameLBSVoteAck()
    else
        print("error reve="..name)
	end
end

-- 掉线了
function M:handle_Offline()
    if G_Data.roomid == 0 then
        return
    end

    G_NetManager:connectGame(G_Data.room_ip, G_Data.room_port, handler(self,self.on_reconnect_success), handler(self,self.on_reconnect_fail), true)
end

-- 断线重连socket连上了
function M:on_reconnect_success()
    
    G_GameDeskManager:EnterGameReq(true)
end

-- 断线重连socket失败
function M:on_reconnect_fail()

end

-- 默认聊天
function M:handleChatAck(msg)
    self.GameDeskLayer:handleChatAck(msg)
end

-- 语音消息
function M:handleVoiceChatAck(msg)
    self.GameDeskLayer:handleVoiceChatAck(msg)
end

-- 玩家断线
function M:handleUserOfflineAck(msg)
    self.GameDeskLayer:handleUserOfflineAck(msg)
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

-- 投票
function M:handleGameVoteAck(msg)
    -- 已投票数量
    local nVoteCount = 0
    for nIndex, tInfo in ipairs(msg.vote) do
        if tInfo.nVoteState ~= 0 then
            nVoteCount = nVoteCount + 1
        end
    end

    local bFind = false
    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
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

    -- 隐藏投票框
    self.GameVoteLayer:onExit()
    -- 隐藏投票信息
    self.GameVoteNoticeLayer:setVisible(false)
end

-- 新玩家
function M:handlePlayerEnterAck(msg)
    -- 增加玩家
	G_GamePlayer:addPlayerInfo(msg.userData)
    -- 桌子层处理
    self.GameDeskLayer:handlePlayerEnterAck(msg)
end

-- 玩家离开
function M:handlePlayerLeaveAck(msg)
    -- 桌子层处理
    self.GameDeskLayer:handlePlayerLeaveAck(msg)
end

-- 进入游戏
function M:handleEnterGameAck(msg)
    -- 进入房间失败
	if msg.err ~= 0 then
		self:handleEnterError(msg.err)
		return
	end
	
    -- 设置房间信息
    for nIndex, tData in pairs(msg.room.options) do
        self.tRoomInfo[tData.key] = tData.nValue
    end
    -- 玩家人数
    G_GameDefine.nPlayerCount = self.tRoomInfo.player_count
    -- 显示房间信息
    self:showRoomInfo()

    local _player = G_GamePlayer:getMainPlayer()
    if _player.userid == self.tRoomInfo.master_id then 
        self.GameDeskLayer.isMaster = true
    else 
        self.GameDeskLayer.isMaster = false  
    end 

    for _, _player in ipairs(msg.players) do
		G_GamePlayer:addPlayerInfo(_player, _player.userid == G_GamePlayer:getMainPlayer().userid)
	end

    -- 桌子层处理
    self.GameDeskLayer:handleEnterGameAck(msg)
end

-- 断线重连
function M:handleSceneAck(msg)
    G_GameDefine.nGameStatus = msg.nGameStatus
    G_GameDefine.nGameCount = msg.nGameCount
    G_GameDefine.nTotalGameCount = msg.nTotalGameCount

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

    -- 桌子层处理
    self.GameDeskLayer:handleSceneAck(msg)
end

-- 准备消息
function M:handleReadyAck(msg)
    -- 非空闲状态,不处理
    if G_GameDefine.nGameStatus ~= G_GameDefine.game_free then
        return
    end

    -- 桌子层处理
    self.GameDeskLayer:handleReadyAck(msg)
end

function M:handleGameStartAck(msg)
    -- 更新游戏状态
    G_GameDefine.nGameStatus = G_GameDefine.game_play
    -- 设置游戏局数
    G_GameDefine.nGameCount = G_GameDefine.nGameCount + 1

    self.tOutCardData = {}

    -- 隐藏结算界面
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
    self.m_pGameEnd = nil

    -- 桌子层消息处理
    self.GameDeskLayer:handleGameStartAck(msg)
end

-- 出牌消息
function M:handleOutCardAck(msg)
    -- 取得玩家信息
    local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nOutCardSeat)
    -- 性别
    local nSex = (_player == nil) and 1 or _player.sex
    local strSex = (nSex == 1) and "man" or "woman"
    local strCard = bit.band(msg.nCardData[1], 0x0F)
    local strMusic = ""
    local actionsID_ = nil 
    -- 取得牌类型
    local nCardType = self.GameLogic.getCardType(msg.nCardData)
    if nCardType == self.GameLogic.CT_SINGLE then
        strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/"..strCard..".wav"
    elseif nCardType == self.GameLogic.CT_DOUBLE then
        strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/2_"..strCard..".wav"
    elseif nCardType == self.GameLogic.CT_THREE then
        strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/3_"..strCard..".wav"
    elseif nCardType == self.GameLogic.CT_SINGLE_LINE then
        strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/Straight.wav"
        actionsID_ = GameConfigManager.actionsID.SHUNZI
    elseif nCardType == self.GameLogic.CT_DOUBLE_LINE then
        strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/MorePairs.wav"
        --连对
        actionsID_ = GameConfigManager.actionsID.DOUBLE_LINE
    elseif nCardType == self.GameLogic.CT_THREE_LINE then
        strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/Plane.wav"
        actionsID_ = GameConfigManager.actionsID.FEIJI
    elseif nCardType == self.GameLogic.CT_THREE_TAKE_ONE then
        if #msg.nCardData <= 4 then
            strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/ThreeAndOne.wav"
            --三对一
            actionsID_ = GameConfigManager.actionsID.THREE_TAKE_ONE
        else
            strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/Plane.wav"
            actionsID_ = GameConfigManager.actionsID.FEIJI
        end
    elseif nCardType == self.GameLogic.CT_THREE_TAKE_TWO then
        if #msg.nCardData <= 5 then
            strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/ThreeAndDui.wav"
            --三对二
            actionsID_ = GameConfigManager.actionsID.THREE_TAKE_TWO
        else
            strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/Plane.wav"
            actionsID_ = GameConfigManager.actionsID.FEIJI
        end
    elseif nCardType == self.GameLogic.CT_BOMB_CARD then
        strMusic = "Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/Bomb.wav"
        G_CommonFunc:playAnimals(6,"baoguang",GameConfigManager.tGameID.PDK,self)
    end
    if strMusic ~= "" then
        G_GameDeskManager.Music:playSound(strMusic, false)
    end
    -- 剩1张牌
    if msg.bLeftOne then
        G_GameDeskManager.Music:playSound("Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/Warning.wav")
    end

    if actionsID_ then 
        local endFrame = GameConfigManager.actions[actionsID_]
        G_CommonFunc:runAction(endFrame,actionsID_,GameConfigManager.tGameID.PDK,self)
    end 

    -- 桌子层消息处理
    self.GameDeskLayer:handleOutCardAck(msg)
end

-- 过牌消息
function M:handlePassCardAck(msg)
    -- 取得玩家信息
    local _player = G_GamePlayer:getPlayerBySeverSeat(msg.nPassSeat)
    -- 性别
    local nSex = (_player == nil) and 1 or _player.sex
    local strSex = (nSex == 1) and "man" or "woman"
    G_GameDeskManager.Music:playSound("Music/"..GameConfigManager.tGameID.PDK.."/"..strSex.."/Pass"..math.random(1,4)..".wav", false)

    -- 桌子层消息处理
    self.GameDeskLayer:handlePassCardAck(msg)
end

-- 游戏结束
function M:handleGameEndAck(msg)
    -- 设置空闲状态
    G_GameDefine.nGameStatus = G_GameDefine.game_free

    -- 先处理结算信息
    local isWin = false 
    local nServerSeat = G_GamePlayer:getServerSeat(1)
    if msg.nGameScore[nServerSeat] > 0 then
        isWin = true 
    else
        if msg.nGameScore[nServerSeat] == 0 and msg.card[nServerSeat] ~= nil and #msg.card[nServerSeat].nCardData == 0 then
            isWin = true 
        else
            isWin = false 
        end
    end
    local function showEnd()
        -- body
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
            -- 游戏结束
            self.GameDeskLayer:handleGameEndAck(msg)
        end)))
        -- 显示结算页面
        self:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.CallFunc:create(function()
            if self.m_pGameEnd == nil then
                self.m_pGameEnd = GameEndLayer.create()
                self:addChild(self.m_pGameEnd)
                self.m_pGameEnd:GameEndAck(G_GameDefine.nGameCount, G_GameDefine.nTotalGameCount, msg)
            else
                self.m_pGameEnd:GameEndAck(G_GameDefine.nGameCount, G_GameDefine.nTotalGameCount, msg)
            end
            -- 解散不显示小局结算
            if self.bDisovleGame then
                self.m_pGameEnd:setVisible(false)
            end
        end)))
    end
    local sound = "Music/"..GameConfigManager.tGameID.DGNN.."/win.mp3"
    if isWin then 
        --[[
        local actionsID_ = GameConfigManager.actionsID.SHENGLI
        local endFrame = GameConfigManager.actions[actionsID_]
        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/win.mp3"
        G_CommonFunc:runAction(endFrame,actionsID_,GameConfigManager.tGameID.PDK,self,function()
        -- body
            showEnd()
        end)
        --]]
        G_CommonFunc:showSuccessAnimas(self,function()
            -- body
            showEnd()
        end)
    else
        sound = "Music/"..GameConfigManager.tGameID.DGNN.."/lose.mp3" 
        showEnd()
    end
    G_GameDeskManager.Music:playSound(sound,false)  
end

-- 总结算信息
function M:handleGameTotalEndAck(msg)
    -- 设置结束,不然服务器关闭,客户端这边会重连
    G_Data.roomid = 0

    if self.m_pGameGameTotalEnd == nil then
        self.m_pGameGameTotalEnd = GameTotalEndLayer:create()
        self.m_pGameGameTotalEnd:GameTotalEndAck(msg,self.bDisovleGame,self.tRoomInfo.master_id)
        self.m_pGameGameTotalEnd:setVisible(false)
        self:addChild(self.m_pGameGameTotalEnd, 101)
    end
end

-- 提示信息
function M:handlePromptAck(msg)
    G_CommonFunc:showGeneralTips(GameConfigManager.tGameID.PDK,msg.szPrompt,self,cc.p(display.cx,display.cy))
end

-- 显示总结算
function M:showGameTotalEnd()
    -- 隐藏结算界面
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
    self.m_pGameEnd = nil

    if self.m_pGameGameTotalEnd ~= nil then
        self.m_pGameGameTotalEnd:setVisible(true)
    end
end

-- 重新开始
function M:Action_Restart(bReady)
    if self.m_pGameEnd ~= nil then
	    self.m_pGameEnd:removeFromParent()
    end
	self.m_pGameEnd = nil

    if G_Data.bReplay then
        return
    end

	G_GameDefine.nGameStatus = G_GameDefine.game_free

    local nSelfServerSeat = G_GamePlayer:getServerSeat(1)
    if bReady then
        -- 清除出牌
        self.GameDeskLayer.GameCardManager:clearShowOutCard(0)
        -- 发送准备
        self.GameDeskLayer:Click_Ready()
    else
        -- 设置准备按钮
        self.GameDeskLayer:SetReadyBtn(false, true)
    end
end

-- 进入失败提示
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

-- 显示房间信息
function M:showRoomInfo()
    local strShowCard = self.tRoomInfo.show_card == 1 and "显示牌数 " or "不显示牌数 "
    local strBankerCard = self.tRoomInfo.first_out == 1 and "首局黑桃3必出 " or ""
    local strPressCard = self.tRoomInfo.press_card == 1 and "必须管 " or ""
    local strHongTen = self.tRoomInfo.code_card == 1 and "红桃10扎鸟" or ""
    local strInfo = "经典玩法 "..G_GameDefine.nPlayerCount.."人 "..strShowCard..strBankerCard..strPressCard..strHongTen
    -- 显示房间信息
    self.GameDeskLayer:showRoomInfo(strInfo)
end

-- 点击离开
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

-- 点击聊天
function M:Click_Chat()
    --[[
    if self.GameChatLayer == nil then
	    self.GameChatLayer = GameChatLayer:create()
	    self:addChild(self.GameChatLayer)
        self.GameChatLayer:addCloseListener(function()
            self.GameChatLayer:removeFromParent()
            self.GameChatLayer = nil 
        end)
    end
    --]]
end

-- 设置
function M:Click_Set()
    if self.GameSetLayer == nil then
	    self.GameSetLayer = GameSetLayer:create(false)
	    self:addChild(self.GameSetLayer)
        self.GameSetLayer:addCloseListener(function()
            self.GameSetLayer:removeFromParent()
            self.GameSetLayer = nil 
        end)
    end
end


-- 游戏离开
function M:GameLeave_Confirm()
    -- 发送解散消息
    G_NetManager:sendMsg(EventConfig.NETTYPE_GAME,"protocol.GameLeaveReq", {})
end

-- 游戏离开
function M:LeaveRoom(tGameID)
    -- 清理数据
    self.GameDeskLayer:removeFromParent()
    self.GameDeskLayer  = nil 
    G_Data.roomid = 0
    G_Data.recordType = tGameID or nil 
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

function M:showHelpLayer()
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
    G_GameDefine.nPlayerCount = self.tRoomInfo.player_count
    -- 显示房间信息
    self:showRoomInfo()

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

function M:ShowChatInfo(nLocalSeat,dwMsgID,text)
    self.GameChatLayer:ShowChatInfo(nLocalSeat,dwMsgID,text,false)
end

function M:setChatLayerVisible(isVisible)
    self.GameChatLayer:setVisible(true)
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
