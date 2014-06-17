AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "The Garbage"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.noGrab = true
ENT.ModelTable = {
	"models/props_interiors/Furniture_Couch02a.mdl",
	"models/props_interiors/Furniture_Desk01a.mdl",
	"models/props_c17/FurnitureCouch002a.mdl",
	"models/props_c17/FurnitureDrawer001a.mdl",
	"models/props_interiors/Furniture_Vanity01a.mdl",
}

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 40)
		entity:Spawn()
		entity:Activate()
		entity.dev = true

		return entity
	end

	function ENT:Initialize()
		self:SetModel(table.Random(self.ModelTable))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self.health = 150
		local ang = AngleRand()
		ang.r = 0
		ang.p = 0
		self:SetAngles(ang)

		local p = self:GetPhysicsObject()
		if (p and p:IsValid()) then
			p:Wake()
		end
	end

	function ENT:Use(activator)
	end

	function ENT:OnTakeDamage(dmginfo)
		local client = dmginfo:GetAttacker()

		if (client:GetClass() != "player") then
			return
		end

		if self.dev then
			self:Remove()
			return
		end

		local grb = client:GetLocalVar("garbages")
		if grb and table.HasValue(grb, self) then
			local dmg = dmginfo:GetDamage()
			self:EmitSound(Format("physics/wood/wood_plank_break%s.wav", math.random(1,3)))
			self.health = self.health - dmg

			if self.health <= 0 then
				for k, v in ipairs(grb) do
					if (v == self) then
						table.remove(grb, k)
					end
				end

				local amt = #grb
				if (amt == 0) then
					client:ClearMission()
				else
					client:notify(GetLang("garbageleft", amt))
					client:SetLocalVar("garbages", grb)
				end

				self:Remove()
			end
		end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS // To not get blocked
	end
else
	function ENT:OnRemove()
		local e = EffectData()
		e:SetStart(self:GetPos() + self:OBBCenter())
		util.Effect( "FeatherDestroy", e )
		self:EmitSound(Format("physics/wood/wood_crate_break%s.wav", math.random(1, 5)))
	end
	
	local icon = surface.GetTextureID("vgui/notices/cleanup")
	function ENT:DrawScreen(w, h)
		local grb = LocalPlayer():GetLocalVar("garbages")
		if grb and table.HasValue(grb, self) then
			local sc = self:GetPos():ToScreen()
			local sx, sy, visible = sc.x, sc.y, sc.visible
			sx = math.Clamp(sx, h*.1, w - h*.1)
			sy = math.Clamp(sy, h*.1, h - h*.1)

			local text = GetLang"garbage"
			local tx, ty = draw.SimpleText(text, "fr_VoteFontShadow", sx, sy, Color(0, 0, 0, alpha), 1, 1)
			draw.SimpleText(text, "fr_VoteFont", sx, sy, Color(255, 255, 255, alpha), 1, 1)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(icon)
			local size = 16*1.5
			surface.DrawTexturedRect(math.Round(sx-size/2), math.Round(sy-size/2) - ty - 10, size, size)
		end
	end
end