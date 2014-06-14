if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Weapon Search"
SWEP.Author = "Black Tea"
SWEP.Instructions = "Left click to search his wepaons"
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "Feather"
SWEP.HoldType = "normal"

SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.IconLetter = ""

function SWEP:GetViewModelPosition(pos, ang)
	-- die
	pos.z = 35575
	return pos, ang
end

if SERVER then
	function SWEP:PrimaryAttack()
		local td = {}
			td.start = self.Owner:GetShootPos()
			td.endpos = td.start + self.Owner:GetAimVector()*64
			td.filter = self.Owner
		local trace = util.TraceLine(td)
		local target = trace.Entity

		if target:IsValid() and target:IsPlayer() and !self.target then
			self:StartSearch(trace.Entity)	
		end

		self:SetNextPrimaryFire(CurTime() + .5)
	end

	function SWEP:StartSearch(client)
		self.target = client
		local searchtime = 1
		netstream.Start(self.Owner, "FeatherProgressDisplay", {GetLang"hudsearchname", searchtime})
		netstream.Start(self.target, "FeatherProgressDisplay", {GetLang"hudsearchvictimname", searchtime})

		timer.Create(self:EntIndex() .. "_SEARCH", searchtime, 1, function()
			if self:IsValid() and self.Owner:IsValid() and self.Owner:Alive() then
				local result = {}
				for k, v in pairs(self.target:GetWeapons()) do
					table.insert(result, v:GetClass())
				end
				netstream.Start(self.Owner, "FeatherWeaponSearch", result)
				self.target = nil
			end
		end)
	end
	
	function SWEP:OnRemove()
		self:StopSearch()
	end

	function SWEP:StopSearch()
		self.target = nil
		netstream.Start(self.Owner, "FeatherProgressDisplay", {"", 0})

		timer.Destroy(self:EntIndex() .. "_SEARCH")
	end

	function SWEP:Think()
		if self.target and self.target:IsValid() then
			local dist = self.target:GetPos():Distance(self.Owner:GetPos())
			if dist >= 64*1.5 then
				self:StopSearch()	
			end
		end
	end
else
	function SWEP:PrimaryAttack()
	end

	local PNL = {}

	function PNL:Init()
		self:SetSize(400, 250)
		self:Center()
		self:MakePopup()
		self:SetText("Result")

		local text = vgui.Create("DLabel", self)
		text:Dock(TOP)
		text:SetContentAlignment(2)
		text:SetFont("fr_MenuBigFont")
		text:SetText(GetLang"searchwindow")
		text:DockMargin(5, 10, 5, 5)
		text:SetAutoStretchVertical( true )
		text:SetColor(color_black)	

		self.content = vgui.Create("PanelList", self)
		self.content:Dock(FILL)
		self.content:EnableVerticalScrollbar()
		self.content:SetSpacing(5)
		self.content:SetPadding(10)
		self.content.Paint = function() end
	end
	
	function PNL:AddWeapon(name)
		local text = vgui.Create("DLabel", self)
		text:SetContentAlignment(1)
		text:SetFont("fr_FrameFont")
		text:SetText(GetWeaponName(name))
		text:SetAutoStretchVertical( true )
		text:SetColor(color_black)	
		self.content:AddItem(text)
	end

	vgui.Register("FeatherWeaponSearch", PNL, "FeatherFrame")

	netstream.Hook("FeatherWeaponSearch", function(data)
		if WeaponResult and WeaponResult:IsValid() then
			WeaponResult:Close()
			WeaponResult = nil
		end

		WeaponResult = vgui.Create("FeatherWeaponSearch")
		for k, v in pairs(data) do
			WeaponResult:AddWeapon(v)
		end
	end)
end

function SWEP:DrawHUD()
	local w, h = ScrW(), ScrH()

	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*64
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if hook.Run("CanDrawWeaponHUD") then
		draw.SimpleText(GetLang"hudsearch", "fr_Arrested", w/2, h/2 + 35, color_white, 1, 1)
		if trace.Entity:IsValid() then
			if trace.Entity:IsPlayer() then
				draw.SimpleText(GetLang("hudsearchtarget", trace.Entity:Name()), "fr_Arrested", w/2, h/2 + 60, Color(255, 122, 122), 1, 1)
			end
		end
	end
end

function SWEP:SecondaryAttack()
end