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

function FindRandomPlayer()
	return table.Random(player.GetAll())
end

function FindRandomPlayerWithJob(jobindex)
	return table.Random(team.GetPlayers(jobindex))
end

function NoticeFindPlayer(client, name)
	local fault = GetLang("invalid", "player")

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