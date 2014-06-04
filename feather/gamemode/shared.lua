DeriveGamemode("cn")

GM.Name = "Feather"
GM.Author = "Chessnut and rebel1324"
GM.TeamBased = true

GM.Jobs = {}

function GM:CreateJob(name, color, job)
	local index = table.insert(self.Jobs, job)
		team.SetUp(index, name, color, false)
	return index
end

function GM:CreateTeams()
	TEAM_CITIZEN = self:CreateJob("Citizen", Color(0, 255, 0), {
		salary = 25
	})
end

cn.util.includeFolder("systems", "feather")
cn.util.includeFolder("meta", "feather")
cn.util.includeFolder("hooks", "feather")