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

local function AddTablePanel(panel, key, var, name)
	local textpnl = vgui.Create("DPanel")
	
	local txt = vgui.Create("DLabel", textpnl)
	txt:Dock(TOP)
	txt:SetText(name or key)
	txt:SetTextColor(color_black)
	txt:DockMargin(0, 0, 0, 5)

	
	local dlist = vgui.Create("DListView", textpnl)
	dlist:Dock(FILL)
	dlist:SetMultiSelect(false)
	local wow = dlist:AddColumn("key")
	wow:SetWide(1)
	dlist:AddColumn("value")

	local tbl = (type(var) == 'table') and (var.value) or (var)
	if tbl then
		for k, v in pairs(tbl) do
			dlist:AddLine(k, tostring(v))
			dlist.data = v
			dlist.datakey = k
		end	
	end

	dlist.OnClickLine = function(pnl, line)
		if (input.IsMouseDown(MOUSE_LEFT)) then
			Derma_StringRequest("Enter the value to set", "Modify Table Value", pnl.data, function(data)
				tbl[dlist.datakey] = data
				netstream.Start("fr_SetConfig", key, tbl)
			end)
		elseif (input.IsMouseDown(MOUSE_RIGHT)) then
			local menu = DermaMenu()

			local option = menu:AddOption("Delete Row", function()
			end)

			local option = menu:AddOption("Modify Row", function()
			end)

			local option = menu:AddOption("Add Row", function()
				Derma_StringDoubleRequest("Enter the value to add", "Modify Table Value", pnl.data, function(data)
					--tbl[dlist.datakey] = data
					--netstream.Start("fr_SetConfig", key, tbl)
				end)
			end)

			menu:Open()
		end
	end

	textpnl:SetTall(150)
	textpnl:SetDrawBackground(false)
	panel:AddItem(textpnl)

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

		local notice = vgui.Create("FeatherNoticeBar", panel.content)
		notice:SetType(4)
		notice:SetText(GetLang("configsavedtip"))
		panel.content:AddItem(notice)

		local notice = vgui.Create("FeatherNoticeBar", panel.content)
		notice:SetType(1)
		notice:SetText(GetLang("configwarntip"))
		panel.content:AddItem(notice)

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
				panel.mods[k] = AddTablePanel(panel.content, k, modded[k] or v, v.desc)
			else

			end
		end

		local btn = vgui.Create("DButton")
		btn:SetText("Reset All Configs")
		btn:SetFont("fr_BigTarget")
		btn:SetTextColor(Color(255, 0, 0))
		btn:SetTall(40)
		btn.DoClick = function()
			Derma_Query("Are you sure to delete all server config data?", "Are you sure?", "Yes", function()
				netstream.Start("fr_ResetConfig")
			end, "No")
		end
		panel.content:AddItem(btn)
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

netstream.Hook("fr_UpdateConfig", function(client)
	if MENU then
		timer.Simple(.1, function()
			ConfigPanelInit(MENU)
		end)
	end
end)
