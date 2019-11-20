--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

function printServer(message)
    print(_serverPrefix .. message)
end

function log(msg)
    -- Later
end

function debugMsg(msg)
    -- Later
end

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end