local color = Color(255, 236, 12, 255)
local deltaMoney = 500

local OFFSET_CROUCH = Vector(0, 0, -16)
local OFFSET_NORMAL = Vector(0, 0, 16)

function FrameTimeC()
	return math.Clamp(FrameTime(), 1/60, 1)
end

function GM:HUDPaint()
	local w, h = ScrW(), ScrH()
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

	for k, v in ipairs(ents.GetAll()) do
		if v.DrawScreen then
			v:DrawScreen(w, h)
		end
	end

	self:ProgressPaint(w, h)
	self:CenterDisplayPaint(w, h)
	self:Lockdown(w, h)
end

function GM:Lockdown(w, h)
	if GetNetVar("lockdown") then
		local text = "Mayor declared Lockdown. All Citizens in the street will be punished. Reason: " .. GetNetVar("lockdownreason")
		surface.SetFont("fr_Progress")
		local tx, ty = surface.GetTextSize(text)
		draw.SimpleText(text, "fr_Progress", -RealTime()*200%(w+tx) - tx, ty/5, color_white, 0, 0)
	end
end

function GM:ProgressPaint(w, h)
	if self.DisplayTime < CurTime() then
		self.DisplayAlpha = math.Clamp(Lerp(FrameTimeC()*3, self.DisplayAlpha, 0), 0, 255)	
	else
		self.DisplayAlpha = math.Clamp(Lerp(FrameTimeC()*3, self.DisplayAlpha, 255), 0, 255)	
	end

	if math.floor(self.DisplayTime) > 0 then
		surface.SetFont("fr_Progress")
		surface.SetTextColor(255, 255, 255, self.DisplayAlpha)
		local tx, ty = surface.GetTextSize(self.DisplayText)
		surface.SetTextPos(w/2 - tx/2, h/2 - ty)
		surface.DrawText(self.DisplayText)

		local sizex, sizey = w/4, 20
		local ft = math.Clamp(((self.DisplayTime - CurTime()) / self.DisplayMaxTime), 0, 1)
		local col = self.DisplayColor

		surface.SetDrawColor(0, 0, 0, self.DisplayAlpha)
		surface.DrawRect(w/2 - sizex/2, h/2 + sizey/3, sizex, sizey)
		surface.SetDrawColor(col.r, col.g, col.b, self.DisplayAlpha)
		surface.DrawRect(w/2 - sizex/2, h/2 + sizey/3, sizex * (1 - ft), sizey)
	end
end

function GM:CenterDisplayPaint(w, h)
	if self.CenterDisplayTime < CurTime() then
		self.CenterDisplayAlpha = math.Clamp(Lerp(FrameTimeC()*3, self.CenterDisplayAlpha, 0), 0, 255)	
	else
		self.CenterDisplayAlpha = math.Clamp(Lerp(FrameTimeC()*3, self.CenterDisplayAlpha, 255), 0, 255)	
	end

	if math.floor(self.CenterDisplayAlpha) > 0 then
		self.CenterDisplayText:Draw(w/2, h/3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, self.CenterDisplayAlpha)
	end
end

GM.DisplayText = "Display"
GM.DisplayMaxTime = 0
GM.DisplayTime = 0
GM.DisplayAlpha = 0
GM.DisplayColor = Color(150, 250, 150)

local dcol = Color(150, 250, 150)
function GM:DisplayProgress(text, time, col)
	self.DisplayText = text
	self.DisplayMaxTime = time
	self.DisplayTime = CurTime() + time
	self.DisplayAlpha = 0
	if col then
		self.DisplayColor = col
	else
		self.DisplayColor = dcol
	end
end
netstream.Hook("FeatherProgressDisplay", function(data)
	GAMEMODE:DisplayProgress(data[1], data[2], data[3])
end)

GM.CenterDisplayText = "Display"
GM.CenterDisplayTime = 0
GM.CenterDisplayAlpha = 0

function GM:CenterDisplay(text, time)
	surface.PlaySound("buttons/lightswitch2.wav")

	local prefix = "<font=fr_Progress>"
	local postfix = "</font>"
	self.CenterDisplayText = markup.Parse(prefix .. text .. postfix)
	self.CenterDisplayTime = CurTime() + time
	self.CenterDisplayAlpha = 0
end
netstream.Hook("FeatherCenterDisplay", function(data)
	GAMEMODE:CenterDisplay(data[1], data[2])
end)

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

netstream.Hook("PlaySound", function(data)
	surface.PlaySound(data)
end)