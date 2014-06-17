
GM:RegisterChat("broadcast", {
	canSay = function(speaker)
		if speaker:Team() != TEAM_MAYOR then
			return false
		end

		return true
	end,
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"broadcast" , Color(255, 0, 0), speaker:Name(), ": " .. text)
	end,
	prefix = {"/broadcast", "/b"},
})

GM:RegisterChat("ooc", {
	deadCanTalk = true,
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"ooc", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end,
	prefix = {"/ooc", "//"},
})

GM:RegisterChat("advert", {
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"advert", team.GetColor(speaker:Team()), speaker:Name(), Color(200, 230, 0), ": " .. text)
	end,
	prefix = {"/advert", "/ad"},
})

GM:RegisterChat("yell", {
	canHear = feather.config.get("chatRange", 512) * 2,
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"yell", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end,
	prefix = {"/y", "/yell"},
})

GM:RegisterChat("it", {
	canHear = feather.config.get("chatRange", 512),
	onChat = function(speaker, text)
		chat.AddText(color_white, "** "..text)
	end,
	prefix = {"/it"},
})

GM:RegisterChat("me", {
	canHear = feather.config.get("chatRange", 512),
	onChat = function(speaker, text)
		chat.AddText(color_white, "**"..speaker:Name().." "..text)
	end,
	prefix = {"/me", "/action"},
})

GM:RegisterChat("looc", {
	deadCanTalk = true,
	canHear = feather.config.get("chatRange", 512),
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"looc", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end,
	prefix = {"[[", "]]", "/looc", "/l", ".//"},
})

GM:RegisterChat("ic", {
	canHear = feather.config.get("chatRange", 512),
	onChat = function(speaker, text)
		chat.AddText(team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end
})