cn.db = cn.db or {}
cn.db.module = "sqlite"

function cn.db.initialize(mode, callback, hostname, username, password, port)
	if (mode == "sqlite") then
		cn.db.module = "sqlite"

		if (callback) then
			callback()
		end
	end
end

function cn.db.escape(value)
	return sql.SQLStr(value)
end

function cn.db.query(value, callback)
	if (cn.db.module == "sqlite") then
		local result = sql.Query(value)

		if (result == nil) then
			result = {}
		end

		if (!result) then
			MsgN("* Query: "..value)
			MsgN("* Error: "..sql.LastError())
		elseif (callback) then
			callback(result)
		end
	end
end