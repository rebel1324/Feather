// MAKE ARREST DONE
local playerMeta = FindMetaTable("Player")

if SERVER then
	GM.JailPos = {}

	function GM:LoadJailPos()
		GAMEMODE.JailPos = {}

		cn.db.query(Format("SELECT _vector FROM fr_jailpos WHERE _map = '%s'", GetMap()), function(data)
			for k, v in pairs(data) do
				table.insert(GAMEMODE.JailPos, SQL2Vector(v._vector))
			end
		end)
	end
	hook.Add("InitPostEntity", "FeatherLoadJailPos", GM.LoadJailPos)

	function GM:SaveJailPos()
		local clearquery = Format("DELETE FROM fr_jailpos WHERE _map = '%s'", GetMap())
		cn.db.query(clearquery, function()	end)
		
		local savequery = "INSERT INTO fr_jailpos (_map, _vector) VALUES ('%s', '%s')"
		for k, v in ipairs(self.JailPos) do
			cn.db.query(Format(savequery, GetMap(), Vector2SQL(v)), function(data) 
				PrintTable(data)
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

	hook.Add("PlayerSpawn", "FeatherJailSpawn", function(client)
		if (client:IsArrested()) then
			client:Arrest()
		end
	end)

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
		GAMEMODE:CenterDisplay(GetLang("wanted", self:Name(), from:Name(), reason), 3)

		self:SetNetVar("wanted", {time, reason})

		timer.Create(self:SteamID64() .. "_WANTED", time, 1, function()
			if !self:IsValid() then
				return
			end

			NotifyAll(GetLang("unwanted", self:Name()))
			self:SetNetVar("wanted", nil)
		end)
	end
	
	function playerMeta:UnWanted(mute)
		if !mute then
			NotifyAll(GetLang("unwanted", self:Name()))
		end

		self:SetNetVar("wanted", nil)
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
	netstream.Hook("SetLaws", function(data, len)
		GAMEMODE.CustomLaws = data
	end)
end

function playerMeta:IsWanted()
	return self:GetNetVar("wanted")
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
	category = "Goverment Commands",
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
	category = "Goverment Commands",
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
	category = "Goverment Commands",
	desc = "This command allows goverment to stop seek certain player for the prosecution.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local ply = arguments[1]

		if !GAMEMODE:GetJobData(client:Team()).goverment and !client:IsAdmin() then
			client:notify(GetLang"begoverment", 1)
			return
		end

		client:notify(GetLang"newjailpos")
		GAMEMODE:AddJailPos(client:GetPos())
	end
}, "addjailpos")

GM:RegisterCommand({
	category = "Goverment Commands",
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
		GAMEMODE.JailPos = {client:GetPos()}
		GAMEMODE:SaveJailPos()
	end
}, "setjailpos")

GM:RegisterCommand({
	category = "Goverment",
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
		
		GAMEMODE:Lockdown(reason)
	end
}, "lockdown")

GM:RegisterCommand({
	category = "Goverment",
	desc = "This command allows mayor to add laws.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local law = table.concat(arguments, " ")

		if (!GAMEMODE:GetJobData(client:Team()).mayor) then
			client:notify(GetLang"bemayor", 1)
			return
		end

		if (!law or law == "") then
			client:notify(GetLang"invalidtext", 1)
			return
		end
		
		local laws = GAMEMODE.CustomLaws or {}
		if (#laws + #GAMEMODE.DefaultLaws >= 15) then
			client:notify(GetLang"maxrows", 1)
			return
		end

		table.insert(laws, law)
		netstream.Start(player.GetAll(), "SetLaws", laws)
	end
}, "addlaw")

GM:RegisterCommand({
	category = "Goverment",
	desc = "This command allows mayor to add laws.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		local row = tonumber(arguments[1])

		if !GAMEMODE:GetJobData(client:Team()).mayor then
			client:notify(GetLang"bemayor", 1)
			return
		end

		if (!row or row == "") then
			client:notify(GetLang"invalidtext", 1)
			return
		end

		if (row <= #GAMEMODE.DefaultLaws) then
			client:notify(GetLang"defaultlaw", 1)
			return
		end
		
		local delrow = row - #GAMEMODE.DefaultLaws
		if (GAMEMODE.CustomLaws and GAMEMODE.CustomLaws[delrow]) then
			table.remove(GAMEMODE.CustomLaws, delrow)
			netstream.Start(player.GetAll(), "SetLaws", GAMEMODE.CustomLaws)
		else
			client:notify(GetLang"invalidrow", 1)
		end
	end
}, "removelaw")


GM:RegisterCommand({
	category = "Goverment",
	desc = "This command allows mayor to add laws.",
	syntax = "<Target Player> <Reason> [time]",
	onRun = function(client, arguments)
		if !GAMEMODE:GetJobData(client:Team()).mayor then
			client:notify(GetLang"bemayor", 1)
			return
		end

		if (#ents.FindByClass("feather_lawboard") >= 2) then
			client:notify(GetLang"maxlawboards", 1)
			return
		end

		local td = {}
			td.start = client:GetShootPos()
			td.endpos = td.start + client:GetAimVector()*(256)
			td.filter = client
		local trace = util.TraceLine(td)

		local entity = ents.Create("feather_lawboard")
		entity:SetPos(trace.HitPos - trace.HitNormal * -80)
		entity:Spawn()
		entity:Activate()
		entity:SetNetVar("owner", client)

		return entity
	end
}, "spawnlaw")