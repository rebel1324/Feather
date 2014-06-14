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

SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "Feather"
SWEP.HoldType = "normal"

SWEP.WorldModel = "models/weapons/w_bugbait.mdl"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.IconLetter = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:GetViewModelPosition(pos, ang)
	-- die
	pos.z = 35575
	return pos, ang
end

function SWEP:Reload()
end

function SWEP:Lock(ent)
	ent:EmitSound("doors/door_latch1.wav")
	ent:Fire("lock")
	ent.locked = true
	self.Owner:notify(GetLang"lockdoor")
end

function SWEP:Unlock(ent)
	ent:EmitSound("doors/door_latch3.wav")
	ent:Fire("unlock")
	ent.locked = false
	self.Owner:notify(GetLang"unlockdoor")
end

if SERVER then 
	function SWEP:PrimaryAttack()
		local td = {}
			td.start = self.Owner:GetShootPos()
			td.endpos = td.start + self.Owner:GetAimVector()*128
			td.filter = self.Owner
		local trace = util.TraceLine(td)
		local ent = trace.Entity

		if (ent and ent:IsValid()) then
			if (ent:IsDoor()) then
				local str = type(ent:GetDoorOwners()):lower()
				if str == "string" then
					local group = GAMEMODE.DoorGroup[ent:GetDoorOwners()]
					if group and group.canuse(self.Owner) then
						self:Lock(ent)

						netstream.Start(player.GetAll(), "FeatherAnimation", {self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true})
						self:SetNextPrimaryFire(CurTime() + 1)
					end
				else
					if (ent:GetDoorOwner() != self.Owner) then
						ent:EmitSound("physics/wood/wood_crate_impact_hard2.wav", 160, 110)

						netstream.Start(player.GetAll(), "FeatherAnimation", {self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true})
					else
						self:Lock(ent)

						netstream.Start(player.GetAll(), "FeatherAnimation", {self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true})
						self:SetNextPrimaryFire(CurTime() + 1)
					end
				end
			else

			end
		end
	end

	function SWEP:SecondaryAttack()
		local td = {}
			td.start = self.Owner:GetShootPos()
			td.endpos = td.start + self.Owner:GetAimVector()*128
			td.filter = self.Owner
		local trace = util.TraceLine(td)
		local ent = trace.Entity

		if (ent and ent:IsValid()) then
			if (ent:IsDoor()) then
				local str = type(ent:GetDoorOwners()):lower()
				if str == "string" then
					local group = GAMEMODE.DoorGroup[ent:GetDoorOwners()]
					if group and group.canuse(self.Owner) then
						self:Unlock(ent)

						netstream.Start(player.GetAll(), "FeatherAnimation", {self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true})
						self:SetNextSecondaryFire(CurTime() + 1)
					end
				else
					if (ent:GetDoorOwner() != self.Owner) then
						ent:EmitSound("physics/wood/wood_crate_impact_hard2.wav", 160, 110)

						netstream.Start(player.GetAll(), "FeatherAnimation", {self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true})
					else
						self:Unlock(ent)

						netstream.Start(player.GetAll(), "FeatherAnimation", {self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true})
						self:SetNextSecondaryFire(CurTime() + 1)
					end
				end
			else

			end
		end
	end
else
	function SWEP:PrimaryAttack()
	end
	function SWEP:SecondaryAttack()
	end
	netstream.Hook("FeatherAnimation", function(data)
		local target = data[1]

		target:AnimRestartGesture(data[2], data[3], data[4])
	end)
end