local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

cn.net = cn.net or {}
cn.net.globals = cn.net.globals or {}

netstream.Hook("net.var", function(index, key, value)
	cn.net[index] = cn.net[index] or {}
	cn.net[index][key] = value
end)

netstream.Hook("net.del", function(index)
	cn.net[index] = nil
end)

netstream.Hook("net.lcl", function(key, value)
	cn.net[LocalPlayer():EntIndex()] = cn.net[LocalPlayer():EntIndex()] or {}
	cn.net[LocalPlayer():EntIndex()][key] = value
end)

netstream.Hook("net.gvar", function(key, value)
	cn.net.globals[key] = value
end)

function GetNetVar(key, default)
	local value = cn.net.globals[key]

	return value != nil and value or default
end

function entityMeta:GetNetVar(key, default)
	local index = self:EntIndex()

	if (cn.net[index] and cn.net[index][key] != nil) then
		return cn.net[index][key]
	end

	return default
end

playerMeta.GetLocalVar = entityMeta.GetNetVar