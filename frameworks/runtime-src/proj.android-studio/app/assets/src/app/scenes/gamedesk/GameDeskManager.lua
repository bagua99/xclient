
local GameDeskManager = class("GameDeskManager")

local SocketTCP = require("componentex.SocketTCP")
local ByteArray = require("componentex.ByteArray")
local scheduler =  cc.Director:getInstance():getScheduler()

function GameDeskManager:ctor()

    self.nGameID = nil
    -- 创建音乐对象
    self.Music = require("app.music.AudioManager"):create()
end

function GameDeskManager:enterGame()

    self.nGameID = G_Data.CL_JoinGameAck.nGameID
    if self.nGameID == nil then
        return
    end

    -- 设置游戏信息
    cc.exports.G_GameDefine = require("app.scenes.gamedesk."..self.nGameID..".GameDefine"):create()
    cc.exports.G_GamePlayer = require("app.scenes.gamedesk."..self.nGameID..".GamePlayer"):create()

    -- 设置游戏ID
    G_GameDefine.nLastGameID = self.nGameID

    self.DeskManager = {}
    self.DeskManager.Protocol = require("app.scenes.gamedesk."..self.nGameID..".GameProtocol")

    local GameDesk = require("app.scenes.gamedesk."..self.nGameID..".game.GameDeskScene"):create()
    self.DeskManager[self.nGameID] = GameDesk

    display.runScene(GameDesk,nil,0.3,display.COLOR_WHITE)
end

--[[
function GameDeskManager:quitGame()

    self.Music = nil

    cc.exports.G_GameDefine = nil
    cc.exports.G_GamePlayer = nil

    self.DeskManager = nil
end
--]]

-- 发送心跳
function GameDeskManager:sendHeart()

	G_Data.GAME_HeartBeatReq = {}
	G_Data.GAME_HeartBeatReq.ullTime = os.time()

    self:sendGameProtoclMsg(NETTYPE_GAME,"GAME_HeartBeatReq")
end

-- 发送聊天信息
function GameDeskManager:sendUserChat(strText, nChatID)

	local __strSendData = ByteArray.new()
	local nStrLen = ef.extensFunction:getInstance():getStrLen(strText) + 1
	local strP = nStrLen.."p"
    __strSendData:writeBuf(string.pack("i", ID_BASEGAMELOGIC + 0x1001))
 	__strSendData:writeBuf(string.pack("i", 4+nStrLen))
 	__strSendData:writeBuf(string.pack(strP, strText))
    -- 发送数据
    G_NetManager:sendGameProtoclMsg(NETTYPE_GAME, __strSendData)
end

function GameDeskManager:netEvent_Connected(event)

    if self.schedule_warn then
    	scheduler:unscheduleScriptEntry(self.schedule_warn)
    	self.schedule_warn = nil
    end
    self.schedule_warn = scheduler:scheduleScriptFunc(handler(self,self.sendHeart),3,false)
end

function GameDeskManager:netEvent_getData(event)

    if self.nGameID == nil then
        return
    end

    if self.DeskManager == nil or self.DeskManager[self.nGameID] == nil then
        return
    end

    local tMsg = self.DeskManager.Protocol.res_protocol[event.msgID]
    if tMsg == nil then
        release_print("netEvent_getData no find event.msgID "..event.msgID)
        return
    end
    event.msgName = tMsg.MsgName
    self.DeskManager[self.nGameID]:handleMessage(event)
end

function GameDeskManager:netEvent_Close(event)

    if self.schedule_warn then
    	scheduler:unscheduleScriptEntry(self.schedule_warn)
    	self.schedule_warn = nil
    end
end

function GameDeskManager:sendGameProtoclMsg(nType, strMsgName)

    if nType ~= NETTYPE_GAME then
        return
    end

    local tMsg = self.DeskManager.Protocol.req_protocol[strMsgName]
    -- 数据信息
    local tData = G_Data[strMsgName]
    local nMsgLen = self:getMsgLen(tMsg["protocol"])

	local __strSendData = ByteArray.new()
    -- 压入消息头
	__strSendData:writeBuf(string.pack("i", tMsg.ID))
	__strSendData:writeBuf(string.pack("i", nMsgLen))
    -- 压入数据
	self:writeMsg(__strSendData, tData, tMsg)
    -- 发送数据
    G_NetManager:sendGameProtoclMsg(nType, __strSendData)
end

function GameDeskManager:writeMsg(bytes, tData, tMsg)

	for i = 1,#tMsg["protocol"] do
		local strParam = tMsg["protocol"][i]
		if string.sub(strParam,1,1) == "$" then

			local strS = string.sub(strParam,2)
			self:writeMsg(bytes, tData[strS], self.DeskManager.Protocol.struct[strS])
        elseif string.sub(strParam,1,1) == "#" then

            -- 取出参数名字解析
            local tbMsg = string.split(tMsg["params"][i],"|")
			if #tbMsg < 2 then
				print("param is error,no |")
				return
			end
			local iNum = tonumber(string.sub(tbMsg[1],2))
			local iNum2 = 1
			if #tbMsg == 3 then
				iNum2 = tonumber(tbMsg[2])
			end

			local strS = string.sub(tbMsg[2],1,1)
			if #tbMsg == 3 then
				strS = string.sub(tbMsg[3],1,1)
			end

			local ayName = tbMsg[2]
			if #tbMsg == 3 then
				ayName = tbMsg[3]
			end

			if strS == "$" then
				ayName = string.sub(ayName,2)
			end

			local tProtocol = string.split(tMsg["protocol"][i],"|")
			if #tProtocol ~= #tbMsg then
				print("protocol is error,no |")
				return
			end
		
			local ayNameProtocol = tProtocol[2]
			if #tbMsg == 3 then
				ayNameProtocol = tProtocol[3]
			end

			for j=1,iNum do
				
				if strS == "$" then
					if #tbMsg == 3 then
						for z=1,iNum2 do
							self:writeMsg(bytes,tData[ayName][j][z],self.DeskManager.Protocol.struct[ayName])
						end
					else
						self:writeMsg(bytes,tData[ayName][j],self.DeskManager.Protocol.struct[ayName])
					end
				else
					if #tbMsg == 3 then
						for z=1,iNum2 do
							bytes:writeBuf(string.pack(ayNameProtocol, tData[ayName][j][z]))
						end
					else
                        bytes:writeBuf(string.pack(ayNameProtocol, tData[ayName][j]))
					end
				end
			end
		else
            if strParam == "b" then
                bytes:writeBool(tData[tMsg["params"][i]])
            else
			    bytes:writeBuf(string.pack(strParam, tData[tMsg["params"][i]]))
            end
		end
	end
end

function GameDeskManager:getMsgLen(strMsg)

	local msgLen = 0
	for i = 1,#strMsg do

		local strParam = strMsg[i]
		if string.sub(strParam,1,1) == "$" then

			local strS = string.sub(strParam,2)
			msgLen = msgLen+ self:getMsgLen(self.DeskManager.Protocol.struct[strS]["protocol"])
		elseif string.sub(strParam,1,1) == "#" then

			local tbMsg = string.split(strParam,"|")
			if #tbMsg < 2 then
				release_print("protocol is error,no |")
				return
			end
			if #tbMsg == 2 then
				local iNum = tonumber(string.sub(tbMsg[1],2))
				msgLen = msgLen + iNum * self:getMsgLen({tbMsg[2]})
			elseif #tbMsg == 3 then
				local iNum = tonumber(string.sub(tbMsg[1],2))
				iNum = iNum * tonumber(tbMsg[2])
				msgLen = msgLen + iNum * self:getMsgLen({tbMsg[3]})
			end
		else

            local strFlag = string.sub(strParam,-1)
			local strNum = 1
			if string.len(strParam) ~= 1 then
				strNum = tonumber(string.sub(strParam,1,-2))
			end
			msgLen = msgLen + strNum * SocketTCP:getFlagLen(strFlag)
		end
	end

	return msgLen
end

function GameDeskManager:writeRecvMsg(bytes, tData, mapMess)

	for i=1,#mapMess["params"] do
		local strParam = mapMess["params"][i]
		if string.sub(strParam,1,1) == "$" then
			local strS = string.sub(strParam,2)
			tData[strS] = {}
			self:writeRecvMsg(bytes, tData[strS], self.DeskManager.Protocol.struct[strS])
		elseif string.sub(strParam,1,1) == "#" then
			local tbMsg = string.split(strParam,"|")
			if #tbMsg < 2 then
				assert("param is error,no |")
				return
			end
			local iNum = tonumber(string.sub(tbMsg[1],2))
			local iNum2 = 1
			if #tbMsg == 3 then
				iNum2 = tonumber(tbMsg[2])
			end

			local strS = string.sub(tbMsg[2],1,1)
			if #tbMsg == 3 then
				strS = string.sub(tbMsg[3],1,1)
			end

			local ayName = tbMsg[2]
			if #tbMsg == 3 then
				ayName = tbMsg[3]
			end

			if strS == "$" then
				ayName = string.sub(ayName,2)
			end
			tData[ayName] = {}


			local tProtocol = string.split(mapMess["protocol"][i],"|")
			if #tProtocol ~= #tbMsg then
				assert("protocol is error,no |")
				return
			end
		
			local ayNameProtocol = tProtocol[2]
			if #tbMsg == 3 then
				ayNameProtocol = tProtocol[3]
			end

			local iOneTotal = 1
			if strS == "$" then
				ayNameProtocol = string.sub(tProtocol[2],2)
				if #tbMsg == 3 then
					ayNameProtocol = string.sub(tProtocol[3],2)
				end
			else
                local strFlag = string.sub(ayNameProtocol,-1)
				local iNum = 1
				if string.len(ayNameProtocol) ~= 1 then
					iNum = tonumber(string.sub(ayNameProtocol,1,-2))
				end
				iOneTotal = iNum * SocketTCP:getFlagLen(strFlag)
			end

			for j=1,iNum do
				
				if strS == "$" then
					tData[ayName][j] = {}
					if #tbMsg == 3 then
						for z=1,iNum2 do
							tData[ayName][j][z] = {}
							self:writeRecvMsg(bytes,tData[ayName][j][z],protocol.struct[ayName])
						end
					else
						
						self:writeRecvMsg(bytes,tData[ayName][j],protocol.struct[ayName])
					
					end
				else
					if #tbMsg == 3 then
						tData[ayName][j] = {}
						for z=1,iNum2 do
							self.m_iWriteLen = self.m_iWriteLen + iOneTotal
							local strInfo = bytes:rawUnPack(ayNameProtocol)
							tData[ayName][j][z] = strInfo
							bytes:setPos(self.m_iWriteLen)
						end
					else
						self.m_iWriteLen = self.m_iWriteLen + iOneTotal
						local strInfo = bytes:rawUnPack(ayNameProtocol)
						tData[ayName][j] = strInfo
						bytes:setPos(self.m_iWriteLen)
					end
				end
			end
		else
            local strFlag = string.sub(mapMess["protocol"][i],-1)
			local iNum = 1
			if string.len(mapMess["protocol"][i]) ~= 1 then
				iNum = tonumber(string.sub(mapMess["protocol"][i],1,-2))
			end
			self.m_iWriteLen = self.m_iWriteLen + iNum * SocketTCP:getFlagLen(strFlag)
			local strInfo = bytes:rawUnPack(mapMess["protocol"][i])
			tData[strParam] = strInfo
			bytes:setPos(self.m_iWriteLen)
		end
	end
end

-- 写入游戏读取消息
function GameDeskManager:writeGameRecvMsg(tData, msgData, mapMess)

    local __ba = ByteArray.new()
    __ba:writeBuf(msgData)
    __ba:setPos(1)
    self.m_iWriteLen = 1
    self:writeRecvMsg(__ba, tData, mapMess)
end

return GameDeskManager