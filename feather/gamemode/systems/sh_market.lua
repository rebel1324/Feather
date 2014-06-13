// GET SHIPMENT SPAWN DONE
// MORE MARKET THINGS SHOULD BE ADDED.

GM.EntityList = {}
GM.WeaponList = {}

function GM:AddEntity(uniqueid, classname, name, category, job, desc, model, price)
	self.EntityList[uniqueid] = {
		classname = classname,
		name = name,
		category = category,
		desc = desc,
		model = model,
		price = price,
		job = job,
	}

	return self.EntityList[uniqueid]
end

function GM:AddShipment(uniqueid, classname, amount, job, name, category, desc, model, price, allowsingle)
	self.WeaponList[uniqueid] = {
		classname = classname,
		name = name,
		category = category,
		desc = desc,
		model = model,
		amount = amount,
		single = allowsingle,
		price = price,
		job = job,
	}

	return self.WeaponList[uniqueid]
end

function GM:CanBuyWeapon(client, uniqueid, data, menu)
	if (data.job and #data.job != 0 and !table.HasValue(data.job, client:Team())) then
		if (!menu) then
			client:notify(GetLang"yourjobcantbuy")
		end
		return false
	end

	if (client:IsArrested()) then
		if (!menu) then
			client:notify(GetLang"yourearrested")
		end
		return false
	end

	if (!menu and !client:PayMoney(data.price)) then
		return false
	end
end

function GM:BuyWeapon(client, uniqueid, data, single)
	if (hook.Run("CanBuyWeapon", client, uniqueid, data, single)) == false then
		return false	
	end

	local td = {}
		td.start = client:GetShootPos()
		td.endpos = td.start + client:GetAimVector()*64
		td.filter = client
	local trace = util.TraceLine(td)

	if (!single) then
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

function GM:CanBuyEntity(client, uniqueid, data, menu)
	if (data.job and #data.job != 0 and !table.HasValue(data.job, client:Team())) then
		if (!menu) then
			client:notify(GetLang"yourjobcantbuy")
		end
		return false
	end

	if (client:IsArrested()) then
		if (!menu) then
			client:notify(GetLang"yourearrested")
		end
		return false
	end

	if (!menu and !client:PayMoney(data.price)) then
		return false
	end
end

function GM:BuyEntity(client, uniqueid, data)
	if hook.Run("CanBuyEntity", client, uniqueid, data) == false then
		return false	
	end
	
	if client.market and client.market[uniqueid] and #client.market[uniqueid] >= (data.max or 2) then
		client:notify(GetLang("entmax", data.max or 2))
		return false
	end

	local td = {}
		td.start = client:GetShootPos()
		td.endpos = td.start + client:GetAimVector()*64
		td.filter = client
	local trace = util.TraceLine(td)

	local sent = scripted_ents.GetStored( data.classname )
	local SpawnFunction = scripted_ents.GetMember( data.classname, "SpawnFunction" )
	local ent
	if ( !isfunction( SpawnFunction ) ) then 
		ent = SpawnFunction( sent, client, trace, data.classname )
	else
		ent = ents.Create(data.classname)
		ent:SetPos(trace.HitPos)
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()
	end

	if (ent and ent:IsValid()) then
		hook.Run("OnPurchasedEntity", client, uniqueid, data, ent)
	end
	
	return ent
end

function GM:CanBuyFood(client, uniqueid, data)
	if (data.job and #data.job != 0 and !table.HasValue(data.job, client:Team())) then
		if (!menu) then
			client:notify(GetLang"yourjobcantbuy")
		end
		return false
	end

	if (client:IsArrested()) then
		if (!menu) then
			client:notify(GetLang"yourearrested")
		end
		return false
	end

	if (!menu and !client:PayMoney(data.price)) then
		return false
	end

	return data.buyable
end

function GM:BuyFood(client, uniqueid, data)
	if (hook.Run("CanBuyFood", client, uniqueid, data) == false) then
		return false	
	end

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
	
	return ent
end

if SERVER then
	function GM:OnPurchasedEntity(client, uniqueid, data, entity)
		if (data.postbuy) then
			data.postbuy(client, entity)
		end

		entity.Owner = client
		entity:SetNetVar("owner", client)
		client.market = client.market or {}
		client.market[uniqueid] = client.market[uniqueid] or {}
		if (!norecord) then
			table.insert(client.market[uniqueid], entity)
		end
	end

	hook.Add("EntityRemoved", "FeatherMarketRemove", function(entity)
		local owner = entity.Owner
		if owner then
			if !owner.market then return end

			for cat, dat in pairs(owner.market) do
				for k, e in pairs(dat) do
					if !e or !e:IsValid() then
						table.remove(owner.market[cat], k)
					end
				end
			end
		end
	end)

	hook.Add("PlayerDisconnected", "FeatherMarketDestroy", function(client)
		if !client.market then return end
		
		for _, dat in pairs(client.market) do
			for _, e in ipairs(dat) do
				if e:IsValid() then
					e:Remove()
				end
			end
		end
	end)	
end

GM:RegisterCommand({
	category = "Market and Money",
	onRun = function(client, arguments)
		local buy = table.concat(arguments, " ")

		local buycat = 0
		local data = GAMEMODE.EntityList[buy]

		if (!data) then
			buycat = 1
			data = GAMEMODE.WeaponList[buy]
		end

		if (!data) then
			buycat = 2
			data = GAMEMODE.FoodList[buy]
			if !data or !data.buyable then
				data = nil
			end
		end

		if (!buy or buy == "") then
			client:notify(GetLang("provide", "Unique ID."))
			return
		end

		if (data) then
			if (buycat == 0) then
				if GAMEMODE:BuyEntity(client, buy, data) != false then
					client:notify(GetLang("purchase", data.name, MoneyFormat(data.price)))
				end
			elseif (buycat == 1) then
				if GAMEMODE:BuyWeapon(client, buy, data) != false then
					client:notify(GetLang("purchase", data.name, MoneyFormat(data.price)))
				end
			elseif (buycat == 2) then
				if GAMEMODE:BuyFood(client, buy, data) != false then
					client:notify(GetLang("purchase", data.name, MoneyFormat(data.price)))
				end
			end

			return
		end
	end
}, "buy")

GM:RegisterCommand({
	category = "Market and Money",
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