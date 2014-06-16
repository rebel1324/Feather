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
	/*
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
	*/
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
vgui.Register("FeatherMissionButton", PNL, "DButton")

local PNL = {}

function PNL:Init()
	self:SetText("Job Terminal")
	self:SetSize(400, 600)
	self:Center()
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)

	local text = vgui.Create("DLabel", self)
	text:Dock(TOP)
	text:DockMargin(5, 15, 5, 0)
	text:SetContentAlignment(5)
	text:SetFont("fr_MenuBigFont")
	text:SetText("JOB BOARD")
	text:SetAutoStretchVertical( true )
	text:SetColor(color_black)	

	local notice = vgui.Create("FeatherNoticeBar", self)
	notice:Dock(TOP)
	notice:DockMargin(5, 10, 5, 0)
	notice:SetText(GetLang("jobboardtip"))
	notice:SetType(7)

	self.content = vgui.Create("PanelList", self)
	self.content:Dock(FILL)
	self.content:DockMargin(5, 10, 5, 5)
	self.content:EnableVerticalScrollbar()
	self.content:SetSpacing(10)
	self.content:SetPadding(10)
end

function PNL:RefreshJob()
	self.content:Clear()
	for k, v in ipairs(GAMEMODE.AvailableMissions) do
		if !v.taken then
			self:AddJob(v, k)
		end
	end
end

function PNL:AddJob(data, index)
	local btn = vgui.Create("FeatherMissionButton", self.content)
	btn:SetTall(50)
	btn:SetText(Format("%s (%s)", data.name, MoneyFormat(data.price)))
	btn:SetFont("fr_MenuFont")
	btn:SetColor(color_white)
	btn.DoClick = function()
		LocalPlayer():ConCommand("say /requestmission ".. index)
	end
	self.content:AddItem(btn)
end
vgui.Register("FeatherJob", PNL, "FeatherFrame")

netstream.Hook("FeahterJobMenu", function(data)
	GAMEMODE.AvailableMissions = data or {}

	if JOBLIST then
		if JOBLIST.Close then
			JOBLIST:Close()
		end
		JOBLIST = nil
		return
	end
	JOBLIST = vgui.Create("FeatherJob")
	JOBLIST:RefreshJob()
end)

netstream.Hook("FeahterJobUpdate", function(data)
	if data then
		GAMEMODE.AvailableMissions = data
	end

	if JOBLIST then
		if JOBLIST.Close then
			JOBLIST:RefreshJob()
		end
	end
end)

netstream.Hook("FeahterJobPing", function(data)
	if JOBLIST then
		if JOBLIST.Close then
			netstream.Start("FeahterJobPing")
		end
	end
end)