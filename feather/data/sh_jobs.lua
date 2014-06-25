function GM:InitializeJobs()
	if #self.Jobs > 0 then
		self.Jobs = {}
	end

	TEAM_CITIZEN = self:CreateJob("Citizen", Color(46, 204, 113), {
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
		salary = feather.config.get("salary"),
		cmd = "citizen",
		desc = GetLang("jobcitizen"),
	})

	TEAM_COOK = self:CreateJob("Cook", Color(255, 140, 250), {
		model = {
			"models/player/mossman.mdl"
		},
		salary = math.Round(feather.config.get("salary") * 1.5),
		cmd = "cook",
		desc = GetLang("jobcook"),
		max = 2,
	})

	TEAM_GUNDEALER = self:CreateJob("Gun Dealer", Color(255, 130, 0), {
		model = {
			"models/player/monk.mdl",
		},
		salary = math.Round(feather.config.get("salary") * 1.5),
		cmd = "gundealer",
		desc = GetLang("jobgundealer"),
		max = 2,
	})

	TEAM_MEDIC = self:CreateJob("Medic", Color(0, 130, 0), {
		model = {
			"models/player/kleiner.mdl",
		},
		salary = math.Round(feather.config.get("salary") * 1.5),
		cmd = "medic",
		loadout = {
			"weapon_medic",
		},
		desc = GetLang("jobmedic"),
		max = 2,
	})

	TEAM_HITMAN = self:CreateJob("Hitman", Color(100, 80, 255), {
		model = {
			"models/player/leet.mdl",
		},
		salary = math.Round(feather.config.get("salary") * 1),
		convicts = true,
		hitman = true,
		cmd = "hitman",
		desc = GetLang("jobhitman"),
		max = 1,
	})

	TEAM_MAYOR = self:CreateJob("Mayor", Color(80, 0, 0), {
		model = {
			"models/player/breen.mdl",
		},
		salary = math.Round(feather.config.get("salary") * 4),
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

	TEAM_POLICE = self:CreateJob("Police", Color(0, 100, 200), {
		model = {
			"models/player/police.mdl",
			"models/player/police_fem.mdl",
		},
		salary = math.Round(feather.config.get("salary") * 2),
		goverment = true,
		cmd = {"cop", "cp", "police"},
		vote = true,
		loadout = {
			"weapon_pistol",
			"weapon_arrest",
			"weapon_unarrest",
			"weapon_search",
		},
		gang = true,
		desc = GetLang("jobpolice"),
		max = 4,
	})

	TEAM_POLICECHIEF = self:CreateJob("Police Chief", Color(0, 50, 200), {
		model = {
			"models/player/combine_soldier.mdl",
		},
		salary = math.Round(feather.config.get("salary") * 3),
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

	TEAM_MOBSTER = self:CreateJob("Mobster", Color(100, 100, 100), {
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
		salary = math.Round(feather.config.get("salary") * 1),
		convicts = true,
		cmd = "mob",
		desc = GetLang("jobmobster"),
	})

	TEAM_MOBBOSS = self:CreateJob("Mob Boss", Color(50, 50, 50), {
		model = {
			"models/player/gman_high.mdl",
		},
		salary = math.Round(feather.config.get("salary") * 2),
		convicts = true,
		childjob = TEAM_MOBSTER,
		cmd = "mobboss",
		loadout = {
			"weapon_lockpick",
		},
		gang = true,
		desc = GetLang("jobmobsterboss"),
		max = 1,
	})
end
GM:InitializeJobs()