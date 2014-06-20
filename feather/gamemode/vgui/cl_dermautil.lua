function Derma_StringDoubleRequest( strTitle, strText, strDefaultText, strDefaultText2, fnEnter, fnCancel, strButtonText, strButtonCancelText )

	local window = vgui.Create( "DFrame" )
	window:SetTitle( strTitle or "Message Title (First Parameter)" )
	window:SetDraggable( false )
	window:ShowCloseButton( true )
	window:SetBackgroundBlur( true )
	window:SetDrawOnTop( true )


	local text = vgui.Create( "DLabel", window )
	text:SetText( strText or "Message Text (Second Parameter)" )
	text:SizeToContents()
	text:SetContentAlignment( 5 )
	text:Dock(TOP)
	text:SetTextColor( color_white )

	local txtentr = vgui.Create( "DTextEntry", window )
		txtentr:SetText( strDefaultText or "" )
		txtentr:DockMargin(5, 10, 5, 0)
		txtentr:Dock(TOP)

	local txtentr2 = vgui.Create( "DTextEntry", window )
		txtentr2:SetText( strDefaultText2 or "" )
		txtentr2:DockMargin(5, 5, 5, 0)
		txtentr2:Dock(TOP)

	local btnpanel = vgui.Create( "DPanel", window )
		btnpanel:SetDrawBackground( false )
		btnpanel:SetTall( 30 )

	local btn = vgui.Create( "DButton", btnpanel )
		btn:SetText( strButtonText or "OK" )
		btn:SizeToContents()
		btn:SetTall( 20 )
		btn:SetWide( btn:GetWide() + 20 )
		btn:SetPos( 5, 5 )
		btn.DoClick = function() window:Close() fnEnter( txtentr:GetValue(), txtentr2:GetValue() ) end

	local btncnl = vgui.Create( "DButton", btnpanel )
		btncnl:SetText( strButtonCancelText or "Cancel" )
		btncnl:SizeToContents()
		btncnl:SetTall( 20 )
		btncnl:SetWide( btn:GetWide() + 20 )
		btncnl:SetPos( 5, 5 )
		btncnl.DoClick = function() window:Close() if ( fnCancel ) then fnCancel( txtentr:GetValue(), txtentr2:GetValue() ) end end
		btncnl:MoveRightOf( btn, 5 )

	local w, h = text:GetSize()
	w = math.max( w, 400 ) 

	window:SetSize( w + 50, h + 25 + 90 + 10 )
	window:Center()

	btnpanel:SetWide( btn:GetWide() + 5 + btncnl:GetWide() + 10 )
	btnpanel:CenterHorizontal()
	btnpanel:AlignBottom( 8 )

	window:MakePopup()
	window:DoModal()
	return window

end