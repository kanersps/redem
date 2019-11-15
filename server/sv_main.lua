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
    ['defaultDatabase'] = GetConvar('es_defaultDatabase', '1'),
    ['enableCustomData'] = GetConvar('es_enableCustomData', '0'),
    ['identifierUsed'] = GetConvar('es_identifierUsed', 'steam')
}

print("(server) EssentialMode: RedM edition loaded (" .. _VERSION .. ")")


RegisterServerEvent('playerConnecting')
AddEventHandler('playerConnecting', function(name, setKickReason)
	local id
	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len(settings.defaultSettings.identifierUsed .. ":")) == (settings.defaultSettings.identifierUsed .. ":") then
			id = v
			break
		end
	end

	if not id then
		setKickReason("Unable to find requested identifier: '" .. settings.defaultSettings.identifierUsed .. "', please relaunch RedM")
		CancelEvent()
	end
end)

RegisterServerEvent("redem:playerActivated")
AddEventHandler("redem:playerActivated", function()
    local _source = source
    printServer("Player activated: " .. GetPlayerName(_source))

    local id
    for k,v in ipairs(GetPlayerIdentifiers(Source))do
        if string.sub(v, 1, string.len(settings.defaultSettings.identifierUsed .. ":")) == (settings.defaultSettings.identifierUsed .. ":") then
            id = v
            break
        end
    end
        
    registerUser(id, _source)
end)