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

function Vector2SQL(v)
	return v[1] .. "," .. v[2] .. "," .. v[3]
end

function SQL2Vector(v)
	local tbl = string.Explode(",", v)
	return Vector(tbl[1], tbl[2], tbl[3])
end

function Angle2SQL(a)
	return a.p .. "," .. a.y .. "," .. a.r
end

function SQL2Angle(v)
	local tbl = string.Explode(",", v)
	return Angle(tonumber(tbl[1]), tonumber(tbl[2]),tonumber(tbl[3]))
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
	return feather.config.get("currency") .. string.Comma(num)
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
	["weapon_stunstick"] = "models/weapons/w_stunbaton.mdl",
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

function GM:SpawnWeapon(position, angles, class)
	if (!class or (!wepdat and !hl2conv[class])) then
		return
	end

	local weapon = ents.Create("feather_weapon")
	weapon:SetWeapon(class)
	weapon:SetPos(position or Vector(0, 0, 0))
	weapon:SetAngles(angles or Angle(0, 0, 0))
	if hl2conv[class] then
		weapon:SetModel(hl2conv[class])
	else
		weapon:SetModel(wepdat.WorldModel)
	end
	weapon:Spawn()

	return weapon
end

local hl2conv = {
	["weapon_pistol"] = "9MM PISTOL",
	["weapon_crowbar"] = "CROWBAR",
	["weapon_stunstick"] = "STUNSTICK",
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
		return (wepdat.PrintName)
	else
		return "A Weapon"
	end
end

function GetRandomEntity(class)
	return table.Random(ents.FindByClass(class))
end

local strNum = "1234567890.-"
function IsNumberString(str)
	if (string.find( strNum, str )) then
		return true
	end

	return false
end

-- For overriding.
-- Actually... For koreans.... 
local function pluralizeString(str, quantity)
	return str .. ((quantity ~= 1) and "s" or "")
end

function string.NiceTime( seconds )
	if ( seconds == nil ) then return "a few seconds" end

	if ( seconds < 60 ) then
		local t = math.floor( seconds )
		return t .. pluralizeString(" second", t);
	end

	if ( seconds < 60 * 60 ) then
		local t = math.floor( seconds / 60 )
		return t .. pluralizeString(" minute", t);
	end

	if ( seconds < 60 * 60 * 24 ) then
		local t = math.floor( seconds / (60 * 60) )
		return t .. pluralizeString(" hour", t);
	end

	if ( seconds < 60 * 60 * 24 * 7 ) then
		local t = math.floor( seconds / (60 * 60 * 24) )
		return t .. pluralizeString(" day", t);
	end
	
	if ( seconds < 60 * 60 * 24 * 7 * 52 ) then
		local t = math.floor( seconds / (60 * 60 * 24 * 7) )
		return t .. pluralizeString(" week", t);
	end

	local t = math.floor( seconds / (60 * 60 * 24 * 7 * 52) )
	return t .. pluralizeString(" year", t);
end

function FeatherError(str, nohalt)
	if !str then
		return
	end

	str = "Feather Internal Error: " .. str
	if nohalt then
		ErrorNoHalt(str)
	else
		Error(str)
	end
end