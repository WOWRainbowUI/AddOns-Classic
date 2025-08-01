---------------------------------
---NovaRaidCompanion Encounters--
--------------------------------
--This will be split up into seperate dungeon modules at some point, just playing with stuff here atm.

local addonName, NRC = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");

NRC.lastEncounterStartTime = 0;
NRC.lastEncounterEndTime = 0;
NRC.encounter = {};
local checkWeapons;
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo;
local Unitname = UnitName;
local UnitGUID = UnitGUID;
local GetItemInfo = GetItemInfo or C_Item.GetItemInfo;
local GetItemInfoInstant = GetItemInfoInstant or C_Item.GetItemInfoInstant;
local GetItemGem = GetItemGem or C_Item.GetItemGem;
local GetItemCount = GetItemCount or C_Item.GetItemCount;
local GetSpellLink = GetSpellLink or C_Spell.GetSpellLink;
local GetNumGossipOptions = GetNumGossipOptions or C_GossipInfo.GetNumOptions;
local staticPopupFrame = NRC:createStaticPopupAttachment("NRCStaticPopupFrame", 320, 38, 0, 0);
--staticPopupFrame:SetFrameStrata("DIALOG");
--staticPopupFrame:SetFrameLevel(999);
local GetSpellInfo = NRC.GetSpellInfo;

function NRC:encounterStart(...)
	local encounterID, encounterName, difficultyID, groupSize = ...;
	NRC.encounter.encounterID = encounterID;
	NRC.encounter.encounterName = encounterName;
	NRC.encounter.difficultyID = difficultyID;
	NRC.encounter.groupSize = groupSize;
	NRC.lastEncounterStartTime = GetServerTime();
	--if (encounterID == 733) then
		--Kael'thas weapons check.
		--Changed to check all encounters caus may aswell, and often raids head to to SCC after.
		NRC:checkWeaponsEquipped();
	--end
	if (encounterID == 730) then
		if (not NRC.config.attunementWarnings) then
			return;
		end
		--Alar costume check.
		--NRC:debug("checking bt attune");
		local hasQuest = C_QuestLog.IsOnQuest(10946);
		local isComplete = C_QuestLog.IsQuestFlaggedCompleted(10946);
		if (hasQuest and not NRC:hasBuff("player", 39527) and not isComplete) then
			NRC:sendWarning(L["alarCostumeMissing"]);
		end
	end
end

function NRC:encounterEnd(...)
	NRC.encounter = {};
	local encounterID, encounterName, difficultyID, groupSize, success = ...;
	NRC.lastEncounterEndTime = GetServerTime();
	NRC.lastEncounter = encounterID;
	if (encounterID == 733) then
		checkWeapons = true;
	end
	if (success) then
		NRC:checkAttuneQuest(encounterID);
	end
end

function NRC:checkAttuneQuest(encounterID)
	if (not NRC.config.attunementWarnings) then
		return;
	end
	local delay = 15;
	if (encounterID == 626) then
		--NRC:debug("checking bt attune");
		local delay = 20;
		C_Timer.After(delay, function()
			local hasQuest = C_QuestLog.IsOnQuest(10944);
			local isComplete = C_QuestLog.IsQuestFlaggedCompleted(10708);
			local isComplete2 = C_QuestLog.IsQuestFlaggedCompleted(10944);
			--If we did the prequest and don't have the quest from Seer.
			if (isComplete and (not hasQuest and not isComplete2)) then
				NRC:sendReminder(L["attuneWarningSeerOlum"]);
			end
		end)
	elseif (encounterID == 650) then
		--NRC:debug("checking ssc attune");
		local hasQuest = C_QuestLog.IsOnQuest(10901);
		local isComplete = C_QuestLog.IsQuestFlaggedCompleted(10901);
		if (hasQuest and not isComplete) then
			C_Timer.After(delay, function()
				local itemCount = GetItemCount(31750);
				if (itemCount < 1) then
					NRC:sendReminder(string.format(L["attuneWarning"], L["Earthen Signet"], L["The Cudgel of Kar'desh"]));
				end
			end)
		end
	elseif (encounterID == 662) then
		--NRC:debug("checking ssc attune");
		local hasQuest = C_QuestLog.IsOnQuest(10901);
		local isComplete = C_QuestLog.IsQuestFlaggedCompleted(10901);
		if (hasQuest and not isComplete) then
			C_Timer.After(delay, function()
				local itemCount = GetItemCount(31751);
				if (itemCount < 1) then
					NRC:sendReminder(string.format(L["attuneWarning"], L["Blazing Signet"], L["The Cudgel of Kar'desh"]));
				end
			end)
		end
	elseif (encounterID == 628) then
		--NRC:debug("checking hyjal attune");
		local hasQuest = C_QuestLog.IsOnQuest(10445);
		local isComplete = C_QuestLog.IsQuestFlaggedCompleted(10445);
		if (hasQuest and not isComplete) then
			C_Timer.After(delay, function()
				local itemCount = GetItemCount(29905);
				if (itemCount < 1) then
					NRC:sendReminder(string.format(L["attuneWarning"], L["Vashj's Vial Remnant"], L["The Vials of Eternity"]));
				end
			end)
		end
	elseif (encounterID == 733) then
		--NRC:debug("checking hyjal attune");
		local hasQuest = C_QuestLog.IsOnQuest(10445);
		local isComplete = C_QuestLog.IsQuestFlaggedCompleted(10445);
		if (hasQuest and not isComplete) then
			C_Timer.After(delay, function()
				local itemCount = GetItemCount(29905);
				if (itemCount < 1) then
					NRC:sendReminder(string.format(L["attuneWarning"], L["Kael's Vial Remnant"], L["The Vials of Eternity"]));
				end
			end)
		end
	elseif (encounterID == 618) then
		--NRC:debug("checking bt attune");
		local hasQuest = C_QuestLog.IsOnQuest(10947);
		local isComplete = C_QuestLog.IsQuestFlaggedCompleted(10947);
		if (hasQuest and not isComplete) then
			C_Timer.After(delay, function()
				local itemCount = GetItemCount(32459);
				if (itemCount < 1) then
					NRC:sendReminder(string.format(L["attuneWarning"], L["Time-Phased Phylactery"], L["An Artifact From the Past"]));
				end
			end)
		end
	end
end

local lastShadowNeckWarning = 0;
function NRC:checkShadowNeckBT(delay)
	if (NRC.config.checkShadowNeckBT) then
		local cooldown = 300;
		if (delay) then
			cooldown = delay;
		end
		local neckLink = GetInventoryItemLink("player", GetInventorySlotInfo("NECKSLOT"));
		if (neckLink) then
			local _, itemID = strsplit(":", neckLink);
			if (itemID == "32757" or itemID == "32649" or itemID == "24097") then
				--Skip mother and illidan and teron for neck teleport.
				if (not next(NRC.encounter) or (NRC.encounter.encounterID ~= 607 and NRC.encounter.encounterID ~= 609
						and NRC.encounter.encounterID ~= 604)) then
					--Skip check if teron just ended a few seconds ago.
					if (GetServerTime() - lastShadowNeckWarning > cooldown
							and not (GetServerTime() - NRC.lastEncounterEndTime < 10 and NRC.lastEncounter ~= 604)) then
						NRC:sendReminder(L["shadowNeckBTWarning"]);
						lastShadowNeckWarning = GetServerTime();
					end
				end
			end
		end
	end
end

local lastPvpTrinketWarning = 0;
function NRC:checkPvpTrinket(delay)
	if (NRC.config.checkPvpTrinket) then
		local cooldown = 300;
		if (delay) then
			cooldown = delay;
		end
		--Skip check on twins in Sunwell and Rage Winterchill in Hyjal.
		if (not next(NRC.encounter) or (NRC.encounter.encounterID ~= 727 and NRC.encounter.encounterID ~= 618)) then
			local trinketLink = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET0SLOT"));
			if (trinketLink) then
				local _, itemID, itemName = strsplit(":", trinketLink);
				if (itemID) then
					local itemName = GetItemInfo(itemID);
					--There's too many trinket ids so use name for now, it will work with languages that add to the locale file.
					if (itemName == L["Medallion of the Alliance"] or itemName == L["Insignia of the Alliance"]
							or itemName == L["Medallion of the Horde"] or itemName == L["Insignia of the Horde"] or itemName == L["Blood-Caked Insignia"]) then
						if (GetServerTime() - lastPvpTrinketWarning > cooldown) then
							NRC:sendReminder(L["pvpTrinketWarning"]);
							lastPvpTrinketWarning = GetServerTime();
						end
					end
				end
			end
			local trinketLink = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET1SLOT"));
			if (trinketLink) then
				local _, itemID, itemName = strsplit(":", trinketLink);
				if (itemID) then
					local itemName = GetItemInfo(itemID);
					--There's too many trinket ids so use name for now, it will work with languages that add to the locale file.
					if (itemName == L["Medallion of the Alliance"] or itemName == L["Insignia of the Alliance"]
							or itemName == L["Medallion of the Horde"] or itemName == L["Insignia of the Horde"]) then
						if (GetServerTime() - lastPvpTrinketWarning > cooldown) then
							NRC:sendReminder(L["pvpTrinketWarning"]);
							lastPvpTrinketWarning = GetServerTime();
						end
					end
				end
			end
		end
	end
end

local lastFishingGearWarning = 0;
function NRC:checkFishingGear(delay)
	if (not NRC.fishingGear) then
		return;
	end
	if (NRC.db.global.checkFishingGear) then
		local cooldown = 300;
		if (delay) then
			cooldown = delay;
		end
		local gearLink = GetInventoryItemLink("player", GetInventorySlotInfo("MAINHANDSLOT"));
		if (gearLink) then
			local _, itemID = strsplit(":", gearLink);
			if (itemID) then
				itemID = tonumber(itemID);
				if (NRC.fishingGear[itemID]) then
					if (GetServerTime() - lastFishingGearWarning > cooldown) then
						NRC:sendReminder(string.format(L["fishingGearWarning"], gearLink), true);
						lastFishingGearWarning = GetServerTime();
					end
				end
			end
		end
	end
end

--[[function NRC:playerEnteringWorldEncounters(...)
	local isLogon, isReload = ...;
	--On rare occasions you PLAYER_ENTERING_WORLD as a ghost still instead of unghosting beforehand.
	local isInstance, instanceType = IsInInstance();
	if (isInstance) then
		if (isReload) then
			C_Timer.After(0.2, function()
				NRC:enteredInstance();
			end)
		elseif (isLogon) then
			C_Timer.After(0.2, function()
				NRC:enteredInstance();
			end)
		else
			C_Timer.After(0.2, function()
				if (isInstance) then
					NRC:enteredInstance();
				end
			end)
		end
	elseif (NRC.inInstance and not isReload) then
		NRC:leftInstance();
	end
end

function NRC:enteredInstance()
	NRC.inInstance = true;
	local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty,
			isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo();
	NRC.lastInstanceID = instanceID;
	NRC.lastInstanceName = instanceName;
end

function NRC:leftInstance()
	NRC.inInstance = nil;
end]]

local checkWeaponsCD, lastWeaponWarning = 0, 0;
function NRC:checkWeaponsEquipped()
	if (NRC.isRetail) then
		return;
	end
	if (not NRC.config.ktNoWeaponsWarning or UnitLevel("player") ~= 70) then
		return;
	end
	if (GetServerTime() - checkWeaponsCD < 5) then
		return;
	end
	checkWeapons = nil;
	checkWeaponsCD = GetServerTime();
	local equipped;
	local itemNameMH, itemTypeMH, itemSubTypeMH, itemEquipLocMH, classIDMH, subclassIDMH;
	local itemNameOH, itemTypeOH, itemSubTypeOH, itemEquipLocOH, classIDOH, subclassIDOH;
	local mainhandLink = GetInventoryItemLink("player", GetInventorySlotInfo("MAINHANDSLOT"));
	if (mainhandLink) then
		itemNameMH, _, _, _, _, itemTypeMH, itemSubTypeMH, _, itemEquipLocMH, _, _, classIDMH, subclassIDMH = GetItemInfo(mainhandLink) ;
	end
	local offhandLink = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"));
	if (offhandLink) then
		itemNameOH, _, _, _, _, itemTypeOH, itemSubTypeOH, _, itemEquipLocOH, _, _, classIDOH, subclassIDOH = GetItemInfo(offhandLink) ;
	end
	--Check if a weapon is equipped.
	local twoHanded;
	local msg = L["noWeaponsEquipped"];
	if (NRC.class == "HUNTER") then
		--Only checking ranged slot for hunters, they pick up the bow in KT.
		local rangedLink = GetInventoryItemLink("player", GetInventorySlotInfo("RANGEDSLOT"));
		if (rangedLink) then
			equipped = true;
		else
			msg = L["noRangedEquipped"];
		end
	elseif (classIDMH == 2) then
		--If there's a weapon equipped check if it's 2-handed.
		if (subclassIDMH == 1 or subclassIDMH == 6 or subclassIDMH == 5 or subclassIDMH == 8 or subclassIDMH == 10) then
			--If it's 2-handed then we don't check for offhand.
			equipped = true;
		else
			--Check for offhand.
			if (offhandLink) then
				equipped = true;
			else
				msg = L["noOffhandEquipped"];
			end
		end
	end
	if (not equipped and GetServerTime() - lastWeaponWarning > 300) then
		lastWeaponWarning = GetServerTime();
		NRC:sendRaidNotice(msg, nil, 7);
		NRC:print(msg);
		PlaySound(8959);
	end
end

--spellID -> texture.
--For wrath we'll just merge feasts into the cauldrons display.
local cauldrons = {
	[41498] = 133782,
	[41443] = 133778,
	[41497] = 32851,
	[41494] = 133779,
	[41495] = 32850,
	[92649] = 461808, --Cauldron of Battle
    [92712] = 461809, --Big Cauldron of Battle
    [473466] = 133781, --SoD Firewater Cauldron.
};
local feasts = {
	--Feasts.
	[57301] = 132184,
	[57426] = 237303,
	[87644] = 134040, --Seafood Magnifique Feast
};
local repairBots = {
	--Repair bots.
	[22700] = 132836,
	[44389] = 133859,
	[54711] = 133872,
	[67826] = 294476,
};
local mailboxes = {
	--Mailbox.
	[54710] = 133871,
};

local portals = {
	--Portals.
	[54710] = 133871,
};

if (NRC.isSOD) then
	cauldrons[429961] = 133662; --Sleeping bag.
	repairBots[1213955] = 136172;
end

local trackAnnounce = {};
for k, v in pairs(cauldrons) do
	trackAnnounce[k] = v;
end
for k, v in pairs(feasts) do
	trackAnnounce[k] = v;
end
for k, v in pairs(repairBots) do
	trackAnnounce[k] = v;
end
for k, v in pairs(mailboxes) do
	trackAnnounce[k] = v;
end
for k, v in pairs(portals) do
	trackAnnounce[k] = v;
end
--These are no longer used below.
cauldrons = nil;
mailboxes = nil;

local lastGeyser = 0;
local function combatLogEventUnfiltered(...)
	local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, 
			destName, destFlags, destRaidFlags, spellID, spellName = ...;
	--[[if (spellID == 38971 and NRC.config.acidGeyserWarning) then
		--Acid Geyser used by Underbog Colossus in SCC.
		--Mainly for my own raid, dbm doesn't do this for some reason.
		if (destName == UnitName("player") and GetServerTime() - lastGeyser > 9) then
			SendChatMessage(spellName .. " on " .. UnitName("player") .. "!", "SAY");
			NRC:sendRaidNotice(spellName .. " on me!", nil, 5);
			PlaySound(8959);
			lastGeyser = GetServerTime();
		end
	end]]
	if (subEvent == "SPELL_CAST_SUCCESS") then
		--spellID = 54710
		if (trackAnnounce[spellID]) then
			local inInstance = IsInInstance();
			if (inInstance) then
				--Trim the msg a bit for english clients, no need to show it's a major, all cauldrons are.
				spellName = string.gsub(spellName, "Major ", "");
				if (spellID == 429961) then
					spellName = L["Sleeping Bag"];
				end
				local msg = spellName .. " placed on the ground.";
				if (sourceGUID ~= UnitGUID("player")) then
					msg = spellName .. " placed on the ground by " .. sourceName .. ".";
				end
				if (spellName == "Wormhole") then
					msg = spellName .. " Portal placed on the ground.";
					if (sourceGUID ~= UnitGUID("player")) then
						msg = spellName .. " Portal placed on the ground by " .. sourceName .. ".";
					end
				end
				if (NRC.config.cauldronMsgOther or (sourceGUID == UnitGUID("player") and NRC.config.cauldronMsg)) then
					SendChatMessage(msg, "SAY");
				end
				if (NRC.config.sreShowCauldrons) then
					local msg = "|cFFFFAE42" .. spellName .. " put down.";
					NRC:sreSendEvent(msg, trackAnnounce[spellID], sourceName);
				end
			end
		end
		if (spellID == 61031 and NRC.config.showTrainset) then
			local inInstance = IsInInstance();
			if (inInstance) then
				SendChatMessage(spellName .. " placed on the ground by " .. sourceName .. ".", "SAY");
			else
				NRC:print(spellName .. " placed on the ground by " .. sourceName .. ".");
			end
		end
		if (feasts[spellID]) then
			if (not NRC:inOurGroup(sourceName)) then
				return;
			end
			local mapID = C_Map.GetBestMapForUnit("player");
			if (mapID == 125 or mapID == 126) then
				--Not in dal.
				return;
			end
			if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
				local msg = "{rt1}" .. spellName .. " placed on the ground by " .. sourceName .. ".";
				if (NRC.config.feastLeaderMsg) then
					SendChatMessage(msg, NRC.config.feastLeaderChannel);
				end
			end
		end
		if (repairBots[spellID]) then
			if (not NRC:inOurGroup(sourceName)) then
				return;
			end
			local mapID = C_Map.GetBestMapForUnit("player");
			if (mapID == 125 or mapID == 126) then
				--Not in dal.
				return;
			end
			if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
				local msg = "{rt1}" .. spellName .. " placed on the ground by " .. sourceName .. ".";
				if (NRC.config.repairLeaderMsg) then
					SendChatMessage(msg, NRC.config.repairLeaderChannel);
				end
			end
		end
		if (portals[spellID]) then
			if (not NRC:inOurGroup(sourceName)) then
				return;
			end
			local mapID = C_Map.GetBestMapForUnit("player");
			if (mapID == 125 or mapID == 126) then
				--Not in dal.
				return;
			end
			if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
				local msg = "{rt1}" .. spellName .. " cast by " .. sourceName .. ".";
				if (spellName == "Wormhole") then
					msg = "{rt1}" .. spellName .. " Portal Generator cast by " .. sourceName .. ".";
				end
				if (NRC.config.repairLeaderMsg) then
					SendChatMessage(msg, NRC.config.repairLeaderChannel);
				end
			end
		end
	elseif (subEvent == "SPELL_CREATE") then
		if (spellID == 23598 and sourceGUID == UnitGUID("player")) then
			if (NRC.config.summonStoneMsg) then
				--This only checks if the weakaura exists, can't check if it's actually loaded so we can't do anything for now.
				--if (WeakAuras and WeakAuras.GetData("Nova Summon Announcer (Summoning stones and warlock)")) then
					--return;
				--end
				local arg = GetSubZoneText();
				if (not arg or arg == "") then
					arg = GetZoneText();
				end
				local msg;
				if (arg) then
					msg = L["Summoning"] .. " {rt1}" .. UnitName("target") .. "{rt1} to " .. arg .. ", " .. L["click!"];
				else
					msg = L["Summoning"] .. " {rt1}" .. UnitName("target") .. "{rt1}, " .. L["click!"];
			    end
			    NRC:sendGroup(msg);
			end
		end
	elseif (subEvent == "SPELL_DISPEL") then
		if (destGUID == sourceGUID) then
			return;
		end
		local dispelledSpellID, dispelledSpellName, auraType = select(15, ...), select(16, ...), select(18, ...);
		if (auraType ~= "BUFF") then
			return;
		end
		if (C_Map.GetBestMapForUnit("player") == 125) then
			--Duelers dispel spam while in dal.
			return;
		end
		if (NRC.config.dispelsTranqOnly and spellID ~= 19801 and spellID ~= 1218134) then
			return;
		end
		if (NRC.config.sreShowDispels and sourceGUID and string.find(sourceGUID, "Player")) then
			local _, sourceClass = GetPlayerInfoByGUID(sourceGUID);
			local isSourceNpc, isDestNpc;
			if (sourceGUID and strfind(sourceGUID, "Creature")) then
				isSourceNpc = true;
			end
			if (destGUID and strfind(destGUID, "Creature")) then
				isDestNpc = true;
			end
			local destClass;
			if (destGUID and strfind(destGUID, "Player")) then
				_, destClass = GetPlayerInfoByGUID(destGUID);
			end
			local destSpellID, destSpellName = select(15, ...);
			local _, _, icon = GetSpellInfo(spellID);
			local _, _, destIcon = GetSpellInfo(destSpellID);
			NRC:sreDispelEvent(spellID, spellName, destSpellName, icon, destIcon, sourceName, sourceClass, destName, destClass, isSourceNpc, isDestNpc);
		end
		local inOurGroup = NRC:inOurGroup(sourceName);
		if (destGUID and sourceGUID == UnitGUID("player") or inOurGroup) then
			local inInstance, instanceType = IsInInstance();
			local spellName = GetSpellInfo(spellID);
			local isPlayer = strfind(destGUID, "Player");
			local isCreature = strfind(destGUID, "Creature");
			local isPvp = (instanceType == "pvp");
			
			local allow;
			if (isCreature and NRC.config.dispelsCreatures) then
				allow = true;
			end
			if (isPlayer) then
				if (NRC.config.dispelsFriendlyPlayers and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == COMBATLOG_OBJECT_REACTION_FRIENDLY) then
					allow = true;
				end
				if (NRC.config.dispelsEnemyPlayers and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
					allow = true;
				end
			end
			if (not allow) then
				return;
			end
			if (not spellName or spellName == "") then
				spellName = "Unknown";
			end
			local dispelledSpellLink;
			if (not NRC.isClassic) then
				dispelledSpellLink = GetSpellLink(dispelledSpellID);
			end
			local source = sourceName;
			local dest = destName;
			local you;
			if (sourceGUID == UnitGUID("player")) then
				you = "You";
			end
			local _, sourceClass = GetPlayerInfoByGUID(sourceGUID);
			if (sourceClass) then
				local _, _, _, classHex = NRC.getClassColor(sourceClass);
				source = "|c" .. classHex .. source .. "|r";
			end
			if (strfind(destGUID, "Player")) then
				local _, destClass = GetPlayerInfoByGUID(destGUID);
				if (destClass) then
					local _, _, _, classHex = NRC.getClassColor(destClass);
					dest = "|c" .. classHex .. dest .. "|r";
				end
			end
			local msg = source .. " " .. string.format(L["dispelledCast"], dispelledSpellLink or dispelledSpellName, dest) .. ".";
			local printMsg = (you or source) .. " " .. string.format(L["dispelledCast"], dispelledSpellLink or dispelledSpellName, dest) .. ".";
			--If group enabled send to group.
			--If print enabled then print, but only if we didn't send to group.
			--If say enabled then send either way if inside an instance, or print if outside.
			---The print settings interfere with NWB, so disabled for now until I add a settings global for dispels there.
			local printed;
			if (sourceGUID == UnitGUID("player")) then
				if ((inInstance and not isPvp and NRC.config.dispelsMyCastRaid)
						or (not inInstance and NRC.config.dispelsMyCastWorld)
						or (isPvp and NRC.config.dispelsMyCastPvp)) then
					--[[if (not inInstance and not isPvp and NRC.config.dispelsMyCastRaid) then
						return;
					end
					if (isPvp and not NRC.config.dispelsMyCastPvp) then
						return;
					end]]
					if (IsInGroup() and not isPvp) then
						if (NRC.config.dispelsMyCastGroup and not isPvp) then
							--Never send to group inside bgs.
							NRC:sendGroup(NRC:stripColors(msg));
						end
					end
					if (NRC.config.dispelsMyCastPrint) then
						printed = true;
						NRC:print(printMsg);
					end
					if (inInstance and not isPvp) then
						if (NRC.config.dispelsMyCastSay) then
							printed = true;
							SendChatMessage(NRC:stripColors(msg), "SAY");
						end
					end
					if (not printed and NRC.config.dispelsMyCastSay) then
						NRC:print(printMsg);
					end
				end
			elseif (inOurGroup) then
				if ((inInstance and not isPvp and NRC.config.dispelsOtherCastRaid)
						or (not inInstance and NRC.config.dispelsOtherCastWorld)
						or (isPvp and NRC.config.dispelsOtherCastPvp)) then
					--Disabled group chat for other peoples dispels, the msgs would probably be a bit obnoxious.
					--[[if (IsInGroup()) then
						if (NRC.config.dispelsOtherCastGroup and not isPvp) then
							--Never send to group inside bgs.
							NRC:sendGroup(NRC:stripColors(msg));
						end
					end]]
					if (NRC.config.dispelsOtherCastPrint) then
						printed = true;
						NRC:print(printMsg);
					end
					--[[if (inInstance) then
						if (NRC.config.dispelsOtherCastSay) then
							if (not isPvp) then
								SendChatMessage(NRC:stripColors(msg), "SAY");
								printed = true;
							end
						end
					end]]
					if (not printed and NRC.config.dispelsOtherCastPrint) then
						NRC:print(printMsg);
					end
				end
			end
		end
	end
end

local NRCTargetSpawnTime;
function NRC:loadTargetSpawnTimeFrames()
	NRCTargetSpawnTime = NRC:createTextDisplayFrame("NRCTargetSpawnTime", 100, 20, 0, 100, "Target Spawn Time");
	--Hide frame at load.
	NRCTargetSpawnTime:SetBackdropColor(0, 0, 0, 0);
	NRCTargetSpawnTime:SetBackdropBorderColor(1, 1, 1, 0);
	--NRCTargetSpawnTime.onUpdateFunction = "updateTargetSpawnTime";
	local point, _, relativePoint, x, y = NRCTargetSpawnTime:GetPoint();
	if (point == "CENTER" and x == NRCTargetSpawnTime.defaultX and y == NRCTargetSpawnTime.defaultY) then
		NRCTargetSpawnTime.firstRun = true;
		NRCTargetSpawnTime.fs:SetText(L["Hold Shift To Drag"]);
		NRCTargetSpawnTime.updateTooltip("|cFFFFFF00Target Spawn Time Frame");
		--Show frame so it can be dragged if fresh install.
		NRCTargetSpawnTime:SetBackdropColor(0, 0, 0, 0.5);
		NRCTargetSpawnTime:SetBackdropBorderColor(1, 1, 1, 0.2);
	end
	NRC:refreshTargetSpawnTimeFrame();
end

function NRC:refreshTargetSpawnTimeFrame()
	if (NRC.config.showMobSpawnedTime) then
		NRCTargetSpawnTime:Show();
	else
		NRCTargetSpawnTime:Hide();
	end
end

function NRC:updateTargetSpawnTime()
	if ((not UnitExists("target") and NRCTargetSpawnTime.firstRun) or NRCTargetSpawnTime.hasBeenReset) then
		NRCTargetSpawnTime.fs:SetText(L["Hold Shift To Drag"]);
		NRCTargetSpawnTime.updateTooltip("|cFFFFFF00" .. L["Target Spawn Time Frame"]);
		NRCTargetSpawnTime:SetBackdropColor(0, 0, 0, 0.5);
		NRCTargetSpawnTime:SetBackdropBorderColor(1, 1, 1, 0.2);
		NRCTargetSpawnTime.hasData = nil;
		return;
	elseif (not UnitExists("target")) then
		NRCTargetSpawnTime.fs:SetText("");
		NRCTargetSpawnTime.updateTooltip("");
		NRCTargetSpawnTime.tooltip:Hide();
		NRCTargetSpawnTime.hasData = nil;
		return;
	end
	--Spawn time by GUID was worked out by some big brains on the wow addons discord.
	local guid = UnitGUID("target");
	local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid);
	if (unitType == "Creature" or unitType == "Vehicle") then
		local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23);
		local spawnEpochOffset = bit.band(tonumber(strsub(spawnUID, 5), 16), 0x7fffff);
		local spawnIndex = bit.rshift(bit.band(tonumber(strsub(spawnUID, 1, 5), 16), 0xffff8), 3);
		local spawnTime = spawnEpoch + spawnEpochOffset;
		if (spawnTime > GetServerTime()) then
			-- This only occurs if the epoch has rolled over since a unit has spawned.
			spawnTime = spawnTime - ((2^23) - 1);
		end
		local timeAgo = NRC:getTimeString(GetServerTime() - spawnTime, true, "short");
		if (NRCTargetSpawnTime) then
			NRCTargetSpawnTime.fs:SetText(L["Spawned"] .. " " .. timeAgo);
			local name = UnitName("target");
			local msg = "|cFFFFFF00" .. name .. "|r\n" .. L["Spawned"] .. " " .. L["at"] .. ": " .. date("%Y-%m-%d %H:%M:%S", spawnTime);
			NRCTargetSpawnTime.updateTooltip(msg);
			NRCTargetSpawnTime.hasData = true;
		else
			NRCTargetSpawnTime.fs:SetText("");
			NRCTargetSpawnTime.tooltip.fs:SetText("");
		end
	else
		NRCTargetSpawnTime.fs:SetText("");
		NRCTargetSpawnTime.tooltip.fs:SetText("");
	end
end

local function GameTooltipSetItem(tooltip, ...)
	local _, itemLink = GameTooltip:GetItem();
	if (itemLink) then
		local _, itemID = strsplit(":", itemLink);
		if (itemID == "33102") then
			--ZA last boss quest item check.
			local completed = C_QuestLog.IsQuestFlaggedCompleted(11178);
			if (completed) then
				tooltip:AddLine("|cFFFF6900[NRC] " .. L["Completed quest"] .. ".");
			else
				tooltip:AddLine("|cFFFF6900[NRC] " .. L["Not completed quest"] .. ".");
			end
			--Refresh size etc.
			tooltip:Show();
		end
	end
end

if (not NRC.isRetail) then
	GameTooltip:GetItem()
	GameTooltip:HookScript("OnTooltipSetItem", GameTooltipSetItem);
end

function NRC:startCombatLogging(isRaid)
	local instance, instanceType = IsInInstance();
	if (instance and (instanceType == "raid" or isRaid)) then
		if (not LoggingCombat()) then
			LoggingCombat(true);
			print("|cFFFFFF00" .. COMBATLOGENABLED);
		end
	end
end

local lastGossipMsg = 0;
local function gossipShow()
	local npcGUID = UnitGUID("npc");
	local npcID;
	if (npcGUID) then
		_, _, _, _, _, npcID = strsplit("-", npcGUID);
	end
	if (not npcID) then
		return;
	end
	if (npcID == "25632" and NRC.config.autoSunwellPortal) then
		if (GetNumGossipOptions() > 1) then
			for i = 1, GetNumGossipOptions() do
				--Select last option
				if (i == GetNumGossipOptions()) then
					NRC:selectGossipOption(i);
					if (GetTime() - lastGossipMsg > 1) then
						lastGossipMsg = GetTime();
						NRC:print(L["Taking Sunwell teleport."]);
					end
				end
			end
		end
	end
end

local f = CreateFrame("Frame", "NRCEncounters");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("PLAYER_TARGET_CHANGED");
f:RegisterEvent("PLAYER_REGEN_DISABLED");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("GOSSIP_SHOW");
f:RegisterEvent("UNIT_INVENTORY_CHANGED");
f:SetScript('OnEvent', function(self, event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		combatLogEventUnfiltered(CombatLogGetCurrentEventInfo());
	elseif (event == "PLAYER_ENTERING_WORLD") then
		local isLogon, isReload = ...;
		--NRC:playerEnteringWorldEncounters(...);
		NRC:updateTargetSpawnTime();
		if (NRC.lastRaidGroupInstanceID == 550) then
			checkWeapons = true;
		end
		if (isLogon or isReload) then
			C_Timer.After(30, function()
				NRC:checkMetaGem();
			end)
		else
			local inInstance, instanceType = IsInInstance();
			if (inInstance) then
				C_Timer.After(3, function()
					NRC:checkFishingGear();
				end)
			end
			C_Timer.After(5, function()
				NRC:checkMetaGem();
			end)
		end
	elseif (event == "ENCOUNTER_START") then
		NRC:encounterStart(...);
	elseif (event == "ENCOUNTER_END") then
		NRC:encounterEnd(...);
	elseif (event == "PLAYER_TARGET_CHANGED") then
		NRC:updateTargetSpawnTime();
	elseif (event == "PLAYER_REGEN_DISABLED") then
		NRC:updateTargetSpawnTime();
		if (checkWeapons or (NRC.raid and NRC.raid.instanceID == 550)) then
			--Check when any combat starts inside The Eye.
			NRC:checkWeaponsEquipped();
		end
		if (NRC.raid) then
			if (NRC.raid.instanceID == 580 or NRC.raid.instanceID == 564 or NRC.raid.instanceID == 534) then
				local long;
				if (NRC.raid.instanceID == 534) then
					long = true;
				end
				C_Timer.After(2, function()
					NRC:checkShadowNeckBT(300);
				end)
			--elseif (NRC.raid.instanceID == 580 or NRC.raid.instanceID == 564 or NRC.raid.instanceID == 534) then
				C_Timer.After(3, function()
					NRC:checkPvpTrinket(300);
				end)
			end
			C_Timer.After(3, function()
				NRC:checkFishingGear(300);
			end)
		end
	elseif (event == "GOSSIP_SHOW") then
		gossipShow(...);
	elseif (event == "UNIT_INVENTORY_CHANGED") then
		local unit = ...;
		if (unit == "player") then
			NRC:throddleEventByFunc("UNIT_INVENTORY_CHANGED", 5, "checkMetaGem");
		end
	end
end)

local middleIcon;
function NRC:startMiddleIcon(icon, shownTime, text, bottomText) --/run NRC:startMiddleIcon(136122, 5, nil, "|cFFFF6900Down|r")
	if (not shownTime) then
		shownTime = 2;
	end
	if (not middleIcon) then
		middleIcon = NRC:createIconFrame("NRCMiddleIconFrame", 60, 60, 0, 100);
	end
	if (text) then
		middleIcon.fs:SetText(text);
	else
		middleIcon.fs:SetText("");
	end
	if (bottomText) then
		middleIcon.fsBottom:SetText(bottomText);
	else
		middleIcon.fsBottom:SetText("");
	end
	middleIcon.texture:SetTexture(icon);
	middleIcon:Show();
	C_Timer.After(shownTime, function()
		--This needs to handle restarts later.
		middleIcon:Hide()
	end)
end

local isShown;
if (NRC.isWrath or NRC.isCata) then
	hooksecurefunc("StaticPopup_Show", function(...)
		for i = 1, STATICPOPUP_NUMDIALOGS do
			local frame = _G["StaticPopup" .. i];
			if (frame.which == "DEATH" and frame:IsShown()) then
				C_Timer.After(0.1, function()
					if (NRC.config.releaseWarning and NRC.raid and next(NRC.encounter)) then
						--Some other addons or weakauras may hide the button, if it's hidden then we don't need this feature.
						isShown = frame.button1:IsShown();
						if (isShown) then
							staticPopupFrame:ClearAllPoints();
							staticPopupFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 8, 20);
							staticPopupFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -8, 20);
							staticPopupFrame:Show();
							if (next(NRC.encounter)) then
								staticPopupFrame.fs2:SetText("|cFFFF0A0AEncounter in progress don't release.");
								staticPopupFrame.fs:SetText("");
							else
								staticPopupFrame.fs2:SetText("|cFF00C800Encounter has ended.");
								staticPopupFrame.fs:SetText("|cFFFF6900NRC|r");
							end
						end
					end
				end)
			end
		end
	end)
	
	hooksecurefunc("StaticPopup_Hide", function(...)
		local shown;
		for i = 1, STATICPOPUP_NUMDIALOGS do
			local frame = _G["StaticPopup" .. i];
			if (frame.which == "DEATH" and frame:IsShown()) then
				shown = true;
			end
		end
		if (not shown) then
			staticPopupFrame:Hide();
			staticPopupFrame:ClearAllPoints();
			staticPopupFrame.fs:SetText("");
			staticPopupFrame.fs2:SetText("");
		end
	end)
	
	--Add a timer to the ressurectiom popup.
	hooksecurefunc("StaticPopup_OnUpdate", function(self, event)
	    if (self.which == "RESURRECT_NO_SICKNESS") then
			local timeLeft = self.timeleft;
			if (timeLeft > 0) then
				local t = self.text:GetText();
				if (strmatch(t, " %(%d+%)$")) then
					--If not first update and our string is already attached then we need to remove old timer and attach new.
					t = gsub(t, " %(%d+%)$", "");
				end
				self.text:SetText(t .. " (" .. ceil(timeLeft) .. ")");
			end
		elseif (self.which == "DEATH") then
			if (NRC.config.releaseWarning and NRC.raid and isShown) then
				if (isShown) then
					if (next(NRC.encounter)) then
						if (IsShiftKeyDown()) then
							self.button1:Enable();
							staticPopupFrame.fs2:SetText("|cFFFF0A0AEncounter in progress |cFF00C800(Shift held down)|r.");
						else
							self.button1:Disable();
							staticPopupFrame.fs2:SetText("|cFFFF0A0AEncounter in progress (Hold shift to release).");
							if (not _G[self:GetName() .. "Text"]:GetText() or _G[self:GetName() .. "Text"]:GetText() == "") then
								--If for some reason this fires outside an instance the text will be blank.
								--Something on Blizzards end wipes the text if the button is disabled, doesn't happen inside raids when there's no timer.
								_G[self:GetName() .. "Text"]:SetText(DEATH_RELEASE_NOTIMER);
							end
						end
						staticPopupFrame.fs:SetText("");
					else
						staticPopupFrame.fs2:SetText("|cFF00C800Encounter has ended.");
						staticPopupFrame.fs:SetText("|cFFFF6900NRC|r");
						self.button1:Enable();
					end
				end
			end
		end
	end)
end

function NRC:getMetaGem()
	local metaGemName, metaGemLink, metaGemTexture, metaGemActive;
	--Maybe enable this later, it makes so if no meta text match found it will always be active.
	--But it also makes it harder to know if the check ever stops working, no bug reports.
	--metaGemActive = true;
	local headSlot = GetInventorySlotInfo("HEADSLOT");
	local headItem = GetInventoryItemLink("player", headSlot);
	--Some non-english clients don't always have the meta gem in first slot.
	--TW client has it in first or second slot on different items it can be either, really strange.
	--So we need to try find which is the meta.
	local hasGem, foundGemText;
	if (headItem) then
		for slot = 1, 3 do
			local gemName, gemLink = GetItemGem(headItem, slot);
			if (gemLink) then
				--Get the item subClass.
				local itemID, itemType, itemSubType, itemEquipLoc, texture, classID, subclassID = GetItemInfoInstant(gemLink);
				if (itemSubType == META_GEM) then
					hasGem = true;
					local tooltipScanner = NRC:getTooltipScanner();
					tooltipScanner:SetHyperlink(gemLink);
					local gemEffect;
					for line = 2, 5 do
						local lineText = _G[tooltipScanner:GetName() .. "TextLeft".. line] and _G[tooltipScanner:GetName() .. "TextLeft".. line]:GetText();
						if (lineText and lineText ~= ITEM_BIND_ON_PICKUP and lineText ~= ITEM_UNIQUE_EQUIPPABLE
								 and lineText ~= ITEM_QUALITY2_DESC and lineText ~= ITEM_QUALITY3_DESC and lineText ~= ITEM_QUALITY4_DESC
								 and not strfind(lineText, string.gsub(ITEM_RACES_ALLOWED, "%%s", ""))
								 and (not SOCKETING_ITEM_MIN_LEVEL_I or not strfind(lineText, string.gsub(SOCKETING_ITEM_MIN_LEVEL_I, "%%s", "")))) then
							gemEffect = lineText;
							break;
						end
					end
					local hasItem, hasCD, repair = tooltipScanner:SetInventoryItem("player", headSlot);
					local text;
					if (hasItem and gemEffect) then
						for line = 2, 20 do
							text = _G[tooltipScanner:GetName() .. "TextLeft".. line] and _G[tooltipScanner:GetName() .. "TextLeft".. line]:GetText();
							if (not text) then
								--Very rare no text but it does happen, just act like it was active.
								return "", "", 0, true
							end --ITEM_REQ_SKILL = Requires %s (hopefully works in all languages?).
							--Spoiler alert, it didn't work for all languages. --Benötigt %1$s
							--Easier just to match the first word "Requires" than deal with the different captures in other languages I think.
							--And oh boy we can't even match the first word becaus lua won't match accented letters as a word, so match to first space instead.
							--I suck at string matching and languages are hard ok.
							local firstWord = strmatch(ITEM_REQ_SKILL, "^(.+) ");
							--if (strfind(text, gemEffect, 1, true) and strfind(text, string.gsub(ITEM_REQ_SKILL, "%%s", "(.+)"))) then
							if (strfind(text, gemEffect, 1, true) and strfind(text, firstWord)) then
								foundGemText = true;
								metaGemActive = not strmatch(text, "cff808080") or false;
								break;
							end
						end
					end
					--if (not metaGemActive) then
					--	print(1, gemEffect)
					--	print(2, text)
					--end
					metaGemName, metaGemLink, metaGemTexture = gemName, gemLink, texture;
					tooltipScanner:Hide();
				end
			end
		end
	end
	if (RatingBusterWOTLK_DB) then
		--Seems to be an issue with the curse version of this addon by another author and it breaking the meta gem line.
		metaGemActive = true;
	end
	if (not foundGemText) then
		--If we can't find the gem text then don't warn user.
		metaGemActive = true;
		if (hasGem) then
			NRC:debug("Meta gem text not found in head slot tooltip.");
		end
	end
	return metaGemName, metaGemLink, metaGemTexture, metaGemActive;
end

local lastMetaWarning, lastMetaStatus = 0;
function NRC:checkMetaGem()
	if (NRC.expansionNum < 2 or NRC.expansionNum > 4) then
		--No meta gem in classic and no activation req in MoP.
		return;
	end
	if (not NRC.config.checkMetaGem or (GetServerTime() - NRC.loadTime) < 120) then
		return;
	end
	local metaGemName, metaGemLink, metaGemTexture, metaGemActive = NRC:getMetaGem();
	local newStatus = metaGemActive ~= lastMetaStatus
	lastMetaStatus = metaGemActive
	if (metaGemLink and not metaGemActive) then
		if ((GetServerTime() - lastMetaWarning > 1800) or newStatus) then
			local texture = "|T" .. metaGemTexture .. ":12:12:0:0|t";
			NRC:print("Warning: Meta gem is inactive: " .. texture .. " " .. metaGemLink);
			lastMetaWarning = GetServerTime();
		end
 	end
end


--Some debug stuff just early testing possible future features.
--[[local inCombat = {};
local f = CreateFrame("Frame");
--f:RegisterEvent("PLAYER_REGEN_DISABLED");
--f:RegisterEvent("ENCOUNTER_START");
--f:RegisterEvent("ENCOUNTER_END");
--f:RegisterEvent("UNIT_FLAGS");
f:SetScript('OnEvent', function(self, event, ...)
	if (not NRC.isDebug) then
		return;
	end
	if (event == "ENCOUNTER_START" or event == "PLAYER_REGEN_DISABLED") then
		if (event == "ENCOUNTER_START") then
			print("Encounter start:", ..., GetTime());
		end
		local unitType = "party";
		if (IsInRaid()) then
			unitType = "raid";
		end
		local count = 0;
		for i = 1, GetNumGroupMembers() do
			local unit = unitType .. i;
			local inCombat = UnitAffectingCombat(unit);
			if (inCombat) then
				local name = UnitName(unit);
				print("In combat:", name);
			end
			count = count + 1;
			if (count == 5) then
				return;
			end
		end
		local inCombat = UnitAffectingCombat("player");
		if (inCombat) then
			local name = UnitName("player");
			print("In combat:", name, GetTime());
		end
		--Or check for first unit flag change after encounter start?
	--elseif (event == "ENCOUNTER_END") then

	elseif (event == "UNIT_FLAGS") then
		local inInstance, instanceType = IsInInstance();
		if (instanceType == "pvp" or not inInstance) then
			return;
		end
		local unit = ...;
		local name = UnitName(unit);
		if (UnitAffectingCombat(unit) and not inCombat[name]) then
			inCombat[name] = true;
			print("[Combat]", name, GetTime())
		elseif (inCombat[name] and not UnitAffectingCombat(unit)) then
			inCombat[name] = nil;
			print("[Combat Ended]", name)
		end
	end
end)]]