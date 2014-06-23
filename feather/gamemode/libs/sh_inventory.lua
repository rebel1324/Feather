local playerMeta = FindMetaTable("Player")
-- Inventory Structure
/*
	local tbl = player:GetNetVar("inv")

	>> tbl = {
		['uniqueid '] = {
			[1] = {
				amount = 1,
				data = {
					--stuffs
				},
			},
			[2] = {
				amount = 3
				data = {
					--stuffs
				},
			}
		}
	}
*/

-- If partially matches, call this function.
local function CheckDataEqual(data1, data2)
	for k, v in pairs(data1) do
		if (v != data2.k) then
			return false
		end
	end

	return true
end

-- If completely matches, call this function.
local function CheckDataCompleteEqual(data1, data2)
	for k, v in pairs(data1) do
		if (v != data2.k) then
			return false
		end
	end

	for k, v in pairs(data2) do
		if (v != data1.k) then
			return false
		end
	end

	return true
end


function playerMeta:GiveItem(item, amount, data, forced)
	local item = self:GetItem(item)
	local inv = self:GetInventory()
	local itemdata = feather.item.get(item)
	data = data or {}

	if (itemdata) then
		if (item) then
			for k, v in pairs(item) do
				if (CheckDataCompleteEqual(v.data, data)) then
					v.amount = v.amount + amount

					return
				end
			end
		end

		data = table.Merge(data, itemdata.data)
		table.insert(inv, {amount = amount, data = data})
		self:SetNetVar("inv", inv) -- god, forsake me. I made whole table sync!!!!!!!!!!!!!! NOOOOOOOOOOOOO
	end
end

function playerMeta:GetItem(item) -- yes, get item.
	local inv = self:GetInventory()
	return inv[item] or {}
end

function playerMeta:GetItemSpec(item, conditions)
	local item = self:GetItem(item)
	for k, v in pairs(item) do
		if (CheckDataEqual(conditions, v.data)) then
			return item.k
		end
	end

	return
end

function playerMeta:HasItem(item, amount)
	local amt = self:GetItemCount(item)

	return (amt >= amount)
end

function playerMeta:GetItemCount(item)
	local tbl = self:GetItem(item)
	local amt = 0
	for k, v in ipairs(tbl) do
		if (v and v.amount )then
			amt = amt + v.amount
		end
	end

	return (amt or 0)
end

function playerMeta:GetInventory()
	return self:GetLocalVar("inv")
end

do
	-- heck, for food and stuffs.
	hook.Add("OnFoodCreated", "ItemizeFood", function(fooddata, uid)
		ITEM = feather.items[uid] or {}
			ITEM.key = uid
			ITEM.name = fooddata.name
			ITEM.desc = "A Food that you can eat."
			ITEM.price = fooddata.price
			ITEM.model = fooddata.model

			feather.items[uid] = ITEM
		ITEM = nil
	end)

	feather.item = feather.item or {}
	feather.items = feather.items or {}
	feather.itemBases = feather.itemBases or {}

	function feather.item.get(class)
		return feather.items[class]
	end

	function feather.item.getAll()
		return feather.items
	end

	function feather.item.load(directory)
		directory = directory or "feather/data/items"

		for k, v in ipairs(file.Find(directory.."/base/*.lua", "LUA")) do
			local name = string.StripExtension(v)

			BASE = feather.itemBases[name] or {}
				BASE.key = name

				if (SERVER) then
					AddCSLuaFile(directory.."/base/"..v)
				end

				include(directory.."/base/"..v)
				feather.itemBases[name] = ITEM				
			BASE = nil
		end

		for k, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
			local name = string.StripExtension(v)

			ITEM = feather.items[name] or {}
				ITEM.key = name
				ITEM.name = "Unknown"
				ITEM.desc = "No description available."
				ITEM.price = 0

				function ITEM:call(method, client, entity, ...)
					self.client = client
					self.entity = entity
						if (self[method]) then
							local result = {self[method](self, ...)}
						end
					self.client = nil
					self.entity = nil

					return unpack(result)
				end

				if (SERVER) then
					AddCSLuaFile(directory.."/"..v)
				end

				include(directory.."/"..v)

				if (ITEM.base) then
					if (feather.itemBases[ITEM.base]) then
						feather.items[name] = table.Inheirt(ITEM, feather.itemBases[ITEM.base])
					else
						ErrorNoHalt("Item '"..name.."' has an invalid base ("..ITEM.base..")! Not registering...\n")
					end
				else
					feather.items[name] = ITEM
				end
			ITEM = nil
		end
	end
end