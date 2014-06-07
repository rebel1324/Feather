DeriveGamemode("cn")

GM.Name = "Feather"
GM.Author = "Chessnut and rebel1324"
GM.TeamBased = true

GM.Language = "english"
GM.ChatPrefix = "[!|/|%.]"
GM.ChatRange = 512
GM.DefaultChatColor = Color(62, 142, 200)

GM.Jobs = {}

function GM:CreateJob(name, color, job)
	local index = table.insert(self.Jobs, job)
		team.SetUp(index, name, color, false)
	return index
end

function GM:GetJobData(index)
	return self.Jobs[index] or nil
end

function GM:CreateTeams()
	TEAM_CITIZEN = self:CreateJob("Citizen", Color(0, 230, 0), {
		salary = 25,
		cmd = "citizen",
	})

	TEAM_COOK = self:CreateJob("Cook", Color(240, 100, 250), {
		salary = 25,
		cmd = "cook",
	})

	TEAM_GUNDEALER = self:CreateJob("Gun Dealer", Color(200, 0, 0), {
		salary = 25,
		cmd = "gundealer",
	})

	TEAM_MEDIC = self:CreateJob("Medic", Color(0, 180, 0), {
		salary = 25,
		cmd = "medic",
	})

	// GOVERMENTS 

	TEAM_MAYOR = self:CreateJob("Mayor", Color(0, 255, 0), {
		salary = 25,
		mayor = true,
		goverment = true,
		cmd = "mayor",
		vote = true,
	})

	TEAM_POLICE = self:CreateJob("Police", Color(0, 100, 200), {
		salary = 25,
		goverment = true,
		cmd = "police",
		vote = true,
	})

	TEAM_POLICECHIEF = self:CreateJob("Police Chief", Color(0, 50, 200), {
		salary = 25,
		goverment = true,
		childjob = TEAM_POLICE,
		cmd = "citizen",
	})

	// CRIMES 

	TEAM_MOBSTER = self:CreateJob("Mobster", Color(100, 100, 100), {
		salary = 25,
		convicts = true,
		cmd = "mob",
	})

	TEAM_HITMAN = self:CreateJob("Hitman", Color(0, 230, 0), {
		salary = 25,
		convicts = true,
		hitman = true,
		cmd = "hitman",
	})

	TEAM_MOBBOSS = self:CreateJob("Mob Boss", Color(50, 50, 50), {
		salary = 25,
		convicts = true,
		childjob = TEAM_MOBSTER,
		cmd = "mobboss",
	})
end

cn.util.includeFolder("systems", "feather")
cn.util.includeFolder("meta", "feather")
cn.util.includeFolder("hooks", "feather")