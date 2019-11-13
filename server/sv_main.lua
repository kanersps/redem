--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

_serverPrefix = "(client) RedEM: "
_VERSION = '0.1.0'
_firstCheckPerformed = false
_UUID = LoadResourceFile(GetCurrentResourceName(), "uuid") or "unknown"

settings = {}
settings.defaultSettings = {
	['startingCash'] = GetConvar('es_startingCash', '0'),
	['startingBank'] = GetConvar('es_startingBank', '0'),
    ['defaultDatabase'] = GetConvar('es_defaultDatabase', '1')
}

print("(server) EssentialMode: RedM edition loaded (" .. _VERSION .. ")")

RegisterServerEvent("redem:playerActivated")
AddEventHandler("redem:playerActivated", function()
    local _source = source
    printServer("Player activated: " .. GetPlayerName(_source))

    for k,v in ipairs(GetPlayerIdentifiers(_source))do
        print(k .. ":" .. v)

        registerUser("developer", _source)
    end
end)