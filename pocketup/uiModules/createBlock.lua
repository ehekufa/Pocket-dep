-- создание блока как объекта

--[[ отправляемые данные
block - plugins.json таблина с информацией о блоке. пример: {"setPosition", { {{"number", 100}}, {{"number", 200}} }}
]]

--[[ получаемые данные
возвращается группа. допустим, oна называется group;
group.image1 - объект-изображение;
group.image2 - вторая часть объекта-изображения блока;
group.cells - список всех параметров блока;
group.cells[i] - массив, содержащий в себе тип параметра и все объекты(кнопки, тексты и т. д.) от этого параметра;
]]

local _animatesCache = {}
local _sheetOptionsCache = {}

function createBlock(block)
	local infoBlock = allBlocks[block[1]]
	if (infoBlock==nil) then
		infoBlock = {"block", "blocks/block_light_1.png", { {{"text", app.words[612]}} }, 109, 88, false}
	end
	local group = display.newGroup()
	group.x, group.y = CENTER_X, CENTER_Y
	local image = display.newImage(infoBlock[2])
	image.xScale = display.contentWidth/image.width/1.75/(infoBlock[1]=="event" and 1 or 412/109)
	image.yScale = image.xScale*1.4
	image.x = -CENTER_X
	image.anchorX = 0
	group:insert(image)

	local optKey = tostring(infoBlock[5]).."x"..tostring(infoBlock[4])
	local sheetOptions = _sheetOptionsCache[optKey]
	if not sheetOptions then
		sheetOptions = {
			width=1,
			height=infoBlock[5],
			numFrames=infoBlock[4],
		}
		_sheetOptionsCache[optKey] = sheetOptions
	end
	local imageSheet = utils.getBlockImageSheet(infoBlock[2], sheetOptions)
	local animates = _animatesCache[infoBlock[4]]
	if not animates then
		animates = {{
			name="stand",
			start=infoBlock[4],
			count=1,
			time=0,
			loopCount=1,
		}}
		_animatesCache[infoBlock[4]] = animates
	end

	local sprite = display.newSprite(imageSheet, animates)
	sprite.width = display.contentWidth-image.width*image.xScale
	sprite.x = image.x+(image.width-1)*image.xScale
	sprite.yScale, sprite.anchorX, sprite.height = image.yScale, 0, image.height
	group:insert(sprite)
	local formulas = infoBlock[3]
	local xF = -display.contentCenterX/1.5
	local yF = 0
	local countCells = 0
	group.image1 = image
	group.image2 = sprite
	group.cells = {}
	local group2 = display.newGroup()
	group:insert(group2)

	if (infoBlock[2]:find("yellow", 1, true) ~= nil) then
		sprite:setFillColor(0.85,0.85,0.75)
		image:setFillColor(0.85,0.85,0.75)
	end
	local isLightBlock = infoBlock[2]:find("light_", 1, true) ~= nil

	if (block[1]:find("paidBlock_", 1, true) ~= nil) then
		local rect = display.newRoundedRect(-display.contentWidth/2.4, -sprite.height/2+display.contentWidth/17, 0, display.contentWidth/16, display.contentWidth/32)
		group:insert(rect)
		rect:setFillColor(0.25,0.75,0.4)
		rect.strokeWidth = 2
		rect:setStrokeColor(0.2, 0.6, 0.3)
		local text = display.newText("25₽", rect.x, rect.y, nil, app.fontSize1)
		group:insert(text)
		rect.width = text.width+rect.height
	end

	for i=1, #formulas do
		for i2=1, #formulas[i] do
			local rawFormula = formulas[i][i2]
			local formulaType = rawFormula[1]
			local formulaVal

			if (formulaType~="text") then
				countCells = countCells+1
				formulaVal = block[2] and block[2][countCells]
			else
				formulaVal = rawFormula[2]
			end

			if (formulaType=="text") then
				local header = display.newText(formulaVal, xF, yF, "fonts/font_1.ttf", app.fontSizeBlock)
				if isLightBlock then
					header:setFillColor(0, 0, 0)
				end
				header.anchorX=0
				group2:insert(header)
				xF = header.x+header.width+display.contentWidth/30
			elseif (formulaType=="cell") then
				local button = display.newImage("images/notVisible.png")
				button.width, button.height = display.contentWidth/10*rawFormula[3], display.contentWidth/15
				button.anchorX, button.x, button.y = 0, xF, yF
				button.alpha = 0.5
				group2:insert(button)
				local line = display.newRect(button.x+button.width/2, button.y+button.height/2, button.width, display.contentWidth/300)
				line.anchorY=0
				group2:insert(line)
				local valueCell = display.newText({
					text = loadFormula(formulaVal or {}),
					x = button.x+button.width/2,
					y=button.y,
					width=button.width,
					height=button.height,
					align="center",
					font=nil,
					fontSize=app.fontSize1,
				})
				group2:insert(valueCell)
				group.cells[#group.cells+1] = {"cell", button, line, valueCell}
				button.idParameter = #group.cells
				button.block = group
				button.typeParameter = "cell"
				xF = button.x+button.width+display.contentWidth/30
			elseif (formulaType=="function" or formulaType=="objects" or formulaType=="backgrounds" or formulaType=="variables" or formulaType=="arrays" or formulaType=="scenes" or formulaType=="scripts" or formulaType=="goTo" or formulaType=="typeRotate" or formulaType=="sounds" or formulaType=="images" or formulaType=="effectParticle" or formulaType=="onOrOff" or formulaType=="alignText" or formulaType=="isDeleteFile" or formulaType=="typeBody" or formulaType=="GL" or formulaType=="inputType" or formulaType=="videos") then
				yF = yF-display.contentWidth/40
				local button = display.newImage("images/notVisible.png")
				button.x, button.y, button.width, button.height = -display.screenOriginX+display.contentWidth/25, yF, display.contentWidth/2.625*2, display.contentWidth/15
				group2:insert(button)
				local triangle = display.newText("◢", button.x+button.width/2, button.y, nil, app.fontSize2)
				triangle.rotation = 45
				group2:insert(triangle)

				local nameFunction = ""
				if (formulaType=="function") then
					local namesFunctions = funsP["получить json"](app.idScene.."/functions")
					for j=1, #namesFunctions do
						if (namesFunctions[j][1]==formulaVal[2]) then
							nameFunction = namesFunctions[j][2]
							break
						end
					end
				elseif (formulaType=="objects") then
					nameFunction = app.words[(block[1]=="collision" or block[1]=="endedCollision") and 85 or (block[1]=="clone" or block[1]:find("broadcastFun>", 1, true)~=nil) and 90 or 87]
					local namesObjects = funsP["получить json"](app.idScene.."/objects")
					for j=1, #namesObjects do
						if (namesObjects[j][2]==formulaVal[2]) then
							nameFunction = namesObjects[j][1]
							break
						end
					end
					if (nameFunction==nil) then
						nameFunction = app.words[85]
					end
				elseif (formulaType=="backgrounds") then
					nameFunction = app.words[87]
					local objsList = funsP["получить json"](app.idScene.."/objects")
					local idBackgroundObject = objsList[1] and objsList[1][2]
					if idBackgroundObject then
						local namesBackgrounds = funsP["получить json"](app.idScene.."/object_"..idBackgroundObject.."/images")
						for j=1, #namesBackgrounds do
							if (namesBackgrounds[j][2]==formulaVal[2]) then
								nameFunction = namesBackgrounds[j][1]
								break
							end
						end
					end
				elseif (formulaType=="variables") then
					nameFunction = app.words[87]
					local namesVariables = funsP["получить json"]((formulaVal[1]=="globalVariable" and app.idProject or app.idObject).."/variables")
					for j=1, #namesVariables do
						if (namesVariables[j][1]==formulaVal[2]) then
							nameFunction = namesVariables[j][2]
						end
					end
				elseif (formulaType=="arrays") then
					nameFunction = app.words[87]
					local namesArrays = funsP["получить json"]((formulaVal[1]=="globalArray" and app.idProject or app.idObject).."/arrays")
					for j=1, #namesArrays do
						if (namesArrays[j][1]==formulaVal[2]) then
							nameFunction = namesArrays[j][2]
						end
					end
				elseif (formulaType=="scenes") then
					nameFunction = app.words[87]
					local namesScenes = funsP["получить json"](app.idProject.."/scenes")
					for j=1, #namesScenes do
						if (namesScenes[j][2]==formulaVal[2]) then
							nameFunction = namesScenes[j][1]
							break
						end
					end
				elseif (formulaType=="scripts") then
					local namesScripts = {["thisScript"]=app.words[114], ["allScripts"]=app.words[115], ["otherScripts"]=app.words[116]}
					nameFunction = namesScripts[formulaVal[2]]
				elseif (formulaType=="goTo") then
					if (formulaVal[2]=="touch") then
						nameFunction = app.words[123]
					elseif (formulaVal[2]=="random") then
						nameFunction = app.words[124]
					else
						nameFunction = app.words[123]
						local namesObjects = funsP["получить json"](app.idScene.."/objects")
						for j=1, #namesObjects do
							if (namesObjects[j][2]==formulaVal[2]) then
								nameFunction = namesObjects[j][1]
								break
							end
						end
					end
				elseif (formulaType=="typeRotate") then
					local typesRotates = {
						["leftToRight"] = app.words[133],
						["true"] = app.words[134],
						["false"] = app.words[135]
					}
					nameFunction = typesRotates[formulaVal[2]]
				elseif (formulaType=="sounds") then
					nameFunction = app.words[87]
					local namesSounds = funsP["получить json"](app.idObject.."/sounds")
					for j=1, #namesSounds do
						if (formulaVal[2]==namesSounds[j][2]) then
							nameFunction = namesSounds[j][1]
							break
						end
					end
				elseif (formulaType=="images") then
					nameFunction = app.words[87]
					local namesImages = funsP["получить json"](app.idObject.."/images")
					for j=1, #namesImages do
						if (formulaVal[2]==namesImages[j][2]) then
							nameFunction = namesImages[j][1]
							break
						end
					end
				elseif (formulaType=="effectParticle") then
					local typesParticles = {
						["in"]=app.words[178],
						["out"]=app.words[179],
					}
					nameFunction = typesParticles[formulaVal[2]]
				elseif (formulaType=="onOrOff") then
					nameFunction = formulaVal[2]=="on" and app.words[183] or app.words[184]
				elseif (formulaType=="alignText") then
					local alignsText = {
						["center"]=app.words[210],
						["left"]=app.words[211],
						["right"]=app.words[212],
					}
					nameFunction = alignsText[formulaVal[2]]
				elseif (formulaType=="isDeleteFile") then
					nameFunction = formulaVal[2]=="save" and app.words[222] or app.words[223]
				elseif (formulaType=="typeBody") then
					local typesParticles = {
						["dynamic"]=app.words[393],
						["static"]=app.words[394],
						["noPhysic"]=app.words[395],
					}
					nameFunction = typesParticles[formulaVal[2]]
				elseif (formulaType=="GL") then
					nameFunction = formulaVal[2]
				elseif (formulaType=="inputType") then
					local types = {
						["default"] = app.words[498],
						["number"] = app.words[499],
						["decimal"] = app.words[500],
						["phone"] = app.words[501],
						["url"] = app.words[502],
						["email"] = app.words[503],
						["no-emoji"] = app.words[504],
					}
					nameFunction = types[formulaVal[2]]
				elseif (formulaType=="videos") then
					nameFunction = app.words[87]
					local namesVideos = funsP["получить json"](app.idObject.."/videos")
					for j=1, #namesVideos do
						if (formulaVal[2]==namesVideos[j][2]) then
							nameFunction = namesVideos[j][1]
							break
						end
					end
				end

				local header = display.newText(nameFunction, button.x-button.width/2, yF, nil, app.fontSize1)
				header.anchorX=0
				group2:insert(header)
				group.cells[#group.cells+1] = {"function", button, header, triangle}
				button.idParameter = #group.cells
				button.typeParameter = formulaType
				button.block = group
				yF = yF-display.contentWidth/40
			elseif (formulaType=="shapeHitbox") then
				local button = display.newImage("images/notVisible.png")
				button.x, button.y, button.width, button.height = -display.screenOriginX+display.contentWidth/25, yF, display.contentWidth/2.625*2, display.contentWidth/15
				group2:insert(button)
				local line = display.newRect(button.x, button.y+button.height/2, button.width, display.contentWidth/300)
				line.anchorY=0
				group2:insert(line)
				local valueCell = display.newText({
					text = formulaVal[2],
					x = button.x,
					y=button.y,
					width=button.width,
					height=button.height,
					align="left",
					font=nil,
					fontSize=app.fontSize1,
				})
				group2:insert(valueCell)
				group.cells[#group.cells+1] = {"shapeHitbox", button, line, valueCell}
				button.idParameter = #group.cells
				button.block = group
				button.typeParameter = "shapeHitbox"
				yF = yF-display.contentWidth/40
			end -- elseif
		end
		yF = yF + display.contentWidth/10
		xF = -display.contentCenterX/1.5
	end
	group2.y = -group2.height/2+(infoBlock[1]=="event" and display.contentWidth/10 or display.contentWidth/40)
	for i=1, #group.cells do
		group.cells[i][2].heightParameters = group2.height
	end
	return(group)
end
