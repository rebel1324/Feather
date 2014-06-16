GM.Missions = {}
GM.AvailableMissions = {}
GM.MapPos = {}

function GM:AddMission(job)
	self.Missions[job.uid] = job
end

function GM:AddMapPos(map, cat, pos)
	map = map:lower()
	GM.MapPos[map] = GM.MapPos[map] or {}
	GM.MapPos[map][cat] = GM.MapPos[map][cat] or {}
	table.insert(GM.MapPos[map][cat], pos)
end

function GM:GetMapPos(cat)
	local map = game.GetMap():lower()
	if !self.MapPos[map][cat] then
		return false
	end

	return table.Random(self.MapPos[map][cat])
end

function GM:OnMissionComplete(client)
	client:ClearMission()
end

function GM:GetMission(mission)
	return self.Missions[mission]
end

function GM:CanAcceptMission(client, index)
	if (client:IsArrested()) then
		client:notify(GetLang"yourearrested")
		return false
	end

	if (client:IsWanted()) then
		return false
	end

	index = tonumber(index)
	local info = self.AvailableMissions[index]
	if (!info or info.taken) then
		client:notify(GetLang"missiontaken")
		return false
	end

	if (self:GetMission()) then
		client:notify(GetLang"onmission")
		return false
	end

	if (client.nextMission and client.nextMission > CurTime()) then
		client:notify(GetLang"missiondelay")
		return false
	end
end

function GM:OnAcceptMission(client, index)
	index = tonumber(index)
	local info = self.AvailableMissions[index]
	if info then
		client.nextMission = CurTime() + feather.config.get("missionDelay")

		self.AvailableMissions[index].taken = client
		client.missioninfo = info
		client.missioninfo.index = index

		client:AcceptMission(info.mission)

		local mission = GAMEMODE:GetMission(info.mission)
		mission.onAccept(client)
		client:notify(GetLang"missionaccept")
		netstream.Start(client, "FeahterJobUpdate", GAMEMODE.AvailableMissions)
	end
end

function GM:RequestMission(client, index)
	if hook.Run("CanAcceptMission", client, index) == false then
		return false
	end

	hook.Run("OnAcceptMission", client, index)
end

local playerMeta = FindMetaTable("Player")
function playerMeta:GetMission()
	return self:GetNetVar("mission")
end

function playerMeta:AcceptMission(mission)
	self:SetNetVar("mission", mission)
end

function playerMeta:ClearMission(failed)
	local info = self.missioninfo
	if !info then
		FeatherError("No Clear Mission Provided.")
		return
	end

	local mission = GAMEMODE:GetMission(info.mission)
	if mission then
		if failed then
			mission.onFailed(self, info)
		else
			mission.onSuccess(self, info)
		end
		mission.onEnded(self, info)
	end

	if (GAMEMODE.AvailableMissions[tonumber(info.index)].client == self) then
		table.remove(GAMEMODE.AvailableMissions, info.index)
	end
	self.missioninfo = nil
	self:SetNetVar("mission", nil)
end

function GM:RefreshJobs()
	if SERVER then
		GAMEMODE.AvailableMissions = {}
		for i = 1, 10 do
			local mission = table.Random(GAMEMODE.Missions)
			if mission then
				table.insert(GAMEMODE.AvailableMissions, {
					name = table.Random(mission.names),
					price = math.random(mission.moneymin, mission.moneymax),
					mission = mission.uid,
					taken = false,
				})	
			end
		end

		netstream.Start(player.GetAll(), "FeahterJobPing")
		NotifyAll(GetLang"newmissions")
		
		timer.Create("FEATHER_MISSIONS", feather.config.get("missionRefreshTime"), 1, function()
			GAMEMODE:RefreshJobs()
		end)
	end
end
hook.Add("InitPostEntity", "FeatherMissionAdd", GM.RefreshJobs)

hook.Add("PlayerDeath", "FeatherMissionFail", function(client)
	if client:GetMission() then
		client:ClearMission(true)
	end
end)

if SERVER then
	netstream.Hook("FeahterJobPing", function(client)
		netstream.Start(client, "FeahterJobUpdate", GAMEMODE.AvailableMissions)
	end)
end

GM:RegisterCommand({
	desc = "This command allows you to get some mission to earn some money.",
	syntax = "<UniqueID of the Mission>",
	category = "Market and Money",
	onRun = function(client, arguments)
		local mission = table.concat(arguments, " ")

		if (!mission or mission == "") then
			client:notify(GetLang("provide", "Unique ID."))
			return false
		end

		GAMEMODE:RequestMission(client, mission)

		return true
	end
}, "requestmission")
