if CLIENT then
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
end

GM.Missions = {}
GM.AvailableMissions = {}
GM.MapPos = {}

function GM:AddMission(job)
	self.Missions[job.uid] = job
end

function GM:AddMapPos(map, cat, pos)
	map = map:lower()
	GM.MapPos[map] = GM.MapPos[map] or {}
	GM.MapPos[map][cat] = GM.MapPos[map][cat] or {}
	table.insert(GM.MapPos[map][cat], pos)
end

function GM:GetMapPos(cat)
	local map = game.GetMap():lower()
	if !self.MapPos[map][cat] then
		return false
	end

	return table.Random(self.MapPos[map][cat])
end

function GM:OnMissionComplete(client)
	client:ClearMission()
end

function GM:GetMission(mission)
	return self.Missions[mission]
end

function GM:CanAcceptMission(client, index)
	if (client:IsArrested()) then
		client:notify(GetLang"yourearrested")
		return false
	end

	if (client:IsWanted()) then
		return false
	end

	index = tonumber(index)
	local info = self.AvailableMissions[index]
	if (!info or info.taken) then
		client:notify(GetLang"missiontaken")
		return false
	end

	if (self:GetMission()) then
		client:notify(GetLang"onmission")
		return false
	end

	if (client.nextMission and client.nextMission > CurTime()) then
		client:notify(GetLang"missiondelay")
		return false
	end
end

function GM:OnAcceptMission(client, index)
	index = tonumber(index)
	local info = self.AvailableMissions[index]
	if info then
		client.nextMission = CurTime() + self.MissionDelay

		self.AvailableMissions[index].taken = client
		client.missioninfo = info
		client.missioninfo.index = index

		client:AcceptMission(info.mission)

		local mission = GAMEMODE:GetMission(info.mission)
		mission.onAccept(client)
		client:notify(GetLang"missionaccept")
	end
end

function GM:RequestMission(client, index)
	if hook.Run("CanAcceptMission", client, index) == false then
		return false
	end

	hook.Run("OnAcceptMission", client, index)
end

local playerMeta = FindMetaTable("Player")
function playerMeta:GetMission()
	return self:GetNetVar("mission")
end

function playerMeta:AcceptMission(mission)
	self:SetNetVar("mission", mission)
end

function playerMeta:ClearMission(failed)
	local info = self.missioninfo
	if !info then
		FeatherError("No Clear Mission Provided.")
		return
	end

	local mission = GAMEMODE:GetMission(info.mission)
	if mission then
		if failed then
			mission.onFailed(self, info)
		else
			mission.onSuccess(self, info)
		end
		mission.onEnded(self, info)
	end

	if (GAMEMODE.AvailableMissions[tonumber(info.index)].client == self) then
		table.remove(GAMEMODE.AvailableMissions, info.index)
	end
	self.missioninfo = nil
	self:SetNetVar("mission", nil)
end

function GM:RefreshJobs()
	self.AvailableMissions = {}
	for i = 1, 10 do
		local mission = table.Random(self.Missions)
		if mission then
			table.insert(self.AvailableMissions, {
				name = table.Random(mission.names),
				price = math.random(mission.moneymin, mission.moneymax),
				mission = mission.uid,
				taken = false,
			})	
		end
	end

	timer.Simple(100, function()
		GAMEMODE:RefreshJobs()
	end)
end
GM:RefreshJobs()

GM:RegisterCommand({
	desc = "This command allows you to get some mission to earn some money.",
	syntax = "<UniqueID of the Mission>",
	category = "Market and Money",
	onRun = function(client, arguments)
		local mission = table.concat(arguments, " ")

		if (!mission or mission == "") then
			client:notify(GetLang("provide", "Unique ID."))
			return false
		end

		GAMEMODE:RequestMission(client, mission)

		return true
	end
}, "requestmission")
