// MAKE ARREST DONE

local playerMeta = FindMetaTable("Player")

if SERVER then
	GM.JailPos = {}

	function GM:LoadJailPos()
		// LOAD IT FROM SQL
	end
	
	function GM:SaveJailPos()
		// SAVE IT IN TEH SQL.
	end

	function GM:OnPlayerArrested()
		return self.DefaultArrestTime, "Arrested"
	end

	function playerMeta:Arrest(arrester, reason, time)
		if #GAMEMODE.JailPos > 0 then
			local jailpos
			local try = 0
			while (try <= 100) do


				try = try + 1
			end
		end

		time, reason = hook.Run("OnPlayerArrested", self, arrester, reason, time)

		GAMEMODE:CenterDisplay("" .. self:Name() .. " has been arrested by ".. self:Name() ..".\nArrested time: " .. string.NiceTime(time) .. ".", 3)
		self:UnWanted(true)
		self:StripWeapons()
		self:SetNetVar("arrested", true)

		timer.Create(self:SteamID64() .. "_ARREST", time, 1, function()
			if !self or !self:IsValid() then
				return
			end

			self:UnArrest()
		end)
	end

	function playerMeta:UnArrest()
		self:SetNetVar("arrested", false)
		hook.Run("PlayerLoadout", self)
	end

	function playerMeta:Wanted(from, reason, time)
		NotifyAll("Player " .. self:Name() .. " is now wanted by the police. Reason: " .. reason)

		self:SetNetVar("wanted", true)
		netstream.Start(player.GetAll(), "FeatherWanted", {self, true, time})

		timer.Create(self:SteamID64() .. "_WANTED", time, 1, function()
			if !self:IsValid() then
				return
			end

			NotifyAll("Player " .. self:Name() .. " is no longer wanted by the police.")
			self:SetNetVar("wanted", false)
		end)
	end
	
	function playerMeta:UnWanted(mute)
		if !mute then
			NotifyAll("Player " .. self:Name() .. " is no longer wanted by the police.")
		end

		self:SetNetVar("wanted", false)
		timer.Destroy(self:SteamID64() .. "_WANTED")
	end

	hook.Add("PlayerInitialSpawn", "FeatherJailExtender", function(client)
	end)

	function GAMEMODE:Lockdown(reason)
		SetNetVar("lockdown", true)
		SetNetVar("lockdownreason", reason)
		self:BroadcastSound("npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav")
		NotifyAll("Mayor declared the lockdown.")
	end

	function GAMEMODE:UnLockdown(reason)
		SetNetVar("lockdown", false)
		SetNetVar("lockdownreason", nil)
		NotifyAll("Mayor finished the lockdown.")
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
		client:notify("You can't wanted goverment player.", 3)
		return false
	end

	if self:IsWanted() then
		client:notify("That player is already wanted.", 3)
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
			client:notify("You should be in goverment to do this action.", 4)
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
			client:notify("You should find a player to be wanted.", 4)
			return
		end

		if !reason or reason == "" then
			client:notify("You must provide a reason to wanted a player.", 4)
			return
		end

		if target == client then
			client:notify("You can't get your name on ther list be yourself.", 4)
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
			client:notify("You should be in goverment to do this action.", 4)
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
			client:notify("You should find a player to be unwanted.", 4)
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
	desc = "This command allows goverment to get control of the city for temporaliy.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local reason = table.concat(arguments, " ")

		if GetNetVar("lockdown") then
			GAMEMODE:UnLockdown()
			return	
		end

		if GAMEMODE:GetJobData(client:Team()).mayor then
			client:notify("You should be mayor to lockdown the city.", 4)
			return
		end

		if !reason or reason == "" then
			client:notify("You must provide a reason to lockdown the city.", 4)
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