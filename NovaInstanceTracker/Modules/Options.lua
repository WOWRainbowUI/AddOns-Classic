-------------------------
--Nova Instance Tracker--
-------------------------
--https://www.curseforge.com/members/venomisto/projects

local addonName = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaInstanceTracker");
local maxRecordsKept = 250;
local maxTradesKept = 300;
NIT.maxRecordsShown = 250;

NIT.options = {
	name =  "",
	handler = NIT,
	type = 'group',
	args = {
		titleText = {
			type = "description",
			name = "        " .. NIT.prefixColor .. "NovaInstanceTracker (v" .. string.format("%.2f", NIT.version) .. ")",
			fontSize = "large",
			order = 1,
		},
		authorText = {
			type = "description",
			name = "|TInterface\\AddOns\\NovaInstanceTracker\\Media\\nitLogo32:32:32:0:20|t |cFF9CD6DEby Novaspark-Arugal|r  |cFF00C800-|r  |cFFFFFF00For help or suggestions discord.gg/RTKMfTmkdj|r",
			fontSize = "medium",
			order = 2,
		},
		resetAllInstances = {
			type = "execute",
			name = L["resetAllInstancesTitle"];
			desc = L["resetAllInstancesDesc"],
			func = function()
				NIT:resetAllInstances();
			end,
			order = 3,
			confirm = function()
				return "|cFFFFFF00" .. L["resetAllInstancesConfirm"];
			end,
		},
		autoDialogue = {
			type = "header",
			name = L["autoDialogueDesc"],
			order = 23,
		},
		autoSlavePens = {
			type = "toggle",
			name = L["autoSlavePensTitle"],
			desc = L["autoSlavePensDesc"],
			order = 24,
			get = "getAutoSlavePens",
			set = "setAutoSlavePens",
		},
		autoCavernsFlight = {
			type = "toggle",
			name = L["autoCavernsFlightTitle"],
			desc = L["autoCavernsFlightDesc"],
			order = 25,
			get = "getAutoCavernsFlight",
			set = "setAutoCavernsFlight",
		},
		autoCavernsArthas = {
			type = "toggle",
			name = L["autoCavernsArthasTitle"],
			desc = L["autoCavernsArthasDesc"],
			order = 26,
			get = "getAutoCavernsArthas",
			set = "setAutoCavernsArthas",
		},
		autoBlackMorass = {
			type = "toggle",
			name = L["autoBlackMorassTitle"],
			desc = L["autoBlackMorassDesc"],
			order = 27,
			get = "getAutoBlackMorass",
			set = "setAutoBlackMorass",
		},
		autoSfkDoor = {
			type = "toggle",
			name = L["autoSfkDoorTitle"],
			desc = L["autoSfkDoorDesc"],
			order = 27,
			get = "getAutoSfkDoor",
			set = "setAutoSfkDoor",
		},
		colorsHeader = {
			type = "header",
			name = L["colorsHeaderDesc"],
			order = 28,
		},
		chatColor = {
			type = "color",
			name = L["chatColorTitle"],
			desc = L["chatColorDesc"],
			order = 29,
			get = "getChatColor",
			set = "setChatColor",
			hasAlpha = false,
		},
		mergeColor = {
			type = "color",
			name = L["mergeColorTitle"],
			desc = L["mergeColorDesc"],
			order = 30,
			get = "getMergeColor",
			--get = function()
			--	return 0, 255, 0;
			--end,
			set = "setMergeColor",
			hasAlpha = false,
		},
		resetColors = {
			type = "execute",
			name = L["resetColorsTitle"],
			desc = L["resetColorsDesc"],
			func = "resetColors",
			order = 31,
		},
		generalHeader = {
			type = "header",
			name = L["generalHeaderDesc"],
			order = 32,
		},
		enteredMsg = {
			type = "toggle",
			name = L["enteredMsgTitle"],
			desc = L["enteredMsgDesc"],
			order = 33,
			get = "getEnteredMsg",
			set = "setEnteredMsg",
		},
		raidEnteredMsg = {
			type = "toggle",
			name = L["raidEnteredMsgTitle"],
			desc = L["raidEnteredMsgDesc"],
			order = 34,
			get = "getRaidEnteredMsg",
			set = "setRaidEnteredMsg",
		},
		pvpEnteredMsg = {
			type = "toggle",
			name = L["pvpEnteredMsgTitle"],
			desc = L["pvpEnteredMsgDesc"],
			order = 35,
			get = "getPvpEnteredMsg",
			set = "setPvpEnteredMsg",
		},
		noRaidInstanceMergeMsg = {
			type = "toggle",
			name = L["noRaidInstanceMergeMsgTitle"],
			desc = L["noRaidInstanceMergeMsgDesc"],
			order = 36,
			get = "getNoRaidInstanceMergeMsg",
			set = "setNoRaidInstanceMergeMsg",
		},
		instanceResetMsg = {
			type = "toggle",
			name = L["instanceResetMsgTitle"],
			desc = L["instanceResetMsgDesc"],
			order = 37,
			get = "getInstanceResetMsg",
			set = "setInstanceResetMsg",
		},
		minimapButton = {
			type = "toggle",
			name = L["minimapButtonTitle"],
			desc = L["minimapButtonDesc"],
			order = 36,
			get = "getMinimapButton",
			set = "setMinimapButton",
		},
		--[[ignore40Man = { --This shouldn't be an option really, it needs to be tested if 40mans count towards lockout and hardcoded.
			type = "toggle",
			name = L["ignore40ManTitle"],
			desc = L["ignore40ManDesc"],
			order = 31,
			get = "getIgnore40Man",
			set = "setIgnore40Man",
		},]]
		showMoneyTradedChat = {
			type = "toggle",
			name = L["showMoneyTradedChatTitle"],
			desc = L["showMoneyTradedChatDesc"],
			order = 38,
			get = "getShowMoneyTradedChat",
			set = "setShowMoneyTradedChat",
		},
		timeStampFormat = {
			type = "select",
			name = L["timeStampFormatTitle"],
			desc = L["timeStampFormatDesc"],
			values = {
				[12] = L["12 hour"],
				[24] = L["24 hour"],
			},
			sorting = {
				[1] = 12,
				[2] = 24,
			},
			order = 39,
			get = "getTimeStampFormat",
			set = "setTimeStampFormat",
		},
		timeStampZone = {
			type = "select",
			name = L["timeStampZoneTitle"],
			desc = L["timeStampZoneDesc"],
			values = {
				["local"] = L["Local Time"],
				["server"] = L["Server Time"],
			},
			sorting = {
				[1] = "local",
				[2] = "server",
			},
			order = 40,
			get = "getTimeStampZone",
			set = "setTimeStampZone",
		},
		instanceWindowWidth = {
			type = "range",
			name = L["instanceWindowWidthTitle"],
			desc = L["instanceWindowWidthDesc"],
			order = 41,
			get = "getInstanceWindowWidth",
			set = "setInstanceWindowWidth",
			min = 575,
			max = 900,
			softMin = 575,
			softMax = 900,
			step = 1,
			width = 1.5,
		},
		instanceWindowHeight = {
			type = "range",
			name = L["instanceWindowHeightTitle"],
			desc = L["instanceWindowHeightDesc"],
			order = 42,
			get = "getInstanceWindowHeight",
			set = "setInstanceWindowHeight",
			min = 150,
			max = 1200,
			softMin = 150,
			softMax = 1200,
			step = 1,
			width = 1.5,
		},
		charsWindowWidth = {
			type = "range",
			name = L["charsWindowWidthTitle"],
			desc = L["charsWindowWidthDesc"],
			order = 43,
			get = "getCharsWindowWidth",
			set = "setCharsWindowWidth",
			min = 350,
			max = 900,
			softMin = 350,
			softMax = 900,
			step = 1,
			width = 1.5,
		},
		charsWindowHeight = {
			type = "range",
			name = L["charsWindowHeightTitle"],
			desc = L["charsWindowHeightDesc"],
			order = 44,
			get = "getCharsWindowHeight",
			set = "setCharsWindowHeight",
			min = 150,
			max = 950,
			softMin = 150,
			softMax = 950,
			step = 1,
			width = 1.5,
		},
		tradeWindowWidth = {
			type = "range",
			name = L["tradeWindowWidthTitle"],
			desc = L["tradeWindowWidthDesc"],
			order = 45,
			get = "getTradeWindowWidth",
			set = "setTradeWindowWidth",
			min = 350,
			max = 900,
			softMin = 350,
			softMax = 900,
			step = 1,
			width = 1.5,
		},
		tradeWindowHeight = {
			type = "range",
			name = L["tradeWindowHeightTitle"],
			desc = L["tradeWindowHeightDesc"],
			order = 46,
			get = "getTradeWindowHeight",
			set = "setTradeWindowHeight",
			min = 150,
			max = 950,
			softMin = 150,
			softMax = 950,
			step = 1,
			width = 1.5,
		},
		resetFrames = {
			type = "execute",
			name = L["resetFramesTitle"],
			desc = L["resetFramesDesc"],
			func = "resetFrames",
			order = 47,
		},
		detectSameInstance = {
			type = "toggle",
			name = L["detectSameInstanceTitle"],
			desc = L["detectSameInstanceDesc"],
			order = 48,
			get = "getDetectSameInstance",
			set = "setDetectSameInstance",
		},
		logHeader = {
			type = "header",
			name = L["logHeaderDesc"],
			order = 50,
		},
		logTextExample = {
			type = "description",
			name = function()
				return NIT:getLogExample();
			end,
			fontSize = "medium",
			order = 51,
		},
		openInstanceLogFrame = {
			type = "execute",
			name = L["openInstanceLogFrameTitle"],
			func = "openInstanceLogFrame",
			order = 55,
		},
		logSize = {
			type = "range",
			name = L["logSizeTitle"],
			desc = L["logSizeDesc"],
			order = 56,
			get = "getLogSize",
			set = "setLogSize",
			min = 1,
			max = NIT.maxRecordsShown,
			softMin = 1,
			softMax = NIT.maxRecordsShown,
			step = 1,
			width = "double",
		},
		showAltsLog = {
			type = "toggle",
			name = L["showAltsLogTitle"],
			desc = L["showAltsLogDesc"],
			order = 57,
			get = "getShowAltsLog",
			set = "setShowAltsLog",
		},
		showLockoutTime = {
			type = "toggle",
			name = L["showLockoutTimeTitle"],
			desc = L["showLockoutTimeDesc"],
			order = 58,
			get = "getShowLockoutTime",
			set = "setShowLockoutTime",
		},
		show24HourOnly = {
			type = "toggle",
			name = L["show24HourOnlyTitle"],
			desc = L["show24HourOnlyDesc"],
			order = 59,
			get = "getShow24HourOnly",
			set = "setShow24HourOnly",
		},
		timeStringType = {
			type = "select",
			name = L["timeStringTypeTitle"],
			desc = L["timeStringTypeDesc"],
			values = {
				["long"] = L["Long"],
				["medium"] = L["Medium"],
				["short"] = L["Short"],
			},
			sorting = {
				[1] = "long",
				[2] = "medium",
				[3] = "short",
			},
			order = 60,
			get = "getTimeStringType",
			set = "setTimeStringType",
		},
		instanceStatsHeader = {
			type = "header",
			name = L["instanceStatsHeaderDesc"],
			order = 70,
		},
		instanceStatsText = {
			type = "description",
			name = "|cFFFFFF00" .. L["instanceStatsTextDesc"],
			fontSize = "medium",
			order = 71,
		},
		instanceStatsOutput = {
			type = "toggle",
			name = L["instanceStatsOutputTitle"],
			desc = L["instanceStatsOutputDesc"],
			order = 72,
			get = "getInstanceStatsOutput",
			set = "setInstanceStatsOutput",
		},
		instanceStatsOutputWhere = {
			type = "select",
			name = L["instanceStatsOutputWhereTitle"],
			desc = L["instanceStatsOutputWhereDesc"],
			values = {
				["self"] = L["Chat Window"],
				["group"] = L["Group Chat (Party/Raid)"],
			},
			sorting = {
				[1] = "self",
				[2] = "group",
			},
			order = 73,
			width = "double",
			get = "getInstanceStatsOutputWhere",
			set = "setInstanceStatsOutputWhere",
		},
		instanceStatsOutputMobCount = {
			type = "toggle",
			name = L["instanceStatsOutputMobCountTitle"],
			desc = L["instanceStatsOutputMobCountDesc"],
			order = 75,
			get = "getInstanceStatsOutputMobCount",
			set = "setInstanceStatsOutputMobCount",
		},
		instanceStatsOutputXP = {
			type = "toggle",
			name = L["instanceStatsOutputXPTitle"],
			desc = L["instanceStatsOutputXPDesc"],
			order = 76,
			get = "getInstanceStatsOutputXP",
			set = "setInstanceStatsOutputXP",
		},
		instanceStatsOutputXpPerHour = {
			type = "toggle",
			name = L["instanceStatsOutputXpPerHourTitle"],
			desc = L["instanceStatsOutputXpPerHourDesc"],
			order = 77,
			get = "getInstanceStatsOutputXpPerHour",
			set = "setInstanceStatsOutputXpPerHour",
		},
		instanceStatsOutputAverageXP = {
			type = "toggle",
			name = L["instanceStatsOutputAverageXPTitle"],
			desc = L["instanceStatsOutputAverageXPDesc"],
			order = 78,
			get = "getInstanceStatsOutputAverageXP",
			set = "setInstanceStatsOutputAverageXP",
		},
		instanceStatsOutputTime = {
			type = "toggle",
			name = L["instanceStatsOutputTimeTitle"],
			desc = L["instanceStatsOutputTimeDesc"],
			order = 79,
			get = "getInstanceStatsOutputTime",
			set = "setInstanceStatsOutputTime",
		},
		instanceStatsOutputGold = {
			type = "toggle",
			name = L["instanceStatsOutputGoldTitle"],
			desc = L["instanceStatsOutputGoldDesc"],
			order = 80,
			get = "getInstanceStatsOutputGold",
			set = "setInstanceStatsOutputGold",
		},
		instanceStatsOutputAverageGroupLevel = {
			type = "toggle",
			name = L["instanceStatsOutputAverageGroupLevelTitle"],
			desc = L["instanceStatsOutputAverageGroupLevelDesc"],
			order = 81,
			get = "getInstanceStatsOutputAverageGroupLevel",
			set = "setInstanceStatsOutputAverageGroupLevel",
		},
		showStatsInRaid = {
			type = "toggle",
			name = L["showStatsInRaidTitle"],
			desc = L["showStatsInRaidDesc"],
			order = 82,
			get = "getShowStatsInRaid",
			set = "setShowStatsInRaid",
		},
		printRaidInstead = {
			type = "toggle",
			name = L["printRaidInsteadTitle"],
			desc = L["printRaidInsteadDesc"],
			order = 83,
			get = "getPrintRaidInstead",
			set = "setPrintRaidInstead",
		},
		statsOnlyWhenActivity = {
			type = "toggle",
			name = L["statsOnlyWhenActivityTitle"],
			desc = L["statsOnlyWhenActivityDesc"],
			order = 84,
			get = "getStatsOnlyWhenActivity",
			set = "setStatsOnlyWhenActivity",
		},
		instanceStatsOutputRunsPerLevel = {
			type = "toggle",
			name = L["instanceStatsOutputRunsPerLevelTitle"],
			desc = L["instanceStatsOutputRunsPerLevelDesc"],
			order = 85,
			get = "getInstanceStatsOutputRunsPerLevel",
			set = "setInstanceStatsOutputRunsPerLevel",
		},
		instanceStatsOutputRunsNextLevel = {
			type = "toggle",
			name = L["instanceStatsOutputRunsNextLevelTitle"],
			desc = L["instanceStatsOutputRunsNextLevelDesc"],
			order = 86,
			get = "getInstanceStatsOutputRunsNextLevel",
			set = "setInstanceStatsOutputRunsNextLevel",
		},
		instanceStatsOutputRep = {
			type = "toggle",
			name = L["instanceStatsOutputRepTitle"],
			desc = L["instanceStatsOutputRepDesc"],
			order = 87,
			get = "getInstanceStatsOutputRep",
			set = "setInstanceStatsOutputRep",
		},
		instanceStatsOutputHK = {
			type = "toggle",
			name = L["instanceStatsOutputHKTitle"],
			desc = L["instanceStatsOutputHKDesc"],
			order = 88,
			get = "getInstanceStatsOutputHK",
			set = "setInstanceStatsOutputHK",
		},
		instanceStatsOutputCurrency = {
			type = "toggle",
			name = L["instanceStatsOutputCurrencyTitle"],
			desc = L["instanceStatsOutputCurrencyDesc"],
			order = 89,
			get = "getInstanceStatsOutputCurrency",
			set = "setInstanceStatsOutputCurrency",
		},
		trimDataHeader = {
			type = "header",
			name = L["trimDataHeaderDesc"],
			order = 330,
		},
		trimDataText = {
			type = "description",
			name = "|cFF9CD6DE".. L["trimDataTextDesc"],
			fontSize = "medium",
			order = 331,
		},
		trimDataBelowLevel = {
			type = "range",
			name = L["trimDataBelowLevelTitle"],
			desc = L["trimDataBelowLevelDesc"],
			order = 332,
			get = "getTrimDataBelowLevel",
			set = "setTrimDataBelowLevel",
			min = 1,
			max = 60,
			softMin = 1,
			softMax = 60,
			step = 1,
			width = "double",
		},
		trimDataBelowLevelButton = {
			type = "execute",
			name = L["trimDataBelowLevelButtonTitle"],
			desc = L["trimDataBelowLevelButtonDesc"],
			func = "removeCharsBelowLevel",
			order = 333,
			--width = 1.7,
			confirm = function()
				return string.format(L["trimDataBelowLevelButtonConfirm"], "|cFFFFFF00" .. NIT.db.global.trimDataBelowLevel .. "|r");
			end,
		},
		--[[trimDataText2 = {
			type = "description",
			name = "|cFF9CD6DE".. L["trimDataText2Desc"],
			fontSize = "medium",
			order = 334,
		},
		trimDataCharInput = {
			type = "input",
			name = L["trimDataCharInputTitle"],
			desc = L["trimDataCharInputDesc"],
			get = "getTrimDataCharInput",
			set = "setTrimDataCharInput",
			order = 335,
			--width = 1.7,
			confirm = function(self, input)
				return string.format(L["trimDataCharInputConfirm"], "|cFFFFFF00" .. input .. "|r");
			end,
		},]]
		notesHeader = {
			type = "header",
			name = L["notesHeaderDesc"],
			order = 998,
		},
		notesDesc = {
			type = "description",
			name = "|cFFFFFF00" .. L["notesDesc"],
			fontSize = "medium",
			order = 999,
		},
	},
};

function NIT:loadSpecificOptions()
	if (NIT.expansionNum > 2) then
		NIT.options.args["autoGammaBuffHeader"] = {
			type = "header",
			name = L["autoGammaBuffDesc"],
			order = 4,
		};
		NIT.options.args["autoGammaBuff"] = {
			type = "toggle",
			name = L["autoGammaBuffTitle"],
			desc = L["autoGammaBuffDesc"],
			order = 5,
			get = "getAutoGammaBuff",
			set = "setAutoGammaBuff",
		};
		NIT.options.args["autoGammaBuffReminder"] = {
			type = "toggle",
			name = L["autoGammaBuffReminderTitle"],
			desc = L["autoGammaBuffReminderDesc"],
			order = 6,
			get = "getAutoGammaBuffReminder",
			set = "setAutoGammaBuffReminder",
		};
		NIT.options.args["dungeonPopTimer"] = {
			type = "toggle",
			name = L["dungeonPopTimerTitle"],
			desc = L["dungeonPopTimerDesc"],
			order = 7,
			get = "getDungeonPopTimer",
			set = "setDungeonPopTimer",
		};
		NIT.options.args["autoGammaBuffType"] = {
			type = "select",
			name = L["autoGammaBuffTypeTitle"],
			desc = L["autoGammaBuffTypeDesc"],
			values = {
				[1] = "Auto Select (Spec Based)",
				[2] = MELEE,
				[3] = RANGED,
				[4] = HEALER,
				[5] = TANK,
			},
			sorting = {
				[1] = 1,
				[2] = 2,
				[3] = 3,
				[4] = 4,
				[5] = 5,
			},
			order = 8,
			width = 1.7,
			get = "getAutoGammaBuffType",
			set = "setAutoGammaBuffType",
		};
		if (NIT.isMOP) then
			--In mop the buffs changed a bit to caster/phys instead of melee and ranged.
			NIT.options.args.autoGammaBuffType.values[2] = STRING_SCHOOL_PHYSICAL .. " (Xuen)";
			NIT.options.args.autoGammaBuffType.values[3] = gsub(SPELL_SCHOOLMAGICAL, "^%l", strupper) .. " (Yu'lon)";
			NIT.options.args.autoGammaBuffType.values[4] = HEALER .. " (Chi-Ji)";
			NIT.options.args.autoGammaBuffType.values[5] = TANK .. " (Niuzao)";
		end
		NIT.options.args["autoGammaText"] = {
			type = "description",
			name = "|cFFFF0000" .. L["note"] .. " |cFF9CD6DE" .. L["gammaConfigWarning"],
			fontSize = "medium",
			order = 9,
		};
	end
	if (NIT.expansionNum == 3) then
		NIT.options.args["autoWrathDailies"] = {
			type = "toggle",
			name = L["autoWrathDailiesTitle"],
			desc = L["autoWrathDailiesDesc"],
			order = 10,
			get = "getAutoWrathDailies",
			set = "setAutoWrathDailies",
		};
	end
	if (NIT.isSOD) then
		NIT.options.args["lootReminder"] = {
			type = "header",
			name = L["lootReminderDesc"],
			order = 14,
		};
		NIT.options.args["lootReminderReal"] = {
			type = "toggle",
			name = L["lootReminderRealTitle"],
			desc = L["lootReminderRealDesc"],
			order = 15,
			get = "getLootReminderReal",
			set = "setLootReminderReal",
		};
		NIT.options.args["skipRealMsgIfCapped"] = {
			type = "toggle",
			name = L["skipRealMsgIfCappedTitle"],
			desc = L["skipRealMsgIfCappedDesc"],
			order = 16,
			get = "getSkipRealMsgIfCapped",
			set = "setSkipRealMsgIfCapped",
		};
		NIT.options.args["soundsLootReminder"] = {
			type = "select",
			name = L["soundsLootReminderTitle"],
			desc = L["soundsLootReminderDesc"],
			values = function()
				return NIT:getSounds();
			end,
			order = 17,
			get = "getSoundsLootReminder",
			set = "setSoundsLootReminder",
		};
		NIT.options.args["lootReminderSize"] = {
			type = "range",
			name = L["lootReminderSizeTitle"],
			desc = L["lootReminderSizeDesc"],
			order = 18,
			get = "getLootReminderSize",
			set = "setLootReminderSize",
			min = 10,
			max = 150,
			softMin = 10,
			softMax = 150,
			step = 1,
		};
		NIT.options.args["lootReminderX"] = {
			type = "range",
			name = L["lootReminderXTitle"],
			desc = L["lootReminderXDesc"],
			order = 19,
			get = "getLootReminderX",
			set = "setLootReminderX",
			min = -1000,
			max = 1000,
			softMin = -1000,
			softMax = 1000,
			step = 1,
			width = 1.5,
		};
		NIT.options.args["lootReminderY"] = {
			type = "range",
			name = L["lootReminderYTitle"],
			desc = L["lootReminderYDesc"],
			order = 20,
			get = "getLootReminderY",
			set = "setLootReminderY",
			min = -1000,
			max = 1000,
			softMin = -1000,
			softMax = 1000,
			step = 1,
			width = 1.5,
		};
		NIT.options.args["lootReminderMysRelic"] = {
			type = "toggle",
			name = L["lootReminderMysRelicTitle"],
			desc = L["lootReminderMysRelicDesc"],
			order = 21,
			get = "getLootReminderMysRelic",
			set = "setLootReminderMysRelic",
		};
		NIT.options.args["lootReminderMysRelicParty"] = {
			type = "toggle",
			name = L["lootReminderMysRelicPartyTitle"],
			desc = L["lootReminderMysRelicPartyDesc"],
			order = 22,
			get = "getLootReminderMysRelicParty",
			set = "setLootReminderMysRelicParty",
		};
	end
	if (NIT.isClassic) then
		NIT.options.args["argentDawnTrinketReminder"] = {
			type = "toggle",
			name = L["argentDawnTrinketReminderTitle"],
			desc = L["argentDawnTrinketReminderDesc"],
			order = 49,
			get = "getArgentDawnTrinketReminder",
			set = "setArgentDawnTrinketReminder",
			width = 1.5,
		};
	end
end
		
		
function NIT:getLogExample()
	--Simulate a log entry.
	local classLocalized, classEnglish = UnitClass("player");
	local v = {
		playerName = UnitName("player"),
		classEnglish = classEnglish,
		instanceName = L["Test Instance"],
		enteredTime = GetServerTime() - 600,
		leftTime = GetServerTime() - 300,
	}
	local line = NIT:buildInstanceLineFrameString(v, 1);
	return L["Example"] .. ": " .. line;
end

------------------------
--Load option defaults--
------------------------
NIT.optionDefaults = {
	global = {
		--The Ace3 GUI color picker seems to play better with decimals.
		--Some colors work with 255 method, some don't.
		--chatColorR = 255, chatColorG = 255, chatColorB = 0,
		--prefixColorR = 255, prefixColorG = 105, prefixColorB = 0,
		chatColorR = 1, chatColorG = 1, chatColorB = 0,
		mergeColorR = 1, mergeColorG = 1, mergeColorB = 0,
		prefixColorR = 1, prefixColorG = 0.4117647058823529, prefixColorB = 0,
		logSize = 100,
		showAltsLog = true,
		timeStringType = "medium",
		showLockoutTime = true,
		maxRecordsKept = maxRecordsKept,
		maxTradesKept = maxTradesKept,
		instanceResetMsg = true,
		enteredMsg = true,
		raidEnteredMsg = false,
		pvpEnteredMsg = true,
		timeStampFormat = 12,
		timeStampZone = "local",
		ignore40Man = false,
		showMoneyTradedChat = true,
		instanceStatsOutputMobCount = true,
		instanceStatsOutputXP = true,
		instanceStatsOutputXPPercent = true,
		instanceStatsOutputAverageXP = false,
		instanceStatsOutputTime = true,
		instanceStatsOutputGold = true,
		instanceStatsOutputAverageGroupLevel = false,
		instanceStatsOutputRep = true,
		instanceStatsOutputHK = true,
		instanceStatsOutputXpPerHour = true,
		instanceStatsOutputCurrency = true,
		lastVersionMsg = 0,
		moneyString = "textures",
		instanceStatsOutput = true,
		instanceStatsOutputWhere = "self",
		minimapIcon = {["minimapPos"] = 180, ["hide"] = false},
		minimapButton = true,
		restedCharsOnly = false,
		detectSameInstance = true,
		showStatsInRaid = false,
		printRaidInstead = true,
		statsOnlyWhenActivity = false,
		show24HourOnly = false,
		trimDataBelowLevel = 1,
		instanceStatsOutputRunsPerLevel = true,
		instanceStatsOutputRunsNextLevel = false,
		instanceWindowWidth = 620,
		instanceWindowHeight = 501,
		charsWindowWidth = 600,
		charsWindowHeight = 350,
		tradeWindowWidth = 580,
		tradeWindowHeight = 320,
		copyTradeTime = true,
		copyTradeZone = true,
		copyTradeTimeAgo = true,
		copyTradeRecords = 100;
		charsMinLevel = 1,
		autoSfkDoor = true,
		autoSlavePens = true,
		autoBlackMorass = true,
		autoCavernsFlight = true,
		autoCavernsArthas = true,
		showPvpLog = true,
		showPveLog = true,
		noRaidInstanceMergeMsg = true,
		resetCharData = true, --Reset one time to delete data before alt UI stuff was added.
		autoGammaBuff = true,
		autoGammaBuffReminder = true,
		autoGammaBuffType = 1,
		dungeonPopTimer = true,
		autoWrathDailies = true,
		lootReminderReal = true,
		lootReminderSize = 24,
		lootReminderX = -10,
		lootReminderY = 150,
		lootReminderMinimap = true,
		lootReminderMysRelic = true,
		lootReminderMysRelicParty = false,
		wipeUpgradeData = true,
		argentDawnTrinketReminder = true,
		skipRealMsgIfCapped = false,
		soundsLootReminder = "None",
		resetCelestialBuffChoice = true,
	},
};

if (NIT.isRetail) then
	NIT.optionDefaults.global.instanceWindowWidth = 650;
end

function NIT:resetMinimapPosition()
	NIT.db.global.minimapIcon = NIT.optionDefaults.global.minimapIcon;
end

--5 per hour and 30 per day lockouts are character specific.
function NIT:buildDatabase()
	--Create realm tables if they don't exist.
	if (not self.db.global[NIT.realm]) then
		self.db.global[NIT.realm] = {};
	end
	if (not self.db.global[NIT.realm].instances) then
		self.db.global[NIT.realm].instances = {};
	end
	--Debug stuff.
	--[[self.db.global[NIT.realm].instances = self.db.global["Thunderstrike"].instances
	for i = 1, 500 do
		if (i > 5 and self.db.global[NIT.realm].instances[i]) then
			print(i)
			self.db.global[NIT.realm].instances[i] = nil
		end
	end]]
 	if (not self.db.global[NIT.realm].trades) then
		self.db.global[NIT.realm].trades = {};
	end
	if (not self.db.global[NIT.realm].myChars) then
		self.db.global[NIT.realm].myChars = {};
	end
	if (not self.db.global[NIT.realm].myChars[UnitName("player")]) then
		self.db.global[NIT.realm].myChars[UnitName("player")] = {};
	end
	if (not self.db.global[NIT.realm].myChars[UnitName("player")].bossKills) then
		self.db.global[NIT.realm].myChars[UnitName("player")].bossKills = {};
	end
	if (not self.db.global[NIT.realm].myChars[UnitName("player")].trackedItems) then
		self.db.global[NIT.realm].myChars[UnitName("player")].trackedItems = {};
	end
	--if (not self.db.global[NIT.realm].myChars[UnitName("player")].levelLog) then
	--	self.db.global[NIT.realm].myChars[UnitName("player")].levelLog = {};
	--end
	if (not self.db.global[NIT.realm].gammaBuffSettings) then
		self.db.global[NIT.realm].gammaBuffSettings = {};
	end
	if (not self.db.global.versions) then
		self.db.global.versions = {};
	end
	self.data = self.db.global[NIT.realm];
end

local function loadNewVersionFrame(version, notes, title, icon, x, y)
	if (not _G[addonName .. "UpdateNotesFrame"]) then
 		local frame = CreateFrame("Frame", _G[addonName .. "UpdateNotesFrame"], UIParent, "BackdropTemplate");
		frame:SetToplevel(true);
		frame:SetMovable(true);
		frame:EnableMouse(true);
		frame:SetUserPlaced(false);
		frame:SetFrameStrata("HIGH");
		frame:SetSize(500, 500);
		frame:SetPoint("TOP", UIParent, "CENTER", x, y);
		frame:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = [[Interface/Buttons/WHITE8X8]],
			edgeSize = 1,
			insets = {top = 4, left = 4, bottom = 4, right = 4},
		});
		frame:SetBackdropColor(0, 0, 0, 1);
		frame:SetBackdropBorderColor(1, 1, 1, 0.5);
		frame.title = frame:CreateFontString("$parentFS", "ARTWORK");
		frame.title:SetFontObject(Game15Font);
		frame.title:SetPoint("TOP", 0, -8);
		frame.title2 = frame:CreateFontString("$parentFS", "ARTWORK");
		frame.title2:SetFontObject(Game15Font);
		frame.title2:SetPoint("TOP", 0, -24);
		frame.fs = frame:CreateFontString("$parentFS", "ARTWORK");
		frame.fs:SetFontObject(Game13Font);
		frame.fs:SetPoint("TOPLEFT", 15, -52);
		frame.fs:SetPoint("TOPRIGHT", -15, -52);
		frame.fs:SetJustifyH("LEFT");
		frame.texture = frame:CreateTexture(nil, "ARTWORK");
		--frame.texture:SetPoint("TOPLEFT", 10, -10);
		frame.texture:SetPoint("TOPRIGHT", frame.title, "TOPLEFT", -10, 0);
		frame.texture:SetSize(30, 30);
		frame.closeButton = CreateFrame("Button", "$parentClose", frame, "UIPanelCloseButton");
		frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1);
		frame.closeButton:SetWidth(26);
		frame.closeButton:SetHeight(26);
		frame.closeButton:SetFrameLevel(15);
		frame.closeButton:SetScript("OnClick", function(self, arg)
			frame:Hide();
		end)
		frame:SetScript("OnMouseDown", function(self, button)
			if (button == "LeftButton" and not self.isMoving) then
				self:StartMoving();
				self.isMoving = true;
			end
		end)
		frame:SetScript("OnMouseUp", function(self, button)
			if (button == "LeftButton" and self.isMoving) then
				self:StopMovingOrSizing();
				self.isMoving = false;
				frame:SetUserPlaced(false);
			end
		end)
		frame:SetScript("OnHide", function(self)
			if (self.isMoving) then
				self:StopMovingOrSizing();
				self.isMoving = false;
			end
	end)
		_G[addonName .. "UpdateNotesFrame"] = frame;
 	end
 	local frame = _G[addonName .. "UpdateNotesFrame"];
 	frame.texture:SetTexture(icon);
 	frame.title:SetText("|cFFFFFF00" .. title);
	frame.title2:SetText("|cFF00FF00New in|r |cFFFF6900v" .. string.format("%.2f", version) .. "");
 	local text = "";
	if (notes) then
		for k, v in ipairs(notes) do
			if (string.match(v, "Version 1") or v == " ") then
				text = text .. "|cFFFFFFFF" .. v .. "|r\n\n";
			else
				text = text .. "|TInterface\\QUESTFRAME\\UI-Quest-BulletPoint:12:12:0:0|t |cFFFFFFFF" .. v .. "|r\n\n";
			end
		end
	end
	if (text ~= "") then
		frame.fs:SetText(text);
		local height = frame.fs:GetStringHeight();
		frame:SetHeight(height + 75);
		frame:Show();
	end
end

function NIT:checkNewVersion()
	--NIT.db.global.versions = {}; --To test.
	local newVersionNotes = 2.08;
	if (NIT.version and NIT.version == newVersionNotes) then
		if (not NIT.db.global.versions[NIT.version]) then
			if (NIT.isMOP) then
				local notes = {
					"Added arena type (2v2/3v3/5v5) and rating changes to the instance log for expansions without teams (MoP+).",
					"Improved a bunch of other stuff with arena log entries.",
					"Fixed some issues with recording rep gains that gave a bonus amount (like account wide MoP unlocks).",
					"Fixed ret paladin auto celestial buff, it chooses melee but can be changed to magical in options (they seem to do about the same dmg for rets?).",
				};
				loadNewVersionFrame(NIT.version, notes, "Nova Instance Tracker", "Interface\\AddOns\\NovaInstanceTracker\\Media\\portal", 30, 200);
			end
			--Wipe old data.
			NIT.db.global.versions = {};
			--Set this version has been loaded before.
			NIT.db.global.versions[NIT.version] = GetServerTime();
		end
	end
end

function NIT:setLogSize(info, value)
	self.db.global.logSize = value;
end

function NIT:getLogSize(info)
	return self.db.global.logSize;
end

--Show all alts in the log window.
function NIT:setShowAltsLog(info, value)
	self.db.global.showAltsLog = value;
	NIT:hideAllLineFrames();
	NIT:recalcInstanceLineFrames();
	if (NIT.instanceFrameShowsAltsButton) then
		--Refresh the checkbox on instance log frame.
		NIT.instanceFrameShowsAltsButton:SetChecked(value);
	end
end

function NIT:getShowAltsLog(info)
	return self.db.global.showAltsLog;
end

--Show the past 24h in log only.
function NIT:setShow24HourOnly(info, value)
	self.db.global.show24HourOnly = value;
	NIT:hideAllLineFrames();
	NIT:recalcInstanceLineFrames();
end

function NIT:getShow24HourOnly(info)
	return self.db.global.show24HourOnly;
end

--Show lockout instead of time entered.
function NIT:setShowLockoutTime(info, value)
	self.db.global.showLockoutTime = value;
	NIT:recalcInstanceLineFrames();
end

function NIT:getShowLockoutTime(info)
	return self.db.global.showLockoutTime;
end
--Time strings in instance log.
function NIT:setTimeStringType(info, value)
	self.db.global.timeStringType = value;
	NIT:recalcInstanceLineFrames();
end

function NIT:getTimeStringType(info)
	return self.db.global.timeStringType;
end

function NIT:setInstanceResetMsg(info, value)
	self.db.global.instanceResetMsg = value;
end

function NIT:getInstanceResetMsg(info)
	return self.db.global.instanceResetMsg;
end

function NIT:setEnteredMsg(info, value)
	self.db.global.enteredMsg = value;
end

function NIT:getEnteredMsg(info)
	return self.db.global.enteredMsg;
end

function NIT:setRaidEnteredMsg(info, value)
	self.db.global.raidEnteredMsg = value;
end

function NIT:getRaidEnteredMsg(info)
	return self.db.global.raidEnteredMsg;
end

function NIT:setPvpEnteredMsg(info, value)
	self.db.global.pvpEnteredMsg = value;
end

function NIT:getPvpEnteredMsg(info)
	return self.db.global.pvpEnteredMsg;
end

function NIT:setNoRaidInstanceMergeMsg(info, value)
	self.db.global.noRaidInstanceMergeMsg = value;
end

function NIT:getNoRaidInstanceMergeMsg(info)
	return self.db.global.noRaidInstanceMergeMsg;
end

--Chat color.
function NIT:setChatColor(info, r, g, b, a)
	self.db.global.chatColorR, self.db.global.chatColorG, self.db.global.chatColorB = r, g, b;
	NIT.chatColor = "|cff" .. NIT:RGBToHex(self.db.global.chatColorR, self.db.global.chatColorG, self.db.global.chatColorB);
end

function NIT:getChatColor(info)
	return self.db.global.chatColorR, self.db.global.chatColorG, self.db.global.chatColorB;
end

--Merge color.
function NIT:setMergeColor(info, r, g, b, a)
	self.db.global.mergeColorR, self.db.global.mergeColorG, self.db.global.mergeColorB = r, g, b;
	NIT.mergeColor = "|cff" .. NIT:RGBToHex(self.db.global.mergeColorR, self.db.global.mergeColorG, self.db.global.mergeColorB);
end

function NIT:getMergeColor(info)
	return self.db.global.mergeColorR, self.db.global.mergeColorG, self.db.global.mergeColorB;
end

--Reset colors.
function NIT:resetColors(info, r, g, b, a)
	self.db.global.chatColorR = self.optionDefaults.global.chatColorR;
	self.db.global.chatColorG = self.optionDefaults.global.chatColorG;
	self.db.global.chatColorB = self.optionDefaults.global.chatColorB;
	self.db.global.mergeColorR = self.optionDefaults.global.mergeColorR;
	self.db.global.mergeColorG = self.optionDefaults.global.mergeColorG;
	self.db.global.mergeColorB = self.optionDefaults.global.mergeColorB;
	NIT.chatColor = "|cff" .. NIT:RGBToHex(self.db.global.chatColorR, self.db.global.chatColorG, self.db.global.chatColorB);
	NIT.mergeColor = "|cff" .. NIT:RGBToHex(self.db.global.mergeColorR, self.db.global.mergeColorG, self.db.global.mergeColorB);
end

--Which timestamp format to use 12h/24h.
function NIT:setTimeStampFormat(info, value)
	self.db.global.timeStampFormat = value;
end

function NIT:getTimeStampFormat(info)
	return self.db.global.timeStampFormat;
end

--Which timezone format to use local/server.
function NIT:setTimeStampZone(info, value)
	self.db.global.timeStampZone = value;
end

function NIT:getTimeStampZone(info)
	return self.db.global.timeStampZone;
end

--Ignore 40man instances.
function NIT:setIgnore40Man(info, value)
	self.db.global.ignore40Man = value;
end

function NIT:getIgnore40Man(info)
	return self.db.global.ignore40Man;
end

--Minimap button
function NIT:setMinimapButton(info, value)
	self.db.global.minimapButton = value;
	if (value) then
		NIT.LDBIcon:Show("NovaInstanceTracker");
		self.db.global.minimapIcon.hide = false;
	else
		NIT.LDBIcon:Hide("NovaInstanceTracker");
		self.db.global.minimapIcon.hide = true;
	end
end

function NIT:getMinimapButton(info)
	return self.db.global.minimapButton;
end

--Show gold trades in chat.
function NIT:setShowMoneyTradedChat(info, value)
	self.db.global.showMoneyTradedChat = value;
end

function NIT:getShowMoneyTradedChat(info)
	return self.db.global.showMoneyTradedChat;
end

--Auto detect same instance as last.
function NIT:setDetectSameInstance(info, value)
	self.db.global.detectSameInstance = value;
end

function NIT:getDetectSameInstance(info)
	return self.db.global.detectSameInstance;
end

--Show stats when exiting dungeon.
function NIT:setInstanceStatsOutput(info, value)
	self.db.global.instanceStatsOutput = value;
end

function NIT:getInstanceStatsOutput(info)
	return self.db.global.instanceStatsOutput;
end

--Where to show stats when exiting dungeon.
function NIT:setInstanceStatsOutputWhere(info, value)
	self.db.global.instanceStatsOutputWhere = value;
end

function NIT:getInstanceStatsOutputWhere(info)
	return self.db.global.instanceStatsOutputWhere;
end

--Mob count stats output when exiting dungeon.
function NIT:setInstanceStatsOutputMobCount(info, value)
	self.db.global.instanceStatsOutputMobCount = value;
end

function NIT:getInstanceStatsOutputMobCount(info)
	return self.db.global.instanceStatsOutputMobCount;
end

--XP stats output when exiting dungeon.
function NIT:setInstanceStatsOutputXP(info, value)
	self.db.global.instanceStatsOutputXP = value;
end

function NIT:getInstanceStatsOutputXP(info)
	return self.db.global.instanceStatsOutputXP;
end

--XP per hour stats output when exiting dungeon.
function NIT:setInstanceStatsOutputXpPerHour(info, value)
	self.db.global.instanceStatsOutputXpPerHour = value;
end

function NIT:getInstanceStatsOutputXpPerHour(info)
	return self.db.global.instanceStatsOutputXpPerHour;
end

--Average XP stats output when exiting dungeon.
function NIT:setInstanceStatsOutputAverageXP(info, value)
	self.db.global.instanceStatsOutputAverageXP = value;
end

function NIT:getInstanceStatsOutputAverageXP(info)
	return self.db.global.instanceStatsOutputAverageXP;
end

--Time stats output when exiting dungeon.
function NIT:setInstanceStatsOutputTime(info, value)
	self.db.global.instanceStatsOutputTime = value;
end

function NIT:getInstanceStatsOutputTime(info)
	return self.db.global.instanceStatsOutputTime;
end

--Gold stats output when exiting dungeon.
function NIT:setInstanceStatsOutputGold(info, value)
	self.db.global.instanceStatsOutputGold = value;
end

function NIT:getInstanceStatsOutputGold(info)
	return self.db.global.instanceStatsOutputGold;
end

--Average group level stats output when exiting dungeon.
function NIT:setInstanceStatsOutputAverageGroupLevel(info, value)
	self.db.global.instanceStatsOutputAverageGroupLevel = value;
end

function NIT:getInstanceStatsOutputAverageGroupLevel(info)
	return self.db.global.instanceStatsOutputAverageGroupLevel;
end

--Show stats while in raid.
function NIT:setShowStatsInRaid(info, value)
	self.db.global.showStatsInRaid = value;
end

function NIT:getShowStatsInRaid(info)
	return self.db.global.showStatsInRaid;
end

--Print to chat if in raid instead.
function NIT:setPrintRaidInstead(info, value)
	self.db.global.printRaidInstead = value;
end

function NIT:getPrintRaidInstead(info)
	return self.db.global.printRaidInstead;
end

--Show stats only when activity (xp, mob kills etc).
function NIT:setStatsOnlyWhenActivity(info, value)
	self.db.global.statsOnlyWhenActivity = value;
end

function NIT:getStatsOnlyWhenActivity(info)
	return self.db.global.statsOnlyWhenActivity;
end

--Trim data of characters below this level.
function NIT:setTrimDataBelowLevel(info, value)
	self.db.global.trimDataBelowLevel = value;
end

function NIT:getTrimDataBelowLevel(info)
	return self.db.global.trimDataBelowLevel;
end

--Trim data for single char.
function NIT:setTrimDataCharInput(info, value)
	NIT:removeSingleChar(value);
end

function NIT:getTrimDataCharInput(info)

end

--Runs per level stats output when exiting dungeon.
function NIT:setInstanceStatsOutputRunsPerLevel(info, value)
	self.db.global.instanceStatsOutputRunsPerLevel = value;
end

function NIT:getInstanceStatsOutputRunsPerLevel(info)
	return self.db.global.instanceStatsOutputRunsPerLevel;
end

--Runs until next level stats output when exiting dungeon.
function NIT:setInstanceStatsOutputRunsNextLevel(info, value)
	self.db.global.instanceStatsOutputRunsNextLevel = value;
end

function NIT:getInstanceStatsOutputRunsNextLevel(info)
	return self.db.global.instanceStatsOutputRunsNextLevel;
end

--Rep stats output when exiting dungeon.
function NIT:setInstanceStatsOutputRep(info, value)
	self.db.global.instanceStatsOutputRep = value;
end

function NIT:getInstanceStatsOutputRep(info)
	return self.db.global.instanceStatsOutputRep;
end

--Honor kills stats output when exiting bg.
function NIT:setInstanceStatsOutputHK(info, value)
	self.db.global.instanceStatsOutputHK = value;
end

function NIT:getInstanceStatsOutputHK(info)
	return self.db.global.instanceStatsOutputHK;
end

function NIT:setInstanceStatsOutputCurrency(info, value)
	self.db.global.instanceStatsOutputCurrency = value;
end

function NIT:getInstanceStatsOutputCurrency(info)
	return self.db.global.instanceStatsOutputCurrency;
end

--Instance window dimensions.
function NIT:setInstanceWindowWidth(info, value)
	self.db.global.instanceWindowWidth = value;
	_G["NITInstanceFrame"]:SetWidth(value);
	_G["NITInstanceFrame"].EditBox:SetWidth(value - 30);
end

function NIT:getInstanceWindowWidth(info)
	return self.db.global.instanceWindowWidth;
end

function NIT:setInstanceWindowHeight(info, value)
	self.db.global.instanceWindowHeight = value;
	_G["NITInstanceFrame"]:SetHeight(value);
end

function NIT:getInstanceWindowHeight(info)
	return self.db.global.instanceWindowHeight;
end

--Chars window dimensions.
function NIT:setCharsWindowWidth(info, value)
	self.db.global.charsWindowWidth = value;
	_G["NITAltsFrame"]:SetWidth(value);
	_G["NITAltsFrame"].EditBox:SetWidth(value - 30);
end

function NIT:getCharsWindowWidth(info)
	return self.db.global.charsWindowWidth;
end

function NIT:setCharsWindowHeight(info, value)
	self.db.global.charsWindowHeight = value;
	_G["NITAltsFrame"]:SetHeight(value);
end

function NIT:getCharsWindowHeight(info)
	return self.db.global.charsWindowHeight;
end

--Trade window dimensions.
function NIT:setTradeWindowWidth(info, value)
	self.db.global.tradeWindowWidth = value;
	_G["NITTradeLogFrame"]:SetWidth(value);
	_G["NITTradeLogFrame"].EditBox:SetWidth(value - 30);
end

function NIT:getTradeWindowWidth(info)
	return self.db.global.tradeWindowWidth;
end

function NIT:setTradeWindowHeight(info, value)
	self.db.global.tradeWindowHeight = value;
	_G["NITTradeLogFrame"]:SetHeight(value);
end

function NIT:getTradeWindowHeight(info)
	return self.db.global.tradeWindowHeight;
end

--Reset frames.
function NIT:resetFrames()
	self.db.global.instanceWindowWidth = self.optionDefaults.global.instanceWindowWidth;
	self.db.global.instanceWindowHeight = self.optionDefaults.global.instanceWindowHeight;
	self.db.global.charsWindowWidth = self.optionDefaults.global.charsWindowWidth;
	self.db.global.charsWindowHeight = self.optionDefaults.global.charsWindowHeight;
	self.db.global.tradeWindowWidth = self.optionDefaults.global.tradeWindowWidth;
	self.db.global.tradeWindowHeight = self.optionDefaults.global.tradeWindowHeight;
	_G["NITInstanceFrame"]:SetWidth(self.db.global.instanceWindowWidth);
	_G["NITInstanceFrame"].EditBox:SetWidth(self.db.global.instanceWindowWidth - 30);
	_G["NITInstanceFrame"]:SetHeight(self.db.global.instanceWindowHeight);
	_G["NITInstanceFrame"]:ClearAllPoints();
	_G["NITInstanceFrame"]:SetPoint("CENTER", UIParent, 0, 100);
	_G["NITAltsFrame"]:SetWidth(self.db.global.charsWindowWidth);
	_G["NITAltsFrame"].EditBox:SetWidth(self.db.global.charsWindowWidth - 30);
	_G["NITAltsFrame"]:SetHeight(self.db.global.charsWindowHeight);
	_G["NITAltsFrame"]:ClearAllPoints();
	_G["NITAltsFrame"]:SetPoint("CENTER", UIParent, 0, 100);
	_G["NITTradeLogFrame"]:SetWidth(self.db.global.tradeWindowWidth);
	_G["NITTradeLogFrame"].EditBox:SetWidth(self.db.global.tradeWindowWidth - 30);
	_G["NITTradeLogFrame"]:SetHeight(self.db.global.tradeWindowHeight);
	_G["NITTradeLogFrame"]:ClearAllPoints();
	_G["NITTradeLogFrame"]:SetPoint("CENTER", UIParent, 20, 120);
	_G["NITTradeCopyFrame"]:SetWidth(self.db.global.tradeWindowWidth);
	_G["NITTradeCopyFrame"].EditBox:SetWidth(self.db.global.tradeWindowWidth - 30);
	_G["NITTradeCopyFrame"]:SetHeight(self.db.global.tradeWindowHeight);
	_G["NITTradeCopyFrame"]:ClearAllPoints();
	_G["NITTradeCopyFrame"]:SetPoint("CENTER", UIParent, -70, 150);
	NIT:print(L["resetFramesMsg"]);
end

--Auto dialogue slave pens.
function NIT:setAutoSlavePens(info, value)
	self.db.global.autoSlavePens = value;
end

function NIT:getAutoSlavePens(info)
	return self.db.global.autoSlavePens;
end

--Auto dialogue caverns flight.
function NIT:setAutoCavernsFlight(info, value)
	self.db.global.autoCavernsFlight = value;
end

function NIT:getAutoCavernsFlight(info)
	return self.db.global.autoCavernsFlight;
end

--Auto dialogue caverns arthas.
function NIT:setAutoCavernsArthas(info, value)
	self.db.global.autoCavernsArthas = value;
end

function NIT:getAutoCavernsArthas(info)
	return self.db.global.autoCavernsArthas;
end

--Auto dialogue black morass.
function NIT:setAutoBlackMorass(info, value)
	self.db.global.autoBlackMorass = value;
end

function NIT:getAutoBlackMorass(info)
	return self.db.global.autoBlackMorass;
end

--Auto dialogue sfk door.
function NIT:setAutoSfkDoor(info, value)
	self.db.global.autoSfkDoor = value;
end

function NIT:getAutoSfkDoor(info)
	return self.db.global.autoSfkDoor;
end

--Auto gamma buff dialogue.
function NIT:setAutoGammaBuff(info, value)
	self.db.global.autoGammaBuff = value;
end

function NIT:getAutoGammaBuff(info)
	return self.db.global.autoGammaBuff;
end

--Auto gamma buff reminder.
function NIT:setAutoGammaBuffReminder(info, value)
	self.db.global.autoGammaBuffReminder = value;
end

function NIT:getAutoGammaBuffReminder(info)
	return self.db.global.autoGammaBuffReminder;
end

--Dungeon pop timer.
function NIT:setDungeonPopTimer(info, value)
	self.db.global.dungeonPopTimer = value;
end

function NIT:getDungeonPopTimer(info)
	return self.db.global.dungeonPopTimer;
end

--Auto get daily quests.
function NIT:setAutoWrathDailies(info, value)
	self.db.global.autoWrathDailies = value;
end

function NIT:getAutoWrathDailies(info)
	return self.db.global.autoWrathDailies;
end

--Which gamma dung buff to get.
function NIT:setAutoGammaBuffType(info, value)
	if (NIT.data.gammaBuffSettings) then
		NIT.data.gammaBuffSettings[UnitName("player")] = value;
	else
		self.db.global.autoGammaBuffType = value;
	end
end

function NIT:getAutoGammaBuffType(info)
	if (NIT.data.gammaBuffSettings and NIT.data.gammaBuffSettings[UnitName("player")]) then
		return NIT.data.gammaBuffSettings[UnitName("player")];
	else
		return self.db.global.autoGammaBuffType;
	end
end

--Loot reminder Tarnished Undermine Real.
function NIT:setLootReminderReal(info, value)
	self.db.global.lootReminderReal = value;
end

function NIT:getLootReminderReal(info)
	return self.db.global.lootReminderReal;
end

--Loot reminder Tarnished Undermine Real skip if capped.
function NIT:setSkipRealMsgIfCapped(info, value)
	self.db.global.skipRealMsgIfCapped = value;
end

function NIT:getSkipRealMsgIfCapped(info)
	return self.db.global.skipRealMsgIfCapped;
end

--Kara relics in SoD.
function NIT:setLootReminderMysRelic(info, value)
	self.db.global.lootReminderMysRelic = value;
end

function NIT:getLootReminderMysRelic(info)
	return self.db.global.lootReminderMysRelic;
end

function NIT:setLootReminderMysRelicParty(info, value)
	self.db.global.lootReminderMysRelicParty = value;
end

function NIT:getLootReminderMysRelicParty(info)
	return self.db.global.lootReminderMysRelicParty;
end

--Loot reminder text size.
function NIT:setLootReminderSize(info, value)
	self.db.global.lootReminderSize = value;
	NIT:updateLootReminderFrame(true);
end

function NIT:getLootReminderSize(info)
	return self.db.global.lootReminderSize;
end

--Loot reminder X position.
function NIT:setLootReminderX(info, value)
	self.db.global.lootReminderX = value;
	NIT:updateLootReminderFrame(true);
end

function NIT:getLootReminderX(info)
	return self.db.global.lootReminderX;
end

--Loot reminder Y position.
function NIT:setLootReminderY(info, value)
	self.db.global.lootReminderY = value;
	NIT:updateLootReminderFrame(true);
end

function NIT:getLootReminderY(info)
	return self.db.global.lootReminderY;
end

--Argent Dawn trinket reminder.
function NIT:setArgentDawnTrinketReminder(info, value)
	self.db.global.rgentDawnTrinketReminder = value;
end

function NIT:getArgentDawnTrinketReminder(info)
	return self.db.global.argentDawnTrinketReminder;
end

--Loot reminder sound.
function NIT:setSoundsLootReminder(info, value)
	self.db.global.soundsLootReminder = value;
	local soundFile = NIT.LSM:Fetch("sound", value);
	PlaySoundFile(soundFile, "Master");
end

function NIT:getSoundsLootReminder(info)
	return self.db.global.soundsLootReminder;
end

local sounds = {
	--["NIT - Zelda"] = "Interface\\AddOns\\NovaInstanceTracker\\Media\\Zelda.ogg",
};

function NIT:getSounds(type)
	NIT.sounds = {};
	for _, v in pairs(NIT.LSM:List("sound")) do
		NIT.sounds[v] = v;
	end
	for k, v in NIT:pairsByKeys(sounds) do
		NIT.sounds[k] = k;
	end
	NIT.sounds["None"] = "None";
	return NIT.sounds;
end

function NIT:playSound(sound)
	if (NIT.db.global[sound] and NIT.db.global[sound] ~= "None") then
		local soundFile = NIT.LSM:Fetch("sound", NIT.db.global[sound]);
		PlaySoundFile(soundFile, "Master");
	end
end