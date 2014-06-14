// MAKE GET LANG DONE

GM.Languages = {}

function GetLang(name, ...)
	GAMEMODE = GAMEMODE or GM -- get error and shit.

	if GAMEMODE.Languages[GAMEMODE.Language] then
		if GAMEMODE.Languages[GAMEMODE.Language][name] then
			return string.format( GAMEMODE.Languages[GAMEMODE.Language][name], ... )
		end

		if GAMEMODE.Languages["english"][name] then
			return string.format( GAMEMODE.Languages["english"][name], ... )
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
l.demote = "Demote %s? (Reason :%s)."
l.playerdemoted = "%s is demoted from his job."
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
l.notown = "This is not your entity."

l.wanted = "Player %s is now wanted by the police.\nOrdered By: %s\nReason: %s"
l.unwanted = "%s is no longer wanted by the police."
l.arrested = "%s is arrested by %s.\nArrest Time: %s."
l.arrestedby = "You're arrested by %s."
l.unarrested = "%s is unarrested by %s"
l.unarrestedfull = "You're now back to the life."
l.wantedgoverment = "You can't wanted goverment player."
l.alreadywanted = "That player is already wanted."

l.unowned = "Unowned"
l.untitled = "Untitled"
l.unownable = "Unownable"
l.doorhelp = "You can buy this door by pressing F2."
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
l.hudsearchname = "Someone is seaching you."
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
l.jobboardtip = "You can see job's info by right clicking the button."

l.deliverybreifing = "You have to deliver the package to the destination in %d seconds."
l.deliveryfailed = "You failed to deliver the package in time."
l.deliveryobj = "The Package"
l.deliverydest = "Package Destination"
l.missiontaken = "The mission is already taken by another player."
l.onmission = "You're already on another mission."
l.missiondelay = "You can't do another job that fast!"
l.missionaccept = "You accepted the mission."


local lang = "korean"
GM.Languages[lang] = {}
local l = GM.Languages[lang]


l.hitrequest = "당신은 %s 의 암살 의뢰를 %s 에 맡겼습니다.."
l.zerosalary = "당신은 돈을 받지 못했습니다"
l.nopay = "당신은 돈을 받지 못했습니다."
l.payday = "당신은 월급으로 %s을 받았습니다!"
l.canttalk = "당신은 지금 말할 수 없습니다!"
l.noperm = "당신은 이것을 할 권한이 없습니다."
l.cantbecomejob = "아직 이 직업이 될 수 없습니다."
l.cantafford = "당신은 충분한 돈이 없습니다."
l.cantvote = "지금 투표를 할 수 없습니다."
l.onjobvote = "현재 투표가 진행중입니다. 나중에 다시 시도해 주십시오."
l.needtobe = "당신은 먼저 %s 직업이 되야 합니다."
l.onjob = "당신은 이미 이 직업을 가지고 있습니다."
l.toofast = "너무 빠릅니다! 나중에 다시 시도해 주십시오."
l.becamejob = "%s 님이 %s 직업이 되셨습니다."
l.wantstobe = "%s wants to be %s."
l.demote = "%s을 강등할까요? (이유 :%s)."
l.playerdemoted = "%s 님이 현재 직업에서 강등당했습니다."
l.jobvotefail = "%s 님이 %s 직업이 되지 못하셨습니다."
l.yes = "네"
l.no = "아니오"
l.votetime = "남은 시간: %s"
l.cantdo = "현재 그 행동을 할 수 없습니다."
l.yourjobcantdo = "당신의 직업은 이것을 할 수 없습니다."
l.yourjobcantbuy = "당신의 직업은 이것을 구매 할 수 없습니다."
l.givemoney = "당신은 %s 님에게 %s 만큼을 주었습니다."
l.biggerthan = "%s 보다 큰 숫자를 제공하여 주십시오."
l.purchase = "당신은 %s 을/를 %s 에 구입하셨습니다."
l.provide = "당신은 반드시 %s 을/를 제공해야 합니다.."
l.entinvalid = "그 %s는 존재하지 않습니다."
l.entmax = "당신은 이것을 %s개 이상 소유가 불가능합니다."
l.faceadjent = "가격 설정이 가능한 물건을 보셔야 합니다."
l.modify_button = "수정"
l.purchase_button = "구매"
l.close_button = "닫기"
l.begoverment = "당신은 먼저 정부에 들어야 합니다."
l.bemayor = "당신은 먼저 시장이 되어야 합니다."
l.toocheap = "당신의 판매 물품이 너무 싸 %s 만큼을 잃었습니다."
l.moneyfound = "%s 만큼의 돈을 찾았습니다."
l.moneyearn = "%s 만큼의 돈을 벌었습니다."
l.price = "가격: %s"
l.profit = "이익: %s"
l.cookingfood = "요리 중%s"
l.printingmoney = "인쇄 중%s"
l.opening = "개봉 중%s"
l.notown = "이것은 당신이 소유한 물품이 아닙니다."

l.wanted = "%s님의 수배령이 내려졌습니다.\n신청자: %s\n이유: %s"
l.unwanted = "%s님은 더이상 수배되지 않습니다."
l.arrested = "%s님이 %s님에게 체포되었습니다.\n구금 시간: %s."
l.arrestedby = "당신은 %s님에게 체포되었습니다."
l.unarrested = "%s님이 %s님에게 체포가 해제되었습니다."
l.unarrestedfull = "당신은 만기 출소하였습니다."
l.wantedgoverment = "당신은 정부 플레이어를 수배할 수 없습니다."
l.alreadywanted = "그 플레이어는 이미 수배중입니다."

l.unowned = "소유되지 않음"
l.unownable = "소유할 수 없음"
l.untitled = "문"
l.doorhelp = "F2를 눌러 이 문을 살 수 있습니다."
l.itsunownable = "이 문을 소유할 수 없습니다."
l.doorowner = "주인: %s"
l.doornoowner = "이 문의 주인이 없습니다."
l.dooroccupied = "이 문을 살 수 없습니다."
l.doorsold = "이 문을 매각했습니다."
l.doorpurchase = "당신은 이 문을 %s에 구매하였습니다."
l.setdoorownable = "당신은 이 문을 초기화했습니다."
l.setdoorunownable = "당신은 이 문을 소유 불가로 설정했습니다."
l.setdoorhidden = "당신은 이 문을 숨겼습니다."
l.setdoorunhidden = "당신은 이 문을 숨기지 않았습니다."
l.setdoortitle = "당신은 이 문의 이름을 바꾸었습니다."
l.lockdoor = "문을 잠갔습니다."
l.unlockdoor = "문을 열었습니다."

l.hitsuccess = "암살자 %s님이 타겟을 암살했습니다!"
l.requesthitsuccess = "암살자 %s님이 의뢰한 타겟 %s님을 사살했습니다!"
l.hitfailed = "암살자 %s님이 의뢰를 실패했습니다."
l.hitlisted = "이미 암살 리스트에 이름이 올라가 있습니다."
l.hitrequested = "%s님에 대한 암살 의뢰를 성공적으로 의뢰했습니다."
l.oncontract = "다른사람의 의뢰를 현재 의뢰가 끝나기 전까지 완료할 수 없습니다."
l.mustbehitman = "먼저 암살자 직업이 되어야 합니다."

l.invalid = "%s 존재 하지 않음."
l.invalidplayer = "그 플레이어는 존재하지 않습니다."
l.invalidentity = "대상 엔티티를 찾을 수 없습니다."
l.invalidreason = "이유를 반드시 적어야 합니다."
l.invalidjob = "직업이 올바르지 않습니다."
l.invalidtext = "제대로된 텍스트를 입력해야 합니다."
l.invalidrow = "그 줄의 법은 존재하지 않습니다."

l.licenseexist = "This license already exists"
l.thishaslicense = "this player already has this license"
l.haslicense = "You already have this license"
l.closertomachine = "You must get closer to the machine."
l.arrestlicense = "You can't grant license to arrested personel."
l.grantlicense = "You granted %s to %s."
l.getgrantlicense = "%s granted %s to you."
l.revokelicense = "%s 를 %s님으로 부터 가져갔습니다."
l.getrevokelicense = "%s님이 %s를 가져갔습니다."
l.lockdown = "현재 시간부로 계엄령이 발동되었습니다. 밖에 있는 사람들은 모두 처벌될 것 입니다. 계엄령 사유: %s"
l.cantdolockdown = "계엄령이 선언된 상태에서 할 수 없습니다"
l.declarelockdown = "시장이 계엄령을 선언했습니다."
l.finishlockdown = "시장이 계엄령을 철회했습니다."
l.newjailpos = "감옥 위치를 추가했습니다."
l.setjailpos = "모든 감옥 위치을 지우고 하나의 감옥 위치를 설정하였습니다."
l.yourearrested = "체포된 상태에선 할 수 없습니다."
l.heisarrested = "체포된 사람에게 할 수 없습니다."
l.defaultlaw = "기본 법은 삭제할 수 없습니다."
l.maxrows = "최대 법 개수 도달."
l.maxlawboards = "최대 법판 개수 도달."

l.lotterycooldown = "다음 복권 추천 개최를 위해서 %s초 만큼 기다려야 합니다."
l.lotteryalreadyjoined = "이미 복권 추첨에 참가하였습니다."
l.lotterywinner = "당첨자는... %s님입니다! 총 %s를 수령해갑니다!"
l.lotteryvote = "%s을 내고 복권 추첨에 참가합니까?"
l.lotteryticket = "복권 티켓"

l.broadcast = "(방송) "
l.ooc = "(전체) "
l.advert = "(광고) "
l.yell = "(외침) "
l.looc = "(LOOC) "

l.hudarrest = "<공격> 키로 플레이어를 체포합니다."
l.hudarresttarget = "%s 체포 (%s)."
l.hudarresttargetback = "%s 다시 감옥에 구금."

l.hudunarrest = "<공격> 키로 플레이어를 체포를 해제합니다."
l.hudunarresttarget = "%s 사면."

l.hudsearch = "<공격> 키로 플레이어를 수색합니다."
l.hudsearchtarget = "%s 무기 수색."
l.hudsearchname = "무기 수색 중"
l.hudsearchname = "무기 수색 중"
l.searchwindow = "수색 결과"

l.hudpick = "<공격> 키로 문을 땁니다."
l.hudpicktarget = "예상 시간: %s."
l.hudpickname = "문 여는 중"

l.hudheal = "<공격> 키로 플레이어를 치료합니다."
l.hudhealsec = "<보조 공격> 키로 자신을 치료합니다."
l.hudhealtarget = "%s 치료."

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

l.jobmenutip = "오른쪽 클릭으로 직업 정보를 알 수 있습니다."

l.deliverybreifing = "당신은 물건을 대상 지점까지 %d초 이내에 배달해야 합니다."
l.deliveryfailed = "당신은 물건을 제 시간에 배달하는것에 실패했습니다."
l.deliveryobj = "배달 대상"
l.deliverydest = "배달 목표"
l.missiontaken = "이미 그 임무는 다른 플레이어가 맡았습니다."
l.onmission = "당신은 이미 임무를 하고 있습니다."
l.missiondelay = "다른 임무를 그렇게 빨리 할 수 없습니다!"
l.missionaccept = "임무를 수락했습니다."