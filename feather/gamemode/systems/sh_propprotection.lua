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

function GM:PlayerSpawnedProp(client, model, entity)
	entity.Owner = client
end

function GM:PlayerSpawnedSENT(client, entity)
	entity.Owner = client
end

function GM:PlayerSpawnedRagdoll(client, entity)
	entity.Owner = client
end

function GM:PlayerSpawnedEffect(client, entity)
	entity.Owner = client
end

function GM:PlayerSpawnedSWEP(client, entity)
	entity.Owner = client
end

function GM:PlayerSpawnedVehicle(client, entity)
	entity.Owner = client
end

function GM:PhysgunPickup(client, entity)
	if (client:IsAdmin()) then
		return true
	end
	
	if (entity:IsNPC()) then
		return (client:IsAdmin())
	end

	if ((entity.Owner and entity.Owner == client) or entity:GetNetVar("owner") == client) then
		local class = entity:GetClass():lower()
		if (string.find(class, "feather_")) then
			return entity.allowphys
		end

		if SERVER then
			local tbl = constraint.GetAllConstrainedEntities(entity)
			if (tbl) then
				for k, v in pairs(tbl) do
					if (v == entity) then continue end

					if (!v.Owner or v.Owner != client or entity:GetNetVar("owner") != client) then
						return false
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
		return false
	end

	return true
end