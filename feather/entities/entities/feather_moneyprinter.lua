AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Money Printer"
ENT.Author = "Black Tea"
ENT.Category = "Feather"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/consolebox01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end

		local time = GAMEMODE.MoneyPrinterTime
		timer.Simple(math.Rand(time[1], time[2]), function()
			self:PrintMoney()
		end)
	end

	function ENT:GoneWrong()
		self.exploding = true
		self:Ignite()

		timer.Simple(1, function() 
			self:Remove()
		end)
	end

	function ENT:PrintMoney()
		local time = GAMEMODE.MoneyPrinterTime
		GAMEMODE:CreateMoney(self:GetPos() + self:OBBCenter() + self:GetUp()*25, self:GetAngles(), 200)

		local dice = math.Rand(0, 100)
		if dice < 1 then
			self:GoneWrong()
		end

		timer.Simple(math.Rand(time[1], time[2]), function()
			if !self:IsValid() or self.exploding then 
				return
			end
			
			self:PrintMoney()
		end)
	end

	function ENT:Use(activator)
	end
else
	/*
	function ENT:DrawTargetID(x, y, alpha)
		nut.util.DrawText(x, y, nut.currency.GetName(self:GetNetVar("amount", 0), true), Color(255, 255, 255, alpha))
	end
	*/
end