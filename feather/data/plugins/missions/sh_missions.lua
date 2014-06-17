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

-- MISSION PACKAGE
-- Bring entity A to entity B.

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

-- MISSION JUNKDESTROY
-- Destroy all junks.

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
