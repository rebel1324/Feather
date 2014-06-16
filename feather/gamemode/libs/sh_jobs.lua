function GM:CreateJob(name, color, job)
	local index = table.insert(self.Jobs, job)
		team.SetUp((#self.Jobs), name, color, false)
	return (#self.Jobs)
end

function GM:GetJobData(index)
	return self.Jobs[index] or nil
end

cn.util.include("feather/data/sh_jobs.lua")