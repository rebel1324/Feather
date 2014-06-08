// MAKE GET LANG DONE

GM.Languages = {}

function GetLang(name, ...)
	if !GAMEMODE.Languages[GAMEMODE.Language][name] then
		return "Failed to get language ".. name	
	end
	return Format( GAMEMODE.Languages[GAMEMODE.Language][name], ... or nil )
end

local lang = "english"
GM.Languages[lang] = {}
local l = GM.Languages[lang]


l.hitrequest = "You requested hit %s for %s."
l.zerosalary = "You did not receive a salary because you are unemployed"
l.nopay = "You did not receive your pay."
l.payday = "You have received a pay of %s!"
l.canttalk = "You can't talk for now!"
l.noperm = "You don't have enough permission to do this."
l.cmdinvalid = "This command does not exists."
l.plyinvalid = "That player does not exists.."
l.jobinvalid = "That Job does not exists."
l.cantbecomejob = "You cannot become job right now."
l.getjob = "%s has been %."
l.cantafford = "You can't afford it."

l.broadcast = "(BROADCAST) "
l.ooc = "(OOC) "
l.advert = "(ADVERT) "
l.yell = "(YELL) "
l.looc = "(LOOC) "