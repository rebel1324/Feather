
local playerMeta = FindMetaTable("Player")

GM.WantedList = {}

function playerMeta:IsWanted()
	return GAMEMODE.WantedList[self]
end

if SERVER then
	GM.JailPos = {}
	GM.JailedList = {}

	function GM:LoadJailPos()
		// LOAD IT FROM SQL
	end
	
	function GM:SaveJailPos()
		// SAVE IT IN TEH SQL.
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

		self:UnWanted()
		self:SetNetVar("arrested", true)
	end

	function playerMeta:UnArrest()
		self:SetNetVar("arrested", false)
	end

	function playerMeta:Wanted(from, reason, time)
		NotifyAll("Player " .. self:Name() .. " is now wanted by the police. Reason: " .. reason)

		GAMEMODE.WantedList[self] = CurTime() + time
		netstream.Start(player.GetAll(), "FeatherWanted", {self, true, time})

		timer.Create(self:SteamID64() .. "_WANTED", time, 1, function()
			if !self:IsValid() then
				for k, v in pairs(GAMEMODE.WantedList) do
					if !k or !k:IsValid() then
						GAMEMODE.WantedList[k] = nil
					end
				end

				return
			end

			NotifyAll("Player " .. self:Name() .. " is no longer wanted by the police.")
			GAMEMODE.WantedList[self] = nil
			netstream.Start(player.GetAll(), "FeatherWanted", {self, false})
		end)
	end
	
	function playerMeta:UnWanted()
		NotifyAll("Player " .. self:Name() .. " is no longer wanted by the police.")

		GAMEMODE.WantedList[self] = nil
		netstream.Start(player.GetAll(), "FeatherWanted", {self, false})
		timer.Destroy(self:SteamID64() .. "_WANTED")
	end

	hook.Add("PlayerInitialSpawn", "FeatherJailExtender", function(client)
		if table.HasValue(GAMEMODE.WantedList, client) then
			client:Arrest()
		end
	end)
else
	netstream.Hook("FeatherWanted", function(data)
		local target = data[1]
		local wanted = data[2]
		if target and target:IsValid() then
			if wanted then
				local time = data[3]
				GAMEMODE.WantedList[target] = CurTime() + time
			else
				GAMEMODE.WantedList[target] = nil
			end
		end
	end)
	// YAY
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
