local function decodeString(encoded)
    local decoded = ""
    for _, v in ipairs(encoded) do
        decoded = decoded .. string.char(v)
    end
    return decoded
end

function scene_menu()
    local funMenuObjects = {}
    funMenuObjects[1] = function ()
        
    end
    local groupScene = display.newGroup()
    local topBarArray = topBar(groupScene, 'Pocket Up', funMenuObjects, nil, nil)
    topBarArray[2].fill = {
        type='image',
        filename='sprites/icon.png'
    }
    app.scene = "menu"
    app.scenes[app.scene] = {groupScene}
    local scrollItems = plugins.widget.newScrollView({
        width=display.contentWidth,
		height=display.contentHeight-topBarArray[1].height,
		horizontalScrollDisabled=true,
		isBounceEnabled=false,
		hideBackground=true,
    })
    scrollItems.y = CENTER_Y+topBarArray[1].height/2
    local texts = {
        {text = app.words[659], icon='images/continue.png'},
        {text = app.words[661], icon='images/programs.png'},
        {text = app.words[660], icon='images/teleg.png'},
        {text = app.words[662], icon='images/tutorials.png'},
        {text = app.words[663], icon='images/setting.png'},
        --{text='Paint Up', icon='images/paint.png'}
    }
    local rpn = funsP["получить сохранение"]("lastProject")
    local recentProjectName = ''
    local recentProjectId = '0'
    if rpn ~= '[]' then
        local t = plugins.json.decode(rpn)
        if type(t) == 'table' then
            recentProjectName = t['name'] or ''
            recentProjectId = t['id'] or '0'
        end
    end

   

    local y = display.actualContentWidth/(#texts/1.5)/2+50
    for i = 1, #texts do
        if i < 2 then
            local a = display.newRect(0, 0, display.actualContentWidth, display.actualContentWidth/(#texts/1.5)+100)
            a:setFillColor(0, 71/255, 93/255)
            scrollItems:insert(a)
            a.y = y
            a.x = CENTER_X 
            local icon = display.newImageRect(texts[i].icon, 128, 128)
            local arrow = display.newImage('images/arrow.png')
            local text = display.newText(texts[i].text, 0, 0, nil, 35)
            local displayRecentName = recentProjectName
            if string.len(displayRecentName) > display.actualContentWidth/20 then
                displayRecentName = string.sub(displayRecentName, 1, display.actualContentWidth/20)..'...'
            end
            local textRecentProject = display.newText(displayRecentName, 0, 0, nil, 30)

            icon.y = y
            icon.x = display.screenOriginX+icon.width/2+15

            scrollItems:insert(textRecentProject)
            scrollItems:insert(icon)

            text.x = display.screenOriginX+(text.width/2)+158
            textRecentProject.x = display.screenOriginX+(textRecentProject.width/2)+158
            textRecentProject.y = y+20
            text:setFillColor(181/255, 234/255, 248/255)
            text.y = y-20
            scrollItems:insert(text)

            local splitter = display.newRect(CENTER_X, y+a.height/2, display.actualContentWidth-70, 2)
            scrollItems:insert(splitter)
            splitter:setFillColor(4/255, 34/255, 44/255)
            
            arrow.width = arrow.width/4
            arrow.height = arrow.height/4
            scrollItems:insert(arrow)
            arrow.x = display.actualContentWidth-arrow.width
            arrow.y = y
            y = y + a.height-50
            a:addEventListener('touch', function (event)
                if event.phase == 'began' then
                    event.target:setFillColor(23/255,91/255,114/255)
                    display.getCurrentStage():setFocus(event.target, event.id)
                elseif event.phase == 'moved' then
                    local dy = math.abs( ( event.y - event.yStart ) )
                    if ( dy > 10 ) then
                        scrollItems:takeFocus( event )
                        event.target:setFillColor(0, 71/255, 93/255)
                    end
                elseif event.phase == 'ended' or event.phase == 'cancelled' then
                    event.target:setFillColor(0, 71/255, 93/255)
                    display.getCurrentStage():setFocus(event.target, nil)
                    if event.phase == 'ended' then
                        local scenesToProject = recentProjectName ~= '' and plugins.json.decode(funsP["получить сохранение"](recentProjectId.."/scenes")) or nil
                        if recentProjectName ~= '' and type(scenesToProject) == 'table' and #scenesToProject > 0 then
                            display.remove(app.scenes[app.scene][1])
                            app.idProject = recentProjectId
                            app.nmProject = recentProjectName
                            scene_objects(recentProjectId.."/scene_"..scenesToProject[1][2].."/objects", recentProjectName, scenesToProject[1])
                        else
                            funsP["вызвать уведомление"](app.words[664])
                        end
                    end
                end
                return true
            end)
        else
            local a = display.newRect(0, 0, display.actualContentWidth, display.actualContentWidth/(#texts/1.5))
            a:setFillColor(0, 71/255, 93/255)
            scrollItems:insert(a)
            a.y = y
            a.x = CENTER_X
            local icon = display.newImageRect(texts[i].icon, 128, 128)
            
            local text = display.newText(texts[i].text, 0, 0, nil, 35)
            text.x = display.screenOriginX+(text.width/2)+158
            text.y = y
            icon.y = y
            icon.x = display.screenOriginX+icon.width/2+15
            text:setFillColor(181/255, 234/255, 248/255)
            scrollItems:insert(text)
            scrollItems:insert(icon)
            a.i = i

            local splitter = display.newRect(CENTER_X, y+a.height/2, display.actualContentWidth-70, 2)
            scrollItems:insert(splitter)
            splitter:setFillColor(4/255, 34/255, 44/255)
            
            local arrow = display.newImage('images/arrow.png')
            arrow.width = arrow.width/4
            arrow.height = arrow.height/4
            scrollItems:insert(arrow)
            arrow.x = display.actualContentWidth-arrow.width
            arrow.y = y
            a:addEventListener('touch', function (event)
                if event.phase == 'began' then
                    event.target:setFillColor(23/255,91/255,114/255)
                    display.getCurrentStage():setFocus(event.target, event.id)
                elseif event.phase == 'moved' then
                    local dy = math.abs( ( event.y - event.yStart ) )
                    if ( dy > 10 ) then
                        scrollItems:takeFocus( event )
                        event.target:setFillColor(0, 71/255, 93/255)
                    end
                elseif event.phase == 'ended' or event.phase == 'cancelled' then
                    event.target:setFillColor(0, 71/255, 93/255)
                    display.getCurrentStage():setFocus(event.target, nil)
                    if event.phase == 'ended' then
                        if event.target.i == 3 then
                            local link = {104, 116, 116, 112, 115, 58, 47, 47, 116, 46, 109, 101, 47, 112, 111, 99, 107, 101, 116, 95, 117, 112, 95, 99, 104, 97, 116}
                            system.openURL(decodeString(link))
                        elseif event.target.i == 2 then
                            display.remove(app.scenes[app.scene][1])
                            scene_projects()
                        elseif event.target.i == 4 then
                            local link = {104, 116, 116, 112, 115, 58, 47, 47, 119, 119, 119, 46, 121, 111, 117, 116, 117, 98, 101, 46, 99, 111, 109, 47, 104, 97, 115, 104, 116, 97, 103, 47, 112, 111, 99, 107, 101, 116, 117, 112}
                            system.openURL(decodeString(link))
                        elseif event.target.i == 5 then
                            funsP["вызвать уведомление"](app.words[51])
                        elseif event.target.i == 6 then
                            display.remove(app.scenes[app.scene][1])
                            scene_paint()
                        end
                    end
                end
                return true
            end)
            y = y + a.height
        end 
    end
    groupScene:insert(scrollItems)
end