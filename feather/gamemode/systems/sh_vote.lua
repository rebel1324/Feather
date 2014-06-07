if SERVER then	
	function GM:StartVote(starter, title, text, time, onsucess, onfailed, uniqueid)
		if hook.Run("CanVoteStart", starter) == false then
			return false
		end
		
		local tid = starter:SteamID64() .. "_" .. title or uniqueid
		hook.Run("OnVoteStart")

		timer.Create(tid, time, 1, function()
			if (!IsValid(starter)) then
				timer.Remove(tid)

				return
			end
		end)
	end
end