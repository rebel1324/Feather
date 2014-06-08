if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Arrest Baton"
SWEP.Author = "Black Tea"
SWEP.Instructions = "Left click to arrest"
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = 0
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

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*128
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if SERVER then
		local ply = trace.Entity

		if ply:IsPlayer() then
			ply:Arrest(self.Owner)
		end
	end

	self:SetNextPrimaryFire(CurTime() + .5)
end

function SWEP:SecondaryAttack()
end