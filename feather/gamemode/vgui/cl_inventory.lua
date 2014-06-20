print(1)
print('inventory icon')
print('inventory panel') -- for repeditive use like trade or etc.


local test = {
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/PropaneCanister001a.mdl",
	"models/props_c17/BriefCase001a.mdl",
}

local function InventoryPanelInit(self)
	self.content:Clear()

	for k, v in ipairs(test) do
		local item = vgui.Create("FeatherItemIcon", self.content)
		item:SetSize(64, 64)
		self.content:AddItem(item)
	end
end

local function MainMenuAdd(panel)
	panel:AddButton(GetLang"menuinventory", function()
		InventoryPanelInit(panel)
	end)
end

--hook.Add("OnMenuLoadButtons", "FeatherInventoryAdd", MainMenuAdd)


local PNL = {}

function PNL:SetItem()
end

function PNL:PaintOverHovered(w, h)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("FeatherItemIcon", PNL, "SpawnIcon")	