AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Money Printer"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/consolebox01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetDTBool(0, false)
		self.health = 100

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end

		local time = feather.config.get("printerTime")
		timer.Simple(math.Rand(time[1], time[2]), function()
			if (self:IsValid()) then
				self:PrintMoney()
			end
		end)
	end

	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self.health = self.health - damage

		if (self.health < 0) then
			local effectData = EffectData()
			effectData:SetStart(self:GetPos())
			effectData:SetOrigin(self:GetPos())
				
			util.Effect("Explosion", effectData, true, true)
			self:Remove()
		end
	end

	function ENT:GoneWrong()
		self.exploding = true
		self:Ignite(3)

		timer.Simple(3, function() 
			if (!self:IsValid()) then return end
			local effectData = EffectData()
			effectData:SetStart(self:GetPos())
			effectData:SetOrigin(self:GetPos())
				
			util.Effect("Explosion", effectData, true, true)
			util.BlastDamage( self, self.Owner or self, self:GetPos() + Vector( 0, 0, 1 ), 256, 120 )
			self:Remove()
		end)
	end

	function ENT:PrintMoney()
		self:SetDTBool(0, true)
		self:EmitSound("ambient/machines/combine_terminal_idle4.wav", 110, 150)
		timer.Simple(2, function()
			if (!self:IsValid()) then
				return
			end
			self:SetDTBool(0, false)
			
			local time = feather.config.get("printerTime")
			GAMEMODE:CreateMoney(self:GetPos() + self:OBBCenter() + self:GetUp()*25, self:GetAngles(), 200)

			local dice = math.Rand(0, 100)
			if (dice < feather.config.get("printExplodeRate")) then
				self:GoneWrong()
			end

			timer.Simple(math.Rand(time[1], time[2]), function()
				if (!self:IsValid() or self.exploding) then 
					return
				end
				
				self:PrintMoney()
			end)
		end)
	end

	function ENT:Use(activator)
	end
else
	function ENT:DrawTargetInfo()
		local origin = self:GetPos() + Vector(0, 0, 5)
		local pos = (origin):ToScreen()

		local text = "Money Printer"
		draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
		draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)

		if (self:GetDTBool(0)) then
			text = GetLang("printingmoney", string.rep(".", math.floor((CurTime()*2)%4)))
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y + 20, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y + 20, Color(255, 155, 155, alpha), 1, 1)
		end
	end

	local glowMaterial = Material("sprites/glow04_noz")

	function ENT:DrawTranslucent()
		local pos = self:GetPos()
		pos = pos + self:GetUp() * 8
		pos = pos + self:GetForward() * 17
		pos = pos + self:GetRight() * -12

		render.SetMaterial(glowMaterial)
		if (self:GetDTBool(0)) then
			render.DrawSprite(pos, 12, 12, Color( 44, 255, 44, alpha ) )
		else
			render.DrawSprite(pos, 12, 12, Color( 255, 44, 44, alpha ) )
		end
	end
end