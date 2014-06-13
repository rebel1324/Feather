AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Wanted Board"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos)
		entity:SetAngles(trace.HitNormal:Angle())
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/garbage_carboard002a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end

	function ENT:Use(activator)
	end
else
	function ENT:Draw()
		self:SetRenderBounds(self:GetForward()*2 + self:GetUp()*50 + self:GetRight()*150, 
							self:GetForward()*-2 + self:GetUp()*-50 + self:GetRight()*-150)
	end
	
	function ENT:DrawTranslucent()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetForward(), 90)
		ang:RotateAroundAxis(self:GetRight(), 0)
		ang:RotateAroundAxis(self:GetUp(), 90)

		cam.Start3D2D(self:GetPos(), ang, .2)
			surface.SetDrawColor(0, 0, 0, 230)
			local size = 300
			surface.DrawRect(-size*1.5/2, -size/2, size*1.5, size)

			draw.SimpleText("DEAD OR ALIVE", "fr_License", 0, -size/2 + 10, Color(255 ,255, 255), 1, 0)

			local nums = 0
			local bx, bx2, by, rs = -size*1.5/2 + 30, size*1.5/2 - 30,-size/2 + 50, 23
			draw.RoundedBox(0, bx, by - 8, bx2 - bx, 2, color_white )
			local arst = {}
			for k, v in ipairs(player.GetAll()) do
				local time = v:IsWanted()
				if !time then continue end

				table.insert(arst, {v, time[1]})
			end

			for k, v in SortedPairsByMemberValue(arst, 2) do
				draw.SimpleText(v[1]:Name(), "fr_LicenseBtn", bx, by + nums*rs, Color(255 ,255, 255), 0, 0)
				draw.SimpleText(string.NiceTime(math.ceil(v[2] - CurTime())), "fr_LicenseBtn", bx2, by + nums*rs, Color(255 ,255, 255), 2, 0)

				nums = nums + 1
				if nums == 9 then
					draw.SimpleText("And More..", "fr_LicenseBtn", bx, by + nums*rs, Color(255 ,255, 255), 0, 0)
					break 
				end
			end
		cam.End3D2D()
	end
end