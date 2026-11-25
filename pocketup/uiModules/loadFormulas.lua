-- визуальная прогрузка формулы в блоке или редакторе выражений

--[[ отправляемы данные
event - plugins.json формула конкретного параметра в блоке
posCursor - позиция(number), на которой нужно отобразить курсор. необязательный параметр(при указании nil курсор в формуле не будет добавлен)
]]

-- получаемые данные - текст-формула(string)

local tableTrueSpace = {
	["-"]=true,
	["+"]=true,
	["÷"]=true,
	["×"]=true,
	["("]=true,
	[")"]=true,
	[""]=true,
}

function loadFormula(event, posCursor)
	local allVariables
	local allArrays
	local tableObjects
	local parts = {}
	local nParts = 0

	for i=1, #event do
		local item = event[i]
		local typeFormula = item[1]
		local oldNameFormula = event[i > 1 and (i - 1) or 1][2]
		local nameFormula = item[2]
		if (i>1 and nameFormula~="(" and ((typeFormula~="number" and not tableTrueSpace[nameFormula]) or (event[i-1][1]~="number" and not tableTrueSpace[oldNameFormula])) ) then
			nParts = nParts + 1
			parts[nParts] = "  "
		end

		if (posCursor==i) then
			nParts = nParts + 1
			parts[nParts] = "│"
		end

		if (typeFormula=="number") then
			nParts = nParts + 1
			parts[nParts] = tostring(nameFormula)
		elseif (typeFormula=="text") then
			nParts = nParts + 1
			parts[nParts] = "'"..tostring(nameFormula).."'"
		elseif (typeFormula=="localVariable" or typeFormula=="globalVariable") then
			if not allVariables then
				allVariables = {}
				local globalVariables = app.idProject and funsP["получить json"](app.idProject.."/variables") or {}
				local localVariables = app.idObject and funsP["получить json"](app.idObject.."/variables") or {}
				for vi=1, #globalVariables do
					allVariables["globalVariable_"..globalVariables[vi][1]] = globalVariables[vi][2]
				end
				for vi=1, #localVariables do
					allVariables["localVariable_"..localVariables[vi][1]] = localVariables[vi][2]
				end
			end
			local nameVar = allVariables[typeFormula.."_"..tostring(nameFormula)]
			nParts = nParts + 1
			parts[nParts] = '"'..tostring(nameVar==nil and app.words[380] or nameVar)..'"'
		elseif (typeFormula=="localArray" or typeFormula=="globalArray") then
			if not allArrays then
				allArrays = {}
				local globalArrays = app.idProject and funsP["получить json"](app.idProject.."/arrays") or {}
				local localArrays = app.idObject and funsP["получить json"](app.idObject.."/arrays") or {}
				for ai=1, #globalArrays do
					allArrays["globalArray_"..globalArrays[ai][1]] = globalArrays[ai][2]
				end
				for ai=1, #localArrays do
					allArrays["localArray_"..localArrays[ai][1]] = localArrays[ai][2]
				end
			end
			local nameArr = allArrays[typeFormula.."_"..tostring(nameFormula)]
			nParts = nParts + 1
			parts[nParts] = '*'..tostring(nameArr==nil and app.words[381] or nameArr)..'*'
		elseif (nameFormula=="touchesObject2" and item[3]~=nil) then
			if not tableObjects then
				tableObjects = app.idScene and funsP["получить json"](app.idScene.."/objects") or {}
			end
			local idObject = item[3]
			local nameObject
			for oi=1, #tableObjects do
				if (tableObjects[oi][2]==idObject) then
					nameObject = tableObjects[oi][1]
					break
				end
			end
			if (nameObject==nil) then
				nameObject = app.words[618]
			end
			nParts = nParts + 1
			parts[nParts] = tostring(nameFormulas[nameFormula] or "error").."("..tostring(nameObject)..")"
		else
			nParts = nParts + 1
			parts[nParts] = tostring(nameFormulas[nameFormula] or "error")
		end
	end
	if (posCursor==#event+1) then
		nParts = nParts + 1
		parts[nParts] = "│"
	end
	return table.concat(parts)
end