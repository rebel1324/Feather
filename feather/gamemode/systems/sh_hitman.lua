local playerMeta = FindMetaTable("Player")

if SERVER then

	function GM:CanRequestHit(client)
	end

	function GM:CanAcceptHit(client)
	end

	function GM:OnHitAccepted(client, request)
	end

	function GM:OnHitFailed(client)
	end
	hook.Add("PlayerDeath", "HitFailed", function(client)
		// if player is hitman
		// hook.Call("OnHitFailed", GAMEMODE, client) 
	end)

	function playerMeta:RequestHit(client, hit, reason)
		self.target = client
	end

	function playerMeta:CancelHit(name)
		if self.target then
			self.target = nil
		end
	end

end