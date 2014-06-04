local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

cn.net = cn.net or {}
cn.net.globals = cn.net.globals or {}

function SetNetVar(key, value, receiver)
	if (GetNetVar(key) == value) then return end

	cn.net.globals[key] = value

	netstream.Start(receiver, "net.gvar", key, value)
end

function playerMeta:SyncNetVars()
	for entity, data in pairs(cn.net) do
		if (entity == "globals") then
			for k, v in pairs(data) do
				netstream.Start(self, "net.gvar", k, v)
			end
		elseif (IsValid(entity)) then
			for k, v in pairs(data) do
				netstream.Start(self, "net.var", entity:EntIndex(), k, v)
			end
		end
	end
end

function entityMeta:SendNetVar(key, receiver)
	netstream.Start(receiver, "net.var", self:EntIndex(), key, cn.net[self] and cn.net[self][key])
end

function entityMeta:ClearNetVars(receiver)
	cn.net[self] = nil

	netstream.Start(receiver, "net.del", self:EntIndex())
end

function entityMeta:SetNetVar(key, value, receiver)
	cn.net[self] = cn.net[self] or {}

	if (cn.net[self][key] != value) then
		cn.net[self][key] = value
	end

	self:SendNetVar(key, receiver)
end

function entityMeta:GetNetVar(key, default)
	if (cn.net[self] and cn.net[self][key] != nil) then
		return cn.net[self][key]
	end

	return default
end

function playerMeta:SetLocalVar(key, value)
	cn.net[self] = cn.net[self] or {}
	cn.net[self][key] = value

	netstream.Start(self, "net.lcl", key, value)
end

playerMeta.GetLocalVar = entityMeta.GetNetVar

function GetNetVar(key, default)
	local value = cn.net.globals[key]

	return value != nil and value or default
end

hook.Add("EntityRemoved", "cn.net.cleanUp", function(entity)
	entity:ClearNetVars()
end)

hook.Add("PlayerInitialSpawn", "cn.net.sync", function(client)
	client:SyncNetVars()
end)