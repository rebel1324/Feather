AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Ammo"
ENT.Author = "Black Tea"
ENT.Category = "Feather"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/BoxSRounds.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end

		timer.Simple(feather.config.get("entityRemoveTime"), function()
			if self:IsValid() then
				self:Remove()
			end
		end)
	end

	function ENT:SetAmmo(class, amount)
		self:SetNetVar("ammo", class)
		self:SetNetVar("amount", amount)

		if amount <= 0 then
			self:Remove()
		end
	end

	function ENT:Use(activator)
		activator:GiveAmmo(self:GetNetVar("amount", 0), self:GetNetVar("ammo"))
		self:Remove()
	end
end