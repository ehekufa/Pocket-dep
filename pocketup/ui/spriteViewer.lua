-- сцена для просмотра конкретного образa обьекта

local cache = {}

local function touchBg(event)
    if event.phase == 'ended' then
        if cache['col'] == 'black' then
            display.setDefault('background', 1, 1, 1)
            cache['col'] = 'white'
        else
            display.setDefault('background', 0, 0, 0)
            cache['col'] = 'black'
        end
    end
end


function scene_viewsprite(pathImage, nameImage)

    local groupScene = display.newGroup()
    local funBackObjects = {}
    local oldFunBack = funBack
    app.scene = "viewsprite"
    app.scenes[app.scene] = {groupScene}
    local topBarArray = topBar(groupScene, nameImage, nil, nil, funBackObjects)
    topBarArray[4].alpha = 0


    display.setDefault('background', 0, 0, 0)
    cache['col'] = 'black'
    local image = display.newImage(pathImage, system.DocumentsDirectory)
    if image then
        image.x = CENTER_X
        image.y = CENTER_Y
        if image.width>image.height then
            image.xScale = display.contentWidth/1.1/image.width
            image.yScale=image.xScale
        else
            image.yScale = display.contentWidth/1.1/image.height
            image.xScale=image.yScale
        end
        groupScene:insert(image)
    end
    Runtime:addEventListener('touch', touchBg)

    funBackObjects[1] = function()
        Runtime:removeEventListener('touch', touchBg)
        display.remove(groupScene)
        app.scene = "scripts"
        if app.scenes["scripts"] and app.scenes["scripts"][1] then
            app.scenes["scripts"][1].alpha = 1
        end
        display.setDefault("background", 4/255, 34/255, 44/255)
        funBack = oldFunBack
    end
end