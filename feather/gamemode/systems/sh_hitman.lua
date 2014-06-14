local playerMeta = FindMetaTable("Player")

if SERVER then
	function GM:CanRequestHit(client, target, price)
		price = price or GAMEMODE.HitCost

		if (client:IsArrested()) then
			client:Notify("yourearrested")
			return false
		end

		if (!client:PayMoney(0 or price)) then
			return false
		end

		if (!target:IsValid()) then
			client:notify(GetLang"invalidplayer")
			return false
		end

		if (target.targeted) then
			client:notify(GetLang"hitlisted")
			return false
		end

		if ((target == client) or (target:Team() == TEAM_HITMAN)) then
			client:notify(GetLang"cantdo")
			return false
		end
	end

	function GM:CanAcceptHit(client)
		if (client:IsArrested()) then
			client:Notify("yourearrested")
			return false
		end

		if (client:Team() != TEAM_HITMAN) then
			client:notify(GetLang"mustbehitman")
			return false
		end

		if (client.target or client.request) and (client.target:IsValid() or client.request:IsValid()) then
			--client:notify(GetLang"oncontract")
			return false
		end
	end

	function GM:OnHitAccepted(client, target, request, money)
		client.target = target
		client.request = request

		client.target.targeted = client
		client.request.requested = client
		client:SetNetVar("onhit", true)
	end

	function GM:OnHitFailed(client)
		if (client.target or client.request) and (client.target:IsValid() or client.request:IsValid()) then
			NotifyAll(GetLang("hitfailed", client:Name()))

			client.target.targeted = nil
			client.request.requested = nil

			client.target = nil
			client.request = nil

			client:SetNetVar("onhit", nil)
		end
	end

	function GM:OnHitSuccess(client)
		NotifyAll(GetLang("hitsuccess", client:Name()))
		client.request:notify(GetLang("requesthitsuccess", client:Name(), client.target:Name()))

		client.target.targeted = nil
		client.request.requested = nil

		client.target = nil
		client.request = nil

		client:SetNetVar("onhit", nil)
	end

	hook.Add("PlayerDisconnected", "HitFailed", function(client)
		if client.targeted then
			hook.Run("OnHitFailed", client) 
		end
	end)

	hook.Add("PlayerDeath", "HitFailed", function(client)
		if client:Team() == TEAM_HITMAN and client:HasHitTarget() then
			hook.Run("OnHitFailed", client) 
		end

		if client.targeted then
			hook.Run("OnHitSuccess", client.targeted) 
		end
	end)

	function playerMeta:HasHitTarget()
		return self.target, self.request
	end

	function playerMeta:RequestHit(client, target, request, money)
		local condition1 = hook.Run("CanRequestHit", request, target, money)
		local condition2 = hook.Run("CanAcceptHit", client)

		if (condition1 != false and condition2 != false) then
			hook.Run("OnHitAccepted", client, target, request, money)
			client:notify(GetLang("hitrequested", target:GetName()))	
			request:notify(GetLang("hitrequested", target:GetName()))	
		else
			print('failed')
		end
	end

	function playerMeta:CancelHit(name)
		hook.Run("OnHitFailed", self) 
	end
end

GM:RegisterCommand({
	category = "Hitman",
	desc = "This command allows you to make a hit contract to certain/random hitman.\nYou can specify the hitman who will carry on your contracy by providing additional name after the target's name.",
	syntax = "<Target ID> [Hitman's name]",
	onRun = function(client, arguments)
		local target = arguments[1]
		local hitman = arguments[2]

		local hittarget, contractor
		if target then
			hittarget = FindPlayer(target)

			if hitman then
				contractor = FindPlayer(hitman)
			else
				contractor = FindRandomPlayerWithJob(TEAM_HITMAN)
			end
		end

		if (!hittarget or !contractor or !hittarget:IsValid() or !contractor:IsValid()) then
			client:notify(GetLang("invalidplayer"))
			return
		end

		client:RequestHit(contractor, hittarget, client)
	end
}, "requesthit")

GM:RegisterCommand({
	category = "Hitman",
	desc = "This command allows hitman to cancel the hit contract what he's on.",
	onRun = function(client, arguments)
		hook.Run("OnHitFailed", client) 
	end
}, "cancelhit")