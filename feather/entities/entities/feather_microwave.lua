AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Microwave"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/tv_monitor01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.foodprice = 20
		self:SetNetVar("price", 200)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end

		self.GenerateSound = CreateSound(self, "plats/heavymove1.wav")
	end

	function ENT:GetOwner()
		return self.Owner or self:GetNetVar("owner")
	end

	function ENT:Use(activator)
		if !self:GetDTBool(0) and activator:PayMoney(self:GetNetVar("price"), nil, GetLang("purchase", "Food", MoneyFormat(self:GetNetVar("price", 0))) ) then
			if self.Owner and self.Owner:IsValid() then
				self.Owner:addMoney(self:GetNetVar("price") - self.minprice)
			end

			self:EmitSound("plats/elevator_start1.wav")
			self:SetDTBool(0, true)
			self.GenerateSound:Play()

			timer.Simple(2, function()
				self:PopFood()
				self.GenerateSound:Stop()
				self:SetDTBool(0, false)
				self:EmitSound("HL1/fvox/bell.wav")
			end)
		end
	end

	function ENT:PopFood()
		local entity = ents.Create("feather_food")
		entity:SetPos(self:GetPos() + self:OBBCenter() + self:GetForward()*10)
		entity:SetAngles(AngleRand())
		entity:Spawn()
		entity:Activate()

		entity:SetFood("chinese")
	end

	function ENT:OnRemove()
		self.GenerateSound:Stop()
	end
else
	local glowMaterial = Material("sprites/glow04_noz")

	function ENT:DrawTranslucent()
		local pos = self:GetPos() + self:OBBCenter()
		pos = pos + self:GetUp() * 5
		pos = pos + self:GetForward() * 8	
		pos = pos + self:GetRight() * -8

		render.SetMaterial(glowMaterial)
		render.DrawSprite(pos, 6, 6, Color( 44, 255, 44, alpha ) )
	end

	function ENT:DrawScreen()
		local origin = self:GetPos() + Vector(0, 0, 14)
		local pos = (origin):ToScreen()
		local alpha = math.Clamp((1 - origin:DistToSqr(EyePos()) / 256^2) * 255, 0, 255)

		if alpha > 0 then
			local text = self.PrintName
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, Color(255, 255, 255, alpha), 1, 1)

			text = GetLang("price", MoneyFormat(self:GetNetVar("price", 0)))
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y + 22, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y + 22, Color(255, 255, 255, alpha), 1, 1)

			if self:GetDTBool(0) then
				text = GetLang("cookingfood", string.rep(".", math.floor((CurTime()*2)%4)))
				draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y + 44, Color(0, 0, 0, alpha), 1, 1)
				draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y + 44, Color(255, 155, 155, alpha), 1, 1)
			end
		end
	end
end