AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Shipment"
ENT.Author = "Chessnut"
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/item_item_crate.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

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

	function ENT:Use(activator)
		local data = GAMEMODE.WeaponList[self:GetContent()]

		local ent = ents.Create(data.classname)
		ent:SetPos(self:GetPos() + self:OBBCenter() + self:GetUp()*40)
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()

		self:SetAmount(self:GetAmount() - 1)

		if self:GetAmount() <= 0 then
			self:Remove()
		end
	end

	function ENT:StartTouch(entity)
		if (entity:GetClass() == "feather_shipment" and entity:GetContent() == self:GetContent()) then
			self:SetAmount(self:GetAmount() + entity:GetAmount())
			entity:Remove()
		end
	end
else
	function ENT:DrawTargetInfo()
		local origin = self:GetPos() + Vector(0, 0, 30)
		local pos = (origin):ToScreen()
		local data = GAMEMODE.WeaponList[self:GetDTString(0)]

		local text = "Weapon Shipment"
		draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
		draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)

		if data then
			pos.y = pos.y + 25
			text = data.name
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)

			pos.y = pos.y + 25
			text = "Amount : " .. self:GetDTInt(0)
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)
		end
	end
end