// GET LICENSE CREATION TESTED
// NEED LICENSE CONTROL TERMINAL
GM.Licenses = {}

if SERVER then
	function GM:LoadLicense()
		cn.db.query("SELECT * FROM fr_licenses", function(data)
			if (IsValid(self)) then
				PrintTable(data)
			end
		end)
	end
	hook.Add("OnGamemodeLoaded", "FeatherLicenseLoad", GM:LoadLicense())

	function GM:SaveLicense()
		for k, v in pairs(GAMEMODE.Licenses) do
			if (v.default ~= true) then
				cn.db.query("SELECT * FROM fr_licenses WHERE _uniqueID = ".. k, function(data) 
					if (table.Count(data) == 0) then
						cn.db.query("INSERT INTO fr_licenses (_uniqueID, _name, _desc, _price) VALUES ('".. k .."', '".. v.name .."', '".. v.desc .."', ".. v.price ..")")
					else
						cn.db.query("UPDATE fr_licenses SET _name = '".. v.name .."', _desc = '".. v.desc .."', _price = ".. v.price .." WHERE = ".. k)
					end
				end)
			end
		end
	end
	hook.Add("ShutDown", "FeatherLicenseLoad", GM:LoadLicense())

	local function RevokeAllLicense(client)
		local l = client:GetLicenses()

		for k, v in pairs(l) do
			client:RevokeLicense(k)
		end
	end
	hook.Add("PlayerDeath", "FeatherLicenseRevoke", RevokeAllLicense)

	netstream.Hook("RequestLicenses", function(client)
		if (!client.infoLicenses) then
			client.infoLicenses = true
			netstream.Start("RequestLicenses", GAMEMODE.Licenses)
		end
	end)

	netstream.Hook("RequestLicense", function(client, data)
		if !IsEntityClose(client:GetPos(), 128, "feather_licensem") then
			client:notify("You must get closer to the machine.")	
		end

		local info = GAMEMODE:GetLicenseInfo(data)
		if client:GiveLicense(data) then
			client:EmitSound("plats/train_use1.wav")
			client:notify("You got " .. info.name .. " for " .. MoneyFormat(info.price) .. ".")
		else
			client:notify("You already have this license.")
		end
	end)
else
	netstream.Hook("RequestLicenses", function(data)
		GAMEMODE.Licenses = data
	end)

	hook.Add("PlayerAuthed", "FeatherRequestServerLicenses", function()
		netstream.Start("RequestLicenses")
	end)

	local PNL = {}

	function PNL:Init()
		self:SetTall(70)
		self:DockMargin(5, 5, 5, 5)
	end 

	function PNL:SetData(id, data)
		self.data = data
		self.id = id

		local text = vgui.Create("DLabel", self)
		text:Dock(TOP)
		text:SetContentAlignment(1)
		text:SetFont("fr_LicenseTitle")
		text:SetText(self.data.name)
		text:DockMargin(17, 10, 5, 5)
		text:SetAutoStretchVertical( true )
		text:SetColor(color_black)	

		local text = vgui.Create("DLabel", self)
		text:Dock(TOP)
		text:SetContentAlignment(1)
		text:SetFont("fr_LicenseBtn")
		text:SetText("$ ".. self.data.price)
		text:DockMargin(17, 0, 5, 5)
		text:SetAutoStretchVertical( true )
		text:SetColor(color_black)	
	end
	
	function PNL:OnCursorEntered()
		self.on = true
		surface.PlaySound("UI/buttonrollover.wav")
	end
	
	function PNL:OnCursorExited()
		self.on = false
	end

	function PNL:DoClick()
		self.p:SelectButton(self)
		surface.PlaySound("npc/turret_floor/click1.wav")
	end

	function PNL:Paint(w, h)
		if self.data then
			if self.activated then
				surface.SetDrawColor(255, 255, 255)
			elseif self.on then
				surface.SetDrawColor(255, 255, 255)
			else
				surface.SetDrawColor(222, 222, 222)
			end

			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetDrawColor(155, 155, 155)
			surface.DrawOutlinedRect(1, 1, w-2, h-2)
		end
	end

	vgui.Register("LicenseList", PNL, "DButton")

	local PNL = {}

	function PNL:Init()
		self:SetSize(300, 400)
		self:Center()
		self:MakePopup()

		local text = vgui.Create("DLabel", self)
		text:Dock(TOP)
		text:SetContentAlignment(2)
		text:SetFont("fr_License")
		text:SetText("License Manager")
		text:DockMargin(5, 5, 5, 5)
		text:SetAutoStretchVertical( true )
		text:SetColor(color_white)	

		self.content = vgui.Create("DScrollPanel", self)
		self.content:Dock(TOP)
		self.content:SetTall(275)
		self.content:DockMargin(5,5,5,5)
		self.content:SetDrawBackground(true)

		self.mod = vgui.Create("DButton", self)
		self.mod:SetFont("fr_LicenseBtn")
		self.mod:SetText("Modify")
		self.mod:SetTall(30)
		self.mod:SetWide(86)
		self.mod:SetPos(10, self:GetTall() - 10 - self.mod:GetTall())
		self.mod:SetColor(color_black)

		self.pur = vgui.Create("DButton", self)
		self.pur:SetFont("fr_LicenseBtn")
		self.pur:SetText("Purchase")
		self.pur:SetTall(30)
		self.pur:SetWide(86)
		self.pur:SetPos(10*2 + self.pur:GetWide()*1, self:GetTall() - 10 - self.pur:GetTall())
		self.pur:SetColor(color_black)
		self.pur.DoClick = function()
			if self.selected then
				netstream.Start("RequestLicense", self.selected.id)
			end
		end

		local btn = vgui.Create("DButton", self)
		btn:SetFont("fr_LicenseBtn")
		btn:SetText("Close")
		btn:SetTall(30)
		btn:SetWide(86)
		btn:SetPos(10*3 + btn:GetWide()*2, self:GetTall() - 10 - btn:GetTall())
		btn:SetColor(color_black)
		btn.DoClick = function() self:Close() end

		self.pur:SetDisabled(true)
		self.mod:SetDisabled(true)
		self:LoadLicense()
	end
	
	function PNL:SelectButton(pnl)
		if self.selected then
			self.selected.activated = false
		end

		self.pur:SetDisabled(false)
		self.mod:SetDisabled(false)
		self.selected = pnl
		pnl.activated = true
	end
	
	function PNL:LoadLicense()
		for k, v in pairs(GAMEMODE.Licenses) do
			local pnl = vgui.Create("LicenseList", self.content)
			pnl:Dock(TOP)
			pnl:SetText("")
			pnl:SetData(k, v)
			pnl.p = self
		end
	end
	
	vgui.Register("LicenseMenu", PNL, "DFrame")

	netstream.Hook("LicenseMachine", function()
		if LicenseMenu and LicenseMenu:IsVisible() then
			return
		end

		LicenseMenu = vgui.Create("LicenseMenu")
	end)
end

function GM:CreateLicense(uniqueID, name, desc, price) // In-Game User custom License
	self.Licenses[uniqueID] = {
		name = name or "A License",
		desc = desc or "The license that allows you to do something.",
		price = price or 10,
		default = false,
	}
end

function GM:GetLicenseInfo(uniqueID)
	return self.Licenses[uniqueID]
end

function GM:AddDefaultLicense(uniqueID, name, desc, price) // Add Default License
	self.Licenses[uniqueID] = {
		name = name or "A License",
		desc = desc or "The license that allows you to do something.",
		price = price or 10,
		default = true,
	}
end

function FindLicense(name)
	for k, v in pairs(GAMEMODE.Licenses) do
		if k == name then
			return v
		end
	end

	for k, v in pairs(GAMEMODE.Licenses) do
		if (StringMatches(v.name, name)) then
			return v
		end
	end
end

local playerMeta = FindMetaTable("Player")

if SERVER then
	function playerMeta:GetLicenses()
		return self:GetNetVar("license")
	end

	function playerMeta:GetLicense(name)
		local tbl = self:GetNetVar("license") or {}
		return tbl[name] or false
	end

	function playerMeta:GiveLicense(name)
		if (!self:GetLicense(name)) then
			local tbl = self:GetNetVar("license") or {}
			tbl[name] = true
			self:SetNetVar("license", tbl)

			return true
		else
			return false
		end
	end

	function playerMeta:RevokeLicense(name)
		if (self:GetLicense(name)) then
			local tbl = self:GetNetVar("license") or {}
			tbl[name] = nil
			self:SetNetVar("license", tbl)

			return true
		else
			return false
		end
	end

	function GM:CanGrantLicense(lic, data, client, target) 
		if (target:IsArrested() or client:IsArrested()) then
			client:notify("You can't grant license to arrested personel.", 4)
			return false
		end

		if (!GAMEMODE:GetJobData(client:Team()).goverment) then
			client:notify("You should be in goverment to do this action.", 4)
			return false
		end
	end
end

GM:RegisterCommand({
	desc = "This command allows you to give license to facing/specific player if you're in goverment faction.",
	syntax = "<License Name/UniqueID> [Target Player]",
	onRun = function(client, arguments)
		local lic = arguments[1]
		local ply = arguments[2]

		local target
		if (ply) then
			target = FindPlayer(ply)
		else
			local trace = client:GetEyeTraceNoCursor()
			target = trace.Entity
		end

		if (!target or !target:IsValid()) then
			client:notify("You should find a player to give license.", 4)
			return
		end

		if (target == client) then
			client:notify("You can't give license to yourself.", 4)
			return
		end

		if (target:GetPos():Distance(client:GetPos()) <= 128) then
			local data = FindLicense(lic)

			if (hook.Run("CanGrantLicense", lic, data, client, target) == false) then
				return 
			end

			if (data) then
				if target:GiveLicense(lic) then
					client:notify("You grant " .. target:Name() .. " " .. data.name .. ".", 4)
					target:notify(client:Name() .. " grant you " .. data.name .. ".", 4)
					hook.Run("OnGrantLicense", lic, data, client, target)
				else
					client:notify("He already has that license.", 4)
				end
			end
		end
	end
}, "givelicense")

GM:RegisterCommand({
	desc = "This command allows you to take license to facing/specific player if you're in goverment faction.",
	syntax = "<License Name/UniqueID> [Target Player]",
	onRun = function(client, arguments)
		local lic = arguments[1]
		local ply = arguments[2]

		local target
		if (ply) then
			target = FindPlayer(ply)
		else
			local trace = client:GetEyeTraceNoCursor()
			target = trace.Entity
		end

		if (!target or !target:IsValid()) then
			client:notify("You should find a player to give license.", 4)
			return
		end

		if (target == client) then
			client:notify("You can't give license to yourself.", 4)
			return
		end

		if (target:GetPos():Distance(client:GetPos()) <= 128) then
			local data = FindLicense(lic)

			if (hook.Run("CanRevokeLicense", lic, data, client, target)) == false then
				return 
			end

			if (data) then
				if target:RevokeLicense(lic) then
					client:notify("You revoked " .. data.name .. " from " .. target:Name() .. ".", 4)
					target:notify(client:Name() .. " revoked " .. data.name .. " from you.", 4)
					hook.Run("OnRevokeLicense", lic, data, client, target)
				else
					client:notify("He doesn't have that license.", 4)
				end
			end
		end
	end
}, "revokelicense")

GM:AddDefaultLicense("gun", "Gun License", "The license that allows you to carry firearms.", 500)
GM:AddDefaultLicense("drive", "Drive License", "The license that allows you to drive vehicles.", 300)