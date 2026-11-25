local language = funsP['получить сохранение']('selectLanguage')
if language == '[]' then
    language = 'Русский'
end
local path = {
    English = 'eng',
    ['Русский'] = 'ru'
}
local file = io.open(system.pathForFile("pocketup/languages/"..(path[language] or "ru")..".json"), "r")
local words = {}
if file then
    words = plugins.json.decode(file:read("*a")) or {}
    io.close(file)
end
return words