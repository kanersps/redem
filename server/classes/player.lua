--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

-- OOP hack
function CreatePlayer(source, permission_level, money, bank, identifier, license, group, roles)
	local self = {}

	-- Initialize all initial variables for a user
	self.source = source
	self.permission_level = permission_level
	self.money = money
	self.bank = bank
	self.identifier = identifier
	self.license = license
	self.group = group
	self.session = {}
	self.roles = stringsplit(roles, "|")

	-- FXServer <3
	ExecuteCommand('add_principal identifier.' .. self.identifier .. " group." .. self.group)

	local rTable = {}

	-- Sets money for the user
	rTable.setMoney = function(m)
		if type(m) == "number" then
			local prevMoney = self.money
			local newMoney = m

			self.money = m

			-- Performs some math to see if money was added or removed, mainly for the UI component
			if((prevMoney - newMoney) < 0)then
				TriggerClientEvent("es:addedMoney", self.source, math.abs(prevMoney - newMoney), (settings.defaultSettings.nativeMoneySystem == "1"))
			else
				TriggerClientEvent("es:removedMoney", self.source, math.abs(prevMoney - newMoney), (settings.defaultSettings.nativeMoneySystem == "1"))
			end

			TriggerClientEvent('redem:addMoney', self.source, m)

			TriggerClientEvent('redem:activateMoney', self.source , self.money)
		else
			print('ES_ERROR: There seems to be an issue while setting money, something else then a number was entered.')
		end
	end
	
	-- Returns money for the player
	rTable.getMoney = function()
		return self.money
	end

	-- Sets a players bank balance
	rTable.setBankBalance = function(m)
		if type(m) == "number" then
			-- Triggers an event to save it to the database
			TriggerEvent("es:setPlayerData", self.source, "bank", m, function(response, success)
				self.bank = m
			end)

			TriggerClientEvent('redem:addBank', self.source, self.bank)
		else
			log('ES_ERROR: There seems to be an issue while setting bank, something else then a number was entered.')
			print('ES_ERROR: There seems to be an issue while setting bank, something else then a number was entered.')
		end
	end

	-- Returns the players bank
	rTable.getBank = function()
		return self.bank
	end

	-- Kicks the player with the specified reason
	rTable.kick = function(r)
		DropPlayer(self.source, r)
	end

	-- Adds money to the user
	rTable.addMoney = function(m)
		if type(m) == "number" then
			local newMoney = self.money + m

			self.money = newMoney

			-- This is used for every UI component to tell them money was just added
			TriggerClientEvent("es:addedMoney", self.source, m, (settings.defaultSettings.nativeMoneySystem == "1"), self.money)
			TriggerClientEvent('redem:addMoney', self.source, m)
			
			TriggerClientEvent('redem:activateMoney', self.source , self.money)
		else
			log('ES_ERROR: There seems to be an issue while adding money, a different type then number was trying to be added.')
			print('ES_ERROR: There seems to be an issue while adding money, a different type then number was trying to be added.')
		end
	end

	-- Removes money from the user
	rTable.removeMoney = function(m)
		if type(m) == "number" then
			local newMoney = self.money - m

			self.money = newMoney

			-- This is used for every UI component to tell them money was just removed
			TriggerClientEvent("es:removedMoney", self.source, m, (settings.defaultSettings.nativeMoneySystem == "1"), self.money)
			TriggerClientEvent('redem:addMoney', self.source, m)

			TriggerClientEvent('redem:activateMoney', self.source , self.money)
		else
			log('ES_ERROR: There seems to be an issue while removing money, a different type then number was trying to be removed.')
			print('ES_ERROR: There seems to be an issue while removing money, a different type then number was trying to be removed.')
		end
	end

	-- Adds money to a users bank
	rTable.addBank = function(m)
		if type(m) == "number" then
			local newBank = self.bank + m
			self.bank = newBank

			-- Triggers an event to tell the UI components money was just added
			TriggerClientEvent("es:addedBank", self.source, m)
			TriggerClientEvent('redem:addBank', self.source, self.bank)
		else
			log('ES_ERROR: There seems to be an issue while adding to bank, a different type then number was trying to be added.')
			print('ES_ERROR: There seems to be an issue while adding to bank, a different type then number was trying to be added.')
		end
	end

	-- Removes money from a users bank
	rTable.removeBank = function(m)
		if type(m) == "number" then
			local newBank = self.bank - m
			self.bank = newBank

			-- Triggers an event to tell the UI components money was just removed
			TriggerClientEvent("es:removedBank", self.source, m)
			TriggerClientEvent('redem:addBank', self.source, self.bank)
		else
			log('ES_ERROR: There seems to be an issue while removing from bank, a different type then number was trying to be removed.')
			print('ES_ERROR: There seems to be an issue while removing from bank, a different type then number was trying to be removed.')
		end
	end

	-- Session variables, handy for temporary variables attached to a player
	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end

	-- Session variables, handy for temporary variables attached to a player
	rTable.getSessionVar = function(k)
		return self.session[k]
	end

	-- Returns a users permission level
	rTable.getPermissions = function()
		return self.permission_level
	end

	-- Sets a users permission level
	rTable.setPermissions = function(p)
		if type(p) == "number" then
			self.permission_level = p
		else
			print('ES_ERROR: There seems to be an issue while setting permissions, a different type then number was set.')
		end
	end

	-- Returns the players identifier used in EssentialMode
	rTable.getIdentifier = function(i)
		return self.identifier
	end

	-- Returns the users current active group
	rTable.getGroup = function()
		return self.group
	end

	-- Global set
	rTable.set = function(k, v)
		self[k] = v
	end

	-- Global get
	rTable.get = function(k)
		return self[k]
	end

	-- Creates globals, pretty nifty function take a look at https://docs.essentialmode.com for more info
	rTable.setGlobal = function(g, default)
		self[g] = default or ""

		rTable["get" .. g:gsub("^%l", string.upper)] = function()
			return self[g]
		end

		rTable["set" .. g:gsub("^%l", string.upper)] = function(e)
			self[g] = e
		end

		Users[self.source] = rTable
	end

	-- Returns if the user has a specific role or not
	rTable.hasRole = function(role)
		for k,v in ipairs(self.roles)do
			if v == role then
				return true
			end
		end
		return false
	end

	-- Adds a role to a user, and if they already have it it will say they had it
	rTable.giveRole = function(role)
		for k,v in pairs(self.roles)do
			if v == role then
				print("User (" .. GetPlayerName(source) .. ") already has this role")
				return
			end
		end

		-- Updates the database with the roles aswell
		self.roles[#self.roles + 1] = role
		db.updateUser(self.identifier, {roles = table.concat(self.roles, "|")}, function()end)
	end

	-- Removes a role from a user
	rTable.removeRole = function(role)
		for k,v in pairs(self.roles)do
			if v == role then
				table.remove(self.roles, k)
			end
		end

		-- Updates the database with the roles aswell
		db.updateUser(self.identifier, {roles = table.concat(self.roles, "|")}, function()end)
	end

	return rTable
end