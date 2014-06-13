AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "License Terminal"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_interface002.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end

	function ENT:Use(activator)
		netstream.Start(activator, "LicenseMachine")
	end
else
	function ENT:DrawScreen()
		local origin = self:GetPos() + Vector(0, 0, 50)
		local pos = (origin):ToScreen()
		local alpha = math.Clamp((1 - origin:DistToSqr(EyePos()) / 512^2) * 255, 0, 255)

		if alpha > 0 then
			local text = self.PrintName
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, Color(255, 255, 255, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, Color(0, 0, 0, alpha), 1, 1)
		end
	end
end