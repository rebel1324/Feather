local entityMeta = FindMetaTable("Entity")

GM.DoorGroup = {
	["goverment"] = {
		text = "Owned by Goverment",
		canuse = function(client)
			local jobdata = GAMEMODE:GetJobData(client:Team())
			return jobdata.goverment
		end,
	}
}

if SERVER then 
	-- EW GOTTA FIX TIS CODE
	function GM:LoadDoorData()
		local doors = {}
		cn.db.query(Format("SELECT * FROM fr_doordata WHERE _map = '%s'", GetMap()), function(data)
			for k, v in ipairs(data) do
				if v._entid then
					doors[tonumber(v._entid)] = v
				end
			end

			for k, v in ipairs(ents.GetAll()) do	
				local dat = doors[v:MapCreationID()]			
				if dat then
					local owner = dat._owner
					local title = dat._title
					local hidden = tobool(tonumber(dat._hidden or 0))

					v:SetNetVar("owners", owner)
					v:SetNetVar("title", title)
					v:SetNetVar("hidden", hidden)
					if owner == "unownable" then
						v:SetNetVar("unownable", true)
					end
				end
			end
		end)
	end
	hook.Add("InitPostEntity", "FeatherLoadDoorData", GM.LoadDoorData)

	function GM:SaveDoorData(door)
		local getquery = Format("SELECT * FROM fr_doordata WHERE _map = '%s' AND _entid = %s", GetMap(), door:MapCreationID())
		local insertquery = Format("INSERT INTO fr_doordata (_map, _title, _owner, _entid, _hidden) VALUES ('%s', '%s', '%s', %s, %s)", GetMap(), door:GetNetVar("title", ""), door:GetNetVar("owners", ""), door:MapCreationID(), (door:GetNetVar("hidden", false)) and (1) or (0)) 
		local updatequery = Format("UPDATE fr_doordata SET _title = '%s', _owner = '%s', _hidden = %s WHERE _map = '%s' AND _entid = '%s'", door:GetNetVar("title", ""), door:GetNetVar("owners", ""), (door:GetNetVar("hidden", false)) and (1) or (0), GetMap(), door:MapCreationID()) 
		cn.db.query(getquery, function(data)
			if (IsValid(door)) then
				if (table.Count(data) == 0) then
					cn.db.query(insertquery)
				else
					cn.db.query(updatequery)
				end
			end
		end)
	end

	function GM:DeleteDoorData(door)
		local getquery = Format("SELECT * FROM fr_doordata WHERE _map = '%s' AND _entid = %s", GetMap(), door:MapCreationID())
		local deletequery = Format("DELETE FROM fr_doordata WHERE _map = '%s' AND _entid = %s", GetMap(), door:MapCreationID())
		cn.db.query(getquery, function(data)
			if (IsValid(door)) then
				if (table.Count(data) != 0) then
					cn.db.query(deletequery)
				end
			end
		end)
	end

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
			self:SetNetVar("title", nil)
		end
	end

	function GM:FlushPlayerDoor(client)
		for k, v in ipairs(ents.GetAll()) do
			if v:IsDoor() then
				if GetDoorOwner(v:GetDoorOwners()) == client then
					v:FlushDoor()
				end

				if !GetDoorOwner(v:GetDoorOwners()):IsValid() then
					v:FlushDoor()
				end
			end
		end
	end
	hook.Add("PlayerDisconnect", "FeatherDoorFlush", GM.FlushPlayerDoor)

	function GM:CanBuyDoor(client, door)
		if self:GetDoorCount(client) >= feather.config.get("maxDoors") then
			client:notify("2muchdoor")
			return false
		end

		if door:GetNetVar("unownable") or type(door:GetDoorOwners()):lower() == "string" then
			client:notify(GetLang"itsunownable")
			return false
		end
	end

	function GM:GetDoorCount(client)
		local count = 0
		for k, v in ipairs(ents.GetAll()) do
			if (v:IsDoor() and v:GetDoorOwner() == client) then
				count = count + 1
			end
		end

		return count
	end
else
	function GM:DrawDoorInfo(w, h)
		if hook.Run("CanDrawDoorInfo") == false then
			return
		end
		local ply = LocalPlayer()
		local trace = ply:GetEyeTraceNoCursor()
		local door = trace.Entity
		if door:IsValid() and door:IsDoor() and door:GetPos():Distance(EyePos()) < 128 and !door:GetNetVar("hidden") then
			self.DrawDoor = true

			local sx, sy = w/2, h/2

			local text = (door:GetNetVar("title") or (door:GetNetVar("unownable") and GetLang"unownable" or (door:GetNetVar("owners") and GetLang"untitled" or GetLang"unowned")))
			surface.SetFont("fr_LicenseTitle")
			local tx, ty = surface.GetTextSize(text)
			draw.SimpleText(text, "fr_Arrested", sx - tx/2, sy - ty, color_white, 0, 0)

			local owners = door:GetNetVar("owners")
			if !door:GetNetVar("owners") then
				text = GetLang"doorhelp"
				local tx, ty = surface.GetTextSize(text)
				draw.SimpleText(text, "fr_Arrested", sx - tx/2, sy, color_white, 0, 0)
			else
				if string.lower(type(owners)) == "table" then
					local owner = GetDoorOwner(owners)
					
					if !owner or !owner:IsValid() then
						return
					end

					text = GetLang("doorowner", owner:Name())
					local tx, ty = surface.GetTextSize(text)
					draw.SimpleText(text, "fr_Arrested", sx - tx/2, sy, color_white, 0, 0)

					if owner != ply then
						
					end
				else
					local group = self.DoorGroup[owners]
					if group then
						local tx, ty = surface.GetTextSize(group.text)
						draw.SimpleText(group.text, "fr_Arrested", sx - tx/2, sy, color_white, 0, 0)
					end
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
	if type(table):lower() != "table" then return end
	
	for k, v in pairs(table) do
		if v then
			return k
		end
	end
end

GM:RegisterCommand({
	category = "Property",
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

			if (type(target:GetNetVar("owners")):lower() == "string") then
				GAMEMODE:SaveDoorData(target)
			end
		else
			client:notify(GetLang"dooroccupied", 4)
		end
	end
}, "title")

GM:RegisterCommand({
	category = "Property",
	desc = "This command allows you to buy the door you're looking at.",
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

		if !client:PayMoney(feather.config.get("doorPrice")) then
			return
		end

		if hook.Run("CanBuyDoor", client, target) == false then
			return
		end

		target:SetDoorOwner(client)
		client:notify(GetLang("doorpurchase", MoneyFormat(feather.config.get("doorPrice"))))
	end
}, "buydoor")

GM:RegisterCommand({
	category = "Property",
	desc = "This command allows you to sell the door you're looking at.",
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
	category = "Property",
	desc = "This command allows admin to change the door's ownable state to unownable.",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		target:SetNetVar("unownable", true)
		target:SetNetVar("owners", "unownable")
		client:notify(GetLang"setdoorunownable")
		GAMEMODE:SaveDoorData(target)
	end
}, "setunownable")

GM:RegisterCommand({
	category = "Property",
	desc = "This command allows admin to change the door's ownable state to unownable and make the door as certain faction exclusive.",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity
		local faction = arguments[1]

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		target:SetNetVar("owners", faction)
		client:notify(faction)
		GAMEMODE:SaveDoorData(target)
	end
}, "setfactiondoor")

GM:RegisterCommand({
	category = "Property",
	desc = "This command allows admin to change the door's hidden state.\nMaking door unhidden have same effect as making door ownable.",
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
			GAMEMODE:SaveDoorData(target)
		else
			target:SetNetVar("hidden", false)
			target:SetNetVar("unownable", nil)
			target:SetNetVar("title", nil)
			target:SetNetVar("owners", nil)
			client:notify(GetLang"setdoorunhidden")
			GAMEMODE:DeleteDoorData(target)
		end
		target:SetNetVar("title", nil)
	end
}, "sethidden")

GM:RegisterCommand({
	category = "Property",
	desc = "This command allows admin to change the door's ownable state to ownable and reset all door data.",
	syntax = "<Door Title>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if (!target or !target:IsValid()) then
			client:notify(GetLang"invalidentity", 4)
			return
		end

		target:SetNetVar("unownable", nil)
		target:SetNetVar("title", nil)
		target:SetNetVar("owners", nil)
		client:notify(GetLang"setdoorownable")
		GAMEMODE:DeleteDoorData(target)
	end
}, "setownable")
// TODO: Door Manager funcitons