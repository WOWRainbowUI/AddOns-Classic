﻿--[[--
	alex@0
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;
local l10n = CT.l10n;

if l10n.Locale ~= nil and l10n.Locale ~= "" then return;end

BINDING_CATEGORY_ALATALENTEMU = "<|cff00ff00TalentEmu|r>";
BINDING_NAME_ALARAIDTOOL_NEWWINDOW = "Create an emulator";
BINDING_NAME_ALARAIDTOOL_QUERY = "Inspect target";

l10n.Locale = "enUS";

l10n.Emu = "Emu";
l10n.OK = "OK";
l10n.Cancel = "Cancel";
l10n.Search = "Search";
l10n.Hide = "Hide";
l10n.CurTreePointsLabel = "Points";
l10n.CurPointsTotal = "Total";
l10n.CurPointsRemaining = "Idle";
l10n.CurPointsUsed = "Used";
l10n.CurPointsReqLevel = "Lv";
l10n.message = "*CHAT";
l10n.import = "IMPORT";
l10n.me = "Me";

l10n.ReadOnly = "|cffff0000ReadOnly|r";
l10n.NonReadOnly = "|cff00ff00Editable|r";
l10n.LabelPointsChanged = "(|cffff0000Modified|r)";
l10n.ResetButton = "Reset this tree";
l10n.ExpanButton = "Expand";
l10n.ResetAllButton = "Reset";
l10n.ResetToSetButton = "Reset";
l10n.ReadOnlyButton = "|cff00ff00Click|r to Set";
l10n.CloseButton = "Close";

l10n.ClassButton = "\n|cff00ff00LeftClick|r Toggle class\n|cff00ff00RightClick|r Load saved talents\n|cff00ff00Shift and LeftClick in Menu|r Delete saved talent";
l10n.InspectTargetButton = "Inspect target";
l10n.SpellListButton = "Spell List";
l10n.SpellAvailable = "|cff00ff00Available|r";
l10n.SpellUnavailable = "|cffff0000Not Available|r";
l10n.TrainCost = "Train Cost ";
l10n.ShowAllSpell = "All ranks";
l10n.ApplyTalentsButton = "Apply talents";
l10n.SettingButton = "Settings";
l10n.ApplyTalentsButton_Notify = "Apply these talents?";
l10n.ApplyTalentsFinished = "Talents applied";
l10n.ImportButton = "Import from code or wowhead/nfu/yxrank url";
l10n.ExportButton = "|cff00ff00LeftClick|r Export code\n|cff00ff00RightClick|r Export to |cffff0000wowhead/nfu|r url";
l10n.AllData = "AllData";
l10n.SaveButton = "|cff00ff00LeftClick|r Save talents\n|cff00ff00RightClick|r Load saved talents\n|cff00ff00ALT+RightClick|r Load another character's talent\n|cff00ff00Shift and LeftClick in Menu|r Del";
l10n.SendButton = "|cff00ff00LeftClick|r Send talents\n|cff00ff00RightClick|r Browse talents in chat";
l10n.EquipmentFrameButton = "Equipment list";

l10n.TalentFrameCallButton = "Open TalentEmu";
l10n.TalentFrameCallButtonString = "Emu";
l10n.CurRank = "Current Rank";
l10n.NextRank = "Next Rank";
l10n.MaxRank = "Top Rank";
l10n.ReqPoints = "%d/%d in %s";

l10n.AutoShowEquipmentFrame_TRUE = "Show Equipments Automatically";
l10n.AutoShowEquipmentFrame_FALSE = "Show Equipments Manually";
l10n.Minimap_TRUE = "Show DBIcon";
l10n.Minimap_FALSE = "Hide DBIcon";
l10n.ResizableBorder_TRUE = "Resizing by Dragging";
l10n.ResizableBorder_FALSE = "Disable Resizing";
l10n.SetSingleFrame_TRUE = "Single Window";
l10n.SetSingleFrame_FALSE = "Multiple Windows";
l10n.SetStyleAllTo1_ThisWin = "Triple talent trees this frame";
l10n.SetStyleAllTo2_ThisWin = "Single talent tree this frame";
l10n.SetStyleAllTo1_LaterWin = "Triple talent trees";
l10n.SetStyleAllTo2_LaterWin = "Single talent tree";
l10n.TalentsInTip_TRUE = "Talents in tip";
l10n.TalentsInTip_FALSE = "No talents in tip";
l10n.TalentsInTipIcon_TRUE = "Texture talents in tip";
l10n.TalentsInTipIcon_FALSE = "Text talents in tip";
l10n.Style = "Style"

-- l10n.DBIcon_Text = "|cff00ff00LeftClick|r Create an emulator\n|cff00ff00RightClick|r Explorer group member";
l10n.TooltipLines = {
	"|cff00ff00LeftClick|r Create an emulator",
	"RightClick|r Explorer group member",
};
l10n.SpellListFrameGTTSpellLevel = "Spell level: ";
l10n.SpellListFrameGTTReqLevel = "Level: ";

l10n.DATA = {
	talent = "talent",

	DEATHKNIGHT = "deathknight",
	DRUID = "druid",
	HUNTER = "hunter",
	MAGE = "mage",
	PALADIN = "paladin",
	PRIEST = "priest",
	ROGUE = "rogue",
	SHAMAN = "shaman",
	WARLOCK = "warlock",
	WARRIOR = "warrior",

	[398] = "Blood",
	[399] = "Frost",
	[400] = "Unholy",
	[283] = "Balance",
	[281] = "Feral",
	[282] = "Restoration",
	[361] = "BeastMastery",
	[363] = "Marksmanship",
	[362] = "Survival",
	[81] = "Arcane",
	[41] = "Fire",
	[61] = "Frost",
	[382] = "Holy",
	[383] = "Protection",
	[381] = "Retribution",
	[201] = "Discipline",
	[202] = "Holy",
	[203] = "Shadow",
	-- [182] = "Assassination",
	-- [181] = "Combat",
	-- [183] = "Subtlety",
	-- [261] = "Elemental",
	-- [263] = "Enhancement",
	-- [262] = "Restoration",
	[302] = "Affliction",
	[303] = "Demonology",
	[301] = "Destruction",
	[161] = "Arms",
	[164] = "Fury",
	[163] = "Protection",

	[398] = "Blood",
	[399] = "Frost",
	[400] = "Unholy",
	[752] = "Balance",
	[750] = "Feral",
	[748] = "Restoration",
	[811] = "BeastMastery",
	[807] = "Marksmanship",
	[809] = "Survival",
	[799] = "Arcane",
	[851] = "Fire",
	[823] = "Frost",
	[831] = "Holy",
	[839] = "Protection",
	[855] = "Retribution",
	[760] = "Discipline",
	[813] = "Holy",
	[795] = "Shadow",
	[182] = "Assassination",
	[181] = "Combat",
	[183] = "Subtlety",
	[261] = "Elemental",
	[263] = "Enhancement",
	[262] = "Restoration",
	[871] = "Affliction",
	[867] = "Demonology",
	[865] = "Destruction",
	[746] = "Arms",
	[815] = "Fury",
	[845] = "Protection",

	H = "|cff00ff00Healer|r",
	D = "|cffff0000DPS|r",
	T = "|cffafafffTANK|r",
	P = "|cffff0000PVP|r",
	E = "|cffffff00PVE|r",

};

l10n.RACE = "RACE";
l10n["HUMAN|DWARF|NIGHTELF|GNOME|DRAENEI"] = "Alliance";
l10n["ORC|SCOURGE|TAUREN|TROLL|BLOODELF"] = "Horde";
l10n["HUMAN"] = "Human";
l10n["DWARF"] = "Dwarf";
l10n["NIGHTELF"] = "NightElf";
l10n["GNOME"] = "Gnome";
l10n["DRAENEI"] = "Draenei";
l10n["ORC"] = "Orc";
l10n["SCOURGE"] = "Scourge";
l10n["TAUREN"] = "Tauren";
l10n["TROLL"] = "Troll";
l10n["BLOODELF"] = "BloodElf";


l10n.RaidToolLableItemLevel = "ItemLv";
l10n.RaidToolLableItemSummary = "Items";
l10n.RaidToolLableEnchantSummary = "Encs";
l10n.RaidToolLableGemSummary = "Gems";
l10n.RaidToolLableBossModInfo = "Version of DBM";
l10n.guildList = "Guild Member";

l10n.SLOT = {
	[0] = "Ammo",
	[1] = "Head",
	[2] = "Neck",
	[3] = "Shoulder",
	[4] = "Skirt",
	[5] = "Chest",
	[6] = "Waist",
	[7] = "Leg",
	[8] = "Feet",
	[9] = "Wrist",
	[10] = "Glove",
	[11] = "Finger",
	[12] = "Finger",
	[13] = "Trinet",
	[14] = "Trinet",
	[15] = "Cloak",
	[16] = "MainHand",
	[17] = "OffHand",
	[18] = "Ranged",
	[19] = "Tabard",
};
l10n.EMTPY_SLOT = "|cffff0000Empty|r";
l10n.MISS_ENCHANT = "|cffff0000Miss enchant|r";

l10n.Gem = {
	Red = "|cffff0000R|r",
	Blue = "|cff007fffB|r",
	Yellow = "|cfffcff00Y|r",
	Purple = "|cffff00ffP|r",
	Green = "|cff00ff00G|r",
	Orange = "|cffff7f00O|r",
	Meta = "|cffffffffM|r",
	Prismatic = "|cffffffffP|r",
};
l10n.MissGem = {
	["?"] = "|cff7f7f7f?|r",
	Red = "|cff7f7f7fR|r",
	Blue = "|cff7f7f7fB|r",
	Yellow = "|cff7f7f7fY|r",
	Purple = "|cff7f7f7fP|r",
	Green = "|cff7f7f7fG|r",
	Orange = "|cff7f7f7fO|r",
	Meta = "|cff7f7f7fM|r",
	Prismatic = "|cff7f7f7fP|r",
};


l10n["CANNOT APPLY : ERROR CATA."] = "CANNOT APPLY : WRONG TALENTS (CATA).";
l10n["CANNOT APPLY : NEED MORE TALENT POINTS."] = "CANNOT APPLY : NEED MORE TALENT POINTS.";
l10n["CANNOT APPLY : TALENTS IN CONFLICT."] = "CANNOT APPLY : TALENTS IN CONFLICT.";
l10n["CANNOT APPLY : UNABLE TO GENERATE TALENT MAP."] = "CANNOT APPLY : UNABLE TO GENERATE TALENT MAP.";
l10n["CANNOT APPLY : TALENT MAP ERROR."] = "CANNOT APPLY : TALENT MAP ERROR.";
l10n["TalentDB Error : DB SIZE IS NOT EQUAL TO TalentFrame SIZE."] = "TalentDB Error : DB SIZE IS NOT EQUAL TO TalentFrame SIZE.";


l10n.PopupQuery = "|cffff7f00Inspect|r";

--	emulib
l10n["WOW VERSION"] = "The talents does not fit che client";
l10n["NO DECODER"] = "Unable to decode talent data";
