local function AddCheck(panel, key, var, name)
	local radio = vgui.Create("DCheckBoxLabel")
	radio:SetText(name or key)
	radio:SetValue(tonumber(var))
	radio:SetTextColor(color_black)
	radio:SetValue((type(var) == 'table') and (var.value) or (var))
	panel:AddItem(radio)

	radio.OnChange = function(pnl, value)
		netstream.Start("fr_SetConfig", key, value)
	end

	return radio
end
/*
local function AddSlider(panel, key, var)
	local slder = vgui.Create("DNumSlider")
	slder:SetText(key)
	slder.Label:SetTextColor(color_black)
	panel:AddItem(slder)

	return slder
end
*/
local function AddSlider(panel, key, var, name)
	local textpnl = vgui.Create("DPanel")
	
	local txt = vgui.Create("DLabel", textpnl)
	txt:Dock(TOP)
	txt:SetText(name or key)
	txt:SetTextColor(color_black)
	txt:DockMargin(0, 0, 0, 5)

	local txt = vgui.Create("DTextEntry", textpnl)
	txt:Dock(TOP)
	txt:SetValue((type(var) == 'table') and (var.value) or (var))
	
	textpnl:SetTall(45)
	textpnl:SetDrawBackground(false)
	panel:AddItem(textpnl)

	txt.OnEnter = function(pnl, value)
		local value = tonumber(txt:GetValue())
		netstream.Start("fr_SetConfig", key, value)
	end

	return textpnl
end

local function AddTextPanel(panel, key, var, name)
	local textpnl = vgui.Create("DPanel")
	
	local txt = vgui.Create("DLabel", textpnl)
	txt:Dock(TOP)
	txt:SetText(name or key)
	txt:SetTextColor(color_black)
	txt:DockMargin(0, 0, 0, 5)

	local txt = vgui.Create("DTextEntry", textpnl)
	txt:Dock(TOP)
	txt:SetValue((type(var) == 'table') and (var.value) or (var))
	
	textpnl:SetTall(45)
	textpnl:SetDrawBackground(false)
	panel:AddItem(textpnl)

	txt.OnEnter = function(pnl, value)
		local value = txt:GetValue()
		netstream.Start("fr_SetConfig", key, value)
	end

	return textpnl
end

local function ConfigPanelInit(panel)
	panel.content:Clear()
	panel.mods = {}

	local notice = vgui.Create("FeatherNoticeBar", panel.content)
	notice:SetType(7)
	panel.content:AddItem(notice)

	if LocalPlayer():IsSuperAdmin() then
		notice:SetText(GetLang("configtip"))
		local default, modded = feather.config.getAll()

		for k, v in pairs(default) do
			local varType = feather.config.getType(k)
			if (varType == "boolean") then
				panel.mods[k] = AddCheck(panel.content, k, modded[k] or v, v.desc)
			elseif (varType == "number") then
				panel.mods[k] = AddSlider(panel.content, k, modded[k] or v, v.desc)
			elseif (varType == "string") then
				panel.mods[k] = AddTextPanel(panel.content, k, modded[k] or v, v.desc)
			elseif (varType == "table") then

			else

			end
		end
	else
		notice:SetText(GetLang("configauthtip"))
	end
end

local function MainMenuAdd(panel)
	panel:AddButton(GetLang"menuconfig", function()
		panel:SetKeyboardInputEnabled(true)
		ConfigPanelInit(panel)
	end)	
end

hook.Add("OnMenuLoadButtons", "Feather_ConfigAdd", MainMenuAdd)
