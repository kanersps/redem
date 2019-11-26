--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

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

games { 'rdr3'}

fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
