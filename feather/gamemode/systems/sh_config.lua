if (SERVER) then cn.data.setBaseDir("feather") end

feather.config = feather.config or {}
feather.config.vars = feather.config.vars or {}
feather.config.default = {}

function feather.config.create(key, value, desc, nonShared)
	feather.config.default[key] = {value = value, desc = desc or "No description available.", nonShared = nonShared}
end

function feather.config.set(key, value, receiver)
	feather.config.vars[key] = value

	if (SERVER and !feather.config.default[key].nonShared) then
		netstream.Start(receiver, "fr_Config", key, value)
	end
end

function feather.config.get(key, default)
	if (feather.config.vars[key] != nil) then
		return feather.config.vars[key]
	end

	if (default == nil) then
		local config = feather.config.default[key]
		default = config and config.default
	end

	return default
end

function feather.config.getType(key)
	return feather.config.default[key] and type(feather.config.default[key].value)
end

if (SERVER) then
	function feather.config.load()
		local saved = cn.data.read("config", {})
		local buffer = {}
		
		for k, v in pairs(feather.config.default) do
			buffer[k] = v.value
		end

		feather.config.vars = table.Merge(buffer, saved)
	end

	function feather.config.save()
		local buffer = {}

		for k, v in pairs(feather.config.vars) do
			local default = feather.config.default[k]

			if (v != (default and default.value)) then
				buffer[k] = v
			end
		end

		cn.data.write("config", buffer)
	end

	function feather.config.send(client)
		netstream.Start(client, "fr_ConfigInit", feather.config.vars)
	end

	hook.Add("Initialize", "fr_ConfigLoader", feather.config.load)
	hook.Add("ShutDown", "fr_ConfigSaver", feather.config.save)
	hook.Add("PlayerInitialSpawn", "fr_SendConfig", feather.config.send)
else
	netstream.Hook("fr_Config", function(key, value)
		feather.config.vars[key] = value
	end)

	netstream.Hook("fr_ConfigInit", function(data)
		feather.config.vars = data
	end)
end