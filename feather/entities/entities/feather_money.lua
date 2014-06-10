AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Money"
ENT.Author = "Black Tea / Chessnut"
ENT.Category = "Feather"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel(GAMEMODE.MoneyModel)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end

		hook.Run("MoneyEntityCreated", self)
	end

	function ENT:SetMoney(amount)
		if (amount <= 0) then
			self:Remove()
		end

		self:SetDTInt(0, amount)
	end

	function ENT:Use(activator)
		local amount = self:GetDTInt(0) or 0

		if (amount >= 0 and IsValid(activator) and hook.Run("PlayerCanPickupMoney", activator, self) != false) then
			activator:GiveMoney(amount)
			activator:notify(GetLang("moneyfound", MoneyFormat(amount)))

			self:Remove()
		end
	end

	function ENT:StartTouch(entity)
		if (entity:GetClass() == "feather_money") then
			self:SetMoney(self:GetDTInt(0, "amount") + entity:GetDTInt(0, "amount"))
			entity:Remove()
		end
	end
else
	function ENT:DrawTargetInfo()
		local origin = self:GetPos() + Vector(0, 0, 3)
		local pos = (origin):ToScreen()

		local text = MoneyFormat(self:GetDTInt(0, "amount"))
		draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
		draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)
	end
end