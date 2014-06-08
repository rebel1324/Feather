GM.Licenses = {}

function GM:LoadLicense()
	// LOAD IT FROM THE SQL
	// YES
end

function GM:SaveLicense()
	for k, v in pairs(GAMEMODE.Licenses) do
		if v.default ~= true then
			// SAVE
		end
	end
end

function GM:CreateLicense(uniqueID, name, desc, price) // In-Game User custom License
	self.Licenses[uniqueID] = {
		name = name or "A License",
		desc = desc or "The license that allows you to do something.",
		price = price or 10,
		default = false,
	}
end

function GM:GetLicenseInfo(uniqueID)
	return self.Licenses[uniqueID]
end

function GM:AddDefaultLicense(uniqueID, name, desc, price) // Add Default License
	self.Licenses[uniqueID] = {
		name = name or "A License",
		desc = desc or "The license that allows you to do something.",
		price = price or 10,
		default = true,
	}
end

function FindLicense(name)
	for k, v in pairs(GAMEMODE.Licenses) do
		if k == name then
			return v
		end
	end

	for k, v in pairs(GAMEMODE.Licenses) do
		if StringMatches(v.name, name) then
			return v
		end
	end
end

local playerMeta = FindMetaTable("Player")

if SERVER then
	function playerMeta:GetLicenses()
		return self:GetNetVar("license")
	end

	function playerMeta:GetLicense(name)
		local tbl = self:GetNetVar("license") or {}
		return tbl[name] or false
	end

	function playerMeta:GiveLicense(name)
		if !self:GetLicense(name) then
			local tbl = self:GetNetVar("license") or {}
			tbl[name] = true
			self:SetNetVar("license", tbl)

			return true
		else
			return false
		end
	end

	function playerMeta:RevokeLicense(name)
		if self:GetLicense(name) then
			local tbl = self:GetNetVar("license") or {}
			tbl[name] = nil
			self:SetNetVar("license", tbl)

			return true
		else
			return false
		end
	end
end

GM:RegisterCommand({
	desc = "This command allows you to give license to facing/specific player if you're in goverment faction.",
	syntax = "<License Name/UniqueID> [Target Player]",
	onRun = function(client, arguments)
		local lic = arguments[1]
		local ply = arguments[2]

		if !GAMEMODE:GetJobData(client:Team()).goverment then
			client:notify("You should be in goverment to do this action.", 4)
			return
		end

		local target
		if ply then
			target = FindPlayer(ply)
		else
			local trace = client:GetEyeTraceNoCursor()
			target = trace.Entity
		end

		if !target or !target:IsValid() then
			client:notify("You should find a player to give license.", 4)
			return
		end

		if target == client then
			client:notify("You can't give license to yourself.", 4)
			return
		end

		if target:GetPos():Distance(client:GetPos()) <= 128 then
			local data = FindLicense(lic)

			if hook.Run("CanGrantLicense", lic, data, client, target) == false then
				return 
			end

			if data then
				if target:GiveLicense(lic) then
					client:notify("You grant " .. target:Name() .. " " .. data.name .. ".", 4)
					target:notify(client:Name() .. " grant you " .. data.name .. ".", 4)
					hook.Run("OnGrantLicense", lic, data, client, target)
				else
					client:notify("He already has that license.", 4)
				end
			end
		end
	end
}, "givelicense")

GM:RegisterCommand({
	desc = "This command allows you to take license to facing/specific player if you're in goverment faction.",
	syntax = "<License Name/UniqueID> [Target Player]",
	onRun = function(client, arguments)
		local lic = arguments[1]
		local ply = arguments[2]

		if !GAMEMODE:GetJobData(client:Team()).goverment then
			client:notify("You should be in goverment to do this action.", 4)
			return
		end

		local target
		if ply then
			target = FindPlayer(ply)
		else
			local trace = client:GetEyeTraceNoCursor()
			target = trace.Entity
		end

		if !target or !target:IsValid() then
			client:notify("You should find a player to give license.", 4)
			return
		end

		if target == client then
			client:notify("You can't give license to yourself.", 4)
			return
		end

		if target:GetPos():Distance(client:GetPos()) <= 128 then
			local data = FindLicense(lic)

			if hook.Run("CanRevokeLicense", lic, data, client, target) == false then
				return 
			end

			if data then
				if target:RevokeLicense(lic) then
					client:notify("You revoked " .. data.name .. " from " .. target:Name() .. ".", 4)
					target:notify(client:Name() .. " revoked " .. data.name .. " from you.", 4)
					hook.Run("OnRevokeLicense", lic, data, client, target)
				else
					client:notify("He doesn't have that license.", 4)
				end
			end
		end
	end
}, "revokelicense")

GM:AddDefaultLicense("gun", "Gun License", "The license that allows you to carry firearms.", 500)
GM:AddDefaultLicense("drive", "Drive License", "The license that allows you to drive vehicles.", 300)