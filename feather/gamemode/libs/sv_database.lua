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
	
	CREATE TABLE IF NOT EXISTS fr_doordata (
		_entid int PRIMARY KEY,
		_map mediumtext,
		_title mediumtext,
		_hidden boolean,
		_owner mediumtext
	);
	
	CREATE TABLE IF NOT EXISTS fr_entities (
		_map mediumtext,
		_id int,
		_class mediumtext,
		_vector mediumtext,
		_angle mediumtext,
		_data mediumtext
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

	function playerMeta:LoadFeatherData()
		cn.db.query("SELECT _money, _inventory FROM fr_players WHERE _steamID = "..self:SteamID64(), function(data)
			if (IsValid(self)) then
				if (table.Count(data) == 0) then
					cn.db.query("INSERT INTO fr_players (_steamID, _money, _inventory) VALUES ("..self:SteamID64()..", 500, \"\")")
				end

				if data and data[1] then
					data = data[1]
					self:SetMoney(tonumber(data._money) or 500)

					MsgN("Loaded data for "..self:Name()..".")
				end

				hook.Call("PostLoadPlayerData", self)
			end
		end)
	end

	function playerMeta:SaveFeatherData()
		local query = "UPDATE fr_players SET _money = "..self:GetMoney()..", _inventory = \"\" WHERE _steamID = "..self:SteamID64()
		local name = self:Name()

		cn.db.query(query, function()
			MsgN("Feather has saved data for "..name..".")
		end)
	end
end