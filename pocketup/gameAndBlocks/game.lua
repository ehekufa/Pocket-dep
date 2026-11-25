_G.lua = nil
local makeBlock_other = require("pocketup.gameAndBlocks.launchBlocks_other")
local makeBlock_cerberus = require("pocketup.gameAndBlocks.launchBlocks_cerberus")
local renameFormulas = calculateGameFormulas

function encodeList(event)
    if type(event) ~= "table" then
        return tostring(event or "")
    end
    local parts = {}
    for i = 1, #event do
        parts[i] = tostring(event[i])
    end
    return table.concat(parts, "\n")
end

local function make_all_formulas(formulas, object)
    local tableInfoObject = {
        {'size',"("..object..".property_size)"},
        {'direction',"("..object..".rotation)"},
        {'directionView',"("..object..".rotation/2)"},
        {'positionX',object..".x"},
        {'positionY',"(-("..object..".y))"},
        {'speedX', 'pocketupFuns.getLinearVelocity('..object..',"x")'},
        {'speedY', 'pocketupFuns.getLinearVelocity('..object..',"y")'},
        {'angularVelocity', '('..object..'.angularVelocity==nil and 0 or '..object..'.angularVelocity)'},
        {'transparency', "math.round((1-"..object..".alpha)*100)"},
        {"numberImage", object..".numberImage"},
        {"brightness",object..".property_brightness"},
        {'color', object..".property_color"},
        {"nameImage", "listNamesImages["..object..".numberImage]"},
        {"touchesFinger","("..object..".isTouch==true)"},
        {"touchesObject","pocketupFuns.countTouchesObjects("..object..")"},
        {'countImages', "#listNamesImages"},
    }
    for i = 1, #tableInfoObject do
        renameFormulas[tableInfoObject[i][1]] = tableInfoObject[i][2]
    end

    local parts = {"("}
    for i = 1, #formulas do
        local formula = formulas[i]
        if formula[1] == "number" then
            if type(formula[2]) == "number" or formula[2] == "." then
                parts[#parts + 1] = tostring(formula[2])
            else
                parts[#parts + 1] = "0"
            end
        elseif formula[1] == "text" then
            local escaped = tostring(formula[2] or "")
                :gsub("\\", "\\\\")
                :gsub("\r\n", "\\n")
                :gsub("\n", "\\n")
                :gsub("\r", "\\n")
                :gsub("'", "\\'")
            parts[#parts + 1] = " '" .. escaped .. "' "
        elseif formula[1] == "globalVariable" then
            parts[#parts + 1] = " var_" .. tostring(formula[2]) .. " "
        elseif formula[1] == "localVariable" then
            parts[#parts + 1] = " " .. object .. ".var_" .. tostring(formula[2]) .. " "
        elseif formula[1] == "globalArray" then
            parts[#parts + 1] = " list_" .. tostring(formula[2]) .. " "
        elseif formula[1] == "localArray" then
            parts[#parts + 1] = " " .. object .. ".list_" .. tostring(formula[2]) .. " "
        elseif formula[1] == "function" and formula[2] == "touchesObject2" then
            parts[#parts + 1] = " pocketupFuns.isTouchObject2(target, " .. tostring(formula[3]) .. ") "
        else
            parts[#parts + 1] = " " .. (renameFormulas[formula[2]] or "0") .. " "
        end
    end
    parts[#parts + 1] = ")"
    return table.concat(parts)
end

local isEvent = {
    start=true, touchObject=true, touchScreen=true, ["function"]=true, collision=true, changeBackground=true, startClone=true,
    movedObject=true, onTouchObject=true, movedScreen=true, onTouchScreen=true, touchBack=true, endedCollision=true,
    keypressed=true, endKeypressed = true, whenTheTruth = true
}

function _G.noremoveAllObjects()
    local stage = display.getCurrentStage()
    for i = stage.numChildren, 1, -1 do
        local child = stage[i]
        if child then
            child._notRemove = true
        end
    end
end

function _G.removeAllObjects()
    local stage = display.getCurrentStage()
    for i = stage.numChildren, 1, -1 do
        local child = stage[i]
        if child and child._notRemove ~= true then
            child:removeSelf()
        end
    end
end

function _G.scene_run_game(typeBack, paramsBack)
    BlocksAllHandlers = {}
    local moduleHandlers = {'data', 'control', 'textFields', 'sounds', 'physics', 'pen', 'particles', 'miniScenes', 'images', 'elementInterface', 'device', 'videos'}
    for _, module in ipairs(moduleHandlers) do
        for key, value in pairs(require('pocketup.gameAndBlocks.launchBlocks.'..module)) do
            BlocksAllHandlers[key] = value
        end
    end

    app.scene = "game"
    app.words = {}

    local isScriptsBack = false
    local dW, dH, dCX, dCY, sOX, sOY = display.actualContentWidth, display.contentHeight, CENTER_X, CENTER_Y, display.screenOriginX, display.screenOriginY

    native.setProperty("windowMode", "fullscreen")
    display.setDefault('background', 1, 1, 1)

    local options = plugins.json.decode(funsP['получить сохранение'](app.idProject..'/options')) or {}
    options.displayWidth = tonumber(options.displayWidth) or 720
    options.displayHeight = tonumber(options.displayHeight) or 1280
    if utils.isWin or utils.isSim then
        options.orientation = "vertical"
    end

    renameFormulas.displayWidth = "("..tostring(options.orientation == "vertical" and options.displayWidth or options.displayHeight)..")"
    renameFormulas.displayHeight = "("..tostring(options.orientation == "vertical" and options.displayHeight or options.displayWidth)..")"
    renameFormulas.displayActualWidth = "("..tostring(options.orientation == "vertical" and display.actualContentWidth or display.actualContentHeight)..")"
    renameFormulas.displayActualHeight = "("..tostring(options.orientation == "vertical" and display.actualContentHeight or display.actualContentWidth)..")"

    function _G.showOldScene()
        app.words = require("pocketup.modules.loadLanguage")
        native.setProperty("windowMode", "normal")
        display.setDrawMode('default')
        display.setDefault("background", 4/255, 34/255, 44/255)

        plugins.orientation.lock('portrait')

        display.screenOriginX, display.screenOriginY = sOX, sOY
        display.contentWidth, display.contentHeight = dW, dH
        display.contentCenterX = dCX
        CENTER_X = dCX
        CENTER_Y = dCY
        collectgarbage('collect')
        if not IsBuild then
            if typeBack == "scripts" then
                scene_scripts(paramsBack[1], paramsBack[2], paramsBack[3])
            elseif typeBack == "objects" then
                scene_objects(paramsBack[1], paramsBack[2], paramsBack[3])
            elseif typeBack == "scenes" then
                scene_scenes(paramsBack[1], paramsBack[2])
            end
        else
            os.exit()
        end
    end

    _G.max_fors = 0

    local luaChunks = {}
    local function emit(str)
        if str and str ~= "" then
            luaChunks[#luaChunks + 1] = str
        end
    end

    if true then
        local scenes = plugins.json.decode(funsP['получить сохранение'](app.idProject..'/scenes')) or {}
        if #scenes == 0 then
            showOldScene()
            return
        end

        if options.orientation == "horizontal" then
            emit("plugins.orientation.lock('landscape')\n")
        end

        emit([==[
system.activate('multitouch')
plugins.physics.start(true)
audio.setVolume(1.0, { channel = 0 })

local _imgDimCache = {}
local function getImageProperties(path, dir)
    if dir == system.DocumentsDirectory and _imgDimCache[path] then
        local c = _imgDimCache[path]
        return c[1], c[2]
    end
    local image = display.newImage(path, dir)
    if not image then
        return 0, 0
    end
    image.alpha = 0
    local width = image.width
    local height = image.height
    display.remove(image)
    if dir == system.DocumentsDirectory then
        _imgDimCache[path] = {width, height}
    end
    return width, height
end

local thread = require('plugins.thread')

local joysticks = {}
local Timers = {}
local Timers_max = 0
local globalConstants = {
    isTouch=false,
    touchX=0,
    touchY=0,
    touchId=0,
    keysTouch={},
    touchsXId={},
    touchsYId={},
    isTouchsId={}
}

local Scenes = {}

local pocketupFuns = {}
pocketupFuns.perlinNoise = function(x, y, seed)
    return plugins.perlin.new(x, y, seed)
end
pocketupFuns.sin = function(v)
    return math.sin(math.rad(v))
end
pocketupFuns.cos = function(v)
    return math.cos(math.rad(v))
end
pocketupFuns.tan = function(v)
    return math.tan(math.rad(v))
end
pocketupFuns.asin = function(v)
    return math.deg(math.asin(v))
end
pocketupFuns.acos = function(v)
    return math.deg(math.acos(v))
end
pocketupFuns.atan = function(v)
    return math.deg(math.atan(v))
end
pocketupFuns.atan2 = function(v, v2)
    return math.deg(math.atan2(v, v2))
end
pocketupFuns.roundUp = function(v)
    return math.floor(v) + 1
end
pocketupFuns.connect = function(v, v2, v3)
    return tostring(v) .. tostring(v2) .. (v3 == nil and '' or tostring(v3))
end
pocketupFuns.ternaryExpression = function(condition, answer1, answer2)
    return condition and answer1 or answer2
end
pocketupFuns.regularExpression = function(regular, expression)
    return string.match(expression, regular)
end
pocketupFuns.characterFromText = function(pos, value)
    return plugins.utf8.sub(value, pos, pos)
end

pocketupFuns.getLinearVelocity = function(object, xOrY)
    if object.physicsReload == nil then
        return 0
    else
        local vx, vy = object:getLinearVelocity()
        return xOrY == 'x' and vx or vy
    end
end
pocketupFuns.getEllementArray = function(element, array)
    return array[element] == nil and '' or array[element]
end
pocketupFuns.containsElementArray = function(array, value)
    for i = 1, #array do
        if array[i] == value then
            return true
        end
    end
    return false
end
pocketupFuns.getIndexElementArray = function(array, value)
    for i = 1, #array do
        if array[i] == value then
            return i
        end
    end
    return 0
end
pocketupFuns.levelingArray = function(array)
    return array
end
pocketupFuns.displayPositionColor = function(x, y)
    local hexColor = "#000000"
    local sx = (mainGroup and mainGroup.x or CENTER_X) + x * (mainGroup and mainGroup.xScale or 1)
    local sy = (mainGroup and mainGroup.y or CENTER_Y) - y * (mainGroup and mainGroup.yScale or 1)
    local function onColorSample(event)
        hexColor = utils.rgbToHex({
            math.round((event.r or 0) * 255),
            math.round((event.g or 0) * 255),
            math.round((event.b or 0) * 255)
        })
    end
    display.colorSample(sx, sy, onColorSample)
    return hexColor
end

globalConstants.getTouchXId = function(id)
    local answer = globalConstants.touchsXId[globalConstants.keysTouch['touch_'..id]]
    return answer == nil and 0 or answer
end
globalConstants.getTouchYId = function(id)
    local answer = globalConstants.touchsYId[globalConstants.keysTouch['touch_'..id]]
    return answer == nil and 0 or answer
end
pocketupFuns.getIsTouchId = function(id)
    return globalConstants.isTouchsId[globalConstants.keysTouch['touch_'..id]] == true
end
pocketupFuns.getCountTouch = function()
    local count = 0
    for _ in pairs(globalConstants.isTouchsId) do
        count = count + 1
    end
    return count
end
pocketupFuns.jsonEncode = function(table2)
    local tbl = nil
    pcall(function()
        tbl = plugins.json.decode(table2)
    end)
    if tbl == nil then
        return ''
    else
        local arr = {}
        for _, v in pairs(tbl) do
            arr[#arr + 1] = tostring(v)
        end
        return table.concat(arr, '\n')
    end
end
pocketupFuns.isTouchObject2 = function(target, id)
    return target.touchesObjects['obj_'..id] == true
end
pocketupFuns.countTouchesObjects = function(target)
    for _ in pairs(target.touchesObjects) do
        return true
    end
    return false
end
]==])

        local globalVariables = plugins.json.decode(funsP['получить сохранение'](app.idProject..'/variables')) or {}
        for i = 1, #globalVariables do
            emit("var_"..globalVariables[i][1].." = 0\n")
        end

        local globalArrays = plugins.json.decode(funsP['получить сохранение'](app.idProject..'/arrays')) or {}
        for i = 1, #globalArrays do
            emit("list_"..globalArrays[i][1].." = {}\n")
        end

        emit([==[
local myScene

local WebViews = {}
local textFields = {}
local objects = {}

local events_touchBack = {}
local events_keypressed = {}
local events_endKeypressed = {}
local events_touchScreen = {}
local events_movedScreen = {}
local events_onTouchScreen = {}

local mainGroup

local playSounds = {}
local playingSounds = {}
local loadedSounds = {}
local cameraFocusTimer = nil
local _outlineCache = {}

local mouseX, mouseY = 0, 0
local mouseListener = function(event)
    if mainGroup and mainGroup.x then
        mouseX, mouseY = (event.x - mainGroup.x) / mainGroup.xScale, -(event.y - mainGroup.y) / mainGroup.yScale
    end
end
Runtime:addEventListener('mouse', mouseListener)
]==])

        for s = 1, #scenes do
            local scene_id = scenes[s][2]
            local scene_path = app.idProject.."/scene_"..scene_id
            local xScaleMainGroup = display.contentWidth / options.displayWidth
            local yScaleMainGroup = display.contentHeight / options.displayHeight

            emit([[

-- Сцена
function scene_]]..scene_id..[[()

    mainGroup = display.newGroup()
    mainGroup.iscg = true

    mainGroup.xScale = ]]..tostring(options.orientation ~= "vertical" and not options.aspectRatio and yScaleMainGroup or xScaleMainGroup)..[[
    mainGroup.yScale = ]]..tostring(options.orientation == "vertical" and not options.aspectRatio and yScaleMainGroup or xScaleMainGroup)..[[
    mainGroup.x, mainGroup.y = ]]..(options.orientation == "vertical" and "CENTER_X, CENTER_Y" or "CENTER_Y, CENTER_X")..[[

    app.scene = 'game'
    app.scenes[app.scene] = {mainGroup}

    local cameraGroup = display.newGroup()
    mainGroup:insert(cameraGroup)

    local stampsGroup = display.newGroup()
    cameraGroup:insert(stampsGroup)

    local notCameraGroup = display.newGroup()
    mainGroup:insert(notCameraGroup)

    local focusCameraObject = nil
    local tableFeathers = {}
    local tableFeathersOptions = {3.5, 0, 0, 255}
    ]])
            if options.aspectRatio then
                emit("local blackRectTop = display.newRect("..(options.orientation=="vertical" and ("0,-"..tostring(options.displayHeight/2)..","..tostring(options.displayWidth)..",display.contentHeight") or ("-"..tostring(options.displayHeight/2)..",0,display.contentHeight,"..tostring(options.displayWidth)))..")\nblackRectTop.anchor"..(options.orientation=="vertical" and "Y" or "X").." = 1\nblackRectTop:setFillColor(0,0,0)\nmainGroup:insert(blackRectTop)\nlocal blackRectBottom = display.newRect("..(options.orientation=="vertical" and ("0,"..tostring(options.displayHeight/2)..","..tostring(options.displayWidth)..",display.contentHeight") or (tostring(options.displayHeight/2)..",0,display.contentHeight,"..tostring(options.displayWidth)))..")\nblackRectBottom.anchor"..(options.orientation=="vertical" and "Y" or "X").." = 0\nblackRectBottom:setFillColor(0,0,0)\nmainGroup:insert(blackRectBottom)\n")
            end

            emit([[
    objects = {}
    local events_changeBackground = {}
    local events_function = {}
    local events_whenTheTruth = {}

    local function broadcastFunction(nameFunction)
        for key, value in pairs(objects) do
            for i = 1, #events_function[key][nameFunction] do
                events_function[key][nameFunction][i](value)
                for i2 = 1, #value.clones do
                    events_function[key][nameFunction][i](value.clones[i2])
                end
            end
        end
    end

    local tableVarShow = {}
    local tableNamesClones = {}

    local miniScenes = display.newGroup()
    cameraGroup:insert(miniScenes)

    myScene = ']]..scene_path..[['

    pcall(function()
        local objectsTable = plugins.json.decode(funsP['получить сохранение'](']]..scene_path..[[/objects'))
        if objectsTable then
            local changed = false
            for idx = 1, #objectsTable do
                if objectsTable[idx][3] ~= nil then
                    objectsTable[idx][3] = nil
                    changed = true
                end
            end
            if changed then
                funsP['записать сохранение'](']]..scene_path..[[/objects', plugins.json.encode(objectsTable))
            end
        end
    end)

    Scenes[]]..scene_id..[[] = {
        objects = objects,
        myScene = myScene,

        events_keypressed = events_keypressed,
        events_endKeypressed = events_endKeypressed,
        events_touchBack = events_touchBack,
        events_touchScreen = events_touchScreen,
        events_movedScreen = events_movedScreen,
        events_onTouchScreen = events_onTouchScreen,
        events_whenTheTruth = events_whenTheTruth,

        mainGroup = mainGroup,
        WebViews = WebViews,
        textFields = textFields,

        playSounds = playSounds,
        playingSounds = playingSounds,
        loadedSounds = loadedSounds,
        joysticks = joysticks,

        threadFunRemove = {},
        id = ]]..scene_id..[[
    }
    Scenes.select = Scenes[]]..scene_id..[[]
    ]])

            local objects = plugins.json.decode(funsP['получить сохранение'](scene_path.."/objects")) or {}
            local functions = plugins.json.decode(funsP['получить сохранение'](scene_path.."/functions")) or {}

            for i = 1, #objects do
                if type(objects[i][2]) ~= "string" then
                    emit("\nevents_function['object_"..objects[i][2].."'] = {}")
                    for i2 = 1, #functions do
                        emit("\nevents_function['object_"..objects[i][2].."']['fun_"..functions[i2][1].."'] = {}")
                    end
                end

                emit("\nevents_touchBack['object_"..objects[i][2].."'] = {}"..
                    "\nevents_touchScreen['object_"..objects[i][2].."'] = {}"..
                    "\nevents_movedScreen['object_"..objects[i][2].."'] = {}"..
                    "\nevents_onTouchScreen['object_"..objects[i][2].."'] = {}"..
                    "\nevents_changeBackground['object_"..objects[i][2].."'] = {}"..
                    "\nevents_keypressed['object_"..objects[i][2].."'] = {}"..
                    "\nevents_endKeypressed['object_"..objects[i][2].."'] = {}"..
                    "\nevents_whenTheTruth['object_"..objects[i][2].."'] = {}")
            end

            emit([==[
    local function broadcastChangeBackground(numberImage)
        for key, value in pairs(objects) do
            for i = 1, #events_changeBackground[key] do
                events_changeBackground[key][i](value, numberImage)
                for i2 = 1, #value.clones do
                    events_changeBackground[key][i](value.clones[i2], numberImage)
                end
            end
        end
    end
    ]==])

            for o = 1, #objects do
                if type(objects[o][2]) ~= "string" then
                    local obj_id = objects[o][2]
                    local obj_path = scene_path.."/object_"..obj_id
                    local obj_images = plugins.json.decode(funsP['получить сохранение'](obj_path.."/images")) or {}
                    local obj_sounds = plugins.json.decode(funsP['получить сохранение'](obj_path.."/sounds")) or {}
                    local obj_videos = plugins.json.decode(funsP['получить сохранение'](obj_path.."/videos")) or {}

                    emit([=[
            pcall(function()
                local objectsParticles = {}
                local listImages = {
            ]=])

                    for i = 1, #obj_images do
                        emit((i == 1 and "" or ",")..obj_images[i][2])
                    end
                    emit("}\nlocal listNamesImages = {")
                    for i = 1, #obj_images do
                        local escapedName = tostring(obj_images[i][1] or "")
                            :gsub("\\", "\\\\")
                            :gsub("\r\n", "\\n")
                            :gsub("\n", "\\n")
                            :gsub("\r", "\\n")
                            :gsub("'", "\\'")
                        emit((i == 1 and "'" or "','")..escapedName)
                    end
                    if #obj_images == 0 then
                        emit("}\nlocal listSounds = {")
                    else
                        emit("'}\nlocal listSounds = {")
                    end
                    for i = 1, #obj_sounds do
                        emit((i == 1 and "" or ",")..obj_sounds[i][2])
                    end
                    emit([==[
            }

            local listVideos = {}
            local listEventsVideos = {}
            ]==])

                    if #obj_images > 0 then
                        emit("\nlocal object_"..obj_id.." = display.newImage('"..obj_path.."/image_"..obj_images[1][2]..".png', system.DocumentsDirectory) or display.newImage('images/notVisible.png')")
                        emit("\nobject_"..obj_id..".image_path = '"..obj_path.."/image_"..obj_images[1][2]..".png'")
                    else
                        emit("\nlocal object_"..obj_id.." = display.newImage('images/notVisible.png')")
                    end

                    emit([[
            object_]]..obj_id..[[.infoSaveVisPos = ]]..tostring(o)..[[

            cameraGroup:insert(object_]]..obj_id..[[)
            object_]]..obj_id..[[.touchesObjects = {}
            ]])
                    if o == 1 then
                        emit("local background = object_"..obj_id..
                            " background.listImagesBack, background.listNamesImagesBack, background.obj_pathBack = listImages, listNamesImages, '"..obj_path.."'")
                    end

                    emit("\nobject_"..obj_id..".parent_obj = object_"..obj_id..
                        "\nobject_"..obj_id..".clones = {}"..
                        "\nobjects['object_"..obj_id.."'], object_"..obj_id..".idObject = object_"..obj_id..", "..obj_id..
                        "\nobject_"..obj_id..".numberImage = 1\n\n"..
                        "object_"..obj_id..".tableVarShow, object_"..obj_id..".origWidth, object_"..obj_id..".origHeight, object_"..obj_id..".nameObject, object_"..obj_id..".property_size, object_"..obj_id..".property_brightness, object_"..obj_id..".property_color = {}, object_"..obj_id..".width, object_"..obj_id..".height, 'object_"..obj_id.."', 100, 100, 0\n"..
                        "object_"..obj_id..".countImages = "..tostring(#obj_images).."\n")

                    local localVariables = plugins.json.decode(funsP['получить сохранение'](obj_path.."/variables")) or {}
                    emit("object_"..obj_id..".namesVars = {}\n")
                    for i = 1, #localVariables do
                        emit("object_"..obj_id..".var_"..localVariables[i][1].." = 0\n")
                        emit("object_"..obj_id..".namesVars["..i.."] = 'var_"..localVariables[i][1].."'\n")
                    end

                    local localArrays = plugins.json.decode(funsP['получить сохранение'](obj_path.."/arrays")) or {}
                    emit("object_"..obj_id..".namesLists = {}\n")
                    for i = 1, #localArrays do
                        emit("object_"..obj_id..".list_"..localArrays[i][1].." = {}\n")
                        emit("object_"..obj_id..".namesLists["..i.."] = 'list_"..localArrays[i][1].."'\n")
                    end

                    emit("\n\nlocal events_start = {}\nlocal events_touchObject = {} object_"..obj_id..".events_touchObject = events_touchObject\n\nlocal events_movedObject = {} object_"..obj_id..".events_movedObject = events_movedObject\nlocal events_onTouchObject = {} object_"..obj_id..".events_onTouchObject = events_onTouchObject\nlocal events_collision = {} object_"..obj_id..".events_collision = events_collision\nlocal events_endedCollision = {} object_"..obj_id..".events_endedCollision = events_endedCollision\nlocal events_startClone = {}\nobject_"..obj_id..".events_startClone = events_startClone")
                    emit("\nobject_"..obj_id..".group = cameraGroup")
                    emit([[
            object_]]..obj_id..[[:addEventListener('touch', function(event)
                if event.phase == 'began' then
                    local newIdTouch = globalConstants.touchId + 1
                    globalConstants.touchId = newIdTouch
                    globalConstants.keysTouch['touch_'..newIdTouch], globalConstants.touchsXId[event.id], globalConstants.touchsYId[event.id], globalConstants.isTouchsId[event.id] = event.id, (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale, true
                    globalConstants.isTouch, globalConstants.touchX, globalConstants.touchY = true, (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale
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
                    for i = 1, #events_touchObject do
                        events_touchObject[i](event.target)
                    end
                elseif event.phase == 'moved' then
                    globalConstants.touchsXId[event.id], globalConstants.touchsYId[event.id] = (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale
                    globalConstants.touchX, globalConstants.touchY = (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale
                    for key, value in pairs(objects) do
                        for i = 1, #events_movedScreen[key] do
                            events_movedScreen[key][i](value)
                            for i2 = 1, #value.clones do
                                events_movedScreen[key][i](value.clones[i2])
                            end
                        end
                    end
                    for i = 1, #events_movedObject do
                        events_movedObject[i](event.target)
                    end
                else
                    display.getCurrentStage():setFocus(event.target, nil)
                    globalConstants.touchsXId[event.id], globalConstants.touchsYId[event.id], globalConstants.isTouchsId[event.id] = nil, nil, nil
                    if pocketupFuns.getCountTouch(globalConstants.isTouchsId) == 0 then
                        globalConstants.keysTouch = {}
                        globalConstants.isTouch = false
                    end
                    event.target.isTouch = nil
                    for key, value in pairs(objects) do
                        for i = 1, #events_onTouchScreen[key] do
                            events_onTouchScreen[key][i](value)
                            for i2 = 1, #value.clones do
                                events_onTouchScreen[key][i](value.clones[i2])
                            end
                        end
                    end
                    for i = 1, #events_onTouchObject do
                        events_onTouchObject[i](event.target)
                    end
                end
                return true
            end)
            ]])

                    local blocks = plugins.json.decode(funsP['получить сохранение'](obj_path.."/scripts")) or {}
                    local oldEventName = nil
                    local oldEvent = nil
                    for b = 1, #blocks do
                        local block = blocks[b]
                        if isEvent[block[1]] then
                            if b > 1 then
                                if oldEventName == "whenTheTruth" then
                                    emit("while "..make_all_formulas(oldEvent[2][1], "target").." do coroutine.yield() end\
                                    end\
                                    coroutine.yield()\
                                    end\n")
                                end
                                emit("removeTheard()\
                                end)\
                                local pStart\
                                pStart, tTheard = thread.start(p, target)\n")
                                if oldEventName == "changeBackground" or oldEventName == "collision" or oldEventName == "endedCollision" then
                                    emit("\nend")
                                end
                                emit("\nend\n")
                            end
                            if block[1] == "function" then
                                emit("\nevents_function['object_"..obj_id.."']['fun_"..block[2][1][2].."'][#events_function['object_"..obj_id.."']['fun_"..block[2][1][2].."'] + 1] = function(target)\
                                Timers_max = Timers_max + 1\
                                local tTheard\
                                local removeTheard = function()\
                                    thread.cancel(tTheard)\
                                end\
                                local p\
                                p = coroutine.create(function()\
                                    local threadFun = require('plugins.threadFun')\n")
                            elseif block[1] == "keypressed" or block[1] == "endKeypressed" then
                                emit("\nevents_"..block[1].."['object_"..obj_id.."'][#events_"..block[1].."['object_"..obj_id.."'] + 1] = function(e, target)\
                                local value = e.keyName\n")
                                if block[2][1][1] == 'globalVariable' then
                                    emit('var_'..block[2][1][2]..' = value\n')
                                    emit('if varText_'..block[2][1][2]..' then\n varText_'..block[2][1][2]..'.text = type(var_'..block[2][1][2]..')=="boolean" and (var_'..block[2][1][2]..' and app.words[373] or app.words[374]) or type(var_'..block[2][1][2]..')=="table" and encodeList(var_'..block[2][1][2]..') or var_'..block[2][1][2]..'\nend\n')
                                else
                                    emit('target.var_'..block[2][1][2]..' = value\n')
                                    emit('if target.varText_'..block[2][1][2]..' then\n target.varText_'..block[2][1][2]..'.text = type(target.var_'..block[2][1][2]..')=="boolean" and (target.var_'..block[2][1][2]..' and app.words[373] or app.words[374]) or type(target.var_'..block[2][1][2]..')=="table" and encodeList(target.var_'..block[2][1][2]..') or target.var_'..block[2][1][2]..'\nend\n')
                                end
                                emit("Timers_max = Timers_max + 1\
                                local tTheard\
                                local removeTheard = function()\
                                    thread.cancel(tTheard)\
                                end\
                                local p\
                                p = coroutine.create(function()\
                                    local threadFun = require('plugins.threadFun')\n")
                            elseif block[1] == "touchScreen" or block[1] == "movedScreen" or block[1] == "onTouchScreen" or block[1] == "touchBack" then
                                if block[1] == "touchBack" and block[3] == "on" then
                                    isScriptsBack = true
                                end
                                emit("\nevents_"..block[1].."['object_"..obj_id.."'][#events_"..block[1].."['object_"..obj_id.."'] + 1] = function(target)\n\
                                Timers_max = Timers_max + 1\
                                local tTheard\
                                local removeTheard = function()\
                                    thread.cancel(tTheard)\
                                end\
                                local p\
                                p = coroutine.create(function()\
                                    local threadFun = require('plugins.threadFun')\n")
                            elseif block[1] == "changeBackground" then
                                emit("\nevents_changeBackground['object_"..obj_id.."'][#events_changeBackground['object_"..obj_id.."'] + 1] = function(target, numberImage)\
                                if numberImage == "..(type(block[2][1][2]) == "boolean" and "'off'" or block[2][1][2]).." then\
                                    Timers_max = Timers_max + 1\
                                    local tTheard\
                                    local removeTheard = function()\
                                        thread.cancel(tTheard)\
                                    end\
                                    local p\
                                    p = coroutine.create(function()\
                                        local threadFun = require('plugins.threadFun')\n")
                            elseif block[1] == "collision" or block[1] == "endedCollision" then
                                emit("\nevents_"..block[1].."[#events_"..block[1].." + 1] = function(target, idObject)\
                                if "..(block[2][1][2] == nil and "true" or "idObject == 'object_"..block[2][1][2].."'").." then\
                                    Timers_max = Timers_max + 1\
                                    local tTheard\
                                    local removeTheard = function()\
                                        thread.cancel(tTheard)\
                                    end\
                                    local p\
                                    p = coroutine.create(function()\
                                        local threadFun = require('plugins.threadFun')\n")
                            elseif block[1] == "whenTheTruth" then
                                local condition = make_all_formulas(block[2][1], "target")
                                emit("\nevents_"..block[1].."['object_"..obj_id.."'][#events_"..block[1].."['object_"..obj_id.."'] + 1] = function(target)\n\
                                Timers_max = Timers_max + 1\
                                local tTheard\
                                local removeTheard = function()\
                                    thread.cancel(tTheard)\
                                end\
                                local p\
                                p = coroutine.create(function()\
                                    local threadFun = require('plugins.threadFun')\
                                    while true do\
                                        if "..condition.." then\n")
                                oldEvent = block
                            else
                                emit("\nevents_"..block[1].."[#events_"..block[1].." + 1] = function(target)\
                                Timers_max = Timers_max + 1\
                                local tTheard\
                                local removeTheard = function()\
                                    thread.cancel(tTheard)\
                                end\
                                local p\
                                p = coroutine.create(function()\
                                    local threadFun = require('plugins.threadFun')\n")
                            end
                            oldEventName = block[1]
                        else
                            local luaBlock = makeBlock_other(block, 'target', obj_images, obj_sounds, make_all_formulas, obj_id, obj_path, scene_id, scene_path, options, o, {xScaleMainGroup, yScaleMainGroup}, obj_videos)
                            if luaBlock ~= nil and luaBlock ~= "" then
                                emit("\n"..luaBlock.."\n")
                            else
                                local luaBlockC = makeBlock_cerberus(block, 'target', make_all_formulas, obj_id, obj_path, scene_id, scene_path, options)
                                if luaBlockC ~= nil and luaBlockC ~= "" then
                                    emit("\n"..luaBlockC.."\n")
                                end
                            end
                        end
                    end

                    if #blocks ~= 0 then
                        if oldEventName == "start" then
                            emit("removeTheard()\
                            end)\
                            local pStart\
                            pStart, tTheard = thread.start(p, target)\
                        end\n\n")
                        elseif oldEventName == "changeBackground" or oldEventName == "collision" or oldEventName == "endedCollision" then
                            emit("removeTheard()\
                            end)\
                            local pStart\
                            pStart, tTheard = thread.start(p, target)\nend\nend\n\n")
                        else
                            if oldEventName == "whenTheTruth" then
                                emit("while "..make_all_formulas(oldEvent[2][1], "target").." do coroutine.yield() end\
                                end\
                                coroutine.yield()\
                                end\n")
                            end
                            emit("removeTheard()\
                            end)\
                            local pStart\
                            pStart, tTheard = thread.start(p, target)\nend\n\n")
                        end
                    end
                    emit("\nfor i = 1, #events_start do\n    events_start[i](object_"..obj_id..")\nend\n")
                    emit("object_"..obj_id.."['events_whenTheTruth'] = events_whenTheTruth['object_"..obj_id.."'] or {}\nfor i = 1, #events_whenTheTruth['object_"..obj_id.."'] do\n    events_whenTheTruth['object_"..obj_id.."'][i](object_"..obj_id..")\nend\n")
                    emit("\nend)\n")
                end
            end

            emit("\nend")
        end

        emit("\nscene_"..scenes[1][2].."()\n")
        emit([[local function touchScreenGame(event)
            if event.phase == 'began' then
                local newIdTouch = globalConstants.touchId + 1
                globalConstants.touchId = newIdTouch
                globalConstants.keysTouch['touch_'..newIdTouch], globalConstants.touchsXId[event.id], globalConstants.touchsYId[event.id], globalConstants.isTouchsId[event.id] = event.id, (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale, true
                globalConstants.isTouch, globalConstants.touchX, globalConstants.touchY = true, (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale
                for key, value in pairs(objects) do
                    for i = 1, #events_touchScreen[key] do
                        events_touchScreen[key][i](value)
                        for i2 = 1, #value.clones do
                            events_touchScreen[key][i](value.clones[i2])
                        end
                    end
                end
            elseif event.phase == 'moved' then
                globalConstants.touchsXId[event.id], globalConstants.touchsYId[event.id] = (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale
                globalConstants.touchX, globalConstants.touchY = (event.x-mainGroup.x)/mainGroup.xScale, -(event.y-mainGroup.y)/mainGroup.yScale
                for key, value in pairs(objects) do
                    for i = 1, #events_movedScreen[key] do
                        events_movedScreen[key][i](value)
                        for i2 = 1, #value.clones do
                            events_movedScreen[key][i](value.clones[i2])
                        end
                    end
                end
            else
                globalConstants.touchsXId[event.id], globalConstants.touchsYId[event.id], globalConstants.isTouchsId[event.id] = nil, nil, nil
                if pocketupFuns.getCountTouch(globalConstants.touchsXId) == 0 then
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
            end
        end
        Runtime:addEventListener('touch', touchScreenGame)
        ]])

        emit([[
local funKeyListener = function(e)
    if e.phase == 'down' then
        for key, value in pairs(objects) do
            for i = 1, #events_keypressed[key] do
                events_keypressed[key][i](e, value)
                for i2 = 1, #value.clones do
                    events_keypressed[key][i](e, value.clones[i2])
                end
            end
        end
    else
        for key, value in pairs(objects) do
            for i = 1, #events_endKeypressed[key] do
                events_endKeypressed[key][i](e, value)
                for i2 = 1, #value.clones do
                    events_endKeypressed[key][i](e, value.clones[i2])
                end
            end
        end
    end
    return true
end
Runtime:addEventListener('key', funKeyListener)
]])

        emit([[
local function _disposeSoundTables(sPlay, sLoaded)
    if sPlay then
        for _, list in pairs(sPlay) do
            for _, soundData in ipairs(list) do
                pcall(audio.stop, soundData.channel)
                if not sLoaded then
                    pcall(audio.dispose, soundData.sound)
                end
            end
        end
    end
    if sLoaded then
        for _, handle in pairs(sLoaded) do
            pcall(audio.dispose, handle)
        end
    end
end

function exitGame()
    if cameraFocusTimer then
        pcall(timer.cancel, cameraFocusTimer)
        cameraFocusTimer = nil
    end
    Runtime:removeEventListener('mouse', mouseListener)
    Runtime:removeEventListener('key', funKeyListener)
    if funBackListener then
        Runtime:removeEventListener('key', funBackListener)
    end
    plugins.physics.setDrawMode('normal')
    system.deactivate('multitouch')
    native.setProperty('androidSystemUiVisibility', 'default')
    plugins.physics.stop()
    Runtime:removeEventListener('touch', touchScreenGame)
    showOldScene()
end

function deleteScene(id)
    if not Scenes[id] then
        return true
    end
    local scene = Scenes[id]
    local timers = scene.threads or {}
    for i = 1, #timers do
        pcall(timer.cancel, timers[i])
        timers[i] = nil
    end
    display.remove(scene.mainGroup)
    _disposeSoundTables(scene.playSounds, scene.loadedSounds)
    Scenes[id] = nil
    collectgarbage('collect')
end

function deleteAllScenes()
    timer.cancelAll()
    cameraFocusTimer = nil
    for key, value in pairs(Scenes) do
        if key ~= 'select' and type(value) == 'table' then
            display.remove(value.mainGroup)
            _disposeSoundTables(value.playSounds, value.loadedSounds)
        end
    end
    pcall(audio.stop)
    _disposeSoundTables(playSounds, loadedSounds)
    playSounds = {}
    loadedSounds = {}
    playingSounds = {}
    removeAllObjects()
    transition.cancelAll()
    plugins.physics.setDrawMode('normal')
    collectgarbage('collect')
end

function moveScene()
    transition.pauseAll()
    Scenes.select.globalConstants = {
        touchX = globalConstants.touchX,
        touchY = globalConstants.touchY
    }
    Scenes.select.threads = {}
    for i = 1, #thread.timers do
        if thread.timers[i] then
            table.insert(Scenes.select.threads, thread.timers[i])
        end
    end
    thread.timers = {}
    mainGroup.isVisible = false
    local objectsTable = nil
    local objectsChanged = false
    pcall(function()
        objectsTable = plugins.json.decode(funsP['получить сохранение'](myScene..'/objects'))
    end)
    for _, value in pairs(objects) do
        local target = value
        pcall(function()
            if objectsTable and target.parent_obj == target and objectsTable[target.infoSaveVisPos] then
                if objectsTable[target.infoSaveVisPos][3] == nil then
                    objectsTable[target.infoSaveVisPos][3] = {}
                end
                objectsTable[target.infoSaveVisPos][3].size = target.property_size / 100
                objectsTable[target.infoSaveVisPos][3].rotation = target.rotation
                objectsTable[target.infoSaveVisPos][3].path = target.image_path
                objectsChanged = true
            end
        end)
        pcall(function()
            plugins.physics.removeBody(target)
        end)
    end
    if objectsChanged and objectsTable then
        pcall(function()
            funsP['записать сохранение'](myScene..'/objects', plugins.json.encode(objectsTable))
        end)
    end
    plugins.physics.setDrawMode('normal')
    timer.pauseAll()
    ]]..(options.orientation == "vertical" and "plugins.orientation.lock('portrait')" or "plugins.orientation.lock('landscape')")..[[
    for _, list in pairs(playSounds) do
        for _, soundData in ipairs(list) do
            pcall(audio.pause, soundData.channel)
        end
    end
    WebViews = {}
    textFields = {}
    objects = {}
    events_touchBack = {}
    events_keypressed = {}
    events_endKeypressed = {}
    events_touchScreen = {}
    events_movedScreen = {}
    events_onTouchScreen = {}
    events_whenTheTruth = {}
    playSounds = {}
    playingSounds = {}
    loadedSounds = {}
    joysticks = {}
    Timers = {}
    Timers_max = 0
    native.setProperty('windowMode', 'fullscreen')
    collectgarbage('collect')
end
]])

        if isScriptsBack then
            emit([[
function funBackListener(event)
    if (event.keyName == 'back' or event.keyName == 'deleteBack') and event.phase == 'up' then
        for key, value in pairs(objects) do
            for i = 1, #events_touchBack[key] do
                events_touchBack[key][i](value)
                for i2 = 1, #value.clones do
                    events_touchBack[key][i](value.clones[i2])
                end
            end
        end
    end
    return true
end
Runtime:addEventListener('key', funBackListener)
]])
        else
            emit([[
function funBackListener(event)
    if (event.keyName == 'back' or event.keyName == 'deleteBack') and event.phase == 'up' then
        local rect = display.newImage('images/notVisible.png')
        mainGroup:insert(rect)
        rect.width, rect.height = ]]..(options.orientation == "vertical" and display.contentWidth or display.contentHeight)..", "..(options.orientation == "vertical" and display.contentHeight or display.contentWidth)..[[
        rect:toBack()
        rect.alpha = 0.004
        pcall(display.save, mainGroup, { filename = myScene..'/icon.png', baseDir = system.DocumentsDirectory, backgroundColor = {1,1,1,1} })
        Runtime:removeEventListener('key', funBackListener)
        pcall(audio.stop)
        deleteAllScenes()
        exitGame()
        plugins.orientation.lock('portrait')
    end
    return true
end
Runtime:addEventListener('key', funBackListener)
]])
        end

        emit([[
function funBackListener2(event)
    if (event.keyName == 'back' or event.keyName == 'deleteBack') and event.phase == 'up' then
        if funBackListener then
            Runtime:removeEventListener('key', funBackListener)
        end
        pcall(audio.stop)
        deleteAllScenes()
        exitGame()
        plugins.orientation.lock('portrait')
    end
end
]])
    else
        emit(require('pocketup.gameAndBlocks.projectCode'))
    end

    local lua = table.concat(luaChunks)
    luaChunks = nil

    noremoveAllObjects()
    collectgarbage('collect')
    BlocksAllHandlers = {}

    local origPrint = _G.print
    if not utils.isSim then
        _G.print = function(...) end
    end

    local f, error_msg = loadstring(lua)
    if f then
        local status, run_err = pcall(f)
        _G.print = origPrint
        if not status then
            local line_number = tonumber(string.match(tostring(run_err), "%d+")) or "?"
            pcall(function() native.setProperty("windowMode", "normal") end)
            error("Ошибка:" .. tostring(run_err) .. " строка:" .. tostring(line_number))
        else
            return run_err
        end
    else
        _G.print = origPrint
        local line_number = tonumber(string.match(tostring(error_msg), "%d+"))
        if line_number then
            local lines = lua:split('\n')
            if lines and lines[line_number] then
                print(lines[line_number])
            end
        end
        pcall(function() native.setProperty("windowMode", "normal") end)
        error("Ошибка:" .. tostring(error_msg) .. " строка:" .. tostring(line_number or "?"))
    end
end
