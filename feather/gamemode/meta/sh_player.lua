local playerMeta = FindMetaTable("Player")

function playerMeta:notify(message, class)
	if (SERVER) then
		GAMEMODE:Notify(message, class, self)
	else
		GAMEMODE:Notify(message, class)
	end
end