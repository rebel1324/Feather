AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Lost Package"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos - trace.HitNormal * 10)
		entity:SetAngles(trace.HitNormal:Angle())
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/cardboard_box001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
	end

	function ENT:Use(activator)
		local pck = LocalPlayer():GetLocalVar("package")
		if pck and pck == self:EntIndex() then
			activator:ClearMission()
		end
	end

	function ENT:Think()
		for k, v in ipairs(player.GetAll()) do
			if v then
				if (!self.nextBeep or self.nextBeep < CurTime()) then
					self:EmitSound("HL1/fvox/beep.wav") -- make beeps

					self.nextBeep = CurTime() + .5
					break
				end
			end
		end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS // To not get blocked
	end
else
	local icon = surface.GetTextureID("vgui/notices/hint")
	function ENT:DrawTargetInfo(w, h)
		local pck = LocalPlayer():GetLocalVar("package")
		if pck and pck == self:EntIndex() then
			local text = "The Lost Package"
			draw.SimpleText(text, "fr_BigTargetShadow", pos.x, pos.y , Color(0, 0, 0), 1, 1)
			draw.SimpleText(text, "fr_BigTarget", pos.x, pos.y , Color(255, 255, 255), 1, 1)
		end
	end
end