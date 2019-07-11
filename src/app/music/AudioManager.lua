
local M = class("AudioManager")

function M:ctor()
	
end

-- 卸载音乐
function M:unloadSound()
    audio.unloadSound(self.musicName)
end

-- 播放背景音乐
function M:playBackMusic(strName, bLoop)
    if self.musicName  == nil  then 
        self.musicName = strName 
    else
        if self.musicName == strName then 
            self.changeScene = false
        else
            self.changeScene = true 
            self.musicName = strName
        end 
    end
    local nMusic = cc.UserDefault:getInstance():getIntegerForKey("Music", 0)
    if nMusic ~= 1 then
        return
    end
    if bLoop == nil then
        bLoop = true
    end
    audio.playMusic(self.musicName, bLoop)
end

-- 暂停背景音乐
function M:pauseBackMusic()
    audio.pauseMusic()
end

-- 停止背景音乐
function M:stopBackMusic()
    audio.stopMusic()
end

-- 恢复背景音乐
function M:resumeBackMusic()
    local nMusic = cc.UserDefault:getInstance():getIntegerForKey("Music", 0)
    if nMusic ~= 1 then
        return
    end
    if self.changeScene == true then 
        self:playBackMusic(self.musicName,true)
    else 
        audio.resumeMusic()
    end
end

-- 播放声音
function M:playSound(strSound, bLoop)
    local nSound = cc.UserDefault:getInstance():getIntegerForKey("Sound", 0)
    if nSound ~= 1 then
        return
    end

    if strSound == nil or strSound == "" then
        return
    end

    if bLoop == nil then
        bLoop = false
    end

    audio.playSound(strSound, isLoop)
end

-- 暂停声音
function M:pauseSound(handle)
    audio.pauseSound(handle)
end

-- 停止声音
function M:stopSound(handle)
    audio.stopSound(handle)
end

-- 恢复声音
function M:resumeSound(handle)
    audio.resumeSound(handle)
end

return M