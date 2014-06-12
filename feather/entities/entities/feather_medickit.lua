AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Medic Kit"
ENT.Author = "Black Tea"
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/HealthKit.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:Heal(client, amt)
		GAMEMODE:FadeScreen(client, Color(0, 255, 0, 150), 2)

		client:SetHealth(math.Clamp(client:Health() + amt, 0, client:GetMaxHealth()))
	end

	function ENT:Use(activator)
		if (activator:Health() >= activator:GetMaxHealth() or self.activated) then
			return
		end

		self.activated = true
		activator:EmitSound("weapons/slam/mine_mode.wav")
		timer.Simple(.3, function()
			if (activator:IsValid() and activator:Alive()) then
				activator:EmitSound("items/smallmedkit1.wav")
				self:Heal(activator, 50)
				self:Remove()
			end
		end)

	end
else
	function ENT:DrawScreen()
		local origin = self:GetPos() + self:GetUp()*2
		local pos = (origin):ToScreen()
		local alpha = math.Clamp((1 - origin:DistToSqr(EyePos()) / 256^2) * 255, 0, 255)

		local text = self.PrintName
		draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0, alpha), 1, 1)
		draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255, alpha), 1, 1)
	end
end