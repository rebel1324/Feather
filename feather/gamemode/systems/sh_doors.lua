local entityMeta = FindMetaTable("Entity")

if SERVER then
	// SAVE DOOR:
	// HIDDEN, UNOWNABLE, IF OWNER IS NUMBER
	// TITLE IS SAVED WHEN THESE CONDITIONS ARE MATCHED.

	function entityMeta:SetDoorOwner(client)
		local tbl = self:GetDoorOwners() or {}
		for k, v in pairs(tbl) do
			tbl[k] = false	
		end

		tbl[client] = true
		self:SetNetVar("owners", tbl)
	end
	
	function entityMeta:SetDoorSubOwner(client)
		local tbl = self:GetDoorOwners()

		if GetDoorOwner(tbl) == client then
			return
		end

		tbl[client] = false
		self:SetNetVar("owners", tbl)
	end

	function entityMeta:FlushDoor()
		if self:IsDoor() then
			self:SetNetVar("owners", nil)
		end
	end

	function GM:FlushPlayerDoor(client)
		for k, v in ipairs(ents.GetAll()) do
			if v:IsDoor() then
				if GetDoorOwner(v:GetDoorOwners()) == client then
					v:FlushDoor()
				end
			end
		end
	end
	hook.Add("PlayerDisconnect", "FeatherDoorFlush", GM.FlushPlayerDoor)

	function GM:CanBuyDoor(client, door)
		if door:GetNetVar("unownable") then
			client:notify(GetLang"itsunownable")
			return false
		end
	end
else
	function GM:DrawDoorInfo(w, h)
		if hook.Run("CanDrawDoorInfo") == false then
			return
		end
		
		local trace = LocalPlayer():GetEyeTraceNoCursor()
		local door = trace.Entity
		if door:IsValid() and door:IsDoor() and door:GetPos():Distance(EyePos()) < 128 and !door:GetNetVar("hidden") then
			self.DrawDoor = true

			local sx, sy = w/2, h/2

			local text = (door:GetNetVar("title") or (door:GetNetVar("unownable") and "Unownable" or (door:GetNetVar("owners") and "Untitled" or "Unowned")))
			surface.SetFont("fr_LicenseTitle")
			local tx, ty = surface.GetTextSize(text)
			draw.SimpleText(text, "fr_Arrested", sx - tx/2, sy - ty, color_white, 0, 0)

			local owners = door:GetNetVar("owners")
			if !door:GetNetVar("owners") then
				text = "You can buy this door by pressing F2"
				local tx, ty = surface.GetTextSize(text)
				draw.SimpleText(text, "fr_Arrested", sx - tx/2, sy, color_white, 0, 0)
			else
				if string.lower(type(owners)) == "table" then
					local owner = GetDoorOwner(owners)
					text = GetLang("doorowner", owner:Name())
					local tx, ty = surface.GetTextSize(text)
					draw.SimpleText(text, "fr_Arrested", sx - tx/2, sy, color_white, 0, 0)

					if owner != LocalPlayer() then
						
					end
				else
					// GROUP ONLY.
				end
			end
		else
			self.DrawDoor = false
		end
	end
end

function entityMeta:IsDoor()
	if string.find(self:GetClass(), "door") then
		return true
	end
end

function entityMeta:GetDoorOwner()
	if self:IsDoor() then
		return GetDoorOwner(self:GetDoorOwners())
	end
end

function entityMeta:GetDoorOwners()
	if self:IsDoor() then
		return self:GetNetVar("owners")
	end
end

function GetDoorOwner(table)
	if !table then return end
	
	for k, v in pairs(table) do
		if v then
			return k
		end
	end
end

GM:RegisterCommand({
	desc = "This command allows you to change the door's title.",
	syntax = "<Door Title>",
	onRun = function(client, arguments)
		local str = table.concat(arguments, " ")

		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		if (client:IsSuperAdmin() or target:GetDoorOwner() == client) then
			target:SetNetVar("title", str)
			client:notify(GetLang"setdoortitle", 4)
		else
			client:notify(GetLang"dooroccupied", 4)
		end
	end
}, "title")

GM:RegisterCommand({
	desc = "This command allows you to change the door's title.",
	syntax = "<Door Title>",
	onRun = function(client, arguments)
		local str = table.concat(arguments, " ")

		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		if target:GetDoorOwner() then
			client:notify(GetLang"dooroccupied", 4)
			return
		end

		if !client:payMoney(GAMEMODE.DoorPrice) then
			return
		end

		if hook.Run("CanBuyDoor", client, target) == false then
			return
		end

		target:SetDoorOwner(client)
		client:notify(GetLang("doorpurchase", MoneyFormat(GAMEMODE.DoorPrice)))
	end
}, "buydoor")

GM:RegisterCommand({
	desc = "This command allows you to change the door's title.",
	syntax = "<Door Title>",
	onRun = function(client, arguments)
		local str = table.concat(arguments, " ")

		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		if !target:GetDoorOwner() then
			client:notify(GetLang"doornoowner", 4)
			return
		end

		if target:GetDoorOwner() != client then
			client:notify(GetLang"dooroccupied", 4)
			return
		end

		target:FlushDoor()
		client:notify(GetLang"doorsold")
	end
}, "selldoor")

GM:RegisterCommand({
	desc = "This command allows you to change the door's title.",
	syntax = "<Door Title>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		target:SetNetVar("unownable", true)
		client:notify(GetLang"setdoorunownable")
	end
}, "setunownable")

GM:RegisterCommand({
	desc = "This command allows you to change the door's title.",
	syntax = "<Door Title>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		target:SetNetVar("unownable", nil)
		client:notify(GetLang"setdoorownable")
	end
}, "setownable")

GM:RegisterCommand({
	desc = "This command allows you to change the door's title.",
	syntax = "<Door Title>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		if !target:GetNetVar("hidden") then
			target:SetNetVar("hidden", true)
			target:SetNetVar("unownable", true)
			client:notify(GetLang"setdoorhidden")
		else
			target:SetNetVar("hidden", nil)
			target:SetNetVar("unownable", nil)
			client:notify(GetLang"setdoorunhidden")
		end
		target:SetNetVar("title", nil)
	end
}, "sethidden")

// TODO: Door Manager funcitons