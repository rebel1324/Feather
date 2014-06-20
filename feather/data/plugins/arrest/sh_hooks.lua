feather.config.create("arrestTime", 300)
feather.config.create("wantedTime", 300)

if (SERVER) then
	hook.Add("CanDemote", "fr_ArrestDemote", function(client)
		if (client:IsArrested()) then
			client:notify(GetLang"yourearrested")

			return false
		end
	end)

	hook.Add("CanBecomeJob", "fr_ArrestJob", function(client)
		if (client:IsArrested()) then
			return false, GetLang"yourearrested"
		end
	end)

	hook.Add("CanPlayerLoadout", "fr_LoadoutArrest", function(client)
		return !client:IsArrested()
	end)

	hook.Add("PlayerGetPayAmount", "fr_ArrestPay", function(client)
		if client:IsArrested() then
			return false, GetLang("arrestedpay")
		end
	end)

	hook.Add("PlayerSpawnObject", "fr_ArrestSpawn", function(client)
		if client:IsArrested() then
			return false
		end
	end)
else
	surface.CreateFont("fr_Arrested", {
		font = "Trebuchet MS",
		size = 24,
		weight = 1000,
		shadow = true,
		antialias = true
	})

	hook.Add("HUDPaint", "fr_ArrestPaint", function()
		local w, h = ScrW(), ScrH()

		if LocalPlayer():GetNetVar("arrested") then
			local text = "You're arrested."
			surface.SetFont("fr_LicenseTitle")
			local tx, ty = draw.SimpleText(text, "fr_Arrested", w/2, h/5*4, color_white, 1, 1)
			text = "Your arrest will be lifted in " .. string.NiceTime(math.ceil(LocalPlayer():GetNetVar("arrested") - CurTime())) .. "."
			draw.SimpleText(text, "fr_Arrested", w/2, h/5*4 + ty, color_white, 1, 1)
		end
	end)

	hook.Add("DrawPlayerInfo", "fr_ArrestInfo", function(client, info)
		if (client:IsWanted()) then
			info:draw("Wanted by Police", Color(239, 72, 54), Color(242, 38, 19))
		end

		if (client:IsArrested()) then
			info:draw("Arrested", Color(239, 72, 54), Color(239, 72, 54))
		end
	end)
end