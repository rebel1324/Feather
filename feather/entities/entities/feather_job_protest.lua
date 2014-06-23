AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Protest Pane"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 10)
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_lab/filecabinet02.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:Wake()
		end
	end

	function ENT:Think()
		local owner = self.owner
		if owner and owner:IsValid() then
			local dist = owner:GetPos():Distance(self:GetPos())
			if dist > 128 then
				return
			end
		else
			self:Remove()
		end

		if (!self.nextTime or self.nextTime < CurTime()) then
			local time = self:GetNetVar("time", 60) 
			self:SetNetVar("time", time - 1)

			if time <= 1 then
				owner:ClearMission()
			end
		end

		self:NextThink(CurTime() + 1)
		return true
	end

	function ENT:Use(activator)
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS // To not get blocked
	end
else
	local icon = surface.GetTextureID("vgui/notices/hint")
	function ENT:Draw()
		self.panel = self.panel or ClientsideModel("models/props_lab/bewaredog.mdl")
		if self.panel:IsValid() then
			self.panel:SetPos(self:GetPos())
			self.panel:SetRenderOrigin(self:GetPos())
			self.panel:SetNoDraw(false)
			local ang = self:GetAngles()
			ang.p = 0 ang.r = 0
			self.panel:SetAngles(ang)
			self.panel:SetRenderAngles(ang)
			self.panel:SetMaterial("models/debug/debugwhite")
		end
	end

	local scale = .05
	local size = 500
	function ENT:DrawTranslucent()
		local p = self.panel
		if p and p:IsValid() then
			local pos = p:GetRenderOrigin()
			local lvec = Vector( 1, -.5, 28.62 )
			local f, r, u = p:GetForward(), p:GetRight(), p:GetUp()
			pos = pos + f * lvec.x
			pos = pos + r * lvec.y
			pos = pos + u * lvec.z

			local ang = p:GetRenderAngles()
			ang:RotateAroundAxis(u, 85)
			ang:RotateAroundAxis(f, 2.5)
			ang:RotateAroundAxis(r, -85)

			cam.Start3D2D(pos, ang, scale)
				draw.SimpleText(self:GetNetVar("word", "Loading"), "fr_3d2dTextContext", 0, 0, color_white, 1, 1)
			cam.End3D2D()
		end
	end

	function ENT:OnRemove()
		if self.panel and self.panel:IsValid() then
			self.panel:Remove()
		end
	end
	
	function ENT:DrawScreen(w, h)
		local pck = LocalPlayer():GetLocalVar("panel")
		if pck and pck == self:EntIndex() then
			local sc = self:GetPos():ToScreen()
			local sx, sy, visible = sc.x, sc.y, sc.visible
			sx = math.Clamp(sx, h*.1, w - h*.1)
			sy = math.Clamp(sy, h*.1, h - h*.1)

			local text = "Hold: " .. self:GetNetVar("time", 60) 
			local tx, ty = draw.SimpleText(text, "fr_VoteFontShadow", sx, sy, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_VoteFont", sx, sy, Color(255, 255, 255, alpha), 1, 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(icon)
			local size = 16*1.5
			surface.DrawTexturedRect(math.Round(sx-size/2), math.Round(sy-size/2) - ty - 10, size, size)
		end
	end
end