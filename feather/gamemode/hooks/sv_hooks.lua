-- Load Data when player is on control.
function GM:PlayerInitialSpawn(client)
	client:SetTeam(TEAM_CITIZEN)
	client:LoadFeatherData()

	local uniqueID = "fr_PayCheck"..client:SteamID()

	timer.Create(uniqueID, 30, 0, function()
		if (!IsValid(client)) then return timer.Remove(uniqueID) end

		self:PayDay(client)
	end)
end

function GM:PayDay(client)
	if (hook.Run("PlayerCanReceivePay", client) != false) then
		local amount, reason = hook.Run("PlayerGetPayAmount", client)

		if (!amount or amount == 0) then
			return client:notify(reason or GetLang"nopay")
		end

		hook.Run("PlayerReceivePay", client, amount)
	end
end

function GM:PostLoadPlayerData(client)
	self:PayDay(client)
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
end

function GM:PlayerLoadout(client)
	if hook.Run("CanPlayerLoadout", client) == false then
		return
	end

	hook.Run("GetBaseLoadout", client)
end

function GM:PlayerSetModel(client)
	local index = client:Team()
	local jobdata = self:GetJobData(index)

	client:SetWalkSpeed(feather.config.get("walkSpeed"))
	client:SetRunSpeed(feather.config.get("runSpeed"))
	if jobdata and jobdata.model then
		client:SetModel(table.Random(jobdata.model))
	end
end

function GM:PlayerSay(client, text, public)
	local result = self:ProcessChat(client, text)

	if (result) then
		return result
	end
	
	return text
end

function GM:CanBecomeJob(client, data, teamindex)
	if (client.bannedJobs and client.bannedJobs[teamindex] and client.bannedJobs[teamindex] > CurTime()) then
		return false, GetLang"jobapplybanned"
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
		self:StartVote(from, GetLang("demote", to:Name(), reason), 10, funcs)

		return false
	else
		to.bannedJobs = to.bannedJobs or {}
		to.bannedJobs[to:Team()] = CurTime() + feather.config.get("jobBanTime")
		to:notify(GetLang("jobbanned", string.ToMinutesSeconds(feather.config.get("jobBanTime"))))

		NotifyAll(GetLang("playerdemoted", to:Name()))
		GAMEMODE:BecomeJob(to, to:Team(), TEAM_CITIZEN, true, false)

		return true
	end
end

function GM:BecomeJob(client, oldjobindex, teamindex, voted, silent)
	local data = self:GetJobData(teamindex)
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

	local result, fault = hook.Run("CanBecomeJob", client, data, teamindex)

	if result == false then
		client:notify(fault or GetLang"cantbecomejob")
		return
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

function GM:AddMarker(client, pos, icon, text, time)
	netstream.Start(client, "FeatherMarker", {
		pos = pos,
		icon = icon,
		text = text,
		time = time,
	})
end

function GM:OnPlayerDestory(entity, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if (attacker and attacker:IsValid() and attacker:IsPlayer()) then
		local data = self:GetJobData(attacker:Team())
		local inflictor = dmginfo:GetInflictor()
		if (entity and entity:IsValid() and entity.OnPlayerDestory) then
			entity:OnPlayerDestory(entity, attacker, inflictor, data)
		end
	end
end

function GM:GetFallDamage(client, vel)
	if (GetConVarNumber("sv_falldamage") != 0 or feather.config.get("falldamage")) then
        vel = vel - 320  
        return vel*(100/(1024-320))
	end
	return 10
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

function GM:PlayerSpawnSENT(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnSWEP(client)
	return client:IsAdmin()
end

function GM:PlayerSpawnVehicle(client)
	return client:IsAdmin()
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