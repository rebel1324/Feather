function GM:PlayerInitialSpawn(client)
	client:SetTeam(TEAM_CITIZEN)
	client:loadFeatherData()

	local uniqueID = "fr_PayCheck"..client:SteamID()

	timer.Create(uniqueID, 30, 0, function()
		if (!IsValid(client)) then return timer.Remove(uniqueID) end
		
		if (hook.Run("PlayerCanReceivePay", client) != false) then
			local amount, reason = hook.Run("PlayerGetPayAmount", client)

			if (!amount or amount == 0) then
				return client:notify(reason or "You did not receive your pay.")
			end

			hook.Run("PlayerReceivePay", client, amount)
		end
	end)
end

function GM:ShutDown()
	for k, v in pairs(player.GetAll()) do
		v:saveFeatherData()
	end
end

function GM:PlayerReceivePay(client, amount)
	client:giveMoney(amount)
	client:notify("You have received a pay of $"..amount.." dollars!")
end

function GM:PlayerDisconnected(client)
	client:saveFeatherData()
end

function GM:PlayerCanReceivePay(client)
	return true
end

function GM:PlayerGetPayAmount(client)
	local job = self.Jobs[client:Team()]

	if (job and job.salary) then
		return job.salary
	else
		return false, "You did not receive a salary because you are unemployed."
	end
end

function GM:Notify(message, class, receiver)
	netstream.Start(receiver, "fr_Notify", message, class or NOTIFY_GENERIC)
end