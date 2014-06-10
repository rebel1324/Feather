--[[
	You can choose the following:
		"sqlite" - Local database (found in sv.db)
		"mysqloo" - To be implemented
		"tmysql4" - To be implemented
--]]
local DB_MODULE = "sqlite"
local DB_USERNAME = "root"
local DB_PASSWORD = "password"
local DB_DATABASE = "feather"
local DB_PORT = 3306

local QUERY_CREATE_SQLITE = [[
	CREATE TABLE IF NOT EXISTS fr_players (
		_steamID int PRIMARY KEY,
		_money int,
		_inventory mediumtext
	);

	CREATE TABLE IF NOT EXISTS fr_licenses (
		_uniqueID mediumtext unique,
		_name mediumtext,
		_price int
	);

	CREATE TABLE IF NOT EXISTS fr_jailpos (
		_map mediumtext,
		_vector mediumtext
	);
]]

hook.Add("Initialize", "fr_Database", function()
	cn.db.initialize(DB_MODULE, function()
		cn.db.query(QUERY_CREATE_SQLITE)

		MsgN("Feather has connected to the database.")
	end, DB_USERNAME, DB_PASSWORD, DB_DATABASE, DB_PORT)
end)

do
	local playerMeta = FindMetaTable("Player")

	function playerMeta:loadFeatherData()
		cn.db.query("SELECT _money, _inventory FROM fr_players WHERE _steamID = "..self:SteamID64(), function(data)
			if (IsValid(self)) then
				if (table.Count(data) == 0) then
					cn.db.query("INSERT INTO fr_players (_steamID, _money, _inventory) VALUES ("..self:SteamID64()..", 500, \"\")")
				end

				self:SetMoney(tonumber(data._money) or 500)

				MsgN("Loaded data for "..self:Name()..".")
			end
		end)
	end

	function playerMeta:saveFeatherData()
		local query = "UPDATE fr_players SET _money = "..self:GetMoney()..", _inventory = \"\" WHERE _steamID = "..self:SteamID64()
		local name = self:Name()

		cn.db.query(query, function()
			MsgN("Feather has saved data for "..name..".")
		end)
	end
end