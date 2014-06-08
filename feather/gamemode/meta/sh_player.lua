local playerMeta = FindMetaTable("Player")

function playerMeta:notify(message, class)
	if (SERVER) then
		GAMEMODE:Notify(message, class, self)
	else
		GAMEMODE:Notify(message, class)
	end
end

function NotifyAll(message, class)
	for k, v in pairs(player.GetAll()) do
		v:notify(message, class)
	end
end

function FindPlayer(name)
	for k, v in pairs(player.GetAll()) do
		if (StringMatches(v:Name(), name)) then
			return v
		end
	end
end

function NoticeFindPlayer(client, name)
	local fault = GetLang"plyinvalid"

	if (!name) then
		client:notify(fault)

		return
	end

	local target = nut.util.FindPlayer(name)

	if (!IsValid(target)) then
		client:notify(fault)
	end

	return target
end