if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Battering Ram"
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
SWEP.UseHands = true	
SWEP.cantDrop = true

SWEP.Category = "Feather"
SWEP.HoldType = "normal"

SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.IconLetter = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("rpg")
end

function SWEP:DrawWorldModel()
	self:DrawModel()

	local at = self:GetAttachment(1)
	local pos, ang = at.Pos, at.Ang
	ang:RotateAroundAxis(ang:Forward(), 90)
	pos = pos + ang:Up()*2.7
	pos = pos + ang:Right()*-.2
	pos = pos + ang:Forward()*-10

	cam.Start3D2D(pos, ang, .2)
		draw.SimpleText(self.PrintName, "ChatFont", 0, 0, color_white, 2, 1)
	cam.End3D2D()
end

if SERVER then
	function SWEP:PrimaryAttack()
		local td = {}
			td.start = self.Owner:GetShootPos()
			td.endpos = td.start + self.Owner:GetAimVector()*64
			td.filter = self.Owner
		local trace = util.TraceLine(td)
		local door = trace.Entity

		if (door:IsValid() and door:IsDoor()) then
			self.Owner:ViewPunch(Angle(-20, 0, 0))
			door:Fire("unlock")
			door:EmitSound(Format("doors/vent_open%s.wav", math.random(1, 3)))
			door:EmitSound(Format("physics/wood/wood_box_break%s.wav", math.random(1, 2)))
			door:Fire("open", .5)
		end

		self:SetNextPrimaryFire(CurTime() + 2)
	end
else
	function SWEP:PrimaryAttack()
	end

	hook.Add("CanDrawDoorInfo", "FeatherBatteringRam", function()
		local wep = LocalPlayer():GetActiveWeapon()
		if (wep and wep:IsValid()) then
			if (wep:GetClass() == "weapon_batteringram") then
				return false
			end
		end
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
		draw.SimpleText(GetLang"hudslamdoor", "fr_Arrested", w/2, h/2 + 35, color_white, 1, 1)
		if (trace.Entity:IsValid()) then
			if trace.Entity:IsDoor() then
				draw.SimpleText(GetLang("hudslamdoortarget", string.NiceTime(feather.config.get("lockPickTime"))), "fr_Arrested", w/2, h/2 + 60, Color(255, 122, 122), 1, 1)
			end
		end
	end
end