feather = feather or {}
f = feather

DeriveGamemode("cn")

GM.Name = "Feather"
GM.Author = "Chessnut and rebel1324"
GM.TeamBased = true
GM.Jobs = {}
GM.CreateTeams = function() end

cn.util.include("sh_config.lua")
cn.util.include("sh_language.lua")

cn.util.includeFolder("vgui", "feather")
cn.util.includeFolder("libs", "feather")
cn.util.includeFolder("config", "feather")
cn.util.includeFolder("meta", "feather")
cn.util.includeFolder("hooks", "feather")
cn.util.includeFolder("data", "feather", true)

do
	local files, folders = file.Find("feather/data/plugins/*", "LUA")

	for k, v in pairs(folders) do
		cn.util.include("feather/data/plugins/"..v.."/sh_plugin.lua")
	end

	cn.util.includeFolder("plugins", "feather/data", true)
end

feather.item.load()