local playerMeta = FindMetaTable("Player")

GM.FoodList = {}

function playerMeta:GetHunger()
	return self:GetLocalVar("hunger", 0)
end

function playerMeta:GetHungerPercent()
	return math.Clamp(((self:GetHunger() - CurTime()) / GAMEMODE.HungerTime), 0 ,1)
end

function GM:AddFood(uniqueID, name, model, hunger, price, buyable)
	GM.FoodList[uniqueID] = {
		name = name,
		model = model,
		hunger = hunger,
		price = price,
		buyable = buyable or false,
	}

	return GM.FoodList[uniqueID]
end

function GM:GetFood(uniqueID)
	return self.FoodList[uniqueID]
end

if SERVER then
	function playerMeta:SetHunger(amt)
		self:SetLocalVar("hunger", CurTime() + amt)
	end

	function playerMeta:AddHunger(amt)
		local n = self:GetHunger() - CurTime()
		self:SetHunger(math.Clamp(( (n < 0) and (amt) or (n + amt) ), 0, GAMEMODE.HungerTime))
	end

	function GM:OnPlayerHunger(client)
		client:SetHealth(client:Health() - 10)

		if client:Health() <= 0 then
			client:Kill()
		end
	end

	function GM:HungerThink()
		local cur = CurTime()

		if GAMEMODE.HungerMode then
			for k, v in ipairs(player.GetAll()) do
				if !v.nextHunger or v.nextHunger < cur and v:Alive() then
					if v:GetHunger() < cur then
						hook.Run("OnPlayerHunger", v)
					end

					v.nextHunger = cur + GAMEMODE.HungerThinkRate
				end
			end
		end
	end
	hook.Add("Think", "FeatherHungerThink", GM.HungerThink)

	function GM:PlayerHungerInit(client)
		client:SetHunger(self.HungerTime)
	end
	hook.Add("PlayerSpawn", "FeatherHungerInit", function(client)
		GAMEMODE:PlayerHungerInit(client)
	end)
end