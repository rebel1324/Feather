if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Key"
SWEP.Author = "Black Tea"
SWEP.Instructions = "Left click to lock/knock the door\nRight click to unlock/knock the door"
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
end

function SWEP:SecondaryAttack()
end