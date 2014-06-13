include("shared.lua")

local font = "Tahoma"

surface.CreateFont("fr_BigTarget", {
	font = font,
	weight = 1000,
	size = 22
})

surface.CreateFont("fr_BigTargetShadow", {
	font = font,
	weight = 1000,
	size = 22,
	blursize = 5
})

surface.CreateFont("fr_HUDNumber", {
	name = "halflife2",
	weight = 1000,
	additive = true,
	size = ScreenScale(16)
})

surface.CreateFont("fr_Progress", {
	font = "Trebuchet MS",
	size = ScreenScale(15),
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_License", {
	font = "Trebuchet MS",
	size = 30,
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_LicenseBtn", {
	font = "Trebuchet MS",
	size = 20,
	weight = 1000,
	antialias = true
})

surface.CreateFont("fr_LicenseTitle", {
	font = "Trebuchet MS",
	size = 25,
	weight = 1000,
	antialias = true
})

surface.CreateFont("fr_Arrested", {
	font = "Trebuchet MS",
	size = 25,
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_3d2dTextTitle", {
	font = "Trebuchet MS",
	size = 124,
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_3d2dTextContext", {
	font = "Trebuchet MS",
	size = 60,
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_HUDFont", {
	font = "Calibri",
	size = 30,
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_MenuBigFont", {
	font = "Calibri",
	size = 35,
	weight = 1000,
	antialias = true
})

surface.CreateFont("fr_MenuFont", {
	font = "Calibri",
	size = 26,
	weight = 1000,
	antialias = true
})

surface.CreateFont("fr_CategoryFont", {
	font = "Calibri",
	size = 25,
	weight = 1000,
	antialias = true
})

surface.CreateFont("fr_FrameFont", {
	font = "Calibri",
	size = 20,
	weight = 1000,
	antialias = true
})

surface.CreateFont("fr_VoteFont", {
	font = "Tahoma",
	weight = 1000,
	size = 13
})


concommand.Add("fonts_sourcescheme_view",function()
	local fonts = util.KeyValuesToTable(file.Read("resource/clientscheme.res",'GAME')).fonts
       
	local sortable= {}
	for font,tbl in next,fonts do
		local i=next(tbl,next(tbl)) and 0
		for _,tbl in next,tbl do
			if i then
				i=i+1
				tbl.num = i
			end
		       
			tbl.fontname = font
			table.insert(sortable,tbl)
		       
		end
	end
       
	--table.sort(sortable,function(a,b)
	--      return a.tall>b.tall
	--end)
	local curtbl
	local f = vgui.Create'DFrame'
	local testtxt="abcABCöäå"
       
	f:SetSize(1280,ScrH()-32-32)
	f:Center()
	f:SetSizable(true)
	f:MakePopup()
       
	local a = vgui.Create( "DTextEntry", f )
	       
		a:SetText(testtxt)
		a:Dock(TOP)
		a.OnChange=function(a)
			testtxt = a:GetText()
		end
	local list = vgui.Create( "PanelList", f )
	       
		list:EnableVerticalScrollbar()
		list:Dock(FILL)
		list:SetSpacing(4)
	local surface=surface
	for _,t in next,sortable do
	       
		local pnl = vgui.Create( "EditablePanel", list )
	       
		local font = t.fontname
	       
		local add = t.num and ' '..t.num
	       
		local info = font
	       
			surface.SetFont(font)
			local w,h = surface.GetTextSize("W")
			pnl:SetTall(h+32+4)
	       
			surface.SetFont(font)
		pnl.Paint=function(pnl,w,h)
			surface.SetDrawColor(30,30,30,100)
			surface.DrawRect(0,0,w,h)
			surface.SetFont("Default")
			surface.SetTextPos(0,0)
			surface.SetTextColor(111,111,222,255)
			surface.DrawText(info)
			if add then
				surface.SetTextColor(150,222,255,255)
				surface.DrawText(add)
			end            
			surface.SetFont(font)
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(0,32)
			surface.DrawText(testtxt )
		end
		pnl.OnCursorEntered=function()
			curtbl=t
		end
		list:AddItem(pnl)
	end
       
	hook.Add("HUDPaint","fontviewer",function()
		if not f:IsValid() then hook.Remove("HUDPaint","fontviewer") return end
		if not curtbl then return end
		local fontname = curtbl.fontname
	       
		surface.SetFont("ChatFont")
		local tw,th =surface.GetTextSize("W")
	       
		local y=70
		for key,val in next,curtbl do
			surface.SetTextPos(64,y)
			surface.SetTextColor(111,111,222,255)
			surface.DrawText(tostring(key))
			surface.DrawText("  ")
			surface.SetTextColor(150,222,255,255)
			surface.DrawText(tostring(val))
			y=y+th
		end
	       
		surface.SetFont(fontname)
		surface.SetTextColor(255,255,255,255)
		surface.SetTextPos(64,y)
		surface.DrawText(testtxt)
	end)
end)