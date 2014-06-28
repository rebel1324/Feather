if SERVER then AddCSLuaFile() end

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.obb = self:GetNWVector("obb")

	self:InitCollision()
end

if CLIENT then
	hook.Add("PlayerAuthed", "clip.clinit", function(ply)
		for k, v in ipairs(ents.FindByClass("playerblocker")) do
			-- re-init for shit.
			v:InitCollision()
		end
	end)
end

function ENT:InitCollision()
	self:DrawShadow(false)
	self:SetCollisionBounds(-self.obb, self.obb)
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(0)
	self:SetCustomCollisionCheck(true)
	if CLIENT then
		self:SetRenderBounds(-self.obb, self.obb)
	end
end

hook.Add("ShouldCollide", "clip.colide", function(a, b)
	if a:GetClass() == "playerblocker" then
		return true
	end
end)

/*

netstream.Hook("InitClientClip", function(ent)
	local obb = self:GetNWVector("obb")
	ent:SetCollisionBounds(-obb, obb)
	ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end)
*/

function ENT:Draw()
end

/*
local matdat = {
	["$basetexture"] = "vgui/progressbar",
}
local clipmat = CreateMaterial("VisualClipMaterial", "VertexLitGeneric", matdat)
*/

function ENT:BuildMeshObj()
	self.meshobj = Mesh()

	local origin = self:GetPos()
	local up = self:GetUp()
	local right = self:GetRight()
	local forward = self:GetForward()

	local sizex = math.abs(self.obb.y)
	local sizey = math.abs(self.obb.x)
	local sizez = math.abs(self.obb.z)

	local scale = 4
	local uv = 1
	local fou = sizex / sizez * scale
	local fov = 1 * scale
	local riu = sizey / sizez * scale
	local riv = 1 * scale
	local upu = sizey / sizex * scale / 2
	local upv = 1 * scale / 2

	local verts = { -- A table of 3 vertices that form a triangle
		-- down
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = -up }, -- -+
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = upu, v = 0, normal = -up }, -- --
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = upu, v = upv, normal = -up }, -- +-

		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = upu, v = upv, normal = -up }, -- -+
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = upu, v = 0, normal = -up }, -- +-
		{ pos = origin + right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = -up }, -- ++

		-- up
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = 0, v = 0, normal = up }, -- -+
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = 0, v = upv, normal = up }, -- ++
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = upu, v = upv, normal = up }, -- +-

		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = upu, v = upv, normal = up }, -- +-
		{ pos = origin - right*sizex - forward*sizey + up*sizez, u = upu, v = 0, normal = up }, -- --
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = 0, v = 0, normal = up }, -- -+

		-- forward
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = fou, v = fov, normal = forward }, -- ++
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = 0, v = fov, normal = forward }, -- -+
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = forward }, -- --
		
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = forward }, -- --
		{ pos = origin + right*sizex + forward*sizey - up*sizez, u = fou, v = 0, normal = forward }, -- +-
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = fou, v = fov, normal = forward }, -- ++

		-- backward
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = fou, v = fov, normal = -forward }, -- ++
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -forward }, -- --
		{ pos = origin - right*sizex - forward*sizey + up*sizez, u = 0, v = fov, normal = -forward }, -- -+
		
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -forward }, -- --
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = fou, v = fov, normal = -forward }, -- ++
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = fou, v = 0, normal = -forward }, -- +-
	
		-- left
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = -right }, -- ++
		{ pos = origin - right*sizex - forward*sizey + up*sizez, u = 0, v = riv, normal = -right }, -- -+
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -right }, -- --
		
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -right }, -- --
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = riu, v = 0, normal = -right }, -- +-
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = -right }, -- ++
		
		-- right
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = right }, -- ++
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = right }, -- --
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = 0, v = riv, normal = right }, -- -+
	
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = right }, -- --
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = right }, -- ++
		{ pos = origin + right*sizex + forward*sizey - up*sizez, u = riu, v = 0, normal = right }, -- +-
	}

	self.meshobj:BuildFromTriangles( verts ) -- Load the vertices into the IMesh object
end

function ENT:DrawTranslucent()
	self.obb = self:GetNWVector("obb")
	self:SetRenderBounds(-self.obb, self.obb)
	self:SetCollisionBounds(-self.obb, self.obb)
		
	if self.obb then
		self:BuildMeshObj()
	end

	if self.meshobj then
		render.SetMaterial(Material("models/props_combine/com_shield001a"))

		self.meshobj:Draw()
	end
end

function ENT:StartTouch(ent)
	self.touchSound = self.touchSound or CreateSound(self, "ambient/machines/combine_shield_touch_loop1.wav")
	self.touchSound:Play()
end

function ENT:EndTouch(ent)
	self.touchSound:Stop()
end

function ENT:KeyValue( key, value )
end

function ENT:OnRemove()
end

function ENT:AcceptInput( inputName, activator, called, data )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end