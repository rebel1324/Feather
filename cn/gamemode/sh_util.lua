function cn.util.include(name)
	if (name:find("sv_") and SERVER) then
		include(name)
	elseif (name:find("sh_")) then
		if (SERVER) then
			AddCSLuaFile(name)
		end

		include(name)
	elseif (name:find("cl_")) then
		if (CLIENT) then
			include(name)
		else
			AddCSLuaFile(name)
		end
	end
end

function cn.util.includeFolder(folder, baseFolder, noGamemode)
	baseFolder = baseFolder or "cn"

	for k, v in pairs(file.Find(baseFolder..(noGamemode and "/" or "/gamemode/")..folder.."/*.lua", "LUA")) do
		cn.util.include((noGamemode and baseFolder.."/" or "")..folder.."/"..v)
	end
end

cn.util.includeFolder("libs/external", "cn")
cn.util.includeFolder("libs", "cn")