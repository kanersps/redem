--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'


client_scripts {
    'client/cl_main.lua'
}

server_scripts {
    'server/sv_util.lua',
    'server/sv_main.lua',
    'server/sqlite/SQLite.net.dll',
	--'config.lua',
	--'server/util.lua',
	--'server/main.lua',
	'server/sv_db.lua',
	'server/classes/player.lua',
	'server/classes/groups.lua',
	'server/sv_player.lua',
	--'server/player/login.lua',
	--'server/metrics.lua'
}

server_exports {
	'getPlayerFromId',
	'addAdminCommand',
	'addCommand',
	'addGroupCommand',
	'addACECommand',
	'canGroupTarget'
}