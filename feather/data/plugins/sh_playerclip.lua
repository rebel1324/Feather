if SERVER then
	local playerclips = {}

	function AddPlayerBarrier( min, max )
		table.insert(playerclips, {min, max})
	end

	hook.Add("InitPostEntity", "playerclip.addass", function()
		local spawnpos, obb
		for _, vecs in ipairs(playerclips) do
			obb = (vecs[2]-vecs[1])/2
			spawnpos = vecs[1] + obb

			local c_brush = ents.Create("playerblocker")
			c_brush:SetNWVector("obb", obb)
			c_brush:SetPos(spawnpos)
			c_brush:Spawn()
			c_brush:Activate()
		end
	end)	

	AddPlayerBarrier(
		Vector(-2450.8718261719, -2658.3791503906, -203.75219726563),
		Vector(-2807.96875, -2785.8713378906, 76.21711730957))

	AddPlayerBarrier(
		Vector(256.43780517578, -2321.8654785156, -203.96875),
		Vector(-118.96875762939, -2481.6694335938, 76.795761108398))

	AddPlayerBarrier(
		Vector(64.370788574219, 2126.1313476563, -203.96875),
		Vector(415.96875, 2257.7214355469, 76.078186035156))

	AddPlayerBarrier(
		Vector(2416.1408691406, 2087.0249023438, -203.96875),
		Vector(2733.96875, 2202.0766601563, 76.699752807617))
end