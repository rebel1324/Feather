GRADIENT = Material("vgui/gradient")

surface.CreateFont("fr_NotiFont", {
	font = "Myriad Pro",
	size = 16,
	weight = 500,
	antialias = true
})

local PNL = {}
PNL.pnlTypes = {
	[1] = { -- NOT ALLOWED
		col = Color( 200, 60, 60 ),
		icon = "icon16/exclamation.png"
	},
	[2] = { -- COULD BE CANCELED
		col = Color( 255, 100, 100 ),
		icon = "icon16/cross.png"
	},
	[3] = { -- WILL BE CANCELED
		col = Color( 255, 100, 100 ),
		icon = "icon16/cancel.png"
	},
	[4] = { -- TUTORIAL/GUIDE
		col = Color( 100, 185, 255 ),
		icon = "icon16/book.png"
	},
	[5] = { -- ERROR
		col = Color( 255, 255, 100 ),
		icon = "icon16/error.png"
	},
	[6] = { -- YES
		col = Color( 140, 255, 165 ),
		icon = "icon16/accept.png"
	},
	[7] = { -- TUTORIAL/GUIDE
		col = Color( 100, 185, 255 ),
		icon = "icon16/information.png"
	},
}

function PNL:Init()
	self.type = 1
	self.text = self:Add( "DLabel" )
	self.text:SetFont( "fr_NotiFont" )
	self.text:SetContentAlignment(5)
	self.text:SetTextColor( color_white )
	self.text:SizeToContents()
	self.text:Dock( FILL )
	self.text:DockMargin(2, 2, 2, 2)
	self.text:SetExpensiveShadow(1, Color(25, 25, 25, 120))
	self:SetTall(28)
end

function PNL:SetType( num )
	self.type = num
	return 
end

function PNL:SetText( str )
	self.text:SetText( str )
end

function PNL:SetFont( str )
	self.text:SetFont( str )
end

function PNL:Paint()
	self.material = self.material or Material( self.pnlTypes[ self.type ].icon )
	local col = self.pnlTypes[ self.type ].col
	local mat = self.material
	local size = self:GetTall()*.6
	local marg = 3
	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), col )	
	if mat then
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( size/2, self:GetTall()/2-size/2 + 1, size, size )
	end
end

vgui.Register("FeatherNoticeBar", PNL, "DPanel")

local PNL = {}

function PNL:Init()
end

function PNL:Paint(w, h)
	if self.hover then
		surface.SetDrawColor(103, 128, 159)
	else
		surface.SetDrawColor(52, 73, 94)
	end
	surface.DrawRect(0, 0, w, h)
end

function PNL:OnCursorEntered()
	self.hover = true
end

function PNL:OnCursorExited()
	self.hover = false
end

function PNL:Think()
end
vgui.Register("FeatherMainMenuButton", PNL, "DButton")

local PNL = {}
local menubarsize = .25
local menubartopsize = .12

function PNL:Init()
	self:SetSize(640, 480)
	self:Center()
	self:DockPadding(0, 0, 0, 0)
	self:MakePopup()

	self.menu = vgui.Create("DPanel", self)
	self.menu:Dock(LEFT)
	self.menu:DockPadding(0, self:GetTall()*menubartopsize, 0, 0)
	self.menu:SetWidth(self:GetWide()*menubarsize)
	self.menu.Paint = function(p, w, h)
		surface.SetDrawColor(34, 49, 63)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(57*1.1, 80*1.1, 100*1.1)
		surface.DrawRect(0, 0, w, h*menubartopsize)

		draw.SimpleText("MENU", "fr_HUDFont", w/2, h*menubartopsize/2, color_white, 1, 1)
	end

	self.content = vgui.Create("PanelList", self)
	self.content:EnableVerticalScrollbar()
	self.content:Dock(FILL)
	self.content:SetPadding(10)
	self.content:SetSpacing(10)
	self.content.Paint = function(p, w, h)
		surface.SetDrawColor(242, 241, 239)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 200)
		surface.SetMaterial(GRADIENT)
		surface.DrawTexturedRectRotated(w*.05/2 - 1, h/2, w*.05, h, 180)
	end


	self:AddButton("Job", function()
		self:LoadJob()
	end)
	self:LoadJob()

	self:AddButton("Shop", function()
		self:LoadItems()
	end)

	self:AddButton("Config", function()
		self:LoadConfigs()
	end)

	hook.Run("OnMenuLoadButtons", self)

	self:AddButton("Close", function()
		self:Close()
	end)
end

function PNL:LoadJob()
	self.content:Clear()

	local notice = vgui.Create("FeatherNoticeBar", self.content)
	notice:SetText("Hehe Nutscript feeling over the place.")
	notice:SetType(7)
	self.content:AddItem(notice)

	for k, v in ipairs(team.GetAllTeams()) do
		local data = GAMEMODE:GetJobData(k)
		if data.childjob and data.childjob != LocalPlayer():Team() then
			continue
		end

		local pnl = vgui.Create("DButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(team.GetName(k))
		pnl:SetFont("fr_MenuFont")
		if data then
			pnl.DoClick = function()
				LocalPlayer():ConCommand("say /job ".. ((string.lower(type(data.cmd)) == "table") and (table.Random(data.cmd)) or (data.cmd)))
			end
		end
		self.content:AddItem(pnl)
	end
end

function PNL:AddText(str, font)
	local text = vgui.Create("DLabel")
	text:Dock(TOP)
	text:SetContentAlignment(1)
	text:SetFont(font or "fr_MenuFont")
	text:SetText(str)
	text:DockMargin(17, 10, 5, 5)
	text:SetAutoStretchVertical( true )
	text:SetColor(color_black)	
	return text
end
	
function PNL:LoadItems()
	self.content:Clear()
	local client = LocalPlayer()

	local catlist = {}
	for k, v in SortedPairsByMemberValue(GAMEMODE.EntityList) do
		if hook.Run("CanBuyEntity", client, v.__key, v, true) == false then
			continue
		end

		if v.category and !catlist[v.category] then
			local pnl = vgui.Create("DPanel", self.content)
			pnl:SetTall(40)
			pnl.Paint = function() end
			self.content:AddItem(pnl)
			catlist[v.category] = self:AddText(v.category or "", "fr_CategoryFont")
			catlist[v.category]:SetParent(pnl)
			catlist[v.category]:Dock(FILL)
		end

		local pnl = vgui.Create("DButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(v.name)
		pnl:SetFont("fr_MenuFont")
		pnl.DoClick = function()
			client:ConCommand("say /buy ".. v.__key)
		end
		self.content:AddItem(pnl)
	end

	for k, v in SortedPairsByMemberValue(GAMEMODE.WeaponList) do
		if hook.Run("CanBuyWeapon", client, v.__key, v, true) == false then
			continue
		end

		if v.category and !catlist[v.category] then
			local pnl = vgui.Create("DPanel", self.content)
			pnl:SetTall(40)
			pnl.Paint = function() end
			self.content:AddItem(pnl)
			catlist[v.category] = self:AddText(v.category or "", "fr_CategoryFont")
			catlist[v.category]:SetParent(pnl)
			catlist[v.category]:Dock(FILL)
		end

		local pnl = vgui.Create("DButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(v.name)
		pnl:SetFont("fr_MenuFont")
		pnl.DoClick = function()
			client:ConCommand("say /buy ".. v.__key)
		end
		self.content:AddItem(pnl)
	end
	
	for k, v in SortedPairsByMemberValue(GAMEMODE.FoodList) do
		if hook.Run("CanBuyFood", client, v.__key, v, true) == false then
			continue
		end

		if v.category and !catlist[v.category] then
			local pnl = vgui.Create("DPanel", self.content)
			pnl:SetTall(40)
			pnl.Paint = function() end
			self.content:AddItem(pnl)
			catlist[v.category] = self:AddText(v.category or "", "fr_CategoryFont")
			catlist[v.category]:SetParent(pnl)
			catlist[v.category]:Dock(FILL)
		end

		local pnl = vgui.Create("DButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(v.name or 0)
		pnl:SetFont("fr_MenuFont")
		pnl.DoClick = function()
			client:ConCommand("say /buy ".. v.__key)
		end
		self.content:AddItem(pnl)
	end

	hook.Run("OnMenuLoadItems", self)
end

function PNL:LoadConfigs()
	self.content:Clear()
end

function PNL:AddButton(str, func)
	local btn = vgui.Create("FeatherMainMenuButton", self.menu)
	btn:Dock(TOP)
	btn:SetText(str)
	btn:SetFont("fr_MenuFont")
	btn:SetColor(color_white)
	btn:SetTall(45)
	if func then
		btn.DoClick = func
	end
end

function PNL:Paint()
end

function PNL:Think()
end
vgui.Register("FeatherMainMenu", PNL, "DFrame")

local function ShowMenu()
	if MENU then
		if MENU.Close then
			MENU:Close()
		end
		MENU = nil
	end
	MENU = vgui.Create("FeatherMainMenu")
end

CLICKER = CLICKER or false
local function Clicker()
	CLICKER = !CLICKER
	gui.EnableScreenClicker(CLICKER)
end

hook.Add("PlayerBindPress", "FeatherMenuLoad", function(client, bind, pressed)
	if bind == "gm_showteam" then
		return false
	elseif bind == "gm_showspare1" then
		Clicker()
		return false
	elseif bind == "gm_showspare2" then
		ShowMenu()
		return false
	end
end)