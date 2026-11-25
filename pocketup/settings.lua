-- базовые настройки проекта
_G.app = {}
app.cerberus = {}
app.scenes = {}
app.scene = 'null'

_G.plugins = {}
_G.utils = {}

utils.isWin = system.getInfo 'platform' ~= 'android'
utils.isSim = system.getInfo 'environment' == 'simulator'

plugins.utf8 = require( "plugin.utf8" )
plugins.utf8.split = function(text, sep) local result = {} for s in text:gmatch('[^' .. sep .. ']+') do result[#result + 1] = s end return result end
plugins.json = require("json")
plugins.widget = require("widget")

plugins.lfs = require("lfs")
plugins.physics = require("physics")
plugins.orientation = require('plugin.orientation')
plugins.perlin = require("plugins.noise")

display.contentWidth = display.actualContentWidth
--display.contentHeight = display.safeActualContentHeight
if (utils.isWin) then
    display.contentHeight = display.safeActualContentHeight
else
    display.contentHeight = display.actualContentHeight
end
CENTER_X = display.contentCenterX
CENTER_Y = display.screenOriginY+display.contentHeight/2

app.words = require("pocketup.modules.loadLanguage")

display.setDefault( 'minTextureFilter', 'nearest' )
display.setDefault( 'magTextureFilter', 'nearest' )

function utils.deepCopy(orig)
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = (type(v) == "table") and utils.deepCopy(v) or v
    end
    return copy
end

utils._blockImageSheets = {}
function utils.getBlockImageSheet(imagePath, options)
    local key = imagePath .. "|" .. tostring(options.width) .. "x" .. tostring(options.height) .. "x" .. tostring(options.numFrames)
    local sheet = utils._blockImageSheets[key]
    if not sheet then
        sheet = graphics.newImageSheet(imagePath, options)
        utils._blockImageSheets[key] = sheet
    end
    return sheet
end

os.removeFolder = function (path, isremove)
    if type(path) ~= "string" then
        return
    end
    local rootAttr = plugins.lfs.attributes(path)
    if not rootAttr or rootAttr.mode ~= "directory" then
        return
    end
    local sep = utils.isWin and "\\" or "/"
    for file in plugins.lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local filePath = path .. sep .. file
            local attr = plugins.lfs.attributes(filePath)
            if attr ~= nil then
                if attr.mode == "directory" then
                    os.removeFolder(filePath)
                else
                    os.remove(filePath)
                end
            end
        end
    end
    if not isremove then
        plugins.lfs.rmdir(path)
    end
end

os.copy = function(link, link2)
    if type(link) ~= "string" or type(link2) ~= "string" then
        return false
    end
    local src = io.open(link, "rb")
    if not src then
        return false
    end
    local dst = io.open(link2, "wb")
    if not dst then
        io.close(src)
        return false
    end
    while true do
        local chunk = src:read(65536)
        if not chunk then
            break
        end
        dst:write(chunk)
    end
    io.close(src)
    io.close(dst)
    return true
end

function os.copy_folder(path, path2, isCreate2)
    if not isCreate2 then
        plugins.lfs.mkdir(path2)
    end
    local rootAttr = plugins.lfs.attributes(path)
    if not rootAttr or rootAttr.mode ~= "directory" then
        return
    end
    for file in plugins.lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local filePath = path.."/"..file
            local attr = plugins.lfs.attributes(filePath)
            if attr and attr.mode == "directory" then
                os.copy_folder(filePath, path2..'/'..file)
            elseif attr then
                os.copy(filePath, path2..'/'..file)
            end
        end
    end
end

_G.display = display
_G.system = system
_G.os = os
_G.timer = timer
_G.Runtime = Runtime
_G.graphics = graphics
_G.audio = audio
_G.native = native

os.write = function (value , path , basedir)
    if type(path) ~= 'string' or value == nil then
        return true
    end
    local link = path
    if basedir then
        link = system.pathForFile(path , basedir)
    end
    local file = io.open(link , 'wb')
    if not file then
        return false
    end
    file:write(value)
    file:close()
end

os.read = function (path , mode , basedir)
    local link = path
    if type(path) ~= 'string' then
        return true
    end
    if type(mode) ~= 'string' then
        mode = '*a'
    end
    if basedir then
        link = system.pathForFile(path , basedir)
    end
    local file = io.open(link , 'rb')
    if not file then
        return nil
    end
    local value = file:read(mode)
    file:close()
    return value
end

display.setStatusBar(display.DefaultStatusBar)

function setFocus(object, id)
	display.getCurrentStage():setFocus( object, id )
end

app.cerberus.newImage = function(nameFile, directory, x, y)
	if (directory~=system.DocumentsDirectory) then
		return display.newImage(nameFile)
	else
		-- взять изображение из ресурсов
	end
end

app.idProject = nil
app.nmProject = nil
app.idScene = nil
app.idObject = nil
display.setDefault("background", 4/255, 34/255, 44/255)
app.scene = nil

---------------------------------------------------
utils.printText = display.newText({
	text="тест",
	x=CENTER_X,
	y=CENTER_Y*1.5,
	width=display.contentWidth,
	font=nil,
	fontSize=nil,
})
function utils.printC(event)
	utils.printText.text = event
	utils.printText:toFront()
end
utils.printText.alpha=0
---------------------------------------------------
app.fontSizeBlock = math.min(display.contentWidth/15, 32.5)
app.fontSize1 = math.min(display.contentWidth/20, 32.5)
app.fontSize2 = math.min(display.contentWidth/24, 25)
app.fontSize0 = app.fontSize1*1.125
app.roundedRect = app.fontSize1/8



utils.select_Scroll = ''

function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end