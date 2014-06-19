if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Stun Stick"
SWEP.Author = "Black Tea"
SWEP.Instructions = "Left click to unarrest"
SWEP.Slot = 0
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
	pos = pos
	return pos, ang
end


function SWEP:Reload()
end

local glowMaterial = Material("sprites/glow04_noz")
function SWEP:DrawWorldModel()
	self:DrawModel()

	local at = self:GetAttachment(1)
	local pos = at.Pos + at.Ang:Forward()*-1
	if (self:IsValid()) then
		self:DrawSparks(pos, at.Ang, 1)
	end
end

function SWEP:PostDrawViewModel(vm, client, weapon)
	if (vm and vm:IsValid()) then
		local at = vm:GetAttachment(1)
		local pos = at.Pos
		self:DrawSparks(pos, at.Ang, 2, true)
	end
end

function SWEP:DrawSparks(pos, ang, scale, view)
	render.SetMaterial(glowMaterial)
	if (!view) then
		render.DrawSprite(pos, math.Rand(8, 16), math.Rand(8, 16), Color( 85, 100, 255, alpha ) )
	end

	self.emitter = self.emitter or ParticleEmitter(Vector(0, 0, 0))
	self.emitter:DrawAt(pos, Angle(0, 0, 0))

	if !self.nextEmit or self.nextEmit < CurTime() then
		for i = 1, 5 do
			local spark = self.emitter:Add("effects/spark", VectorRand()*.5)
			spark:SetVelocity(VectorRand()*20)
			spark:SetDieTime(math.Rand(.05,.1))
			spark:SetStartAlpha(math.Rand(222,255))
			spark:SetStartSize(math.random(1,2)*scale)
			spark:SetEndSize(0*scale)
			spark:SetStartLength(0*scale)
			spark:SetEndLength(5*scale)
			spark:SetRoll(math.Rand(180,480))
			spark:SetRollDelta(math.Rand(-3,3))
			spark:SetGravity( Vector( 0, 0, -100 ) )
			spark:SetAirResistance(0)
		end

		for i = 1, 2 do
			local spark = self.emitter:Add("sprites/glow04_noz", VectorRand()*2*scale)

			spark:SetDieTime(math.Rand(.01,.1))
			spark:SetStartAlpha(math.Rand(222,255))
			spark:SetStartSize(math.random(1,5)*scale)
			spark:SetEndSize(0*scale)
			spark:SetRoll(math.Rand(180,480))
			spark:SetRollDelta(math.Rand(-3,3))
			spark:SetAirResistance(0)
		end

		self.nextEmit = CurTime() + .1
	end
end

function SWEP:PrimaryAttack()
	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*128
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if (SERVER) then
		local entity = trace.Entity
 	
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker( self.Owner or self )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( math.random( 15, 30 ) )
	
		timer.Simple(.15, function()
			if (self and self.Owner:IsValid() and self.Owner:Alive() and entity:IsValid()) then
				entity:EmitSound("weapons/stunstick/stunstick_impact1.wav")
				if (entity:IsPlayer() or entity:IsNPC()) then
					dmginfo:SetDamage( math.random( 1, 2 ) )
					local v = self.Owner:GetAimVector()*(300)
					v.z = v.z/10
					entity:SetVelocity(v)
				else
					local phys = entity:GetPhysicsObject()
					if (phys and phys:IsValid()) then
						phys:SetVelocity(self.Owner:GetAimVector()*300)
					end
				end
				entity:TakeDamageInfo( dmginfo )
			end
		end)
	end

	self:EmitSound("Weapon_Crowbar.Single")
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_MISSCENTER)

	self:SetNextPrimaryFire(CurTime() + .5)
end

function SWEP:SecondaryAttack()
end
