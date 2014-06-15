if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Lock Pick"
SWEP.Author = "Black Tea"
SWEP.Instructions = "Left click to pick the lock."
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.cantDrop = true

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

		if (trace.Entity:IsValid() and trace.Entity:IsDoor() and !self.target) then
			self:StartPick(trace.Entity)	
		end

		self:SetNextPrimaryFire(CurTime() + .5)
	end

	function SWEP:StartPick(target)
		self.target = target
		local picktime = feather.config.get("lockPickTime")
		netstream.Start(self.Owner, "FeatherProgressDisplay", {GetLang"hudpickname", picktime})

		timer.Create(self:EntIndex() .. "_PICK", picktime, 1, function()
			if self:IsValid() and self.Owner:IsValid() and self.Owner:Alive() and self.target:IsValid() then
				self.target:EmitSound("doors/vent_open1.wav", 30, 90)
				self.target:Fire("unlock")

				self.target = nil
			end
		end)
	end
	
	function SWEP:OnRemove()
		self:StopPick()
	end

	function SWEP:StopPick()
		self.target = nil
		netstream.Start(self.Owner, "FeatherProgressDisplay", {"", 0})

		timer.Destroy(self:EntIndex() .. "_PICK")
	end

	function SWEP:Think()
		if (self.target and self.target:IsValid()) then
			local td = {}
				td.start = self.Owner:GetShootPos()
				td.endpos = td.start + self.Owner:GetAimVector()*64
				td.filter = self.Owner
			local trace = util.TraceLine(td)

			if trace.Entity != self.target then
				self:StopPick()	
			end
		end
	end
else
	function SWEP:PrimaryAttack()
	end

	hook.Add("CanDrawDoorInfo", "FeatherLockpick", function()
		return !(LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_lockpick")
	end)
end

function SWEP:SecondaryAttack()
	
end

function SWEP:DrawHUD()
	local w, h = ScrW(), ScrH()

	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*64
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if (hook.Run("CanDrawWeaponHUD") != false) then
		draw.SimpleText(GetLang"hudpick", "fr_Arrested", w/2, h/2 + 35, color_white, 1, 1)
		if (trace.Entity:IsValid()) then
			if trace.Entity:IsDoor() then
				draw.SimpleText(GetLang("hudpicktarget", string.NiceTime(feather.config.get("lockPickTime"))), "fr_Arrested", w/2, h/2 + 60, Color(255, 122, 122), 1, 1)
			end
		end
	end
end