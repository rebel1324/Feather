local ammo = {
	{ammoname = "pistol", name = "Pistol Ammo", model = "models/Items/BoxSRounds.mdl", amount = 20, price = 50},
	{ammoname = "smg1", name = "SMG Ammo", model = "models/Items/BoxMRounds.mdl", amount = 45, price = 100},
	{ammoname = "ar2", name = "AR2 Ammo", model = "models/Items/BoxMRounds.mdl", amount = 30, price = 100},
	{ammoname = "357", name = ".357 Ammo", model = "models/Items/357ammo.mdl", amount = 6, price = 100},
}
for k, v in ipairs(ammo) do
	local data = GM:AddEntity(v.ammoname .. "ammo", "feather_ammo", v.name, "Ammunition", {}, v.name, v.model, v.price)
	data.postPurchase = function(entity, client)
		entity.Owner = client
		entity:SetAmmo(v.ammoname, v.amount)
		entity:SetModel(v.model)
	end
end

GM:AddEntity("moneyprinter", "feather_moneyprinter", "Money Printer", "General", {}, "This machine prints money and gives you constant profit.", "models/props_c17/consolebox01a.mdl", 1000)
GM:AddEntity("microwave", "feather_microwave", "Microwave", "General", {TEAM_COOK}, "This machine cooks foods to sell.", "models/props_c17/tv_monitor01.mdl", 500)

GM:AddShipment("pistol", "weapon_pistol", 10, {TEAM_GUNDEALER}, "9mm Pistol", "Firearms", "A Pistol that fires shits", "models/weapons/w_pistol.mdl", 1500)
GM:AddShipment("smg", "weapon_smg1", 10, {TEAM_GUNDEALER}, "Sub Machinegun", "Firearms", "A Sub Machine Gun that fires bullets", "models/weapons/w_smg1.mdl", 3000)
GM:AddShipment("shotgun", "weapon_shotgun", 10, {TEAM_GUNDEALER}, "Shotgun", "Firearms", "A Shotgun that fires bullets", "models/weapons/w_shotgun.mdl", 3000)
GM:AddShipment("crowbar", "weapon_crowbar", 10, {TEAM_GUNDEALER, TEAM_MOBBOSS}, "Crowbar", "Melee", "A Metal Bar that really useful to break something.", "models/weapons/w_crowbar.mdl", 3000)
GM:AddShipment("stunstick", "weapon_stunstick", 10, {TEAM_GUNDEALER, TEAM_MAYOR, TEAM_POLICECHIEF}, "Stunstick", "Melee", "A Metal Bar that really useful to beat someone.", "models/weapons/w_stunbaton.mdl", 3000)
local data = GM:AddShipment("medickit", "feather_medickit", 10, {TEAM_MEDIC}, "Medic Kit", "Utility", "A Medic kit that heals the user", "models/Items/HealthKit.mdl", 800)
data.entity = true

GM:AddDefaultLicense("gun", "Gun License", "The license that allows you to carry firearms.", 500)
GM:AddDefaultLicense("drive", "Drive License", "The license that allows you to drive vehicles.", 300)