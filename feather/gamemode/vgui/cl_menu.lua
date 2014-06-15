GRADIENT = Material("vgui/gradient")

local function MenuShadow(w, h)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.SetMaterial(GRADIENT)
	surface.DrawTexturedRect(w - w*.1, 0, w*.1, h)
end

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

	if self.activated then
		surface.SetDrawColor(242, 241, 239)
		surface.DrawRect(0, 0, w, h)
	else
		surface.DrawRect(0, 0, w, h)
		MenuShadow(w, h)
	end
end

function PNL:OnCursorEntered()
	self.hover = true
	surface.PlaySound("UI/buttonrollover.wav")
end

function PNL:OnCursorExited()
	self.hover = false
end

function PNL:Deactivate()
	self:SetColor(color_white)
	self.activated = false
end

function PNL:Activate()
	local p = self:GetParent()
	for k, v in pairs(p.buttons) do
		if (v != self) then
			v:Deactivate()
		end
	end

	self:SetColor(color_black)
	self.activated = true
end

function PNL:DoClick()
	self:OnClick()
	self:Activate()
	surface.PlaySound("weapons/pistol/pistol_empty.wav")
end

function PNL:Think()
end
vgui.Register("FeatherMainMenuButton", PNL, "DButton")



local PNL = {}

function PNL:Init()
end

function PNL:SetData(tbl, index)
	self.data = tbl
	self.index = index
end

function PNL:Paint(w, h)
	if self.hover then
		surface.SetDrawColor(103, 128, 159)
	else
		surface.SetDrawColor(62, 83, 104)
	end
	surface.DrawRect(0, 0, w, h)
end

function PNL:OnRemove()
	if self.info and self.info.Close then
		self.info:Close()
	end
end

function PNL:DoRightClick()
	if self.info then 
		if self.info.Close then
			self.info:Close()
		end
		self.info = nil
	end
	
	self.info = vgui.Create("FeatherFrame")
	self.info:SetSize(300, 300)
	self.info:Center()
	self.info:SetText("Job Information")
	self.info:MakePopup()

	local text = vgui.Create("DLabel", self.info)
	text:Dock(TOP)
	text:SetContentAlignment(2)
	text:SetFont("fr_MenuBigFont")
	text:SetText(team.GetName(self.index))
	text:DockMargin(5, 20, 5, 0)
	text:SetAutoStretchVertical( true )
	text:SetColor(color_black)	

	local scroll = vgui.Create("PanelList", self.info)
	scroll:Dock(FILL)
	scroll:EnableVerticalScrollbar()
	scroll:SetSpacing(10)
	scroll:SetPadding(10)
	scroll.Paint = function() end

	local text = vgui.Create("DLabel", self.info)
	text:SetContentAlignment(2)
	text:SetFont("fr_FrameFont")
	text:SetText(self.data.desc)
	text:DockMargin(17, 10, 5, 5)
	text:SetWrap(true)
	text:SetAutoStretchVertical( true )
	text:SetColor(color_black)	
	scroll:AddItem(text)
end

function PNL:OnCursorEntered()
	self.hover = true
	surface.PlaySound("UI/buttonrollover.wav")
end

function PNL:OnCursorExited()
	self.hover = false
end

function PNL:DoClick()
	self:OnClick()
	surface.PlaySound("weapons/pistol/pistol_empty.wav")
end

function PNL:Think()
end
vgui.Register("FeatherJobButton", PNL, "DButton")


local PNL = {}

function PNL:Init()
end

function PNL:SetData(tbl, index)
	self.data = tbl
	self.index = index
end

function PNL:Paint(w, h)
	if self.hover then
		surface.SetDrawColor(103, 128, 159)
	else
		surface.SetDrawColor(62, 83, 104)
	end
	surface.DrawRect(0, 0, w, h)
end

function PNL:OnCursorEntered()
	self.hover = true
	surface.PlaySound("UI/buttonrollover.wav")
end

function PNL:OnCursorExited()
	self.hover = false
end

function PNL:DoClick()
	self:OnClick()
	surface.PlaySound("weapons/pistol/pistol_empty.wav")
end

function PNL:Think()
end
vgui.Register("FeatherStuffButton", PNL, "DButton")

local PNL = {}

function PNL:Init()
	self.text = "Sample Text"
end

function PNL:SetText(str)
	self.text = str
end

function PNL:Paint(w, h)
	surface.SetDrawColor(150, 40, 27)
	surface.DrawRect(0, 0, 5, h)

	draw.SimpleText(self.text, "fr_MenuFont", 20, self:GetTall()/2, color_black, 0, 1)
end
vgui.Register("FeatherCategoryPanel", PNL, "DPanel")

local PNL = {}
local menubarsize = .25
local menubartopsize = .12

function PNL:Init()
	self:SetSize(640, 480)
	self:Center()
	self:DockPadding(0, 0, 0, 0)
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
	self.NextClose = CurTime() + .5

	self.menu = vgui.Create("DPanel", self)
	self.menu:Dock(LEFT)
	self.menu:DockPadding(0, self:GetTall()*menubartopsize, 0, 0)
	self.menu:SetWidth(self:GetWide()*menubarsize)
	self.menu.Paint = function(p, w, h)
		surface.SetDrawColor(34, 49, 63)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(57*1.1, 80*1.1, 100*1.1)
		surface.DrawRect(0, 0, w, h*menubartopsize)

		MenuShadow(w, h)
		
		draw.SimpleText("MENU", "fr_HUDFont", w/2, h*menubartopsize/2, color_white, 1, 1)
	end
	self.menu.buttons = {}

	self.content = vgui.Create("PanelList", self)
	self.content:EnableVerticalScrollbar()
	self.content:Dock(FILL)
	self.content:SetPadding(10)
	self.content:SetSpacing(10)
	self.content.Paint = function(p, w, h)
		surface.SetDrawColor(242, 241, 239)
		surface.DrawRect(0, 0, w, h)
	end

	local d = self:AddButton(GetLang"menujob", function()
		self:LoadJob()
	end)
	self:LoadJob()
	d:Activate()

	self:AddButton(GetLang"menushop", function()
		self:LoadItems()
	end)

	hook.Run("OnMenuLoadButtons", self)

	self:AddButton(GetLang"menuconfig", function()
		self:LoadConfigs()
	end)	

	self:AddButton(GetLang"menuclose", function()
		self:Close()
	end)
end

function PNL:OnRemove()
	surface.PlaySound("buttons/lightswitch2.wav")
end

function PNL:LoadJob()
	self.content:Clear()

	local notice = vgui.Create("FeatherNoticeBar", self.content)
	notice:SetText(GetLang("jobmenutip"))
	notice:SetType(7)
	self.content:AddItem(notice)

	for k, v in ipairs(team.GetAllTeams()) do
		local data = GAMEMODE:GetJobData(k)
		if (data.childjob and data.childjob != LocalPlayer():Team() or k == LocalPlayer():Team()) then
			continue
		end

		local pnl = vgui.Create("FeatherJobButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(team.GetName(k))
		pnl:SetFont("fr_MenuFont")
		pnl:SetColor(color_white)
		pnl:SetData(data, k)
		pnl.DoClick = function()
			LocalPlayer():ConCommand("say /job ".. ((string.lower(type(data.cmd)) == "table") and (table.Random(data.cmd)) or (data.cmd)))
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
			catlist[v.category] = vgui.Create("FeatherCategoryPanel", self.content)
			catlist[v.category]:SetTall(40)
			catlist[v.category]:SetText(v.category)
			self.content:AddItem(catlist[v.category])
		end

		local pnl = vgui.Create("FeatherStuffButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(Format("%s (%s)", v.name, MoneyFormat(v.price)))
		pnl:SetFont("fr_MenuFont")
		pnl:SetColor(color_white)
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
			catlist[v.category] = vgui.Create("FeatherCategoryPanel", self.content)
			catlist[v.category]:SetTall(40)
			catlist[v.category]:SetText(v.category)
			self.content:AddItem(catlist[v.category])
		end

		local pnl = vgui.Create("FeatherStuffButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(Format("%s (%s)", v.name, MoneyFormat(v.price)))
		pnl:SetFont("fr_MenuFont")
		pnl:SetColor(color_white)
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
			catlist[v.category] = vgui.Create("FeatherCategoryPanel", self.content)
			catlist[v.category]:SetTall(40)
			catlist[v.category]:SetText(v.category)
			self.content:AddItem(catlist[v.category])
		end

		local pnl = vgui.Create("FeatherStuffButton", self.content)
		pnl:SetTall(50)
		pnl:SetText(Format("%s (%s)", v.name, MoneyFormat(v.price)))
		pnl:SetFont("fr_MenuFont")
		pnl:SetColor(color_white)
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
	btn:DockMargin(0, 0, 0, 0)
	btn:SetText(str)
	btn:SetFont("fr_MenuFont")
	btn:SetColor(color_white)
	btn:SetTall(45)
	if func then
		btn.OnClick = func
	end

	table.insert(self.menu.buttons, btn)
	return btn
end

function PNL:Paint()
end

vgui.Register("FeatherMainMenu", PNL, "DFrame")

netstream.Hook("UpdateJobs", function()
	if MENU and MENU.LoadJob then
		timer.Simple(.1, function()
			MENU:LoadJob()
		end)
	end
end)
