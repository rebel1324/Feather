// GET SHIPMENT SPAWN DONE
// MORE MARKET THINGS SHOULD BE ADDED.

GM.EntityList = {}
GM.WeaponList = {}

function GM:AddEntity(uniqueid, classname, name, category, desc, model, price, job)
	self.EntityList[uniqueid] = {
		classname = classname,
		name = name,
		category = category,
		desc = desc,
		model = model,
		job = job,
		price = price
	}

	return self.EntityList[classname]
end

function GM:AddWeapon(uniqueid, classname, amount, name, category, desc, model, price, job, allowsingle)
	self.WeaponList[uniqueid] = {
		classname = classname,
		name = name,
		category = category,
		desc = desc,
		model = model,
		amount = amount,
		single = allowsingle,
		job = job,
		price = price
	}

	return self.WeaponList[classname]
end

function GM:BuyWeapon(client, uniqueid, data, single)
	local td = {}
		td.start = client:GetShootPos()
		td.endpos = td.start + client:GetAimVector()*64
		td.filter = client
	local trace = util.TraceLine(td)

	if !single then
		local ent = ents.Create("feather_shipment")
		ent:SetPos(trace.HitPos)
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()

		ent:SetContent(uniqueid)
		ent:SetAmount(data.amount)
	else
		// spawn single weapon
	end
end

function GM:BuyEntity(client, uniqueid, data)
	local td = {}
		td.start = client:GetShootPos()
		td.endpos = td.start + client:GetAimVector()*64
		td.filter = client
	local trace = util.TraceLine(td)

	local sent = scripted_ents.GetStored( data.classname )
	local SpawnFunction = scripted_ents.GetMember( data.classname, "SpawnFunction" )
	
	if ( !isfunction( SpawnFunction ) ) then 
		ent = SpawnFunction( sent, client, trace, data.classname )
	else
		local ent = ents.Create(data.classname)
		ent:SetPos(trace.HitPos)
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()
	end

	if ent and ent:IsValid() then
		client:addMoney(-data.price)
		hook.Run("OnPurchasedEntity", client, uniqueid, data, ent)
	end
	
	return ent
end

function GM:BuyFood(client, uniqueid, data)
	local td = {}
		td.start = client:GetShootPos()
		td.endpos = td.start + client:GetAimVector()*64
		td.filter = client
	local trace = util.TraceLine(td)
	
	local ent = ents.Create("feather_food")
	ent:SetPos(trace.HitPos)
	ent:SetAngles(Angle(0, 0, 0))
	ent:Spawn()
	ent:Activate()

	ent:SetFood(uniqueid)

	if ent and ent:IsValid() then
		client:addMoney(-data.price)
		hook.Run("OnPurchasedEntity", client, uniqueid, data, ent)
	end
	
	return ent
end

if SERVER then
	function GM:OnPurchasedEntity(client, uniqueid, data, ent)
		if data.postbuy then
			data.postbuy(client, ent)
		end
	end
end

GM:RegisterCommand({
	onRun = function(client, arguments)
		local buy = table.concat(arguments, " ")

		local buycat = 0
		local data = GAMEMODE.EntityList[buy]

		if !data then
			buycat = 1
			data = GAMEMODE.WeaponList[buy]
		end

		if !data then
			buycat = 2
			data = GAMEMODE.FoodList[buy]
			if !data.buyable then
				data = nil
			end
		end

		if !buy or buy == "" then
			client:notify(GetLang("provide", "Unique ID."))
			return
		end

		if data then
			if !client:canAfford(data.price) then
				client:notify(GetLang"cantafford")
				return
			end

			client:notify(GetLang("purchase", data.name, MoneyFormat(data.price)))

			if buycat == 0 then
				GAMEMODE:BuyEntity(client, buy, data)
			elseif buycat == 1 then
				GAMEMODE:BuyWeapon(client, buy, data)
			elseif buycat == 2 then
				GAMEMODE:BuyFood(client, buy, data)
			end

			return
		end

		client:notify()
	end
}, "buy")

GM:RegisterCommand({
	desc = "This command allows you to take license to facing/specific player if you're in goverment faction.",
	syntax = "<License Name/UniqueID> [Target Player]",
	onRun = function(client, arguments)
		local price = math.Clamp(tonumber(arguments[1]) or 0, 0, math.huge)

		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"entinvalid", 4)
			return
		end

		local eprice = target:GetNetVar("price")

		if (eprice) then			
			target:SetNetVar("price", price)
		else
			client:notify(GetLang"faceadjent")
		end
	end
}, "setprice")