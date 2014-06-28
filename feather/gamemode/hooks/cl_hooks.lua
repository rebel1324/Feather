local color = Color(255, 236, 12, 255)
local deltaMoney = 500

local OFFSET_CROUCH = Vector(0, 0, -16)
local OFFSET_NORMAL = Vector(0, 0, 16)

local chattype = "ic"

local tagw = 6

local dcol = Color(150, 250, 150)

local margin = 20
local sx, sy = 200, 45
local curhpp = 0
local curhupp = 0
local textmargin = 15
local curmoney = 0
local salaryColor = Color(46, 204, 133)

local iconsize = 16*2

GM.FadeSpeed = 1
GM.FadeAlpha = 0
GM.FadeColor = color_white
GM.IsChatOpen = false
GM.CurChat = ""
GM.DisplayText = "Display"
GM.DisplayMaxTime = 0
GM.DisplayTime = 0
GM.DisplayAlpha = 0
GM.DisplayColor = Color(150, 250, 150)
GM.CenterDisplayText = "Display"
GM.CenterDisplayTime = 0
GM.CenterDisplayAlpha = 0
GM.Markers = {}
GM.Icons = {
	[1] = surface.GetTextureID("vgui/notices/error"),
	[2] = surface.GetTextureID("vgui/notices/generic"),
	[3] = surface.GetTextureID("vgui/notices/hint"),
	[4] = surface.GetTextureID("vgui/notices/undo"),
	[5] = surface.GetTextureID("vgui/notices/cleanup"),
}

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
	self:DrawDoorInfo(w, h)
	self:ScreenFade(w, h)
	self:ChatAssist(w, h)
	self:DrawMarker(w, h)

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

function GM:ChatAssist(w, h)
	if self.IsChatOpen then
		local x, y = chat.GetChatBoxPos()

		local curchat = GAMEMODE.ChatTypes["ic"]
		for k, v in pairs(self.ChatTypes) do
			if v.prefix then
				for _, t in ipairs(v.prefix) do
					if string.find(self.CurChat, t, 0, true) then
						curchat = GAMEMODE.ChatTypes[k]
					end
				end
			end
		end

		local range = 512
		local hears = {}
		local i = 0
		local cut = 5
		y = y - 20
		for k, v in ipairs(player.GetAll()) do
			local dist = v:GetPos():Distance(LocalPlayer():GetPos())
			if (curchat.canHear(LocalPlayer(), v) and LocalPlayer() != v) then
				if i >= cut then
				else
					table.insert(hears, v)
				end
				i = i + 1
			end
		end

		if i >= cut then
			local tx, ty = draw.SimpleText(GetLang("andmore", i - cut + 1), "fr_ChatAssist", x, y, color_white, 0, 1)
			y = y - ty
		end

		for k, v in ipairs(hears) do
			local tx, ty = draw.SimpleText(v:Name(), "fr_ChatAssist", x, y, color_white, 0, 1)
			y = y - ty
		end

		x, y = x, y
		draw.SimpleText(GetLang"canhear", "fr_ChatAssist", x, y, Color(214, 69, 65), 0, 1)
	end
end

function GM:ScreenFade(w, h)
	self.FadeAlpha = Lerp(FrameTimeC() * self.FadeSpeed, self.FadeAlpha, 0)

	surface.SetDrawColor(self.FadeColor.r, self.FadeColor.g, self.FadeColor.b, math.floor(self.FadeAlpha))
	surface.DrawRect(0, 0, w, h)
end

function GM:HUDShouldDraw(name)
	if (
		name == "CHudHealth" or
		name == "CHudBattery" or
		name == "CHudSecondaryAmmo"
	) then
		return false
	end

	return true
end

local function DrawHUDBar(x, y, w, h, col, p)
	p = p or 1
	surface.SetDrawColor(22, 34, 52, col.a)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(col.r, col.g, col.b, col.a)
	surface.DrawRect(x, y, math.Round(w * p), h)
end

function GM:LocalPlayerInfo(w, h)
	local teamID = LocalPlayer():Team()

	local posx, posy = margin, h - margin 
	
	if feather.config.get("hunger") then -- If Hunger Mod is active, draw hunger bar in bottom of the health bar.
		posy = posy - 5
		curhupp = Lerp(FrameTimeC(), curhupp, math.Clamp(LocalPlayer():GetHungerPercent(), 0, 1))
		DrawHUDBar( posx, posy, sx, 5, Color(58, 83, 155), curhupp)
	end
	
	posx, posy = posx, posy - sy
	curhpp = Lerp(FrameTimeC(), curhpp, math.Clamp(LocalPlayer():Health()/100, 0, 1))

	-- draw a bar with Color(150, 40, 27) and hp fraction.
	DrawHUDBar( posx, posy, sx, sy, Color(150, 40, 27), curhpp)

	-- draw an armor overlay.
	DrawHUDBar( posx, posy, 200 * math.Clamp(LocalPlayer():Armor() / 100, 0, 1), sy, Color(250, 250, 250, 15 + math.sin(RealTime() * 3)*10), curhpp)

	-- draw health amount on the health bar.
	draw.SimpleText(math.Clamp(LocalPlayer():Health(), 0, math.huge), "fr_HUDFont", margin + 10, posy + sy/2, color_white, 0, 1)

	-- this helps to get smooth money count.
	curmoney = Lerp(FrameTimeC() * 2, curmoney, LocalPlayer():GetMoney())

	posx, posy = posx , posy - 25
	-- Get job data from current team index.
	local data = self:GetJobData(teamID) 
	local tx, ty = draw.SimpleText(MoneyFormat(math.Round(curmoney)), "fr_HUDFont", posx, posy, color_white, 0, 1)

	if data then -- if job data is valid, draw salary.
		draw.SimpleText("+" .. MoneyFormat(data.salary) or 0, "fr_HUDFont", posx + tx + 6, posy, salaryColor, 0, 1)
	end

	posy = posy - ty - 0
	-- draw team name.
	local tx, ty = draw.SimpleText(team.GetName(teamID), "fr_HUDFont", posx, posy, color_white, 0, 1)
end

function GM:PlayerInfo(w, h)
	local position = LocalPlayer():GetPos()
	local shootPos = LocalPlayer():GetShootPos()
	local filter = {}
	local info = {}

	-- Proper Thirdperson Support.
	if (LocalPlayer():ShouldDrawLocalPlayer()) then
		local a = hook.Run("CalcView", LocalPlayer(), EyePos(), EyeAngles())
		if a.origin then
			position = a.origin
			shootPos = a.origin
			filter = ents.FindInSphere(shootPos, 16)
		else
			local ve = self:GetViewEntity()
			if ve and ve:IsValid() then
				position = ve:GetPos()
				shootPos = ve:GetPos()
				filter = ve
			end
		end
	else
		filter = LocalPlayer()
	end

	function info:draw(text, color, color2)
		local alpha = info.alpha
		color.a = alpha
		color2 = color2 or Color(0, 0, 0)
		color2.alpha = alpha

		local w, h = draw.SimpleText(text, "fr_BigTargetShadow", info.x, info.y, color2, 1, 1)
		draw.SimpleText(text, "fr_BigTarget", info.x, info.y, color, 1, 1)

		info.y = info.y - h

		return w, h
	end

	for k, v in ipairs(player.GetAll()) do
		if ((v != LocalPlayer() or v:ShouldDrawLocalPlayer()) and v:Alive()) then
			local bi = v:LookupBone("ValveBiped.Bip01_Head1")
			local bonepos = v:GetBonePosition(bi)
			local origin = (bi != 0) and (bonepos + Vector(0, 0, 11)) or (v:GetShootPos() + (v:Crouching() and OFFSET_CROUCH or OFFSET_NORMAL)) 
			local alpha = (1 - origin:DistToSqr(position) / 262144) * 255 + 150

			if (alpha > 0) then
				local trace = util.TraceLine({
					start = shootPos,
					endpos = v:GetShootPos(),
					filter = filter
				})
				
				if (trace.Hit and trace.Entity != v) then continue end

				local position = origin:ToScreen()
				local px, py = position.x, position.y
				local tx, ty = 0, 0
				local color = team.GetColor(v:Team())
				local job = team.GetName(v:Team())
				color.a = alpha

				info.x = px
				info.y = py
				info.alpha = alpha

				hook.Run("DrawPlayerInfo", v, info)
				
				local shadowColor = Color(color.r * .6, color.g * .6, color.b * .6)
				info:draw(job, color, shadowColor)

				draw.SimpleText(v:Name(), "fr_BigTargetShadow", info.x, info.y, Color(0, 0, 0, alpha), 1, 1)
				draw.SimpleText(v:Name(), "fr_BigTarget", info.x, info.y, Color(255, 255, 255, alpha), 1, 1)
			end
		end
	end
end

function GM:DrawMarker(w, h)
	for k, v in ipairs(self.Markers) do
		if (v.time < CurTime()) then
			v.alpha = Lerp(FrameTimeC(), v.alpha, 0)	

			if (math.floor(v.alpha) < 1) then
				table.remove(self.Markers, k)
			end
		else
			v.alpha = Lerp(FrameTimeC(), v.alpha, 255)	
		end

		local sc = v.pos:ToScreen()
		local sx, sy, visible = sc.x, sc.y, sc.visible
		sx = math.Clamp(sx, h*.1, w - h*.1)
		sy = math.Clamp(sy, h*.1, h - h*.1)

		local text = v.text
		local tx, ty = draw.SimpleText(text, "fr_VoteFontShadow", sx, sy, Color(0, 0, 0, math.ceil(v.alpha)), 1, 1)
		draw.SimpleText(text, "fr_VoteFont", sx, sy, Color(255, 255, 255, math.ceil(v.alpha)), 1, 1)

		surface.SetDrawColor(255, 255, 255, math.ceil(v.alpha))
		surface.SetTexture(v.icon)
		surface.DrawTexturedRect(math.Round(sx-iconsize/2), math.Round(sy-iconsize/2) - ty - 10, iconsize, iconsize)
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

function GM:CenterDisplay(text, time)
	surface.PlaySound("buttons/lightswitch2.wav")

	local prefix = "<font=fr_Progress>"
	local postfix = "</font>"
	self.CenterDisplayText = markup.Parse(prefix .. text .. postfix, ScrW())
	self.CenterDisplayTime = CurTime() + time
	self.CenterDisplayAlpha = 0
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

function GM:CanDrawWeaponHUD()
	return !(self.DrawDoor or self.DisplayTime > CurTime() or math.floor(self.DisplayAlpha) > 0)
end

function GM:ChatTextChanged(text)
	self.CurChat = text
end

function GM:StartChat()
	self.IsChatOpen = true
end

function GM:FinishChat()
	self.IsChatOpen = false
end

function GM:ShowSpare1()
end

function GM:ShowSpare2()
end

function GM:ShowTeam()
end

function GM:GravGunPunt()
	return false
end

function GM:ScoreboardShow()
	if SCOREBOARD then
		if SCOREBOARD.Close then
			SCOREBOARD:Close()
		end
		SCOREBOARD = nil
	end
		
	SCOREBOARD = vgui.Create("FeatherScoreboard")
	SCOREBOARD:MakePopup()
end

function GM:ScoreboardHide()
	if SCOREBOARD then
		SCOREBOARD:Remove()
	end
end

local function ShowMenu()
	if MENU then
		if MENU.Close then
			MENU:Close()
		else
			MENU = nil
			MENU = vgui.Create("FeatherMainMenu")
			surface.PlaySound("buttons/lightswitch2.wav")
		end
		return
	end
	MENU = vgui.Create("FeatherMainMenu")
	surface.PlaySound("buttons/lightswitch2.wav")
end

function GM:ShowHelp()
	if HELP then
		if HELP.Close then
			HELP:Close()
			HELP = nil
		else
			HELP = nil
			HELP = vgui.Create("FeatherHelp")
		end
		return
	end
	HELP = vgui.Create("FeatherHelp")
end

CLICKER = CLICKER or false
local function Clicker()
	CLICKER = !CLICKER
	gui.EnableScreenClicker(CLICKER)
end

function GM:AddMarker(pos, icon, text, time)
	table.insert(self.Markers, {pos = pos, icon = self.Icons[math.Clamp(icon, 0, #self.Icons)], text = text, time = CurTime() + time, alpha = 0})
end

hook.Add("PlayerBindPress", "FeatherMenuLoad", function(client, bind, pressed)
	if bind == "gm_showteam" then
		local ply = LocalPlayer()
		local data = {}
			data.start = ply:GetShootPos()
			data.endpos = data.start + ply:GetAimVector()*96
			data.filter = ply
		local trace = util.TraceLine(data)
		local ent = trace.Entity

		if ent and ent:IsValid() then
			if ent:IsDoor() then
				if ent:GetDoorOwner() == ply then
					ply:ConCommand("say /selldoor")
				else
					ply:ConCommand("say /buydoor")
				end
			end
		end
		return false
	elseif bind == "gm_showspare1" then
		Clicker()
		return false
	elseif bind == "gm_showspare2" then
		ShowMenu()
		return false
	elseif bind == "gm_showhelp" then
		GAMEMODE.ShowHelp()
		return false
	end
end)

netstream.Hook("FeatherProgressDisplay", function(data)
	GAMEMODE:DisplayProgress(data[1], data[2], data[3])
end)

netstream.Hook("FeatherCenterDisplay", function(data)
	GAMEMODE:CenterDisplay(data[1], data[2])
end)

netstream.Hook("FeatherMarker", function(data)
	if data.sound then
		surface.PlaySound(data.sound)
	end

	if (data.pos and data.icon and data.text) then
		data.time = data.time or 5
		GAMEMODE:AddMarker(data.pos, data.icon, data.text, data.time)
	end
end)

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