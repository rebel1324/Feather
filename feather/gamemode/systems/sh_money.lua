local playerMeta = FindMetaTable("Player")

if (SERVER) then
	function playerMeta:giveMoney(amount)
		self:SetLocalVar("money", self:GetLocalVar("money", 0) + amount)
	end

	function playerMeta:takeMoney(amount)
		self:GiveMoney(-amount)
	end

	function playerMeta:setMoney(amount)
		self:SetLocalVar("money", amount)
	end
end

function playerMeta:getMoney()
	return self:GetLocalVar("money", 0)
end