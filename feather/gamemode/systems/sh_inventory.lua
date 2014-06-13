local playerMeta = FindMetaTable("Player")

function playerMeta:GiveItem()

end

function playerMeta:GetItem()

end

function playerMeta:GetItems()

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