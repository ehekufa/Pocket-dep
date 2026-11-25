-- сцена с конкретной категорией блоков

local getCategoriesBlocks = require("pocketup.gameAndBlocks.blocks.categoriesBlocks")
oldBackScripts = nil
function scene_categoryScripts(category, nameCategory, funAddBlock)

	if (oldBackScripts==nil) then
		oldBackScripts=funBack
	end

	local namesFunctions = plugins.json.decode(funsP["получить сохранение"](app.idScene.."/functions"))
	local nameFunction = nil
	if (#namesFunctions>0) then
		nameFunction = namesFunctions[#namesFunctions][1]
	else
		namesFunctions[1] = {1, app.words[79], 0}
		funsP["записать сохранение"](app.idScene.."/functions", plugins.json.encode(namesFunctions))
		nameFunction = 1
	end

	local objsList = funsP["получить json"](app.idScene.."/objects")
	local idBackgroundObject = objsList[1] and objsList[1][2]
	local namesBackgrounds = idBackgroundObject and funsP["получить json"](app.idScene.."/object_"..idBackgroundObject.."/images") or {}
	local nameBackground = #namesBackgrounds>0 and namesBackgrounds[1][2] or nil
	local namesGlobalVariables = funsP["получить json"](app.idProject.."/variables")
	local namesLocalVariables = funsP["получить json"](app.idObject.."/variables")
	local nameVariable = nil
	local localityVariable = "globalVariable"
	if (#namesLocalVariables>0) then
		nameVariable = namesLocalVariables[#namesLocalVariables][1]
		localityVariable = "localVariable"
	elseif (#namesGlobalVariables>0) then
		nameVariable = namesGlobalVariables[#namesGlobalVariables][1]
	end
	local namesGlobalArrays = funsP["получить json"](app.idProject.."/arrays")
	local namesLocalArrays = funsP["получить json"](app.idObject.."/arrays")
	local nameArray = nil
	local localityArray = "globalArray"
	if (#namesLocalArrays>0) then
		nameArray = namesLocalArrays[#namesLocalArrays][1]
		localityArray = "localArray"
	elseif (#namesGlobalArrays>0) then
		nameArray = namesGlobalArrays[#namesGlobalArrays][1]
	end
	local namesScenes = funsP["получить json"](app.idProject.."/scenes")
	local nameScene = nil
	if (#namesScenes>1) then
		if (app.idScene~=app.idProject.."/scene_"..namesScenes[1][2]) then
			nameScene = namesScenes[1][2]
		else
			nameScene = namesScenes[2][2]
		end
	end
	local namesSounds = funsP["получить json"](app.idObject.."/sounds")
	local nameSound = #namesSounds>0 and namesSounds[1][2] or nil
	local namesImages = funsP["получить json"](app.idObject.."/images")
	local nameImage = #namesImages>0 and namesImages[1][2] or nil
	local namesVideos = funsP["получить json"](app.idObject.."/videos")
	local nameVideo = #namesVideos>0 and namesVideos[1][2] or nil

	local groupScene = display.newGroup()
	local groupSceneScroll = display.newGroup()
	app.scene = "categoryScripts"
	app.scenes[app.scene] = {groupScene, groupSceneScroll}
	local isSceneAlive = true
	local loadTimer = nil
	local touchBackMenu = {function ()
		isSceneAlive = false
		if loadTimer then
			timer.cancel(loadTimer)
			loadTimer = nil
		end
		display.remove(groupScene)
		display.remove(groupSceneScroll)
		scene_categoriesScripts(funAddBlock)
	end}
	local topBarArray = topBar(groupScene, nameCategory, nil, nil, touchBackMenu)
	topBarArray[4].alpha = 0

	local scrollProjects = plugins.widget.newScrollView({
		width=display.contentWidth,
		height=display.contentHeight-topBarArray[1].height,
		horizontalScrollDisabled=true,
		isBounceEnabled=false,
		hideBackground=true,
	})
	scrollProjects.x = CENTER_X
	groupScene:insert(scrollProjects)
	scrollProjects:insert(groupSceneScroll)
	scrollProjects.anchorY=0
	scrollProjects.y = topBarArray[1].y+topBarArray[1].height

	local function loadBlocksCategory(blocksCategory)
		if (blocksCategory==nil) then
			scrollProjects:setScrollHeight(groupSceneScroll.height+display.contentWidth/2)
			return
		end
		local yTargetPos = 0
		local function touchBlockRow(event)
			if (event.phase=="began") then
				display.getCurrentStage():setFocus(event.target, event.id)
			elseif (event.phase=="moved" and (math.abs(event.y-event.yStart)>20 or math.abs(event.x-event.xStart)>20)) then
				scrollProjects:takeFocus(event)
			elseif (event.phase=="ended" or event.phase=="cancelled") then
				display.getCurrentStage():setFocus(event.target, nil)
				if (event.phase=="ended") then
					if (553~=nameCategory) then
						isSceneAlive = false
						if loadTimer then
							timer.cancel(loadTimer)
							loadTimer = nil
						end
						local infoBlock = event.target.infoBlock
						display.remove(app.scenes[app.scene][1])
						display.remove(app.scenes[app.scene][2])
						app.scene = "scripts"
						app.scenes[app.scene][1].alpha = 1
						app.scenes[app.scene][1].x = 0
						funBack = oldBackScripts
						oldBackScripts = nil
						funAddBlock(infoBlock)
					else
						app.cerberus.newBannerQuestion(app.words[616], nil, "", app.words[16])
					end
				end
			end
			return(true)
		end

		for i=1, #blocksCategory do
			local block = createBlock(blocksCategory[i])
			block.infoBlock = utils.deepCopy(blocksCategory[i])
			yTargetPos = yTargetPos+block.height
			block.y = yTargetPos-block.height/2
			groupSceneScroll:insert(block)
			block:addEventListener("touch", touchBlockRow)
		end
		scrollProjects:setScrollHeight(groupSceneScroll.height+display.contentWidth/2)
	end

	local allBlocksCategories = getCategoriesBlocks(localityVariable, nameVariable, localityArray, nameArray, nameFunction, nameBackground, nameScene, nameSound, nameImage, nameVideo )
	loadBlocksCategory(allBlocksCategories[category])
end
