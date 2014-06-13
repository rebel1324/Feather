AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Law Board"
ENT.Author = "Black Tea"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.allowphys = true

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos - trace.HitNormal * -80)
		entity:Spawn()
		entity:Activate()
		entity:SetNetVar("owner", client)

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props/cs_assault/Billboard.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:Use(activator)
	end
else
	function ENT:DrawTranslucent()
		local ang = self:GetAngles()
		local pos = self:GetPos() + self:GetForward() * 1 
		ang:RotateAroundAxis(self:GetForward(), 90)
		ang:RotateAroundAxis(self:GetRight(), 0)
		ang:RotateAroundAxis(self:GetUp(), 90)

		local scale = .1
		local size = 580*2
		local tx, ty = 0, -size/2 + 30
		local lw, lh = size*1.7, 5

		local up = self:GetUp()
		local right = self:GetRight()
		local forward = self:GetForward()
		local ch = up*size*0.5*scale
		local cw = right*lw*0.5*scale

		cam.Start3D2D(pos, ang, scale)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-size*2/2, -size/2, size*2, size)
			draw.SimpleText("LAW OF THE LAND", "fr_3d2dTextTitle", tx, ty, Color(255 ,255, 255), 1, 0)
			ty = ty + 150
			draw.RoundedBox(0, -lw/2, ty, lw, 5, color_white )
		cam.End3D2D()

		render.PushCustomClipPlane(up, up:Dot( pos-ch ))
		render.PushCustomClipPlane(-up, (-up):Dot( pos+ch ))
		render.PushCustomClipPlane(right, right:Dot( pos-cw ))
		render.PushCustomClipPlane(-right, (-right):Dot( pos+cw ))
		render.EnableClipping( true )
			cam.Start3D2D(pos, ang, scale)
				tx = -lw/2
				ty = ty - 40
				local i = 0
				for k, v in ipairs(GAMEMODE.DefaultLaws) do
					ty = ty + 60
					i = i + 1
					draw.SimpleText(i .. ". " .. v, "fr_3d2dTextContext", tx, ty, Color(255 ,255, 255), 0, 0)
				end
				if GAMEMODE.CustomLaws then
					for k, v in ipairs(GAMEMODE.CustomLaws) do
						ty = ty + 60
						i = i + 1
						draw.SimpleText(i .. ". " .. v, "fr_3d2dTextContext", tx, ty, Color(255 ,255, 255), 0, 0)
					end
				end
			cam.End3D2D()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.EnableClipping( false )
	end
end