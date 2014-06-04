local color = Color(255, 236, 12, 255)
local deltaMoney = 500

local OFFSET_CROUCH = Vector(0, 0, -16)
local OFFSET_NORMAL = Vector(0, 0, 16)

function GM:HUDPaint()
	local teamID = LocalPlayer():Team()

	draw.SimpleText("Money: $"..LocalPlayer():getMoney(), "BudgetLabel", 8, 8, color_white, 0, 0)
	draw.SimpleText("Salary: $"..(self.Jobs[teamID] and self.Jobs[teamID].salary or 0), "BudgetLabel", 8, 24, color_white, 0, 0)
	draw.SimpleText("Job: "..team.GetName(teamID), "BudgetLabel", 8, 40, color_white, 0, 0)

	local position = LocalPlayer():GetPos()
	local shootPos = LocalPlayer():GetShootPos()
	local aimVector = LocalPlayer():GetAimVector()

	for k, v in ipairs(player.GetAll()) do
		if (v != LocalPlayer() and v:Alive()) then
			local theirShootPos = v:GetShootPos()
			local origin = theirShootPos + (v:Crouching() and OFFSET_CROUCH or OFFSET_NORMAL)
			local alpha = (1 - origin:DistToSqr(position) / 262144) * 255 + 150

			if (alpha > 0) then
				local trace = util.TraceLine({
					start = shootPos,
					endpos = theirShootPos,
				})

				if (trace.Hit and trace.Entity != v) then continue end

				local position = origin:ToScreen()
				local color = team.GetColor(v:Team())
				color.a = alpha

				draw.SimpleText(v:Name(), "fr_BigTargetShadow", position.x, position.y, Color(0, 0, 0, alpha), 1, 1)
				draw.SimpleText(v:Name(), "fr_BigTarget", position.x, position.y, color, 1, 1)
			end
		end
	end
end

function GM:Notify(message, class)
	self:AddNotify(message, class, 5)

	local fileName = "ambient/water/drip"..math.random(1, 4)..".wav"

	if (class == NOTIFY_UNDO) then
		fileName = "buttons/button15.wav"
	end

	surface.PlaySound(fileName)

	MsgN(message)
end

netstream.Hook("fr_Notify", function(message, class)
	GAMEMODE:Notify(message, class)
end)