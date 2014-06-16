// MAKE GET LANG DONE

GM.Languages = {}

function GetLang(name, ...)
	GAMEMODE = GAMEMODE or GM -- get error and shit.

	local index = feather.config.get("language")
	
	if GAMEMODE.Languages[index] then
		if GAMEMODE.Languages[index][name] then
			return string.format( GAMEMODE.Languages[index][name], ... )
		end

		if GAMEMODE.Languages["english"][name] then
			return string.format( GAMEMODE.Languages["english"][name], ... )
		end
	end

	return "Failed to get language ".. name	or "<NO LANG!>"
end

cn.util.includeFolder("languages", "feather/data", true)