local playerMeta = FindMetaTable("Player")

if SERVER then

	function GM:CanRequestHit(client)

	end

	function GM:CanAcceptHit(client)
		if !client:IsArrested() then
			return false
		end
	end

	function GM:OnHitAccepted(client, request)

	end

	function GM:OnHitFailed(client, reason)
		client.target.targeted = nil
		client.target = nil
	end

	function GM:OnHitSuccess(client, reason)
		client.target.targeted = nil
		client.target = nil
	end

	hook.Add("PlayerDisconnected", "HitFailed", function(client)
		if client.targeted then
			hook.Call("OnHitFailed", GAMEMODE, client, reason) 
		end
	end)

	hook.Add("PlayerDeath", "HitFailed", function(client)
		if client:Team() == TEAM_HITMAN then
			hook.Call("OnHitFailed", GAMEMODE, client, reason) 
		end

		if client.targeted then
			if client.targeted == TEAM_HITMAN then
				hook.Call("OnHitSuccess", GAMEMODE, client, reason) 
			end
		end
	end)

	function playerMeta:RequestHit(client, hit, reason)
		self.target = client
		self.target.targeted = self
	end

	function playerMeta:CancelHit(name)
		hook.Call("OnHitFailed", GAMEMODE, self, reason) 
	end

end