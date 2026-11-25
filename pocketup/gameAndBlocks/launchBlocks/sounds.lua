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
        local path = ']] .. soundFile .. [['
        local sound = loadedSounds[path]
        if not sound then
            sound = audio.loadSound(path, system.DocumentsDirectory)
            loadedSounds[path] = sound
        end
        if sound then
            local channel = audio.play(sound)
            if channel and channel > 0 then
                table.insert(playSounds[ ]] .. soundId .. [[ ], {sound = sound, channel = channel})
            end
        end
    end)
            ]]
            return lua
        end
    end,

    playSoundAndWait = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o)
        if not (infoBlock[2] and infoBlock[2][1] and infoBlock[2][1][2] ~= nil) then
            return ''
        end
        local soundId = infoBlock[2][1][2]
        local soundFile = obj_path .. '/sound_' .. soundId .. '.mp3'
        local lua = [[
    local sound
    pcall(function()
        if not playSounds[ ]] .. soundId .. [[ ] then
            playSounds[ ]] .. soundId .. [[ ] = {}
        end
        local path = ']] .. soundFile .. [['
        sound = loadedSounds[path]
        if not sound then
            sound = audio.loadSound(path, system.DocumentsDirectory)
            loadedSounds[path] = sound
        end
        if sound then
            local channel = audio.play(sound)
            if channel and channel > 0 then
                table.insert(playSounds[ ]] .. soundId .. [[ ], {sound = sound, channel = channel})
            end
        end
    end)
    if sound then
        local time = audio.getDuration(sound)
        if time and time > 0 then
            threadFun.wait(time)
        end
    end
        ]]
        return lua
    end,

    stopSound = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2] and infoBlock[2][1] and infoBlock[2][1][2] ~= nil then
            local soundId = infoBlock[2][1][2]
            local lua = [[
    pcall(function()
        if playSounds[ ]] .. soundId .. [[ ] then
            for _, soundData in ipairs(playSounds[ ]] .. soundId .. [[ ]) do
                if soundData.channel then
                    audio.stop(soundData.channel)
                end
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
        for _, list in pairs(playSounds) do
            for _, soundData in ipairs(list) do
                if soundData.channel then
                    audio.stop(soundData.channel)
                end
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
        audio.setVolume(volume / 100)
    end)
        ]]
        return lua
    end,

    editVolumeSound = function(infoBlock, object, images, sounds, make_all_formulas)
        local lua = [[
    pcall(function()
        local volume = ]] .. make_all_formulas(infoBlock[2][1], object) .. [[
        audio.setVolume(audio.getVolume() + volume / 100)
    end)
        ]]
        return lua
    end,

    playSoundId = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o)
        local soundIdExpr = make_all_formulas(infoBlock[2][1], object)
        local lua = [[
        pcall(function()
            local soundId = ]] .. soundIdExpr .. [[
            if not playSounds[soundId] then
                playSounds[soundId] = {}
            end
            local path = ']] .. obj_path .. [[/sound_' .. tostring(soundId) .. '.mp3'
            local sound = loadedSounds[path]
            if not sound then
                sound = audio.loadSound(path, system.DocumentsDirectory)
                loadedSounds[path] = sound
            end
            if sound then
                local channel = audio.play(sound)
                if channel and channel > 0 then
                    table.insert(playSounds[soundId], {sound = sound, channel = channel})
                end
            end
        end)
            ]]
        return lua
    end,

    playSoundIdAndWait = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o)
        local soundIdExpr = make_all_formulas(infoBlock[2][1], object)
        local lua = [[
        local sound
        pcall(function()
            local soundId = ]] .. soundIdExpr .. [[
            if not playSounds[soundId] then
                playSounds[soundId] = {}
            end
            local path = ']] .. obj_path .. [[/sound_' .. tostring(soundId) .. '.mp3'
            sound = loadedSounds[path]
            if not sound then
                sound = audio.loadSound(path, system.DocumentsDirectory)
                loadedSounds[path] = sound
            end
            if sound then
                local channel = audio.play(sound)
                if channel and channel > 0 then
                    table.insert(playSounds[soundId], {sound = sound, channel = channel})
                end
            end
        end)
        if sound then
            local time = audio.getDuration(sound)
            if time and time > 0 then
                threadFun.wait(time)
            end
        end
            ]]
        return lua
    end,

    setVolumeSoundSpecific = function(infoBlock, object, images, sounds, make_all_formulas)
        if not (infoBlock[2] and infoBlock[2][1] and infoBlock[2][1][2] ~= nil) then
            return ''
        end
        local soundId = infoBlock[2][1][2]
        local lua = [[
        pcall(function()
            local soundsList = playSounds[ ]] .. soundId .. [[ ]
            if soundsList then
                local volume = ]] .. make_all_formulas(infoBlock[2][2], object) .. [[
                for _, soundData in ipairs(soundsList) do
                    if soundData.channel then
                        audio.setVolume(volume / 100, {channel = soundData.channel})
                    end
                end
            end
        end)
        ]]
        return lua
    end,

    setVolumeSoundIdSpecific = function(infoBlock, object, images, sounds, make_all_formulas)
        local soundIdExpr = make_all_formulas(infoBlock[2][1], object)
        local lua = [[
        pcall(function()
            local soundsList = playSounds[ ]] .. soundIdExpr .. [[ ]
            if soundsList then
                local volume = ]] .. make_all_formulas(infoBlock[2][2], object) .. [[
                for _, soundData in ipairs(soundsList) do
                    if soundData.channel then
                        audio.setVolume(volume / 100, {channel = soundData.channel})
                    end
                end
            end
        end)
        ]]
        return lua
    end
}
