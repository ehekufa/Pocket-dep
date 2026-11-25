return {
    ["timer3"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local rep = make_all_formulas(infoBlock[2][1], object)
        local time = make_all_formulas(infoBlock[2][2], object)
        return "for i=1, type(" .. rep .. ") == 'number' and " .. rep .. " or 0 do\
            threadFun.wait(type(" .. time .. ") == 'number' and (" .. time .. "*1000) or 0)"
    end,

    ["endTimer2"] = function()
        return "coroutine.yield()\nend"
    end,

    ["wait"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local time = make_all_formulas(infoBlock[2][1], object)
        return "threadFun.wait(" .. time .. "*1000)"
    end,

    ["commentary"] = function()
    end,

    ["cycleForever"] = function()
        return "while true do"
    end,

    ["endCycleForever"] = function()
        return
        "coroutine.yield()\
        end"
    end,

    ["ifElse (2)"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local condition = make_all_formulas(infoBlock[2][1], object)
        return "if " .. condition .. " then"
    end,

    ["if"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local condition = make_all_formulas(infoBlock[2][1], object)
        return "if " .. condition .. " then"
    end,

    ["else"] = function()
        return "else"
    end,

    ["endIf"] = function()
        return "end"
    end,

    ["repeatIsTrue"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local condition = make_all_formulas(infoBlock[2][1], object)
        return "while " .. condition .. " do"
    end,

    ["repeat"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local rep = make_all_formulas(infoBlock[2][1], object)
        return "for i=1, type(" .. rep .. ") == 'number' and " .. rep .. " or 0, 1 do"
    end,

    ["endRepeat"] = function()
        return "coroutine.yield()\
        end"
    end,

    ["waitIfTrue2"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local arg1 = make_all_formulas(infoBlock[2][1], object)
        return "while not " .. arg1 .. " do\
        coroutine.yield()\
        end"
    end,

    ["for"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local one = make_all_formulas(infoBlock[2][1], object)
        local _end = make_all_formulas(infoBlock[2][2], object)
        max_fors = max_fors + 1
        local lua = ''
        lua = lua ..
        "for i" ..
        max_fors ..
        " = (type(" ..
        one .. ") == 'number' and " .. one .. " or 0) , type(" .. _end .. ") == 'number' and " .. _end .. " or 0, 1 do\n"
        if (infoBlock[2][3][2] ~= nil) then
            if infoBlock[2][3][1] == "globalVariable" then
                lua = lua .. "var_" .. infoBlock[2][3][2] .. " = i" .. max_fors .. "\n"
            else
                lua = lua .. "target.var_" .. infoBlock[2][3][2] .. " = i" .. max_fors .. "\n"
            end
        end
        return lua
    end,

    ["endFor"] = function()
        return "end"
    end,

    ["foreach"] = function(infoBlock, object, images, sounds, make_all_formulas)
        max_fors = max_fors + 1
        local arrId = infoBlock[2][1][2] or "nil"
        local varId = infoBlock[2][2][2] or "nil"
        local arrPrefix = (infoBlock[2][1][1] == "globalArray") and "" or "target."
        local varPrefix = (infoBlock[2][2][1] == "globalVariable") and "" or "target."
        local varExpr = varPrefix .. "var_" .. varId
        local textExpr = varPrefix .. "varText_" .. varId
        local lua = ''
        lua = lua .. 'for key' .. max_fors .. ', value' .. max_fors .. ' in pairs(' .. arrPrefix .. 'list_' .. arrId .. ') do\n'
        lua = lua .. varExpr .. ' = value' .. max_fors .. '\n'
        lua = lua .. 'if ' .. textExpr .. ' then\n ' .. textExpr .. '.text = type(' .. varExpr .. ")==" .. "'boolean'" ..
            ' and (' .. varExpr .. ' and app.words[373] or app.words[374]) or type(' .. varExpr .. ")==" .. "'table'" ..
            ' and encodeList(' .. varExpr .. ') or ' .. varExpr .. '\nend'
        return lua
    end,

    ["endForeach"] = function()
        return "end"
    end,

    ["deleteScene"] = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][1][2] == nil then
            return ''
        end
        local lua = "pcall(function()\n"
        lua = lua .. "deleteScene(" .. infoBlock[2][1][2] .. ")"
        lua = lua .. "\nend)"
        return lua
    end,

    ["continueScene"] = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id,
                                 scene_path, options, o)
        if infoBlock[2][1][2] == nil then
            return ''
        end
        local id = infoBlock[2][1][2]

        local lua = "pcall(function()\n"
        lua = lua ..
            "moveScene()\
        if not Scenes[" .. id .. "] then\
            scene_" .. infoBlock[2][1][2] .. "()\
            return true\
        end\
        \
        local scene = Scenes[" .. id .. "]\
        Scenes.select = scene\
        \
        globalConstants.touchX = scene.globalConstants.touchX\
        globalConstants.touchY = scene.globalConstants.touchY\
        globalConstants.isTouch = false\
        \
        thread.timers = scene.threads\
        for i = 1 , #thread.timers do\
            timer.resume(thread.timers[i])\
        end\
        mainGroup = scene.mainGroup\
        mainGroup.isVisible = true\
        \
        \
        WebViews = scene.WebViews\
        textFields = scene.textFields\
        objects = scene.objects\
        \
        events_touchBack = scene.events_touchBack\
        events_keypressed = scene.events_keypressed\
        events_endKeypressed = scene.events_endKeypressed\
        events_touchScreen = scene.events_touchScreen\
        events_movedScreen = scene.events_movedScreen\
        events_onTouchScreen = scene.events_onTouchScreen\
        events_whenTheTruth = scene.events_whenTheTruth\
        playSounds = scene.playSounds\
        playingSounds = scene.playingSounds\
        loadedSounds = scene.loadedSounds or loadedSounds\
        \
        joysticks = scene.joysticks\
        Timers = {}\
        Timers_max = 0\
        \
        \
        for key, value in pairs(objects) do\
            pcall(function()\
                transition.resume(value)\
            end)\
            pcall(function()\
                if value.physicsReload then\
                    value:physicsReload()\
                end\
            end)\
        end\
        for key, value in pairs(playSounds) do\
            for key2, value2 in pairs(value) do\
                audio.resume(value2.channel)\
            end\
        end\
        "
        return lua .. "\nend)\
        removeTheard()\ncoroutine.yield()"
    end,

    ["runScene"] = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][1][2] == nil then
            return ''
        end
        local lua = "pcall(function()\n"
        lua = lua ..
            "moveScene()\
        if Scenes[" .. infoBlock[2][1][2] .. "] then\
            deleteScene(" .. infoBlock[2][1][2] .. ")\
        end\
        scene_" .. infoBlock[2][1][2] .. "()"
        lua = lua .. "\nend)\
        removeTheard()\ncoroutine.yield()"
        return lua
    end,

    ["exitGame"] = function()
        local lua = "pcall(function()\n"
        lua = lua ..
        "native.setProperty( \"androidSystemUiVisibility\", \"default\" )\ntimer.new(0, function()\ndisplay.save(mainGroup,{ filename=myScene..'/icon.png', baseDir=system.DocumentsDirectory, backgroundColor={1,1,1,1}})\nfunBackListener2({keyName='deleteBack', phase='up'})\nend)"
        return lua .. "\nend)"
    end,

    ["stopScript"] = function()
        return "removeTheard()\ncoroutine.yield(true)"
    end,

    clone = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path,
                     options, o)
        local lua = [[
        pcall(function()
            %s
            local myClone
            if target.parent_obj.countImages > 0 then
                myClone = display.newImage(target.image_path, system.DocumentsDirectory, target.x, target.y)
                myClone.image_path = target.image_path
                for k, v in pairs(target.parent_obj.namesVars) do
                    myClone[v] = 0
                end
                for k, v in pairs(target.parent_obj.namesLists) do
                    myClone[v] = {}
                end
            else
                myClone = display.newImage('images/notVisible.png', target.x, target.y)
            end
            target.group:insert(myClone)
            myClone.group = target.group
            myClone.events_whenTheTruth = target.events_whenTheTruth
            for i = 1, #myClone.events_whenTheTruth do
                myClone.events_whenTheTruth[i](myClone)
            end

            myClone:addEventListener('touch', function(event)
                if event.phase == 'began' then
                    local newIdTouch = globalConstants.touchId + 1
                    globalConstants.touchId = newIdTouch
                    globalConstants.keysTouch['touch_' .. newIdTouch] = event.id
                    globalConstants.touchsXId[event.id] = (event.x - mainGroup.x) / mainGroup.xScale
                    globalConstants.touchsYId[event.id] = -(event.y - mainGroup.y) / mainGroup.yScale
                    globalConstants.isTouchsId[event.id] = true
                    globalConstants.isTouch = true
                    globalConstants.touchX = (event.x - mainGroup.x) / mainGroup.xScale
                    globalConstants.touchY = -(event.y - mainGroup.y) / mainGroup.yScale
                    display.getCurrentStage():setFocus(event.target, event.id)
                    event.target.isTouch = true
                    for key, value in pairs(objects) do
                        for i = 1, #events_touchScreen[key] do
                            events_touchScreen[key][i](value)
                            for i2 = 1, #value.clones do
                                events_touchScreen[key][i](value.clones[i2])
                            end
                        end
                    end
                    for i = 1, #myClone.parent_obj.events_touchObject do
                        myClone.parent_obj.events_touchObject[i](event.target)
                    end
                elseif event.phase == 'moved' then
                    globalConstants.touchsXId[event.id] = (event.x - mainGroup.x) / mainGroup.xScale
                    globalConstants.touchsYId[event.id] = -(event.y - mainGroup.y) / mainGroup.yScale
                    globalConstants.touchX = (event.x - mainGroup.x) / mainGroup.xScale
                    globalConstants.touchY = -(event.y - mainGroup.y) / mainGroup.yScale
                    for key, value in pairs(objects) do
                        for i = 1, #events_movedScreen[key] do
                            events_movedScreen[key][i](value)
                            for i2 = 1, #value.clones do
                                events_movedScreen[key][i](value.clones[i2])
                            end
                        end
                    end
                    for i = 1, #myClone.parent_obj.events_movedObject do
                        myClone.parent_obj.events_movedObject[i](event.target)
                    end
                else
                    display.getCurrentStage():setFocus(event.target, nil)
                    event.target.isTouch = nil
                    globalConstants.touchsXId[event.id] = nil
                    globalConstants.touchsYId[event.id] = nil
                    globalConstants.isTouchsId[event.id] = nil
                    if pocketupFuns.getCountTouch(globalConstants.isTouchsId) == 0 then
                        globalConstants.keysTouch = {}
                        globalConstants.isTouch = false
                    end
                    for key, value in pairs(objects) do
                        for i = 1, #events_onTouchScreen[key] do
                            events_onTouchScreen[key][i](value)
                            for i2 = 1, #value.clones do
                                events_onTouchScreen[key][i](value.clones[i2])
                            end
                        end
                    end
                    for i = 1, #myClone.parent_obj.events_onTouchObject do
                        myClone.parent_obj.events_onTouchObject[i](event.target)
                    end
                end
                return true
            end)

            myClone.xScale = target.xScale
            myClone.yScale = target.yScale
            myClone.alpha = target.alpha
            myClone.rotation = target.rotation
            myClone.numberImage = target.numberImage
            myClone.parent_obj = target.parent_obj
            myClone.fill.effect = 'filter.brightness'
            myClone.property_brightness = target.property_brightness
            myClone.fill.effect.intensity = (target.property_brightness) / 100 - 1
            myClone.parent_obj = target.parent_obj or target
            target.parent_obj.clones[#target.parent_obj.clones + 1] = myClone
            myClone.idClone = #target.parent_obj.clones
            myClone.tableVarShow = {}
            myClone.origWidth = target.origWidth
            myClone.origHeight = target.origHeight
            myClone.width = target.width
            myClone.height = target.height
            myClone.property_size = target.property_size
            myClone.isVisible = target.isVisible
            myClone.physicsReload = target.physicsReload or function(ob) end
            myClone.physicsType = target.physicsType or 'static'
            myClone.physicsTable = target.physicsTable and utils.deepCopy(target.physicsTable) or {}
            myClone:physicsReload()
            myClone.property_color = target.property_color
            local r = pocketupFuns.sin(target.property_color - 22 + 56) / 2 + 0.724
            local g = pocketupFuns.cos(target.property_color + 56) / 2 + 0.724
            local b = pocketupFuns.sin(target.property_color + 22 + 56) / 2 + 0.724
            myClone:setFillColor(r, g, b)
            myClone.touchesObjects = {}

            myClone.gravityScale = target.gravityScale
            myClone.isSensor = target.isSensor
            myClone.parent_obj.events_startClone = myClone.parent_obj.events_startClone or (events_startClone or {})

            timer.new(0, function()
                if not myClone or not myClone.x then return 0 end
                for i = 1, #myClone.parent_obj.events_startClone do
                    myClone.parent_obj.events_startClone[i](myClone)
                end
                if not myClone.addEventListener then return 0 end
                myClone:addEventListener('collision', function(event)
                    if not (event.target and event.target.touchesObjects and event.other and event.other.parent_obj) then return end
                    if event.phase == 'began' then
                        event.target.touchesObjects['obj_' .. event.other.parent_obj.idObject] = true
                        timer.new(0, function()
                            if event.target and event.target.x and event.other and event.other.parent_obj then
                                for i = 1, #myClone.parent_obj.events_collision do
                                    myClone.parent_obj.events_collision[i](event.target, event.other.parent_obj.nameObject)
                                end
                            end
                        end)
                    elseif event.phase == 'ended' then
                        event.target.touchesObjects['obj_' .. event.other.parent_obj.idObject] = nil
                        timer.new(0, function()
                            if event.target and event.target.x and event.other and event.other.parent_obj then
                                for i = 1, #myClone.parent_obj.events_endedCollision do
                                    myClone.parent_obj.events_endedCollision[i](event.target, event.other.parent_obj.nameObject)
                                end
                            end
                        end)
                    end
                end)
            end)
        end)
    ]]

        local targetDeclaration = ""
        if infoBlock[2][1][2] ~= nil then
            targetDeclaration = string.format("local target = objects['object_%s']", infoBlock[2][1][2])
        end

        return string.format(lua, targetDeclaration)
    end,

    ["deleteClone"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local lua = "pcall(function()\n"
        lua = lua ..
            "if target then\
            if target.idClone and target.idClone >= 1 then\
                table.remove(target.parent_obj.clones, target.idClone)\
                for i=1, #target.parent_obj.clones do\
                    target.parent_obj.clones[i].idClone = i\
                end\
            end\
            display.remove(target)\
        end"
        lua = lua .. "\nend)\nremoveTheard()\ncoroutine.yield()"
        return lua
    end,

    ["broadcastFunction"] = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][1][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua .. "timer.new(0, function() broadcastFunction('fun_" .. infoBlock[2][1][2] .. "')end)"
            return lua .. "\nend)"
        end
    end,

    ["broadcastFunctionAndWait"] = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][1][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua .. "broadcastFunction('fun_" .. infoBlock[2][1][2] .. "')"
            return lua .. "\nend)"
        end
    end,

    ["broadcastFun>allObjects"] = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][1][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua ..
            "local function broadcastFunction(nameFunction)\nfor key, value in pairs(objects) do\nfor i=1, #events_function[key][nameFunction] do\nevents_function[key][nameFunction][i](value)\nend\nend\nend\nbroadcastFunction('fun_" ..
            infoBlock[2][1][2] .. "')"
            return lua .. "\nend)"
        end
    end,

    ["broadcastFun>allClones"] = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][1][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua ..
            "local function broadcastFunction(nameFunction)\nfor key, value in pairs(objects) do\nfor i=1, #events_function[key][nameFunction] do\nfor i2=1, #value.clones do\nevents_function[key][nameFunction][i](value.clones[i2])\nend\nend\nend\nend\nbroadcastFunction('fun_" ..
            infoBlock[2][1][2] .. "')"
            return lua .. "\nend)"
        end
    end,

    ["broadcastFun>objectAndClones"] = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path,
                                                scene_id, scene_path, options, o)
        if infoBlock[2][2][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua ..
            "local function broadcastFunction(nameFunction)\nlocal key = 'object_" ..
            (infoBlock[2][1][2] == nil and obj_id or infoBlock[2][1][2]) ..
            "'\nlocal value = objects[key]\nfor i=1, #events_function[key][nameFunction] do\nevents_function[key][nameFunction][i](value)\nfor i2=1, #value.clones do\nevents_function[key][nameFunction][i](value.clones[i2])\nend\nend\nend\nbroadcastFunction('fun_" ..
            infoBlock[2][2][2] .. "')"
            return lua .. "\nend)"
        end
    end,

    ["broadcastFun>object"] = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id,
                                       scene_path, options, o)
        if infoBlock[2][2][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua ..
            "local function broadcastFunction(nameFunction)\nlocal key = 'object_" ..
            (infoBlock[2][1][2] == nil and obj_id or infoBlock[2][1][2]) ..
            "'\nlocal value = objects[key]\nfor i=1, #events_function[key][nameFunction] do\nevents_function[key][nameFunction][i](value)\nend\nend\nbroadcastFunction('fun_" ..
            infoBlock[2][2][2] .. "')"
            return lua .. "\nend)"
        end
    end,

    ["broadcastFun>clones"] = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id,
                                       scene_path, options, o)
        if infoBlock[2][2][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua ..
            "local function broadcastFunction(nameFunction)\nlocal key = 'object_" ..
            (infoBlock[2][1][2] == nil and obj_id or infoBlock[2][1][2]) ..
            "'\nlocal value = objects[key]\nfor i=1, #events_function[key][nameFunction] do\nfor i2=1, #value.clones do\nevents_function[key][nameFunction][i](value.clones[i2])\nend\nend\nend\nbroadcastFunction('fun_" ..
            infoBlock[2][2][2] .. "')"
            return lua .. "\nend)"
        end
    end,

    ["addNameClone"] = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id,
                                scene_path, options, o)
        local lua = "pcall(function()\n"
        lua = lua ..
        "target.myName = " ..
        make_all_formulas(infoBlock[2][1], object) ..
        "\ntableNamesClones[target.myName] = target\ntarget.nameObject = 'object_" .. obj_id .. "'"
        return lua .. "\nend)"
    end,

    ["broadcastFun>nameClone"] = function(infoBlock, object, images, sounds, make_all_formulas)
        if infoBlock[2][2][2] ~= nil then
            local lua = "pcall(function()\n"
            lua = lua ..
                "local function broadcastFunction(nameFunction)\
                local value = tableNamesClones[" .. make_all_formulas(infoBlock[2][1], object) .. "]\
                local key = value.nameObject\
                for i=1, #events_function[key][nameFunction] do\
                    events_function[key][nameFunction][i](value)\
                end\
                value = nil\
                key = nil\
            end\
            broadcastFunction('fun_" .. infoBlock[2][2][2] .. "')"
            return lua .. "\nend)"
        end
    end,

    ["whenTheTruth"] = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id,
                                scene_path, options, o, mainGroup, videos)
        local lua = "pcall(function()\n"
        return lua .. "\nend)"
    end,
    ["endWhenTheTruth"] = function(infoBlock, object, images, sounds, make_all_formulas, obj_id, obj_path, scene_id,
                                   scene_path, options, o, mainGroup, videos)
        local lua = "pcall(function()\n"
        return lua .. "\nend)"
    end,

    ["deleteAllClones"] = function(infoBlock, object, images, sounds, make_all_formulas)
        local lua = "pcall(function()\n"
        if (infoBlock[2][1][2] ~= nil) then
            lua = lua .. "\nlocal target = objects['object_" .. infoBlock[2][1][2] .. "']"
        end
        lua = lua .. "if target and target.parent_obj and target.parent_obj.clones then\n"
        lua = lua .. "    for i = #target.parent_obj.clones, 1, -1 do\n"
        lua = lua .. "        local clone = target.parent_obj.clones[i]\n"
        lua = lua ..
        "        display.remove(clone)\nif clone.myName then if tableNamesClones[clone.myName] then tableNamesClones[clone.myName] = nil end end\nclone.x = nil\nclone = nil\n"
        lua = lua .. "        table.remove(target.parent_obj.clones, i)\n"
        lua = lua .. "    end\n"
        lua = lua .. "end\n"
        return lua .. "end)"
    end,

    ["drawMode"] = function(infoBlock)
        local lua = "pcall(function()\n"
        lua = lua .. "display.setDrawMode( 'wireframe', " .. (infoBlock[2][1][2] == "on" and "true" or "false") .. " )"
        lua = lua ..
        "\ndisplay.setDefault( 'background', " ..
        (infoBlock[2][1][2] == "on" and "true" or "false") ..
        " and 0 or 1, " ..
        (infoBlock[2][1][2] == "on" and "true" or "false") ..
        " and 0 or 1, " .. (infoBlock[2][1][2] == "on" and "true" or "false") .. " and 0 or 1)\n"
        return lua .. "\nend)"
    end,
}
