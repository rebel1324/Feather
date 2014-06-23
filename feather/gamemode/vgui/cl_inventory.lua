print(1)
print('inventory icon')
print('inventory panel') -- for repeditive use like trade or etc.


local test = {
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/PropaneCanister001a.mdl",
	"models/props_c17/BriefCase001a.mdl",
}

local function CreateCategory(panel)
	local cat = vgui.Create("DIconLayout", panel)
	--cat:SetLabel("wow")
	cat:SetSpaceX(4)
	cat:SetSpaceY(4)
	panel:AddItem(cat)
	return cat
end

local size = 64
local function InventoryPanelInit(self)
	self.content:Clear()

	local cat = CreateCategory(self.content)
	
	for uid, itemdata in pairs(feather.item.getAll()) do
		local item = cat:Add("FeatherItemIcon")
		item:SetSize(size, size)
		item:SetItem(itemdata)
	end

	cat:SizeToContents()
end

local function MainMenuAdd(panel)
	panel:AddButton(GetLang"menuinventory", function()
		InventoryPanelInit(panel)
	end)
end

hook.Add("OnMenuLoadButtons", "FeatherInventoryAdd", MainMenuAdd)

local PNL = {}

function PNL:Init()
	self.tip = vgui.Create("FeatherTooltip")
end

function PNL:SetItem(item)
	if self.tip then
		local desc = item.desc
		if (item.desc and type(item.desc) == "function") then
			desc = item.desc()
		end

		self.tip:SetText(item.name, desc)
		self:SetModel(item.model)
	end
end

function PNL:Paint( w, h )
	surface.SetDrawColor(210, 215, 211)
	surface.DrawRect(0, 0, w, h)
end

function PNL:OnCursorEntered()
	self.Hovered = true
	if self.tip and self.tip.SetVisible then
		self.tip:SetVisible(true)
	end
end

function PNL:OnCursorExited()
	self.Hovered = false
	if self.tip and self.tip.SetVisible then
		self.tip:SetVisible(false)
	end
end

function PNL:OnRemove()
	if self.tip and self.tip.Close then
		self.tip:Close()
	end
end

function PNL:SetModel( mdl, skin, bdg )
	if (!mdl) then debug.Trace() return end
	self:SetModelName( mdl )
	self:SetSkinID( skin )
	if ( tostring(bdg):len() != 9 ) then
		bdg = "000000000"
	end
	self.m_strBodyGroups = bdg;
	self.Icon:SetModel( mdl, skin, bdg )
end

function PNL:PaintOver(w, h)
	local gap = 0
	surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(0, 0, w, h)

	gap = 1
	if (self.Hovered) then
		surface.SetDrawColor(207, 0, 15)
	else
		surface.SetDrawColor(149, 165, 166)
	end
	surface.DrawOutlinedRect(gap, gap, w - gap*2, h - gap*2)
end

vgui.Register("FeatherItemIcon", PNL, "SpawnIcon")	