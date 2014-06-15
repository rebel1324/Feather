AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Shipment"
ENT.Author = "Black Tea"
ENT.Category = "Feather"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/item_item_crate.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.health = 100

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end

		hook.Run("OnShipmentSpawned", self)
	end

	function ENT:GetContent()
		return self:GetDTString(0)
	end

	function ENT:GetAmount()
		return self:GetDTInt(0)
	end

	function ENT:SetContent(str)
		self:SetDTString(0, str)
	end

	function ENT:SetAmount(amount)
		self:SetDTInt(0, amount)
	end

	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self.health = self.health - damage

		if (self.health < 0) then
			local data = GAMEMODE.WeaponList[self:GetContent()]
			for i = 1, math.Clamp(self:GetAmount(), 0, 5) do
				GAMEMODE:SpawnWeapon(self:GetPos() + self:OBBCenter() + self:GetUp()*40 + VectorRand()*10, Angle(0, 0, 0), data.classname)
				self:GibBreakServer(VectorRand()*100)
				self:Remove()
			end
		end
	end

	function ENT:OpenShipment()
		local data = GAMEMODE.WeaponList[self:GetContent()]

		if !data.entity then
			GAMEMODE:SpawnWeapon(self:GetPos() + self:OBBCenter() + self:GetUp()*40, Angle(0, 0, 0), data.classname)
		else
			ent = ents.Create(data.classname)
			ent:SetPos(self:GetPos() + self:OBBCenter() + self:GetUp()*40)
			ent:SetAngles(Angle(0, 0, 0))
			ent:Spawn()
		end

		self:SetAmount(self:GetAmount() - 1)

		if (self:GetAmount() <= 0) then
			self:Remove()
		end
	end
	
	function ENT:Use(activator)
		if (self:GetDTBool(0)) then
			return
		end

		self:SetDTBool(0, true)
		self:EmitSound("items/ammocrate_open.wav")

		timer.Simple(1, function()
			if (!self:IsValid()) then
				return
			end

			self:EmitSound("items/ammo_pickup.wav")
			self:OpenShipment()
			self:SetDTBool(0, false)
		end)
	end

	function ENT:StartTouch(entity)
		if (entity:GetClass() == "feather_shipment" and entity:GetContent() == self:GetContent()) then
			self:SetAmount(self:GetAmount() + entity:GetAmount())
			entity:Remove()
		end
	end
else
	function ENT:DrawTargetInfo()
		local origin = self:GetPos() + self:GetUp()*30
		local pos = (origin):ToScreen()
		local data = GAMEMODE.WeaponList[self:GetDTString(0)]

		local text = data.name .. " Shipment"
		draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
		draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)

		if (data) then
			pos.y = pos.y + 25
			text = data.name
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)

			pos.y = pos.y + 25
			text = "Amount : " .. self:GetDTInt(0)
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)
		end

		if (self:GetDTBool(0)) then
			pos.y = pos.y + 22
			text = GetLang("opening", string.rep(".", math.floor((CurTime()*2)%4)))
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y, Color(52, 152, 219, alpha), 1, 1)
		end
	end
end