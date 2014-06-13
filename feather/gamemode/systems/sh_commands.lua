// SHAMELESSLY BROUGHT FROM THE NUTSCRIPT MAN
GM.ChatCommands = {}
GM.ChatTypes = {}

function GM:RegisterCommand(commandTable, command)
	if (!command) then
		error("No command name provided.")
	end

	if (!commandTable) then
		error("No command table provided.")
	end
	
	if (!commandTable.category) then
		commandTable.category = "Default Commands"
	end

	self.ChatCommands[string.lower(command)] = commandTable
end

function GM:RegisterChat(command, structure)
	structure.canHear = structure.canHear or function() return true end

	if (type(structure.canHear) == "number") then
		local distance = structure.canHear

		function structure.canHear(speaker, listener)
			if (speaker:GetPos():Distance(listener:GetPos()) > distance) then
				return false
			end

			return true
		end
	end

	structure.canSay = structure.canSay or function(speaker)
		local result = hook.Run("ChatClassCanSay", class, structure, speaker)

		if (result != nil) then
			return result
		end

		if (!speaker:Alive() and !structure.deadCanTalk) then
			speaker:notify(GetLang"canttalk")

			return false
		end

		return true
	end

	hook.Run("ChatClassRegister", class, structure)

	self.ChatTypes[command] = structure
end

function GM:RunCommand(client, command, arguments, noMsgOnFail)
	local commandTable = self.ChatCommands[string.lower(command)]
	local echo = false

	if (commandTable) then
		if (commandTable.onRun) then
			if (commandTable.hasPermission) then
				if (commandTable.hasPermission(client) == false) then
					client:notify(GetLang"noperm")

					return
				end
			elseif (commandTable.superAdminOnly) then
				if (!client:IsSuperAdmin()) then
					client:notify(GetLang"noperm")


					return
				end
			elseif (commandTable.adminOnly) then
				if (!client:IsAdmin()) then					
					client:notify(GetLang"noperm")


					return
				end
			end

			if (!commandTable.allowDead and !client:Alive()) then
				client:notify(GetLang"canttalk")

				return
			end

			local result = commandTable.onRun(client, arguments)

			if (result == false) then
				echo = true
			end

			if !(silent or commandTable.silent) then
				if (#arguments > 0) then
					//nut.util.AddLog(client:Name().." has ran command '"..action.." "..table.concat(arguments, " ").."'", LOG_FILTER_CONCOMMAND)
				else
					//nut.util.AddLog(client:Name().." has ran command '"..action.."'", LOG_FILTER_CONCOMMAND)
				end
			end
		end
	elseif (!noMsgOnFail) then
		client:notify(GetLang("invalid", "command"))
	end

	if (!echo) then
		return ""
	end
end

function GM:ProcessCommand(client, text)
	if (string.sub(text, 1, 1) == "/") then
		local arguments = {}
		local text2 = string.sub(text, 2)
		local quote = (string.sub(text2, 1, 1) != "\"")

		for chunk in string.gmatch(text2, "[^\"]+") do
			quote = !quote

			if (quote) then
				table.insert(arguments, chunk)
			else
				for chunk in string.gmatch(chunk, "[^ ]+") do
					table.insert(arguments, chunk)
				end
			end
		end

		local command

		if (arguments[1]) then
			command = string.lower(arguments[1])
		end
		
		if (command) then
			table.remove(arguments, 1)

			local value = self:RunCommand(client, command, arguments, noMsgOnFail)

			if (value) then
				return value
			end
		end

		return ""
	end
end

function GM:CanSay(client, mode)
	local class = self.ChatTypes[mode]

	if (!class) then
		return false
	end

	return class.canSay(client)
end

-- Returns a table of players that can hear a speaker.
function GM:GetChatListeners(client, mode, excludeClient)
	local class = self.ChatTypes[mode]
	local listeners = excludeClient and {} or {client}

	if (class) then
		for k, v in pairs(player.GetAll()) do
			if (class.canHear(client, v)) then
				listeners[#listeners + 1] = v
			end
		end
	end

	return listeners
end

-- Send a chat class to the clients that can hear it based off the classes's canHear function.
function GM:ChatSend(client, mode, text, listeners)
	local class = self.ChatTypes[mode]

	if (!class) then
		return
	end

	if (class.onChat) then
		if (!listeners) then
			listeners = {client}

			for k, v in pairs(player.GetAll()) do
				if (class.canHear(client, v) and v != client) then
					listeners[#listeners + 1] = v
				end
			end
		end

		netstream.Start(listeners, "FeatherChatMessage", {client, mode, text})
	end

	if (class.onSaid) then
		class.onSaid(client, text, listeners)
	end

	local color = team.GetColor(client:Team())
	local channel = "r"
	local highest = 0

	for k, v in pairs(color) do
		if (v > highest and k != "a") then
			highest = v
			channel = k
		end

		if (v <= 50) then
			color[k] = 0
		end
	end

	if (highest <= 200) then
		color[channel] = 200
	else
		color[channel] = 255
	end
	
	MsgC(color, client:Name())
	MsgC(color_white, ": ")
	MsgC(Color(200, 200, 200), "("..string.upper(mode)..") ")
	MsgC(color_white, text.."\n")

	return listeners
end

function GM:ProcessChat(client, text) // Sorry, I don't have time to reconstruct whole shit.
	local mode
	local text2 = string.lower(text)

	for k, v in pairs(self.ChatTypes) do
		if (type(v.prefix) == "table") then
			for k2, v2 in pairs(v.prefix) do
				local length = #v2

				if (!v.noSpacing) then
					length = length + 1
				end

				if (string.Left(text2, length) == v2..(!v.noSpacing and " " or "")) then
					mode = k
					text = string.sub(text, length + 1)

					break
				end
			end
		elseif (v.prefix) then
			local length = #v.prefix + 1

			if (string.Left(text2, length) == v.prefix.." ") then
				mode = k
				text = string.sub(text, length + 1)
			end
		end
	end

	mode = mode or "ic"

	if (mode == "ic") then
		local value = self:ProcessCommand(client, text)

		if (value) then
			return value
		end
	end

	
	if (!self:CanSay(client, mode)) then
		return ""
	end

	local listeners = self:GetChatListeners(client, mode)

	text = hook.Run("PrePlayerSay", client, text, mode, listeners) or text
	self:ChatSend(client, mode, text, listeners)
	

	return ""
end

if CLIENT then
	netstream.Hook("FeatherChatMessage", function(data)
		local speaker = data[1]
		local mode = data[2]
		local text = data[3]
		local class = GAMEMODE.ChatTypes[mode]

		if (!IsValid(speaker) or !class) then
			return
		end

		if (!hook.Run("ChatClassPreText", class, speaker, text, mode)) then
			class.onChat(speaker, text)
		end

		hook.Run("ChatClassPostText", class, speaker, text, mode)
	end)
end

/* HERE IT GOES TONS OF CHATS */

GM:RegisterChat("broadcast", {
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"broadcast" , Color(255, 0, 0), speaker:Name(), ": " .. text)
	end,
	prefix = {"/broadcast", "/b"},
})

GM:RegisterChat("ooc", {
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"ooc", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end,
	prefix = {"/ooc", "//"},
})

GM:RegisterChat("advert", {
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"advert", team.GetColor(speaker:Team()), speaker:Name(), Color(200, 230, 0), ": " .. text)
	end,
	prefix = {"/advert", "/ad"},
})

GM:RegisterChat("yell", {
	canHear = GM.ChatRange * 2,
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"yell", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end,
	prefix = {"/y", "/yell"},
})

GM:RegisterChat("it", {
	canHear = GM.ChatRange,
	onChat = function(speaker, text)
		chat.AddText(color_white, "** "..text)
	end,
	prefix = {"/it"},
})

GM:RegisterChat("me", {
	canHear = GM.ChatRange,
	onChat = function(speaker, text)
		chat.AddText(color_white, "**"..speaker:Name().." "..text)
	end,
	prefix = {"/me", "/action"},
})

GM:RegisterChat("looc", {
	canHear = GM.ChatRange,
	onChat = function(speaker, text)
		chat.AddText(color_white, GetLang"looc", team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end,
	prefix = {"[[", "]]", "/looc", "/l"},
})

GM:RegisterChat("ic", {
	canHear = GM.ChatRange,
	onChat = function(speaker, text)
		chat.AddText(team.GetColor(speaker:Team()), speaker:Name(), color_white, ": " .. text)
	end
})

/* HERE IT GOES TONS OF COMMANDS */

GM:RegisterCommand({
	desc = "This commands allows you to switch over to other job from your current job.\nYour job-specific items/entities could be removed by switching the job.",
	syntax = "<job name/uniqueID>",
	onRun = function(client, arguments)
		local job = arguments[1]

		for k, v in ipairs(GAMEMODE.Jobs) do
			if v.cmd then
				if string.lower(type(v.cmd)) == "table" then
					for _, cmd in ipairs(v.cmd) do
						if cmd == job then
							GAMEMODE:BecomeJob(client, client:Team(), k)

							return
						end
					end
				else
					if v.cmd == job then
						GAMEMODE:BecomeJob(client, client:Team(), k)

						return
					end
				end
			end
		end

		client:notify(GetLang"invalidjob")
	end
}, "job")

GM:RegisterCommand({
	desc = "This commands sets citizens/other job's spawnpoint at your foot.",
	syntax = "[job name/uniqueID]",
	onRun = function(client, arguments)
		local job = arguments[1]
	end
}, "setspawn")

GM:RegisterCommand({
	desc = "This commands removes citizens/other job's spawnpoint in certain range from your foot.",
	syntax = "[range]",
	onRun = function(client, arguments)
		local range = arguments[1]
	end
}, "removespawn")

GM:RegisterCommand({
	desc = "This commands gets nearby spawnpoints and display them with particles.",
	syntax = "[range]",
	onRun = function(client, arguments)
		local range = arguments[1]
	end
}, "getspawn")