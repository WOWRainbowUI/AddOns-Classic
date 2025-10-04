--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Help
local M = KT:NewModule("Help")
KT.Help = M

local T = LibStub("MSA-Tutorials-1.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local HELP_PATH = KT.MEDIA_PATH.."Help\\"
local ICON_URL = HELP_PATH.."help_icon-url"
local ICON_HEART = "|T"..HELP_PATH.."help_patreon:14:14:2:0:256:32:174:190:0:16|t"

local db, dbChar
local helpTitle = KT.TITLE.." |cffffffff"..KT.VERSION.."|r"
local helpPath = KT.MEDIA_PATH.."Help\\"
local helpName = "help"
local helpNumPages = 10
local supportersName = "supporters"
local supportersNumPages = 1
local cTitle = "|cffffd200"
local cBold = "|cff00ffe3"
local cWarning = "|cffff7f00"
local cDots = "|cff808080"
local offs = "\n|T:1:8|t"
local ebSpace = "|T:16:1|t\n"
local beta = "|cffff7fff[Beta]|r"
local new = "|cffff7fff[NEW]|r"

local KTF = KT.frame

--------------
-- Internal --
--------------

local function AddonInfo(name)
	local info = "Addon "..name
	if C_AddOns.IsAddOnLoaded(name) then
		info = info.." |cff00ff00is installed|r."
	else
		info = info.." |cffff0000is not installed|r."
	end
	info = info.." Support you can enable / disable in Options.\n"..ebSpace
	return info
end

local function SetFormatedPatronName(tier, name, realm, note)
	if realm then
		realm = " @"..realm
	else
		realm = ""
	end
	if note then
		note = " ... "..note
	else
		note = ""
	end
	return format("- |cff%s%s|r|cff7f7f7f%s%s|r\n", KT.QUALITY_COLORS[tier], name, realm, note)
end

local function SetFormatedPlayerName(name, realm, note)
	if realm then
		realm = " @"..realm
	else
		realm = ""
	end
	if note then
		note = " ... "..note
	else
		note = ""
	end
	return format("- %s|cff7f7f7f%s%s|r\n", name, realm, note)
end

local function SetupTutorials()
	T.RegisterTutorial(helpName, {
		savedvariable = KT.db.global,
		key = "helpTutorial",
		title = helpTitle,
		icon = helpPath.."KT_logo",
		font = "Fonts\\FRIZQT__.TTF",
		width = 582,
		height = 610,
		paddingX = 35,
		paddingTop = 26,
		paddingBottom = 24,
		imageWidth = 512,
		imageHeight = 256,
		{	-- 1
			image = helpPath.."help_kaliels-tracker",
			text = cTitle..KT.TITLE.." (Classic)|r replaces default tracker and adds some features from WoW Retail to WoW Classic.\n\n"..
					"Some features:\n"..
					"- Tracking Quests\n"..
					"- Tracking Achievements (not in Classic Era)\n"..
					"- Change tracker position\n"..
					"- Expand / Collapse tracker relative to selected position (direction)\n"..
					"- Auto set trackers height by content with max. height limit\n"..
					"- Scrolling when content is greater than max. height\n"..
					"- Remember collapsed tracker after logout / exit game\n\n"..
					"... and many other enhancements (see next pages).",
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 2
			image = helpPath.."help_header-buttons",
			imageHeight = 128,
			heading = "Header buttons",
			text = "Minimize button:\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:0:14:209:170:0|t "..cDots.."...|r Expand Tracker\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:16:30:209:170:0|t "..cDots.."...|r Collapse Tracker\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:32:46:209:170:0|t "..cDots.."...|r when is tracker empty\n\n"..
					"Other buttons:\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:0:14:209:170:0|t "..cDots.."...|r Open Quest Log\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:16:30:209:170:0|t "..cDots.."...|r Open Achievements (not in Classic Era)\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:32:46:209:170:0|t "..cDots.."...|r Open Filters menu\n\n"..
					"Buttons |T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:0:2:32:64:16:30:0:14:209:170:0|t and "..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:0:2:32:64:16:30:16:30:209:170:0|t you can disable in Options.\n\n"..
					"You can set "..cBold.."[key bind]|r for Minimize button.\n"..
					cBold.."Alt+Click|r on Minimize button opens "..KT.TITLE.." Options.",
			paddingBottom = 11,
			shine = KTF.MinimizeButton,
			shineTop = 13,
			shineBottom = -14,
			shineRight = 16,
		},
		{	-- 3
			image = helpPath.."help_quest-title-tags",
			imageHeight = 128,
			heading = "Quest title tags",
			text = "Quest level |cffff8000[42]|r is at the beginning of the quest title.\n"..
					"Quest type tags are at the end of quest title.\n\n"..
					KT.CreateQuestTagIcon(nil, 7, 14, 2, 0, 0.34, 0.425, 0, 0.28125).." "..cDots.."........|r Daily quest|T:14:121|t"..
						KT.CreateQuestTagIcon(nil, 16, 16, 0, 0, unpack(QUEST_TAG_TCOORDS[Enum.QuestTag.Heroic])).." "..cDots.."......|r Heroic quest\n"..
					KT.CreateQuestTagIcon(nil, 7, 14, 2, 0, 0.34, 0.425, 0, 0.28125)..KT.CreateQuestTagIcon(nil, 7, 14, 0, 0, 0.34, 0.425, 0, 0.28125).." "..cDots.."......|r Weekly quest|T:14:107|t"..
						KT.CreateQuestTagIcon(nil, 16, 16, 0, 0, unpack(QUEST_TAG_TCOORDS[Enum.QuestTag.PvP])).." "..cDots.."......|r PvP quest\n"..
					KT.CreateQuestTagIcon(nil, 16, 16, 0, 0, unpack(QUEST_TAG_TCOORDS[Enum.QuestTag.Group])).." "..cDots.."......|r Group quest|T:14:114|t"..
						"|cffd900b8S|r "..cDots.."........|r Scenario quest\n"..
					KT.CreateQuestTagIcon(nil, 16, 16, 0, 0, unpack(QUEST_TAG_TCOORDS[Enum.QuestTag.Dungeon])).." "..cDots.."......|r Dungeon quest|T:14:95|t"..
						KT.CreateQuestTagIcon(nil, 16, 16, 0, 0, unpack(QUEST_TAG_TCOORDS[Enum.QuestTag.Account])).." "..cDots.."......|r Account quest\n"..
					KT.CreateQuestTagIcon(nil, 17, 17, -1, 0, unpack(QUEST_TAG_TCOORDS[Enum.QuestTag.Raid])).." "..cDots.."......|r Raid quest|T:14:125|t"..
						KT.CreateQuestTagIcon(nil, 7, 14, 2, 0, 0.055, 0.134, 0.28125, 0.5625).." "..cDots.."........|r Legendary quest\n\n"..
					cWarning.."Note:|r Not all of these tags are used in Classic.",
			paddingBottom = 16,
			shineTop = 10,
			shineBottom = -9,
			shineLeft = -12,
			shineRight = 10,
		},
		{	-- 4
			image = helpPath.."help_tracker-filters",
			heading = "Tracker Filters",
			text = "For open Filters menu "..cBold.."Click|r on the button |T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-2:1:32:64:16:30:32:46:209:170:0|t.\n\n"..
					"There are two types of filters:\n"..
					cTitle.."Static filter|r - adds quests/achievements to tracker by criterion (e.g. \"Daily\") and then you can add / remove items by hand.\n"..
					cTitle.."Dynamic filter|r - automatically adding quests/achievements to tracker by criterion (e.g. \"|cff00ff00Auto|r Zone\") "..
					"and continuously changing them. This type doesn't allow add / remove items by hand."..
					"When is some Dynamic filter active, header button is green |T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-2:1:32:64:16:30:32:46:0:255:0|t.\n\n"..
					"For Achievements can change searched categories, it will affect the outcome of the filter.\n\n"..
					"This menu displays other options affecting the content of the tracker.",
			paddingBottom = 20,
			shine = KTF.FilterButton,
			shineTop = 10,
			shineBottom = -11,
			shineLeft = -10,
			shineRight = 11,
		},
		{	-- 5
			image = helpPath.."help_quest-item-buttons",
			heading = "Quest Item buttons",
			text = "For support Quest Items you need Questie addon (see page 8). Buttons are out of the tracker, because Blizzard doesn't allow to work with the action buttons inside addons.\n\n"..
					"|T"..helpPath.."help_quest-item-buttons_2:32:32:1:0:64:32:0:32:0:32|t "..cDots.."...|r  This tag indicates quest item in quest. The number inside is for\n"..
					"              identification moved quest item button.\n\n"..
					"|T"..helpPath.."help_quest-item-buttons_2:32:32:0:3:64:32:32:64:0:32|t "..cDots.."...|r  Real quest item button is moved out of the tracker to the left/right\n"..
					"              side (by selected anchor point). The number is the same as for the tag.\n\n"..
					cWarning.."Warning:|r\n"..
					"In some situation during combat, actions around the quest item buttons paused and carried it up after a player is out of combat.",
			paddingBottom = 22,
			shineTop = 3,
			shineBottom = -2,
			shineLeft = -4,
			shineRight = 3,
		},
		{	-- 6
			image = helpPath.."help_tracker-modules",
			heading = "Order of Modules",
			text = "Allows to change the order of modules inside the tracker. Supports all modules including external (e.g. PetTracker).",
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 7
			image = helpPath.."help_quest-log",
			heading = "Quest Log",
			text = cWarning.."Note:|r In Blizzard's Quest Log and supported Quest Log addons is disabled click on Quest Log "..
					"headers (for collapse / expand). This is because collapsed sections hide contained quests for "..KT.TITLE..".\n\n"..

					cTitle.."Supported addons|r\n\n"..
					"- Classic Quest Log\n"..ebSpace.."\n"..
					"- QuestGuru\n"..ebSpace,
			editbox = {
				{
					icon = ICON_URL,
					text = "https://www.wowinterface.com/downloads/info24937-ClassicQuestLogforClassic.html",
					width = 500,
					left = 8,
					bottom = 40,
				},
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/questguru_classic",
					width = 500,
					left = 8,
					bottom = 2,
				}
			},
			paddingBottom = 22,
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 8
			image = helpPath.."help_addon-questie",
			heading = "Support addon Questie",
			text = "Questie support adds some features that use this addon's quest database.\n\n"..
					cTitle.."Zone filtering improvements|r\n"..
					"Improved zone filtering now shows relevant quests in all quest-related zones (start, progress and end locations).\n\n"..
					cTitle.."Quest Item buttons|r\n"..
					"For quests with usable items, shows these items as a buttons next to the tracker (see page 5).\n\n"..
					cTitle.."Quest dropdown menu options|r\n"..
					"- "..cBold.."Show on Map|r - displays a map with closest quest objectives.\n"..
					"- "..cBold.."Set TomTom Waypoint|r - sets TomTom arrow for closest quest objective. This"..
					offs.."option is shown, if addon TomTom is installed.\n\n"..
					"Options "..cBold.."Show on Map|r and "..cBold.."Set TomTom Waypoint|r are disabled, if no map data exists.\n\n"..
					AddonInfo("Questie"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/questie",
					width = 510,
					bottom = 2,
				}
			},
			paddingBottom = 22,
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 9
			image = helpPath.."help_addon-pettracker",
			heading = "Support addon PetTracker",
			text = "PetTracker support adjusts display of zone pet tracking inside "..KT.TITLE..".\nIt also fix some visual bugs.\n\n"..
					AddonInfo("PetTracker"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/pettracker",
					width = 510,
					bottom = 2,
				}
			},
			paddingBottom = 22,
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 10
			image = helpPath.."help_whats-new_logo",
			imageWidth = 192,
			imageHeight = WOW_PROJECT_ID > WOW_PROJECT_CLASSIC and 42 or 22,
			imageTexCoords = WOW_PROJECT_ID > WOW_PROJECT_CLASSIC and { 0, 0.75, 0, 0.65625 } or { 0, 0.75, 0.65625, 1 },
			imagePoint = "TOPRIGHT",
			imageX = -40,
			imageY = WOW_PROJECT_ID > WOW_PROJECT_CLASSIC and -29 or -43,
			imageAbsolute = true,
			heading = "     What's New",
			headingFont = "Fonts\\MORPHEUS.ttf",
			headingSize = 26,
			text = "If you like "..KT.TITLE..", consider supporting it on Patreon "..ICON_HEART.."|r\n"..ebSpace.."\n"..

					(cTitle.."Version 5.2.0|r\n"..
					"- ADDED - support for WoW 5.5.1.63449\n"..
					"- CHANGED - addon support - Questie 11.5.4\n"..
					"- CHANGED (help) - Active Patrons\n"..
					"\n")..

					(cTitle.."Version 5.1.3|r\n"..
					"- FIXED - occasional error when cold starting WoW\n"..
					"\n")..

					(cTitle.."Version 5.1.2|r\n"..
					"- FIXED - Expand after track option not working for all quests\n"..
					"\n")..

					(cTitle.."Version 5.1.1|r\n"..
					"- FIXED (Era) - error when tracker is empty (no PetTracker module)\n"..
					"\n")..

					(cTitle.."Version 5.1.0|r\n"..
					"- ADDED (MoP) - dungeon Challenge Mode support (untested)\n"..
					"- ADDED - addon support - PetTracker 11.2\n"..
					"- CHANGED - addon support - Questie 11.3.1\n"..
					"- CHANGED - PetTracker - improvement\n"..
					"- FIXED - Help - error if no quest is being tracked\n"..
					"- FIXED - PetTracker - sometimes SetWidth nil value error\n"..
					"- PERFORMANCE - optimization of zone filtering code\n"..
					"\n")..

					cTitle.."WoW 5.5.1/1.15.7 - Known issues w/o solution|r\n"..
					"- Clicking on tracked quests or achievements has no response during combat.\n"..
					"- Header buttons Q and A don't work during combat.\n"..
					"- Scenario Proving Grounds is not supported.\n\n"..

					cTitle.."Issue reporting|r\n"..
					"For reporting please use "..cBold.."Tickets|r instead of Comments on CurseForge.\n"..ebSpace.."\n"..

					cWarning.."Before reporting of errors, please deactivate other addons and make sure the bug is not caused "..
					"by a collision with another addon.|r",
			editbox = {
				{
					icon = ICON_URL,
					text = "https://patreon.com/kalielstracker",
					width = 510,
					top = 52,
				},
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/kaliels-tracker-classic/issues",
					width = 510,
					bottom = 40,
				}
			},
			paddingBottom = 20,
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		onShow = function(self, i)
			if dbChar.collapsed then
				KT:MinimizeButton_OnClick()
			end
			if i == 2 then
				local eraMod = WOW_PROJECT_ID > WOW_PROJECT_CLASSIC and 0 or 20
				if KTF.FilterButton then
					self[i].shineLeft = db.headerOtherButtons and -75 + eraMod or -35
				else
					self[i].shineLeft = db.headerOtherButtons and -55 + eraMod or -15
				end
			elseif i == 3 then
				local questLogIndex = GetQuestIndexForWatch(1)
				if questLogIndex then
					local questID = GetQuestIDFromLogIndex(questLogIndex)
					local block = QUEST_TRACKER_MODULE.usedBlocks[questID]
					if block then
						self[i].shine = block
					end
					KTF.Scroll.value = 0
					ObjectiveTracker_Update()
				end
			elseif i == 5 then
				self[i].shine = KTF.Buttons
			end
			end,
		onHide = function()
			T.TriggerTutorial("supporters", 1)
		end
	})

	T.RegisterTutorial("supporters", {
		savedvariable = KT.db.global,
		key = "supportersTutorial",
		title = helpTitle,
		icon = helpPath.."KT_logo",
		font = "Fonts\\FRIZQT__.TTF",
		width = 582,
		height = 610,
		paddingX = 35,
		paddingTop = 26,
		paddingBottom = 24,
		{	-- 1
			heading = "      Become a Patron",
			text = "If you like "..KT.TITLE..", consider supporting it on Patreon.\n\n\n\n"..
					"After 10 years of working on an addon, I started Patreon. It's created as\na compensation for "..
					"the amount of time that addon development requires.\n\n"..
					"                                    Many thanks to all supporters "..ICON_HEART.."\n\n"..
					cTitle.."Active Patrons|r\n"..
					SetFormatedPatronName("Epic", "Liothen", "Emerald Dream")..
					SetFormatedPatronName("Rare", "Ian F")..
					SetFormatedPatronName("Rare", "Spance")..
					SetFormatedPatronName("Uncommon", "Anaara", "Auchindoun")..
					SetFormatedPatronName("Uncommon", "Charles Howarth")..
					SetFormatedPatronName("Uncommon", "Illidanclone", "Kazzak")..
					SetFormatedPatronName("Uncommon", "Mystekal")..
					SetFormatedPatronName("Uncommon", "Paul Westervelt")..
					SetFormatedPatronName("Uncommon", "Semy", "Ravencrest")..
					SetFormatedPatronName("Uncommon", "Xeelee", "Razorfen")..
					SetFormatedPatronName("Common", "Darren Divecha")..
					"\n"..
					cTitle.."Testers|r\n"..
					SetFormatedPlayerName("Asimeria", "Drak'thul")..
					SetFormatedPlayerName("Torresman", "Drak'thul"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://patreon.com/kalielstracker",
					width = 510,
					top = 52,
				}
			},
		},
	})
end

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	SetupTutorials()
	local last = false
	if KT.VERSION ~= KT.db.global.version then
		local data = T.GetTutorial(helpName)
		local index = data.savedvariable[data.key]
		if index then
			last = index < helpNumPages and index or true
			T.ResetTutorial(helpName)
		end
	end
	T.TriggerTutorial(helpName, helpNumPages, last)
end

function M:ShowHelp(index)
	HideUIPanel(SettingsPanel)
	T.ResetTutorial(helpName)
	T.TriggerTutorial(helpName, helpNumPages, index or false)
end

function M:ShowSupporters()
	HideUIPanel(SettingsPanel)
	T.ResetTutorial(supportersName)
	T.TriggerTutorial(supportersName, supportersNumPages)
end