print('Logging System.')

LOG_MAX = 100
LOG_LINES = {}
FILTER_SERVERACTION = 1
FILTER_USERACTION = 2
FILTER_USERCHAT = 4

function GM:AddLog(str, type)
	local filter = feather.config.get("chatFilter", 0)
	local date = os.date()
	str = Format("[%s] %s", date, str)

	netstream.Start("FeahterLog", str)
	table.insert(LOG_LINES, str)
	
	if (#LOG_LINES >= 100) then
		self:SaveLog()
	end
end

function GM:SaveLog()
	LOG_LINES = {}
end

function GM:SendLog()
end

if CLIENT then
	netstream.Hook("FeahterLog", function(str)
		print(str)
	end)
end