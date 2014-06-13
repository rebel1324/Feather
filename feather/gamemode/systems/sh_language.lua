// MAKE GET LANG DONE

GM.Languages = {}

function GetLang(name, ...)
	GAMEMODE = GAMEMODE or GM -- get error and shit.

	if GAMEMODE.Languages[GAMEMODE.Language] then
		if GAMEMODE.Languages[GAMEMODE.Language][name] then
			return string.format( GAMEMODE.Languages[GAMEMODE.Language][name], ... )
		end

		if GAMEMODE.Languages["english"][name] then
			return string.format( GAMEMODE.Languages[GAMEMODE.Language][name], ... )
		end
	end

	return "Failed to get language ".. name	or "<NO LANG!>"
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
l.cantbecomejob = "You cannot become job right now."
l.getjob = "%s has been %."
l.cantafford = "You can't afford it."
l.cantvote = "You can't vote right now."
l.onjobvote = "Your Job vote is ongoing. Try again later."
l.needtobe = "You need to be %s first."
l.onjob = "You're already on that job."
l.toofast = "Your input is too fast! Try again later."
l.becamejob = "%s has been made a %s"
l.wantstobe = "%s wants to be %s."
l.jobvotefail = "%s didn't made to be %s."
l.yes = "Yes"
l.no = "No"
l.votetime = "Time: %s"
l.cantdo = "You can't do that."
l.yourjobcantdo = "Your ."
l.yourjobcantbuy = "Your job can't buy this."
l.givemoney = "You gave %s to %s."
l.biggerthan = "You must provide the number bigger than %s."
l.purchase = "You purchased %s for %s."
l.provide = "You must provide %s."
l.entinvalid = "That %s does not exists."
l.entmax = "You can't own this more than %s."
l.faceadjent = "You must face the entity that you can set the price."
l.modify_button = "Modify"
l.purchase_button = "Purchase"
l.close_button = "Close"
l.begoverment = "You should be in goverment to do this action."
l.bemayor = "You should be mayor to do this action."
l.toocheap = "You lost %s because your product is too cheap."
l.moneyfound = "You found %s."
l.moneyearn = "You earned %s."
l.price = "Price : %s"
l.profit = "Profit : %s"
l.cookingfood = "Cooking Food%s"
l.printingmoney = "Printing Money%s"
l.opening = "Opening%s"

l.wanted = "Player %s is now wanted by the police.\nOrdered By: %s\nReason: %s"
l.unwanted = "%s is no longer wanted by the police."
l.arrested = "%s is arrested by %s.\nArrest Time: %s."
l.arrestedby = "You're arrested by %s."
l.unarrested = "%s is unarrested by %s"
l.unarrestedfull = "You're now back to the life."
l.wantedgoverment = "You can't wanted goverment player."
l.alreadywanted = "That player is already wanted."

l.unowned = "Unowned"
l.unownable = "Unownable"
l.itsunownable = "The door is unownable."
l.doorowner = "Owner: %s"
l.doornoowner = "This door has no owner."
l.dooroccupied = "You don't own this door."
l.doorsold = "You sold this door."
l.doorpurchase = "You purchased this door for %s."
l.setdoorownable = "You set this door ownable."
l.setdoorunownable = "You set this door unownable."
l.setdoorhidden = "You set this door hidden."
l.setdoorunhidden = "You set this not hidden."
l.setdoortitle = "You changed this door's title."
l.lockdoor = "You locked the door."
l.unlockdoor = "You unlocked the door."

l.hitsuccess = "Hitman %s successfully compromised the target!"
l.requesthitsuccess = "Hitman %s successed to compromise %s!"
l.hitfailed = "Hitman %s failed to compromise the target."
l.hitlisted = "That player is already on hit list."
l.hitrequested = "You made successful hit contract for %s."
l.oncontract = "You can't accept other contract until you finish your contract."
l.mustbehitman = "You must be hitman to accept the contract."

l.invalid = "That %s does not exists."
l.invalidplayer = "That player does not exists."
l.invalidentity = "Can't find target entity."
l.invalidreason = "You must provide the reason."
l.invalidjob = "That job is not valid."
l.invalidtext = "You must provide valid text."
l.invalidrow = "That row does not exists."

l.licenseexist = "This license already exists"
l.thishaslicense = "this player already has this license"
l.haslicense = "You already have this license"
l.closertomachine = "You must get closer to the machine."
l.arrestlicense = "You can't grant license to arrested personel."
l.grantlicense = "You granted %s to %s."
l.getgrantlicense = "%s granted %s to you."
l.revokelicense = "You revoked %s from %s."
l.getrevokelicense = "%s revoked %s from you."
l.lockdown = "Mayor declared Lockdown. All Citizens in the street will be punished. Reason: %s"
l.cantdolockdown = "You can't do that under the lockdown"
l.declarelockdown = "Mayor declared Lockdown."
l.finishlockdown = "Mayor declared Lockdown."
l.newjailpos = "You added new Jail Position."
l.setjailpos = "You cleared all Jail Positions and set this position as new Jail Position."
l.yourearrested = "You can't do that while you're arrested."
l.heisarrested = "You can't do that to arrested player."
l.defaultlaw = "You can't delete default laws."
l.maxrows = "Maximum Row Reached."
l.maxlawboards = "Maximum Law Boards Reached."

l.lotterycooldown = "You must wait for %s to open next lottery."
l.lotteryalreadyjoined = "You already joined currently lottery pool."
l.lotterywinner = "The winner is.... %s! He earned %s."
l.lotteryvote = "Lottery is started. Purchase lottery for %s?"
l.lotteryticket = "Lottery Ticket"

l.broadcast = "(BROADCAST) "
l.ooc = "(OOC) "
l.advert = "(ADVERT) "
l.yell = "(YELL) "
l.looc = "(LOOC) "

l.hudarrest = "Press <ATTACK> to arrest the player."
l.hudarresttarget = "Arrest %s for %s."
l.hudarresttargetback = "Put %s back to the jail."

l.hudunarrest = "Press <ATTACK> to unarrest the player."
l.hudunarresttarget = "Make %s Free."

l.hudsearch = "Press <ATTACK> to search the player."
l.hudsearchtarget = "Search %s's weapons."
l.hudsearchname = "Searching for the Weapons"
l.searchwindow = "Search Result"

l.hudpick = "Press <ATTACK> to pick the lock."
l.hudpicktarget = "Estimated time %s."
l.hudpickname = "Picking the Lock"

l.hudheal = "Press <PRIMARY> to heal the player."
l.hudhealsec = "Press <SECONDARY> to heal yourself."
l.hudhealtarget = "Heal %s."

l.jobcitizen = [[This is citizen who lives in the city.]]
l.jobcook = [[You can get some profit by selling some foods to hungry players on the city.
You can buy 'Microwave' in the Shop Category and can set it's price with '/setprice <amount>' command.]]
l.jobgundealer = [[You can get some profit by selling some guns to players on the city.
Mostly you're not allowed to kill other with your own guns.
You can buy Weapon Shipments in the Shop Category.]]
l.jobmedic = [[You can save other citizen's live in the city.
Also you can get paid by healing other player's Health.
You can buy some medical supplies in the Shop Category.]]
l.jobmayor = [[This job is Goverment Job.
You can control the city when you're mayor. This job requires Job Vote.
You can lockdown the city with '/lockdown <reason>'.
You can give license to the player with '/givelicense <licenseid>'.
You can wanted a player with '/wanted <player> <reason>'.
You can warrant the player with '/warrant <player> <reason>'.]]
l.jobpolice = [[This job is Goverment Job.
You can wanted a player with '/wanted <player> <reason>'.
You can warrant the player with '/warrant <player> <reason>'.]]
l.jobpolicechief = [[This job is Goverment Job.
You can wanted a player with '/wanted <player> <reason>'.
You can warrant the player with '/warrant <player> <reason>'.]]
l.jobmobster = [[This is citizen who lives in the city.]]
l.jobmobsterboss = [[This is citizen who lives in the city.]]
l.jobhitman = [[This is citizen who lives in the city.]]

l.jobmenutip = "You can see job's info by right clicking the button."