GM.Licenses = {}

function GM:LoadLicense()
end

function GM:SaveLicense()
end

function GM:CreateLicense() // In-Game User custom License
end

function GM:AddDefaultLicense(uniqueID, name, price) // Add Default License
	GM.Licenses[uniqueID] = {
		name = name,
		price = price,
	}
end

GM:AddDefaultLicense("gl", "Gun License", 500)
GM:AddDefaultLicense("dl", "Drive License", 300)

local playerMeta = FindMetaTable("Player")

if SERVER then
	function playerMeta:GetLicenses()
		return self:GetNetVar("license")
	end

	function playerMeta:GetLicense(name)
		return self:GetNetVar("license")[name]
	end

	function playerMeta:GiveLicense(name)

	end

	function playerMeta:RevokeLicense(name)

	end
end