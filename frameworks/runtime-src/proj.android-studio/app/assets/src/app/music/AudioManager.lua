
local AudioManager = class("AudioManager")

function AudioManager:ctor()
	
end

-- 卸载音乐
function AudioManager:unloadSound(strName)
    audio.unloadSound(strName)
end

-- 播放背景音乐
function AudioManager:playBackMusic(strName, bLoop)

    local bMusic = cc.UserDefault:getInstance():getBoolForKey("Music", false)
    if not bMusic then
        return
    end

    if bLoop == nil then
        bLoop = true
    end

    audio.playMusic(strName, bLoop)
end

-- 暂停背景音乐
function AudioManager:pauseBackMusic()

    audio.pauseMusic()
end

-- 停止背景音乐
function AudioManager:stopBackMusic()

    audio.stopMusic()
end

-- 恢复背景音乐
function AudioManager:resumeBackMusic()

    local bMusic = cc.UserDefault:getInstance():getBoolForKey("Music", false)
    if not bMusic then
        return
    end

    audio.resumeMusic()
end

-- 播放声音
function AudioManager:playSound(strSound, bLoop)

    local bSound = cc.UserDefault:getInstance():getBoolForKey("Sound", false)
    if not bSound then
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
function AudioManager:pauseSound(handle)

    audio.pauseSound(handle)
end

-- 停止声音
function AudioManager:stopSound(handle)

    audio.stopSound(handle)
end

-- 恢复声音
function AudioManager:resumeSound(handle)

    audio.resumeSound(handle)
end

return AudioManager