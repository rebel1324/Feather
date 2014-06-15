feather = feather or {}
f = feather
DeriveGamemode("cn")

GM.Name = "Feather"
GM.Author = "Chessnut and rebel1324"
GM.TeamBased = true
GM.Jobs = {}


feather.config = feather.config or {}
feather.config.vars = feather.config.vars or {}
feather.config.default = {}

function feather.config.create(key, value, desc, nonShared)
	feather.config.default[key] = {value = value, desc = desc or "No description available.", nonShared = nonShared}
end

function feather.config.set(key, value, receiver)
	feather.config.vars[key] = value

	if (SERVER and !feather.config.default[key].nonShared) then
		netstream.Start(receiver, "fr_Config", key, value)
	end
end

function feather.config.get(key, default)
	if (feather.config.vars[key] != nil) then
		return feather.config.vars[key]
	end

	if (default == nil) then
		local config = feather.config.default[key]
		default = config and config.value
	end

	return default
end

function feather.config.getType(key)
	return feather.config.default[key] and type(feather.config.default[key].value)
end

if (SERVER) then
	function feather.config.load()
		local saved = cn.data.read("config", {})
		local buffer = {}
		
		for k, v in pairs(feather.config.default) do
			buffer[k] = v.value
		end

		feather.config.vars = table.Merge(buffer, saved)
	end

	function feather.config.save()
		local buffer = {}

		for k, v in pairs(feather.config.vars) do
			local default = feather.config.default[k]

			if (v != (default and default.value)) then
				buffer[k] = v
			end
		end

		cn.data.write("config", buffer)
	end

	function feather.config.send(client)
		netstream.Start(client, "fr_ConfigInit", feather.config.vars)
	end

	hook.Add("Initialize", "fr_ConfigLoader", feather.config.load)
	hook.Add("ShutDown", "fr_ConfigSaver", feather.config.save)
	hook.Add("PlayerInitialSpawn", "fr_SendConfig", feather.config.send)
else
	netstream.Hook("fr_Config", function(key, value)
		feather.config.vars[key] = value
	end)

	netstream.Hook("fr_ConfigInit", function(data)
		feather.config.vars = data
	end)
end

function GM:CreateJob(name, color, job)
	local index = table.insert(self.Jobs, job)
		team.SetUp((#self.Jobs), name, color, false)
	return (#self.Jobs)
end

function GM:GetJobData(index)
	return self.Jobs[index] or nil
end

function GM:PlayerNoClip(client)
	return client:IsAdmin()
end

function GM:CreateTeams()
end

cn.util.includeFolder("vgui", "feather")
cn.util.includeFolder("systems", "feather")
cn.util.includeFolder("config", "feather")
cn.util.includeFolder("meta", "feather")
cn.util.includeFolder("hooks", "feather")

feather.item.load()

TEAM_CITIZEN = GM:CreateJob("Citizen", Color(46, 204, 113), {
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
	salary = feather.config.get("salary", 50),
	cmd = "citizen",
	desc = GetLang("jobcitizen"),
})

TEAM_COOK = GM:CreateJob("Cook", Color(255, 140, 250), {
	model = {
		"models/player/mossman.mdl"
	},
	salary = math.Round(feather.config.get("salary", 50) * 1.5),
	cmd = "cook",
	desc = GetLang("jobcook"),
	max = 2,
})

TEAM_GUNDEALER = GM:CreateJob("Gun Dealer", Color(255, 130, 0), {
	model = {
		"models/player/monk.mdl",
	},
	salary = math.Round(feather.config.get("salary", 50) * 1.5),
	cmd = "gundealer",
	desc = GetLang("jobgundealer"),
	max = 2,
})

TEAM_MEDIC = GM:CreateJob("Medic", Color(0, 130, 0), {
	model = {
		"models/player/kleiner.mdl",
	},
	salary = math.Round(feather.config.get("salary", 50) * 1.5),
	cmd = "medic",
	loadout = {
		"weapon_medic",
	},
	desc = GetLang("jobmedic"),
	max = 2,
})

TEAM_HITMAN = GM:CreateJob("Hitman", Color(100, 80, 255), {
	model = {
		"models/player/leet.mdl",
	},
	salary = math.Round(feather.config.get("salary", 50) * 1),
	convicts = true,
	hitman = true,
	cmd = "hitman",
	desc = GetLang("jobhitman"),
	max = 1,
})

TEAM_MAYOR = GM:CreateJob("Mayor", Color(80, 0, 0), {
	model = {
		"models/player/breen.mdl",
	},
	salary = math.Round(feather.config.get("salary", 50) * 4),
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

TEAM_POLICECHIEF = GM:CreateJob("Police Chief", Color(0, 50, 200), {
	model = {
		"models/player/combine_soldier.mdl",
	},
	salary = math.Round(feather.config.get("salary", 50) * 3),
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

TEAM_POLICE = GM:CreateJob("Police", Color(0, 100, 200), {
	model = {
		"models/player/police.mdl",
		"models/player/police_fem.mdl",
	},
	salary = math.Round(feather.config.get("salary", 50) * 2),
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

TEAM_MOBBOSS = GM:CreateJob("Mob Boss", Color(50, 50, 50), {
	model = {
		"models/player/GMan_high.mdl",
	},
	salary = math.Round(feather.config.get("salary", 50) * 2),
	convicts = true,
	childjob = TEAM_MOBSTER,
	cmd = "mobboss",
	loadout = {
		"weapon_lockpick",
	},
	desc = GetLang("jobmobsterboss"),
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
	salary = math.Round(feather.config.get("salary", 50) * 1),
	convicts = true,
	cmd = "mob",
	desc = GetLang("jobmobster"),
})

GM:AddEntity("moneyprinter", "feather_moneyprinter", "Money Printer", "General", {}, "This machine prints money and gives you constant profit.", "models/props_c17/consolebox01a.mdl", 1000)
GM:AddEntity("microwave", "feather_microwave", "Microwave", "General", {TEAM_COOK}, "This machine cooks foods to sell.", "models/props_c17/tv_monitor01.mdl", 500)

GM:AddShipment("pistol", "weapon_pistol", 10, {TEAM_GUNDEALER}, "9mm Pistol", "Firearms", "A Pistol that fires shits", "models/weapons/w_pistol.mdl", 1500)
GM:AddShipment("smg", "weapon_smg1", 10, {TEAM_GUNDEALER}, "Sub Machinegun", "Firearms", "A Sub Machine Gun that fires bullets", "models/weapons/w_smg1.mdl", 3000)
local data = GM:AddShipment("medickit", "feather_medickit", 10, {TEAM_MEDIC}, "Medic Kit", "Utility", "A Medic kit that heals the user", "models/Items/HealthKit.mdl", 800)
data.entity = true

GM:AddDefaultLicense("gun", "Gun License", "The license that allows you to carry firearms.", 500)
GM:AddDefaultLicense("drive", "Drive License", "The license that allows you to drive vehicles.", 300)

GM:AddFood("chinese", "Chinese Takeout", "models/props_junk/garbage_takeoutcarton001a.mdl", {TEAM_COOK}, feather.config.get("hungerTime", 200), 10)
GM:AddFood("watermelon", "Watermelon", "models/props_junk/watermelon01.mdl", {TEAM_COOK}, feather.config.get("hungerTime", 200) * .1, 20, true)
GM:AddFood("fastfood", "Fast Food", "models/props_junk/garbage_bag001a.mdl", {TEAM_COOK}, feather.config.get("hungerTime", 200) * .3, 50, true)
GM:AddFood("soda", "Soda", "models/props_junk/PopCan01a.mdl", {TEAM_COOK}, feather.config.get("hungerTime", 200) * .05, 10, true)


local map = "rp_locality"
GM:AddMapPos(map, "package", Vector(-2800.5080566406, -110.48152923584, -383.96875))
GM:AddMapPos(map, "package", Vector(-3128.8796386719, -104.14462280273, -383.96875))
GM:AddMapPos(map, "package", Vector(610.07916259766, -1274.1938476563, -271.96875))
GM:AddMapPos(map, "package", Vector(-955.61157226563, 1258.4536132813, -215.96875))
GM:AddMapPos(map, "package", Vector(-954.94006347656, 1109.4389648438, -215.96875))
GM:AddMapPos(map, "package", Vector(-2375.1765136719, 1100.1162109375, -383.96875))
GM:AddMapPos(map, "package", Vector(-2751.6884765625, -1393.1632080078, -315.96875))
GM:AddMapPos(map, "garbage", Vector(675.68273925781, 1312.0180664063, -7.9687576293945))
GM:AddMapPos(map, "garbage", Vector(568.93365478516, -1631.2705078125, -6.96875))
GM:AddMapPos(map, "garbage", Vector(582.03704833984, -1527.4556884766, -6.96875))
GM:AddMapPos(map, "garbage", Vector(-2621.1901855469, -1777.9755859375, -6.96875))
GM:AddMapPos(map, "garbage", Vector(-2503.9892578125, -1800.4158935547, -6.96875))
GM:AddMapPos(map, "garbage", Vector(-2074.5385742188, 1518.0069580078, -7.96875))
GM:AddMapPos(map, "garbage", Vector(-2182.4033203125, 1529.2066650391, -7.96875))
GM:AddMapPos(map, "garbage", Vector(-616.55511474609, -1768.4284667969, -15.968753814697))
GM:AddMapPos(map, "garbage", Vector(-2658.1638183594, -1025.3074951172, -315.96875))
GM:AddMapPos(map, "garbage", Vector(-2867.2309570313, -1297.3129882813, -315.96875))
GM:AddMapPos(map, "garbage", Vector(-1356.9670410156, -1922.2923583984, -15.96875))
GM:AddMapPos(map, "garbage", Vector(-2293.4653320313, 1329.8887939453, -383.96875))
GM:AddMapPos(map, "garbage", Vector(-2451.3549804688, 1350.2510986328, -383.96875))
GM:AddMapPos(map, "garbage", Vector(-1469.0399169922, -1081.1253662109, -9.4270668029785))
GM:AddMapPos(map, "garbage", Vector(-1983.6811523438, -989.18499755859, -20.190910339355))

local JOB = {}
JOB.uid = "package"
JOB.names = {
	"Package Delivery",
	"Secret Delivery",
	"Recycle Stuffs",
	"Discard Evidance",
	"No More Proofs",
	"Delicate Stuffs",
	"My Porn Magazines",
	"Too lazy to dump",
	"My son's XBox Games",
}
JOB.moneymin = 200
JOB.moneymax = 400
JOB.desc = "Deliver Package to the dumpster."
JOB.canAccept = function(client)
	return true
end
local seconds = 100
JOB.onAccept = function(client)
	local dest = GetRandomEntity("feather_job_pckdest")
	if !dest or !dest:IsValid() then
		client:notify("Please place more than 1 package destination.")
		client:ClearMission()
	end

	local pck = ents.Create("feather_job_pckobj")
	pck:SetPos(GAMEMODE:GetMapPos("package") + Vector(0, 0, 40))
	pck:Spawn()
	pck.dest = dest
	pck.owner = client
	client:SetLocalVar("package", pck:EntIndex())
	client:SetLocalVar("dest", dest:EntIndex())
	client:notify(GetLang("deliverybreifing", seconds))

	timer.Create(client:SteamID64() .. "_DELIVERY", seconds, 1, function()
		if client:IsValid() then
			client:ClearMission(true) -- failed.
		end
	end)
end
JOB.onEnded = function(client)
	client:SetLocalVar("package", nil)
	client:SetLocalVar("dest", nil)

	for k, v in ipairs(ents.FindByClass("feather_job_pckobj")) do
		if v.owner then 
			if v.owner == client then
				v:Remove()
			elseif !v.owner:IsValid() then
				v:Remove()
			end
		end
	end
	timer.Destroy(client:SteamID64() .. "_DELIVERY")
end
JOB.onFailed = function(client)
	if !client:IsValid() then return false end

	client:notify(GetLang"deliveryfailed")
end
JOB.onSuccess = function(client, info)
	client:GiveMoney(info.price)
	client:notify(GetLang("moneyearn", MoneyFormat(info.price)))
end
GM:AddMission(JOB)


local JOB = {}
JOB.uid = "junkdestroy"
JOB.names = {
	"Big Garbage",
	"Part-time Destroyer",
	"Cleaning City",
}
JOB.moneymin = 150
JOB.moneymax = 200
JOB.desc = "Destory other shits."
JOB.canAccept = function(client)
	return true
end
local seconds = 80
local amount = 3
JOB.onAccept = function(client)
	local garbages = {}

	for i = 1, amount do
		local pos = GAMEMODE:GetMapPos("garbage")
		while (true) do
			local blocked = false
			for k, v in ipairs(ents.FindInSphere(pos, 64)) do
				if (v:GetClass() == "feather_job_garbage") then
					pos = GAMEMODE:GetMapPos("garbage")
					break
				end
			end

			if (blocked) then
				continue
			end

			break
		end

		local grb = ents.Create("feather_job_garbage")
		grb:SetPos(GAMEMODE:GetMapPos("garbage") + Vector(0, 0, 40))
		grb:Spawn()
		grb.owner = client
		table.insert(garbages, grb)
	end

	timer.Simple(.5, function()
		client:SetLocalVar("garbages", garbages)
	end)
	client:notify(GetLang("garbagebriefing", amount, seconds))

	timer.Create(client:SteamID64() .. "_GARBAGE", seconds, 1, function()
		if client:IsValid() then
			client:ClearMission(true) -- failed.
		end
	end)
end
JOB.onEnded = function(client)
	client:SetLocalVar("garbages", nil)

	for k, v in ipairs(ents.FindByClass("feather_job_garbage")) do
		if v.owner then 
			if v.owner == client then
				v:Remove()
			elseif !v.owner:IsValid() then
				v:Remove()
			end
		end
	end
	timer.Destroy(client:SteamID64() .. "_GARBAGE")
end
JOB.onFailed = function(client)
	if !client:IsValid() then return false end

	client:notify(GetLang"deliveryfailed")
end
JOB.onSuccess = function(client, info)
	client:GiveMoney(info.price)
	client:notify(GetLang("moneyearn", MoneyFormat(info.price)))
end
GM:AddMission(JOB)
