------------------------------
---NovaRaidCompanion Talents--
------------------------------
local addonName, NRC = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");

local talentFrame;
local strsplit = strsplit;
local strsub = strsub;
local tonumber = tonumber;
local GetSpellLink = C_Spell and C_Spell.GetSpellLink or C_Spell.GetSpellLink;
local isMOP = NRC.isMOP;
local talentStringType = 1;
local isTierTalents = NRC.isTierTalents;
local talentRowCount = NRC.talentRowCount;

--[[local function getTalentStringType(talentString)
	if (talentString) then
		--Check hyphen count to work out what type of talent string, if less than 3 it's MoP+ tiers talent structure.
		local _, hyphens = string.gsub(talentString, "%-", "");
		if (hyphens < 3) then
			return 2;
		end
	end
	return 1;
end]]

function NRC:loadTalentFrame()
	if (talentFrame) then
		return;
	end
	if (NRC.isMOP) then
		talentFrame = NRC:createTalentTiersFrame("NRCTalentFrame", 644, 408, 0, 200, 3);
	elseif (NRC.isWrath) then
		talentFrame = NRC:createTalentFrame("NRCTalentFrame", 870, 540, 0, 200, 3);
	else
		talentFrame = NRC:createTalentFrame("NRCTalentFrame", 870, 480, 0, 200, 3);
	end
	talentFrame.fs:SetText("|cFFFFFF00Nova Raid Companion");
	talentFrame:SetScript("OnMouseDown", function(self, button)
		if (button == "LeftButton" and not self.isMoving) then
			self:StartMoving();
			self.isMoving = true;
		end
	end)
	talentFrame:SetScript("OnMouseUp", function(self, button)
		if (button == "LeftButton" and self.isMoving) then
			self:StopMovingOrSizing();
			self.isMoving = false;
			talentFrame:SetUserPlaced(false);
			NRC.db.global[talentFrame:GetName() .. "_point"], _, NRC.db.global[talentFrame:GetName() .. "_relativePoint"], 
					NRC.db.global[talentFrame:GetName() .. "_x"], NRC.db.global[talentFrame:GetName() .. "_y"] = talentFrame:GetPoint();
		end
	end)
	talentFrame:SetScript("OnHide", function(self)
		if (self.isMoving) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
		talentFrame.name = nil;
		talentFrame.talentString = nil;
		talentFrame.talentString2 = nil;
		talentFrame.showOffspec = nil;
		talentFrame.glyphString = nil;
		talentFrame.glyphString2 = nil;
		talentFrame.isInspect = nil;
		talentFrame.fromRaidStatus = nil;
	end)
	if (NRC.db.global[talentFrame:GetName() .. "_point"]) then
		talentFrame.ignoreFramePositionManager = true;
		talentFrame:ClearAllPoints();
		talentFrame:SetPoint(NRC.db.global[talentFrame:GetName() .. "_point"], nil, NRC.db.global[talentFrame:GetName() .. "_relativePoint"],
				NRC.db.global[talentFrame:GetName() .. "_x"], NRC.db.global[talentFrame:GetName() .. "_y"]);
		talentFrame:SetUserPlaced(false);
	end
	talentFrame.onUpdateFunction = "updateTalentFrame";
	--if (NRC.isMOP and NRC.isDebug) then
		--NRC:updateTalentFrame("Novatest", "3-123000", nil, nil, nil)
		--NRC:openTalentFrame("Novatest", "3-123000-1")
	--	NRC:createGlyphStringFromInspect(UnitGUID("player"))
	--end
end

function NRC:openTalentFrame(name, talentString, frame, talentString2, showOffspec, glyphString, glyphString2, guid, isInspect, fromRaidStatus)
	local talentFrame = frame or talentFrame;
	 local isError = NRC:updateTalentFrame(name, talentString, talentFrame, talentString2, showOffspec, glyphString, glyphString2, guid, isInspect, fromRaidStatus);
	 if (not isError) then
	 	talentFrame:Show();
	 	talentFrame:Raise();
	 end
end

function NRC:updateTalentFrame(name, talentString, frame, talentString2, showOffspec, glyphString, glyphString2, guid, isInspect, fromRaidStatus)
	local talentFrame = frame or talentFrame;
	
	--For OnUpdate save some data.
	local name = name or talentFrame.name;
	local talentString = talentString or talentFrame.talentString;
	local talentString2 = talentString2 or talentFrame.talentString2;
	local showOffspec = showOffspec or talentFrame.showOffspec;
	local glyphString = glyphString or talentFrame.glyphString;
	local glyphString2 = glyphString2 or talentFrame.glyphString2;
	local isInspect = isInspect or talentFrame.isInspect;
	local fromRaidStatus = fromRaidStatus or talentFrame.fromRaidStatus;
	talentFrame.name = name;
	talentFrame.talentString = talentString;
	talentFrame.talentString2 = talentString2;
	talentFrame.showOffspec = showOffspec;
	talentFrame.glyphString = glyphString;
	talentFrame.glyphString2 = glyphString2;
	talentFrame.isInspect = isInspect;
	talentFrame.fromRaidStatus = fromRaidStatus;
	--if (not NRC.raidStatusCache and not isInspect) then
	if (fromRaidStatus) then
		--Check if talents have changed while window is still open, only when clicked from raid status window during a raid.
		--A check is made in the raid status OnClick handler to make sure it's a like raid status viewing and not a snapshot.
		if (talentString and NRC.talents[name] and talentString ~= NRC.talents[name]) then
			talentString = NRC.talents[name];
			talentFrame.talentString = talentString;
		end
		if (talentString2 and NRC.talents2[name] and talentString2 ~= NRC.talents2[name]) then
			talentString2 = NRC.talents[name];
			talentFrame.talentString2 = talentString2;
		end
	end
	
	if (guid and not frame.isInspectFrame and not NRC.raidStatusCache) then
		--If this is opened from the raid status window and isn't a cache then reinspect the player to catch any out of range changes.
		--The guid isn't saved on the frame so this only inspects when first opened and not OnUpdate.
		NRC:inspect(guid);
	end
	
	talentFrame.player = name;
	--talentFrame.activeSpec = talentString;
	--talentFrame.offSpec = talentString2;
	local displayTalentString = talentString;
	if (talentString2) then
		if (showOffspec) then
			displayTalentString = talentString2;
			talentFrame.button:SetScript("OnClick", function(self, arg)
				talentFrame.showOffspec = nil;
				NRC:updateTalentFrame(name, talentString, frame, talentString2, nil, glyphString, glyphString2, guid, isInspect, fromRaidStatus);
			end)
			talentFrame.button:SetText("View Active Talents");
		else
			talentFrame.button:SetScript("OnClick", function(self, arg)
				NRC:updateTalentFrame(name, talentString, frame, talentString2, true, glyphString, glyphString2, guid, isInspect, fromRaidStatus);
			end)
			talentFrame.button:SetText("View Offspec Talents");
		end
		talentFrame.button:Show();
	else
		talentFrame.button:Hide();
	end
	if (not displayTalentString) then
		return true;
	end
	if (NRC.isMOP) then
		--Offspec inspect isn't working yet on the beta, disable these for now.
		talentFrame.fs4:Hide();
		talentFrame.button:Hide();
		--[[if (talentString2) then
			--Offspec inspect isn't working yet on the beta, disable these for now.
			talentFrame:SetSize(644, 428);
			talentFrame.fs4:ClearAllPoints();
			talentFrame.button:ClearAllPoints();
			talentFrame.fs4:SetPoint("TOP", -100, -24);
			talentFrame.button:SetPoint("LEFT", talentFrame.fs4, "RIGHT", 10, 0);
		else
			talentFrame:SetSize(644, 408);
		end]]
		local classID, talents, specIndex = strsplit("-", displayTalentString, 3);
		classID = tonumber(classID);
		local class, classEnglish = GetClassInfo(classID);
		talentFrame.updateTalentsDisplay(classEnglish, classID, talents);
		talentFrame.titleTexture:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
		talentFrame.titleTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(classEnglish)]));
		talentFrame.titleTexture:SetSize(20, 20);
		local specID, talentCount, specName, specIcon, specIconPath, treeData = NRC:getSpecFromTalentString(displayTalentString);
		--trees = {strsplit("-", trees, 4)};
		--talentFrame.disableAllTalentFrames();
		local _, _, _, classHex = NRC.getClassColor(classEnglish);
		local text = "|c" .. classHex .. name .. "|r";
		talentFrame.titleTexture2:SetTexture(specIcon);
		talentFrame.titleTexture2:SetSize(18, 18);
		if (not specName) then
			specName = "No Spec"
		end
		text = text .. "  |cFF9CD6DE" .. specName .. "|r";
		if (talentString2) then
			if (showOffspec) then
				talentFrame.fs4:SetText("|cFFFF6900(Offspec Talents)");
			else
				talentFrame.fs4:SetText("|cFF3CE13F(Active Talents)");
			end
		else
			talentFrame.fs4:SetText("");
		end
		talentFrame.fs2:SetText(text);
		local totalPointsSpent = NRC:getTotalTalentCount(talentString);
		if (totalPointsSpent == 0) then
			talentFrame.fs3:SetText("|cFFFF2222" .. totalPointsSpent .. " |cFFFFFF00Points Spent");
		else
			talentFrame.fs3:SetText("|cFFFFFF00" .. totalPointsSpent .. " Points Spent");
		end
	else
		local classID, trees = strsplit("-", displayTalentString, 2);
		classID = tonumber(classID);
		local class, classEnglish = GetClassInfo(classID);
		talentFrame.setClass(classEnglish, classID);
		local specID, talentCount, specName, specIcon, specIconPath, treeData = NRC:getSpecFromTalentString(displayTalentString);
		trees = {strsplit("-", trees, 4)};
		talentFrame.disableAllTalentFrames();
		local _, _, _, classHex = NRC.getClassColor(classEnglish);
		local text = "|c" .. classHex .. name .. "|r";
		if (not specName) then
			specName = "No Spec"
		end
		text = text .. "  |cFF9CD6DE(" .. treeData[1] .. "/" .. treeData[2] .. "/" .. treeData[3] .. ")|r  |cFF9CD6DE" .. specName .. "|r";
		if (talentString2) then
			if (showOffspec) then
				talentFrame.fs4:SetText("|cFFFF6900(Offspec Talents)");
			else
				talentFrame.fs4:SetText("|cFF3CE13F(Active Talents)");
			end
		else
			talentFrame.fs4:SetText("");
		end
		talentFrame.fs2:SetText(text);
		local totalPointsSpent = NRC:getTotalTalentCount(displayTalentString);
		if (totalPointsSpent == 0) then
			talentFrame.fs3:SetText("|cFFFF2222" .. totalPointsSpent .. " |cFFFFFF00Points Spent");
		else
			talentFrame.fs3:SetText("|cFFFFFF00" .. totalPointsSpent .. " Points Spent");
		end
		talentFrame.titleTexture:SetTexture(specIcon or 134400);
		local talentData = NRC:getTalentData(classEnglish);
		for tree, talents in ipairs(trees) do
			talentFrame.trees[tree].fs:SetText("|cFFFFFF00" .. talentData[tree].info.name .. "|r |cFF9CD6DE(" .. treeData[tree] .. ")|r");
			--Iterate talents in each tree.
			for i = 1, #talents do
				local talent = tonumber(strsub(talents, i, i));
				local frame = talentFrame.talentFrames[tree][i];
				if (not frame) then
					--If a frame is missing then there's a talent data mismatch and likely trying to open an entry in raid log from previois expansion.
					NRC:debug("Talent frame data mismatch.");
					return true;
				end
				if (talent > 0) then
					frame.currentRank = talent;
					frame.texture:SetDesaturated();
					frame:SetAlpha(1);
					frame.rankTexture:Show();
					frame.rankFS:Show();
					if (talent < frame.maxRank) then
						frame.rankFS:SetText("|c" .. GREEN_FONT_COLOR:GenerateHexColor() .. talent);
						frame.outerTexture:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
					else
						frame.outerTexture:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
						frame.rankFS:SetText("|c" .. NORMAL_FONT_COLOR:GenerateHexColor() .. talent);
					end
				else
					frame:SetAlpha(0.7);
					frame.currentRank = 0;
				end
			end
		end
	end
	--I need to fix up the glyphs frame for cata before enabling this again.
	--if (not NRC.isWrath) then
	--	talentFrame.glyphs:Hide();
	--end
	if (showOffspec or NRC.expansionNum < 3) then
		--Not displaying glyphs for offspec yet, maybe in later version.
		--The data sync will need to rewritten to include offspec glyphs and keep track of which is the active spec since it can't be inspected.
		talentFrame.glyphs:Hide();
	else
		--local glyphText = "|cFF9CD6DEMajor:|r\n";
		--glyphText = glyphText .. "(1) Glyph of Test\n";
		--glyphText = glyphText .. "(2) Glyph of Test2\n";
		--glyphText = glyphText .. "(3) Empty Slot\n";
		--glyphText = glyphText .. "|cFF9CD6DEMinor:|r\n";
		--glyphText = glyphText .. "(1) Glyph of Test\n";
		--glyphText = glyphText .. "(2) Glyph of Test2\n";
		--glyphText = glyphText .. "(3) Empty Slot";
		if (glyphString2 and showOffspec) then
			local data = NRC:createGlyphDataFromString(glyphString2);
			if (talentFrame.updateGlyphsDisplay) then
				--For cata onwards we load the glyphs graphical display.
				NRC:updateGlyphGraphicalFrame(data, talentFrame, name, glyphString2);
			else
				NRC:updateGlyphFrame(data, talentFrame);
				C_Timer.After(0.1, function()
					NRC:updateGlyphFrame(data, talentFrame);
				end)
				talentFrame.glyphs:Show();
			end
		elseif (glyphString) then
			local data = NRC:createGlyphDataFromString(glyphString);
			if (talentFrame.updateGlyphsDisplay) then
				--For cata onwards we load the glyphs graphical display.
				NRC:updateGlyphGraphicalFrame(data, talentFrame, name, glyphString)
			else
				NRC:updateGlyphFrame(data, talentFrame);
				C_Timer.After(0.1, function()
					NRC:updateGlyphFrame(data, talentFrame);
				end)
				talentFrame.glyphs:Show();
			end
		elseif (NRC.glyphs[name]) then
			local data = NRC:createGlyphDataFromString(NRC.glyphs[name]);
			if (talentFrame.updateGlyphsDisplay) then
				--For cata onwards we load the glyphs graphical display.
				NRC:updateGlyphGraphicalFrame(data, talentFrame, name, NRC.glyphs[name])
			else
				NRC:updateGlyphFrame(data, talentFrame);
				C_Timer.After(0.1, function()
					NRC:updateGlyphFrame(data, talentFrame);
				end)
				talentFrame.glyphs:Show();
			end
		else
			if (talentFrame.glyphs2) then
				--For cata onwards we load the glyphs graphical display.
				talentFrame.glyphs2:Hide();
			end
			talentFrame.glyphs:Hide();
		end
	end
end

function NRC:updateGlyphGraphicalFrame(data, frame, name, glyphString)
	frame.updateGlyphsDisplay(glyphString);
	NRC:updateGlyphFrame(data, frame, name, glyphString);
	C_Timer.After(0.1, function()
		NRC:updateGlyphFrame(data, frame);
	end)
	frame.glyphs:Show();
	--frame.glyphs2:ClearAllPoints();
	--frame.glyphs2:SetPoint("TOPLEFT", frame.glyphs, "BOTTOMLEFT", 1, -1);
	
	frame.glyphs2:ClearAllPoints();
	frame.glyphs2:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 2);
	frame.glyphs:ClearAllPoints();
	frame.glyphs:SetPoint("TOPLEFT", frame.glyphs2, "BOTTOMLEFT", 0, -1);
	frame.glyphs2:Show();
end

function NRC:updateGlyphFrame(data, frame, name, glyphString)
	if (not frame or NRC.expansionNum < 5) then
		--Works for wrath and expansions MoP+.
		--Changed to now only work in MoP+.
		return;
	end
	for i = 1, 6 do
		frame.glyphs["fs" .. i]:SetText("");
	end
	local width = 100;
	if (data) then
		for i = 1, 6 do
			if (data[i] and data[i] > 0) then
				local spell = Spell:CreateFromSpellID(data[i])
				if (spell and not spell:IsSpellEmpty()) then
					spell:ContinueOnSpellLoad(function()
						local name = (spell:GetSpellName() or "Unknown Glyph");
						local _, class = GetClassInfo(data.class);
						--local icon = GetSpellTexture(data[i]);
						local icon;
						if (NRC.expansionNum > 4) then
							icon = C_Spell.GetSpellTexture(data[i]);
						end
						if (not icon) then
							if (class) then
								if (i < 4) then
									icon = "Interface\\Icons\\Inv_glyph_major" .. strlower(class);
								else
									icon = "Interface\\Icons\\Inv_glyph_minor" .. strlower(class);
								end
							end
						end
						local texture = "|T134400:0|t";
						if (icon) then
							texture = "|T" .. icon .. ":0|t";
						end
						local itemLink = GetSpellLink(data[i]);
						frame.glyphs["fs" .. i]:SetText(texture .. " " .. (itemLink or "[" .. name .. "]"));
						local w = frame.glyphs["fs" .. i]:GetWidth();
						if (w > width) then
							width = w;
						end
					end)
				else
					frame.glyphs["fs" .. i]:SetText("Error");
				end
			else
				frame.glyphs["fs" .. i]:SetText("|T134400:0|t [Empty Slot]");
			end
		end
	else
		frame.glyphs.fs1:SetText("No glyph data found.");
	end
	frame.width = width + 20;
	frame.glyphs:SetSize(frame.width, 190);
	if (frame:GetName() == "NRCInspectTalentFrame") then
		frame.glyphs:SetScale(0.9);
	else
		frame.glyphs:SetScale(0.8);
	end
	--If name is included then it's a data update and we should check if talent inspect is open waiting for glyph data.
	if (name) then
		--If inspect frame or supplied frame is open then show new glyph data.
		if (NRCInspectTalentFrame and NRCInspectTalentFrame:IsShown() and NRCInspectTalentFrame.player == name) then
			NRCInspectTalentFrame.glyphs:Show();
		end
		if (frame and frame:IsShown() and frame.frame == name) then
			frame.glyphs:Show();
		end
	end
end

--Get players talents by name and encounter.
function NRC:getTalentsFromEncounter(name, logID, encounterID, attemptID)
	local data = NRC.db.global.instances[logID];
	if (data) then
		--Check if we have an exact match for this encounter and/or attemptID.
		if (data.encounters) then
			local talentCache = {};
			if (attemptID) then
				--If attemptID we want the specific attempt.
				for k, v in ipairs(data.encounters) do
					--Get last recorded talents before this encounter.
					if (k == attemptID) then
						if (v.talentCache and v.talentCache[name]) then
							talentCache = v.talentCache[v.talentCache];
						end
					end
				end
			else
				for k, v in ipairs(data.encounters) do
					--If attemptID not specified then get any talents for this encounter.
					if (v.encounterID == encounterID) then
						if (v.talentCache and v.talentCache[name]) then
							talentCache = v.talentCache[name];
						end
					end
				end
			end
			--Encounter talents are only recorded if they changed so we need to do some checking of other encounters before this one.
			if (not talentCache) then
				--Get last recorded talents before this encounter.
				local backupTalents
				for k, v in ipairs(data.encounters) do
					if (v.talentCache and v.talentCache[name]) then
						backupTalents = v.talentCache[name];
					end
					--Only break if we have talents found because maybe the bosses were killed out of order and we want las known before.
					if (backupTalents) then
						--Only before this attemptID if specified.
						if (attemptID and k == attemptID) then
							break;
						end
						--encounterIDs are in numerical order mostly so we can check before it too if specified.
						if (encounterID and encounterID > v.encounterID) then
							break;
						end
					end
				end
				if (backupTalents) then
					talentCache = backupTalents;
				end
			end
			return talentCache;
		end
	end
end

--Get whole raids talents table by encounter.
function NRC:getAllTalentsFromEncounter(logID, encounterID, attemptID)
	local data = NRC.db.global.instances[logID];
	if (data) then
		--Check if we have an exact match for this encounter and/or attemptID.
		if (data.encounters) then
			local talentCache = {};
			local glyphCache = {};
			if (attemptID) then
				--If attemptID we want the specific attempt.
				for k, v in ipairs(data.encounters) do
					--Get last recorded talents before this encounter.
					if (k == attemptID) then
						if (v.talentCache) then
							talentCache = v.talentCache;
						end
						if (v.glyphCache) then
							glyphCache = v.glyphCache;
						end
					end
				end
			else
				for k, v in ipairs(data.encounters) do
					--If attemptID not specified then get any talents for this encounter.
					if (v.encounterID == encounterID) then
						if (v.talentCache) then
							talentCache = v.talentCache;
						end
						if (v.glyphCache) then
							glyphCache = v.glyphCache;
						end
					end
				end
			end
			--Encounter talents are only recorded if they changed so we need to do some checking of other encounters before this one.
			--Check if any group members are missing because they may only be cached from the first boss if talents haven't changed.
			--Glyphs are always recorded.
			if (data.group and next(data.group)) then
				for k, v in pairs(data.group) do
					local name = v.name;
					if (name) then
						if (not talentCache[name]) then
							local backupTalents;
							--Get last recorded talents before this encounter.
							for k, v in ipairs(data.encounters) do
								if (v.talentCache and v.talentCache[name]) then
									backupTalents = v.talentCache[name];
								end
								--Only break if we have talents found because maybe the bosses were killed out of order and we want las known before.
								if (backupTalents) then
									--Only before this attemptID if specified.
									if (attemptID and k == attemptID) then
										break;
									end
									--As a backup.
									--encounterIDs are in numerical order mostly so we can check before it too if specified.
									if (encounterID and encounterID > v.encounterID) then
										break;
									end
								end
							end
							if (backupTalents) then
								talentCache[name] = backupTalents;
							end
						end
					end
				end
			else
				--If no group then we're probably soloing dungeons so just check ourself.
				local name = data.playerName;
				local backupTalents;
				for k, v in ipairs(data.encounters) do
					if (v.talentCache and v.talentCache[name]) then
						backupTalents = v.talentCache[name];
					end
					--Only break if we have talents found because maybe the bosses were killed out of order and we want las known before.
					if (backupTalents) then
						--Only before this attemptID if specified.
						if (attemptID and k == attemptID) then
							break;
						end
						--As a backup.
						--encounterIDs are in numerical order mostly so we can check before it too if specified.
						if (encounterID and encounterID > v.encounterID) then
							break;
						end
					end
				end
				if (backupTalents) then
					talentCache[name] = backupTalents;
				end
			end
			if (talentCache) then
				return talentCache, glyphCache;
			end
		end
	end
end

function NRC:getSpecFromTalentString(talentString)
	if (talentString) then
		if (isTierTalents) then
			local classID, talents, specIndex = strsplit("-", talentString, 3);
			if (specIndex) then
				classID = tonumber(classID);
				specIndex = tonumber(specIndex);
				--if specIndex is 5 that means no trained spec.
				if (specIndex == 5) then
					return;
				else
					local _, className = GetClassInfo(classID);
					local talentCount = NRC:getTotalTalentCount(talentString);
					--local specName, specIcon, specIconPath = NRC.getSpecData(classID, specIndex);
					--local _, specName, _, specIcon = GetSpecializationInfoForClassID(classID, specIndex);
					--Workaround posted by MrBuds until GetSpecializationInfoForClassID() gets fixed.
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
					local specID = specsByClassID[classID][specIndex];
					if (not specID) then
						--Likely trying to view a raid's talents that happened during previous expansion.
						return;
					end
				    local _, specName, _, specIcon = GetSpecializationInfoByID(specID);
				    --print(specIndex, talentCount, specName, specIcon, nil, nil, className)
					return specIndex, talentCount, specName, specIcon, nil, nil, className;
				end
			end
		else
			local classID, treeData = strsplit("-", talentString, 2);
			if (not classID) then
				return;
			end
			classID = tonumber(classID);
			local trees = {strsplit("-", treeData, 4)};
			local specID = 0;
			local talentCount = 0;
			local treeData = {};
			for k, v in ipairs(trees) do
				local treeCount = 0;
				--Count talents in each tree.
				for i = 1, #v do
				    local num = tonumber(strsub(v, i, i));
				  	treeCount = treeCount + num;
				end
				if (treeCount > talentCount) then
					talentCount = treeCount;
					specID = k;
				end
				treeData[k] = treeCount;
			end
			local specName, specIcon, specIconPath = NRC.getSpecData(classID, specID);
			local _, className = GetClassInfo(classID)
			return specID, talentCount, specName, specIcon, specIconPath, treeData, className;
		end
	end
end

--In wrath GetTalentInfo() is no longer sorted by index by instead random, so we need to sort it when creating strings.
--So we need to feed this a talent table and sort it for we can create our in order talent string.
function NRC:createTalentStringFromTable(data)
	--Example talent data.
	--[[data = {
		classID = 1,
		[1] = { --Trees.
			[1] = {	--Data as gotten by GetTalentInfo(tree, 1), not in index order anymore for wrath.
				rank = 5,
				row = 2,
				column = 4,
			}
		}
		[2] = {
		[3] = {
	}]]
	--Sort by row and column.
	for k, v in ipairs(data) do
		table.sort(v, function(a, b)
			if (a.row == b.row) then
				return a.column < b.column;
			else
				return a.row < b.row;
			end
		end)
	end
	local talentString = tostring(data.classID);
	local hasTalentData;
	for treeID, treeData in ipairs(data) do
		hasTalentData = true;
		local found;
		local treeString = "";
		for talentID, talentData in ipairs(treeData) do
			treeString = treeString .. talentData.rank;
			if (talentData.rank > 0) then
				found = true;
			end
		end
		treeString = strmatch(treeString, "^(%d-)0*$");
		if (found) then
			talentString = talentString .. "-" .. treeString;
		else
			talentString = talentString .. "-0";
		end
	end
	if (not hasTalentData) then
		return talentString .. "-0-0-0"
	else
		return talentString;
	end
end

--Player only.
function NRC:createTalentString()
	return NRC:createTalentStringFromInspect(UnitGUID("player"));
	--[[local talentString, talentString2;
	if (NRC.isRetail) then
		talentString = "0-0-0";
	elseif (isTierTalents) then
		local _, _, classID = UnitClass("player");
		talentString = tostring(classID) .. "-";
		for i = 1, talentRowCount do
			local tierAvailable, selectedTalentColumn, tierUnlockLevel = GetTalentTierInfo(i, C_SpecializationInfo.GetActiveSpecGroup(), nil, "player");
			if (not selectedTalentColumn) then
				--First logon for chars in the beta this is nil, may aswell add a check, probably happens for boosted chars too.
				return;
			end
			talentString = talentString .. selectedTalentColumn;
		end
		local specID = C_SpecializationInfo.GetSpecialization(nil, nil, C_SpecializationInfo.GetActiveSpecGroup());
		talentString = talentString .. "-" .. specID;
	else
		local _, _, classID = UnitClass("player");
		talentString = tostring(classID);
		--Seems all 3 clients are using the new out of order system now.
		--if (NRC.isWrath or NRC.isTBC or NRC.isClassic) then
			local data = {
				classID = classID,
			};
			for tab = 1, GetNumTalentTabs() do
				data[tab] = {};
				for i = 1, GetNumTalents(tab) do
					local name, _, row, column, rank = GetTalentInfo(tab, i);
					--This was changed because there were bugs in cata with GetTalentInfo().
					--Arcane mage has an empty entry at talent 21, and the real 21 was at index 22.	
					if (name) then
						local t = {
							rank = rank,
							row = row,
							column = column,
						};
						tinsert(data[tab], t);
					end
				end
			end
			talentString = NRC:createTalentStringFromTable(data);
	end
	return talentString;]]
end

--In MoP+ tabIndex here is the row index, and no need for count check in mop+.
function NRC:hasTalent(name, tabIndex, talentIndex, count)
	if (name and NRC.talents[name]) then
		if (isTierTalents) then
			local classID, talents, specID = strsplit("-", NRC.talents[name], 3);
			local rows = {};
			string.gsub(talents, ".", function(c) table.insert(rows, c) end);
			if (rows[tabIndex] and tonumber(rows[tabIndex]) == talentIndex) then
				--No need to check count, it's always only 1 talent trained in MoP+.
				return true;
			end
		else
			local classID, talents = strsplit("-", NRC.talents[name], 2);
			local trees = {strsplit("-", talents, 4)};
			if (trees[tabIndex]) then
				local talent = strsub(trees[tabIndex], talentIndex, talentIndex);
				if (talent and tonumber(talent)) then
					if (tonumber(talent) >= count) then
						return true;
					end
				end
			end
		end
	end
end

function NRC:hasGlyph(name, spellID)
	if (name and NRC.glyphs[name]) then
		local classID, glyphs = strsplit("-", NRC.glyphs[name], 2);
		local spellIDs = {strsplit("-", glyphs, 4)}
		for k, v in pairs(spellIDs) do
			if (tonumber(v) == spellI) then
				return true;
			end
		end
	end
end

function NRC:getTalentCount(name, tabIndex, talentIndex)
	if (name and NRC.talents[name]) then
		local classID, talents = strsplit("-", NRC.talents[name], 2);
		local trees = {strsplit("-", talents, 4)};
		if (trees[tabIndex]) then
			local talent = strsub(trees[tabIndex], talentIndex, talentIndex);
			if (talent) then
				return tonumber(talent);
			end
		end
	end
	return 0;
end

--Mapped to expansion numer.
local maxTalentCountLevels = {
	[1] = 51,
	[2] = 61,
	[3] = 71,
	[4] = 41,
	[5] = 6,
	[6] = 7,
	[7] = 7,
};

local function getMaxTalentPoints(level)
	local max = 0;
	if (level) then
		local count = maxTalentCountLevels[NRC.expansionNum];
		if (count) then
			if (NRC.expansionNum == 4) then
				--Cata.
				--You will get your first point at level 10, just like now, but from then on you'll be getting a talent point every odd level until you hit 81.
				--Then, from 81 to 85, you'll get a point for every level.
				if (level == 10) then
					max = 1;
				elseif (level < 81) then
					max = floor((level - 9) / 2) + 1;
				else
					max = count - (85 - level);
				end
			elseif (NRC.expansionNum == 5) then
				--MoP and onwards just return max for now, a table needs creating for lower levels since they don't just get 1 per level.
				--Not accurate for dk's for a few levels in starter zone but that's fine.
				if (level < 30) then
					max = 1;
				elseif (level < 45) then
					max = 2;
				elseif (level < 60) then
					max = 3;
				elseif (level < 75) then
					max = 4;
				elseif (level < 90) then
					max = 5;
				else
					max = count;
				end
			elseif (NRC.expansionNum > 5) then
				--WoD and onwards just return max for now.
				max = count;
			else
				--Classic/TBC/Wrath.
				max = count - (60 - level);
			end
		end
	end
	if (max < 0) then
		max = 0;
	end
	return max;
end

function NRC:getTotalTalentCount(talentString, level)
	local count, unspent = 0;
	if (talentString) then
		if (isTierTalents) then
			local classID, talents, specID = strsplit("-", talentString);
			--Insert each character in our talent string to a table.
			local rows = {};
			string.gsub(talents, ".", function(c) table.insert(rows, c) end);
			for k, v in pairs(rows) do
				if (v ~= "0") then
					count = count + 1;
				end
			end
		else	
			--Classic talents string.
			local trees = {strsplit("-", talentString, 4)};
			for k, v in ipairs(trees) do
				--First is classID, skip that.
				if (k > 1) then
					for i = 1, #v do
					    local c = strsub(v, i, i);
					    count = count + c;
					end
				end
			end
		end
	end
	local maxTalentPoints = getMaxTalentPoints(level);
	return count, maxTalentPoints - count; --Should be changed to GetNumUnspentTalents() if it's in all flavours.
end

--Return a copy of the current raid talents from out talent cache (only current raid members).
function NRC:copyRaidTalents()
	local obj = {};
	local me = UnitName("player");
	for k, v in pairs(NRC.talents) do
		if (NRC:inOurGroup(k) or k == me) then
			obj[k] = v;
		end
	end
	if (next(obj)) then
		local talents = NRC:tableCopy(obj);
		return talents;
	end
end

function NRC:copyRaidGlyphs()
	local obj = {};
	local me = UnitName("player");
	for k, v in pairs(NRC.glyphs) do
		if (NRC:inOurGroup(k) or k == me) then
			obj[k] = v;
		end
	end
	if (next(obj)) then
		local glyphs = NRC:tableCopy(obj);
		return glyphs;
	end
end

function NRC:createGlyphString()
	if (NRC.expansionNum <3) then --or not GetNumGlyphSockets? Changed to an expanion check instead incase the put this func in a namespace for later clasic expansions.
		return;
	end
	if (NRC.expansionNum > 4) then
		--In cata and mop the returns structure changes, use the inspect func for our own glyphs too.
		return NRC:createGlyphStringFromInspect(UnitGUID("player"));
	end
	--For wrath and cata use this old func instead.
	local _, _, classID = UnitClass("player");
	local glyphString, glyphString2 = classID, classID;
	local activeSpec = GetActiveTalentGroup();
	local offSpec = (activeSpec == 1 and 2 or 1);
	local temp = {};
	local count = 0;
	--This way should be used for the graphical display to keep sockets in proper order. See: NRC:createGlyphStringFromInspect() in Inspect.lua
	--But for cata and lower we have no graphical display because there's no inspect and I haven't made a display frame for prime glyphs so just use the old way below.
	--ALSO GetGlyphSocketInfo() has a different return order for cata than mop, if we ever put a graphical display in cata/wrath we need to change the retuena.
	--MoP has 5 returns with spellID moved up to 4th, cata and wrath have 4 returns with spellID in 3rd spot.
	--[[local glyphMap = { --First 3 major, second 3 minor.
		[1] = 2, --Major slot 1.
		[2] = 4, --Major slot 2.
		[3] = 6, --Major slot 3.
		[4] = 1, --Minor slot 1.
		[5] = 3, --Minor slot 2.
		[6] = 5, --Minor slot 3.
	};
	--Active spec.
	for k, v in ipairs(glyphMap) do
		local enabled, type, index, spellID, icon = GetGlyphSocketInfo(v, activeSpec);
		glyphString = glyphString .. "-" .. (spellID or 0);
	end
	--Offspec.
	for k, v in ipairs(glyphMap) do
		local enabled, type, index, spellID, icon = GetGlyphSocketInfo(v, offSpec);
		glyphString2 = glyphString2 .. "-" .. (spellID or 0);
	end]]
	
	for i = 1, GetNumGlyphSockets() do
		local enabled, type, spellID, icon = GetGlyphSocketInfo(i, activeSpec);
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
		local enabled, type, spellID, texture = GetGlyphSocketInfo(i, activeSpec);
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
		local enabled, type, spellID, icon = GetGlyphSocketInfo(i, offSpec);
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
		local enabled, type, spellID, texture = GetGlyphSocketInfo(i, offSpec);
		if (type == 2) then
			count = count + 1;
			temp[count] = spellID or 0;
		end
	end
	table.sort(temp, function(a, b) return a > b end);
	for i = 1, 3 do
		glyphString2 = glyphString2 .. "-" .. (temp[i] or 0);
	end
	--We're only using current spec glyph string atm, probably add dual spec support later.
	--glyphString2 isn't used by any funcs yet.
	--Glyph data can't be inspected and only gets sent others with the addon so mainspec will always be sent.
	--Mainspec glyphs should always be updated by others with the addon so inspecting main spec should always be in sync.
	--On the inspect frame we only display glyphs for main spec.
	return glyphString, glyphString2;
end

function NRC:createGlyphDataFromString(glyphString)
	local temp = {strsplit("-", glyphString)};
	local data = {};
	for k, v in pairs(temp) do
		if (k == 1) then
			data.class = tonumber(v);
		else
			data[k - 1] = tonumber(v);
		end
	end
	return data;
end