AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "The Package"
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
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS // To not get blocked
	end
else
	local icon = surface.GetTextureID("vgui/notices/hint")
	function ENT:DrawScreen(w, h)
		local pck = LocalPlayer():GetLocalVar("package")
		if pck and pck == self:EntIndex() then
			local sc = self:GetPos():ToScreen()
			local sx, sy, visible = sc.x, sc.y, sc.visible
			sx = math.Clamp(sx, h*.1, w - h*.1)
			sy = math.Clamp(sy, h*.1, h - h*.1)

			local text = GetLang"deliveryobj"
			local tx, ty = draw.SimpleText(text, "fr_VoteFontShadow", sx, sy, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_VoteFont", sx, sy, Color(255, 255, 255, alpha), 1, 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(icon)
			local size = 16*1.5
			surface.DrawTexturedRect(math.Round(sx-size/2), math.Round(sy-size/2) - ty - 10, size, size)
		end
	end
end