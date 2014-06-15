local playerMeta = FindMetaTable("Player")

function playerMeta:GiveItem(item, amount, data)
	
end

function playerMeta:GetItem(item)
	local inv = self:GetItems()
	return inv[item]
end

function playerMeta:GetItems()
	return self:GetLocalVar("inv")
end

local function InventoryPanelInit(self)
	self.content:Clear()

end

local function MainMenuAdd(panel)
	panel:AddButton("Inventory", function()
		InventoryPanelInit(panel)
	end)
end

hook.Add("OnMenuLoadButtons", "FeatherInventoryAdd", MainMenuAdd)

do
	feather.item = feather.item or {}
	feather.items = feather.items or {}
	feather.itemBases = feather.itemBases or {}

	function feather.item.load(directory)
		for k, v in ipairs(file.Find((directory or "feather/gamemode/items/base").."/*.lua", "LUA")) do
			local name = string.StripExtension(v)

			BASE = feather.itemBases[name] or {}
				BASE.key = name

				if (SERVER) then
					AddCSLuaFile("items/base/"..v)
				end

				include("items/base/"..v)
				feather.itemBases[name] = ITEM				
			BASE = nil
		end

		for k, v in ipairs(file.Find((directory or "feather/gamemode/items").."/*.lua", "LUA")) do
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
					AddCSLuaFile("items/"..v)
				end

				include("items/"..v)

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