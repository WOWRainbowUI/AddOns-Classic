----------------------------------
---NovaRaidCompanion Group Cache--
----------------------------------
local addonName, NRC = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");

local firstGroupRosterUpdate = true;
local lastSendData = 0;
local units = NRC.units;
local UnitName = UnitName;
local UnitRace = UnitRace;
local UnitIsDead = UnitIsDead;
local GetNumGroupMembers = GetNumGroupMembers;
local GetRaidRosterInfo = GetRaidRosterInfo;
local strfind = strfind;
local strsplit = strsplit;
local IsInRaid = IsInRaid;
local UnitGUID = UnitGUID;
local pairs = pairs;
local GetNormalizedRealmName = GetNormalizedRealmName;
local tinsert = tinsert;
local cachedGetNormalizedRealmName;
local lastGroupJoin = 0;

function NRC:updateGroupCache()
	local group = {};
	local updated;
	local unitType = "party";
	if (IsInRaid()) then
		unitType = "raid";
	end
	local groupMembers = GetNumGroupMembers();
	for i = 1, groupMembers do
		local name, rank, subGroup, level, class, classEnglish, zone, online = GetRaidRosterInfo(i);
		local realm;
		if (name) then
			if (strfind(name, "-")) then
				--Record realm if they're from a different realm than ours.
				name, realm = strsplit("-", name, 2);
			end
			group[name] = {
				class = classEnglish,
				zone = zone,
				online = online,
				realm = realm,
				subGroup = subGroup,
			};
			if (level > 0) then
				--Level is 0 when offline, don't overwrite the level we already know.
				group[name].level = level;
			elseif (NRC.groupCache[name] and NRC.groupCache[name].level) then
				--Backup data from current cache if nothing returned (offline etc).
				group[name].level = NRC.groupCache[name].level;
			end
			if (zone ~= "Offline") then
				group[name].lastKnownZone = zone;
			end
			if (name == UnitName("player")) then
				group[name].guid = UnitGUID("player");
				group[name].unit = "player";
				local _, race = UnitRace("player");
				group[name].race = race;
				--I think it's better to just have player in the unit cache than have seperate lookups for player and group.
				NRC.unitMap[name] = {
					guid = UnitGUID("player"),
					unit = "player",
				};
			else
				for i = 1, groupMembers do
					local u = unitType .. i;
					local nameCheck = UnitName(u);
					if (nameCheck == name) then
						local guid = UnitGUID(u);
						if (guid) then
							group[name].guid = guid;
							group[name].unit = u;
							if (NRC.groupCache[name] and NRC.groupCache[name].race) then
								--Backup data from current cache if nothing returned (offline etc).
								group[name].race = NRC.groupCache[name].race;
							else
								local _, race = UnitRace(u);
								group[name].race = race;
							end
							NRC.unitMap[name] = {
								guid = guid,
								unit = u,
							};
						end
						break;
					end
				end
			end
		end
	end
	for k, v in pairs(group) do
		local groupCache = NRC.groupCache[k];
		if (v.level) then
			if (groupCache and groupCache.level ~= v.level) then
				NRC:groupMemberLevelUpdate(k, v);
			end
		end
		if (not groupCache) then
			--Player joined group.
			v.lastOnlineStatus = v.online;
			NRC.groupCache[k] = v;
			NRC:groupMemberJoined(k, v);
			updated = true;
		elseif(groupCache and v.online and not groupCache.lastOnlineStatus) then
			--Player came online.
			v.lastOnlineStatus = true;
			NRC.groupCache[k] = v;
			NRC:groupMemberOnline(k, v);
			updated = true;
		elseif (groupCache and not v.online and groupCache.lastOnlineStatus) then
			--Player went offline.
			v.lastOnlineStatus = nil;
			NRC.groupCache[k] = v;
			NRC:groupMemberOffline(k, v);
			updated = true;
		else
			v.lastOnlineStatus = v.online;
			NRC.groupCache[k] = v;
		end
		--[[if (not NRC.groupCache[k]) then
			--Player joined group.
			v.lastOnlineStatus = v.online;
			NRC.groupCache[k] = v;
			NRC:groupMemberJoined(k, v);
			updated = true;
		elseif(NRC.groupCache[k] and v.online and not NRC.groupCache[k].lastOnlineStatus) then
			--Player came online.
			v.lastOnlineStatus = true;
			NRC.groupCache[k] = v;
			NRC:groupMemberOnline(k, v);
			updated = true;
		elseif (NRC.groupCache[k] and not v.online and NRC.groupCache[k].lastOnlineStatus) then
			--Player went offline.
			v.lastOnlineStatus = nil;
			NRC.groupCache[k] = v;
			NRC:groupMemberOffline(k, v);
			updated = true;
		else
			v.lastOnlineStatus = v.online;
			NRC.groupCache[k] = v;
		end]]
	end
	for k, v in pairs(NRC.groupCache) do
		if (not group[k]) then
			--Player left group.
			NRC.groupCache[k] = nil;
			NRC:groupMemberLeft(k, v);
			updated = true;
		end
	end
	if (updated) then
		NRC:groupRosterChanged();
	end
end

local function updateUnitDeadState(unit)
	if (units[unit]) then
		local name, realm = UnitName(unit);
		if (realm and realm ~= "" and realm ~= NRC.realm) then
			name = name .. "-" .. realm;
		end
		local dead = UnitIsDead(unit);
		if (dead == false) then
			--Replicate GetRaidRosterInfo() behavior.
			dead = nil;
		end
		if (NRC.groupCache[name]) then
			NRC.groupCache[name].isDead = dead;
		end
	end
end

local function removeFromUnitMap(who)
	if (who) then
		for k, v in pairs(NRC.unitMap) do
			if (v.guid == who or k == who) then
				NRC.unitMap[k] = nil;
			end
		end
	end
end

function NRC:groupMemberJoined(name, data)
	if (not data or not data.guid) then
		--There can be no data on certain occasions like BG's etc.
		return;
	end
	--print(name, "joined group")
	NRC.auraCache[data.guid] = {};
	C_Timer.After(5, function()
		NRC:aurasScanGroup();
	end)
	NRC:loadRaidCooldownChar(name, data);
	--Has to be seperately and not inside loadRaidCooldownChar to avoid creating a endless loop.
	--NRC:loadPartyNeckBuffs();
	if (_G["NRCRaidStatusFrame"]) then
		C_Timer.After(0.5, function()
			NRC:updateRaidStatusFrames(true);
		end)
	end
	NRC:throddleEventByFunc("GROUP_ROSTER_UPDATE", 1, "updateHealerCache", "groupMemberJoined");
	NRC:inspect(data.guid);
end

function NRC:groupMemberLeft(name, data)
	if (not data or not data.guid) then
		--There can be no data on certain occasions like BG's etc.
		return;
	end
	--print(name, "left group")
	--NRC.cooldownList[data.guid] = nil;
	NRC.auraCache[data.guid] = nil;
	NRC.chronoCache[data.guid] = nil;
	NRC.durability[name] = nil;
	NRC.equipCache[name] = nil;
	--NRC:clearInspectdata(data.guid, name);
	NRC:removeRaidManaChar(name);
	NRC:removeFromManaCache(name);
	NRC:removeRaidCooldownChar(data.guid);
	NRC:soulstoneRemovedByLeave(name);
	removeFromUnitMap(data.guid);
	NRC:throddleEventByFunc("GROUP_ROSTER_UPDATE", 1, "updateHealerCache", "groupMemberLeft");
	--Has to be seperately and not inside removeRaidCooldownChar to avoid creating a endless loop.
	--NRC:loadPartyNeckBuffs();
	if (_G["NRCRaidStatusFrame"]) then
		C_Timer.After(0.5, function()
			NRC:updateRaidStatusFrames(true);
		end)
		if (_G["NRCRaidStatusFrame"]:IsShown()) then
			C_Timer.After(2, function()
				NRC:updateRaidStatusFrames(true);
			end)
		end
	end
end

function NRC:groupMemberOnline(name, data)
	if (GetTime() - lastGroupJoin < 1) then
		return;
	end
	--print(name, "came online")
	NRC:updateSoulstoneDurations();
	if (NRC.config.sreOnlineStatus) then
		NRC:sreOnlineStatusEvent(name, data.class, true);
	end
end

function NRC:groupMemberOffline(name, data)
	if (GetTime() - lastGroupJoin < 1) then
		return;
	end
	--print(name, "went offline")
	if (NRC.config.sreOnlineStatus) then
		NRC:sreOnlineStatusEvent(name, data.class);
	end
end

function NRC:groupMemberDied(name, data)
	--print(name, "died")
end

function NRC:groupMemberReleased(name, data)
	--print(name, "released")
end

function NRC:groupMemberLevelUpdate(name, data)
	NRC:removeRaidCooldownChar(data.guid);
	NRC:loadRaidCooldownChar(name, data);
	--NRC:debug(name .. " level change")
end

function NRC:groupRosterChanged()
	--print("roster updated")
	NRC:updateRaidCooldowns();
end

local function normalizeNameRealm(msg)
	msg = string.gsub(msg, " ", "");
	msg = string.gsub(msg, "'", "");
	return msg;
end

--Acepts guid or name.
function NRC:inOurGroup(who)
	if (not who) then
		return;
	end
	local isGuid;
	if (strfind(who, "%-.+%-")) then
		isGuid = true;
	end
	if (isGuid) then
		--Check for guid match.
		if (who == UnitGUID("player")) then
			return true;
		end
		for k, v in pairs(NRC.groupCache) do
			if (v.guid == who) then
				return true;
			end
		end
	else
		if (NRC.groupCache[who]) then
			return true;
		end
		if (strfind(who, "-")) then
			--Realm was included in the query so attach realms if they don't exist in group cache.
			--No realms means they are on our realm.
			for k, v in pairs(NRC.groupCache) do
				if (not strfind(k, "-")) then
					k = k .. "-" .. (cachedGetNormalizedRealmName or GetNormalizedRealmName());
				end
				if (normalizeNameRealm(k) == normalizeNameRealm(who)) then
					return true;
				end
			end
		else
			--Check for for less reliable name only matches for group members from other realms.
			--Shouldn't ever really be used unless another piece of code isn't including correctly..
			--[[for k, v in pairs(NRC.groupCache) do
				local nameOnly = strsplit("-", k);
				if (nameOnly == who) then
					return true;
				end
			end]]
		end
	end
end

--Get guid from group member name, accepts name-realm.
--Also accepts just name (less reliable if they ever enable cross realm in tbc, but would be rare to have 2 same names in group).
--Checks class also if no realm is supplied to even further narrow down the right result.
function NRC:getGroupGuidFromName(name, class)
	--Full name.
	if (NRC.groupCache[name]) then
		return NRC.groupCache[name].guid;
	end
	--Check for for less reliable name only matches.
	for k, v in pairs(NRC.groupCache) do
		local nameOnly = strsplit("-", k);
		if (name == nameOnly and class == v.class) then
			return v.guid;
		end
	end
end

function NRC:getCharDataFromGUID(guid)
	for k, v in pairs(NRC.groupCache) do
		if (guid == v.guid) then
			return v;
		end
	end
	--If the above fails we're not in a group.
	if (guid == UnitGUID("player")) then
		local data = {
			guid = UnitGUID("player");
			unit = "player";	
		};
		local _, class = UnitClass("player");
		data.class = class;
		local _, race = UnitRace("player");
		data.race = race;
		data.level = UnitLevel("player");
		data.zone = GetRealZoneText();
		return data;
	end
end

function NRC:getNameFromGUID(guid)
	if (guid) then
		if (guid == UnitGUID("player")) then
			local name = UnitName("player");
			return name;
		end
		for k, v in pairs(NRC.groupCache) do
			if (guid == v.guid) then
				return k;
			end
		end
		local _, _, _, _, _, name = GetPlayerInfoByGUID(guid);
		return name;
	end
end

function NRC:getLevelFromGUID(guid)
	if (guid) then
		if (guid == UnitGUID("player")) then
			local name = UnitLevel("player");
			return name;
		end
		for k, v in pairs(NRC.groupCache) do
			if (guid == v.guid) then
				return v.level;
			end
		end
	end
end

function NRC:getLocalizedClassFromGUID(guid)
	if (guid) then
		if (guid == UnitGUID("player")) then
			local class = UnitClass("player");
			return class;
		end
		for k, v in pairs(NRC.groupCache) do
			if (guid == v.guid) then
				local class = UnitClass(v.unit);
				return class;
			end
		end
	end
end

--[[function NRC:getUnitFromGUID(guid)
	for k, v in pairs(NRC.groupCache) do
		if (guid == v.guid) then
			return v.unit;
		end
	end
end

function NRC:getUnitFromName(name)
	if (NRC.unitMap[name]) then
		return NRC.unitMap[name].unit;
	end
end]]

function NRC:getUnitFromGUID(guid)
	local unitType = "party";
	if (IsInRaid()) then
		unitType = "raid";
	end
	for i = 1, GetNumGroupMembers() do
		--local name, rank, subGroup, level, class, classEnglish, zone, online, isDead, role, loot = GetRaidRosterInfo(i);
		if (UnitGUID(unitType .. i) == guid) then
			return unitType .. i;
		end
	end
	if (UnitGUID("player") == guid) then
		return "player";
	end
	if (UnitGUID("target") == guid) then
		return "target";
	end
	if (UnitGUID("player") == guid) then
		return "focus";
	end
end

function NRC:getUnitFromName(name)
	local unitType = "party";
	if (IsInRaid()) then
		unitType = "raid";
	end
	for i = 1, GetNumGroupMembers() do
		if (UnitName(unitType .. i) == name) then
			return unitType .. i;
		end
	end
	if (UnitName("player") == name) then
		return "player";
	end
	if (UnitName("target") == name) then
		return "target";
	end
	if (UnitName("player") == name) then
		return "focus";
	end
end

function NRC:getClassFromName(who)
	if (who) then
		if (who == UnitName("player")) then
			local _, class = UnitClass("player");
			return class;
		end
		local name, realm;
		if (strmatch(who, "%-")) then
			name, realm = strsplit(who, "-")'';
		end
		--Check full name-realm first (if realm specified).
		for k, v in pairs(NRC.groupCache) do
			if (k == who) then
				return v.class;
			end
		end
		--Check just name after if above fails.
		for k, v in pairs(NRC.groupCache) do
			if (k == name) then
				return v.class;
			end
		end
	end
end

function NRC:updateHealerCache(func)
	local oldHealerCache = NRC.healerCache;
	local newHealer, removedHealer;
	NRC.healerCache = {};
	for k, v in pairs(NRC.talents) do
		local _, _, specName, specIcon, _, _, class = NRC:getSpecFromTalentString(v);
		if (specName and NRC:inOurGroup(k)) then
			if (NRC.healingSpecs[specName]) then
				local t = {
					name = k,
					specName = specName,
					icon = specIcon,
					class = class,
				};
				tinsert(NRC.healerCache, t);
			end
		end
	end
	if (NRC.specialHealers) then
		for k, v in pairs(NRC.specialHealers) do
			local t = {
				name = k,
				specName = v.specName,
				icon = v.icon,
				class = v.class,
			};
			tinsert(NRC.healerCache, t);
		end
	end
	
	for k, v in pairs(NRC.healerCache) do
		local found;
		for kk, vv in pairs(oldHealerCache) do
			if (v.name == vv.name) then
				found = true;
			end
		end
		if (not found) then
			newHealer = true;
			NRC:debug("New healer found:", v.name);
		end
	end
	for k, v in pairs(oldHealerCache) do
		local found;
		for kk, vv in pairs(NRC.healerCache) do
			if (v.name == vv.name) then
				found = true;
			end
		end
		if (not found) then
			removedHealer = true;
			NRC:debug("Removed healer:", v.name);
		end
	end
	table.sort(NRC.healingSpecs, function(a, b)
		return a.class < b.class
			or a.class == b.class and strcmputf8i(a.name, b.name) < 0;
	end)
	if (newHealer or removedHealer) then
		NRC:throddleEventByFunc("GROUP_ROSTER_UPDATE", 2, "loadTrackedManaChars", func or "updateHealerCache");
	end
	--NRC:debug("Healer Cache:", func);
end

function NRC:isHealer(name)
	for k, v in pairs(NRC.healerCache) do
		if (v.name == name) then
			return true;
		end
	end
end

local f = CreateFrame("Frame");
f:RegisterEvent("GROUP_ROSTER_UPDATE");
f:RegisterEvent("GROUP_FORMED");
f:RegisterEvent("GROUP_JOINED");
f:RegisterEvent("GROUP_LEFT");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("UNIT_FLAGS");
f:RegisterEvent("UNIT_CONNECTION");
f:SetScript('OnEvent', function(self, event, ...)
	if (event == "UNIT_FLAGS") then
		local unit = ...;
		--if (strfind(unit, "party") or strfind(unit, "raid")) then
		--	NRC:throddleEventByFunc(event, 1, "updateGroupCache", ...);
		--end
		updateUnitDeadState(unit);
	elseif (event == "GROUP_ROSTER_UPDATE" or event == "GROUP_FORMED" or event == "GROUP_JOINED"
		or event == "PLAYER_ENTERING_WORLD") then
		firstGroupRosterUpdate = nil;
		C_Timer.After(0.5, function()
			NRC:updateGroupCache();
		end);
		if (event == "PLAYER_ENTERING_WORLD") then
			local isLogon, isReload = ...;
			if (isReload and IsInGroup()) then
				NRC:throddleEventByFunc(event, 1, "loadGroupMana", ...);
				NRC:throddleEventByFunc(event, 2, "updateHealerCache", "PLAYER_ENTERING_WORLD");
			end
			if (not cachedGetNormalizedRealmName and GetNormalizedRealmName()) then
				cachedGetNormalizedRealmName = GetNormalizedRealmName();
			end
		end
		if (event == "GROUP_FORMED" or event == "GROUP_JOINED") then
			--Note: These events don't trigger on reload only login and when joining a group.
			--Sometimes we get both these events so have a cooldown to not send data twice.
			if (GetTime() - lastSendData > 2 and GetNumGroupMembers() > 1) then
				lastSendData = GetTime();
				lastGroupJoin = GetTime();
				--NRC:throddleEventByFunc(event, 5, "requestData", ...);
				NRC:throddleEventByFunc(event, 1, "loadGroupMana", ...);
				NRC:throddleEventByFunc(event, 2, "updateHealerCache", "GROUP_JOINED");
			end
		end
		if (event == "GROUP_ROSTER_UPDATE") then
			if (_G["NRCRaidStatusFrame"] and _G["NRCRaidStatusFrame"]:IsShown()) then
				C_Timer.After(1, function()
					NRC:updateRaidStatusFrames(true);
				end)
			end
		end
	elseif (event == "PLAYER_LOGIN") then
		--Roster data seems to be unreliable at logon, run it again after a short while.
		C_Timer.After(20, function()
			NRC:updateGroupCache();
		end);
		NRC.logonTime = GetServerTime();
	elseif (event == "UNIT_CONNECTION") then
		local unit = ...;
		if (strfind(unit, "party") or strfind(unit, "raid")) then
			C_Timer.After(0.5, function()
				NRC:updateGroupCache();
			end);
		end
	elseif (event == "GROUP_LEFT") then
		NRC.groupCache = {};
		NRC.unitMap = {};
		C_Timer.After(1, function()
			NRC:aurasScanGroup();
		end)
		C_Timer.After(0.2, function()
			NRC:updateHealerCache();
		end)
	end
end)