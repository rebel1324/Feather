local playerMeta = FindMetaTable("Player")
-- ITEM STRUCTURE
/*
	['uniqueid'] = {
		name = 'SHIPMENT'

		price = 100,
		--desc = 'A Shipment that contains items' '** generic string decs.

		desc = function(data)
			return Format("A Shipment that contains %s of %s", data.amount, data.class)
		end,

		data = {
			entity = true,
			amount = 10,
			class = 'item_healthkit',
			price = 1000, -- data price overrides default price.
		},

		funcs = {
			onUse = {
			name = GetLang"use",
			cond = true, -- it could be function.
			func = function() 
				-- Shipment use func
				return true
			end},

			onDrop = {
			name = GetLang"drop",
			cond = true,
			func = function()
				-- Don't drop item.
				return true, false -- first arg is consume item, second arg is drop item.
			end},

			-- can add more.
		}
	}
*/
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

function playerMeta:GiveItem(item, amount, data, forced)
	
end

function playerMeta:GetItem(item)
	local inv = self:GetInventory()
	return inv[item] or {}
end

function playerMeta:GetItemSpec(item, conditions)
	-- get specific
end

function playerMeta:HasItem(item)

end

function playerMeta:GetItemCount()

end

function playerMeta:GetInventory()
	return self:GetLocalVar("inv")
end

local function InventoryPanelInit(self)
	self.content:Clear()
end

local function MainMenuAdd(panel)
	panel:AddButton(GetLang"menuinventory", function()
		InventoryPanelInit(panel)
	end)
end

hook.Add("OnMenuLoadButtons", "FeatherInventoryAdd", MainMenuAdd)

do
	feather.item = feather.item or {}
	feather.items = feather.items or {}
	feather.itemBases = feather.itemBases or {}

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