DeriveGamemode("cn")

GM.Name = "Feather"
GM.Author = "Chessnut and rebel1324"
GM.TeamBased = true

GM.Language = "english"

-- In-Character(Normal) Chat Range.
GM.ChatRange = 512

-- Gamemode's default color.
GM.DefaultChatColor = Color(62, 142, 200)

-- The delay between changing the job.
GM.JobChangeDelay = 5

-- The arrest time when player get arrested by goverment.
GM.DefaultArrestTime = 300

-- The default wanted time that used when no item was provided.
GM.DefaultWantedTime = 300

-- The time to print money with Money Printer. Default: 160 secs to 300 secs.
GM.MoneyPrinterTime = {1.60, 3.00}

-- The Gamemode's money model.
GM.MoneyModel = "models/props/cs_assault/Money.mdl"

-- 
GM.DefaultLaws = {
	"You must obey server's rule",
	"You must not kill people",
}

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
		cmd = {"cop", "cp", "police"},
		vote = true,
		loadout = {
			"weapon_pistol",
			"weapon_arrest",
			"weapon_unarrest",
		},
	})

	TEAM_POLICECHIEF = self:CreateJob("Police Chief", Color(0, 50, 200), {
		salary = 25,
		goverment = true,
		childjob = TEAM_POLICE,
		cmd = "chief",
		loadout = {
			"weapon_pistol",
			"weapon_arrest",
			"weapon_unarrest",
		},
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