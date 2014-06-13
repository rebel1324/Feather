AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Food"
ENT.Author = "Black Tea"
ENT.Category = "Feather"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/plasticbucket001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end

		hook.Run("OnFoodCreated", self)
	end

	function ENT:SetFood(uniqueID)
		local food = GAMEMODE:GetFood(uniqueID)

		if (food) then
			self:SetDTString(0, uniqueID)
			self:SetModel(food.model)
		end
	end

	function ENT:Use(activator)
		local food = GAMEMODE:GetFood(self:GetDTString(0))

		activator:AddHunger(food.hunger)
		self:Remove()
		hook.Run("OnEatFood", self:GetDTString(0), food, activator)
	end
else
	function ENT:DrawScreen()
		local origin = self:GetPos() + Vector(0, 0, 3)
		local pos = (origin):ToScreen()
		local alpha = math.Clamp((1 - origin:DistToSqr(EyePos()) / 256^2) * 255, 0, 255)
		local food = GAMEMODE:GetFood(self:GetDTString(0))

		if (alpha > 0) then
			local text = (food) and (food.name) or ("Food")
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255, alpha), 1, 1)
		end
	end
end