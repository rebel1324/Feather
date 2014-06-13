local color = Color(255, 236, 12, 255)
local deltaMoney = 500

local OFFSET_CROUCH = Vector(0, 0, -16)
local OFFSET_NORMAL = Vector(0, 0, 16)

function FrameTimeC()
	return math.Clamp(FrameTime(), 1/60, 2)
end

function GM:HUDPaint()
	local w, h = ScrW(), ScrH()

	-- Overrideable Functions.
	-- Everything is overrideable by any addons/modifications.
	self:LocalPlayerInfo(w, h) 
	self:PlayerInfo(w, h)
	self:ProgressPaint(w, h)
	self:CenterDisplayPaint(w, h)
	self:Lockdown(w, h)
	self:ArrestTimer(w, h)
	self:DrawDoorInfo(w, h)
	self:ScreenFade(w, h)

	local td = {}
		td.start = LocalPlayer():GetShootPos()
		td.endpos = td.start + LocalPlayer():GetAimVector()*(128)
		td.filter = LocalPlayer()
	local ent = util.TraceLine(td).Entity

	if (ent and ent.DrawTargetInfo) then
		ent:DrawTargetInfo(w, h)
	end

	for k, v in ipairs(ents.GetAll()) do
		if v.DrawScreen then
			v:DrawScreen(w, h)
		end
	end
end

GM.FadeSpeed = 1
GM.FadeAlpha = 0
GM.FadeColor = color_white

function GM:ScreenFade(w, h)
	self.FadeAlpha = Lerp(FrameTimeC() * self.FadeSpeed, self.FadeAlpha, 0)

	surface.SetDrawColor(self.FadeColor.r, self.FadeColor.g, self.FadeColor.b, math.floor(self.FadeAlpha))
	surface.DrawRect(0, 0, w, h)
end

function GM:HUDShouldDraw(name)
	if (
		name == "CHudHealth" or
		name == "CHudBattery" or
		name == "CHudSecondaryAmmo" or
		name == "CHudAmmo"
	) then
		return false
	end

	return true
end

local tagw = 6
local function DrawHUDBar(x, y, w, h, col, p)
	p = p or 1
	surface.SetDrawColor(44, 62, 80, col.a)
	surface.DrawRect(x, y, tagw, h)

	surface.SetDrawColor(22, 34, 52, col.a)
	surface.DrawRect(x + tagw, y, w, h)

	surface.SetDrawColor(col.r, col.g, col.b, col.a)
	surface.DrawRect(x + tagw, y, math.Round(w * p), h)
end


local margin = 20
local sx, sy = 200, 45
local curhpp = 0
local curhupp = 0
local textmargin = 15
local curmoney = 0
local salaryColor = Color(46, 204, 133)

function GM:LocalPlayerInfo(w, h)
	local teamID = LocalPlayer():Team()

	local posx, posy = margin, h - margin 
	
	if self.HungerMode then
		posy = posy - 5
		curhupp = Lerp(FrameTimeC(), curhupp, math.Clamp(LocalPlayer():GetHungerPercent(), 0, 1))
		DrawHUDBar( posx, posy, sx, 5, Color(58, 83, 155), curhupp)
	end
	
	posx, posy = posx, posy - sy
	curhpp = Lerp(FrameTimeC(), curhpp, math.Clamp(LocalPlayer():Health()/100, 0, 1))
	DrawHUDBar( posx, posy, sx, sy, Color(150, 40, 27), curhpp)
	DrawHUDBar( posx, posy, 200 * math.Clamp(LocalPlayer():Armor() / 100, 0, 1), sy, Color(250, 250, 250, 15 + math.sin(RealTime() * 3)*10), curhpp)
	draw.SimpleText(math.Clamp(LocalPlayer():Health(), 0, math.huge), "fr_HUDFont", margin + tagw + 10, posy + sy/2, color_white, 0, 1)

	curmoney = Lerp(FrameTimeC() * 2, curmoney, LocalPlayer():GetMoney())

	posx, posy = posx + tagw , posy - 25
	local data = self:GetJobData(teamID) 
	local tx, ty = draw.SimpleText(MoneyFormat(math.Round(curmoney)), "fr_HUDFont", posx, posy, color_white, 0, 1)
	if data then
		draw.SimpleText("+" .. MoneyFormat(data.salary) or 0, "fr_HUDFont", posx + tx + 6, posy, salaryColor, 0, 1)
	end

	posy = posy - ty - 0
	local tx, ty = draw.SimpleText(team.GetName(teamID), "fr_HUDFont", posx, posy, color_white, 0, 1)
end

function GM:PlayerInfo(w, h)
	local position = LocalPlayer():GetPos()
	local shootPos = LocalPlayer():GetShootPos()
	local aimVector = LocalPlayer():GetAimVector()

	for k, v in ipairs(player.GetAll()) do
		if (v != LocalPlayer() and v:Alive()) then
			local bi = v:LookupBone("ValveBiped.Bip01_Head1")
			local bonepos = v:GetBonePosition(bi)
			local origin = (bi != 0) and (bonepos + Vector(0, 0, 11)) or (v:GetShootPos() + (v:Crouching() and OFFSET_CROUCH or OFFSET_NORMAL)) 
			local alpha = (1 - origin:DistToSqr(position) / 262144) * 255 + 150

			if (alpha > 0) then
				local trace = util.TraceLine({
					start = shootPos,
					endpos = v:GetShootPos(),
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

function GM:ArrestTimer(w, h)
	if LocalPlayer():GetNetVar("arrested") then
		local text = "You're arrested."
		surface.SetFont("fr_LicenseTitle")
		local tx, ty = surface.GetTextSize(text)
		draw.SimpleText(text, "fr_Arrested", w/2 - tx/2, h/5*4, color_white, 0, 0)
		text = "Your arrest will be lifted in " .. string.NiceTime(math.ceil(LocalPlayer():GetNetVar("arrested") - CurTime())) .. "."
		local tx, ty = surface.GetTextSize(text)
		draw.SimpleText(text, "fr_Arrested", w/2 - tx/2, h/5*4 + ty, color_white, 0, 0)
	end
end

function GM:Lockdown(w, h)
	if GetNetVar("lockdown") then
		local text = GetLang("lockdown", GetNetVar("lockdownreason"))
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
		surface.DrawRect(w/2 - sizex/2 + 2, h/2 + sizey/3 + 2, sizex * (1 - ft) - 4, sizey - 4)
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
	self.CenterDisplayText = markup.Parse(prefix .. text .. postfix, ScrW())
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

function GM:CanDrawWeaponHUD()
	return !(self.DrawDoor or self.DisplayTime > CurTime() or math.floor(self.DisplayAlpha) > 0)
end

netstream.Hook("FeatherNotify", function(message, class)
	GAMEMODE:Notify(message, class)
end)

netstream.Hook("FeatherFade", function(data)
	GAMEMODE.FadeSpeed = data[2]
	GAMEMODE.FadeAlpha = data[1].a
	GAMEMODE.FadeColor = data[1]
end)

netstream.Hook("PlaySound", function(data)
	surface.PlaySound(data)
end)

function GM:ShowSpare1()
end

function GM:ShowSpare2()
end

function GM:ShowTeam()
end