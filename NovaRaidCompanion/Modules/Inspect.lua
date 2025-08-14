------------------------------
---NovaRaidCompanion Inspect--
------------------------------

local addonName, NRC = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");
local sanctifiedString = L["Sanctified"];
local uniformString = L["Scarlet Uniform"];
local tonumber = tonumber;
local GetItemInfo = GetItemInfo or C_Item.GetItemInfo;
local GetItemGem = GetItemGem or C_Item.GetItemGem;
local GetItemNumSockets = C_Item.GetItemNumSockets;
local GetItemNumAddedSockets = C_Item.GetItemNumAddedSockets;
local isSOD = NRC.isSOD;
local isMOP = NRC.isMOP;
local expansionNum = NRC.expansionNum;
local strmatch = strmatch;
local isTierTalents = NRC.isTierTalents;
local talentRowCount = NRC.talentRowCount;

local enchantNames = {};
NRC.gearCache = {};
NRC.runesCache = {};
NRC.sanctifiedCache = {};
NRC.enchantsCache = {};
NRC.issuesCache = {};
NRC.setBonuses = {};
local inspectAgainQueue = {};
local currentInspectGUID;
local cachingIssues = {};
local inspectSlotCount = 0;
local checkBeltBuckle = expansionNum > 2 and expansionNum < 6;
local checkGems = GetItemGem and GetItemNumSockets;

local inspectSlots = {
	[1] = "HeadSlot",
	[2] = "NeckSlot",
	[3] = "ShoulderSlot",
	[15] = "BackSlot",
	[5] = "ChestSlot",
	[4] = "ShirtSlot",
	[19] = "TabardSlot",
	[9] = "WristSlot",
	[10] = "HandsSlot",
	[6] = "WaistSlot",
	[7] = "LegsSlot",
	[8] = "FeetSlot",
	[11] = "Finger0Slot",
	[12] = "Finger1Slot",
	[13] = "Trinket0Slot",
	[14] = "Trinket1Slot",
	[16] = "MainHandSlot",
	[17] = "SecondaryHandSlot",
	[18] = "RangedSlot",
};
if (expansionNum > 4) then
	--Ranged slot removed in MoP.
	inspectSlots[18] = nil;
	--Any changes here need to be changed in updateIssuesCache() also.
end
for k, v in pairs(inspectSlots) do
	--Ignore shirt and trinket they're often empty.
	if (k ~= 4 and k ~= 19) then
		inspectSlotCount = inspectSlotCount + 1;
	end
end
local lowInspectSlotCount = inspectSlotCount - 2;

local enchantSlots = {
	[1] = true, --Head.
	[3] = true, --Shoulders.
	[5] = true, --Chest.
	[7] = true, --Legs.
	[8] = true, --Feet.
	[9] = true, --Wrist.
	[10] = true, --Hands.
	[15] = true, --Back.
	[16] = true, --Main hand.
};
if (NRC.isSOD) then
	enchantSlots[17] = true; --Off hand.
end
if (expansionNum > 4) then
	enchantSlots[1] = nil; --Helm enchant removed in MoP.
end
if (expansionNum > 5) then
	enchantSlots[11] = true; --Rings in wod+? (wrath+ for enchanters but we ignoire that).
	enchantSlots[12] = true;
end
NRC.enchantSlots = enchantSlots;

local sanctifiedSlots = {
	--No weapons or relics yet?
	[1] = true,
	[2] = true,
	[3] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[8] = true,
	[9] = true,
	[10] = true,
	[11] = true,
	[12] = true,
	[13] = true,
	[14] = true,
	[15] = true
};

local scarletUniform
--This was changed to use file locales.
--[[local sanctifiedLocalizations = {
	["Sanctified"] = true,
	["Santificar"] = true, --es.
	["Santificado"] = true, --mx.
	["Geweiht"] = true, --de.
	["Sanctifié"] = true, --fr.
	--[""] = true, --it.
	["축성"] = true, --ko.
	["Santificado"] = true, --pt.
	["Освященный предмет"] = true, --ru.
	["灵巧护链"] = true, --cn.
	[""] = true, --tw.
};]]

local tooltipScanner = CreateFrame("GameTooltip", "NRCSanctifiedTooltipScanner", nil, "GameTooltipTemplate");
tooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE");
local tooltipLines = {
	--We need to scan multiple lines, some addons push the line down a few slots.
	[1] = NRCSanctifiedTooltipScannerTextLeft2,
	[2] = NRCSanctifiedTooltipScannerTextLeft3,
	[3] = NRCSanctifiedTooltipScannerTextLeft4,
};
local function getSanctifiedCount(guid)
	--Inspiration here taken from a couple of different weakauras, thanks to the authors.
	if (not NRC.gearCache[guid]) then
		return;
	end
	local count = 0;
	local bonusSetCount = 0;
	for k, v in pairs(NRC.gearCache[guid]) do
		if (sanctifiedSlots[k]) then
            tooltipScanner:SetHyperlink(v.itemLink);
            for _, tooltipLine in ipairs(tooltipLines) do
	            local text = tooltipLine:GetText();
	            if (text) then
	            	--It should be the same color always for all locales?
	            	--text = strmatch(text, "|cFF34FDF0(%w+)|r"); --This doesn't match accented european characters.
	            	local t = strmatch(text, "|cFF34FDF0(.+)|r");
	            	--if (t and sanctifiedLocalizations[text]) then
	            	if (t and t == sanctifiedString) then
		                count = count + 1;
		                --Check Chest/Wrist/Gloves for bonus set.
		                if (k == 5 or k == 9 or k == 10) then
		                    local setID = select(16, GetItemInfo(v.itemLink));
		                    if (setID and setID >= 1905 and setID <= 1918) then
								bonusSetCount = bonusSetCount + 1;
							end
		                end
		                break;
	                end
	                t = strmatch(text, "|cFFEC6340(.+)|r");
	            	if (t and t == uniformString) then
		                count = count + 1;
		                break;
	                end
	            end
            end
	    end
    end
    --If 2 set is equiped of the bonus gear from invasions.
	if (bonusSetCount > 1) then
	   count = count + 2;
	end
	return count;
end
function NRC:getSanctifiedCount(guid)
	return getSanctifiedCount(guid);
end

local enchantTooltipScanner = CreateFrame("GameTooltip", "NRCEnchantTooltipScanner", nil, "GameTooltipTemplate");
enchantTooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE");
--There are only 8 lines created for a tooltip until somehting id displayed and it adds more as needed.
--So trying to insert more than 8 lines to our table before anything with more lines has been added means we don't scan more than 8.
local enchantTooltipLines = {};
for i = 1, 8 do
	tinsert(enchantTooltipLines, _G["NRCEnchantTooltipScannerTextLeft" .. i]);
end

local function getEnchantName(itemLink)
	if (itemLink) then
		local _, _, enchantID = strsplit(":", itemLink);
		if (enchantNames[enchantID]) then
			return enchantNames[enchantID];
		end
		if (#enchantTooltipLines == 8) then
			--If we only have 8 lines recorded then it's the first scan after logon and we need to set an item to so more exist and we can save them for scanning.
			enchantTooltipLines = {};
			enchantTooltipScanner:SetHyperlink(itemLink);
			enchantTooltipScanner:ClearLines();
			for i = 1, 20 do
				tinsert(enchantTooltipLines, _G["NRCEnchantTooltipScannerTextLeft" .. i]);
			end
		end
		local enchantName;
		local unenchantedItemLink = gsub(itemLink, "item:(%d+):(%d+):", "item:%1::");
		local originalLines = {};
		enchantTooltipScanner:ClearLines();
		enchantTooltipScanner:SetHyperlink(unenchantedItemLink);
		for _, tooltipLine in ipairs(enchantTooltipLines) do
		    local text = tooltipLine:GetText();
		    local r, b, g = tooltipLine:GetTextColor();
		    if (text) then
		    	--Check green lines only, sometimes an enchant might be the exact same text as an item's white stats line (like +16 int enchant on sapphiron's right eye).
		    	local r, g, b = tooltipLine:GetTextColor();
		    	--if (r == 0 and g == 1 and b == 0) then
		    	--Changed to check everything non-white instead, dk runes and possibly some other stuff isn't green.
		    	if (r ~= 1 or g ~= 1 or b ~= 1) then
		    		originalLines[text] = true;
		    	end
		    end
		end
		enchantTooltipScanner:ClearLines();
		enchantTooltipScanner:SetHyperlink(itemLink);
		for line, tooltipLine in ipairs(enchantTooltipLines) do
		    local text = tooltipLine:GetText();
		    local r, g, b = tooltipLine:GetTextColor();
		   -- if (r == 0 and g == 1 and b == 0) then
		    if (r ~= 1 or g ~= 1 or b ~= 1) then
			    if (text and not originalLines[text]) then
			    	enchantName = text;
			    	break;
				end
			end
		end
		enchantNames[enchantID] = enchantName;
		return enchantName;
	end
end
function NRC:getEnchantName(itemLink)
	return getEnchantName(itemLink);
end

function NRC:getAverageItemLevel(guid, decimal)
	local averageItemLevel = 0;
	if (guid) then
		--Slots we use for average ilvl calc.
		local slots = {
			[1] = "HeadSlot",
			[2] = "NeckSlot",
			[3] = "ShoulderSlot",
			[15] = "BackSlot",
			[5] = "ChestSlot",
			--[4] = "ShirtSlot",
			--[19] = "TabardSlot",
			[9] = "WristSlot",
			[10] = "HandsSlot",
			[6] = "WaistSlot",
			[7] = "LegsSlot",
			[8] = "FeetSlot",
			[11] = "Finger0Slot",
			[12] = "Finger1Slot",
			[13] = "Trinket0Slot",
			[14] = "Trinket1Slot",
			[16] = "MainHandSlot",
			[17] = "SecondaryHandSlot",
			[18] = "RangedSlot",
		};
		if (expansionNum > 4) then
			--Ranged slot removed in MoP.
			slots[18] = nil;
		end
		local numSlots = 0;
		local data = NRC.gearCache[guid];
		if (data) then
			if (data[16]) then
				local _, _, _, _, _, _, _, _, equipLoc = C_Item.GetItemInfo(data[16].itemLink);
				if (equipLoc == "INVTYPE_2HWEAPON" or ((equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_RANGED") and expansionNum > 4)) then
					--If two hander equipped we ignore offhand.
					slots[17] = nil;
				end
			end
			for k, v in pairs(slots) do
				numSlots = numSlots + 1;
				if (data[k]) then
					local item = Item:CreateFromItemLink(data[k].itemLink);
					if (item) then
						local itemLevel = item:GetCurrentItemLevel();
						if (itemLevel and itemLevel > 0) then
							averageItemLevel = averageItemLevel + itemLevel;
						end
					end
				end
			end
			if (averageItemLevel > 0) then
				averageItemLevel = averageItemLevel / numSlots;
			end
		end
	end
	return NRC:round(averageItemLevel, decimal or 1);
end

local fallbackCache = {};
local function fallbackUpdate(guid, unit)
	if (fallbackCache[guid]) then
		for k, v in pairs(fallbackCache[guid]) do
			local item = Item:CreateFromItemID(v);
			if (item and not item:IsItemEmpty()) then
				item:ContinueOnItemLoad(function()
					local itemLink = item:GetItemLink();
					if (itemLink) then
						if (not NRC.gearCache[guid]) then
							NRC.gearCache[guid] = {};
						end
						--if (unit ~= "player") then
						--	NRC:debug("added gear from inspect", UnitName(unit), itemLink);
						--end
						NRC.gearCache[guid][k] = {
							itemLink = itemLink,
							skipEnchantCheck = true, --Don't check for enchant if we only have a generic itemLink and not the actual equipped itemLink.
							skipGemCheck = true,
						};
						NRC.gearCache[guid].updated = GetServerTime();
					--else
						--NRC:debug("no itemlink found", v)
					end
					if (fallbackCache[guid]) then
						fallbackCache[guid][k] = nil;
					end
					if (not fallbackCache[guid]) then
						C_Timer.After(1.5, function()
							NRC:updateSetBonusCache(guid);
							NRC:updateEnchantsCache(guid);
							if (isSOD) then
								NRC.sanctifiedCache[guid] = getSanctifiedCount(guid);
							end
							NRC:updateIssuesCache(guid);
						end);
					elseif (not next(fallbackCache[guid])) then
						--if (unit ~= "player") then
							--NRC:debug("gear fail inspect complete", UnitName(unit));
						--end
						NRC:updateSetBonusCache(guid);
						NRC:updateEnchantsCache(guid);
						if (isSOD) then
							NRC.sanctifiedCache[guid] = getSanctifiedCount(guid);
						end
						NRC:updateIssuesCache(guid);
						fallbackCache[guid] = nil;
					end
				end)
			end
		end
	end
end

--if got id but missing link then add bare itemlinks and create list to oncontinue
-- then try update all from oncontinue (if unit is still inspectable)
function NRC:buildInventoryFromInspect(guid, unit, secondTry)
	--Don't use this for now, we don't want to keep inspecting for gear changes so it would be unreliable.
	if (guid and not unit) then
		unit = NRC:getUnitFromGUID(guid);
		if (not unit) then
			if (InspectFrame and InspectFrame.unit) then
				unit = InspectFrame.unit;
			end
		end
	end
	if (unit and guid) then
		if (not NRC:inOurGroup(guid)) then
			return;
		end
		--local equipCount = 0;
		local errorNum = 0;
		local updated;
		local cachingIssueFound;
		local gear = {};
		fallbackCache[guid] = nil;
		for k, v in pairs(inspectSlots) do
			local itemID = GetInventoryItemID(unit, k);
			if (itemID) then
				local name = GetItemInfo(itemID);
			end
			local itemLink = GetInventoryItemLink(unit, k);
			if (itemID and not itemLink and unit ~= "player") then
				--NRC:debug("got itemID but not itemlink from inspect", UnitName(unit), itemID);
				cachingIssueFound = true;
				errorNum = errorNum + 1;
				if (not fallbackCache[guid]) then
					fallbackCache[guid] = {};
				end
				fallbackCache[guid][k] = itemID;
			end
			if (itemLink) then
				--if (unit ~= "player") then
					--NRC:debug("added gear from inspect", UnitName(unit), itemLink);
				--end
				gear[k] = {
					itemLink = itemLink;
				};
				if (GetItemGem and GetItemNumSockets) then
					local gemCount = GetItemNumSockets(itemLink);
					--if (k == 6) then
					--	print(1, UnitName(unit), gemCount)
					--end
					--if (gemCount and gemCount > 0) then
					if (gemCount) then
						gear[k].gems = {
							sockets = gemCount,
						};
						local equipped = 0;
						if (k == 6 and checkBeltBuckle) then
							--GetItemNumSockets() does not include a belt buckle socket so we can use this to check if a buckle is on the gear.
							for slot = 1, gemCount do
								local _, gemLink = GetItemGem(itemLink, slot);
								if (gemLink) then
									local _, _, _, _, _, _, color = C_Item.GetItemInfo(gemLink)
									local t = {
										itemLink = gemLink;
										color = color,
									};
									tinsert(gear[k].gems, t);
									equipped = equipped + 1;
									--print(C_Item.GetItemInfo(gemLink))
								end
							end
							--Check extra slot for belt buckle.
							local _, gemLink = GetItemGem(itemLink, gemCount + 1);
							--print(UnitName(unit), gemCount, gemLink)
							if (gemLink) then
								gear[k].hasBeltBuckle = true;
							else
								--If no gemLink is found we need to add tooltip scaning here to check for the empty gem socket texture.
							end
						else
							for slot = 1, gemCount do
								local _, gemLink = GetItemGem(itemLink, slot);
								if (gemLink) then
									local _, _, _, _, _, _, color = C_Item.GetItemInfo(gemLink)
									local t = {
										itemLink = gemLink;
										color = color,
									};
									tinsert(gear[k].gems, t);
									equipped = equipped + 1;
								end
							end
						end
						gear[k].gems.equipped = equipped;
					end
				end
				--equipCount = equipCount + 1;
				updated = true;
			end
		end
		if (updated) then
			NRC.gearCache[guid] = gear;
			NRC.gearCache[guid].updated = GetServerTime();
		end
		if (not secondTry) then
			C_Timer.After(0.5, function()
				if (currentInspectGUID == guid) then
					NRC:buildInventoryFromInspect(guid, unit, true);
				end
			end)
		end
		C_Timer.After(1, function()
			NRC:updateSetBonusCache(guid);
			NRC:updateEnchantsCache(guid);
			if (isSOD) then
				NRC.sanctifiedCache[guid] = getSanctifiedCount(guid);
			end
			NRC:updateIssuesCache(guid);
		end)
		--if (equipCount < 12 and guid ~= UnitGUID("player")) then
			--There seems to be a bug where not all items load.
			--Not sure if it's becaus I need to continue on load or some other issue.
			--Probably not a cache issue with GetInventoryItemLink() becaus INSPECT_READY fires before this?
			--Until I fix it I'll just reschedule another inspect in 10 seconds, or again in 30 if we've tried once already.
		--	if (inspectAgainQueue[guid]) then
		--		C_Timer.After(30, function()
		--			NRC:debug("Low armor count, requeueing inspect for:", UnitName(unit), equipCount, 30);
		--			NRC:inspect(guid);
		--		end);
		--	else
		--		inspectAgainQueue[guid] = true;
		--		C_Timer.After(10, function()
		--			NRC:debug("Low armor count, requeueing inspect for:", UnitName(unit), equipCount, 10);
		--			NRC:inspect(guid);
		--		end);
		--	end
		--end
		if (cachingIssueFound and not cachingIssues[guid]) then
			cachingIssues[guid] = true;
			--There seems to be a bug where not all item links load, but the itemID does.
			--This must be a cache issue and there's no way around it while inspecting other people that I could find.
			--ContinueOnLoad and then querying the slot was not foolproof either.
			--Reschedule another inspect in 2 seconds, or again in 30 if we've tried once already.
			if (inspectAgainQueue[guid]) then
				--NRC:debug("Caching issue found, requeueing inspect for:", UnitName(unit), errorNum, 30);
				C_Timer.After(30, function()
					NRC:inspect(guid);
				end);
				inspectAgainQueue[guid] = nil;
			else
				inspectAgainQueue[guid] = true;
				--NRC:debug("Caching issue found, requeueing inspect for:", UnitName(unit), errorNum, 2);
				C_Timer.After(2, function()
					NRC:inspect(guid, true);
				end);
				C_Timer.After(31, function()
					inspectAgainQueue[guid] = nil;
				end);
			end
			fallbackUpdate(guid, unit);
		end
		if (not cachingIssueFound) then
			cachingIssues[guid] = nil;
			inspectAgainQueue[guid] = nil;
		end
		--NRC:debug("equip inspect complete", UnitName(unit));
	end
end

--This older version almost mostly worked, leaving it here for now.
--[[function NRC:buildInventoryFromInspect(guid, unit, secondTry)
	--Don't use this for now, we don't want to keep inspecting for gear changes so it would be unreliable.
	if (guid and not unit) then
		unit = NRC:getUnitFromGUID(guid);
		if (not unit) then
			if (InspectFrame and InspectFrame.unit) then
				unit = InspectFrame.unit;
			end
		end
	end
	if (unit and guid) then
		if (not NRC:inOurGroup(guid)) then
			return;
		end
		--local equipCount = 0;
		local errorNum = 0;
		--local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(guid);
		--local nameRealm = name .. "-" ..  realm;
		--NRC.gearCache[guid] = nil;
		local updated;
		local cachingIssueFound;
		local gear = {};
		for k, v in pairs(inspectSlots) do
			local itemID = GetInventoryItemID(unit, k);
			if (itemID) then
				local name = GetItemInfo(itemID);
			end
			local itemLink = GetInventoryItemLink(unit, k);
			--if (not itemLink) then
				--run loads and wait then rebuild cache
				
				--add bare link from itemid without enchant if itemlink not found, and ignore that slot from showing missing enchant by addong id as 1 or something
				--the try inspect again in a few seconds
			--end
			if (itemID and not itemLink and unit ~= "player") then
				NRC:debug("got itemID but not itemlink from inspect", UnitName(unit), itemID);
				cachingIssueFound = true;
				errorNum = errorNum + 1;
			end
			if (itemLink) then
				--if (not NRC.gearCache[guid]) then
				--	NRC.gearCache[guid] = {};
				--end
				--if (unit ~= "player") then
					--NRC:debug("added gear from inspect", UnitName(unit), itemLink);
				--end
				--NRC.gearCache[guid][k] = itemLink;
				gear[k] = itemLink;
				--NRC:printRaw(itemLink)
				--equipCount = equipCount + 1;
				updated = true;
			end
		end
		if (updated) then
			--NRC.gearCache[guid] = nil;
			NRC.gearCache[guid] = gear;
			NRC.gearCache[guid].updated = GetServerTime();
		end
		if (not secondTry) then
			C_Timer.After(0.5, function()
				if (currentInspectGUID == guid) then
					NRC:buildInventoryFromInspect(guid, unit, true);
				end
			end)
			--C_Timer.After(1, function()
			--	NRC:updateSetBonusCache(guid);
			--	NRC:updateEnchantsCache(guid);
			--	if (isSOD) then
			--		NRC.sanctifiedCache[guid] = nil;
			--		NRC.sanctifiedCache[guid] = getSanctifiedCount(guid);
			--	end
			--	NRC:updateIssuesCache(guid);
			--end)
		end
		C_Timer.After(1, function()
			NRC:updateSetBonusCache(guid);
			NRC:updateEnchantsCache(guid);
			if (isSOD) then
				NRC.sanctifiedCache[guid] = nil;
				NRC.sanctifiedCache[guid] = getSanctifiedCount(guid);
			end
			NRC:updateIssuesCache(guid);
		end)
		--if (equipCount < 12 and guid ~= UnitGUID("player")) then
			--There seems to be a bug where not all items load.
			--Not sure if it's becaus I need to continue on load or some other issue.
			--Probably not a cache issue with GetInventoryItemLink() becaus INSPECT_READY fires before this?
			--Until I fix it I'll just reschedule another inspect in 10 seconds, or again in 30 if we've tried once already.
		--	if (inspectAgainQueue[guid]) then
		--		C_Timer.After(30, function()
		--			NRC:debug("Low armor count, requeueing inspect for:", UnitName(unit), equipCount, 30);
		--			NRC:inspect(guid);
		--		end);
		--	else
		--		inspectAgainQueue[guid] = true;
		--		C_Timer.After(10, function()
		--			NRC:debug("Low armor count, requeueing inspect for:", UnitName(unit), equipCount, 10);
		--			NRC:inspect(guid);
		--		end);
		--	end
		--end
		if (cachingIssueFound and not cachingIssues[guid]) then
			cachingIssues[guid] = true;
			--There seems to be a bug where not all item links load, but the itemID does.
			--Thsis much be a cachie issues and there's no way around it while specting other people that I could find.
			--Reschedule another inspect in 2 seconds, or again in 30 if we've tried once already.
			if (inspectAgainQueue[guid]) then
				C_Timer.After(30, function()
					NRC:debug("Caching issue found, requeueing inspect for:", UnitName(unit), errorNum, 30);
					NRC:inspect(guid);
				end);
			else
				inspectAgainQueue[guid] = true;
				C_Timer.After(2, function()
					NRC:debug("Caching issue found, requeueing inspect for:", UnitName(unit), errorNum, 2);
					NRC:inspect(guid, true);
				end);
			end
		end
		if (not cachingIssueFound) then
			cachingIssues[guid] = nil;
		end
		--NRC:debug("equip inspect complete", UnitName(unit));
	end
end]]

hooksecurefunc("ClearInspectPlayer", function(...)
	currentInspectGUID = nil;
	--print("inspect end");
end);

function NRC:buildMyInventoryFromInspect()
	NRC:buildInventoryFromInspect(UnitGUID("player"), "player");
end

function NRC:updateEnchantsCache(guid)
	NRC.enchantsCache[guid] = nil;
	if (NRC.gearCache[guid]) then
		local equip = NRC.gearCache[guid];
		for slot, v in pairs(equip) do
			if (enchantSlots[slot]) then
				local _, _, enchantID = strsplit(":", v.itemLink);
				if (enchantID) then
					local enchantName = NRC:getEnchantName(v.itemLink);
					if (not NRC.enchantsCache[guid]) then
						NRC.enchantsCache[guid] = {};
					end
					NRC.enchantsCache[guid][slot] = enchantName or tonumber(enchantID);
				end
			end
		end
	end
	NRC:getEnchantsData(guid)
end

function NRC:getEnchantsData(guid)
	if (NRC.enchantsCache[guid]) then
		local enchants, missingEnchants = {}, {};
		local data = NRC.enchantsCache[guid];
		local gearData = NRC.gearCache[guid];
		for slot, _ in pairs(enchantSlots) do
			if (data[slot]) then
				local t = {
					slot = slot,
					name = data[slot]
				};
				tinsert(enchants, t);
			elseif (gearData[slot] and not gearData[slot].skipEnchantCheck) then
				--Only count a missing slot if something is equipped in that slot.
				local t = {
					slot = slot,
				};
				tinsert(missingEnchants, t);
			end
		end
		--NRC:debug(enchants)
		--NRC:debug(missingEnchants)
		return enchants, missingEnchants;
	end
end

function NRC:getGemsData(guid)
	if (NRC.gearCache[guid]) then
		local sockets, equipped = 0, 0;
		local data = NRC.gearCache[guid];
		local gearData = NRC.gearCache[guid];
		for slot, slotData in pairs(gearData) do
			if (type(slotData) == "table" and slotData.gems) then
				equipped = equipped + slotData.gems.equipped
				sockets = sockets + slotData.gems.sockets;
			end
		end
		return sockets, sockets - equipped;
	end
end

function NRC:getGlyphsData(name)
	local data = NRC.glyphs[name];
	if (data) then
		data = NRC:createGlyphDataFromString(data);
		local missingMajorCount, missingMinorCount = 0, 0;
		for i = 1, 6 do
			if (data[i] == 0) then
				if (i < 4) then
					missingMajorCount = missingMajorCount + 1;
				else
					missingMinorCount = missingMinorCount + 1;
				end
			end
		end
		return missingMajorCount, missingMinorCount;
	end
end


local pvpTrinkets = NRC.pvpTrinkets or {};
function NRC:updateIssuesCache(guid)
	NRC.issuesCache[guid] = nil;
	if (NRC.gearCache[guid]) then
		local slots = {
			[1] = "HeadSlot",
			[2] = "NeckSlot",
			[3] = "ShoulderSlot",
			[15] = "BackSlot",
			[5] = "ChestSlot",
			[9] = "WristSlot",
			[10] = "HandsSlot",
			[6] = "WaistSlot",
			[7] = "LegsSlot",
			[8] = "FeetSlot",
			[11] = "Finger0Slot",
			[12] = "Finger1Slot",
			[13] = "Trinket0Slot",
			[14] = "Trinket1Slot",
			[16] = "MainHandSlot",
			[17] = "SecondaryHandSlot",
			[18] = "RangedSlot",
		};
		if (expansionNum > 4) then
			--Ranged slot removed in MoP.
			slots[18] = nil;
		end
		local numSlots = 0;
		local totalIssues, enchantIssues, glyphIssues, gearMissingIssues, talentsMissing, fishingIssues, gemIssues, beltBuckleIssues = 0, 0, 0, 0, 0, 0, 0, 0;
		local data = NRC.gearCache[guid];
		if (data[16]) then
			local _, _, _, _, _, _, _, _, equipLoc = C_Item.GetItemInfo(data[16].itemLink);
			if (equipLoc == "INVTYPE_2HWEAPON" or ((equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_RANGED") and expansionNum > 4)) then
				--If two hander equipped we ignore offhand.
				slots[17] = nil;
			end
			if (NRC.fishingGear) then
				local _, itemID = strsplit(":", data[16].itemLink);
				if (itemID) then
					itemID = tonumber(itemID);
					if (NRC.fishingGear[itemID]) then
						fishingIssues = fishingIssues + 1;
						totalIssues = totalIssues + 1;
					end
				end
			end
		end
		for k, v in pairs(slots) do
			if (not data[k]) then
				gearMissingIssues = gearMissingIssues + 1;
				totalIssues = totalIssues + 1;
			end
		end
		if (NRC.enchantsCache[guid]) then
			local _, missingEnchants = NRC:getEnchantsData(guid);
			if (#missingEnchants > 0) then
				enchantIssues = #missingEnchants;
				totalIssues = totalIssues + enchantIssues;
			end
		end
		if (checkGems) then
			local _, missingGems = NRC:getGemsData(guid);
			if (missingGems and missingGems > 0) then
				gemIssues = missingGems;
				totalIssues = totalIssues + gemIssues;
			end
		end
		--[[if (checkBeltBuckle and data[6] and NRC:isMaxLevel(guid)) then
			local hasBeltBuckle = GetItemNumAddedSockets(data[6].itemLink); --This func seems not to work.
			--print(1, hasBeltBuckle)
			if (hasBeltBuckle == 0) then
				beltBuckleIssues = 1;
				totalIssues = totalIssues + 1;
			end
		end]]
		if (checkBeltBuckle and data[6] and not data[6].hasBeltBuckle) then
			beltBuckleIssues = 1;
			totalIssues = totalIssues + 1;
		end
		local name, level = NRC:getNameFromGUID(guid), NRC:getLevelFromGUID(guid);
		if (NRC.glyphs[name]) then
			local missingMajorCount, missingMinorCount = NRC:getGlyphsData(name);
			if (missingMajorCount > 0) then
				glyphIssues = missingMajorCount;
				totalIssues = totalIssues + 1;
			end
		end
		local tSpent, tMissing = NRC:getTotalTalentCount(NRC.talents[name], level);
		if (tMissing and tMissing > 0) then
			talentsMissing = tMissing;
			totalIssues = totalIssues + 1;
		end
		local otherIssues = {}
		if (data[8]) then
			local _, bootsID = strsplit(":", data[8].itemLink);
			if (bootsID == "227923") then
				totalIssues = totalIssues + 1;
				tinsert(otherIssues, "Water Treads equipped");
			end
		end
		if (data[13]) then
			local _, trinketID = strsplit(":", data[13].itemLink);
			trinketID = tonumber(trinketID);
			if (pvpTrinkets[trinketID]) then
				totalIssues = totalIssues + 1;
				tinsert(otherIssues, "PvP Trinket equipped");
			end
		end
		if (data[14]) then
			local _, trinketID = strsplit(":", data[14].itemLink);
			trinketID = tonumber(trinketID);
			if (pvpTrinkets[trinketID]) then
				totalIssues = totalIssues + 1;
				tinsert(otherIssues, "PvP Trinket equipped");
			end
		end
		local t = {
			totalIssues = totalIssues,
			enchantIssues = enchantIssues,
			glyphIssues = glyphIssues,
			gearMissingIssues = gearMissingIssues,
			talentsMissing = talentsMissing,
			fishingIssues = fishingIssues,
			gemIssues = gemIssues,
			beltBuckleIssues = beltBuckleIssues;
			otherIssues = otherIssues,
		};
		NRC.issuesCache[guid] = t;
	end
end

function NRC:getTotalIssues(guid)
	if (NRC.issuesCache[guid]) then
		return NRC.issuesCache[guid].totalIssues;
	end
	return 0;
end

function NRC:getIssuesString(guid)
	local text = "";
	local issues = NRC.issuesCache[guid];
	if (issues) then
		if (issues.enchantIssues and issues.enchantIssues > 0) then
			if (issues.enchantIssues == 1) then
				text = text .. "\n|T136244:0|t |cFF9CD6DE" .. issues.enchantIssues .. " missing enchant|r";
			else
				text = text .. "\n|T136244:0|t |cFF9CD6DE" .. issues.enchantIssues .. " missing enchants|r";
			end
		end
		if (issues.gemIssues and issues.gemIssues > 0) then
			if (issues.gemIssues == 1) then
				text = text .. "\n|T133252:0|t |cFF9CD6DE" .. issues.gemIssues .. " missing gem|r";
			else
				text = text .. "\n|T133252:0|t |cFF9CD6DE" .. issues.gemIssues .. " missing gems|r";
			end
		end
		if (issues.beltBuckleIssues and issues.beltBuckleIssues > 0) then
			if (issues.beltBuckleIssues == 1) then
				text = text .. "\n|T132525:0|t |cFF9CD6DEMissing belt buckle|r";
			end
		end
		if (issues.glyphIssues and issues.glyphIssues > 0) then
			if (issues.glyphIssues == 1) then
				text = text .. "\n|T254288:0|t |cFF9CD6DE" .. issues.glyphIssues .. " missing major glyph|r";
			else
				text = text .. "\n|T254288:0|t |cFF9CD6DE" .. issues.glyphIssues .. " missing major glyphs|r";
			end
		end
		if (issues.talentsMissing and issues.talentsMissing > 0) then
			if (issues.talentsMissing == 1) then
				text = text .. "\n|T132222:0|t |cFF9CD6DE" .. issues.talentsMissing .. " missing talent|r";
			else
				text = text .. "\n|T132222:0|t |cFF9CD6DE" .. issues.talentsMissing .. " missing talents|r";
			end
		end
		if (issues.fishingIssues and issues.fishingIssues > 0) then
			text = text .. "\n|T132931:0|t |cFF9CD6DEFishing gear equipped|r";
		end
		if (next(issues.otherIssues)) then
			for k, v in ipairs(issues.otherIssues) do
				text = text .. "\n|cFF9CD6DE" .. v .. "|r";
			end
		end
		if (issues.gearMissingIssues and issues.gearMissingIssues > 0) then
			if (issues.gearMissingIssues == 1) then
				text = text .. "\n|cFF9CD6DE" .. issues.gearMissingIssues .. " gear slot empty|r";
			else
				text = text .. "\n|cFF9CD6DE" .. issues.gearMissingIssues .. " gear slots empty|r";
			end
			if (issues.gearMissingIssues > 5) then
				text = text .. "\n|cFFFFFF00Possible equip error\nReinspect player|r";
			end
		end
		text = gsub(text, "^\n", "");
	end
	return text;
end

--Using the real spellID for set bonuses here, although any number could be used since we can't see other peoples spellID bonuses and have to count armor equipped.
--It's better for sanity purposes to use the correct spellIDto make it easier to keep track of what's what.
--If percent is set then we reduce cooldown time by that percentage, other it's just amount of seconds reduced by {seconds = 30}.
local setBonuses = {
	[1213159] = { --https://www.wowhead.com/classic/spell=1213159/s03-item-taq-druid-restoration-2p-bonus.
		--What spells get a reduduced cooldown time and by how much.
		equippedCountReq = 2,
		armor = {
			[233722] = "Genesis Pauldrons",
			[233721] = "Genesis Greaves",
			[233723] = "Genesis Mask",
			[233719] = "Genesis Breeches",
			[233720] = "Genesis Chestguard",
		},
		cooldownSpellIDs = {
			--Barkskin.
			[29166] = {percent = 65}, --Innervate Rank 1.
			[20484] = {percent = 65}, --Rebirth Rank 1.
			[20739] = {percent = 65}, --Rebirth Rank 2.
			[20742] = {percent = 65}, --Rebirth Rank 3.
			[20747] = {percent = 65}, --Rebirth Rank 4.
			[20748] = {percent = 65}, --Rebirth Rank 5.
		},
	},
	
	--Test set.
	--[[[1218423] = {
		--What spells get a reduduced cooldown time and by how much.
		equippedCountReq = 2,
		armor = {
			[236186] = "Dreamwalker Tunic",
			[236187] = "Dreamwalker Girdle",
		},
		cooldownSpellIDs = {
			--Barkskin.
			[29166] = {percent = 65}, --Innervate Rank 1.
			[20484] = {percent = 65}, --Rebirth Rank 1.
			[20739] = {percent = 65}, --Rebirth Rank 2.
			[20742] = {percent = 65}, --Rebirth Rank 3.
			[20747] = {percent = 65}, --Rebirth Rank 4.
			[20748] = {percent = 65}, --Rebirth Rank 5.
			[22812] = {percent = 50}, --Barskin.
			[428713] = {seconds = 50}, --Barskin SoD.
		},
	},]]
};

--This is a cache of spells effected by a cooldown reduction if set bonus is active.
function NRC:updateSetBonusCache(guid)
	if (NRC.gearCache[guid]) then
		NRC.setBonuses[guid] = nil;
		local equip = NRC.gearCache[guid];
		for setBonusSpellID, setBonusData in pairs(setBonuses) do
			local armor = setBonusData.armor;
			local equippedCount = 0;
			for k, v in pairs(equip) do
				if (type(v) == "table" and v.itemLink) then
					local _, itemID, enchantID = strsplit(":", v.itemLink);
					itemID = tonumber(itemID);
					if (armor[itemID]) then
						equippedCount = equippedCount + 1;
					end
				end
			end
			if (equippedCount >= setBonusData.equippedCountReq) then
				if (not NRC.setBonuses[guid]) then
					NRC.setBonuses[guid] = {};
				end
				if (not NRC.setBonuses[guid][setBonusSpellID]) then
					NRC.setBonuses[guid][setBonusSpellID] = {};
				end
				for spellID, reductionData in pairs(setBonusData.cooldownSpellIDs) do
					NRC.setBonuses[guid][setBonusSpellID][spellID] = reductionData;
				end
				break;
			end
		end
	end
end

--Check if the spellID of a casted cooldown needs a set bonus reduction.
function NRC:getSetBonusCooldownReduction(guid, spellID, timestamp)
	if (NRC.setBonuses[guid]) then
		for setBonusSpellID, cooldownReductionSpells in pairs(NRC.setBonuses[guid]) do
			if (cooldownReductionSpells[spellID]) then
				local cooldownPercent = cooldownReductionSpells[spellID].percent;
				if (cooldownPercent) then
					local secondsLeft = timestamp - GetServerTime();
					local adjustment = (cooldownPercent / 100) * secondsLeft;
					timestamp = timestamp - adjustment;
				else
					local cooldownSeconds = cooldownReductionSpells[spellID].seconds;
					if (cooldownSeconds) then
						timestamp = timestamp - cooldownSeconds;
					end
				end
			end
		end
	end
	return timestamp;
end

--Check if a player has a set bonus spellID active, not a casted spell but the actual set bonus spellID.
function NRC:hasSetBonus(guid, setBonusSpellID)
	if (NRC.setBonuses[guid] and NRC.setBonuses[guid]) then
		local data = setBonuses[setBonusSpellID];
		if (data) then
			for spellID, _ in pairs(data.cooldownSpellIDs) do
				if (NRC.setBonuses[guid][spellID]) then
					return true;
				end
			end
		end
	end
end

function NRC:clearInspectdata(guid, name)
	if (guid) then
		NRC.gearCache[guid] = nil;
		NRC.setBonuses[guid] = nil;
		NRC.sanctifiedCache[guid] = nil;
	end
end

function NRC:clearAllInspectdata()
	NRC.gearCache = {};
	NRC.sanctifiedCache = {};
	NRC.enchantsCache = {};
	NRC.issuesCache = {};
	NRC.setBonuses = {};
	NRC:buildMyInventoryFromInspect();
end

local f = CreateFrame("Frame");
f:RegisterEvent("UNIT_INVENTORY_CHANGED");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("ENCOUNTER_END");
f:SetScript('OnEvent', function(self, event, ...)
	if (event == "UNIT_INVENTORY_CHANGED") then
		local unit = ...;
		if (unit == "player") then
			NRC:throddleEventByFunc("UNIT_INVENTORY_CHANGED", 2, "buildMyInventoryFromInspect");
		else
			local guid = UnitGUID(unit);
			if (NRC:inOurGroup(guid)) then
				NRC:throddleEventByFunc("UNIT_INVENTORY_CHANGED", 3, "inspect", guid);
			end
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		C_Timer.After(5, function()
			NRC:buildMyInventoryFromInspect();
		end);
		--if (NRC.isSOD) then
		--	NRC:loadInspectQueue(true);
		--end
	elseif (event == "ENCOUNTER_END") then
		NRC:loadInspectQueue(true);
	end
end)

local equipmentFrame;
function NRC:openEquipmentFrame(guid)
	if (not equipmentFrame) then
		equipmentFrame = NRC:createEquipmentFrame("NRCEquipmentFrame", 600, 3, 28)
		equipmentFrame.onUpdateFunction = "recalcEquipmentFrame";
		--equipmentFrame.fsTitle:SetText(NRC.prefixColor .. "NRC " .. L["Equipment Viewer"] .. "|r");
	end
	if (not equipmentFrame:IsShown() or guid ~= equipmentFrame.guid) then
		equipmentFrame.guid = guid;
		--equipmentFrame.guid = UnitGUID("player");
		equipmentFrame:Show();
		NRC:recalcEquipmentFrame(true);
		equipmentFrame:Raise();
	else
		equipmentFrame:Hide();
	end
end

function NRC:recalcEquipmentFrame(firstOpen)
	if (firstOpen) then
		equipmentFrame.dots = 0;
		equipmentFrame.fs:SetText("");
		equipmentFrame.fs2:SetText("");
		equipmentFrame.fs3:SetText("");
		equipmentFrame.fs4:SetText("");
		equipmentFrame.fs5:SetText("");
		equipmentFrame.fs6:SetText("");
		equipmentFrame.fs7:SetText("");
		equipmentFrame.fs8:SetText("");
		equipmentFrame.fs9:SetText("");
		equipmentFrame.fs10:SetText("");
		equipmentFrame.fs11:SetText("");
		equipmentFrame.specTexture:SetTexture();
		equipmentFrame.specTexture:SetSize(1, 30);
	end
	local guid = equipmentFrame.guid;
	if (not guid) then
		equipmentFrame.fs:SetText("|cFFFFFF00Error, character no data found.|r");
		equipmentFrame.loadEquipment();
		return;
	end
	local data = NRC:getCharDataFromGUID(guid);
	if (not data) then
		equipmentFrame.fs:SetText("|cFFFFFF00Error, character no data found.|r");
		equipmentFrame.loadEquipment();
		return;
	end
	local name = NRC:getNameFromGUID(guid);
	if (not name) then
		equipmentFrame.fs:SetText("|cFFFFFF00Error, character no data found.|r");
		equipmentFrame.loadEquipment();
		return;
	end
	local nameOnly, realmOnly = strsplit("-", name, 2);
	local _, _, _, classHex = NRC.getClassColor(data.class);
	local colorizedName = "|c" .. classHex .. nameOnly .. "|r";
	equipmentFrame.fs:SetText(colorizedName);
	if (NRC:isInInspectQueue(guid)) then
		equipmentFrame.updateButton:Hide();
		equipmentFrame.updateButton:SetScript("OnClick", function(self, arg)

		end);
		local dots = "";
		if (equipmentFrame.dots == 1) then
			dots = ".";
		elseif (equipmentFrame.dots == 2) then
			dots = "..";
		elseif (equipmentFrame.dots == 3) then
			dots = "...";
		end
		if (equipmentFrame.dots > 2) then
			equipmentFrame.dots = 0;
		else
			equipmentFrame.dots = equipmentFrame.dots + 1;
		end
		equipmentFrame.updateThroddle = 0.5;
		equipmentFrame.fs9:SetText("|cFFA1A1A1Updating equip when");
		equipmentFrame.fs10:SetText("|cFFA1A1A1in range of player");
		equipmentFrame.fs11:SetText("|cFFA1A1A1" .. dots);
		equipmentFrame.updateButton:Hide();
		equipmentFrame.updateThroddle = 0.5;
	else
		equipmentFrame.updateButton:Show();
		equipmentFrame.updateButton:SetScript("OnClick", function(self, arg)
			if (guid == UnitGUID("player")) then
				NRC:buildMyInventoryFromInspect();
				NRC:checkMyTalents();
				NRC.checkMyGlyphs();
			else
				NRC:inspect(guid, true);
			end
		end);
		equipmentFrame.fs9:SetText("");
		equipmentFrame.fs10:SetText("");
		equipmentFrame.fs11:SetText("");
		equipmentFrame.updateThroddle = 1;
	end
	equipmentFrame.talentsButton:SetScript("OnClick", function(self, arg)
		--Do nothing.
	end);
	local equipmentData = NRC.gearCache[guid];
	if (not equipmentData) then
		equipmentFrame.fs2:SetText("|cFFFFFF00No equipment data found.|r");
		equipmentFrame.fs2:Show();
		equipmentFrame.loadEquipment();
		return;
	end
	
	local localizedClass = NRC:getLocalizedClassFromGUID(guid);
	local infoText = data.level .. " " .. data.race .. " " .. (localizedClass or "Unknown");
	local talentString = NRC.talents[name];
	if (talentString) then
		local classID, trees = strsplit("-", talentString, 2);
		classID = tonumber(classID);
		local class, classEnglish = GetClassInfo(classID);
		local specID, talentCount, specName, specIcon, specIconPath, treeData = NRC:getSpecFromTalentString(talentString);
		if (specIconPath) then
			trees = {strsplit("-", trees, 4)};
			local icon = "|T" .. specIconPath .. ":17:17:0:0|t1|t";
			local treeString = "|cFF9CD6DE(" .. treeData[1] .. "/" .. treeData[2] .. "/" .. treeData[3] .. ")|r";
			--equipmentFrame.fs3:SetText(treeString);
			--infoText = infoText .. "\n" .. specName .. " " .. treeString .. " |T" .. specIcon .. ":14:14|t";
			infoText = infoText .. "\n" .. specName .. " " .. treeString;
		elseif (talentCount == 0) then
			infoText = infoText .. "\nNo talents spent";
		elseif (specName) then
			--If MoP+ and talents are spents just show spec name.
			infoText = infoText .. "\n" .. specName;
		else
			infoText = infoText .. "\nNo talents data found";
		end
		--local text3 = colorizedName .. "  " .. treeString .. "  |cFF9CD6DE" .. specName .. "|r";
		if (specIcon) then
			equipmentFrame.specTexture:SetTexture(specIcon);
			equipmentFrame.specTexture:SetSize(equipmentFrame.fs:GetHeight(), equipmentFrame.fs:GetHeight());
		else
			equipmentFrame.specTexture:SetTexture();
			equipmentFrame.specTexture:SetSize(1, equipmentFrame.fs:GetHeight());
		end
		equipmentFrame.talentsButton:SetScript("OnClick", function(self, arg)
			NRC:openTalentFrame(name, talentString);
		end)
		equipmentFrame.talentsButton:Show();
	else
		equipmentFrame.talentsButton:SetScript("OnClick", function(self, arg)
			--Do nothing.
		end)
		equipmentFrame.talentsButton:Hide();
		equipmentFrame.specTexture:SetTexture();
		equipmentFrame.specTexture:SetSize(1, equipmentFrame.fs:GetHeight());
	end
	equipmentFrame.fs2:SetText("|cFF9CD6DE" .. infoText);
	local issues = NRC.issuesCache[guid];
	local issuesHeight = 0;
	if (issues and issues.totalIssues > 0) then
		--equipmentFrame.fs4:SetText("|cFF9CD6DEIssues Found|r");
		--equipmentFrame.fs4:SetText("|cFFFFFF00Issues Found|r");
		equipmentFrame.fs4:SetText("|cFFFF6900[Potential Issues]|r");
		local text = NRC:getIssuesString(guid);
		equipmentFrame.fs5:SetText(text);
		issuesHeight = equipmentFrame.fs5:GetHeight();
	else
		equipmentFrame.fs4:SetText("");
		equipmentFrame.fs5:SetText("|cFFFFFF00No issues detected.");
	end
	equipmentFrame.fs6:SetText("|cFFFFFF00Average iLvl");
	equipmentFrame.fs7:SetText("|cFF9CD6DE" .. NRC:getAverageItemLevel(guid, 2));
	local updated = NRC.gearCache[guid].updated;
	if (updated) then
		equipmentFrame.fs8:SetText("|cFFA1A1A1Last updated " .. NRC:getTimeString(GetServerTime() - updated, true) .. " ago");
	else
		equipmentFrame.fs8:SetText("");
	end
	--If the issues list is long ten extend the frame down to fit the text.
	local issuesHeightOffset = issuesHeight - 55; --If more than 4 lines of text.
	if (issuesHeightOffset > 0) then
		equipmentFrame:SetHeight(equipmentFrame.defaultHeight + issuesHeightOffset);
	else
		equipmentFrame:SetHeight(equipmentFrame.defaultHeight);
	end
	equipmentFrame.loadEquipment(data.class, equipmentData);
end




























---Inspect functions, needed so we can get accurate cooldowns of talented spells like bop, and talent only spells like mana tide.
---This is messy in classic because of very short inspect range but we'll see how it goes...
---If another addon or lib inspects a player it will be removed from our queue.
---Inspect one player every inspectInterval if within inspect range and it's been inspectCooldown since last try on player.
---We wait inspectTimeout if no response from server since last inspect before trying next.
---If we get a response then inspectTimeout is reset and we inspect next.
---inspectInterval time between inspects, even if it's faster than server throddle the timeout will cover it, everyone will still get inspected.

local distanceIndex = 4;
local inspectInterval = 4;
local inspectTimeout = 10;
local inspectCooldown = 60;
local inspectQueue = {};
local lastInspectAttempt = {};
local lastInspect = 0;
local lastAttempt = 0;
local inspectSuccess = {};
local queueRunning;
local inspectingGUID;
local inspectFrameTalents;
local inspectFrameTalentsGUID;
local glyphSpellIDs = NRC.glyphSpellIDs;
local f = CreateFrame("Frame", "NRCGroup");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("GROUP_ROSTER_UPDATE");
f:RegisterEvent("INSPECT_READY");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:SetScript('OnEvent', function(self, event, ...)
	if (event == "UNIT_SPELLCAST_SUCCEEDED") then
		local unit, _, spellID = ...;
		if (strfind(unit, "party") or strfind(unit, "raid")  or unit == "player") then
			--Spec change.
			if (spellID == 63644 or spellID == 63645) then
				if (unit == "player") then
					C_Timer.After(1, function()
						NRC:updateHealerCache("UNIT_SPELLCAST_SUCCEEDED");
					end)
				else
					local guid = UnitGUID(unit);
					if (guid) then
						NRC:inspect(guid);
					end
				end
			--elseif (spellID == 113873 or glyphSpellIDs[spellID]) then
			elseif (spellID == 113873) then
				--Remove talent has been cast in MoP+, inspect after a short time to see which talent has been trained.
				--There is no talent learnt event for group members.
				--We also check for glyphs being swapped, sadly we need every glyph spellID to detect this.
				--We need the actual glyph being applied ID https://www.wowhead.com/mop-classic/spell=124417/black-ice
				--Haven't created the glyph spellIDs db yet, maybe lter.
				if (unit ~= "player") then
					C_Timer.After(5, function()
						local guid = UnitGUID(unit);
						if (guid) then
							NRC:inspect(guid);
						end
					end)
					C_Timer.After(30, function()
						local guid = UnitGUID(unit);
						if (guid) then
							NRC:inspect(guid);
						end
					end)
				end
			end
			if (NRC.specialHealingSpells and NRC.specialHealingSpells[spellID]) then
				local name = UnitName(unit);
				local specialHealingSpells = NRC.specialHealingSpells[spellID];
				if (not NRC.specialHealers[name]) then
					NRC.specialHealers[name] = {
						specName = specialHealingSpells.specName,
						icon = specialHealingSpells.icon,
						class = specialHealingSpells.class,
					};
					NRC:updateHealerCache("UNIT_SPELLCAST_SUCCEEDED");
				end
			end
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		local isLogon, isReload = ...;
		if (isReload) then
			C_Timer.After(5, function()
				NRC:loadInspectQueue();
			end)
		end
	elseif (event == "GROUP_ROSTER_UPDATE") then
		if (IsInGroup()) then
			--This will only inspect if there's a new player not seen before, it doesn't start the inspect queue every time there's a roster update.
			--Because the overwrite arg is missing function NRC:loadInspectQueue(overwrite)
			NRC:throddleEventByFunc(event, 3, "loadInspectQueue", ...);
		end
	elseif (event == "INSPECT_READY") then
		--print(C_SpecializationInfo.GetActiveSpecGroup(true), GetActiveTalentGroup(true))
		--print(C_SpecializationInfo.GetSpecialization(true, nil, 1), C_SpecializationInfo.GetSpecialization(true, nil, 2))
		local guid = ...;
		NRC:receivedInspect(guid);
	end
end)

local function inspectTicker()
	if (not IsInGroup()) then
		NRC:stopInspectQueue();
		return;
	end
	if (InspectFrame and InspectFrame:IsShown()) then
		--Pause if InspectFrame open.
		C_Timer.After(2, function()
			inspectTicker();
		end)
		return;
	end
	if (next(inspectQueue)) then
		if (GetTime() - lastInspect > inspectTimeout) then
			if (inspectingGUID) then
				NRC:stopCurrentInspect();
			end
			if (not UnitIsDead("player") and not InCombatLockdown()
					and GetTime() - lastAttempt > inspectInterval) then
				inspectingGUID = nil;
				for k, guid in pairs(inspectQueue) do
					local unit = NRC:getUnitFromGUID(guid);
					if (unit and UnitExists(unit) and CheckInteractDistance(unit, distanceIndex) and UnitIsConnected(unit)
							and (not lastInspectAttempt[guid] or GetTime() - lastInspectAttempt[guid] > inspectCooldown)) then
						--Even though we checked range with CheckInteractDistance() it can be a little unreliable.
						--So disable error msgs for a split second while we inspect.
						local registerErrors, enableErrorFilter;
						if (UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE")) then
							registerErrors = true;
							UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
						end
						if (ErrorFilter) then
							--If Error Filter installed disable events for a split second and reenable them after NotifyInspect().
							ErrorFilter:UnregisterEvent("UI_ERROR_MESSAGE");
							enableErrorFilter = true;
						end
						--CanInspect() gives UI error feedback to user so run this after errors are disabled.
						if (CanInspect(unit)) then
							--NRC:stopCurrentInspect();
							lastInspectAttempt[guid] = GetTime();
							lastInspect = GetTime();
							lastAttempt = GetTime(); --This is seperate to lastInspect so it can be reset to 0 for interval reasons.
							inspectingGUID = guid;
							NotifyInspect(unit);
							if (registerErrors) then
								UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");
							end
							if (enableErrorFilter) then
								ErrorFilter:UpdateEvents();
							end
							break;
						end
						if (registerErrors) then
							UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");
						end
						if (enableErrorFilter) then
							ErrorFilter:UpdateEvents();
						end
					end
				end
			end
		end
		C_Timer.After(1, function()
			inspectTicker();
		end)
	else
		NRC:stopCurrentInspect();
		NRC:stopInspectQueue();
	end
end

--Load a queue from group cache.
function NRC:loadInspectQueue(overwrite)
	if (IsInGroup()) then
		inspectQueue = {};
		local me = UnitName("player");
		for k, v in pairs(NRC.groupCache) do
			--For now we only inspect each player once per session unless overwrite is set.
			if (v.guid and k ~= me and (overwrite or not inspectSuccess[v.guid])) then
				tinsert(inspectQueue, v.guid);
			end
		end
		if (next(inspectQueue)) then
			--NRC:debug("loaded inspect queue");
			NRC:startInspectQueue();
		end
	end
end

function NRC:startInspectQueue()
	if (NRC.isRetail) then
		return;
	end
	if (not queueRunning) then
		--NRC:debug("starting inspect queue");
		queueRunning = true;
		inspectTicker();
	end
end

function NRC:stopInspectQueue()
	--NRC:debug("stopping inspect queue");
	inspectQueue = {};
	queueRunning = false;
end

--Inspect a single player.
function NRC:inspect(guid, priority)
	if (NRC:isInArena()) then
		--Temp disabled until I do arena next and fix a lua error.
		return;
	end
	local me = UnitGUID("player");
	if (guid == me or not guid) then
		return;
	end
	local _, _, _, _, _, name = GetPlayerInfoByGUID(guid);
	--NRC:debug("inspecting single player", name or guid);
	lastInspectAttempt[guid] = nil;
	if (priority) then
		lastInspect = 0;
		lastAttempt = 0;
		tinsert(inspectQueue, 1, guid);
	else
		tinsert(inspectQueue, guid);
	end
	if (next(inspectQueue)) then
		NRC:startInspectQueue();
	end
end

function NRC:getGroupInspectCount()
	local count = 0;
	for k, v in pairs(NRC.groupCache) do
		if (NRC.talents[k]) then
			count = count + 1;
		end
	end
	return count;
end

function NRC:isInInspectQueue(guid)
	for k, v in pairs(inspectQueue) do
		if (v == guid) then
			return true;
		end
	end
end

--function NRC:sendInspectData(guid, talentString)

--end

function NRC:receivedInspect(guid)
	inspectFrameTalentsGUID = guid;
	local _, _, _, _, _, name = GetPlayerInfoByGUID(guid);
	--NRC:debug("received inspect", name);
	if (not NRC:inOurGroup(guid)) then
		return;
	end
	--local inspected = NRC:getGroupInspectCount() .. "/" .. GetNumGroupMembers();
	lastAttempt = 0;
	for k, v in pairs(inspectQueue) do
		if (v == guid) then
			inspectQueue[k] = nil;
		end
	end
	local talentString;
	if (guid) then
		inspectSuccess[guid] = GetServerTime();
		talentString = NRC:addTalentStringFromInspect(guid);
		NRC:addGlyphStringFromInspect(guid);
		NRC:buildInventoryFromInspect(guid);
	end
	--If the inspect result is from our queue.
	if (guid == inspectingGUID) then
		--if (talentString) then
		--	NRC:sendInspectData(guid, talentString);
		--end
		inspectingGUID = nil;
	end
	currentInspectGUID = guid; --This is used in the funcs above and is not the same as inspectingGUID.
	NRC:updateTrackedManaCharTalents(name);
	NRC:updateHealerCache("receivedInspect");
	NRC:throddleEventByFunc("GROUP_ROSTER_UPDATE", 2, "loadTrackedManaChars", "receivedInspect");
	--inspectAgainQueue[guid] = nil;
end

function NRC:stopCurrentInspect()
	inspectingGUID = nil;
	ClearInspectPlayer();
end

--Add talents to cache.
function NRC:addTalentStringFromInspect(guid)
	local talentString, talentString2 = NRC:createTalentStringFromInspect(guid, true);
	if (talentString) then
		local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(guid);
		local nameRealm = name .. "-" ..  realm;
		if (NRC.groupCache[name]) then
			--NRC:debug("added talents from inspect", name);
			NRC.talents[name] = talentString;
			NRC:loadRaidCooldownChar(name, NRC.groupCache[name]);
		elseif (NRC.groupCache[nameRealm]) then
			NRC.talents[nameRealm] = talentString;
			NRC:loadRaidCooldownChar(nameRealm, NRC.groupCache[nameRealm]);
		end
		if (talentString2) then
			if (NRC.groupCache[name]) then
				--NRC:debug("added talents from inspect", name);
				NRC.talents2[name] = talentString2;
			elseif (NRC.groupCache[nameRealm]) then
				NRC.talents2[nameRealm] = talentString2;
			end
		end
		return talentString;
	end
end

--Add talents to cache.
function NRC:addGlyphStringFromInspect(guid)
	local glyphString, glyphString2 = NRC:createGlyphStringFromInspect(guid, true);
	if (glyphString) then
		local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(guid);
		local nameRealm = name .. "-" ..  realm;
		if (NRC.groupCache[name]) then
			--NRC:debug("added glyphs from inspect", name);
			NRC.glyphs[name] = glyphString;
			NRC:loadRaidCooldownChar(name, NRC.groupCache[name]);
		elseif (NRC.groupCache[nameRealm]) then
			NRC.glyphs[nameRealm] = glyphString;
			NRC:loadRaidCooldownChar(nameRealm, NRC.groupCache[nameRealm]);
		end
		if (glyphString2) then
			if (NRC.groupCache[name]) then
				--NRC:debug("added glyphs from inspect", name);
				NRC.glyphs2[name] = glyphString2;
			elseif (NRC.groupCache[nameRealm]) then
				NRC.glyphs2[nameRealm] = glyphString2;
			end
		end
		return glyphString;
	end
end

function NRC:createTalentStringFromInspect(guid, isInspect)
	local talentString, talentString2;
	if (NRC.isRetail) then
		return "1-0-0-0";
	elseif (isTierTalents) then
		local unit = NRC:getUnitFromGUID(guid);
		local _, _, classID = UnitClass(unit);
		talentString = tostring(classID) .. "-";
		talentString2 = tostring(classID) .. "-";
		
		
		--It seems like C_SpecializationInfo.GetActiveSpecGroup and GetActiveTalentGroup are both broken for inspect in MoP.
		--Both return 1 no matter what, sometimes they start working after an inspect unit changes a talent or somehting to update it.
		--Inspect stills shows the corrent talents for inspected unit current active spec, it just always show primary talents are active even if it's really secondary.
		--I guess that's why looking up C_SpecializationInfo.GetSpecialization is also broken.
		--Very hacky work around for getting the correct specialization below.

	
		--local activeSpec = C_SpecializationInfo.GetActiveSpecGroup(isInspect);
		--print(C_SpecializationInfo.GetActiveSpecGroup(true), GetActiveTalentGroup(true));
		local activeSpec = GetActiveTalentGroup(isInspect);
		--print(UnitName(unit), activeSpec, isInspect, GetInspectSpecialization(unit))
		local offSpec = (activeSpec == 1 and 2 or 1);
		for row = 1, MAX_NUM_TALENT_TIERS do
			--GetTalentTierInfo() didn't seem to work with inspect, atleast on the beta for now.
			--local tierAvailable, selectedTalentColumn, tierUnlockLevel = GetTalentTierInfo(row, activeSpec, true, unit);
			--Use a different route.
			local selectedTalentColumn = 0;
			local talentInfoQuery = {};
			talentInfoQuery.tier = row;
			talentInfoQuery.groupIndex = activeSpec;
			talentInfoQuery.isInspect = isInspect;
			talentInfoQuery.target = unit;
			for column = 1, NUM_TALENT_COLUMNS do
				talentInfoQuery.column = column;
				local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
				if (talentInfo and talentInfo.selected) then
					selectedTalentColumn = column;
				end
			end
			talentString = talentString .. selectedTalentColumn;
		end
		local specID;
		if (isInspect) then
			local specsByClassID = {
				[0] = {74, 81, 79},
			    [1] = {71, 72, 73, 1446},
			    [2] = {65, 66, 70, 1451},
			    [3] = {253, 254, 255, 1448},
			    [4] = {259, 260, 261, 1453},
			    [5] = {256, 257, 258, 1452},
			    [6] = {250, 251, 252, 1455},
			    [7] = {262, 263, 264, 1444},
			    [8] = {62, 63, 64, 1449},
			    [9] = {265, 266, 267, 1454},
			    [10] = {268, 270, 269, 1450},
			    [11] = {102, 103, 104, 105, 1447},
			};
			local spec = GetInspectSpecialization(unit);
			for k, v in pairs(specsByClassID[classID]) do
				if (v == spec) then
					specID = k;
				end
			end
			if (not specID) then
				--Fallback just to avoid errors for now, this won't be accurate though until they fix the func fir inspect...
				--specID = C_SpecializationInfo.GetSpecialization(isInspect, nil, activeSpec);
			end
			--specID = specsByClassID[classID][GetInspectSpecialization(unit)];
			--print(UnitName(unit), specID, classID, GetInspectSpecialization(unit))
		else
			specID = C_SpecializationInfo.GetSpecialization(isInspect, nil, activeSpec);
		end
		talentString = talentString .. "-" .. specID;
		for row = 1, talentRowCount do
			local selectedTalentColumn = 0;
			local talentInfoQuery = {};
			talentInfoQuery.tier = row;
			talentInfoQuery.groupIndex = offSpec;
			talentInfoQuery.isInspect = isInspect;
			talentInfoQuery.target = unit;
			for column = 1, NUM_TALENT_COLUMNS do
				talentInfoQuery.column = column;
				local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
				if (talentInfo and talentInfo.selected) then
					selectedTalentColumn = column;
				end
			end
			talentString2 = talentString2 .. selectedTalentColumn;
		end
		local specID2 = C_SpecializationInfo.GetSpecialization(isInspect, nil, offSpec);
		talentString2 = talentString2 .. "-" .. specID2;
		--GetInspectSpecialization()
		--NRC:debug(talentString, talentString2)
	else
		local unit = NRC:getUnitFromGUID(guid);
		local _, class = GetPlayerInfoByGUID(guid);
		local classID;
		for i = 1, GetNumClasses() do
			local className, classFile, id = GetClassInfo(i);
			if (class == classFile) then
				classID = id;
				break;
			end
		end
		--Fallback just incase, less reliable mapping units to group until I get NRC:getUnitFromGUID() working better.
		if (unit and not classID) then
			_, _, classID = UnitClass(unit);
		end
		if (not classID) then
			return;
		end
		--Seems all 3 clients are using the new out of order system now.
		if (unit or classID) then
			local data = {
				classID = classID,
			};
			local data2 = {
				classID = classID,
			};
			--Number of talents varies by class, but if we get a rough num for this expansion and add 20 it should cover it.
			--We stop iteration when we reach nil (end of talent tree) anyway.
			local numTalents = GetNumTalents(1) + 20;
			if (classID) then
				talentString = tostring(classID);
				talentString2 = tostring(classID);
				local activeSpec = GetActiveTalentGroup(isInspect);
				local offSpec = (activeSpec == 1 and 2 or 1);
				for tab = 1, GetNumTalentTabs() do
					data[tab] = {};
					data2[tab] = {};
					for i = 1, numTalents do
						local name, _, row, column, rank = GetTalentInfo(tab, i, isInspect, nil, activeSpec);
						--This was changed because there were bugs in cata with GetTalentInfo().
						--Arcane mage has an empty entry at talent 21, and the real 21 was at index 22.	
						--[[if (name) then
							data[tab][i] = {
								rank = rank,
								row = row,
								column = column,
							};
						else
							break;
						end]]
						if (name) then
							local t = {
								rank = rank,
								row = row,
								column = column,
							};
							tinsert(data[tab], t);
						end
					end
					for i = 1, numTalents do
						local name, _, row, column, rank = GetTalentInfo(tab, i, isInspect, nil, offSpec);
						--[[if (name) then
							data2[tab][i] = {
								rank = rank,
								row = row,
								column = column,
							};
						else
							break;
						end]]
						if (name) then
							local t = {
								rank = rank,
								row = row,
								column = column,
							};
							tinsert(data2[tab], t);
						end
					end
				end
			end
			talentString = NRC:createTalentStringFromTable(data);
			talentString2 = NRC:createTalentStringFromTable(data2);
		end
	end
	return talentString, talentString2;
end

--First 3 major, second 3 minor.
function NRC:createGlyphStringFromInspect(guid, isInspect)
	--In cata and mop the returns structure changes.
	--And there's no glyph inspect anwyay in previous expansions?
	--For our own glyphs we use an older glyph func in Talents.lua
	if (NRC.expansionNum < 5) then
		return "";
	end
	local unit = NRC:getUnitFromGUID(guid);
	local _, _, classID = UnitClass(unit);
	local glyphString, glyphString2 = classID, classID;
	local activeSpec = C_SpecializationInfo.GetActiveSpecGroup(isInspect);
	local offSpec = (activeSpec == 1 and 2 or 1);
	local temp = {};
	local count = 0;
	local glyphMap = { --First 3 major, second 3 minor.
		[1] = 2, --Major slot 1.
		[2] = 4, --Major slot 2.
		[3] = 6, --Major slot 3.
		[4] = 1, --Minor slot 1.
		[5] = 3, --Minor slot 2.
		[6] = 5, --Minor slot 3.
	};
	--Active spec.
	for k, v in ipairs(glyphMap) do
		local enabled, type, index, spellID, icon = GetGlyphSocketInfo(v, activeSpec, isInspect, unit);
		glyphString = glyphString .. "-" .. (spellID or 0);
	end
	--Offspec.
	for k, v in ipairs(glyphMap) do
		local enabled, type, index, spellID, icon = GetGlyphSocketInfo(v, offSpec, isInspect, unit);
		glyphString2 = glyphString2 .. "-" .. (spellID or 0);
	end
	--This old way below would sort the glyphs into order except there was a problems.
	--If the middle slot (2) was empty then the next slot (3) would move down to 2 and create inconsistancies in the display slots.
	--Now I use a glyphMap above to keep things in the right slots instead.
	--[[for i = 1, GetNumGlyphSockets() do
		local enabled, type, index, spellID, icon = GetGlyphSocketInfo(i, activeSpec, isInspect, unit);
		if (type == 1) then
			count = count + 1;
			temp[count] = spellID or 0;
		end
	end
	table.sort(temp, function(a, b) return a > b end);
	--Make sure filled slots are first.
	for i = 1, 3 do
		glyphString = glyphString .. "-" .. (temp[i] or 0);
	end
	temp = {};
	count = 0;
	for i = 1, GetNumGlyphSockets() do
		local enabled, type, index, spellID, texture = GetGlyphSocketInfo(i, activeSpec, isInspect, unit);
		if (type == 2) then
			count = count + 1;
			temp[count] = spellID or 0;
		end
	end
	table.sort(temp, function(a, b) return a > b end);
	for i = 1, 3 do
		glyphString = glyphString .. "-" .. (temp[i] or 0);
	end
	---Offspec.
	temp = {};
	count = 0;
	--Active spec.
	for i = 1, GetNumGlyphSockets() do
		local enabled, type, index, spellID, icon = GetGlyphSocketInfo(i, offSpec, isInspect, unit);
		if (type == 1) then
			count = count + 1;
			temp[count] = spellID or 0;
		end
	end
	table.sort(temp, function(a, b) return a > b end);
	--Make sure filled slots are first.
	for i = 1, 3 do
		glyphString2 = glyphString2 .. "-" .. (temp[i] or 0);
	end
	temp = {};
	count = 0;
	for i = 1, GetNumGlyphSockets() do
		local enabled, type, index, spellID, texture = GetGlyphSocketInfo(i, offSpec, isInspect, unit);
		if (type == 2) then
			count = count + 1;
			temp[count] = spellID or 0;
		end
	end
	table.sort(temp, function(a, b) return a > b end);
	for i = 1, 3 do
		glyphString2 = glyphString2 .. "-" .. (temp[i] or 0);
	end]]
	--We're only using current spec glyph string atm, probably add dual spec support later.
	--glyphString2 isn't used by any funcs yet.
	--On the inspect frame we only display glyphs for main spec.
	--NRC:debug(glyphString, glyphString2)
	return glyphString, glyphString2;
end

local inspectTalentsCheckBox, inspectTalentsFrame;
local function openInspectTalentsFrame()
	if (not InspectFrame or not InspectFrame.unit) then
		return;
	end
	if (not inspectTalentsFrame) then
		if (NRC.isMOP) then
			inspectTalentsFrame = NRC:createTalentTiersFrame("NRCInspectTalentFrame", 644, 408, 0, 0, 3);
		elseif (NRC.isWrath) then
			inspectTalentsFrame = NRC:createTalentFrame("NRCInspectTalentFrame", 870, 540, 0, 0, 3);
		else
			inspectTalentsFrame = NRC:createTalentFrame("NRCInspectTalentFrame", 870, 480, 0, 0, 3);
		end
		inspectTalentsFrame.closeButton:SetScript("OnClick", function(self, arg)
			inspectTalentsFrame:Hide();
			if (InspectFrameCloseButton and InspectFrame and InspectFrame:IsShown()) then
				InspectFrameCloseButton:Click();
			end
		end)
		inspectTalentsFrame:SetScript("OnHide", function(self)
			inspectTalentsFrame.name = nil;
			inspectTalentsFrame.talentString = nil;
			inspectTalentsFrame.talentString2 = nil;
			inspectTalentsFrame.showOffspec = nil;
			inspectTalentsFrame.glyphString = nil;
			inspectTalentsFrame.glyphString2 = nil;
			inspectTalentsFrame.isInspect = nil;
			inspectTalentsFrame.fromRaidStatus = nil;
		end)
		inspectTalentsFrame.onUpdateFunction = "updateTalentFrame";
		inspectTalentsFrame.fs:SetText("|cFFFFFF00Nova Raid Companion");
		inspectTalentsFrame.isInspectFrame = true;
		inspectTalentsFrame:ClearAllPoints();
	end
	--local guid = inspectFrameTalentsGUID;
	local guid = UnitGUID(InspectFrame.unit);
	if (guid) then
		if (InspectFrameCloseButton) then
			inspectTalentsFrame:SetPoint("TOPLEFT", InspectFrameCloseButton, "TOPRIGHT", 20, -8);
		else
			inspectTalentsFrame:SetPoint("TOPLEFT", InspectFrame, "TOPRIGHT", 20, -8);
		end
		local _, classEnglish, _, _, _, name, realm = GetPlayerInfoByGUID(guid);
		--[[local classID;
		for i = 1, GetNumClasses() do
			local className, classFile, id = GetClassInfo(i);
			if (classEnglish == classFile) then
				classID = id;
				break;
			end
		end]]
		local talentString, talentString2 = NRC:createTalentStringFromInspect(guid, true);
		if (talentString) then
			local glyphString, glyphString2 = NRC:createGlyphStringFromInspect(guid, true);
			--local isError = NRC:updateTalentFrame(name, talentString, inspectTalentsFrame, talentString2, nil, glyphString, glyphString2);
			NRC:openTalentFrame(name, talentString, inspectTalentsFrame, talentString2, nil, glyphString, glyphString2, nil, true);
			inspectTalentsFrame:SetScale(0.875);
			--if (not isError) then
				--inspectTalentsFrame:Show();
			--end
		end
		if (realm and realm ~= "" and realm ~= NRC.realm) then
			name = name .. "-" .. realm;
		end
		if (NRC.expansionNum > 2 and NRC.expansionNum < 5) then
			local isEnemy;
			local targetName = UnitName("target");
			if (name == targetName) then
				--Current target should always be the inspect target if hostile since they can't be raid frames to click on etc.
				isEnemy = UnitIsEnemy("player", "target");
			end
			if (not isEnemy) then
				NRC:sendComm("WHISPER", "glyreq " .. NRC.version, name);
			end
		end
	end
end

function NRC:hookTalentsFrame()
	if (inspectTalentsCheckBox or not InspectFrame) then
		return;
	end
	inspectTalentsCheckBox = CreateFrame("CheckButton", "NRCRaidStatusFrameCheckbox", InspectFrame, "ChatConfigCheckButtonTemplate");
	inspectTalentsCheckBox.Text:SetText("|cFFFFFF00" .. L["NRC Talents"]);
	inspectTalentsCheckBox.Text:SetFont(NRC.regionFont, 11);
	inspectTalentsCheckBox.Text:SetPoint("LEFT", inspectTalentsCheckBox, "RIGHT", -2, 1);
	inspectTalentsCheckBox.tooltip = L["inspectTalentsCheckBoxTooltip"];
	inspectTalentsCheckBox:SetFrameStrata("HIGH");
	inspectTalentsCheckBox:SetFrameLevel(9);
	inspectTalentsCheckBox:SetWidth(20);
	inspectTalentsCheckBox:SetHeight(20);
	inspectTalentsCheckBox:SetPoint("TOPRIGHT", InspectFrame, -105, -53);
	inspectTalentsCheckBox:SetHitRectInsets(0, 0, -10, 7);
	--inspectTalentsCheckBox:SetBackdropBorderColor(0, 0, 0, 1);
	inspectTalentsCheckBox:SetChecked(NRC.config.showInspectTalents);
	inspectTalentsCheckBox:SetScript("OnClick", function()
		local value = inspectTalentsCheckBox:GetChecked();
		NRC.config.showInspectTalents = value;
		if (not value) then
			if (inspectTalentsFrame) then
				inspectTalentsFrame:Hide();
			end
		else
			if (InspectFrame and InspectFrame:IsShown()) then
				openInspectTalentsFrame();
			end
		end
		NRC.acr:NotifyChange("NovaRaidCompanion");
	end);
	InspectFrame:HookScript("OnShow", function(self)
		if (NRC.config.showInspectTalents) then
			openInspectTalentsFrame();
		end
	end)
	InspectFrame:HookScript("OnHide", function(self)
		inspectFrameTalentsGUID = nil;
		if (_G["NRCInspectTalentFrame"]) then
			inspectTalentsFrame:Hide();
		end
	end)
	--Move checkbox depending on which tab is shown.
	if (NRC.expansionNum > 4) then
		InspectFrame:HookScript("OnShow", function(self)
			inspectTalentsCheckBox:SetPoint("TOPRIGHT", InspectFrame, -80, -40);
		end)
	else
		if (InspectPaperDollFrame) then
			InspectPaperDollFrame:HookScript("OnShow", function(self)
				inspectTalentsCheckBox:SetPoint("TOPRIGHT", InspectFrame, -105, -53);
			end)
		else
			NRC:debug("Missing InspectPaperDollFrame frame.");
		end
		if (InspectPVPFrame) then
			--Doesn't exist in era/sod.
			InspectPVPFrame:HookScript("OnShow", function(self)
				inspectTalentsCheckBox:SetPoint("TOPRIGHT", InspectFrame, -105, -38);
			end)
		end
		if (InspectTalentFrame) then
			InspectTalentFrame:HookScript("OnShow", function(self)
				inspectTalentsCheckBox:SetPoint("TOPRIGHT", InspectFrame, -105, -34);
			end)
		end
	end
end

--Update checkbox if we change via addon config.
function NRC:updateInspectTalentsCheckBoxFromConfig(value)
	if (InspectFrame and InspectFrame:IsShown()) then
		inspectTalentsCheckBox:SetChecked(value);
	end
	if (not value) then
		if (inspectTalentsFrame) then
			inspectTalentsFrame:Hide();
		end
	else
		if (InspectFrame and InspectFrame:IsShown()) then
			openInspectTalentsFrame();
		end
	end
end

local f = CreateFrame("Frame");
f:RegisterEvent("GROUP_LEFT");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ADDON_LOADED");
f:SetScript('OnEvent', function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		--If an addon loads the Blizzard_InspectUI before us then we load it with a hook instead of an ADDON_LOADED event.
		if (InspectFrame) then
			NRC:hookTalentsFrame();
		end
	elseif (event == "ADDON_LOADED") then
		local addon = ...;
		if (addon == "Blizzard_InspectUI") then
			NRC:hookTalentsFrame();
		end
	elseif (event == "GROUP_LEFT") then
		inspectSuccess = {};
		NRC:clearAllInspectdata();
	end
end)



--some test iterations
--[[local NRC.gearCache, waiting = {}, {};
local function buildInventoryFromInspect(guid, unit)
	if (unit and guid) then
		NRC.gearCache[guid] = nil;
		waiting[guid] = {};
		local updated;
		local cachingIssueFound;
		for k, v in pairs(inspectSlots) do
			local itemID = GetInventoryItemID(unit, k);
			if (itemID) then
				waiting[guid][k] = itemID;
			end
		end
		for slot, itemID in pairs(waiting[guid]) do
			local item = Item:CreateFromItemID(itemID);
			item:ContinueOnItemLoad(function()
				local itemLink = GetInventoryItemLink(unit, slot);
				if (itemLink) then
					local _, itemID2 = strsplit(":", itemLink);
					itemID2 = tonumber(itemID);
					if (itemID ~= itemID2) then
						debug("inspect itemID mismatch", itemID, itemID2);
					end
					if (not NRC.gearCache[guid]) then
						NRC.gearCache[guid] = {};
					end
					NRC.gearCache[guid][slot] = itemLink;
				else
					debug("have itemid but missing itemlink", itemID)
				end
				waiting[guid][slot] = nil;
				if (not next(waiting[guid])) then
					NRC.gearCache[guid].updated = GetServerTime();
					debug("gear inspect complete", UnitName(unit));
					updateSetBonusCache(guid);
					updateEnchantsCache(guid);
					if (isSOD) then
						sanctifiedCache[guid] = getSanctifiedCount(guid);
					end
					updateIssuesCache(guid);
				end
			end)
		end
	end
end]]

--[[local waiting = {};
function NRC:buildInventoryFromInspect(guid, unit, secondTry)
	--Don't use this for now, we don't want to keep inspecting for gear changes so it would be unreliable.
	if (guid and not unit) then
		unit = NRC:getUnitFromGUID(guid);
		if (not unit) then
			if (InspectFrame and InspectFrame.unit) then
				unit = InspectFrame.unit;
			end
		end
	end
	if (unit and guid) then
		if (not NRC:inOurGroup(guid)) then
			return;
		end
		local equipCount = 0;
		--local errorNum = 0;
		--local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(guid);
		--local nameRealm = name .. "-" ..  realm;
		NRC.gearCache[guid] = nil;
		waiting[guid] = {};
		local updated;
		local cachingIssueFound;
		local gear = {};
		for k, v in pairs(inspectSlots) do
			local itemID = GetInventoryItemID(unit, k);
			if (itemID) then
				waiting[guid][k] = itemID;
				equipCount = equipCount + 1;
			end
		end
		for slot, itemID in pairs(waiting[guid]) do
			local item = Item:CreateFromItemID(itemID);
			item:ContinueOnItemLoad(function()
				--if (currentInspectGUID == guid or unit == "player") then
					local itemLink = GetInventoryItemLink(unit, slot);
					if (itemLink) then
						local _, itemID2, enchantID = strsplit(":", itemLink);
						itemID2 = tonumber(itemID);
						if (itemID ~= itemID2) then
							NRC:debug("Inspect itemID mismatch", itemID, itemID2);
						end
						if (not NRC.gearCache[guid]) then
							NRC.gearCache[guid] = {};
						end
						--if (unit ~= "player") then
						--	NRC:debug("added gear from inspect", UnitName(unit), itemLink);
						--end
						NRC.gearCache[guid][slot] = itemLink;
						NRC.gearCache[guid].updated = GetServerTime();
					else
						NRC:debug("have itemid but missing itemlink", itemID)
					end
					waiting[guid][slot] = nil;
					if (not next(waiting[guid])) then
						if (unit ~= "player") then
							NRC:debug("gear inspect complete", UnitName(unit));
						end
						NRC:updateSetBonusCache(guid);
						NRC:updateEnchantsCache(guid);
						if (isSOD) then
							NRC.sanctifiedCache[guid] = getSanctifiedCount(guid);
						end
						NRC:updateIssuesCache(guid);
					end
				--end
			end)
		end
		if (equipCount < lowInspectSlotCount and guid ~= UnitGUID("player")) then
			--There seems to be a bug where not all items load.
			--Not sure if it's becaus I need to continue on load or some other issue.
			--Probably not a cache issue with GetInventoryItemLink() becaus INSPECT_READY fires before this?
			--Until I fix it I'll just reschedule another inspect in 10 seconds, or again in 30 if we've tried once already.
			if (inspectAgainQueue[guid]) then
				C_Timer.After(30, function()
					NRC:debug("Low armor count, requeueing inspect for:", UnitName(unit), equipCount, 30);
					NRC:inspect(guid);
				end);
			else
				inspectAgainQueue[guid] = true;
				C_Timer.After(5, function()
					NRC:debug("Low armor count, requeueing inspect for:", UnitName(unit), equipCount, 5);
					NRC:inspect(guid);
				end);
			end
		end
	end
end]]