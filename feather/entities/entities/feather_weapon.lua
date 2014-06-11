AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Weapon"
ENT.Author = "Black Tea"
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/weapons/w_smg1.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:GetWeapon()
		return self:GetDTString(0)
	end

	function ENT:SetWeapon(class)
		return self:SetDTString(0, class)
	end

	function ENT:Use(activator)
		if (activator:HasWeapon(self:GetWeapon())) then
			return
		end

		activator:Give(self:GetWeapon())
		self:Remove()
	end
else
	function ENT:DrawScreen()
		local origin = self:GetPos() + self:GetUp()*2
		local pos = (origin):ToScreen()
		local alpha = math.Clamp((1 - origin:DistToSqr(EyePos()) / 256^2) * 255, 0, 255)

		local text = GetWeaponName(self:GetDTString(0))
		draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0, alpha), 1, 1)
		draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255, alpha), 1, 1)
	end
end