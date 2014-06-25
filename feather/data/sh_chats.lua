function GM:InitializeChats()
	self:RegisterChat("broadcast", {
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

	self:RegisterChat("ooc", {
		deadCanTalk = true,
		onChat = function(speaker, text)
			chat.AddText(color_white, GetLang"ooc", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
		end,
		prefix = {"/ooc", "//"},
	})

	self:RegisterChat("advert", {
		onChat = function(speaker, text)
			chat.AddText(color_white, GetLang"advert", team.GetColor(speaker:Team()), speaker:Name(), Color(200, 230, 0), ": " .. text)
		end,
		prefix = {"/advert", "/ad"},
	})

	self:RegisterChat("yell", {
		canHear = feather.config.get("chatRange", 512) * 2,
		onChat = function(speaker, text)
			chat.AddText(color_white, GetLang"yell", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
		end,
		prefix = {"/y", "/yell"},
	})

	self:RegisterChat("it", {
		canHear = feather.config.get("chatRange", 512),
		onChat = function(speaker, text)
			chat.AddText(color_white, "** "..text)
		end,
		prefix = {"/it"},
	})

	self:RegisterChat("me", {
		canHear = feather.config.get("chatRange", 512),
		onChat = function(speaker, text)
			chat.AddText(color_white, "**"..speaker:Name().." "..text)
		end,
		prefix = {"/me", "/action"},
	})

	self:RegisterChat("looc", {
		deadCanTalk = true,
		canHear = feather.config.get("chatRange", 512),
		onChat = function(speaker, text)
			chat.AddText(color_white, GetLang"looc", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
		end,
		prefix = {"[[", "]]", "/looc", "/l", ".//"},
	})

	self:RegisterChat("ic", {
		canHear = feather.config.get("chatRange", 512),
		onChat = function(speaker, text)
			chat.AddText(team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
		end
	})
end
GM:InitializeChats()