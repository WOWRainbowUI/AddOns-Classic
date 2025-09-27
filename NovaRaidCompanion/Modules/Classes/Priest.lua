------------------------------
---NovaRaidCompanion Classes--
------------------------------

local addonName, NRC = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");
if (not NRC.isClassic) then
	return;
end
local _, class = UnitClass("player");
local playerGUID = NRC.playerGUID;
local damage;
local hitsDamage = {};
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo;
local UnitGUID = UnitGUID;
local strfind = strfind;
local GetSpellLink = GetSpellLink or C_Spell.GetSpellLink;
local GetSpellInfo = NRC.GetSpellInfo;
local piFrame = CreateFrame("Frame");

local function tallyDamage(name)
	if (not next(hitsDamage[name])) then
		NRC:debug("Name not found in hitsDamage for PI calc");
		--We may have done this calc already if we're not waiting for aoe dmg.
		--Or pi faded with no dmg.
		hitsDamage[name] = nil;
		if (not next(hitsDamage)) then
			damage = nil;
		end
		return;
	end
	local inInstance = IsInInstance();
	local total = 0;
	local data = hitsDamage[name];
	if (not data.startTime or (GetTime() - data.startTime > 17)) then
		if (not data.startTime) then
			NRC:debug("PI damage startTime missing.", name);
		else
			NRC:debug("PI damage calced outside of 17 seconds since cast.", name);
		end
		return;
	end
	local source = data.source;
	local target = data.target;
	local targetGUID = data.targetGUID;
	local targetMe;
	if (target == UnitName("player")) then
		targetMe = true;
	end
	local sourceMe;
	if (source == UnitName("player")) then
		sourceMe = true;
	end
	--NRC:debug("PI damage calced after", GetTime() - data.startTime, "seconds.", name, source, target, sourceMe, targetMe);
	for k, v in ipairs(data) do
		total = total + v.amount;
	end
	total = total * 0.2;
	total = math.floor(total);
	local countedAoes = {};
	if (not NRC.config.piOnlyWhenDamage or total > 0) then
		local sent, sentMe, sentOtherGroup, printOther;
		--[[if (NRC.config.piSendDamageGroup and sourceMe) then
			--Send my pi damage given to group.
			if (IsInGroup()) then
				local msg = "[NRC] " .. string.format(L["otherDamageMyPI"], name, NRC:commaValue(total));
				NRC:sendGroup(msg, nil, 0.5);
			elseif (not targetMe) then
				local targetString = target;
				if (data.targetClass) then
					local _, _, _, classHex = NRC.getClassColor(data.targetClass);
					targetString = "|c" .. classHex .. target .. "|r";
				end
				C_Timer.After(1, function()
					NRC:print(string.format(L["otherDamageMyPI"], targetString, "|cFF00C800" .. NRC:commaValue(total) .. "|r"));
				end)
			end
			sentMe = true;
		end]]
		if (NRC.config.piSendDamagePrint and sourceMe and not targetMe and not sentMe) then
			--Print my PI given damage gains for all PI's to any other players.
			local targetString = target;
			if (data.targetClass) then
				local _, _, _, classHex = NRC.getClassColor(data.targetClass);
				targetString = "|c" .. classHex .. target .. "|r";
			end
			C_Timer.After(1, function()
				NRC:print(string.format(L["otherDamageMyPI"], targetString, "|cFF00C800" .. NRC:commaValue(total) .. "|r"));
			end)
		end
		--[[if (NRC.config.piSendDamageGroupOther and not sourceMe) then
			if (IsInGroup()) then
				local msg = "[NRC] " .. string.format(L["otherDamageOtherPI"], target, NRC:commaValue(total), source);
				C_Timer.After(0.5, function()
					NRC:sendGroupSettingsCheck(msg, "tricksSendDamageGroupOther", "tricksSendDamageGroup", source);
				end)
			else
				local targetString = target;
				if (data.targetClass) then
					local _, _, _, classHex = NRC.getClassColor(data.targetClass);
					targetString = "|c" .. classHex .. target .. "|r";
				end
				C_Timer.After(1, function()
					NRC:print(string.format(L["otherDamageOtherPI"], targetString, "|cFF00C800" .. NRC:commaValue(total) .. "|r", "|cFFFFFFFF" .. source .. "|r"));
				end)
			end
			sentOtherGroup = true;
		end]]
		if ((NRC.config.piSendDamagePrintToMe or NRC.config.piSendDamagePrintOther) and targetMe) then
			--Print my damage gains for a given PI.
			C_Timer.After(1, function()
				NRC:print(string.format(L["otherTransferedDamagePIMine"], "|cFF00C800" .. NRC:commaValue(total) .. "|r", "|cFFFFFFFF" .. source .. "|r"));
			end)
		elseif (NRC.config.piSendDamagePrintOther and not sourceMe and not sentOtherGroup) then
			--Print damage gains for all PI's to any other players from any priests.
			printOther = true;
			local targetString = target;
			if (data.targetClass) then
				local _, _, _, classHex = NRC.getClassColor(data.targetClass);
				targetString = "|c" .. classHex .. target .. "|r";
			end
			C_Timer.After(1, function()
				NRC:print(string.format(L["otherDamageOtherPI"], targetString, "|cFF00C800" .. NRC:commaValue(total) .. "|r", "|cFFFFFFFF" .. source .. "|r"));
			end)
		end
		--Msg target how much my PI gave them.
		if (NRC.config.piSendDamageWhisper and sourceMe) then
			if (targetGUID and strfind(targetGUID, "Player")) then
				local msg = "[NRC] " .. string.format(L["mePIWhisper"], NRC:commaValue(total));
				SendChatMessage(msg, "WHISPER", nil, target);
			end
		end
		--Msg priest how much dmg they gave me.
		if (NRC.config.piSendDamageWhisperYouGaveMe and targetMe and not sourceMe) then
			if (source) then
				local msg = "[NRC] " .. string.format(L["otherDamagePIMine"], NRC:commaValue(total));
				SendChatMessage(msg, "WHISPER", nil, source);
			end
		end
		--Print how much damage other priests pi gave to me.
		--if (NRC.config.piOtherPriestsMineGained and targetMe and not sentOtherGroup and not printOther) then
		--	NRC:print(string.format(L["otherDamagePIMine"], "|cFF00C800" .. NRC:commaValue(total) .. "|r", "|cFFFFFFFF" .. source .. "|r"));
		--end
	end
	hitsDamage[name] = nil;
	if (not next(hitsDamage)) then
		--No tricks buffs currently up, disable combat log checking.
		damage = nil;
	end
end

local function cancelDamage(name)
	NRC:debug("Cancelled PI ticks damage calc", name);
	hitsDamage[name] = nil;
	if (not next(hitsDamage)) then
		--No tricks buffs currently up, disable combat log checking.
		damage = nil;
	end
end

--Create a tricks table for this player if it doesn't exist, so both needed events can add their data no matter the event fire order.
--Our 2 needed events don't always fire in same order.
local function damageStarted(source, target, targetGUID, inOurGroup)
	if (NRC:isMe(target) or (inOurGroup or NRC:inOurGroup(target))) then
		if (targetGUID) then
			local _, classEnglish  = GetPlayerInfoByGUID(targetGUID);
			hitsDamage[target] = {
				dots = {},
				source = source,
				target = target,
				targetGUID = targetGUID,
				targetClass = classEnglish;
				startTime = GetTime(),
			};
			damage = true;
		end
	end
end

local function combatLogEventUnfiltered(...)
	local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, 
			destName, destFlags, destRaidFlags, spellID, spellName = ...;
	if (damage) then
		if (hitsDamage[sourceName] and strfind(sourceGUID, "Player")) then
			--if (subEvent == "SWING_DAMAGE" or subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE") then
			if (subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE") then
				local spellID, spellName, school, amount, overkill, school, resisted, blocked, absorbed, critical,
							glancing, crushing, isOffHand = select(12, ...);
				local tableID = #hitsDamage[sourceName] + 1;
				if (amount and amount > 0) then
					hitsDamage[sourceName][tableID] = {
						spellID = spellID,
						spellName = spellName,
						amount = amount,
						destName = destName,
					};
					if (critical) then
						hitsDamage[sourceName][tableID].critical = true;
					end
					if (blocked) then
						hitsDamage[sourceName][tableID].blocked = blocked;
					end
					if (absorbed) then
						hitsDamage[sourceName][tableID].absorbed = absorbed;
					end
					if (glancing) then
						hitsDamage[sourceName][tableID].glancing = glancing;
					end
					if (tableID > 500) then
						--Safeguard incase it ever keeps recording because the end of tricks wasn't detected.
						cancelDamage(sourceName);
					end
				end
			end
		end
	end
	if (subEvent == "SPELL_AURA_REMOVED") then
		--If pi was up and has now faded then do the calc.
		--57933 spellID for buff the target gets, here we calc how much dmg we boosted them by.
		if (spellID == 10060) then
			--NRC:debug("Tricks damage calc from target buff removed", destName);
			--If it's wrath then we calc after the 4 second duration is up.
			if (hitsDamage[destName]) then
				tallyDamage(destName);
			end
		end
	elseif (subEvent == "SPELL_AURA_APPLIED") then
		--Start recording damage from pi target.
		if (spellID == 10060) then
			damageStarted(sourceName, destName, destGUID);
			--if (NRC.config.piShowMiddleIcon and destName == UnitName("player")) then
				--Unfinished stuff.
			--	NRC:startMiddleIcon(236283, 1.5, nil, "15% Damage Started");
			--end
			if (hitsDamage[sourceName]) then
				--If tricks buff isn't seen ending within 12 seconds then wipe the data.
				--They must have gone out of range.
				C_Timer.After(16, function()
					if (hitsDamage[sourceName]) then
						NRC:debug("Didn't see PI buff fade", sourceName);
						tallyDamage(sourceName);
					end
				end)
			end
		end
	end
end

piFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
piFrame:SetScript('OnEvent', function(self, event, ...)
	--if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		combatLogEventUnfiltered(CombatLogGetCurrentEventInfo());
	--end
end)