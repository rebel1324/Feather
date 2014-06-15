AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Package Destination"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 30)
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/TrashDumpster01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end

	function ENT:Use(activator)
	end

	function ENT:StartTouch(entity)
		if (entity:GetClass() == "feather_job_pckobj") then
			local client = entity.owner
			local dest = entity.dest
			if client and client:IsValid() and dest == self then
				if client:GetMission() == "package" then
					GAMEMODE:OnMissionComplete(client, "package")
				end
			end
		end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS // To not get blocked
	end
else
	local icon = surface.GetTextureID("vgui/notices/generic")
	function ENT:DrawScreen(w, h)
		local pck = LocalPlayer():GetLocalVar("dest")
		if pck and pck == self:EntIndex() then
			local sc = self:GetPos():ToScreen()
			local sx, sy, visible = sc.x, sc.y, sc.visible
			sx = math.Clamp(sx, h*.1, w - h*.1)
			sy = math.Clamp(sy, h*.1, h - h*.1)

			local text = GetLang"deliverydest"
			local tx, ty = draw.SimpleText(text, "fr_VoteFontShadow", sx, sy, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_VoteFont", sx, sy, Color(255, 255, 255, alpha), 1, 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(icon)
			local size = 16*1.5
			surface.DrawTexturedRect(math.Round(sx-size/2), math.Round(sy-size/2) - ty - 10, size, size)
		end
	end
end