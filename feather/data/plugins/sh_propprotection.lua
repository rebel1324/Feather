GM.PreventDupe = {

}

function duplicator.IsAllowed(classname)
	if (string.find(classname, "feather_")) then
		local sent = scripted_ents.GetStored( classname )
		return sent.allowdupe
	end

	return !table.HasValue(GAMEMODE.PreventDupe, classname:lower())
end

function duplicator.Allow(classname)
	if (string.find(classname, "feather_")) then
		local sent = scripted_ents.GetStored( classname )
		return sent.allowdupe
	end

	return !table.HasValue(GAMEMODE.PreventDupe, classname:lower())
end

function GM:PlayerSpawnProp(client, model)
	if table.HasValue(feather.config.get("blockedModels"), model) then
		client:notify(GetLang"propbanned")
		return false
	end
	
	return true
end

function GM:PlayerSpawnedProp(client, model, entity)
	if entity:IsValid() then
		local phys = entity:GetPhysicsObject()
		if phys and phys:IsValid() then
			local min, max = phys:GetAABB( )
			local size = min:Distance(max)
			print(size)

			if (size >= feather.config.get("tooBigProp")) then
				client:notify(GetLang"toobigprop")
				entity:Remove()
				return
			end

			if (size >= feather.config.get("bigProp")) then
				if (client.nextBigProp and client.nextBigProp > CurTime()) then
					client.nextBigProp = client.nextBigProp + 1
					client:notify(GetLang("bigpropwait", math.ceil(client.nextBigProp - CurTime())))
					entity:Remove()
					return	
				end

				client.nextBigProp = CurTime() + feather.config.get("bigPropWait")
			end
		end

		entity.Owner = client
	end
end

function GM:PlayerSpawnedSENT(client, entity)
	entity.Owner = client
end

function GM:PlayerSpawnedRagdoll(client, entity)
end

function GM:PlayerSpawnedEffect(client, entity)
	entity.Owner = client
end

function GM:PlayerSpawnedSWEP(client, entity)
end

function GM:PlayerSpawnedVehicle(client, entity)
	entity.Owner = client
end

function GM:PhysgunDrop(client, entity)
	if SERVER then
		entity:SetCollisionGroup(entity.prevcol or 0)
	end
end

function GM:PhysgunPickup(client, entity)
	if SERVER then
		if !entity:IsDoor() then -- don't fuck it up.
			entity.prevcol = entity:GetCollisionGroup()
			entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		end
	end

	if (entity:IsNPC()) then
		return (client:IsAdmin())
	end

	if ((entity.Owner and entity.Owner == client) or entity:GetNetVar("owner") == client) then
		local class = entity:GetClass():lower()
		if (string.find(class, "feather_")) then
			return (client:IsAdmin()) or entity.allowphys
		end

		if SERVER then
			local tbl = constraint.GetAllConstrainedEntities(entity)
			if (tbl) then
				for k, v in pairs(tbl) do
					if (v == entity) then continue end

					if (!v.Owner or v.Owner != client or entity:GetNetVar("owner") != client) then
						return (client:IsAdmin())
					end
				end
			end
		end
	else
		if entity.friends and table.HasValue(entity.friends, client) then
			return true
		end

		if SERVER then
			if (!client.NextPropNotify or client.NextPropNotify < CurTime()) then
				client.NextPropNotify = CurTime() + 2
				if (entity.Owner and entity.Owner:IsValid()) then
					client:notify("This entity is owned by " .. entity.Owner:Name() or "Player")
				else
					client:notify("This entity is owned by World")
				end
			end
		end

		if (client:IsAdmin()) then
			return true
		end
		return false
	end

	return true
end

function GM:GravGunPickupAllowed(client, entity)
	return (!entity.noGrab)
end

function GM:CanTool(client, entity, tool)
	entity = entity.Entity
	if entity and entity:IsValid() then
		return (client:IsAdmin()) or (entity.Owner == client)
	end

	return true
end

hook.Add("PlayerDisconnected", "DestroyDisonnceted", function(client)
	if client:IsAdmin() then return end
	
	for k, v in ipairs(ents.GetAll()) do
		if v.Owner == client then
			v:Remove()
		end
	end
end)