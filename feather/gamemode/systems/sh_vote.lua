if SERVER then	
	GM.VoteQueue = {}

	function GM:StartVote(starter, text, time, funcs, uniqueid, size)
		if (!funcs) then
			return false	
		end

		if hook.Run("CanVoteStart", starter) == false then
			return false
		end

		if !uniqueid then
			if starter then
				uniqueid = starter:SteamID64()
			else
				uniqueid = "SERVER"
			end
		end

		local tid = uniqueid .. "_" .. (uniqueid or math.random(10000, 99999))
		time = time or 30

		netstream.Start(player.GetAll(), "SendVoteWindow", {tid, text, time})
		GAMEMODE.VoteQueue[tid] = { funcs = funcs }
		hook.Run("OnVoteStart")

		funcs.onsuccess = funcs.onsuccess or function() end
		funcs.onfailed = funcs.onfailed or function() end

		timer.Create(tid, time, 1, function()
			if (funcs.ondone) then
				funcs.ondone(GAMEMODE.VoteQueue[tid])
			else
				local queue = GAMEMODE.VoteQueue[tid]
				if queue then
					local votedplayers = #queue
					local yes, no = 0, 0
					for k, v in pairs(queue) do
						if v == true then
							yes = yes + 1
						else
							no = no + 1
						end	
					end

					if (yes > 0 and (votedplayers / 2) <= yes and yes > no) then
						funcs.onsuccess(starter, tid)
					else
						funcs.onfailed(starter, tid)
					end
				end
			end

			GAMEMODE.VoteQueue[tid] = nil
		end)
	end

	netstream.Hook("SendVote", function(client, data)
		if hook.Run("CanPlayerThrowVote") == false then
			client:notify(GetLang"cantvote")
			return
		end

		local queue = GAMEMODE.VoteQueue[data[1]]

		if !queue then
			error(GetLang("invalid", "vote"))
			return
		end

		if queue.funcs and queue.funcs.onvote then
			queue.funcs.onvote(client, data[2])
		end

		queue[client] = data[2]
	end)
else
	local PNL = {}

	function PNL:Init()
		self:SetSize(150, 150)
		self.time = CurTime() + 5

		self.label = vgui.Create("DLabel", self)

		self.yes = vgui.Create("DButton", self)
		self.yes:SetSize(69, 25)
		self.yes:SetPos(5, 120)
		self.yes:SetText(GetLang"yes")
		self.yes:SetColor(color_black)
		self.yes.DoClick = function()
			netstream.Start("SendVote", {self.uid, true})
			self:Close()
		end

		self.no = vgui.Create("DButton", self)
		self.no:SetSize(69, 25)
		self.no:SetPos(76, 120)
		self.no:SetText(GetLang"no")
		self.no:SetColor(color_black)
		self.no.DoClick = function()
			netstream.Start("SendVote", {self.uid, false})
			self:Close()
		end

		surface.PlaySound("HL1/fvox/bell.wav")
	end

	function PNL:SetTime(t)
		self.time = CurTime() + t
	end
	
	function PNL:SetVoteText(str)
		self.label:SetText(str)
		self.label:DockMargin(5, 5, 5, 5)
		self.label:Dock(TOP)
		self.label:SetWrap(true)
		self.label:SetAutoStretchVertical( true )
		self.label:SetFont("fr_VoteFont")
		self.label:SetColor(color_black)
	end

	function PNL:Think()
		self:SetText(GetLang("votetime", math.ceil(self.time - CurTime())))

		if (self.time < CurTime()) then
			self:Close()
		end
	end
	vgui.Register("FeatherVote", PNL, "FeatherFrame")

	GM.VoteWindows = {}

	hook.Add("Think", "VoteReplace", function()
		for k, v in pairs(GAMEMODE.VoteWindows) do
			if !v or !v:IsVisible() then
				table.remove(GAMEMODE.VoteWindows, k)
				continue
			end

			local w, h = ScrW(), ScrH()
			local ww, wh = v:GetWide(), v:GetTall()
			v:SetPos(ww * (k-1) + ((k-1)*5), h/2 - wh/2)
		end
	end)

	netstream.Hook("SendVoteWindow", function(data)
		local vote = vgui.Create("FeatherVote")
		vote:SetVoteText(data[2])
		vote:SetTime(data[3])
		vote.uid = data[1]

		table.insert(GAMEMODE.VoteWindows, vote)
	end)
end