--[[
	WARNING: DO NOT EDIT ANY OF THESE VALUES! THESE ARE FOR
	SETTING UP THE CONFIG ONLY, NOT ACTUALLY MODIFYING THE VALUES!
--]]

-- NUMBER VALUES
feather.config.create("chatRange", 512, "Normal Chat Range.")
feather.config.create("salary", 50, "Default Salary (reload required)")
feather.config.create("jobChangeDelay", 5, "Job Change Delay.")
feather.config.create("jobBanTime", 600, "Demote Job Ban Time.")
feather.config.create("printerExplodeRate", 10, "Print Explode Chance")
feather.config.create("moneyModel", "models/props/cs_assault/money.mdl", "Server's money's model.")
feather.config.create("doorPrice", 50, "Door Purchase Price.")
feather.config.create("lockPickTime", 5, "Time to pick a lock.")
feather.config.create("hungerTime", 760, "Tvime until people get starved.")
feather.config.create("hungerRate", 2, "Hunger Think Interval.")
feather.config.create("missionRefreshTime", 100, "Mission Update Interval")
feather.config.create("bigProp", 256, "Big Prop Limit.")
feather.config.create("tooBigProp", 512, "Too Big Prop Limit.")
feather.config.create("bigPropWait", 10, "Big Prop Spawn Cooltime.")
feather.config.create("hitCost", 500, "Hit Request Price.")
feather.config.create("moneyRemoveTime", 300, "Money auto-remove Time.")
feather.config.create("entityRemoveTime", 300, "Entity auto-remove Time.")
feather.config.create("maxDoors", 10, "Max Doors.")
feather.config.create("missionDelay", 10, "Mission Accept Cooltime")

-- BOOLEAN VALUES
feather.config.create("requireElectricity", true, "Machines/Entities Require Electricity")
feather.config.create("hunger", true, "People get hungry.")
feather.config.create("falldamage", false, "Realistic Fall Damage.")
feather.config.create("useMail", false, "Server uses mail.")

-- STRING VALUES
feather.config.create("currency", "$", "Game's Currency")
feather.config.create("language", "english", "Game's Language.")

-- TABLE VALUES
feather.config.create("printerTime", {40, 60})
feather.config.create("blockedModels", {
	"models/props_c17/oildrum001_explosive.mdl",
	"models/Cranes/crane_frame.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_phx/oildrum001_explosive.mdl",
	"models/props_phx/cannonball.mdl",
	"models/props_phx/cannonball_solid.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props_phx/ww2bomb.mdl",
}, "Blocked Models.")
feather.config.create("rules", {
	"Do not RDM(Random DeathMatch). Killing people without any valid/legit reason will get you kicked/banned by the admin.",
	"Do not use any glitches and exploits to attack the server/get more profit.",
	"Do not Random Arrest. Arresting people without any valid/legit reason will get you kicked/banned by the admin.",
	"Do not disrespect admins/staffs. Always be nice to any people in the server.",
}, "Server's Rule.")
feather.config.create("defaultLoadout", {
	"weapon_physgun",
	"weapon_physcannon",
	"gmod_tool",
	"gmod_camera",

	"weapon_fist",
	"weapon_key",
}, "Server's Default Loadout")
feather.config.create("defaultLaws", {
	"You must obey the admins.",
	"You must not kill."
}, "Server's Default Laws.")