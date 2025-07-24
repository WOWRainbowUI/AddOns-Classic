----------------------------------------------
---NovaRaidCompanion data and communications--
----------------------------------------------
--Much of this is taken from my other addon NovaWorldBuffs so some things may look out of place.

local addonName, NRC = ...;
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata;
local version = GetAddOnMetadata("NovaRaidCompanion", "Version") or 9999;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");
local time, elapsed = 0, 0;
local soulstoneDuration = 1800;
if (not NRC.isTBc and not NRC.isClassic) then
	soulstoneDuration = 900;
end

function NRC:OnCommReceived(commPrefix, string, distribution, sender)
	if (commPrefix == NRC.helperCommPrefix) then
		NRC:OnHelperCommReceived(commPrefix, string, distribution, sender);
		return;
	end
	if (distribution == "WHISPER") then
		NRC:OnWhisperCommReceived(commPrefix, string, distribution, sender);
		return;
	end
	--if (NRC.isDebug) then
	--	return;
	--end
	if ((UnitInBattleground("player") or NRC:isInArena()) and distribution ~= "GUILD") then
		return;
	end
	if (distribution ~= "RAID" and distribution ~= "PARTY") then
		return;
	end
	--AceComm doesn't supply realm name if it's on the same realm as player.
	--Not sure if it provives GetRealmName() or GetNormalizedRealmName() for crossrealm.
	--For now we'll check all 3 name types just to be sure until tested.
	local me = UnitName("player") .. "-" .. GetRealmName();
	local meNormalized = UnitName("player") .. "-" .. GetNormalizedRealmName();
	if (sender == UnitName("player") or sender == me or sender == meNormalized) then
		NRC.hasAddon[meNormalized] = tostring(version);
		return;
	end
	local _, realm = strsplit("-", sender, 2);
	--If no realm in name it must be our realm so add it.
	if (not strfind(sender, "-")) then
		--Add normalized realm since roster checks use this.
		sender = sender .. "-" .. GetNormalizedRealmName();
	end
	local decoded;
	if (distribution == "YELL" or distribution == "SAY") then
		decoded = NRC.libDeflate:DecodeForWoWChatChannel(string);
	else
		decoded = NRC.libDeflate:DecodeForWoWAddonChannel(string);
	end
	if (not decoded) then
		NRC:debug("decompress error");
		return;
	end
	local decompressed = NRC.libDeflate:DecompressDeflate(decoded);
	local deserializeResult, deserialized = NRC.serializer:Deserialize(decompressed);
	if (not deserializeResult) then
		NRC:debug("deserialize error");
		return;
	end
	local args = NRC:explode(" ", deserialized, 2);
	local cmd = args[1]; --Cmd (first arg) so we know where to send the data.
	local remoteVersion = args[2]; --Version number.
	local data = args[3]; --Data.
	NRC.hasAddon[sender] = (remoteVersion or "0");
	if (tonumber(remoteVersion) < 1.00) then
		return;
	end
	if (cmd == "d") then
		--Data.
		NRC:receivedData(data, sender, distribution);
	elseif (cmd == "rq") then
		--Request data ("rd" is taken by raid data and the helper weakaura so we use "rq" here).
		NRC:receivedData(data, sender, distribution);
		--Send data back, throddled to once per 10 seconds for when goups are formed and multiple people join.
		--Data is small right now, just a couple of settings and our own raid cooldowns if we have any.
		NRC:sendData();
	elseif (cmd == "s") then
		--Settings.
		NRC:receivedSettings(data, sender, distribution);
	elseif (cmd == "rs") then
		--Request settings.
		NRC:receivedSettings(data, sender, distribution);
		NRC:sendSettings();
	elseif (cmd == "g") then
		--When someone joins our group with this addon.
		NRC:receivedData(data, sender, distribution);
		--Send settings back, throddled to once per 10 seconds for when goups are formed and multiple people join.
		NRC:throddleEventByFunc("s", 10, "sendSettings");
	elseif (cmd == "spell") then
		NRC:receivedString(cmd, data, sender, distribution);
	elseif (cmd == "res") then
		--Resiststances.
		NRC:receivedRes(data, sender, distribution);
	elseif (cmd == "ench") then
		--Enchants.
		NRC:receivedEnchants(data, sender, distribution);
	elseif (cmd == "tal") then
		--Talents.
		NRC:receivedTalents(data, sender, distribution);
	elseif (cmd == "gly") then
		--Glyphs.
		NRC:receivedGlyphs(data, sender, distribution);
	elseif (cmd == "rd") then
		--Raid data, dura enchants resistances.
		NRC:receivedRaidData(data, sender, distribution);
	elseif (cmd == "eq") then
		--Equipment.
		NRC:receivedEquip(data, sender, distribution);
	elseif (cmd == "requestRaidData") then
		--If raid status is opened by someone, throddled.
		NRC:sendRaidData();
	end
	NRC:versionCheck(remoteVersion, distribution, sender);
end

function NRC:OnWhisperCommReceived(commPrefix, string, distribution, sender)
	local me = UnitName("player") .. "-" .. GetRealmName();
	local meNormalized = UnitName("player") .. "-" .. GetNormalizedRealmName();
	if (sender == UnitName("player") or sender == me or sender == meNormalized) then
		NRC.hasAddon[meNormalized] = tostring(version);
		return;
	end
	local _, realm = strsplit("-", sender, 2);
	--If no realm in name it must be our realm so add it.
	if (not strfind(sender, "-")) then
		--Add normalized realm since roster checks use this.
		sender = sender .. "-" .. GetNormalizedRealmName();
	end
	local decoded = NRC.libDeflate:DecodeForWoWAddonChannel(string);
	if (not decoded) then
		NRC:debug("decode error");
		return;
	end
	local decompressed = NRC.libDeflate:DecompressDeflate(decoded);
	if (not decompressed) then
		NRC:debug("decompress error");
		return;
	end
	local deserializeResult, deserialized = NRC.serializer:Deserialize(decompressed);
	if (not deserializeResult) then
		NRC:debug("deserialize error");
		return;
	end
	local args = NRC:explode(" ", deserialized, 2);
	local cmd = args[1]; --Cmd (first arg) so we know where to send the data.
	local remoteVersion = args[2]; --Version number.
	local data = args[3]; --Data.
	if (tonumber(remoteVersion) < 1.22) then
		return;
	end
	if (NRC.expansionNum > 2) then
		if (cmd == "glyrec") then
			NRC:receivedGlyphs(data, sender, distribution, true);
		elseif (cmd == "glyreq") then
			NRC:sendGlyphs(sender)
		end
	end
end

function NRC:OnHelperCommReceived(commPrefix, string, distribution, sender)
	if ((UnitInBattleground("player") or NRC:isInArena()) and distribution ~= "GUILD") then
		return;
	end
	if (distribution ~= "RAID" and distribution ~= "PARTY") then
		return;
	end
	local me = UnitName("player") .. "-" .. GetRealmName();
	local meNormalized = UnitName("player") .. "-" .. GetNormalizedRealmName();
	if (sender == UnitName("player") or sender == me or sender == meNormalized) then
		NRC.hasAddonHelper[meNormalized] = tostring(version);
		return;
	end
	local _, realm = strsplit("-", sender, 2);
	if (not strfind(sender, "-")) then
		sender = sender .. "-" .. GetNormalizedRealmName();
	end
	local decoded;
	if (distribution == "YELL" or distribution == "SAY") then
		decoded = NRC.libDeflate:DecodeForWoWChatChannel(string);
	else
		decoded = NRC.libDeflate:DecodeForWoWAddonChannel(string);
	end
	if (not decoded) then
		NRC:debug("helper decompress error");
		return;
	end
	local decompressed = NRC.libDeflate:DecompressDeflate(decoded);
	local deserializeResult, deserialized = NRC.serializer:Deserialize(decompressed);
	if (not deserializeResult) then
		NRC:debug("helper deserialize error");
		return;
	end
	local args = NRC:explode(" ", deserialized, 2);
	local cmd = args[1]; --Cmd (first arg) so we know where to send the data.
	local remoteVersion = args[2]; --Version number.
	local data = args[3]; --Data.
	NRC.hasAddonHelper[sender] = (remoteVersion or "0");
	if (tonumber(remoteVersion) < 1.00) then
		return;
	end
	if (cmd == "res") then
		NRC:receivedRes(data, sender, distribution);
	elseif (cmd == "ench") then
		NRC:receivedEnchants(data, sender, distribution);
	elseif (cmd == "tal") then
		NRC:receivedTalents(data, sender, distribution);
	elseif (cmd == "gly") then
		NRC:receivedGlyphs(data, sender, distribution);
	elseif (cmd == "rd") then
		NRC:receivedRaidData(data, sender, distribution);
	elseif (cmd == "eq") then
		NRC:receivedEquip(data, sender, distribution);
	end
end

function NRC:versionCheck(remoteVersion, distribution, sender)
	if (distribution == "GUILD" or distribution == "PARTY" or distribution == "RAID") then
		local lastVersionMsg = NRC.db.global.lastVersionMsg;
		if (tonumber(remoteVersion) > tonumber(version) and (GetServerTime() - lastVersionMsg) > 14400) then
			NRC:print("|TInterface\\AddOns\\NovaRaidCompanion\\Media\\nrc_icon2:12:12:0:0|t |cFF0096FF" .. L["versionOutOfDate"]);
			NRC.db.global.lastVersionMsg = GetServerTime();
		end
		if (tonumber(remoteVersion) > tonumber(version)) then
			NRC.latestRemoteVersion = remoteVersion;
		end
	end
end

--Send to specified addon channel.
function NRC:sendComm(distribution, string, target)
	if (not distribution) then
		return;
	end
	if (target == UnitName("player") or NRC:debug()) then
		return;
	end
	if (distribution == "GUILD" and not IsInGuild()) then
		return;
	end
	if ((UnitInBattleground("player") or NRC:isInArena()) and distribution ~= "GUILD") then
		return;
	end
	if (distribution == "CHANNEL") then
		--Get channel ID number.
		local addonChannelId = GetChannelName(target);
		--Not sure why this only accepts a string and not an int.
		--Addon channels are disabled in classic but I'll leave this here anyway.
		target = tostring(addonChannelId);
	elseif (distribution ~= "WHISPER") then
		target = nil;
	end
	local data, serialized;
	serialized = NRC.serializer:Serialize(string);
	local compressed = NRC.libDeflate:CompressDeflate(serialized, {level = 9});
	if (distribution == "YELL" or distribution == "SAY") then
		data = NRC.libDeflate:EncodeForWoWChatChannel(compressed);
	else
		data = NRC.libDeflate:EncodeForWoWAddonChannel(compressed);
	end
	--NRC:debug("Serialized length:", string.len(serialized));
	--NRC:debug("Compressed length:", string.len(compressed));
	if ((distribution == "PARTY" or distribution == "RAID") and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
		NRC:SendCommMessage(NRC.commPrefix, data, "INSTANCE_CHAT", target);
	else
		NRC:SendCommMessage(NRC.commPrefix, data, distribution, target);
	end
end

--Send full data.
NRC.lastDataSent = 0;
function NRC:sendData(distribution, target, prio)
	if (NRC:isPvp()) then
		return;
	end
	if (not distribution) then
		if (IsInRaid()) then
			distribution = "RAID";
		elseif (LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
	       distribution = "INSTANCE_CHAT";
		elseif (IsInGroup()) then
			distribution = "PARTY";
		end
	end
	local inInstance, instanceType = IsInInstance();
	--if (not prio) then
	--	prio = "NORMAL";
	--end
	local data = NRC:createData(distribution);
	if (next(data) ~= nil) then
		data = NRC.serializer:Serialize(data);
		NRC.lastDataSent = GetServerTime();
		NRC:debug("Sending my raid data.");
		NRC:sendComm(distribution, "d " .. version .. " " .. data, target, prio);
	end
end

--Send our own cooldowns + settings and also request other users data back.
function NRC:requestData(distribution, target, prio)
	if (not distribution) then
		if (IsInRaid()) then
			distribution = "RAID";
		elseif (LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
	       distribution = "INSTANCE_CHAT";
		elseif (IsInGroup()) then
			distribution = "PARTY";
		end
	end
	--if (not prio) then
	--	prio = "NORMAL";
	--end
	local data = NRC:createData(distribution);
	NRC.lastDataSent = GetServerTime();
	if (next(data)) then
		data = NRC.serializer:Serialize(data);
		NRC:debug("Requesting raid data.");
		NRC:sendComm(distribution, "rq " .. version .. " " .. data, target, prio);
	end
end

--Send settings.
function NRC:sendSettings(distribution, target, prio)
	if (NRC:isPvp()) then
		return;
	end
	--if (not prio) then
	--	prio = "NORMAL";
	--end
	if (not distribution) then
		if (IsInRaid()) then
			distribution = "RAID";
		elseif (LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
	       distribution = "INSTANCE_CHAT";
		elseif (IsInGroup()) then
			distribution = "PARTY";
		else
			--This should only be sent while in a group.
			return;
		end
	end
	local data = NRC:createSettings(distribution);
	if (next(data) ~= nil) then
		data = NRC.serializer:Serialize(data);
		NRC:debug("Sending my settings.");
		NRC:sendComm(distribution, "s " .. version .. " " .. data, target, prio);
	end
end

--Send settings and also request other users settings back.
function NRC:requestSettings(distribution, target, prio)
	--if (not prio) then
	--	prio = "NORMAL";
	--end
	if (not distribution) then
		if (IsInRaid()) then
			distribution = "RAID";
		elseif (LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
	       distribution = "INSTANCE_CHAT";
		elseif (IsInGroup()) then
			distribution = "PARTY";
		else
			--This should only be sent while in a group.
			return;
		end
	end
	local data = NRC:createSettings(distribution);
	if (next(data) ~= nil) then
		data = NRC.serializer:Serialize(data);
		--NRC.lastSettingsSent = GetServerTime();
		NRC:debug("Requesting settings.");
		NRC:sendComm(distribution, "rs " .. version .. " " .. data, target, prio);
	end
end

--When we join a group we want to send our full data but only get settings back.
function NRC:dataGroupJoined()
	local distribution;
	if (IsInRaid()) then
		distribution = "RAID";
	elseif (IsInGroup()) then
		distribution = "PARTY";
	end
	local inInstance, instanceType = IsInInstance();
	local data = NRC:createData(nil, true);
	if (next(data) ~= nil) then
		data = NRC.serializer:Serialize(data);
		NRC.lastDataSent = GetServerTime();
		--NRC:debug("Sending my raid data.");
		NRC:sendComm(distribution, "g " .. version .. " " .. data);
	end
end

--Send to group when we've used a tracked cooldown (just battle res and major cooldowns mostly).
--This is a backup for people out of range that didn't see the cast.
function NRC:sendSpellUsed(spellID, cooldownTime, destName, destClass, distribution, target)
	if (not distribution) then
		if (IsInRaid()) then
			distribution = "RAID";
		elseif (LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
	       distribution = "INSTANCE_CHAT";
		elseif (IsInGroup()) then
			distribution = "PARTY";
		else
			--This should only be sent while in a group.
			return;
		end
	end
	--if (not destName) then
	--	destName = "UNKNOWN";
	--end
	--if (not destClass) then
	--	destClass = "UNKNOWN";
	--end
	if (destName) then
		destName = NRC:normalizeNameRealm(destName);
	end
	local msg = spellID .. "_" .. cooldownTime;
	if (destName) then
		msg = msg .. "_" .. destName;
		if (destClass) then
			msg = msg .. "_" .. destClass;
		end
	end
	NRC:sendComm(distribution, "spell " .. version .. " " .. msg, target);
end

function NRC:createData(distribution, includeSettings)
	local data = {};
	local cooldowns = NRC:createCooldowns(distribution);
	if (next(cooldowns)) then
		data.cooldowns = cooldowns;
	end
	--Raid data such as weapon enchants, resistances, talents are included with group join.
	local raidData = NRC:createRaidData();
	if (raidData and next(raidData)) then
		data.raidData = raidData;
	end
	--Settings are included when we join a group.
	if (includeSettings) then
		--Include my settings.
		local settings = NRC:createSettings(distribution);
		if (next(settings)) then
			data.settings = settings;
		end
	end
	data = NRC:convertKeys(data, true, distribution);
	return data;
end

function NRC:createSettings(distribution)
	local data = {};
	data.mdSendMyThreatGroup = NRC.config.mdSendMyThreatGroup;
	data.mdSendOtherThreatGroup = NRC.config.mdSendMyThreatGroup;
	data.mdSendMyCastGroup = NRC.config.mdSendMyCastGroup;
	data.mdSendOtherCastGroup = NRC.config.mdSendOtherCastGroup;
	data.tricksSendMyThreatGroup = NRC.config.tricksSendMyThreatGroup;
	data.tricksSendOtherThreatGroup = NRC.config.tricksSendMyThreatGroup;
	data.tricksSendMyCastGroup = NRC.config.tricksSendMyCastGroup;
	data.tricksSendOtherCastGroup = NRC.config.tricksSendOtherCastGroup;
	data = NRC:convertKeys(data, true, distribution);
	return data;
end

function NRC:createCooldowns(distribution)
	local cooldowns = {};
	local myCooldowns = NRC.data.raidCooldowns[UnitGUID("player")];
	if (myCooldowns and next(myCooldowns)) then
		for k, v in pairs(myCooldowns) do
			cooldowns[k] = {
				spellName =	v.spellName,
				spellID	= v.spellID,
				endTime = v.endTime;
				destName = v.destName;
				destClass = v.destClass;
			};
			--We need to include a guid if we have cooldowns so they can be attached at the others end.
			--Getting a guid from someone that just joined group from api is unreliable.
			cooldowns.gu = UnitGUID("player");
		end
	end
	return cooldowns;
end

local validKeys = {
	["cooldowns"] = true,
	["settings"] = true,
	["raidData"] = true,
};

--Key map to shorten variables with for sending.
local shortKeys = {
	["a"] = "cooldowns",
	["b"] = "settings",
	["c"] = "spellName",
	["d"] = "cooldowns",
	["e"] = "settings",
	["f"] = "spellName",
	["g"] = "spellID",
	["h"] = "endTime",
	["i"] = "destName",
	["j"] = "destClass",
	["k"] = "mdSendMyThreatGroup",
	["l"] = "mdSendOtherThreatGroup",
	["m"] = "mdSendMyCastGroup",
	["n"] = "mdSendOtherCastGroup",
	["o"] = "raidData", --Not used, processed elsewhere but reserve it anyway.
	["p"] = "tricksSendMyThreatGroup",
	["q"] = "tricksSendOtherThreatGroup",
	["r"] = "tricksSendMyCastGroup",
	["s"] = "tricksSendOtherCastGroup",
};

function NRC:receivedData(dataReceived, sender, distribution, elapsed)
	local deserializeResult, data = NRC.serializer:Deserialize(dataReceived);
	if (not deserializeResult) then
		NRC:debug("Failed to deserialize data.");
		return;
	end
	if (data.o) then
		--If we get raid data (enchants/resistances/talents) with this then extract it with a function below that the helper weakaura uses.
		--Also this data contains shortKeys{} like a b c which would be converted here back to wrong long keys.
		NRC:receivedRaidData(data.o, sender, distribution, true);
		data.o = nil
	end
	data = NRC:convertKeys(data, nil, distribution);
	if (not data) then
		NRC:debug("Bad hash result.");
		return;
	end
	--NRC:debug(data);
	local foundCooldowns;
	local guid;
	for k, v in pairs(data) do
		if (validKeys[k]) then
			if (k == "cooldowns") then
				guid = v.gu;
				if (guid) then
					for cooldownName, spellData in pairs(v) do
						if (type(v) == "table") then
							if (NRC:isValidCooldown(spellData.spellID)) then
								if (not NRC.data.raidCooldowns[guid]) then
									NRC.data.raidCooldowns[guid] = {};
								end
								if (not NRC.data.raidCooldowns[guid][cooldownName]) then
									NRC.data.raidCooldowns[guid][cooldownName] = {};
								end
								--NRC:debug("Adding data cooldown:", sender, cooldownName);
								NRC.data.raidCooldowns[guid][cooldownName].endTime = spellData.endTime;
								NRC.data.raidCooldowns[guid][cooldownName].spellName = spellData.spellName;
								NRC.data.raidCooldowns[guid][cooldownName].spellID = spellData.spellID;
								NRC.data.raidCooldowns[guid][cooldownName].destName = spellData.destName;
								NRC.data.raidCooldowns[guid][cooldownName].destClass = spellData.destClass;
								--This doesn't update NRC.cooldownList so we need to update from db at the end fo this func.
								foundCooldowns = true;
							end
						end
					end
				end
			elseif (k == "settings") then
				--local nameOnly, realm = strsplit("-", sender, 2);
				for setting, value in pairs(v) do
					--NRC:debug("Settings added for:", sender, setting, value);
					if (not NRC.groupSettings[sender]) then
						NRC.groupSettings[sender] = {};
					end
					--This will include realm name so we must filter that when comparing settings against group roster api.
					NRC.groupSettings[sender][setting] = value;
					--Keep a timestamp for data cleanup funcs.
					--NRC.groupSettings[sender].updated = GetServerTime();
				end
			end
		end
	end
	--If raid cooldown frames load before this data is received when someoe joins group.
	--Then this database data won't be loaded into in to NRC.cooldownList cache.
	--So load it afterwards.
	if (foundCooldowns) then
		C_Timer.After(1, function()
			NRC:updateRaidCooldownsFromDatabase(guid);
		end)
	end
end

function NRC:receivedSettings(dataReceived, sender, distribution)
	local deserializeResult, data = NRC.serializer:Deserialize(dataReceived);
	if (not deserializeResult) then
		NRC:debug("Failed to deserialize data.");
		return;
	end
	data = NRC:convertKeys(data, nil, distribution);
	if (not data) then
		NRC:debug("Bad hash result.");
		return;
	end
	--local nameOnly, realm = strsplit("-", sender, 2);
	for setting, value in pairs(data) do
		--NRC:debug("Settings added for:", sender, setting, value);
		if (not NRC.groupSettings[sender]) then
			NRC.groupSettings[sender] = {};
		end
		--This will include realm name so we must filter that when comparing settings against group roster api.
		NRC.groupSettings[sender][setting] = value;
		--Keep a timestamp for data cleanup funcs.
		--NRC.groupSettings[sender].updated = GetServerTime();
	end
end

--Process received cooldown strings.
function NRC:receivedString(cmd, dataReceived, sender, distribution)
	if (distribution ~= "RAID" and distribution ~= "PARTY") then
		return;
	end
	local found;
	if (cmd == "spell") then
		local guid = NRC:getGuidFromGroup(sender);
		--NRC:debug("received string", sender, dataReceived);
		if (guid) then
			local spellID, cooldownTime, destName, destClass = strsplit("_", dataReceived, 4);
			local destGUID = NRC:getGroupGuidFromName(destName, destClass);
			spellID = tonumber(spellID) or 0;
			if (NRC:isValidCooldown(spellID)) then
				for spell, spellData in pairs(NRC.cooldownList) do
					if (spellData.spellIDs and next(spellData.spellIDs)) then
						for trackedSpellID, spellName in pairs(spellData.spellIDs) do
							if (trackedSpellID == spellID) then
								for char, charData in pairs(spellData.chars) do
									if (char == guid) then
										--Update NRC.cooldownList data so our update func picks it up;
										if (cooldownTime) then
											--If we supplied a cooldown arg then use that instead.
											charData.endTime = tonumber(cooldownTime);
										else
											charData.endTime = GetServerTime() + spellData.cooldown;
										end
										charData.destName = destName;
										charData.destClass = destClass;
										local cooldownName, spellName, _, spellTableName = NRC:getCooldownFromSpellID(spellID);
										--Strip realm from sender for realm check.
										local name, realm = strsplit("-", sender, 2);
										if (realm ~= NRC.realm and realm ~= GetNormalizedRealmName()) then
											--Talents are stored without realm name for people on same realm.
											--If not same realm then add it.
											name = name .. "-" .. realm;
										end
										charData.endTime = NRC:adjustCooldownFromTalentsAndGear(spellTableName, name, charData.endTime, guid, spellID);
										--And update our database.
										if (cooldownName) then
											if (not NRC.data.raidCooldowns[guid]) then
												NRC.data.raidCooldowns[guid] = {};
											end
											if (not NRC.data.raidCooldowns[guid][cooldownName]) then
												NRC.data.raidCooldowns[guid][cooldownName] = {};
											end
											NRC.data.raidCooldowns[guid][cooldownName].endTime = charData.endTime;
											NRC.data.raidCooldowns[guid][cooldownName].spellName = spellName;
											NRC.data.raidCooldowns[guid][cooldownName].spellID = spellID;
											NRC.data.raidCooldowns[guid][cooldownName].destName = destName;
											NRC.data.raidCooldowns[guid][cooldownName].destClass = destClass;
											NRC:pushCastCache(guid, cooldownName, destName, destClass, spellID);
											local realName = NRC:getCooldownFromSpellID(spellID);
											if (destGUID and realName == "Soulstone" and NRC:inOurGroup(destGUID)) then
												NRC:soulstoneAdded(destGUID, GetServerTime() + soulstoneDuration);
												--NRC:debug("remote soulstone added", destGUID);
											end
											NRC:updateRaidCooldowns();
											found = true;
										end
										break;
									end
								end
							end
						end
					end
				end
				if (not found) then
					--If the spell was not being tracked then we need to add it to the DB incase it's enabled after.
					local cooldownName, spellName, cooldown, spellTableName = NRC:getCooldownFromSpellID(spellID);
					local endTime = 0;
					if (cooldownName) then
						if (cooldownTime) then
							--If we supplied a cooldown arg then use that instead.
							endTime = tonumber(cooldownTime);
						else
							endTime = GetServerTime() + cooldown;
						end
						--Strip realm from sender for realm check.
						local name, realm = strsplit("-", sender, 2);
						if (realm ~= NRC.realm and realm ~= GetNormalizedRealmName()) then
							--Talents are stored without realm name for people on same realm.
							--If not same realm then add it.
							name = name .. "-" .. realm;
						end
						endTime = NRC:adjustCooldownFromTalentsAndGear(spellTableName, name, endTime, guid, spellID);
						if (not NRC.data.raidCooldowns[guid]) then
							NRC.data.raidCooldowns[guid] = {};
						end
						if (not NRC.data.raidCooldowns[guid][cooldownName]) then
							NRC.data.raidCooldowns[guid][cooldownName] = {};
						end
						NRC.data.raidCooldowns[guid][cooldownName].endTime = endTime;
						NRC.data.raidCooldowns[guid][cooldownName].spellName = spellName;
						NRC.data.raidCooldowns[guid][cooldownName].spellID = spellID;
						NRC.data.raidCooldowns[guid][cooldownName].destName = destName;
						NRC.data.raidCooldowns[guid][cooldownName].destClass = destClass;
						NRC:pushCooldownCastDetect(guid, name, spellName, spellID);
					end
				end
			end
		end
	end
end

--Adapted from my other addon NovaWorldBuffs.
--Only one person at a time sends group msgs so there's no spam, chosen by alphabetical order and user settings.
--If selfType is specified then we have to check if selfWho has their own announce turned on for this event.
--Example: Misdirection has self announce and other player announce.
--We don't want to announce "other" if the player has the addon and the self settings is enabled.
function NRC:sendGroupSettingsCheck(msg, type, selfType, selfWho, delay)
	if (selfWho) then
		--If no realm was passed then it must be our realm so add it, settings are stored with realm.
		if (not strfind(selfWho, "-")) then
			--Add normalized realm since roster checks use this.
			selfWho = selfWho .. "-" .. GetNormalizedRealmName();
		else
			selfWho = NRC:normalizeNameRealm(selfWho);
		end
	end
	--If the player this msg is about has self enabled for this option type.
	if (selfType and selfWho) then
		if (NRC.groupSettings[selfWho] and NRC.groupSettings[selfWho][selfType] == true and NRC:inOurGroup(selfWho)) then
			NRC:debug("Self found:", selfType, selfWho)
			return;
		end	
	end
	local groupMembers = GetNumGroupMembers();
	local onlineMembers = {};
	local me = UnitName("player") .. "-" .. GetNormalizedRealmName();
	for i = 1, groupMembers do
		local name, _, _, _, _, _, zone, online = GetRaidRosterInfo(i);
		if (name) then
			if (not strfind(name, "-")) then
				name = name .. "-" .. GetNormalizedRealmName();
			end
			if (type) then
				--If type then check our db for other peoples settings.
				--Create a list of people in group with setting enabled
				if (name and online and NRC.hasAddon[name]) then
					--if (NRC.groupSettings[name] and NRC.hasAddon[name] > 1.16) then
					if (NRC.groupSettings[name]) then
						if (NRC.groupSettings[name][type] == true) then
							--Has addon and has this type of msg type option enabled.
							onlineMembers[name] = true;
						end
					elseif (name == me) then
						--If myself check my settings.
						if (NRC.config[type] == true) then
							onlineMembers[name] = true;
						end
					end
				end
			else
				if (name and online and NRC.hasAddon[name]) then
					--If guild member is online and has addon installed add to temp table.
					onlineMembers[name] = true;
				end
			end
		end
	end
	--Check temp table to see if we're first in alphabetical order.
	for k, v in NRC:pairsByKeys(onlineMembers) do
		NRC:debug("Sender: " .. k);
		if (k == me) then
			NRC:sendGroup(NRC:stripColors(msg), nil, delay);
		end
		return;
	end
end

local shortKeysReversed = {};
for k,v in pairs(shortKeys) do
	shortKeysReversed[v] = k;
end

function NRC:convertKeys(table, shorten, distribution)
	if (type(table) ~= "table") then
		NRC:debug("no convertKeys table", table);
		return;
	end
	local keys = shortKeys;
	if (shorten) then
		keys = shortKeysReversed;
	end
	local data = {};
	for k, v in pairs(table) do
		if (type(v) == "table") then
			v = NRC:convertKeys(v, shorten, distribution);
		end
		if (keys[k]) then
			data[keys[k]] = v;
		else
			data[k] = v;
		end
	end
	return data;
end

--NRC helpers from my other addons.
--[[local function checkAddon()
	--Check what's installed, only one addon should help.
	local NWB = GetAddOnMetadata("NovaWorldBuffs", "Version");
	local NIT = GetAddOnMetadata("NovaInstanceTracker", "Version");
	local NRC = GetAddOnMetadata("NovaRaidTracker", "Version");
	if (addonName ~= "NovaRaidCompanion") then
		if (addonName == "NovaWorldBuffs" and not NRC) then
			--NWB helps first if no NRC installed.
			return true;
		end
		if (addonName == "NovaInstanceTracker" and not NRC and not NWB) then
			--If not NWB and NRC then NIT will help.
			return true;
		end
		--If NRC is installed do nothing.
		return;
	end
	return true;
end]]

---Raid data sharing---
--I wish LibDurability had a func to send a single update, this will do for now.
--This is just used upon death and repairing at a vendor.
local myDura, myEnchants;
local function updateDura(percent, broken, sender, channel)
	if (percent) then
		percent = math.floor(percent);
		NRC.durability[sender] = {
			percent = percent,
			broken = broken,
		};
	end
end
NRC.dura:Register("NovaRaidCompanion", updateDura);
NRC.updateDura = updateDura;

function NRC:sendDura()
	if (not IsInGroup()) then
		return;
	end
	--NRC:debug("sending dura update");
	local percent, broken = NRC.dura.GetDurability();
	if (IsInRaid()) then
		C_ChatInfo.SendAddonMessage("Durability", string.format("%d, %d", percent, broken), "RAID");
	elseif (IsInGroup()) then
		C_ChatInfo.SendAddonMessage("Durability", string.format("%d, %d", percent, broken), "PARTY");
	end
end

function NRC:sendDuraThroddled()
	NRC:throddleEventByFunc("DURA_UPDATE", 3, "sendDura");
end

function NRC:updateMyDura()
	local percent, broken = NRC.dura.GetDurability();
	if (not myDura) then
		--First run after logon;
		myDura = percent;
		return;
	end
	if (percent and percent > myDura) then
		--Has repaired or swapped a fresh item on.
		--NRC:debug("repaired");
		NRC:sendDuraThroddled();
	end
	NRC.updateDura(percent, broken, UnitName("player"));
	myDura = percent;
end

local myRes = {};
local lastGroupJoin, lastRaidDataSent = 0, 0;
local myTalentsChanged;
local f = CreateFrame("Frame");
f:RegisterEvent("GROUP_FORMED");
f:RegisterEvent("GROUP_JOINED");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("GROUP_LEFT");
f:RegisterEvent("UNIT_RESISTANCES");
f:RegisterEvent("UNIT_INVENTORY_CHANGED");
f:RegisterEvent("CHARACTER_POINTS_CHANGED");
if (C_EventUtils.IsEventValid("PLAYER_SPECIALIZATION_CHANGED")) then
	f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
end
if (C_EventUtils.IsEventValid("GLYPH_ADDED")) then
	f:RegisterEvent("GLYPH_ADDED");
	f:RegisterEvent("GLYPH_UPDATED");
	f:RegisterEvent("GLYPH_REMOVED");
end
if (C_EventUtils.IsEventValid("PLAYER_TALENT_UPDATE")) then
	f:RegisterEvent("PLAYER_TALENT_UPDATE");
end
--f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGE"); --PLAYER_TALENT_UPDATE is enough to cover dual spec change.
f:SetScript('OnEvent', function(self, event, ...)
	if (event == "GROUP_JOINED" or event == "GROUP_FORMED") then
		--We need a cooldown check if we're first to be invited to a group.
		--Both events fire at once for first invited and we only want to send once.
		if (GetNumGroupMembers() > 1 and GetTime() - lastGroupJoin > 1) then
			lastGroupJoin = GetTime();
			--Instead of just sending data when joining now we request data settings.
			--This is so we can use the same system NWB uses for only person sending msgs to chat based on group user settings.
			--C_Timer.After(2, function()
				NRC:dataGroupJoined();
				--Send data compatible with old versions for a little while after this update, both these data sets fit in 1 msg each so it's fine.
				NRC:sendRaidData();
			--end)
			--NRC:startRaidCacheTicker();
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		NRC:checkMyRes(true);
		NRC:checkMyEnchants(true);
		NRC.checkMyTalents();
		NRC.checkMyGlyphs();
		NRC.checkMyEquip();
		local isLogon, isReload = ...;
		if (isReload) then
			--If reload then group join won't fire so send it here instead.
			C_Timer.After(10, function()
				if (IsInGroup()) then
					NRC:dataGroupJoined();
				end
			end)
			--NRC:startRaidCacheTicker();
		end
		f:UnregisterEvent("PLAYER_ENTERING_WORLD");
	elseif (event == "GROUP_LEFT") then
		NRC.durability = {};
		NRC.resistances = {};
		NRC:checkMyRes(true);
		NRC.equipCache = {};
		NRC:checkMyEquip();
		NRC.weaponEnchants = {};
		NRC:checkMyEnchants(true);
		--NRC.talents = {};
		--NRC.talents2 = {};
		--NRC.glyphs = {};
		--NRC.glyphs2 = {};
		--NRC:stopRaidCacheTicker();
	elseif (event == "PLAYER_REGEN_ENABLED") then
		NRC:checkMyRes();
		f:UnregisterEvent("PLAYER_REGEN_ENABLED");
	elseif (event == "UNIT_RESISTANCES") then
		local unit = ...;
		if (unit == "player") then
			NRC:throddleEventByFunc("UNIT_RESISTANCES", 3, "checkMyRes");
		end
	elseif (event == "UNIT_INVENTORY_CHANGED") then
		NRC:throddleEventByFunc("UNIT_INVENTORY_CHANGED", 3, "checkMyEnchants");
	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
		myTalentsChanged = true;
		NRC:checkMyTalents();
		NRC.checkMyGlyphs();
		NRC:throddleEventByFunc("CHARACTER_POINTS_CHANGED", 2, "sendTalents");
		NRC:throddleEventByFunc("GLYPH_UPDATED", 1, "sendGlyphs");
	elseif (event == "CHARACTER_POINTS_CHANGED" or event == "PLAYER_TALENT_UPDATE") then
		myTalentsChanged = true;
		NRC:checkMyTalents();
		NRC.checkMyGlyphs();
		C_Timer.After(2, function()
			NRC:throddleEventByFunc("CHARACTER_POINTS_CHANGED", 8, "sendTalents");
		end)
	elseif (event == "GLYPH_ADDED" or event == "GLYPH_UPDATED" or event == "GLYPH_REMOVED") then
		NRC:checkMyTalents();
		NRC.checkMyGlyphs();
		C_Timer.After(2, function()
			NRC:throddleEventByFunc("GLYPH_UPDATED", 3, "sendGlyphs");
		end)
	end
end)

function NRC:sendRes()
	if (not IsInGroup()) then
		return;
	end
	if (not GetWeaponEnchantInfo) then
		return;
	end
	local me = UnitName("player");
	NRC.resistances[me] = myRes;
	--NRC:debug("sending res update");
	local data = NRC.serializer:Serialize(myRes);
	NRC:sendGroupComm("res " .. NRC.version .. " " .. data);
end

function NRC:receivedRes(data, sender, distribution)
	local name, realm = strsplit("-", sender, 2);
	if (realm == NRC.realm or realm == GetNormalizedRealmName()) then
		sender = name;
	end
	--NRC:debug("received res update from", sender);
	local deserializeResult, raidData = NRC.serializer:Deserialize(data);
	if (not deserializeResult) then
		NRC:debug("Failed to deserialize res.");
		return;
	end
	if (next(raidData)) then
		NRC.resistances[sender] = raidData;
	else
		NRC.resistances[sender] = nil;
	end
end

function NRC:checkMyRes(setDataOnly)
	if (NRC.isRetail or not UnitResistance) then
		return;
	end
	if (InCombatLockdown() and not setDataOnly) then
		--Don't clog up comms during combat, wait till combat ends then update others.
		f:RegisterEvent("PLAYER_REGEN_ENABLED");
		return;
	end
	local me = UnitName("player");
	local temp = {};
	for i = 2, 6 do
		--0 = Armor, 1 = Holy, 2 = Fire, 3 = Nature, 4 = Frost, 5 = Shadow, 6 = Arcane,
		local _, total = UnitResistance("player", i);
		temp[i] = total;
	end
	myRes = temp;
	NRC.resistances[me] = temp;
	if (setDataOnly) then
		--Just set our data, no sharing.
		return;
	end
	if (not next(myRes)) then
		--First run after logon, create cache and send data if we're in a group.
		myRes = temp;
		if (IsInGroup()) then
			NRC:sendRes();
		end
		return;
	end
	--There is no easy table compare in lua.
	if (myRes[2] ~= temp[2] or myRes[3] ~= temp[3]
			or myRes[4] ~= temp[4] or myRes[5] ~= temp[5] or myRes[6] ~= temp[6]) then
		--Resistances have changed, swapped items or received buff.
		--NRC:debug("resistances changed");
		myRes = temp;
		if (NRC.expansionNum < 4) then
			NRC:sendRes();
		else
			--In cata paladin aura in dungs dropping/reapplying.
			NRC:throddleEventByFunc("ResUpdate", 5, "sendRes");
		end
	else
		myRes = temp;
		if (IsInGroup()) then
			NRC.resistances[me] = myRes;
		end
	end
end

function NRC:sendEnchants()
	if (not IsInGroup()) then
		return;
	end
	if (not GetWeaponEnchantInfo) then
		return;
	end
	local me = UnitName("player");
	if (next(myEnchants)) then
		NRC.weaponEnchants[me] = myEnchants;
	else
		--Table should always have entries if it gets this far but just incase.
		NRC.weaponEnchants[me] = nil;
	end
	--NRC:debug("sending weapon enchant update");
	local data = NRC.serializer:Serialize(myEnchants);
	NRC:sendGroupComm("ench " .. NRC.version .. " " .. data);
end

function NRC:receivedEnchants(data, sender, distribution)
	local name, realm = strsplit("-", sender, 2);
	if (realm == NRC.realm or realm == GetNormalizedRealmName()) then
		sender = name;
	end
	--NRC:debug("received weapon enchant update from", sender);
	local deserializeResult, raidData = NRC.serializer:Deserialize(data);
	if (not deserializeResult) then
		NRC:debug("Failed to deserialize enchants.");
		return;
	end
	NRC.weaponEnchants[sender] = raidData;
end

--EnchantIDs.
NRC.enchantIgnoreList = {
	--Windfury totem.
	[1783] = true,
	[563] = true,
	[564] = true,
	[2638] = true,
	[2639] = true,
	--Wild strikes SoD.
	[6858] = true,
	[7141] = true,
};

function NRC:checkMyEnchants(setDataOnly)
	if (not GetWeaponEnchantInfo) then
		return;
	end
	local me = UnitName("player");
	local temp = {};
	local mh, mhTime, _, mhID, oh, ohTime, _, ohID = GetWeaponEnchantInfo();
	if (mh) then
		--Ignore windfury totems.
		if (not NRC.enchantIgnoreList[mhID]) then
			temp[1] = mhID;
			temp[2] = GetServerTime() + math.floor(mhTime/1000);
		end
	end
	if (oh) then
		if (not NRC.enchantIgnoreList[ohID]) then
			temp[3] = ohID;
			temp[4] = GetServerTime() + math.floor(ohTime / 1000);
		end
	end
	if (next(temp)) then
		NRC.weaponEnchants[me] = temp;
	else
		NRC.weaponEnchants[me] = nil;
	end
	if (setDataOnly) then
		return;
	end
	if (not myEnchants) then
		--First run after logon, create cache and send data if we're in a group.
		myEnchants = temp;
		if (IsInGroup()) then
			NRC:sendEnchants();
		end
		return;
	end
	local changed;
	--Check if enchanted and wasn't previously, or other way around.
	if (myEnchants[1] ~= temp[1] or myEnchants[3] ~= temp[3]) then
		--Weapon enchants have changed.
		--NRC:debug("Weapon enchant changed.");
		changed = true;
	elseif ((myEnchants[2] and temp[2] and temp[2] > myEnchants[2] and temp[2] - myEnchants[2] > 20)
		or(myEnchants[4] and temp[4] and temp[4] > myEnchants[4] and temp[4] - myEnchants[4] > 20)) then
		--Time seems to creep forward every now and then a few seconds so check if weapon actually changed.
		--NRC:debug("Weapon enchant time changed.");
		changed = true;
	end
	if (changed) then
		myEnchants = temp;
		NRC:sendEnchants();
	else
		myEnchants = temp;
		--if (IsInGroup()) then
			if (next(myEnchants)) then
				NRC.weaponEnchants[me] = myEnchants;
			else
				NRC.weaponEnchants[me] = nil;
			end
		--end
	end
end

function NRC:sendTalents()
	if (not IsInGroup()) then
		return;
	end
	local talents = NRC:createTalentString();
	local me = UnitName("player");
	NRC.talents[me] = talents;
	--NRC:debug("sending talents update");
	local data = NRC.serializer:Serialize(talents);
	NRC:sendGroupComm("tal " .. NRC.version .. " " .. data);
	if (myTalentsChanged and IsInGroup()) then
		myTalentsChanged = nil;
		if (not NRC.groupCache[me]) then
			--If we tried to send too early after logon/reload/joining group maybe?
			--Seen this error rarely but it does happen, not sure why.
			--Construct a rough groupCache type table.
			local _, race = UnitRace("player");
			local _, class = UnitRace("player");
			local t = {
				class = class,
				--zone = zone,
				online = true,
				realm = NRC.realm,
				--subGroup = subGroup,
				level = UnitLevel("player"),
				guid = UnitGUID("player"),
				race = race,
				unit = "player",
			};
			NRC:loadRaidCooldownChar(me, t);
		end
		NRC:loadRaidCooldownChar(me, NRC.groupCache[me]);
	end
end

function NRC:receivedTalents(data, sender, distribution)
	local name, realm = strsplit("-", sender, 2);
	if (realm == NRC.realm or realm == GetNormalizedRealmName()) then
		sender = name;
	end
	--NRC:debug("received talents update from", sender);
	local deserializeResult, raidData = NRC.serializer:Deserialize(data);
	if (not deserializeResult) then
		NRC:debug("Failed to deserialize talents.");
		return;
	end
	NRC.talents[sender] = raidData;
end

function NRC:checkMyTalents()
	--if (IsInGroup()) then
		local me = UnitName("player");
		NRC.talents[me], NRC.talents2[me] = NRC:createTalentString();
		NRC:updateIssuesCache(UnitGUID("player"));
	--end
end

function NRC:sendGlyphs(sender)
	if (not IsInGroup() and not sender) then
		return;
	end
	local glyphs = NRC:createGlyphString();
	local me = UnitName("player");
	NRC.glyphs[me] = glyphs;
	--NRC:debug("sending glyphs update");
	local data = NRC.serializer:Serialize(glyphs);
	if (sender) then
		local name, realm = strsplit("-", sender, 2);
		if (realm == NRC.realm or realm == GetNormalizedRealmName()) then
			sender = name;
		end
		NRC:sendComm("WHISPER", "glyrec " .. NRC.version .. " " .. data, sender);
	else
		NRC:sendGroupComm("gly " .. NRC.version .. " " .. data);
	end
end

function NRC:receivedGlyphs(data, sender, distribution, isWhisper)
	local name, realm = strsplit("-", sender, 2);
	if (realm == NRC.realm or realm == GetNormalizedRealmName()) then
		sender = name;
	end
	NRC:debug("received glyphs update from", sender);
	local deserializeResult, raidData = NRC.serializer:Deserialize(data);
	if (not deserializeResult) then
		NRC:debug("Failed to deserialize glyphs.");
		return;
	end
	NRC.glyphs[sender] = raidData;
	if (isWhisper) then
		local data = NRC:createGlyphDataFromString(NRC.glyphs[sender]);
		--This is only used for inspect, if that ever changes then always supplying NRCInspectTalentFrame will error.
		NRC:updateGlyphFrame(data, NRCInspectTalentFrame, sender);
	end
end

function NRC:checkMyGlyphs()
	--if (IsInGroup()) then
		local me = UnitName("player");
		NRC.glyphs[me], NRC.glyphs2[me] = NRC:createGlyphString();
		NRC:updateIssuesCache(UnitGUID("player"));
	--end
end

--Send raid data only, no settings etc.
--This is sent when someone requests it by opening the raid status frame, throddled.
function NRC:createRaidData()
	NRC:checkMyRes(true);
	NRC:checkMyEnchants(true);
	NRC:checkMyTalents();
	NRC.checkMyGlyphs();
	NRC.checkMyEquip();
	local me = UnitName("player");
	NRC.resistances[me] = myRes;
	local data = {};
	if (myRes) then
		data.a = myRes;
	end
	local b = NRC:createTalentString();
	if (b) then
		data.b = b;
	end
	local c;
	if (myEnchants and next(myEnchants)) then
		data.c = myEnchants;
	end
	local percent, broken = NRC.dura.GetDurability();
	if (percent and broken) then
		data.d = floor(percent);
		if (broken and broken > 0) then
			data.e = broken;
		end
	end
	local g = NRC:createGlyphString();
	if (g) then
		data.g = g;
	end
	local h = NRC:getEquipToShare(true);
	if (h) then
		data.h = h;
	end
	return data;
end

function NRC:sendRaidData()
	if (not IsInGroup()) then
		return;
	end
	if (GetServerTime() - lastRaidDataSent < 10) then --Change this time to longer later (once data accuracy is observed properly).
		--If multiple leaders open the status frame we don't need to keep sending data.
		--They should already have it unless they just joined group.
		--Individual stats are sent when they change so data should always be up to date.
		return;
	end
	lastRaidDataSent = GetServerTime();
	local data = NRC:createRaidData();
	data = NRC.serializer:Serialize(data);
	NRC:sendGroupComm("rd " .. NRC.version .. " " .. data);
end

--This is called when we open the raid status frame, throddled.
function NRC:requestRaidData()
	if (not IsInGroup()) then
		return;
	end
	--Durability is requested seperately because it's a 3rd party lib other addons use too.
	NRC.dura:RequestDurability();
	NRC:sendGroupComm("requestRaidData " .. NRC.version);
end

--If it comes included with other data in NRC:receivedData() then it's already deserialized.
function NRC:receivedRaidData(data, sender, distribution, alreadyDeserialized)
	local name, realm = strsplit("-", sender, 2);
	if (realm == NRC.realm or realm == GetNormalizedRealmName()) then
		sender = name;
	end
	--NRC:debug("received raid update from", sender);
	local deserializeResult, raidData;
	if (alreadyDeserialized) then
		deserializeResult, raidData = true, data;
	else
		deserializeResult, raidData = NRC.serializer:Deserialize(data);
	end
	if (not deserializeResult) then
		NRC:debug("Failed to deserialize raid data.");
		return;
	end
	if (raidData) then
		--Resistances.
		if (raidData.a) then
			NRC.resistances[sender] = raidData.a;
		end
		if (raidData.b) then
			NRC.talents[sender] = raidData.b;
		end
		if (raidData.c) then
			NRC.weaponEnchants[sender] = raidData.c;
		end
		if (raidData.d) then
			if (not raidData.e) then
				--We don't include broken items with main data if nothing is broken.
				raidData.e = 0;
			end
			updateDura(raidData.d, raidData.e, sender, distribution)
		end
		if (raidData.g) then
			NRC.glyphs[sender] = raidData.g;
		end
		if (raidData.h) then
			NRC.equipCache[sender] = raidData.h;
		end
	end
end

--[[function NRC:updateRaidCache()
	for k, v in pairs(NRC.weaponEnchants) do
		--Main hand timer.
		if (v[2] and v[2] < GetServerTime()) then
			NRC.weaponEnchants[k][1] = nil;
			NRC.weaponEnchants[k][2] = nil;
		end
		--Offhand timer.
		if (v[4] and v[4] < GetServerTime()) then
			NRC.weaponEnchants[k][3] = nil;
			NRC.weaponEnchants[k][4] = nil;
		end
		if (not v[1] and not v[3]) then
			NRC.weaponEnchants[k] = nil;
		end
	end
end]]

--local ticker;
--function NRC:startRaidCacheTicker()
	--Not needed yet.
	--[[if (ticker) then
		return;
	end
	ticker = true;
	NRC:raidCacheTicker();]]
--end

--function NRC:stopRaidCacheTicker()
--	ticker = nil;
--end

--[[function NRC:raidCacheTicker()
	NRC:updateRaidCache();
	if (ticker) then
		C_Timer.After(5, function()
			NRC:raidCacheTicker();
		end)
	end
end]]

local NRCVersionFrame;
function NRC:openVersionFrame()
	if (not NRCVersionFrame) then
		NRCVersionFrame =  NRC:createSimpleInputScrollFrame("NRCVersionFrame", 300, 450, 0, 100);
		NRCVersionFrame:Hide();
		NRCVersionFrame:SetToplevel(true);
		NRCVersionFrame:SetMovable(true);
		NRCVersionFrame:EnableMouse(true);
		tinsert(UISpecialFrames, "NRCVersionFrame");
		NRCVersionFrame:SetPoint("CENTER", UIParent, 0, 100);
		NRCVersionFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8",insets = {top = 0, left = 0, bottom = 0, right = 0}});
		NRCVersionFrame:SetBackdropColor(0,0,0,.5);
		NRCVersionFrame:SetFrameStrata("HIGH");
		NRCVersionFrame.EditBox:SetAutoFocus(false);
		NRCVersionFrame.EditBox:SetScript("OnKeyDown", function(self, arg)
			--If control key is down keep focus for copy/paste to work.
			--Otherwise remove focus so "enter" can be used to open chat and not have a stuck cursor on this edit box.
			if (not IsControlKeyDown()) then
				NRCVersionFrame.EditBox:ClearFocus();
			end
		end)
		NRCVersionFrame.EditBox:SetScript("OnShow", function(self, arg)
			NRCVersionFrame:SetVerticalScroll(0);
		end)
		local versionUpdateTime = 0;
		NRCVersionFrame:HookScript("OnUpdate", function(self, arg)
			--Only update once per second.
			if (GetServerTime() - versionUpdateTime > 0 and self:GetVerticalScrollRange() == 0) then
				NRC:recalcVersionFrame();
				versionUpdateTime = GetServerTime();
			end
		end)
		NRCVersionFrame.fs:SetText("|cFFFFFF00NRC Addon and Helper Versions|r");
		
		local NRCVersionDragFrame = CreateFrame("Frame", "NRCVersionDragFrame", NRCVersionFrame);
		NRCVersionDragFrame:SetToplevel(true);
		NRCVersionDragFrame:EnableMouse(true);
		NRCVersionDragFrame:SetWidth(205);
		NRCVersionDragFrame:SetHeight(38);
		NRCVersionDragFrame:SetPoint("TOP", 0, 4);
		NRCVersionDragFrame:SetFrameLevel(131);
		NRCVersionDragFrame.tooltip = CreateFrame("Frame", "NRCVersionDragTooltip", NRCVersionDragFrame, "TooltipBorderedFrameTemplate");
		NRCVersionDragFrame.tooltip:SetPoint("CENTER", NRCVersionDragFrame, "TOP", 0, 12);
		NRCVersionDragFrame.tooltip:SetFrameStrata("TOOLTIP");
		NRCVersionDragFrame.tooltip:SetFrameLevel(9);
		NRCVersionDragFrame.tooltip:SetAlpha(.8);
		NRCVersionDragFrame.tooltip.fs = NRCVersionDragFrame.tooltip:CreateFontString("NRCVersionDragTooltipFS", "ARTWORK");
		NRCVersionDragFrame.tooltip.fs:SetPoint("CENTER", 0, 0.5);
		NRCVersionDragFrame.tooltip.fs:SetFont(NRC.regionFont, 12);
		NRCVersionDragFrame.tooltip.fs:SetText(L["Hold to drag"]);
		NRCVersionDragFrame.tooltip:SetWidth(NRCVersionDragFrame.tooltip.fs:GetStringWidth() + 16);
		NRCVersionDragFrame.tooltip:SetHeight(NRCVersionDragFrame.tooltip.fs:GetStringHeight() + 10);
		NRCVersionDragFrame:SetScript("OnEnter", function(self)
			NRCVersionDragFrame.tooltip:Show();
		end)
		NRCVersionDragFrame:SetScript("OnLeave", function(self)
			NRCVersionDragFrame.tooltip:Hide();
		end)
		NRCVersionDragFrame.tooltip:Hide();
		NRCVersionDragFrame:SetScript("OnMouseDown", function(self, button)
			if (button == "LeftButton" and not self:GetParent().isMoving) then
				self:GetParent().EditBox:ClearFocus();
				self:GetParent():StartMoving();
				self:GetParent().isMoving = true;
				--self:GetParent():SetUserPlaced(false);
			end
		end)
		NRCVersionDragFrame:SetScript("OnMouseUp", function(self, button)
			if (button == "LeftButton" and self:GetParent().isMoving) then
				self:GetParent():StopMovingOrSizing();
				self:GetParent().isMoving = false;
			end
		end)
		NRCVersionDragFrame:SetScript("OnHide", function(self)
			if (self:GetParent().isMoving) then
				self:GetParent():StopMovingOrSizing();
				self:GetParent().isMoving = false;
			end
		end)
	end
	
	NRCVersionFrame.fs:SetFont(NRC.regionFont, 14);
	if (NRCVersionFrame:IsShown()) then
		NRCVersionFrame:Hide();
	else
		NRCVersionFrame:SetHeight(300);
		NRCVersionFrame:SetWidth(450);
		local fontSize = false
		NRCVersionFrame.EditBox:SetFont(NRC.regionFont, 14, "");
		NRCVersionFrame.EditBox:SetWidth(NRCVersionFrame:GetWidth() - 30);
		NRCVersionFrame:Show();
		NRC:recalcVersionFrame();
		--Changing scroll position requires a slight delay.
		--Second delay is a backup.
		C_Timer.After(0.05, function()
			NRCVersionFrame:SetVerticalScroll(0);
		end)
		C_Timer.After(0.3, function()
			NRCVersionFrame:SetVerticalScroll(0);
		end)
		--So interface options and this frame will open on top of each other.
		if (InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown()) then
			NRCVersionFrame:SetFrameStrata("DIALOG");
		elseif (SettingsPanel and SettingsPanel:IsShown()) then
			NRCVersionFrame:SetFrameStrata("DIALOG");
		else
			NRCVersionFrame:SetFrameStrata("HIGH");
		end
	end
end

function NRC:recalcVersionFrame()
	NRCVersionFrame.EditBox:SetText("\n\n");
	local sorted, sortedHelper = {}, {};
	local group = {};
	local highestVersion, highestHelperVersion = 0, 0;
	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i);
		if (not strmatch(name, "%-")) then
			name =  name .. "-" .. GetNormalizedRealmName();
		end
		name = string.gsub(string.gsub(name, "'", ""), " ", "");
		group[name] = true;
	end
	for k, v in pairs(NRC.hasAddon) do
		v = tonumber(v);
		if (v > highestVersion) then
			highestVersion = v;
		end
	end
	for k, v in pairs(NRC.hasAddonHelper) do
		v = tonumber(v);
		if (v > highestHelperVersion) then
			highestHelperVersion = v;
		end
	end
	local found;
	for k, v in pairs(NRC.hasAddon) do
		if (group[k]) then
			v = tonumber(v);
			if (not sorted[v]) then
				sorted[v] = {};
			end
			local who, realm = strsplit("-", k, 2);
			sorted[v][who] = true;
			found = true;
			group[k] = nil;
		end
	end
	if (not sorted[NRC.version]) then
		sorted[NRC.version] = {};
	end
	sorted[NRC.version][UnitName("player")] = true;
	local foundHelper;
	for k, v in pairs(NRC.hasAddonHelper) do
		if (group[k]) then
			v = tonumber(v);
			if (not sorted[v]) then
				sortedHelper[v] = {};
			end
			local who, realm = strsplit("-", k, 2);
			sortedHelper[v][who] = true;
			foundHelper = true;
			group[k] = nil;
		end
	end
	NRCVersionFrame.EditBox:Insert("|cFFFFAE42[Addon]|r\n");
	for k, v in NRC:pairsByKeys(sorted) do		
		for kk, vv in NRC:pairsByKeys(v) do
			if (k > 0 or NRC.isDebug) then
				local nameString;
				local class = NRC:getClassFromName(kk);
				if (class) then
					local _, _, _, classHex = NRC.getClassColor(class);
					nameString = "|c" .. classHex .. kk .. "|r";
				else
					nameString = kk;
				end
				if (k < highestVersion) then
					NRCVersionFrame.EditBox:Insert("|cFFFF2222v" .. k .. "|r |cff9CD6DE" .. nameString .. "|r |cFFA1A1A1(out of date)|r\n");
				else
					NRCVersionFrame.EditBox:Insert("|cFF00FF00v" .. k .. "|r |cff9CD6DE" .. nameString .. "|r\n");
				end
			end
		end
	end
	NRCVersionFrame.EditBox:Insert("\n|cFFFFAE42[Weakaura Helper (wago.io/sof4ehBA6)]|r\n");
	for k, v in NRC:pairsByKeys(sortedHelper) do
		for kk, vv in NRC:pairsByKeys(v) do
			if (k > 0 or NRC.isDebug) then
				local nameString;
				local class = NRC:getClassFromName(kk);
				if (class) then
					local _, _, _, classHex = NRC.getClassColor(class);
					nameString = "|c" .. classHex .. kk .. "|r";
				else
					nameString = kk;
				end
				if (k < highestHelperVersion) then
					NRCVersionFrame.EditBox:Insert("|cFFFF2222v" .. k .. "|r |cff9CD6DE" .. nameString .. "|r |cFFA1A1A1(out of date)|r\n");
				else
					NRCVersionFrame.EditBox:Insert("|cFF00FF00v" .. k .. "|r |cff9CD6DE" .. nameString .. "|r\n");
				end
			end
		end
	end
	if (not foundHelper) then
		NRCVersionFrame.EditBox:Insert("No players in group with helper found.|r\n");
	end
	if (next(group)) then
		NRCVersionFrame.EditBox:Insert("\n|cFFFFAE42[Nothing Installed]|r\n");
		for k, v in NRC:pairsByKeys(group) do
			local nameString;
			--local class = NRC:getClassFromName(k);
			--if (class) then
			--	local _, _, _, classHex = NRC.getClassColor(class);
			--	nameString = "|c" .. classHex .. k .. "|r";
			--else
			--	nameString = k;
			--end
			NRCVersionFrame.EditBox:Insert("|cff9CD6DE" .. k .. "|r\n");
		end
	end
end