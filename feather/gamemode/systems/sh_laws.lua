// MAKE ARREST DONE
local playerMeta = FindMetaTable("Player")
GM.WantedList = {}

if SERVER then
	GM.JailPos = {}

	function Vector2SQL(v)
		return v[1] .. "," .. v[2] .. "," .. v[3]
	end

	function GM:LoadJailPos()
		cn.db.query("SELECT * FROM fr_jailpos", function(data)
			if (IsValid(self)) then
				PrintTable(data)
			end
		end)
	end
	hook.Add("InitPostEntity", "FeatherLoadJailPos", GM.LoadJailPos)

	function GM:SaveJailPos()
		local clearquery = Format("DELETE * FROM fr_jailpos WHERE _map = '%s'", GetMap())
		local savequery = "INSERT INTO fr_jailpos (_map, _vector) VALUES ('%s', '%s')"
		for k, v in ipairs(self.JailPos) do
			cn.db.query(Format(savequery, GetMap(), Vector2SQL(v)), function()
			end)
		end
	end

	function GM:AddJailPos(vector)
		table.insert(self.JailPos, vector)

		timer.Create("FeatherJailPosSave", 1, 1, function()
			self:SaveJailPos()
		end)
	end

	function GM:OnPlayerArrested()
		return self.DefaultArrestTime, "Arrested"
	end

	function playerMeta:Arrest(arrester, reason, time)
		if #GAMEMODE.JailPos > 0 then
			local jailpos
			jailpos = table.Random(GAMEMODE.JailPos)

			self:SetPos(jailpos)
		end

		time, reason = hook.Run("OnPlayerArrested", self, arrester, reason, time)

		if self:IsArrested() then 
			return 
		end

		GAMEMODE:CenterDisplay(GetLang("arrested", self:Name(), arrester:Name(), string.NiceTime(time)), 3)
		--GAMEMODE:CenterDisplay("" .. self:Name() .. " has been arrested by ".. arrester:Name() ..".\nArrested time: " .. string.NiceTime(time) .. ".", 3)
		self:notify(GetLang("arrestedby", arrester:Name()))
		self:UnWanted(true)
		self:StripWeapons()
		self:SetNetVar("arrested", CurTime() + time)

		timer.Create(self:SteamID64() .. "_ARREST", time, 1, function()
			if !self or !self:IsValid() then
				return
			end

			self:UnArrest()
		end)
	end

	function playerMeta:UnArrest(unarrester)
		timer.Destroy(self:SteamID64() .. "_ARREST")
		self:SetNetVar("arrested", nil)

		if unarrester then
			NotifyAll(GetLang("unarrested", self:Name(), unarrester:Name()))
			hook.Run("PlayerLoadout", self)
		else
			self:notify(GetLang"unarrestedfull")
			self:Spawn()
		end
	end

	function playerMeta:Wanted(from, reason, time)
		GAMEMODE:CenterDisplay(GetLang("wanted", self:Name(), reason), 3)

		self:SetNetVar("wanted", true)
		netstream.Start(player.GetAll(), "FeatherWanted", {self, true, time})

		timer.Create(self:SteamID64() .. "_WANTED", time, 1, function()
			if !self:IsValid() then
				return
			end

			NotifyAll(GetLang("unwanted", self:Name()))
			self:SetNetVar("wanted", false)
		end)
	end
	
	function playerMeta:UnWanted(mute)
		if !mute then
			NotifyAll(GetLang("unwanted", self:Name()))
		end

		self:SetNetVar("wanted", false)
		timer.Destroy(self:SteamID64() .. "_WANTED")
	end

	hook.Add("PlayerInitialSpawn", "FeatherJailExtender", function(client)
	end)

	function GM:Lockdown(reason)
		SetNetVar("lockdown", true)
		SetNetVar("lockdownreason", reason)
		self:BroadcastSound("npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav")
		NotifyAll(GetLang"declarelockdown")
	end

	function GM:UnLockdown(reason)
		SetNetVar("lockdown", false)
		SetNetVar("lockdownreason", nil)
		NotifyAll(GetLang"finishlockdown")
	end
else
end

function playerMeta:IsWanted()
	return GAMEMODE.WantedList[self]
end

function playerMeta:IsArrested()
	return self:GetNetVar("arrested")
end

function GM:OnWantedPlayer(client, target, reason, time)
	return reason, time
end

function GM:CanWantedPlayer(client, target)
	local targetjob = GAMEMODE:GetJobData(target:Team())

	if targetjob.goverment then
		client:notify(GetLang"wantedgoverment", 3)
		return false
	end

	if client:IsWanted() then
		client:notify(GetLang"alreadywanted", 3)
		return false
	end
end

GM:RegisterCommand({
	desc = "This command allows goverment to seek certain player for the prosecution.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local ply = arguments[1]
		local reason = arguments[2]
		local time = tonumber(arguments[3]) or GAMEMODE.DefaultWantedTime

		if !GAMEMODE:GetJobData(client:Team()).goverment then
			client:notify(GetLang"begoverment", 4)
			return
		end

		local target
		if ply then
			target = FindPlayer(ply)
		else
			local trace = client:GetEyeTraceNoCursor()
			target = trace.Entity
		end

		if !target or !target:IsValid() then
			client:notify(GetLang"invalidplayer", 4)
			return
		end

		if !reason or reason == "" then
			client:notify(GetLang"invalidreason", 4)
			return
		end

		if target == client then
			client:notify(GetLang"cantdo", 4)
			return
		end

		if hook.Run("CanWantedPlayer", client, target) == false then
			return 
		end
		
		//client:notify("You grant " .. target:Name() .. " " .. data.name .. ".", 4)
		//DO CENTER NOTIFY.
		local reason, finaltime = hook.Run("OnWantedPlayer", client, target, reason, time)
		target:Wanted(client, reason, time)
	end
}, "wanted")

GM:RegisterCommand({
	desc = "This command allows goverment to stop seek certain player for the prosecution.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local ply = arguments[1]

		if !GAMEMODE:GetJobData(client:Team()).goverment then
			client:notify(GetLang"begoverment", 4)
			return
		end

		local target
		if ply then
			target = FindPlayer(ply)
		else
			local trace = client:GetEyeTraceNoCursor()
			target = trace.Entity
		end

		if !target or !target:IsValid() then
			client:notify(GetLang"invalidplayer", 4)
			return
		end

		if hook.Run("CanUnWantedPlayer", client, target) == false then
			return 
		end
		
		//client:notify("You grant " .. target:Name() .. " " .. data.name .. ".", 4)
		//DO CENTER NOTIFY.
		local reason, finaltime = hook.Run("OnUnWantedPlayer", client, target)
		target:UnWanted(client)
	end
}, "unwanted")

GM:RegisterCommand({
	desc = "This command allows goverment to stop seek certain player for the prosecution.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local ply = arguments[1]

		if !GAMEMODE:GetJobData(client:Team()).goverment then
			client:notify(GetLang"begoverment", 4)
			return
		end

		local trace = client:GetEyeTraceNoCursor()

		client:notify(GetLang"newjailpos")
		GAMEMODE:AddJailPos(trace.HitPos)
	end
}, "addjailpos")

GM:RegisterCommand({
	desc = "This command allows goverment to stop seek certain player for the prosecution.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local ply = arguments[1]

		if !GAMEMODE:GetJobData(client:Team()).goverment then
			client:notify(GetLang"begoverment", 4)
			return
		end

		local trace = client:GetEyeTraceNoCursor()

		client:notify(GetLang"setjailpos")
		GAMEMODE.JailPos = {trace.HitPos}
	end
}, "setjailpos")

GM:RegisterCommand({
	desc = "This command allows goverment to get control of the city for temporaliy.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local reason = table.concat(arguments, " ")

		if GetNetVar("lockdown") then
			GAMEMODE:UnLockdown()
			return	
		end

		if !GAMEMODE:GetJobData(client:Team()).mayor then
			client:notify(GetLang"bemayor", 4)
			return
		end

		if !reason or reason == "" then
			client:notify(GetLang"invalidreason", 4)
			return
		end

		if hook.Run("CanLockdown", client) == false then
			return 
		end
		
		//client:notify("You grant " .. target:Name() .. " " .. data.name .. ".", 4)
		//DO CENTER NOTIFY.
		GAMEMODE:Lockdown(reason)
	end
}, "lockdown")