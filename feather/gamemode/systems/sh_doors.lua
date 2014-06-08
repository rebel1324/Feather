local entityMeta = FindMetaTable("Entity")

function entityMeta:IsDoor()
	if string.find(self:GetClass(), "door") then
		return true
	end
end

// TODO: Door Manager funcitons.