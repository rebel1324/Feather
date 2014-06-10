function GM:PlayerInitialSpawn(client)
	client:SetTeam(TEAM_CITIZEN)
end

-- Load Data when player is on control.
function GM:PlayerAuthed(client)
	client:loadFeatherData()

	local uniqueID = "fr_PayCheck"..client:SteamID()

	timer.Create(uniqueID, 30, 0, function()
		if (!IsValid(client)) then return timer.Remove(uniqueID) end
		
		if (hook.Run("PlayerCanReceivePay", client) != false) then
			local amount, reason = hook.Run("PlayerGetPayAmount", client)

			if (!amount or amount == 0) then
				return client:notify(reason or GetLang"nopay")
			end

			hook.Run("PlayerReceivePay", client, amount)
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
	if client:IsArrested() then
		amount = 0
	end
	client:GiveMoney(amount)
	client:notify(GetLang("payday", MoneyFormat(amount)))
end

function GM:PlayerDisconnected(client)
	client:saveFeatherData()
end

function GM:PlayerCanReceivePay(client)
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

function GM:CanPlayerLoadout(client)
	return (!client:IsArrested())
end

function GM:PlayerLoadout(client)
	if hook.Run("CanPlayerLoadout", client) == false then
		return
	end

	hook.Run("GetBaseLoadout", client)

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

function GM:CanBecomeJob(client, data, teamindex)
	if (client:IsArrested()) then
		client:notify(GetLang"yourearrested")
	end

	if (client.banned) then
		client:notify(GetLang"cantdo")
	end
end

function GM:BecomeJob(client, teamindex, voted)
	local data = self:GetJobData(teamindex)
	local name = team.GetName(teamindex)

	if !data then
		client:notify(GetLang"invalidjob")
	end

	if !voted and client.nextJob and client.nextJob > CurTime() then
		client:notify(GetLang"toofast")

		return false
	end

	if hook.Run("CanBecomeJob", client, data, teamindex) == false then
		client:notify(GetLang"cantbecomejob")
	end

	if teamindex == client:Team() then
		client:notify(GetLang"onjob")
		return true
	end

	if data.childjob and data.childjob != client:Team() then
		client:notify(GetLang("needtobe", team.GetName(data.childjob)))
		return false
	end

	if !voted and data.vote and #player.GetAll() > 1 then
		if client.onvote then 
			client:notify(GetLang"onjobvote")
			return false
		end
		
		client.onvote = true
		self:StartVote(client, GetLang("wantstobe", client:Name(), name), 10
		,function(cl) GAMEMODE:BecomeJob(cl, teamindex, true) client.onvote = false end
		,function(cl) cl:notify(GetLang("jobvotefail", cl:Name(), name)) end)
		return false
	end

	client.nextJob = CurTime() + GAMEMODE.JobChangeDelay
	client:SetTeam(teamindex)
	hook.Run("PlayerLoadout", client)
	NotifyAll(GetLang("becamejob", client:Name(), name))
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