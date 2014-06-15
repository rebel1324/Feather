-- Load Data when player is on control.
function GM:PlayerInitialSpawn(client)
	client:SetTeam(TEAM_CITIZEN)
	client:LoadFeatherData()

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

function GM:PlayerCanHearPlayersVoice( listener, talker )
	return true, true
end

function GM:CenterDisplay(text, time)
	netstream.Start(player.GetAll(), "FeatherCenterDisplay", {text, time})
end

function GM:BroadcastSound(snd)
	netstream.Start(player.GetAll(), "PlaySound", snd)
end

function GM:InitPostEntity()
	self.EntLoaded = true

	for k, v in ipairs(ents.GetAll()) do
		local phys = v:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:Sleep()
		end
	end
end

function GM:ShutDown()
	self.Shutdown = true
	for k, v in pairs(player.GetAll()) do
		v:SaveFeatherData()
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
	client:SaveFeatherData()
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
	netstream.Start(receiver, "FeatherNotify", message, class or NOTIFY_GENERIC)
end

function GM:FadeScreen(client, color, dur)
	netstream.Start(client, "FeatherFade", {color, dur})
end

function GM:GetBaseLoadout(client)
	for k, v in ipairs(feather.config.get("defaultLoadout", {})) do
		client:Give(v)
	end
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
	local jobdata = self:GetJobData(index)

	if jobdata and jobdata.loadout then
		client:SetModel(table.Random(jobdata.model))

		for k, v in pairs(jobdata.loadout) do
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

function GM:MoneyEntityCreated(self)
	if (feather.config.get("moneyModel"):lower() == "models/props/cs_assault/money.mdl") then
		if self:GetDTInt(0) <= 100 then
			self:SetModel("models/props/cs_assault/Dollar.mdl")
		end
	end
end

function GM:MoneyEntityChanged(self)
	if (feather.config.get("moneyModel"):lower() == "models/props/cs_assault/money.mdl") then
		if self:GetDTInt(0) <= 100 then
			self:SetModel("models/props/cs_assault/Dollar.mdl")
		end
	end
end

function GM:CanBecomeJob(client, data, teamindex)
	if (client:IsArrested()) then
		client:notify(GetLang"yourearrested")
	end

	if (client.banned) then
		client:notify(GetLang"cantdo")
	end
end

function GM:OnPlayerBecomeJob(client, data, teamindex, oldteam)
	local effectData = EffectData()
	effectData:SetStart(client:GetPos())
	util.Effect("FeatherJob", effectData)

	netstream.Start(client, "UpdateJobs")
	hook.Run("PlayerLoadout", client)

	client:SetModel(table.Random(data.model))

	for k, v in ipairs(ents.GetAll()) do
		local owner = v:GetNetVar("owner")
		if (owner and owner == client and v.DeleteOnChange) then
			v:Remove()
		end	
	end

	if (oldteam == TEAM_MAYOR) then
		for k, v in ipairs(ents.FindByClass("feather_lawboard")) do
			v:Remove()
		end
	end
end

function GM:CanDemote(client, target)
	if (!client or !target or !client:IsValid() or !target:IsValid()) then
		client:notify(GetLang"invalidplayer")
		return
	end

	if (client:IsArrested()) then
		client:notify(GetLang"yourearrested")
		return false
	end

	if (!client.nextDemote or client.nextDemote > CurTime()) then
		client:notify(GetLang"toofast")
		return false
	end

	if (target:Team() == TEAM_CITIZEN) then
		client:notify(GetLang"cantdo")
		return false
	end
end

function GM:Demote(from, to, reason, voted)
	if !voted then
		if (hook.Run("CanDemote", from, to) != false) then
			return false
		end

		from.nextDemote = CurTime() + 1
		from.onvote = true
		to.onvote = true
		local funcs = {
			onsuccess = function()
				if (!from:IsValid() or !to:IsValid()) then
					return 
				end

				GAMEMODE:Demote(from, to, reason, true)
				from.onvote = false
				to.onvote = false
			end,
			onfailed = function()
				if (!from:IsValid() or !to:IsValid()) then
					return 
				end
				
				from.onvote = false
				to.onvote = false
			end
		}
		self:StartVote(client, GetLang("demote", to:Name(), reason), 10, funcs)

		return false
	else
		NotifyAll(GetLang("playerdemoted", to:Name()))
		GAMEMODE:BecomeJob(to, to:Team(), TEAM_CITIZEN, true, false)

		return true
	end
end

function GM:BecomeJob(client, oldjobindex, teamindex, voted, silent)
	print(client, teamindex)
	local data = self:GetJobData(teamindex)
	PrintTable(data)
	local name = team.GetName(teamindex)

	if !data then
		client:notify(GetLang"invalidjob")

		return false
	end

	if data.max then
		if #team.GetPlayers(teamindex) >= data.max then
			client:notify(GetLang"jobfull")
			return
		end	
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
		local funcs = {
			onsuccess = function(cl) if !cl:IsValid() then return end GAMEMODE:BecomeJob(cl, cl:Team(), teamindex, true) client.onvote = false end,
			onfailed = function(cl) if !cl:IsValid() then return end cl:notify(GetLang("jobvotefail", cl:Name(), name)) client.onvote = false end
		}
		self:StartVote(client, GetLang("wantstobe", client:Name(), name), 10, funcs)
		return false
	end

	client.nextJob = CurTime() + feather.config.get("JobDelay", 5)
	client:SetTeam(teamindex)
	client:StripWeapons()

	hook.Run("OnPlayerBecomeJob", client, data, teamindex, oldjobindex)
	if !silent then
		NotifyAll(GetLang("becamejob", client:Name(), name))
	end
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

function GM:PlayerSpawnProp(client, model)
	if table.HasValue(feather.config.get("blockedModels", {}), model) then
		return false
	end
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

function GM:ShowHelp()
end

function GM:GravGunPunt()
	return false
end

function GM:PlayerShouldTakeDamage(client, dmg)
	if (dmg:GetClass() == "prop_physics" and dmg.Owner) then
		return false
	end

	return (client:GetMoveType() != MOVETYPE_NOCLIP)
end

function GM:CanDrive(client)
	return (client:IsAdmin())
end


net.Receive( "ArmDupe", function() end )
net.Receive( "CopiedDupe", function() end )
net.Receive( "ReceiveDupe", function() end )