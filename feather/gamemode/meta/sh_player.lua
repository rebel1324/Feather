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

function FindPlayer(client, name, mute)
	local fault = GetLang"plyinvalid"

	if (!name) then
		if (!mute) then
			client:notify(fault)
		end

		return
	end

	local target = nut.util.FindPlayer(name)

	if (!IsValid(target)) then
		if (!mute) then
			client:notify(fault)
		end
	end

	return target
end