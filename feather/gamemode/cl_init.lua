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

surface.CreateFont("fr_GuideText", {
	font = "Arial",
	size = 20,
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_ChatAssist", {
	font = "Trebuchet MS",
	size = 22,
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

surface.CreateFont("fr_VoteFontShadow", {
	font = "Tahoma",
	weight = 1000,
	size = 13,
	blursize = 5
})

surface.CreateFont("fr_ScoreboardTitle", {
	font = "Trebuchet MS",
	size = 50,
	weight = 1000,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_ScoreboardTitleSub", {
	font = "Trebuchet MS",
	size = 26,
	weight = 500,
	shadow = true,
	antialias = true
})

surface.CreateFont("fr_ScoreboardTitleInfo", {
	font = "Trebuchet MS",
	size = 20,
	weight = 500,
	shadow = true,
	antialias = true
})