AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Job Terminal"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos - trace.HitNormal * 10)
		entity:SetAngles(trace.HitNormal:Angle())
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_intmonitor003.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end

	function ENT:Use(activator)
	end
else
	function ENT:DrawTranslucent()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetForward(), 90)
		ang:RotateAroundAxis(self:GetRight(), 0)
		ang:RotateAroundAxis(self:GetUp(), 90)

		cam.Start3D2D(self:GetPos() + self:GetForward() * 26  + self:GetUp()*24, ang, .2)
			surface.SetDrawColor(0, 0, 0, 230)
			local size = 170
			surface.DrawRect(-size/2, -size*1.5/2, size, size*1.5)

			draw.SimpleText("JOB TERMINAL", "fr_LicenseBtn", 3, 3, Color(255 ,255, 255), 1, 1)
		cam.End3D2D()
	end

	function ENT:DrawScreen()
		local origin = self:GetPos() + self:GetForward() * 26 + Vector(0, 0, 40)
		local pos = (origin):ToScreen()
		local alpha = math.Clamp((1 - origin:DistToSqr(EyePos()) / 512^2) * 255, 0, 255)

		if alpha > 0 then
			local text = self.PrintName
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, Color(255, 255, 255, alpha), 1, 1)
		end
	end
end