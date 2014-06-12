print('prop protection')

GM.PreventDupe = {
	"feather_microwave"
}

function duplicator.IsAllowed(classname)
	return false
end
function duplicator.Allow(classname)
	return false
end