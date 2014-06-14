if SERVER then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Medic Kit"
SWEP.Author = "Black Tea"
SWEP.Instructions = "Left click to heal"
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

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*(64*1.3)
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if SERVER then
		local ply = trace.Entity

		if (!ply or !ply:IsValid()) then
			return
		end

		if (ply:Health() == ply:GetMaxHealth()) then
			return
		end

		self.Owner:EmitSound("weapons/slam/mine_mode.wav")
		timer.Simple(.3, function()
			if (self.Owner:IsValid() and self.Owner:Alive()) then
				self.Owner:EmitSound("items/smallmedkit1.wav")
			end
		end)

		if (ply:IsPlayer()) then
			self:Heal(ply, 10)
			self:SetNextPrimaryFire(CurTime() + 2)
			return
		end
	end

	self:SetNextPrimaryFire(CurTime() + .5)
end

function SWEP:Heal(client, amt)
	GAMEMODE:FadeScreen(client, Color(0, 255, 0, 150), 2)

	client:SetHealth(math.Clamp(client:Health() + amt, 0, client:GetMaxHealth()))
end

function SWEP:SecondaryAttack()
	if SERVER then
		local ply = self.Owner

		if (ply:Health() == ply:GetMaxHealth()) then
			return
		end
		
		self.Owner:EmitSound("weapons/slam/mine_mode.wav")
		timer.Simple(.3, function()
			if (self.Owner:IsValid() and self.Owner:Alive()) then
				self.Owner:EmitSound("items/smallmedkit1.wav")
			end
		end)

		if (ply:IsPlayer()) then
			self:Heal(ply, 5)
			self:SetNextSecondaryFire(CurTime() + 2)
			return
		end
	end

	self:SetNextSecondaryFire(CurTime() + .5)
end

function SWEP:DrawHUD()
	local w, h = ScrW(), ScrH()

	local td = {}
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + self.Owner:GetAimVector()*64
		td.filter = self.Owner
	local trace = util.TraceLine(td)

	if hook.Run("CanDrawWeaponHUD") then
		local posx, posy = w/2, h/2
		posy = posy + 35
		draw.SimpleText(GetLang"hudheal", "fr_Arrested", posx, posy, color_white, 1, 1)
		posy = posy + 25
		draw.SimpleText(GetLang"hudhealsec", "fr_Arrested", posx, posy, color_white, 1, 1)

		if trace.Entity:IsValid() then
			if trace.Entity:IsPlayer() then
				posy = posy + 25
				draw.SimpleText(GetLang("hudhealtarget", trace.Entity:Name(), string.NiceTime(feather.config.get("arrestTime"))), "fr_Arrested", posx, posy, Color(46, 204, 113), 1, 1)
			end
		end
	end
end