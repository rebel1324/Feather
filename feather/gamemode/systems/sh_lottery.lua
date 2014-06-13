if SERVER then
	GM.LotteryInfo = {}
	GM.NextLottery = 0

	function GM:StartLottery(client, prize)
		local info = self.LotteryInfo
		info.prizepool = prize
		info.players = {}
		self.NextLottery = CurTime() + 10

		local funcs = {
			ondone = function() GAMEMODE:OnLotteryOver() end,
			onvote = function(client, yes)
				if (yes) then
					GAMEMODE:EnterLottery(client, prize)
				end
			end,
		}
		self:StartVote(client, GetLang("lotteryvote", MoneyFormat(prize)), 10, funcs)

		for k, v in pairs(player.GetAll()) do
		end
	end
	
	function GM:OnLotteryOver()
		local info = self.LotteryInfo
		local multi = #info.players
		for k, v in ipairs(info.players) do
			if !v:IsValid() then
				table.remove(info.players, k)
			end
		end

		local total = info.prizepool*multi
		local lucky = table.Random(info.players)
		if lucky and lucky:IsValid() then
			NotifyAll(GetLang("lotterywinner", lucky:Name(), MoneyFormat(total)))
			lucky:GiveMoney(total)
		end
	end

	function GM:EnterLottery(client, prize)
		if hook.Run("CanEnterLottery", client, prize) == false then
			return
		end

		client:notify(GetLang("purchase", GetLang("lotteryticket"), MoneyFormat(prize)))
		local info = self.LotteryInfo
		table.insert(info.players, client)
	end

	function GM:CanEnterLottery(client, prize)
		if (client:IsArrested()) then
			client:notify(GetLang"yourearrested", 1)
			return
		end

		local info = self.LotteryInfo
		if (table.HasValue(info.players, client)) then
			client:notify(GetLang"lotteryalreadyjoined", 1)
			return
		end

		return client:PayMoney(prize)
	end
	
	function GM:CanStartLottery(client, prize)
		prize = math.Clamp(prize, 0, math.huge)
		if (prize <= 0) then
			return	
		end

		if !GAMEMODE:GetJobData(client:Team()).mayor then
			client:notify(GetLang"bemayor", 1)
			return
		end

		if (self.NextLottery > CurTime()) then
			client:notify(GetLang("lotterycooldown", math.ceil(self.NextLottery - CurTime())), 1)
			return
		end

		if (GetNetVar("lockdown")) then
			client:notify(GetLang"cantdolockdown", 1)
			return
		end

		return client:PayMoney(prize)
	end
end

GM:RegisterCommand({
	desc = "This command starts lottery for players who have the money.",
	syntax = "<Enter Fee>",
	onRun = function(client, arguments)
		local prize = tonumber(arguments[1])

		if hook.Run("CanStartLottery", client) == false then
			return 
		end
		
		GAMEMODE:StartLottery(client, prize)
	end
}, "lottery")