// GOTTA ADDED MORE
function StringMatches(a, b)
	if (a == b) then
		return true
	end

	if (string.lower(a) == string.lower(b)) then
		return true
	end

	if (string.find(a, b) or string.find(b, a)) then
		return true
	end

	a = string.lower(a)
	b = string.lower(b)

	if (string.find(a, b) or string.find(b, a)) then
		return true
	end

	return false
end

function GetMap()
	return string.lower(game.GetMap())
end

function IsEntityClose(pos, range, class)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		if v:GetClass() == class then
			return true
		end
	end

	return false
end

function MoneyFormat(num)
	return GAMEMODE.Currency .. string.Comma(num)
end

function NameToJobIndex(name)
	for k, v in pairs(team.GetAllTeams()) do
		if (StringMatches(team.GetName(k), name)) then
			return k
		end
	end
end

local hl2conv = {
	["weapon_pistol"] = "models/weapons/w_pistol.mdl",
	["weapon_crowbar"] = "models/weapons/w_crowbar.mdl",
	["weapon_smg1"] = "models/weapons/w_smg1.mdl",
	["weapon_ar2"] = "models/weapons/w_irifle.mdl",
	["weapon_crossbow"] = "models/weapons/w_crossbow.mdl",
	["weapon_shotgun"] = "models/weapons/w_shotgun.mdl",
	["weapon_357"] = "models/weapons/w_357.mdl",
	["weapon_rpg"] = "models/weapons/w_rocket_launcher.mdl",
	["weapon_grenade"] = "models/weapons/w_grenade.mdl",
	["weapon_physgun"] = "models/weapons/w_physics.mdl",
	["weapon_physcannon"] = "models/weapons/w_physics.mdl",
}

function SpawnWeapon(position, angles, class)
	if (!class or (!wepdat and !hl2conv[class])) then
		return
	end

	local weapon = ents.Create("feather_weapon")
	weapon:SetWeapon(class)
	weapon:SetPos(position or Vector(0, 0, 0))
	weapon:SetAngles(angles or Angle(0, 0, 0))
	weapon:Spawn()
	if hl2conv[class] then
		weapon:SetModel(hl2conv[class])
	else
		weapon:SetModel(wepdat.WorldModel)
	end

	return weapon
end

local hl2conv = {
	["weapon_pistol"] = "9MM PISTOL",
	["weapon_crowbar"] = "CROWBAR",
	["weapon_smg1"] = "SMG",
	["weapon_ar2"] = "PULSE-RIFLE",
	["weapon_crossbow"] = "CROSSBOW",
	["weapon_shotgun"] = "SHOTGUN",
	["weapon_357"] = ".357 MAGNUM",
	["weapon_rpg"] = "RPG",
	["weapon_grenade"] = "GRENADE",
	["weapon_physgun"] = "PHYSICS GUN",
	["weapon_physcannon"] = "GRAVITY GUN",
}

function GetWeaponName(class)
	local wepdat = weapons.Get(class)
	if hl2conv[class] then
		return hl2conv[class]
	elseif wepdat then
		weapon:SetModel(wepdat.PrintName)
	end
end