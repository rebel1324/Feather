TOOL.Category		= 'Feather'
TOOL.Name			= '#Position Copy'
TOOL.Command		= nil
TOOL.ConfigName		= nil

if(CLIENT) then
	language.Add( 'tool.feather_poscpy.name', 'Position Copy' )
	language.Add( 'tool.feather_poscpy.desc', 'This tool gets the position.' )
	language.Add( 'tool.feather_poscpy.0', 'Left Click: Get Pos Where you looking at, Right Click: Get Pos where you at.' )
else
end

function TOOL:LeftClick(trace)

	if (SERVER) then return true end
	if !IsFirstTimePredicted() then return end
	
	local pos = trace.HitPos
	local text = Format("Vector(%s, %s, %s)", pos.x, pos.y, pos.z)
	self:GetOwner():notify("Position Copied: " .. text, 2)
	SetClipboardText(text)

	return true

end

function TOOL:RightClick(trace)

	if (SERVER) then return true end
	if !IsFirstTimePredicted() then return end

	local pos = self:GetOwner():GetPos()
	local text = Format("Vector(%s, %s, %s)", pos.x, pos.y, pos.z)
	self:GetOwner():notify("Position Copied: " .. text, 2)
	SetClipboardText(text)

	return true

end

function TOOL.BuildCPanel( CPanel )
	
end