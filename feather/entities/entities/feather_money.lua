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
			activator:giveMoney(amount)
			activator:notify("You have picked up ".. amount ..".")

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
	/*
	function ENT:DrawTargetID(x, y, alpha)
		nut.util.DrawText(x, y, nut.currency.GetName(self:GetNetVar("amount", 0), true), Color(255, 255, 255, alpha))
	end
	*/
end