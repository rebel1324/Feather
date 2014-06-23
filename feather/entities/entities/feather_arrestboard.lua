AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Arrest Board"
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
		self:SetModel("models/props_junk/garbage_metalcan002a.mdl")
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
	local size = 1000
	local scale = .06
	function ENT:Draw()
		local bnd = size * scale * .5
		self:SetRenderBounds(self:GetForward()*1 + self:GetUp()*bnd + self:GetRight()*bnd*1.5, 
							self:GetForward()*-1 + self:GetUp()*-bnd + self:GetRight()*-bnd*1.5)
	end
	
	function ENT:DrawTranslucent()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetForward(), 90)
		ang:RotateAroundAxis(self:GetRight(), 0)
		ang:RotateAroundAxis(self:GetUp(), 90)

		cam.Start3D2D(self:GetPos(), ang, scale)
			surface.SetDrawColor(0, 0, 0, 230)
			surface.DrawRect(-size*1.5/2, -size/2, size*1.5, size)

			draw.SimpleText("ARRESTED CONVICTS", "fr_3d2dTextTitle", 0, -size/2 + 20, Color(255 ,255, 255), 1, 0)

			local nums = 0
			local bx, bx2, by, rs = -size*1.5/2 + 80, size*1.5/2 - 80,-size/2 + 170, 60

			draw.RoundedBox(0, bx, by - 20, bx2 - bx, 4, color_white )

			local arst = {}
			for k, v in ipairs(player.GetAll()) do
				local time = v:IsArrested()
				if !time then continue end

				table.insert(arst, {v, time})
			end

			if (#arst > 0) then
				for k, v in SortedPairsByMemberValue(arst, 2) do
					local h = 60
					local time = v[1]:GetNetVar("arrested", 0)
					local timeArrested = time - feather.config.get("arrestTime")
					local timeLeft = math.ceil(v[2] - CurTime())
					local color = color_white
					local fraction = 1 - math.TimeFraction(timeArrested, time, CurTime())

					if (timeLeft <= 30) then
						local delta = 255 - math.abs(math.sin(RealTime() * 2) * 255)

						color = Color(255, delta, delta)
					end

					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(bx, by + nums*rs, bx2 - bx, h)

					surface.SetDrawColor(255 * fraction, 255 - (255 * fraction), 0, 25)
					surface.DrawRect(bx, by + nums*rs, (bx2 - bx) * fraction, h)

					draw.SimpleText(v[1]:Name(), "fr_3d2dTextContext", bx, by + nums*rs, team.GetColor(v[1]:Team()), 0, 0)
					draw.SimpleText(string.ToMinutesSeconds(timeLeft), "fr_3d2dTextContext", bx2, by + nums*rs, color, 2, 0)

					nums = nums + 1
					if (nums == 12) then
						draw.SimpleText("And More..", "fr_3d2dTextContext", bx, by + nums*rs, Color(255 ,255, 255), 0, 0)
						break 
					end
				end
			else
				draw.SimpleText("There are currently no arrests :)", "fr_3d2dTextContext", bx, by, color_white, 0, 0)
			end
		cam.End3D2D()
	end
end