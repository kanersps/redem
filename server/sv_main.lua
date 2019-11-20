--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

_serverPrefix = "(client) RedEM: "
_VERSION = '0.1.0'
_firstCheckPerformed = false
_UUID = LoadResourceFile(GetCurrentResourceName(), "uuid") or "unknown"

commands = {}
commandSuggestions = {}

settings = {}
settings.defaultSettings = {
	['startingCash'] = GetConvar('es_startingCash', '0'),
	['startingBank'] = GetConvar('es_startingBank', '0'),
    ['defaultDatabase'] = GetConvar('es_defaultDatabase', '1'),
    ['enableCustomData'] = GetConvar('es_enableCustomData', '0'),
    ['identifierUsed'] = GetConvar('es_identifierUsed', 'steam'),
    ['commandDelimeter'] = GetConvar('commandDelimeter', '/')
}

print("(server) RedEM: RedM edition loaded (" .. _VERSION .. ")")


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

AddEventHandler('playerDropped', function()
	local Source = source

	if(Users[Source])then
		TriggerEvent("redem:playerDropped", Users[Source])
		db.updateUser(Users[Source].get('identifier'), {money = Users[Source].getMoney(), bank = Users[Source].getBank()})
		Users[Source] = nil
	end
end)

RegisterServerEvent("redem:playerActivated")
AddEventHandler("redem:playerActivated", function()
    local _source = source
    printServer("Player activated: " .. GetPlayerName(_source))

    local id
    for k,v in ipairs(GetPlayerIdentifiers(_source))do
        if string.sub(v, 1, string.len(settings.defaultSettings.identifierUsed .. ":")) == (settings.defaultSettings.identifierUsed .. ":") then
            id = v
            break
        end
    end
        
    registerUser(id, _source)
end)

-- Command handler
AddEventHandler('chatMessage', function(source, n, message)
	if(settings.defaultSettings.disableCommandHandler ~= 'false')then
		return
	end

	if(startswith(message, settings.defaultSettings.commandDelimeter))then
		local command_args = stringsplit(message, " ")

		command_args[1] = string.gsub(command_args[1], settings.defaultSettings.commandDelimeter, "")

		local commandName = command_args[1]
		local command = commands[commandName]

		if(command)then
			local Source = source
			CancelEvent()
			if(command.perm > 0)then
				if(IsPlayerAceAllowed(Source, "command." .. command_args[1]) or Users[source].getPermissions() >= command.perm or groups[Users[source].getGroup()]:canTarget(command.group))then
					table.remove(command_args, 1)
					if (not (command.arguments == #command_args - 1) and command.arguments > -1) then
						TriggerEvent("redem:incorrectAmountOfArguments", source, commands[command].arguments, #args, Users[source])
					else
						command.cmd(source, command_args, Users[source])
						TriggerEvent("redem:adminCommandRan", source, command_args, Users[source])
						log('User (' .. GetPlayerName(Source) .. ') ran admin command ' .. commandName .. ', with parameters: ' .. table.concat(command_args, ' '))
					end
				else
					command.callbackfailed(source, command_args, Users[source])
					TriggerEvent("redem:adminCommandFailed", source, command_args, Users[source])

					if(settings.defaultSettings.permissionDenied ~= "false" and not WasEventCanceled())then
						TriggerClientEvent('chatMessage', source, "", {0,0,0}, settings.defaultSettings.permissionDenied)
					end

					log('User (' .. GetPlayerName(Source) .. ') tried to execute command without having permission: ' .. command_args[1])
					debugMsg("Non admin (" .. GetPlayerName(Source) .. ") attempted to run admin command: " .. commandName)
				end
			else
				table.remove(command_args, 1)
				if (not (command.arguments <= (#command_args - 1)) and command.arguments > -1) then
					TriggerEvent("redem:incorrectAmountOfArguments", source, commands[command].arguments, #args, Users[source])
				else
					command.cmd(source, command_args, Users[source])
					TriggerEvent("redem:userCommandRan", source, command_args)
				end
			end
			
			TriggerEvent("redem:commandRan", source, command_args, Users[source])
		else
			TriggerEvent('redem:invalidCommandHandler', source, command_args, Users[source])

			if WasEventCanceled() then
				CancelEvent()
			end
		end
	else
		TriggerEvent('redem:chatMessage', source, message, Users[source])

		if WasEventCanceled() then
			CancelEvent()
		end
	end
end)

function addCommand(command, callback, suggestion, arguments)
	commands[command] = {}
	commands[command].perm = 0
	commands[command].group = "user"
	commands[command].cmd = callback
	commands[command].arguments = arguments or -1

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

	if(settings.defaultSettings.disableCommandHandler ~= 'false')then
		RegisterCommand(command, function(source, args)
			if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
				callback(source, args, Users[source])
			else
				TriggerEvent("redem:incorrectAmountOfArguments", source, commands[command].arguments, #args, Users[source])
			end
		end, false)
	end

	debugMsg("Command added: " .. command)
end

AddEventHandler('redem:addCommand', function(command, callback, suggestion, arguments)
	addCommand(command, callback, suggestion, arguments)
end)

function addAdminCommand(command, perm, callback, callbackfailed, suggestion, arguments)
	commands[command] = {}
	commands[command].perm = perm
	commands[command].group = "superadmin"
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed
	commands[command].arguments = arguments or -1

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

	ExecuteCommand('add_ace group.superadmin command.' .. command .. ' allow')

	if(settings.defaultSettings.disableCommandHandler ~= 'false')then
		RegisterCommand(command, function(source, args)
			local Source = source

			-- Console check
			if(source ~= 0)then
				if IsPlayerAceAllowed(Source, "command." .. command) or Users[source].getPermissions() >= perm then
					if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
						callback(source, args, Users[source])
					else
						TriggerEvent("redem:incorrectAmountOfArguments", source, commands[command].arguments, #args, Users[source])
					end
				else
					callbackfailed(source, args, Users[source])
				end
			else
				if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
					callback(source, args, Users[source])
				else
					TriggerEvent("redem:incorrectAmountOfArguments", source, commands[command].arguments, #args, Users[source])
				end
			end
		end, true)
	end

	debugMsg("Admin command added: " .. command .. ", requires permission level: " .. perm)
end

AddEventHandler('redem:addAdminCommand', function(command, perm, callback, callbackfailed, suggestion, arguments)
	addAdminCommand(command, perm, callback, callbackfailed, suggestion, arguments)
end)

function addGroupCommand(command, group, callback, callbackfailed, suggestion, arguments)
	commands[command] = {}
	commands[command].perm = math.maxinteger
	commands[command].group = group
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed
	commands[command].arguments = arguments or -1

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

	ExecuteCommand('add_ace group.' .. group .. ' command.' .. command .. ' allow')

	if(settings.defaultSettings.disableCommandHandler ~= 'false')then
		RegisterCommand(command, function(source, args)
			local Source = source

			-- Console check
			if(source ~= 0)then
				if IsPlayerAceAllowed(Source, "command." .. command) or groups[Users[source].getGroup()]:canTarget(group) then
					if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
						callback(source, args, Users[source])
					else
						TriggerEvent("redem:incorrectAmountOfArguments", source, commands[command].arguments, #args, Users[source])
					end
				else
					callbackfailed(source, args, Users[source])
				end
			else
				if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
					callback(source, args, Users[source])
				else
					TriggerEvent("redem:incorrectAmountOfArguments", source, commands[command].arguments, #args, Users[source])
				end
			end
		end, true)
	end

	debugMsg("Group command added: " .. command .. ", requires group: " .. group)
end

AddEventHandler('redem:addGroupCommand', function(command, group, callback, callbackfailed, suggestion, arguments)
	addGroupCommand(command, group, callback, callbackfailed, suggestion, arguments)
end)

AddEventHandler('redem:addACECommand', function(command, group, callback)
	addACECommand(command, group, callback)
end)

-- Info command
commands['info'] = {}
commands['info'].perm = 0
commands['info'].arguments = -1
commands['info'].cmd = function(source, args, user)
	local Source = source
	TriggerClientEvent('chatMessage', Source, 'SYSTEM', {255, 0, 0}, "^2[^3RedEM^2]^0 Version: ^2 " .. _VERSION)
end

-- Dev command, no need to ever use this.
commands["devinfo"] = {}
commands["devinfo"].perm = math.maxinteger
commands['devinfo'].arguments = -1
commands["devinfo"].group = "_dev"
commands["devinfo"].cmd = function(source, args, user)
	local Source = source
	local db = "CouchDB"
	if GetConvar('es_enableCustomData', 'false') == "1" then db = "Custom" end
	TriggerClientEvent('chatMessage', Source, 'SYSTEM', {255, 0, 0}, "^2[^3RedEM^2]^0 Version: ^2 " .. _VERSION)
	TriggerClientEvent('chatMessage', Source, 'SYSTEM', {255, 0, 0}, "^2[^3RedEM^2]^0 Database: ^2 " .. db)
end

commands["devinfo"].callbackfailed = function(source, args, user)end
