GM.EntityList = {}

function GM:AddEntity(uniqueid, classname, name, desc, model, price)
	self.EntityList[uniqueid] = {
		classname = classname,
		name = name,
		desc = desc,
		model = model,
		price = price
	}

	return self.EntityList[classname]
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

	hook.Run("OnPurchasedEntity", client, uniqueid, data, ent)
	return ent
end

GM:RegisterCommand({
	onRun = function(client, arguments)
		local buy = table.concat(arguments, " ")

		local data = GAMEMODE.EntityList[buy]

		if !buy or buy == "" then
			client:notify("You must provide the uniqueid")
			return
		end

		if data then
			if !client:canAfford(data.price) then
				client:notify(GetLang"cantafford")
				return
			end

			client:notify("You purchased ".. data.name .. ".")
			GAMEMODE:BuyEntity(client, buy, data)
		end
	end
}, "buy")

GM:AddEntity("moneyprinter", "feather_moneyprinter", "Money Printer", "This machine prints money and gives you constant profit.", "models/props_c17/consolebox01a.mdl", 250)