// GOTTA ADDED MORE
function StringMatches(a, b)
	if (a == b) then
		return true
	end

	if (string.lower(a) == string.lower(b)) then
		return true
	end

	if (string.find(a, b) or string.find(b, a)) then
		return true
	end

	a = string.lower(a)
	b = string.lower(b)

	if (string.find(a, b) or string.find(b, a)) then
		return true
	end

	return false
end

function GetMap()
	return string.lower(game.GetMap())
end

function IsEntityClose(pos, range, class)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		if v:GetClass() == class then
			return true
		end
	end

	return false
end

function MoneyFormat(num)
	return GAMEMODE.Currency .. string.Comma(num)
end

function NameToJobIndex(name)
	for k, v in pairs(team.GetAllTeams()) do
		if (StringMatches(team.GetName(k), name)) then
			return k
		end
	end
end