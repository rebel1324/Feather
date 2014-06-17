function GM:CreateJob(name, color, job)
	local index = table.insert(self.Jobs, job)
		team.SetUp((#self.Jobs), name, color, false)
	return (#self.Jobs)
end

function GM:GetJobData(index)
	return self.Jobs[index] or nil
end

GM:RegisterCommand({
	desc = "This commands allows you to switch over to other job from your current job.\nYour job-specific items/entities could be removed by switching the job.",
	syntax = "<job name/uniqueID>",
	onRun = function(client, arguments)
		local job = arguments[1]

		for k, v in ipairs(GAMEMODE.Jobs) do
			if v.cmd then
				if string.lower(type(v.cmd)) == "table" then
					for _, cmd in ipairs(v.cmd) do
						if cmd == job then
							GAMEMODE:BecomeJob(client, client:Team(), k)

							return
						end
					end
				else
					if v.cmd == job then
						GAMEMODE:BecomeJob(client, client:Team(), k)

						return
					end
				end
			end
		end

		client:notify(GetLang"invalidjob")
	end
}, "job")

GM:RegisterCommand({
	desc = "This commands allows you to make another player step down from his job.\nAbusing this command will get you banned/kicked.",
	syntax = "<Target's name> <reason>",
	onRun = function(client, arguments)
		local target = arguments[1]

		if !target or target == "" then
			client:notify(GetLang"invalidtext")
			return false
		end

		local targetplayer = FindPlayer(target)
		table.remove(arguments, 1)
		local reason = table.concat(arguments, " ")

		if !targetplayer or !targetplayer:IsValid() then
			client:notify(GetLang"invalidplayer")
			return false
		end

		if !reason or reason == "" then
			client:notify(GetLang"invalidreason")
			return false
		end

		GAMEMODE:Demote(client, targetplayer, reason)
	end
}, "demote")