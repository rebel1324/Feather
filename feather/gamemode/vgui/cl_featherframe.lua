DOWNGRADIENT = Material("vgui/gradient-u")

local topbar = 30

local PNL = {}

function PNL:Init()
	self:SetSize(40, 20)
	self:SetText("x")
	self:DockPadding(5, topbar + 5, 5, 5)
	self:SetColor(color_white)
end

function PNL:DoClick()
	local p = self:GetParent()
	p:Close()

	if p.OnClose then
		p:OnClose(p)
	end
end

function PNL:Paint(w, h)
	surface.SetDrawColor(217, 30, 24)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(239, 72, 54)
	surface.DrawOutlinedRect(0, -1, w, h+1)
end

vgui.Register("FeatherFrameClose", PNL, "DButton")

local PNL = {}

function PNL:Init()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self.title = "Sample Text"

	self.close = vgui.Create("FeatherFrameClose", self)
end

function PNL:SetText(str)
	self.title = str
end

function PNL:PerformLayout()
	self.close:SetPos(self:GetWide() - 10 - 40, 0)
end

function PNL:Paint(w, h)
	surface.SetDrawColor(242, 241, 239)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(34, 49, 63)
	surface.DrawRect(0, 0, w, topbar)
	surface.SetDrawColor(24, 39, 53)
	surface.DrawRect(0, topbar-2, w, 2)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.SetMaterial(DOWNGRADIENT)
	surface.DrawTexturedRect(0, topbar, w, 15)

	draw.SimpleText(self.title, "fr_FrameFont", 10, topbar/2 - 1, color_white, 0, 1)
end

vgui.Register("FeatherFrame", PNL, "DFrame")