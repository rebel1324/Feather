local META = FindMetaTable("CLuaEmitter")
if not META then return end

function META:DrawAt(pos, ang, fov) // Jvs
	local pos, ang = WorldToLocal(EyePos(), EyeAngles(), pos, ang)
	cam.Start3D(pos, ang, fov)
		self:Draw()
	cam.End3D()
end