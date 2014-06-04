function cn.util.include(name)
	if (name:find("sv_") and SERVER) then
		include(name)
	elseif (name:find("sh_")) then
		if (SERVER) then
			AddCSLuaFile(name)
		end

		include(name)
	elseif (name:find("cl_")) then
		if (SERVER) then
			AddCSLuaFile(name)
		else
			include(name)
		end
	end
end

function cn.util.includeFolder(folder, baseFolder)
	for k, v in pairs(file.Find((baseFolder or engine.ActiveGamemode()).."/gamemode/"..folder.."/*.lua", "LUA")) do
		cn.util.include(folder.."/"..v)
	end
end

cn.util.includeFolder("libs/external", "cn")
cn.util.includeFolder("libs", "cn")