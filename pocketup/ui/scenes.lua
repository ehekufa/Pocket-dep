-- сцена для просмотра сцен проекта

function scene_scenes(idProject, nameProjectScenes)
	app.idProject = idProject
	app.nmProject = nameProjectScenes
	local groupScene = display.newGroup()
	local groupSceneScroll = display.newGroup()
	app.scene = "scenes"
	app.scenes[app.scene] = {groupSceneScroll, groupScene}
	local isBackScene = "back"
	local funMenuObjects = {}
	local funCheckObjects = {}
	local funBackObjects = {}
	local valueHeaderTopBar = nameProjectScenes
	local topBarArray = topBar(groupScene, nameProjectScenes, funMenuObjects, funCheckObjects, funBackObjects)

	local scrollProjects = plugins.widget.newScrollView({
		width=display.contentWidth,
		height=display.contentHeight-topBarArray[1].height,
		horizontalScrollDisabled=true,
		isBounceEnabled=false,
		hideBackground=true,
	})
	scrollProjects.x = CENTER_X
	groupScene:insert(scrollProjects)
	scrollProjects.anchorY = 0
	scrollProjects.y = topBarArray[1].y+topBarArray[1].height
	scrollProjects:insert(groupSceneScroll)
	utils.select_Scroll = scrollProjects

	local scenes = plugins.json.decode(funsP["получить сохранение"](idProject.."/scenes"))
	local arraySlots = {}

	local isMoveSlot = false
	local timerMoveSlot = nil
	local isTimerMoveSlot = false

	local function cancelMoveTimer()
		if isTimerMoveSlot and timerMoveSlot then
			timer.cancel(timerMoveSlot)
			timerMoveSlot = nil
			isTimerMoveSlot = false
		end
	end

	local function touchSlotOpenScene(event)
		if (event.phase=="began") then
			event.target:setFillColor(23/255,91/255,114/255)

			if (isBackScene=="back") then
				isTimerMoveSlot = true
				timerMoveSlot = timer.performWithDelay(250, function()
					isTimerMoveSlot = false
					timerMoveSlot = nil
					isMoveSlot = true
					local _, yS = scrollProjects:getContentPosition()
					local groupSlot = event.target.myGroup
					groupSlot.y = event.y-scrollProjects.y-yS
					groupSlot:toFront()
				end)
			end

			display.getCurrentStage():setFocus(event.target, event.id)
		elseif (event.phase=="moved" and (math.abs(event.y-event.yStart)>20 or math.abs(event.x-event.xStart)>20)) then
			cancelMoveTimer()

			if (not isMoveSlot) then
				scrollProjects:takeFocus(event)
				event.target:setFillColor(0, 71/255, 93/255)
			else
				local _, yS = scrollProjects:getContentPosition()
				local groupSlot = event.target.myGroup
				groupSlot.y = event.y-scrollProjects.y-yS

				local idNewSlot = math.max(math.min(math.round(groupSlot.y/event.target.height+1), #arraySlots), 1)
				local idOldSlot = event.target.idSlot
				if (idOldSlot~=idNewSlot) then
					local slot = arraySlots[idOldSlot]
					table.remove(arraySlots, idOldSlot)
					table.insert(arraySlots, idNewSlot, slot)
					table.remove(scenes, idOldSlot)
					table.insert(scenes, idNewSlot, event.target.infoScene)
					funsP["записать сохранение"](idProject.."/scenes", plugins.json.encode(scenes))
					local oldSlot = arraySlots[idOldSlot]
					oldSlot.idSlot = idOldSlot
					transition.to(oldSlot.myGroup, {time=200, y=oldSlot.height*(oldSlot.idSlot-0.5), transition=easing.inOutQuad})
					event.target.idSlot = idNewSlot
				end
			end

		elseif (event.phase=="ended" or event.phase=="cancelled") then
			event.target:setFillColor(0, 71/255, 93/255)
			display.getCurrentStage():setFocus(event.target, nil)

			local wasTap = isTimerMoveSlot
			cancelMoveTimer()

			if (event.phase=="ended" and wasTap and isBackScene=="back") then
				display.remove(app.scenes[app.scene][1])
				display.remove(app.scenes[app.scene][2])
				scene_objects(idProject.."/scene_"..event.target.infoScene[2].."/objects", nameProjectScenes, event.target.infoScene)
			elseif (isMoveSlot) then
				isMoveSlot = false
				event.target.myGroup.y = event.target.height*(event.target.idSlot-0.5)
			end
		end
		return true
	end

	local touchMenuSlot
	local function createSceneSlotCard(iSlot)
		local slotGroup = display.newGroup()
		slotGroup.y = display.contentWidth/3.75*(iSlot-0.5)
		groupSceneScroll:insert(slotGroup)
		local buttonRect = display.newRect(0, 0, display.contentWidth, display.contentWidth/3.75)
		buttonRect.myGroup = slotGroup
		buttonRect.infoScene = scenes[iSlot]
		buttonRect.idSlot = iSlot
		arraySlots[iSlot] = buttonRect
		buttonRect.anchorX = 0
		buttonRect:setFillColor(0, 71/255, 93/255)
		slotGroup:insert(buttonRect)

		local strokeIcon = display.newRect(buttonRect.x+buttonRect.height*0.9, buttonRect.y, buttonRect.height/1.3, buttonRect.height/1.4)
		strokeIcon.strokeWidth = 3
		strokeIcon:setStrokeColor(171/255, 219/255, 241/255)
		strokeIcon:setFillColor(0,0,0,0)
		slotGroup:insert(strokeIcon)

		local containerIcon = display.newContainer(strokeIcon.width, strokeIcon.height)
		slotGroup:insert(containerIcon)
		containerIcon.x, containerIcon.y = strokeIcon.x, strokeIcon.y
		if (funsP["проверить наличие файла"](idProject.."/scene_"..scenes[iSlot][2].."/icon.png")) then
			local imageIcon = display.newImage(idProject.."/scene_"..scenes[iSlot][2].."/icon.png", system.DocumentsDirectory)
			if imageIcon then
				containerIcon:insert(imageIcon)
				local sizeIconProject = containerIcon.height/imageIcon.height
				if (imageIcon.width*sizeIconProject<containerIcon.width) then
					sizeIconProject = containerIcon.width/imageIcon.width
				end
				imageIcon.xScale, imageIcon.yScale = sizeIconProject, sizeIconProject
			end
			strokeIcon:toFront()
		end

		local nameProject = display.newText({
			text = scenes[iSlot][1],
			x = strokeIcon.x+strokeIcon.width/1.5,
			y = strokeIcon.y,
			width = display.contentWidth/2.12,
			height = app.fontSize0*1.15,
			fontSize = app.fontSize0
		})
		nameProject.anchorX = 0
		nameProject:setFillColor(171/255, 219/255, 241/255)
		slotGroup:insert(nameProject)

		local menuProject = display.newImage("images/menu.png")
		menuProject.slot = buttonRect
		menuProject:addEventListener("touch", touchMenuSlot)
		menuProject.x, menuProject.y, menuProject.width, menuProject.height = buttonRect.x+buttonRect.width/1.11, buttonRect.y, buttonRect.height/4.5, buttonRect.height/4.5
		menuProject:setFillColor(171/255, 219/255, 241/255)
		slotGroup:insert(menuProject)

		local menu2Project = display.newImage("images/menu2.png")
		menu2Project.x, menu2Project.y, menu2Project.width, menu2Project.height = buttonRect.width-buttonRect.width/1.075, buttonRect.y, menuProject.width, menuProject.height
		menu2Project:setFillColor(0,0,0,0.5)
		slotGroup:insert(menu2Project)

		buttonRect.strokeIcon = strokeIcon
		buttonRect.containerIcon = containerIcon
		buttonRect.menu = menuProject
		buttonRect.menu2 = menu2Project
		buttonRect.nameProject = nameProject

		buttonRect:addEventListener("touch", touchSlotOpenScene)
		return buttonRect
	end

	touchMenuSlot = function(event)
		if (event.phase=="began") then
			display.getCurrentStage():setFocus(event.target, event.id)
		elseif (event.phase=="moved" and (math.abs(event.x-event.xStart)>20 or math.abs(event.y-event.yStart)>20)) then
			scrollProjects:takeFocus(event)
		elseif (event.phase=="ended" or event.phase=="cancelled") then
			display.getCurrentStage():setFocus(event.target, nil)
			if (event.phase~="ended") then
				return true
			end

			isBackScene = "block"

			local notVisibleRect = display.newImage("images/notVisible.png")
			notVisibleRect.x, notVisibleRect.y, notVisibleRect.width, notVisibleRect.height = CENTER_X, CENTER_Y, display.contentWidth, display.contentHeight
			groupScene:insert(notVisibleRect)

			local _, yPosScroll = scrollProjects:getContentPosition()
			local groupMenu = display.newGroup()
			groupMenu.x, groupMenu.y = display.contentWidth, event.target.slot.myGroup.y+event.target.height/1.25+yPosScroll
			groupScene:insert(groupMenu)

			groupMenu.xScale, groupMenu.yScale, groupMenu.alpha = 0.3, 0.3, 0

			local arrayButtonsFunctions = {{4, "copy"}, {5, "delete"}, {6, "rename"}}

			local buttons = {}
			local buttonContainer = display.newContainer(display.contentWidth/1.8, display.contentWidth/7)
			buttonContainer.anchorX, buttonContainer.anchorY = 1, 0
			groupMenu:insert(buttonContainer)
			local buttonCircle = display.newCircle(0,0,buttonContainer.width/2)
			buttonCircle:setFillColor(1,1,1,0.25)
			buttonCircle.xScale, buttonCircle.yScale, buttonCircle.alpha = 0.25, 0.25, 0
			buttonContainer:insert(buttonCircle)

			local eventTargetMenu = event.target
			local function touchTypeFunction(btnEvent)
				if (btnEvent.phase=="began") then
					buttonContainer:toFront()
					buttonContainer.y = btnEvent.target.y
					transition.to(buttonCircle, {time=150, xScale=1.1, yScale=1.1, alpha=1})
				elseif (btnEvent.phase=="moved" and (math.abs(btnEvent.x-btnEvent.xStart)>20 or math.abs(btnEvent.y-btnEvent.yStart)>20)) then
					transition.to(buttonCircle, {time=150, xScale=0.25, yScale=0.25, alpha=0})
				elseif (btnEvent.phase=="ended" or btnEvent.phase=="cancelled") then
					if (btnEvent.phase~="ended") then
						transition.to(buttonCircle, {time=150, xScale=0.25, yScale=0.25, alpha=0})
						return true
					end

					isBackScene = "back"

					local function isCorrectValue(value)
						for j=1, #scenes do
							if (scenes[j][1]==value) then
								return false
							end
						end
						return true
					end

					local function correctNameSlot(value)
						if (isCorrectValue(value)) then
							return value
						else
							local suffix = 1
							while (not isCorrectValue(value.." ("..suffix..")")) do
								suffix = suffix+1
							end
							return value.." ("..suffix..")"
						end
					end

					if (btnEvent.target.typeFunction=="copy") then
						local idx = eventTargetMenu.slot.idSlot
						local counterProject = plugins.json.decode(funsP["получить сохранение"](app.idProject.."/counter"))
						counterProject[1] = counterProject[1]+1
						local copyObject = utils.deepCopy(scenes[idx])
						copyObject[1] = correctNameSlot(copyObject[1])
						copyObject[2] = counterProject[1]
						funsP["записать сохранение"](app.idProject.."/counter", plugins.json.encode(counterProject))
						funsP["копировать сцену"](app.idProject, app.idProject.."/scene_"..scenes[idx][2], app.idProject.."/scene_"..copyObject[2])
						scenes[#scenes+1] = copyObject
						funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))

						createSceneSlotCard(#scenes)
						local arSlEnd = arraySlots[#arraySlots].myGroup
						scrollProjects:setScrollHeight(arSlEnd.y+arSlEnd.height/2+display.contentWidth/1.5)
						funsP["вызвать уведомление"](string.gsub(app.words[32], "<count>", 1))

					elseif (btnEvent.target.typeFunction=="delete") then
						local idx = eventTargetMenu.slot.idSlot
						local slot = eventTargetMenu.slot
						funsP["удалить объект"](app.idProject.."/scene_"..scenes[idx][2])
						table.remove(arraySlots, idx)
						table.remove(scenes, idx)
						display.remove(slot.myGroup)
						funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))

						if (#scenes==1) then
							display.remove(app.scenes[app.scene][1])
							display.remove(app.scenes[app.scene][2])
							scene_objects(app.idProject.."/scene_"..scenes[1][2].."/objects", nameProjectScenes, scenes[1])
						else
							for j=idx, #scenes do
								local s = arraySlots[j]
								s.idSlot = j
								s.myGroup.y = s.myGroup.y-s.height
							end
							local _, yScroll = scrollProjects:getContentPosition()
							local arSlEnd = arraySlots[#arraySlots].myGroup
							local newScrollHeight = arSlEnd.y+arSlEnd.height/2+display.contentWidth/1.5
							scrollProjects:setScrollHeight(newScrollHeight)
							scrollProjects:scrollToPosition({
								time=0,
								y=math.min(math.max(yScroll, -newScrollHeight+scrollProjects.height), 0)
							})
							funsP["вызвать уведомление"](string.gsub(app.words[34], "<count>", 1))
						end

					elseif (btnEvent.target.typeFunction=="rename") then
						local function isErrorCorrectNameObject(value)
							if (string.len(value)==0) then
								return(app.words[18])
							else
								return(isCorrectValue(value) and "" or app.words[15])
							end
						end
						local function endEditingRename(tableAnswer)
							if (tableAnswer.isOk) then
								tableAnswer.value = tableAnswer.value:gsub((utils.isWin and '\r\n' or '\n'), ' ')
								local slot = eventTargetMenu.slot
								slot.nameProject.text = tableAnswer.value
								scenes[slot.idSlot][1] = tableAnswer.value
								funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))
							end
						end
						app.cerberus.newInputLine(app.words[31], app.words[27], isErrorCorrectNameObject, eventTargetMenu.slot.infoScene[1], endEditingRename)
					end

					for j=1, #buttons do
						buttons[j]:removeEventListener("touch", touchTypeFunction)
					end
					display.remove(notVisibleRect)
					transition.to(groupMenu, {time=200, alpha=0, onComplete=function ()
						display.remove(groupMenu)
					end})
				end
				return(true)
			end

			for j=1, #arrayButtonsFunctions do
				buttons[j] = display.newRect(0, display.contentWidth/7*(j-1), display.contentWidth/1.8, display.contentWidth/7)
				buttons[j].anchorX, buttons[j].anchorY = 1, 0
				buttons[j]:setFillColor(48/255, 48/255, 48/255)
				groupMenu:insert(buttons[j])
				buttons[j].typeFunction = arrayButtonsFunctions[j][2]
				buttons[j]:addEventListener("touch", touchTypeFunction)

				buttons[j].header = display.newText(app.words[arrayButtonsFunctions[j][1]], -buttons[j].width/1.1, buttons[j].y+buttons[j].height/2, nil, app.fontSize1)
				buttons[j].header.anchorX = 0
				groupMenu:insert(buttons[j].header)
			end

			transition.to(groupMenu, {time=150, xScale=1, yScale=1, alpha=1, transition=easing.outQuad})

			notVisibleRect:addEventListener("touch", function (closeEvent)
				if (closeEvent.phase=="ended") then
					isBackScene = "back"
					display.remove(notVisibleRect)
					for j=1, #buttons do
						buttons[j]:removeEventListener("touch", touchTypeFunction)
					end
					transition.to(groupMenu, {time=200, alpha=0, onComplete=function ()
						display.remove(groupMenu)
					end})
				end
				return(true)
			end)
		end
		return(true)
	end

	for j=1, #scenes do
		createSceneSlotCard(j)
	end
	scrollProjects:setScrollHeight(groupSceneScroll.height+display.contentWidth/1.5)

	local circlePlus = display.newCircle(CENTER_X+display.contentWidth/2-display.contentWidth/8, CENTER_Y+display.contentHeight/2-display.contentWidth/8-75, display.contentWidth/11.5)
	circlePlus:setFillColor(1, 172/255, 8/255)
	groupScene:insert(circlePlus)
	local circlePlusAlpha = display.newCircle(circlePlus.x, circlePlus.y, display.contentWidth/11.5)
	circlePlusAlpha:setFillColor(1,1,1,0.25)
	circlePlusAlpha.xScale, circlePlusAlpha.yScale, circlePlusAlpha.alpha = 0.5, 0.5, 0
	groupScene:insert(circlePlusAlpha)
	circlePlus.circleAlpha = circlePlusAlpha

	local circlePlay = display.newCircle(circlePlus.x, circlePlus.y-display.contentWidth/8*1.75, display.contentWidth/11.5)
	circlePlay:setFillColor(1, 172/255, 8/255)
	groupScene:insert(circlePlay)
	local runIcon = display.newImageRect('images/play.png', app.fontSize0*1.75, app.fontSize0*1.75)
	runIcon.x = circlePlay.x
	runIcon.y = circlePlay.y
	groupScene:insert(runIcon)
	local circlePlayAlpha = display.newCircle(circlePlay.x, circlePlay.y, display.contentWidth/11.5)
	circlePlayAlpha:setFillColor(1,1,1,0.25)
	circlePlayAlpha.xScale, circlePlayAlpha.yScale, circlePlayAlpha.alpha = 0.75, 0.75, 0
	groupScene:insert(circlePlayAlpha)
	circlePlay.circleAlpha = circlePlayAlpha

	local circlePlusText = display.newText("+", circlePlus.x, circlePlus.y, nil, app.fontSize0*1.75)
	groupScene:insert(circlePlusText)

	local function touchCirclePlus(event)
		if (event.phase=="began") then
			transition.to(event.target.circleAlpha, {alpha=1, xScale=1, yScale=1, time=100})
			display.getCurrentStage():setFocus(event.target, event.id)
		elseif (event.phase=="moved") then
		elseif (event.phase=="ended" or event.phase=="cancelled") then
			transition.to(event.target.circleAlpha, {alpha=0, xScale=0.75, yScale=0.75, time=100})
			display.getCurrentStage():setFocus(event.target, nil)

			if (event.phase=="ended" and isBackScene=="back") then
				if (event.target==circlePlus) then
					local function isCorrectValue(value)
						if (string.len(value)==0) then
							return(app.words[18])
						else
							for j=1, #scenes do
								if (scenes[j][1]==value) then
									return(app.words[15])
								end
							end
							return("")
						end
					end

					local function correctNameSlot(value)
						if (isCorrectValue(value)=="") then
							return value
						else
							local suffix = 1
							while (isCorrectValue(value.." ("..suffix..")")~="") do
								suffix = suffix+1
							end
							return(value.." ("..suffix..")")
						end
					end

					local function onCompleteObject(ansEvent)
						if (ansEvent.isOk) then
							ansEvent.value = ansEvent.value:gsub((utils.isWin and '\r\n' or '\n'), ' ')
							local counter = plugins.json.decode(funsP["получить сохранение"](app.idProject.."/counter"))
							counter[1] = counter[1]+1
							scenes[#scenes+1] = {ansEvent.value, counter[1]}
							funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))
							funsP["записать сохранение"](app.idProject.."/counter", plugins.json.encode(counter))
							funsP["создать сцену"](app.idProject, app.idProject.."/scene_"..counter[1])

							createSceneSlotCard(#scenes)
							local arSlEnd = arraySlots[#arraySlots].myGroup
							scrollProjects:setScrollHeight(arSlEnd.y+arSlEnd.height/2+display.contentWidth/1.5)
						end
					end

					app.cerberus.newInputLine(app.words[26], app.words[27], isCorrectValue, correctNameSlot(app.words[28]), onCompleteObject)
				else
					cancelMoveTimer()
					app.scenes[app.scene][2].alpha = 0
					app.scenes[app.scene][1].alpha = 0
					isBackScene = 'block'
					display.remove(app.scenes[app.scene][1])
					display.remove(app.scenes[app.scene][2])
					scene_run_game('scenes', {idProject, nameProjectScenes})
				end
			end
		end
		return(true)
	end

	circlePlus:addEventListener("touch", touchCirclePlus)
	circlePlayAlpha:setFillColor(1,1,1,0.125)
	circlePlay:addEventListener("touch", touchCirclePlus)

	local functionsMenu = {}

	local function correctNameScene(value)
		local function isUnique(val)
			for j=1, #scenes do
				if (scenes[j][1]==val) then
					return false
				end
			end
			return true
		end
		if isUnique(value) then
			return value
		end
		local id = 1
		while not isUnique(value.." ("..id..")") do
			id = id + 1
		end
		return value.." ("..id..")"
	end

	local arrayAllButtonsFunctions = {
		["back"]={"back","startmenu",{{4,"copy"},{5,"delete"},{6,"rename"},{9,"options"}}},
		["copy"]={"copy","copyAll",{{10,"copyAll"}}},
		["delete"]={"delete","deleteAll",{{10,"deleteAll"}}},
	}
	arrayAllButtonsFunctions["startmenu"] = arrayAllButtonsFunctions["back"]
	arrayAllButtonsFunctions["copyAll"] = arrayAllButtonsFunctions["copy"]
	arrayAllButtonsFunctions["deleteAll"] = arrayAllButtonsFunctions["delete"]

	functionsMenu["startoptions"] = function()
		cancelMoveTimer()
		display.remove(app.scenes[app.scene][1])
		display.remove(app.scenes[app.scene][2])
		scene_options(app.idProject, app.nmProject)
	end

	local function touchMenu2CopySlot(event)
		if (event.phase=="began") then
			transition.to(event.target, {xScale=0.75, yScale=0.75, time=100})
			display.getCurrentStage():setFocus(event.target, event.id)
		elseif (event.phase=="moved" and (math.abs(event.x-event.xStart)>20 or math.abs(event.y-event.yStart)>20)) then
			transition.to(event.target, {xScale=1, yScale=1, time=200})
			scrollProjects:takeFocus(event)
		elseif (event.phase=="ended" or event.phase=="cancelled") then
			if (event.phase=="ended") then
				if (event.target.isCopySlot) then
					event.target.isCopySlot = nil
				else
					event.target.isCopySlot = true
				end
				event.target.fill = {
					type="image",
					filename="images/checkbox_"..(event.target.isCopySlot and 2 or 1)..".png",
				}
				event.target:setFillColor(171/255, 219/255, 241/255)
			end
			transition.to(event.target, {xScale=1, yScale=1, time=200})
			display.getCurrentStage():setFocus(event.target, nil)
		end
		return(true)
	end

	functionsMenu["startcopy"] = function()
		local arrayIdsWords = {["copy"]=4, ["delete"]=5}
		if (arrayIdsWords[isBackScene]) then
			topBarArray[3].text = app.words[arrayIdsWords[isBackScene]]
		else
			topBarArray[3].text = "заполни название!"
			topBarArray[3]:setFillColor(1,0,0)
		end
		topBarArray[5].alpha = 1
		for j=1, #scenes do
			local slot = arraySlots[j]
			slot.strokeIcon.x = slot.strokeIcon.x+display.contentWidth/20
			slot.containerIcon.x = slot.strokeIcon.x
			slot.nameProject.x = slot.nameProject.x+display.contentWidth/20

			slot.menu2.fill = {
				type="image",
				filename="images/checkbox_1.png",
			}
			slot.menu2:setFillColor(171/255, 219/255, 241/255)
			slot.menu2.x = slot.menu2.x+display.contentWidth/40
			slot.menu2.isCopySlot = nil
			slot.menu2:addEventListener("touch", touchMenu2CopySlot)
			slot.menu.alpha = 0
		end
	end
	functionsMenu["startdelete"] = functionsMenu["startcopy"]

	functionsMenu["checkcopy"] = function ()
		isBackScene = "back"
		topBarArray[3].text = valueHeaderTopBar
		topBarArray[5].alpha = 0
		local countCopiedSlot = 0
		local origCount = #scenes
		for j=1, origCount do
			local slot = arraySlots[j]
			slot.strokeIcon.x = slot.strokeIcon.x-display.contentWidth/20
			slot.containerIcon.x = slot.strokeIcon.x
			slot.nameProject.x = slot.nameProject.x-display.contentWidth/20

			slot.menu2:removeEventListener("touch", touchMenu2CopySlot)
			slot.menu2.fill = {
				type="image",
				filename="images/menu2.png",
			}
			slot.menu2:setFillColor(0,0,0,0.5)
			slot.menu2.x = slot.menu2.x-display.contentWidth/40
			slot.menu.alpha = 1

			if (slot.menu2.isCopySlot) then
				countCopiedSlot = countCopiedSlot+1
				local counter = plugins.json.decode(funsP["получить сохранение"](app.idProject.."/counter"))
				counter[1] = counter[1]+1
				funsP["записать сохранение"](app.idProject.."/counter", plugins.json.encode(counter))
				scenes[#scenes+1] = {correctNameScene(slot.infoScene[1]), counter[1]}
				funsP["копировать сцену"](app.idProject, app.idProject.."/scene_"..slot.infoScene[2], app.idProject.."/scene_"..counter[1])
				funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))

				createSceneSlotCard(#scenes)
				slot.menu2.isCopySlot = nil
			end
		end

		if (countCopiedSlot~=0) then
			funsP["вызвать уведомление"](string.gsub(app.words[countCopiedSlot==1 and 32 or 33], "<count>", countCopiedSlot))
		end

		scrollProjects:setScrollHeight(groupSceneScroll.height+display.contentWidth/1.5)
	end

	functionsMenu["checkdelete"] = function ()
		isBackScene = "back"
		topBarArray[3].text = valueHeaderTopBar
		topBarArray[5].alpha = 0
		local iMinus = 0
		local i2 = 0
		while (i2-iMinus<#scenes) do
			i2 = i2+1
			local idx = i2-iMinus
			local slot = arraySlots[idx]
			if (not slot.menu2.isCopySlot) then
				slot.menu.alpha = 1
				slot.strokeIcon.x = slot.strokeIcon.x-display.contentWidth/20
				slot.containerIcon.x = slot.strokeIcon.x
				slot.nameProject.x = slot.nameProject.x-display.contentWidth/20

				slot.menu2:removeEventListener("touch", touchMenu2CopySlot)
				slot.menu2.fill = {
					type="image",
					filename="images/menu2.png",
				}
				slot.menu2:setFillColor(0,0,0,0.5)
				slot.menu2.x = slot.menu2.x-display.contentWidth/40

				slot.idSlot = idx
				slot.aimPosY = slot.height*(idx-0.5)
				slot.myGroup.y = slot.aimPosY
			else
				table.remove(arraySlots, idx)
				display.remove(slot.myGroup)
				table.remove(scenes, idx)
				iMinus = iMinus+1
				funsP["удалить объект"](app.idProject.."/scene_"..slot.infoScene[2])
				funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))
			end
		end

		if (iMinus~=0 and #arraySlots>0) then
			funsP["вызвать уведомление"](string.gsub(app.words[iMinus==1 and 34 or 35], "<count>", iMinus))
			local _, yScroll = scrollProjects:getContentPosition()
			local arSlEnd = arraySlots[#arraySlots].myGroup
			local newScrollHeight = arSlEnd.y+arSlEnd.height/2+display.contentWidth/1.5
			scrollProjects:setScrollHeight(newScrollHeight)
			scrollProjects:scrollToPosition({
				time=0,
				y=math.min(math.max(yScroll, -newScrollHeight+scrollProjects.height), 0)
			})
		end

		if (#scenes==0) then
			scenes = {{app.words[28], 1}}
			funsP["записать сохранение"](app.idProject.."/counter", "[1, 0, 0, 0]")
			funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))
			funsP["создать сцену"](app.idProject, app.idProject.."/scene_1")
		end
		if (#scenes==1) then
			cancelMoveTimer()
			display.remove(app.scenes[app.scene][1])
			display.remove(app.scenes[app.scene][2])
			scene_objects(idProject.."/scene_"..scenes[1][2].."/objects", nameProjectScenes, scenes[1])
		end
	end

	local function renameButton(event)
		if (event.phase=="ended") then
			local function editingEnd(tableRenameSlot)
				if (tableRenameSlot.isOk) then
					tableRenameSlot.value = tableRenameSlot.value:gsub((utils.isWin and '\r\n' or '\n'), ' ')
					scenes[event.target.idSlot][1] = tableRenameSlot.value
					event.target.nameProject.text = tableRenameSlot.value
					funsP["записать сохранение"](app.idProject.."/scenes", plugins.json.encode(scenes))
				end

				isBackScene = "back"
				topBarArray[4].alpha = 1
				topBarArray[3].text = valueHeaderTopBar

				for j=1, #scenes do
					local slot = arraySlots[j]
					slot.menu.alpha = 1
					slot.menu2.alpha = 1
					slot.strokeIcon.x = slot.strokeIcon.x+display.contentWidth/11
					slot.containerIcon.x = slot.strokeIcon.x
					slot.nameProject.x = slot.nameProject.x+display.contentWidth/11
					slot:removeEventListener("touch", renameButton)
				end

				local _, yScroll = scrollProjects:getContentPosition()
				local newScrollHeight = groupSceneScroll.height+display.contentWidth/1.5
				scrollProjects:setScrollHeight(newScrollHeight)
				scrollProjects:scrollToPosition({
					time=0,
					y=math.min(math.max(yScroll, -newScrollHeight+scrollProjects.height), 0)
				})
			end
			local function checkCorrectName(value)
				if (plugins.utf8.len(value)==0) then
					return(app.words[18])
				else
					for j=1, #scenes do
						if (scenes[j][1]==value) then
							return(app.words[15])
						end
					end
					return("")
				end
			end
			app.cerberus.newInputLine(app.words[31], app.words[27], checkCorrectName, event.target.infoScene[1], editingEnd)
		end
	end

	functionsMenu["startrename"] = function ()
		topBarArray[4].alpha = 0
		topBarArray[3].text = app.words[6]

		for j=1, #scenes do
			local slot = arraySlots[j]
			slot.menu.alpha = 0
			slot.menu2.alpha = 0
			slot.strokeIcon.x = slot.strokeIcon.x-display.contentWidth/11
			slot.containerIcon.x = slot.strokeIcon.x
			slot.nameProject.x = slot.nameProject.x-display.contentWidth/11
			slot:addEventListener("touch", renameButton)
		end

		local iEndSlot = #arraySlots
		while (iEndSlot > 0 and arraySlots[iEndSlot].myGroup.alpha<0.5) do
			iEndSlot = iEndSlot-1
		end
		if iEndSlot > 0 then
			local _, yScroll = scrollProjects:getContentPosition()
			local arSlEnd = arraySlots[iEndSlot].myGroup
			local newScrollHeight = arSlEnd.y+arSlEnd.height/2+display.contentWidth/1.5
			scrollProjects:setScrollHeight(newScrollHeight)
			scrollProjects:scrollToPosition({
				time=0,
				y=math.min(math.max(yScroll, -newScrollHeight+scrollProjects.height), 0)
			})
		end
	end

	functionsMenu["back"] = function()
		isBackScene = arrayAllButtonsFunctions[isBackScene][2]
		local notVisibleRect = display.newImage("images/notVisible.png")
		notVisibleRect.x, notVisibleRect.y, notVisibleRect.width, notVisibleRect.height = CENTER_X, CENTER_Y, display.contentWidth, display.contentHeight
		groupScene:insert(notVisibleRect)

		local groupMenu = display.newGroup()
		groupMenu.x, groupMenu.y = display.contentWidth/1.02, CENTER_Y-display.contentHeight/2+(display.contentWidth-display.contentWidth/1.02)
		groupScene:insert(groupMenu)

		groupMenu.xScale, groupMenu.yScale, groupMenu.alpha = 0.3, 0.3, 0

		local arrayButtonsFunctions = arrayAllButtonsFunctions[isBackScene][3]
		local buttons = {}
		local buttonContainer = display.newContainer(display.contentWidth/1.8, display.contentWidth/7)
		buttonContainer.anchorX, buttonContainer.anchorY = 1, 0
		groupMenu:insert(buttonContainer)
		local buttonCircle = display.newCircle(0,0,buttonContainer.width/2)
		buttonCircle:setFillColor(1,1,1,0.25)
		buttonCircle.xScale, buttonCircle.yScale, buttonCircle.alpha = 0.25, 0.25, 0
		buttonContainer:insert(buttonCircle)

		local function touchTypeFunction(event)
			if (event.phase=="began") then
				buttonContainer:toFront()
				buttonContainer.y = event.target.y
				transition.to(buttonCircle, {time=150, xScale=1.1, yScale=1.1, alpha=1})
			elseif (event.phase=="moved" and (math.abs(event.x-event.xStart)>20 or math.abs(event.y-event.yStart)>20)) then
				transition.to(buttonCircle, {time=150, xScale=0.25, yScale=0.25, alpha=0})
			elseif (event.phase=="ended" or event.phase=="cancelled") then
				if (event.phase~="ended") then
					transition.to(buttonCircle, {time=150, xScale=0.25, yScale=0.25, alpha=0})
					return true
				end
				isBackScene = event.target.typeFunction
				functionsMenu["start"..isBackScene]()
				for j=1, #buttons do
					buttons[j]:removeEventListener("touch", touchTypeFunction)
				end
				display.remove(notVisibleRect)
				transition.to(groupMenu, {time=200, alpha=0, onComplete=function ()
					display.remove(groupMenu)
				end})
			end
			return(true)
		end

		for j=1, #arrayButtonsFunctions do
			buttons[j] = display.newRect(0, display.contentWidth/7*(j-1), display.contentWidth/1.5, display.contentWidth/7)
			buttons[j].anchorX, buttons[j].anchorY = 1, 0
			buttons[j]:setFillColor(48/255, 48/255, 48/255)
			groupMenu:insert(buttons[j])
			buttons[j].typeFunction = arrayButtonsFunctions[j][2]
			buttons[j]:addEventListener("touch", touchTypeFunction)

			buttons[j].header = display.newText(app.words[arrayButtonsFunctions[j][1]], -buttons[j].width/1.1, buttons[j].y+buttons[j].height/2, nil, app.fontSize1)
			buttons[j].header.anchorX = 0
			groupMenu:insert(buttons[j].header)
		end

		transition.to(groupMenu, {time=150, xScale=1, yScale=1, alpha=1, transition=easing.outQuad})

		notVisibleRect:addEventListener("touch", function (closeEvent)
			if (closeEvent.phase=="ended") then
				isBackScene = arrayAllButtonsFunctions[isBackScene][1]
				display.remove(notVisibleRect)
				for j=1, #buttons do
					buttons[j]:removeEventListener("touch", touchTypeFunction)
				end
				transition.to(groupMenu, {time=200, alpha=0, onComplete=function ()
					display.remove(groupMenu)
				end})
			end
			return(true)
		end)
	end

	functionsMenu["startcopyAll"] = function()
		isBackScene = arrayAllButtonsFunctions[isBackScene][1]
		local setIsCopy = arrayAllButtonsFunctions[isBackScene][3][1][1] == 10 and true or nil
		for j=1, #arraySlots do
			local slot = arraySlots[j]
			slot.menu2.isCopySlot = setIsCopy
			slot.menu2.fill = {
				type="image",
				filename="images/checkbox_"..(setIsCopy and 2 or 1)..".png",
			}
			slot.menu2:setFillColor(171/255, 219/255, 241/255)
		end
	end
	functionsMenu["startdeleteAll"] = functionsMenu["startcopyAll"]

	functionsMenu["copy"] = function ()
		local isCancel = true
		for j=1, #arraySlots do
			if (arraySlots[j].menu2.isCopySlot==nil) then
				isCancel = false
				break
			end
		end
		arrayAllButtonsFunctions[isBackScene][3][1][1] = isCancel and 11 or 10
		functionsMenu["back"]()
	end
	functionsMenu["delete"] = functionsMenu["copy"]

	funMenuObjects[1] = function ()
		functionsMenu[isBackScene]()
	end
	funCheckObjects[1] = function ()
		functionsMenu["check"..isBackScene]()
	end

	funBackObjects[1] = function (isSystem)
		if (isSystem==nil or isBackScene=="back") then
			if (isBackScene=="back") then
				cancelMoveTimer()
				display.remove(app.scenes[app.scene][1])
				display.remove(app.scenes[app.scene][2])
				scene_projects()
			elseif (isBackScene=="rename") then
				isBackScene = "back"
				topBarArray[4].alpha = 1
				topBarArray[3].text = valueHeaderTopBar
				for j=1, #scenes do
					local slot = arraySlots[j]
					slot.menu.alpha = 1
					slot.menu2.alpha = 1
					slot.strokeIcon.x = slot.strokeIcon.x+display.contentWidth/11
					slot.containerIcon.x = slot.strokeIcon.x
					slot.nameProject.x = slot.nameProject.x+display.contentWidth/11
					slot:removeEventListener("touch", renameButton)
				end
			else
				for j=1, #arraySlots do
					arraySlots[j].menu2.isCopySlot = nil
				end
				functionsMenu["check"..isBackScene]()
			end
		end
	end
end
