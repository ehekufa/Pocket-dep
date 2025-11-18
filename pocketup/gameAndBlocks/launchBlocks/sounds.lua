return {
    playSound = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o)
        if infoBlock[2] and infoBlock[2][1] and infoBlock[2][1][2] ~= nil then
            local soundId = infoBlock[2][1][2]
            local soundFile = obj_path .. '/sound_' .. soundId .. '.mp3'

            local lua = [[
    pcall(function()
        if not playSounds[ ]] .. soundId .. [[ ] then
            playSounds[ ]] .. soundId .. [[ ] = {}
        end
        local sound = audio.loadSound(']] .. soundFile .. [[', system.DocumentsDirectory)
        local channel = audio.play(sound)
        table.insert(playSounds[ ]] .. soundId .. [[ ], {sound = sound, channel = channel})
    end)
            ]]
            return lua
        end
    end,

    playSoundAndWait = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o)
        local soundId = infoBlock[2][1][2]
        local lua = [[
    local sound
    pcall(function()
        if not playSounds[ ]] .. soundId .. [[ ] then
            playSounds[ ]] .. soundId .. [[ ] = {}
        end
        sound = audio.loadSound(']] .. obj_path .. [[/sound_]] .. soundId .. [[.mp3', system.DocumentsDirectory)
        local channel = audio.play(sound)
        table.insert(playSounds[ ]] .. soundId .. [[ ], {sound = sound, channel = channel})
    end)
    local time = audio.getDuration(sound)
    threadFun.wait(time)
        ]]
        return lua
    end,

    stopSound = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][1][2] ~= nil then
            local soundId = infoBlock[2][1][2]
            local lua = [[
    pcall(function()
        if playSounds[ ]] .. soundId .. [[ ] then
            for _, soundData in ipairs(playSounds[ ]] .. soundId .. [[ ]) do
                audio.stop(soundData.channel)
                audio.dispose(soundData.sound)
            end
            playSounds[ ]] .. soundId .. [[ ] = nil
        end
    end)
            ]]
            return lua
        end
    end,

    stopAllSounds = function()
        local lua = [[
    pcall(function()
        for soundId, sounds in pairs(playSounds) do
            for _, soundData in ipairs(sounds) do
                audio.stop(soundData.channel)
                audio.dispose(soundData.sound)
            end
        end
        playSounds = {}
    end)
        ]]
        return lua
    end,

    setVolumeSound = function(infoBlock, object, images, sounds, make_all_formulas)
        local lua = [[
    pcall(function()
        local volume = ]] .. make_all_formulas(infoBlock[2][1], object) .. [[
        audio.setVolume(volume/100)
    end)
        ]]
        return lua
    end,

    editVolumeSound = function(infoBlock, object, images, sounds, make_all_formulas)
        local lua = [[
    pcall(function()
        local volume = ]] .. make_all_formulas(infoBlock[2][1], object) .. [[
        audio.setVolume(audio.getVolume() + volume/100)
    end)
        ]]
        return lua
    end,

    playSoundId = function (infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o)
        local soundId = make_all_formulas(infoBlock[2][1], object)
        local lua = [[
        local sound
        local soundId = ]]..soundId..[[
        pcall(function()
            if not playSounds[soundId] then
                playSounds[soundId] = {}
            end
            sound = audio.loadSound(']] .. obj_path .. [[/sound_'..soundId..'.mp3', system.DocumentsDirectory)
            local channel = audio.play(sound)
            table.insert(playSounds[ ]] .. soundId .. [[ ], {sound = sound, channel = channel})
        end)
            ]]
        return lua
    end,

    playSoundIdAndWait = function (infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o)
        local soundId = make_all_formulas(infoBlock[2][1], object)
        local lua = [[
        local sound
        local soundId = ]]..soundId..[[
        pcall(function()
            if not playSounds[soundId] then
                playSounds[soundId] = {}
            end
            sound = audio.loadSound(']] .. obj_path .. [[/sound_'..soundId..'.mp3', system.DocumentsDirectory)
            local channel = audio.play(sound)
            table.insert(playSounds[ ]] .. soundId .. [[ ], {sound = sound, channel = channel})
        end)
        local time = audio.getDuration(sound)
        threadFun.wait(time)
            ]]
        return lua
    end,

    setVolumeSoundSpecific = function(infoBlock, object, images, sounds, make_all_formulas)
        local soundId = infoBlock[2][1][2]
        
        local lua = [[
        pcall(function()
            local sound = playSounds[ ]]..soundId..[[ ]
            if sound then
                local volume = ]]..make_all_formulas(infoBlock[2][2], object).."\n"..[[ 
                audio.setVolume(volume/100, {channel = sound.channel})
            else
                print("Failed to set id "..tostring(]]..soundId..[[).." volume: not loaded yet")
            end
        end)
        ]]

        return lua
    end,

    setVolumeSoundIdSpecific = function(infoBlock, object, images, sounds, make_all_formulas)
        local soundId = make_all_formulas(infoBlock[2][1], object)

        local lua = [[
        pcall(function()
            local sound = playSounds[ ]]..soundId..[[ ]
            if sound then
                local volume = ]]..make_all_formulas(infoBlock[2][2], object).."\n"..[[ 
                audio.setVolume(volume/100, {channel = sound.channel})
            else
                print("Failed to set id "..tostring(]]..soundId..[[).." volume: not loaded yet")
            end
        end)
        ]]

        print(lua)

        return lua
    end
}