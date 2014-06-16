local blur = Material("pp/blurscreen")

local function DrawBlur(panel, amount, alpha)
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255, alpha or 255)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

local PNL = {}

function PNL:Init()
	self.text = "Sample Text"
	self.col = Color(150, 40, 27)
end

function PNL:SetText(str)
	self.text = str
end

function PNL:SetColor(col)
	self.col = col
end

function PNL:Paint(w, h)
	surface.SetDrawColor(self.col.r, self.col.g, self.col.b)
	surface.DrawRect(0, 2, 5, h - 4)

	draw.SimpleText(self.text, "fr_MenuFont", 20, self:GetTall()/2, color_white, 0, 1)
end
vgui.Register("FeatherJobCategoryPanel", PNL, "DPanel")

local PNL = {}

function PNL:Init()
end

function PNL:SetPlayer(ply)
	self.player = ply
end

function PNL:Paint(w, h)
	if self.player and self.player:IsValid() then
		draw.SimpleText(self.player:Name(), "fr_MenuFont", 5, self:GetTall()/2, color_white, 0, 1)
		draw.SimpleText(self.player:Ping(), "fr_MenuFont", w - 5, self:GetTall()/2, color_white, 2, 1)
	end
end
vgui.Register("FeatherPlayerPanel", PNL, "DPanel")

local PNL = {}

function PNL:Init()
	local w, h = ScrW(), ScrH()
	self:SetSize(w, h)
	self.alpha = 0

	self.panel = vgui.Create("DPanel", self)
	local hg = h * .8
	self.panel:SetSize(h, hg)
	self.panel:SetPos(w/2 - h/2, (h - hg)/2)
	self.panel:SetDrawBackground(false)

	local p = self.panel
	local text = vgui.Create("DLabel", p)
	text:SetFont("fr_ScoreboardTitle")
	text:SetText(GetHostName())
	text:Dock(TOP)
	text:DockMargin(5, 0, 5, 0)
	text:SetAutoStretchVertical( true )
	text:SetColor(color_white)	

	local text = vgui.Create("DLabel", p)
	text:SetFont("fr_ScoreboardTitleSub")
	text:SetText(GetLang"scoreboardcredit")
	text:Dock(TOP)
	text:DockMargin(5, 0, 5, 0)
	text:SetAutoStretchVertical( true )
	text:SetColor(color_white)	

	local text = vgui.Create("DLabel", p)
	text:SetFont("fr_ScoreboardTitleInfo")
	text:SetText(GetLang"scoreboardinfo")
	text:Dock(TOP)
	text:DockMargin(5, 0, 5, 10)
	text:SetAutoStretchVertical( true )
	text:SetColor(color_white)	

	self.content = vgui.Create("PanelList", p)
	self.content:Dock(FILL)
	self.content:DockMargin(5, 10, 5, 5)
	self.content:EnableVerticalScrollbar()
	self.content:SetSpacing(5)
	self.content:SetPadding(0)
	self.content.Paint = function() end

	self:RefreshPlayers()
	self.playercount = #player.GetAll()
end

function PNL:RefreshPlayers()
	local p = self.content
	p:Clear()

	for i, tbl in ipairs(team.GetAllTeams()) do
		if (#team.GetPlayers(i) > 0) then
			local text = vgui.Create("FeatherJobCategoryPanel", p)
			text:SetText(team.GetName(i))
			text:SetTall(40)
			text:SetColor(team.GetColor(i))
			p:AddItem(text)

			for pi, client in ipairs(team.GetPlayers(i)) do
				local text = vgui.Create("FeatherPlayerPanel", p)
				text:SetPlayer(client)
				text:SetTall(40)
				p:AddItem(text)
			end
		end
	end
	-- display all players on the scoreboard.
end

function PNL:Think()
	-- If player count is different, refresh.
	local plys = #player.GetAll()

	if plys != self.playercount then
		timer.Simple(0, function()
			self:RefreshPlayers()
		end)
	end

	self.playercount = plys
end

function PNL:Paint(w, h)
	self.alpha = Lerp(FrameTimeC()*2, self.alpha, 255)
	DrawBlur(self, 3, self.alpha) -- Shamelessy stolen from NutScript.
	surface.SetDrawColor(0, 0, 0, self.alpha*.8)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("FeatherScoreboard", PNL, "DPanel")