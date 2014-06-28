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

function GM:InsertItem(tbl, id, amt, data)
	if (amt < 0) then
		return
	end

	tbl = tbl or {}
	tbl[id] = tbl[id] or {}
	local item = {}

	if (data) then
		item.data = data
	end

	table.insert(tbl[id], item)

	return tbl
end

function GM:RemoveItem(tbl, id, amt, data, anything)
	if (amt < 0 or !tbl or tbl[id]) then
		return
	end

	for k, v in ipairs(tbl[id]) do
		if (anything) then
			table.remove(tbl[id], k)
			return
		end

		if (data) then
			if (CheckDataCompleteEqual(v.data, data)) then
				table.remove(tbl[id], k)
				return
			end
		else
			if (!v.data or table.Count(v.data) == 0) then
				table.remove(tbl[id], k)
				return
			end
		end
	end

	return tbl
end

function playerMeta:GiveItem(item, amount, data, forced)
	local inv = self:GetInventory() or {}
	local itemdata = feather.item.get(item)
	local t = table.GetKeys(feather.item.getAll())
	if (itemdata) then
		print(2)
		if (itemdata.data or data) then
			data = data or {}
			data = table.Merge(data, itemdata.data)
		end

		inv = GAMEMODE:InsertItem(inv, item, amount, data)
		PrintTable(inv)
		self:SetNetVar("inv", inv) -- god, forsake me. I made whole table sync!!!!!!!!!!!!!! NOOOOOOOOOOOOO
	end
end

local function itemgo(cliend, cmd, args)
	local client = FindPlayer(table.concat(args, " "))

	client:GiveItem("fastfood", 1)
end
concommand.Add("testitem", itemgo)

function playerMeta:GetItems(item) -- yes, get items.
	local inv = self:GetInventory()

	return inv[item] or {}
end

function playerMeta:GetItemSpec(item, conditions, complete)
	local items = self:GetItems(item)

	for k, v in ipairs(items) do
		if (complete) then
			if (CheckDataEqual(conditions, v.data or {})) then
				return k, v
			end
		else
			if (CheckDataCompleteEqual(conditions, v.data or {})) then
				return k, v
			end
		end
	end

	return
end

function playerMeta:HasItem(item, amount)
	local amt = self:GetItemCount(item)

	return (amt >= amount)
end

function playerMeta:GetItemCount(item)
	local items = self:GetItems(item)

	return table.Count(items)
end

function playerMeta:GetInventory()
	return self:GetLocalVar("inv") or {}
end

do
	-- heck, for food and stuffs.
	hook.Add("OnFoodDataCreated", "ItemizeFood", function(fooddata, uid)
		if feather.items then
			ITEM = feather.items[uid] or {}
				ITEM.key = uid
				ITEM.name = fooddata.name
				ITEM.desc = "A Food that you can eat."
				ITEM.price = fooddata.price
				ITEM.model = fooddata.model

				feather.items[uid] = ITEM
			ITEM = nil
		end
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