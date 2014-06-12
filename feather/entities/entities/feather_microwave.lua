AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Microwave"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.FoodStock = "chinese"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props/cs_office/microwave.mdl")
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
		return (self.Owner or self:GetNetVar("owner"))
	end

	function ENT:Use(activator)
		if (!self:GetDTBool(0)) then
			if (self.Owner != activator) then
				if activator:PayMoney(self:GetNetVar("price"), nil, GetLang("purchase", "Food", MoneyFormat(self:GetNetVar("price", 0)))) == false then
					return false
				end
			end

			if (self.Owner and self.Owner:IsValid()) then
				local price = GAMEMODE:GetFood(self.FoodStock).price
				local profit = self:GetNetVar("price") - price

				if (self.Owner:PayMoney(price) == false) then
					return false
				end

				if (activator != self.Owner) then
					if (profit < 0) then
						self.Owner:notify(GetLang("toocheap", MoneyFormat(-profit)))
					else
						self.Owner:notify(GetLang("moneyearn", MoneyFormat(profit)))
					end
				end
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
		local pos = self:GetPos()
		pos = pos + self:GetUp() * 8
		pos = pos + self:GetForward() * 2.5	
		pos = pos + self:GetRight() * -11

		local entity = ents.Create("feather_food")
		entity:SetPos(pos)
		entity:SetAngles(AngleRand())
		entity:Spawn()
		entity:Activate()

		entity:SetFood(self.FoodStock)
	end

	function ENT:OnRemove()
		self.GenerateSound:Stop()
	end
else
	local glowMaterial = Material("sprites/glow04_noz")

	function ENT:DrawTranslucent()
		local pos = self:GetPos()
		pos = pos + self:GetUp() * 14
		pos = pos + self:GetForward() * -12.5	
		pos = pos + self:GetRight() * -11

		render.SetMaterial(glowMaterial)
		if (!self:GetDTBool(0)) then
			render.DrawSprite(pos, 16, 16, Color( 44, 255, 44, alpha ) )
		else
			render.DrawSprite(pos, 16, 16, Color( 255, 44, 44, alpha ) )
		end
	end

	function ENT:DrawScreen()
		local origin = self:GetPos() + Vector(0, 0, 25)
		local pos = (origin):ToScreen()
		local alpha = math.Clamp((1 - origin:DistToSqr(EyePos()) / 256^2) * 255, 0, 255)

		if (alpha > 0) then
			local text = self.PrintName
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, Color(255, 255, 255, alpha), 1, 1)

			pos.y = pos.y + 22
			text = GetLang("price", MoneyFormat(self:GetNetVar("price", 0)))
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, Color(255, 255, 255, alpha), 1, 1)

			local data = GAMEMODE:GetFood(self.FoodStock)
			if (data and self:GetNetVar("owner") == LocalPlayer()) then
				pos.y = pos.y + 22
				local profit = self:GetNetVar("price") - GAMEMODE:GetFood(self.FoodStock).price
				text = GetLang("profit", MoneyFormat(profit))

				local col = Color(46, 204, 113)
				if profit <= 0 then
					col = Color(192, 57, 43)
				end
				col.a = alpha

				draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, col, 1, 1)
				draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, col, 1, 1)
			end

			if (self:GetDTBool(0)) then
				pos.y = pos.y + 22
				text = GetLang("cookingfood", string.rep(".", math.floor((CurTime()*2)%4)))
				draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, Color(0, 0, 0, alpha), 1, 1)
				draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, Color(255, 155, 155, alpha), 1, 1)
			end
		end
	end
end