TOOL.Category		= 'Feather'
TOOL.Name			= '#Door Manager'
TOOL.Command		= nil
TOOL.ConfigName		= nil

if(CLIENT) then
	language.Add( 'tool.feather_doormanager.name', 'Door Manager' )
	language.Add( 'tool.feather_doormanager.desc', 'This tool manages door groups and stuffs' )
	language.Add( 'tool.feather_doormanager.0', 'Click to wow' )
else
end

function TOOL:LeftClick( trace )

	if ( trace.Entity and trace.Entity:IsPlayer() ) then return false end
	if (CLIENT) then return true end
	
	local ply = self:GetOwner()	
	
	return true

end



function TOOL.BuildCPanel( CPanel )
	
end