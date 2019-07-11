
local GamePlayer = class("GamePlayer")

GamePlayer.initInfo = {ullUserID=0, szNickName="", gold=0, sex=1, seat=0, ip="", bLeave=false, imgurl="", ullRoomCard=0, bVote=false}

function GamePlayer:ctor()

	self.tGamePlayer = {}
	self.tMainPlayer = {}
end

function GamePlayer:clear()

	self.tGamePlayer = {}
	self.tMainPlayer = {}
end

function GamePlayer:getLocalSeat(nSeverSeat)

	if nSeverSeat < 0 then
		return 1
	end

	local curValue = (nSeverSeat + G_GameDefine.nMaxPlayerCount - self.tMainPlayer.seat) % G_GameDefine.nMaxPlayerCount + 1
    print("nSeverSeat="..nSeverSeat..",G_GameDefine.nMaxPlayerCount="..G_GameDefine.nMaxPlayerCount..",self.tMainPlayer.seat="..self.tMainPlayer.seat..",G_GameDefine.nMaxPlayerCount="..G_GameDefine.nMaxPlayerCount..",curValue="..curValue)
	return curValue
end


function GamePlayer:getServerSeat(nLocalSeat)

	local curValue = (nLocalSeat + self.tMainPlayer.seat - 1) % G_GameDefine.nPlayerCount
    print("nLocalSeat="..nLocalSeat..",self.tMainPlayer.seat="..self.tMainPlayer.seat..",G_GameDefine.nPlayerCount="..G_GameDefine.nPlayerCount..",curValue="..curValue)
	return curValue
end


function GamePlayer:getMainPlayer()

	return self.tMainPlayer
end

function GamePlayer:getPlayerByUserId(iUserId)

	local bFind = false
	for i=1,#self.tGamePlayer do
		if self.tGamePlayer[i]["ullUserID"] == iUserId then
			return self.tGamePlayer[i]
		end
	end
	return nil
end

function GamePlayer:getPlayerBySeverSeat(iServerSeat)

	local bFind = false
	for i=1,#self.tGamePlayer do
		if self.tGamePlayer[i]["seat"] == iServerSeat then
			return self.tGamePlayer[i]
		end
	end
	return nil
end

function GamePlayer:getPlayerBySeat(iSeat)

	if self.tGamePlayer[iSeat] then
		return self.tGamePlayer[iSeat]
	end
	return nil
end

function GamePlayer:isPlayerByUserId(iUserId)

	local bFind = false
	for i=1,#self.tGamePlayer do
		if iUserId and self.tGamePlayer[i]["ullUserID"] == iUserId then
			bFind = true
			break
		end
	end
	return bFind
end

function GamePlayer:addPlayerInfo(tPlayer,bMain)

	local bFind = false
	for i=1,#self.tGamePlayer do
		if tPlayer["ullUserID"] and self.tGamePlayer[i]["ullUserID"] == tPlayer["ullUserID"] then
			bFind = true
			table.merge(self.tGamePlayer[i],tPlayer)
			if tPlayer["ullUserID"] == self.tGamePlayer[i]["ullUserID"] then
				table.merge(self.tGamePlayer[i],tPlayer)
			end
			if bMain then
				self.tMainPlayer = self.tGamePlayer[i]
			end

			break
		end
	end

	if not bFind then
		if #self.tGamePlayer > G_GameDefine.nMaxPlayerCount then
			release_print("***********addPlayerInfo:Error user max!*************")
			dump(self.tGamePlayer)
			dump(tPlayer)
			return bFind
		end
		local iNum = #self.tGamePlayer + 1
		self.tGamePlayer[iNum] = {}
		table.merge(self.tGamePlayer[iNum],GamePlayer.initInfo)
		table.merge(self.tGamePlayer[iNum],tPlayer)
		if bMain then
			self.tMainPlayer = self.tGamePlayer[iNum]
		end
	end
	return bFind
end

return GamePlayer
