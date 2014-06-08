function GM:PlayerInitialSpawn(client)
	client:SetTeam(TEAM_CITIZEN)
	client:loadFeatherData()

	local uniqueID = "fr_PayCheck"..client:SteamID()

	timer.Create(uniqueID, 30, 0, function()
		if (!IsValid(client)) then return timer.Remove(uniqueID) end
		
		if (hook.Run("PlayerCanReceivePay", client) != false) then
			local amount, reason = hook.Run("PlayerGetPayAmount", client)

			if (!amount or amount == 0) then
				return client:notify(reason or GetLang"nopay")
			end

			hook.Run("PlayerReceivePay", client, MoneyFormat(amount))
		end
	end)
end

function GM:CenterDisplay(text, time)
	netstream.Start(player.GetAll(), "FeatherCenterDisplay", {text, time})
end

function GM:BroadcastSound(snd)
	netstream.Start(player.GetAll(), "PlaySound", snd)
end

function GM:ShutDown()
	for k, v in pairs(player.GetAll()) do
		v:saveFeatherData()
	end
end

function GM:PlayerReceivePay(client, amount)
	client:giveMoney(amount)
	client:notify(GetLang("payday", amount))
end

function GM:PlayerDisconnected(client)
	client:saveFeatherData()
end

function GM:PlayerCanReceivePay(client)
	return !client:GetNetVar("arrested")
end

function GM:PlayerGetPayAmount(client)
	local job = self.Jobs[client:Team()]

	if (job and job.salary) then
		return job.salary
	else
		return false, GetLang("zerosalary")
	end
end

function GM:Notify(message, class, receiver)
	netstream.Start(receiver, "fr_Notify", message, class or NOTIFY_GENERIC)
end

function GM:GetBaseLoadout(client)
	client:Give("weapon_physgun")
	client:Give("weapon_physcannon")
	client:Give("gmod_tool")
	client:Give("gmod_camera")

	client:Give("weapon_fists")
	client:Give("weapon_key")
end

function GM:PlayerLoadout(client)
	hook.Call("GetBaseLoadout", GAMEMODE, client)

	local index = client:Team()
	local teamdata = self:GetJobData(index)

	if teamdata and teamdata.loadout then
		for k, v in pairs(teamdata.loadout) do
			client:Give(v)
		end
	end
end

function GM:PlayerSay(client, text, public)
	local result = self:ProcessChat(client, text)

	if (result) then
		return result
	end
	
	return text
end

function GM:Demote(from, to, reason, voted)
end

function GM:BecomeJob(client, teamindex, voted)
	local data = self:GetJobData(teamindex)
	local name = team.GetName(teamindex)

	if !voted and client.nextJob and client.nextJob > CurTime() then
		client:notify("You're switching Job too fast! Try again later.")

		return false
	end

	if hook.Run("CanBecomeJob", client, data, teamindex) == false then
		client:notify(GetLang"cantbecomejob")
	end

	if teamindex == client:Team() then
		client:notify("You're already on that job.")
		return true
	end

	if data.childjob and data.childjob != client:Team() then
		client:notify("You need to be " .. team.GetName(data.childjob) .. " first!")
		return false
	end

	if !voted and data.vote and #player.GetAll() > 100 then
		if client.onvote then 
			client:notify("Your Job vote is on going. Try again later.")
			return false
		end
		
		client.onvote = true
		self:StartVote(client, client:Name() .. " wants to be " .. name, 10
		,function(cl) GAMEMODE:BecomeJob(cl, teamindex, true) client.onvote = false end
		,function(cl) cl:notify(cl:Name() .. " didn't made to " .. name .. "!") end)
		return false
	end

	client.nextJob = CurTime() + GAMEMODE.JobChangeDelay
	client:SetTeam(teamindex)
	hook.Run("PlayerLoadout", client)
	NotifyAll(client:Name() .. " has been made a " .. name)
end

function GM:CanDrive(client)
	return client:IsAdmin()
end

function GM:CanProperty(client)
	return client:IsAdmin()
end

function GM:PlayerGiveSWEP(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnEffect(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnNPC(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnNPC(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnProp()
	return true
end

function GM:PlayerSpawnSENT(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnSWEP(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnVehicle(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnObject(client)
	return true
end