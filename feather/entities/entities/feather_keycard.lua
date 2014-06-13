AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Keycard Detector"
ENT.Author = "Black Tea / Chessnut"
ENT.Category = "Feather"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		if !trace.Entity:IsDoor() then
			client:notify("You have to looking at the door to place license detector")

			return
		end

		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal)
		entity:SetAngles(trace.HitNormal:Angle())
		entity:Spawn()
		entity:Activate()
		entity:SetParent(trace.Entity)

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_lab/powerbox03a.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end

	function ENT:Use(activator)
	end
else
	local glowMaterial = Material("sprites/glow04_noz")

	function ENT:DrawTranslucent()
		local pos = self:GetPos() + self:OBBCenter()
		pos = pos + self:GetUp()
		pos = pos + self:GetForward() * 3
		pos = pos + self:GetRight() * -2

		render.SetMaterial(glowMaterial)
		render.DrawSprite(pos, 6, 6, Color( 44, 255, 44, alpha ) )
	end
end