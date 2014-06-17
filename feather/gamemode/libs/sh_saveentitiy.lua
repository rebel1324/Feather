// MAKE ARREST DONE
local playerMeta = FindMetaTable("Player")

if SERVER then
	GM.SaveEntity = {
		"feather_arrestboard",
		"feather_jobterminal",
		"feather_job_pckdest",
		"feather_socket",
	}

	local loadquery = "SELECT * FROM fr_entities WHERE _map = '%s'"
	local specquery = "SELECT * FROM fr_entities WHERE _map = '%s' AND _id = %s"
	local insertquery = "INSERT INTO fr_entities (_map, _id, _class, _vector, _angle) VALUES ('%s', %s, '%s', '%s', '%s')"
	local updatequery = "UPDATE fr_entities SET _vector = '%s', _angle = '%s' WHERE _map = '%s' AND _id = %s AND _class = '%s'"
	local dataquery = "UPDATE fr_entities SET _data = '%s', WHERE _map = '%s' AND _id = %s AND _class = '%s'"
	local deletequery = "DELETE FROM fr_entities WHERE _map = '%s' AND _id = '%s'"

	function GM:LoadEntityData()
		GAMEMODE.JailPos = {}

		cn.db.query(Format(loadquery, GetMap()), function(data)
			for k, v in ipairs(data) do
				local ent = ents.Create(v._class)
				ent:SetPos(SQL2Vector(v._vector))
				ent:SetAngles(SQL2Angle(v._angle))
				ent:Spawn()
				ent:Activate()
				ent.saveid = tonumber(v._id)

				if v._data then
					hook.Run("OnLoadEntityData", entity, v._data)
				end
			end
		end)
	end
	hook.Add("InitPostEntity", "FeatherLoadEntities", GM.LoadEntityData)
	
	hook.Add("OnEntityCreated", "FeatherSaveEnity", function(entity)
		if !GAMEMODE.EntLoaded then
			return
		end

		timer.Simple(0, function()
			if entity and entity:IsValid() then
				if table.HasValue(GAMEMODE.SaveEntity, entity:GetClass()) then
					entity.saveid = math.random(1, 9999999999)
					
					cn.db.query(Format(insertquery, GetMap(), entity.saveid, entity:GetClass(),
						Vector2SQL(entity:GetPos()), Angle2SQL(entity:GetAngles())), function(data)
					end)
				end
			end
		end)
	end)

	hook.Add("EntityRemoved", "FeatherDeleteEnity", function(entity)
		if GAMEMODE.Shutdown then
			if table.HasValue(GAMEMODE.SaveEntity, entity:GetClass()) then
				cn.db.query(Format(updatequery, Vector2SQL(entity:GetPos()), Angle2SQL(entity:GetAngles()), GetMap(), entity.saveid, entity:GetClass())
					, function(data) end)

				local encoded = hook.Run("OnSaveEntityData", entity)
				if (encoded and type(encoded):lower() == "string") then
					cn.db.query(Format(dataquery, encoded, GetMap(), entity.saveid))
				end
				return
			end
		end
		
		if table.HasValue(GAMEMODE.SaveEntity, entity:GetClass()) then
			cn.db.query(Format(specquery, GetMap(), entity.saveid), function(data)
				if (table.Count(data) != 0) then
					cn.db.query(Format(deletequery, GetMap(), entity.saveid))
				end
			end)
		end
	end)

	function GM:OnSaveEntityData(entity)
		if (entity and entity:IsValid() and entity.OnDataSave) then
			return entity:OnDataSave() -- returns serialized version of data.
		end
	end
	
	function GM:OnLoadEntityData(entity, encoded)
		if (entity and entity:IsValid() and entity.OnDataLoad) then
			entity:OnDataLoad(encoded) -- runs the loading code with encoded data.
		end
	end
end