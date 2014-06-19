if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Unarrest Baton"
SWEP.Author = "Black Tea"
SWEP.Instructions = "Left click to unarrest"
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

SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"
SWEP.ViewModel = "models/weapons/v_stunbaton.mdl"
SWEP.IconLetter = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

function SWEP:GetViewModelPosition(pos, ang)
	-- die
	pos = pos + self:GetRight()*-2
	return pos, ang
end


function SWEP:Reload()
end

local glowMaterial = Material("sprites/glow04_noz")
function SWEP:DrawWorldModel()
	self:DrawModel()

	local at = self:GetAttachment(1)
	local pos = at.Pos

	render.SetMaterial(glowMaterial)
	render.DrawSprite(pos, math.Rand(8, 16), math.Rand(8, 16), Color( 44, 255, 44, alpha ) )
end

function SWEP:PrimaryAttack()
	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*128
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if SERVER then
		local ply = trace.Entity

		if ply:IsPlayer() and ply:IsArrested() then
			ply:notify("You're unarrested by ".. self.Owner:Name())
			ply:UnArrest(self.Owner)
		end
	end

	self:EmitSound("Weapon_Crowbar.Single")
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_MISSCENTER)

	self:SetNextPrimaryFire(CurTime() + .5)
end

function SWEP:SecondaryAttack()
end

function SWEP:DrawHUD()
	local w, h = ScrW(), ScrH()

	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*128
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if hook.Run("CanDrawWeaponHUD") then
		draw.SimpleText(GetLang"hudunarrest", "fr_Arrested", w/2, h/2 + 35, color_white, 1, 1)
		
		if trace.Entity:IsValid() then
			if trace.Entity:IsPlayer() then
				if trace.Entity:IsArrested() then
					draw.SimpleText(GetLang("hudunarresttarget", trace.Entity:Name()), "fr_Arrested", w/2, h/2 + 60, Color(122, 255, 122), 1, 1)
				end
			end
		end
	end
end