----------------------------------
---NovaRaidCompanion Raid Status--
----------------------------------

--The way frames are handled here could be done a lot better now I know more, one day..

local addonName, NRC = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");
local raidStatusFrame;
local specialSlot, specialSlot2, specialSlot3, specialSlot4, flaskSlot, foodSlot, scrollSlot, intSlot, fortSlot, spiritSlot, shadowSlot, motwSlot, palSlot, duraSlot, worldBuffsSlot;
local armorSlot, holyResSlot, fireResSlot, natureResSlot, frostResSlot, shadowResSlot, arcaneResSlot, weaponEnchantsSlot, talentsSlot;
local extraDataTable = {};
local slotCount, lastRaidRequest, columCount = 0, 0, 0;
local readyCheckStatus, readyCheckRunning, readyCheckEndedTimer, readyCheckEndedTimer2 = {};
local fadeOutTimer;
local worldBuffDurations = true;
local InCombatLockdown = InCombatLockdown;
local lowDurationTime = 300;
local lastOpened = 0;
local numWorldBuffs = 0; --Counted further down when loading db.
NRC.firstRaidStatusUpdate = true;
local getClassColor = NRC.getClassColor;
local isClassic = NRC.isClassic;
local isSOD = NRC.isSOD;
--local isMOP = NRC.isMOP;
local expansionNum = NRC.expansionNum;
local pairs, ipairs = pairs, ipairs;
local gsub = gsub;
--local tinsert = tinsert;
local GetNormalizedRealmName = GetNormalizedRealmName;
local currentMaxWorldbuffs = 0;
local pvpTrinketIcon = NRC.faction == "Horde" and 133453 or 133452;

local checkGammaBuffs;
local gammaBuffs = {};
if (NRC.isCata) then
	--Twilight.
	gammaBuffs[1224930] = {name = "Gift of the Blue Dragonflight", icon = 134155}; --Blue.
	gammaBuffs[1224926] = {name = "Gift of the Red Dragonflight", icon = 134153}; --Red.
	gammaBuffs[1224932] = {name = "Gift of the Green Dragonflight", icon = 134157}; --Green.
	gammaBuffs[1224928] = {name = "Gift of the Bronze Dragonflight", icon = 134156}; --Bronze.
end
if (NRC.isMOP) then
	--Celestial. Why are there 2?
	gammaBuffs[1244204] = {name = "Blessing of Yu'lon", icon = 620831};
	gammaBuffs[1244218] = {name = "Blessing of Yu'lon", icon = 620831};
	gammaBuffs[1244203] = {name = "Blessing of Niuzao", icon = 615340};
	gammaBuffs[1244217] = {name = "Blessing of Niuzao", icon = 615340};
	gammaBuffs[1243285] = {name = "Blessing of Chi-Ji", icon = 877514};
	gammaBuffs[1243293] = {name = "Blessing of Chi-Ji", icon = 877514};
	gammaBuffs[1243315] = {name = "Blessing of Xuen", icon = 620832};
	gammaBuffs[1243316] = {name = "Blessing of Xuen", icon = 620832};
end
if (next(gammaBuffs)) then
	checkGammaBuffs = true;
end

local f = CreateFrame("Frame", "NRCRaidStatus");
f:RegisterEvent("GROUP_FORMED");
f:RegisterEvent("GROUP_JOINED");
f:RegisterEvent("PLAYER_DEAD");
f:RegisterEvent("UPDATE_INVENTORY_DURABILITY");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("READY_CHECK");
f:RegisterEvent("READY_CHECK_CONFIRM");
f:RegisterEvent("READY_CHECK_FINISHED");
f:RegisterEvent("PLAYER_REGEN_DISABLED");
f:RegisterEvent("PLAYER_ROLES_ASSIGNED");
--f:RegisterEvent("GROUP_ROSTER_UPDATE");
f:SetScript('OnEvent', function(self, event, ...)
	if (event == "GROUP_JOINED" or event == "GROUP_FORMED") then
		if (raidStatusFrame and raidStatusFrame:IsShown()) then
			NRC:updateRaidStatusFrames(true);
		end
	elseif (event == "PLAYER_DEAD") then
		C_Timer.After(1, function()
			NRC:sendDuraThroddled();
		end)
	elseif (event == "UPDATE_INVENTORY_DURABILITY") then
		NRC:updateMyDura();
	elseif (event == "PLAYER_ENTERING_WORLD") then
		local isLogon, isReload = ...;
		if (isLogon or isReload) then
			NRC:updateMyDura();
		end
	elseif (event == "READY_CHECK") then
		local startedBy = ...;
		readyCheckStatus = {};
		if (startedBy == UnitName("player")) then
			readyCheckStatus[UnitName("player")] = true; 
		end
		if (readyCheckEndedTimer) then
			readyCheckEndedTimer:Cancel();
			readyCheckEndedTimer = nil;
		end
		if (readyCheckEndedTimer2) then
			readyCheckEndedTimer2:Cancel();
			readyCheckEndedTimer2 = nil;
		end
		readyCheckRunning = true;
		NRC:updateRaidStatusReadyCheckState();
		if (NRC.config.raidStatusShowReadyCheck) then
			NRC:openRaidStatusFrame(true);
			if (ReadyCheckListenerFrame) then
				ReadyCheckListenerFrame:SetFrameLevel(30);
			end
		end
		NRC:updateRaidStatusReadyCheckStatus();
	elseif (event == "READY_CHECK_CONFIRM") then
		local unit, isReady = ...;
		local name = UnitName(unit);
		readyCheckStatus[name] = isReady;
		NRC:updateRaidStatusReadyCheckStatus();
	elseif (event == "READY_CHECK_FINISHED") then
		readyCheckEndedTimer = C_Timer.NewTimer(4, function()
			readyCheckRunning = nil;
			NRC:updateRaidStatusReadyCheckState();
			readyCheckEndedTimer = nil;
			NRC:updateRaidStatusReadyCheckStatus();
		end)
		if (NRC.config.raidStatusFadeReadyCheck) then
			if (raidStatusFrame and raidStatusFrame:IsShown()) then
				readyCheckEndedTimer2 = C_Timer.NewTimer(4, function()
					if (raidStatusFrame and raidStatusFrame:IsShown()) then
						UIFrameFadeOut(raidStatusFrame, 1, 1, 0);
						fadeOutTimer = C_Timer.NewTimer(1, function()
							raidStatusFrame:Hide();
							raidStatusFrame:SetAlpha(1);
							fadeOutTimer = nil;
							NRC:updateRaidStatusReadyCheckStatus();
						end)
					end
				end)
			end
		end
		NRC:updateRaidStatusReadyCheckStatus();
	elseif (event == "PLAYER_REGEN_DISABLED") then
		if (NRC.config.raidStatusHideCombat and raidStatusFrame) then
			raidStatusFrame:Hide();
		end
	elseif (event == "GROUP_ROSTER_UPDATE") then
		if (raidStatusFrame and raidStatusFrame:IsShown()) then
			NRC:updateRaidStatusFrames(true);
			NRC:updateRaidStatusReadyCheckStatus();
		end
	elseif (event == "PLAYER_ROLES_ASSIGNED") then
		NRC:updateRaidStatusFrameButtons();
	end
end)

--Just update the frame flag when opening it incase a readycheck is started before the frame exists.
function NRC:updateRaidStatusReadyCheckState()
	if (raidStatusFrame) then
		if (readyCheckRunning) then
			raidStatusFrame.readyCheckRunning = true;
		else
			raidStatusFrame.readyCheckRunning = nil;
		end
	end
end

function NRC:updateRaidStatusReadyCheckStatus()
	if (raidStatusFrame and raidStatusFrame:IsShown()) then
		--So we don't refresh raid status frame twice on load.
		if (GetTime() - lastOpened > 0.1) then
			NRC:updateRaidStatusFrames();
		end
		if (readyCheckRunning) then
			for k, v in pairs(raidStatusFrame.subFrames) do
				if (v.readyCheckTexture and v.name) then
					local name = v.name;
					if (readyCheckStatus[v.name] == true) then
						v.readyCheckTexture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");
					elseif (readyCheckStatus[v.name] == false) then
						v.readyCheckTexture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady");
					else
						if (readyCheckEndedTimer) then
							--If ready check ended.
							v.readyCheckTexture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady");
						else
							v.readyCheckTexture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Waiting");
						end
					end
					v.fs:SetPoint("LEFT", 17, 0);
				end
			end
		elseif (not fadeOutTimer) then
			for k, v in pairs(raidStatusFrame.subFrames) do
				if (v.readyCheckTexture) then
					v.readyCheckTexture:SetTexture();
					v.fs:SetPoint("LEFT", 5, 0);
				end
			end
		end
	end
end

function NRC:updateRaidStatusButtonText()
	if (raidStatusFrame) then
		if (raidStatusFrame.showRes) then
			raidStatusFrame.button:SetText(L["Less"]);
			if (raidStatusFrame.button.arrowRight) then
				raidStatusFrame.button.arrowRight:Hide();
			end
			if (raidStatusFrame.button.arrowLeft) then
				raidStatusFrame.button.arrowLeft:Show();
			end
		else
			raidStatusFrame.button:SetText(L["More"]);
			if (raidStatusFrame.button.arrowLeft) then
				raidStatusFrame.button.arrowLeft:Hide();
			end
			if (raidStatusFrame.button.arrowRight) then
				raidStatusFrame.button.arrowRight:Show();
			end
		end
	end
end

function NRC:updateRaidStatusGroupColors()
	if (not raidStatusFrame) then
		return;
	end
	if (NRC.config.sortRaidStatusByGroupsColor) then
		local groupColors = {
			"FFFF00", --Yellow.
			"FFA500", --Orange.
			"00FF00", --Lime.
			"FF00FF", --Fuchsia.
			"00FFFF", --Cyan.
			"FF0000", --Red.
			"0000FF", --Blue.
			"008080", --Teal.
			--"000000", --Black.
			--"FFFFFF", --White.
			--"008080", --Teal.
			--"800000", --Maroon.
			--"800080", --Purple.
			--"EE82EE", --Violet.
		};
		for i = 1, 8 do
			local frame = raidStatusFrame.groupFrames[i];
			local r, g, b = NRC:HexToRGBPerc(groupColors[i]);
			if (NRC.config.sortRaidStatusByGroupsColorBackground) then
				frame:SetBackdropColor(r, g, b, 0.1);
			else
				frame:SetBackdropColor(0, 0, 0, 0);
			end
			frame:SetBackdropBorderColor(r, g, b, 1);
			frame.bg:SetBackdropColor(r, g, b, 0.5);
		end
	else
		for i = 1, 8 do
			local frame = raidStatusFrame.groupFrames[i];
			frame:SetBackdropColor(0, 0, 0, 0);
			frame:SetBackdropBorderColor(1, 1, 1, 1);
			frame.bg:SetBackdropColor(0, 0, 0, 0.9);
		end
	end
end

--Create the intial frames at load time.
function NRC:loadRaidStatusFrames()
	if (not raidStatusFrame) then
		--raidStatusFrame = NRC:createGridFrame("NRCRaidStatusFrame", 500, 300, 0, 300, 3);
		raidStatusFrame = NRC:createGridFrame2("NRCRaidStatusFrame", 500, 300, 0, 300, 3);
		raidStatusFrame:SetBackdrop({
			--bgFile = "interface\\garrison\\garrisonuibackground",
			bgFile = "Interface\\FrameGeneral\\UI-Background-Marble",
			--bgFile = "interface\\garrison\\classhallinternalbackground",
			--bgFile = "Interface\\Buttons\\WHITE8x8",
			insets = {top = 0, left = 2, bottom = 2, right = 2},
		});
		raidStatusFrame.borderFrame:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			--edgeFile = "Interface\\Addons\\NovaRaidCompanion\\Media\\UI-Tooltip-Border-FullTopRight",
			tileEdge = true,
			edgeSize = 16,
			insets = {top = 2, left = 2, bottom = 2, right = 2},
		});
		raidStatusFrame.borderFrame:SetFrameLevel(10);
		raidStatusFrame.button:HookScript("OnShow", function(self)
			lastOpened = GetTime();
			if (fadeOutTimer) then
				fadeOutTimer:Cancel();
				fadeOutTimer = nil;
			end
			if (UIFrameIsFading(raidStatusFrame)) then
				--Overwrite fade out so it cancels.
				UIFrameFadeOut(raidStatusFrame, 0.1, 1, 1);
			end
			raidStatusFrame:SetAlpha(1);
			NRC:updateRaidStatusReadyCheckStatus();
		end)
		raidStatusFrame.groupFrames = {};
		for i = 1, 8 do
			local frame = CreateFrame("Frame", "$parentGroupFrame" .. i, raidStatusFrame, "BackdropTemplate");
			frame:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				insets = {top = 2, left = 2, bottom = 2, right = 2},
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
				edgeSize = 8,
			});
			frame.bg = CreateFrame("Frame", "$parentGroupFrameBG" .. i, frame, "BackdropTemplate");
			frame.bg:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				insets = {top = 2, left = 2, bottom = 2, right = 2},
			});
			--local r, g, b = NRC:HexToRGBPerc(groupColors[i]);
			--frame:SetBackdropColor(r, g, b, 0.1);
			--frame:SetBackdropBorderColor(r, g, b, 1);
			--frame.bg:SetBackdropColor(r, g, b, 0.5);
			frame.bg:SetWidth(20);
			frame.bg:SetPoint("TOPLEFT", 1, -1);
			frame.bg:SetPoint("BOTTOMLEFT", 1, 0.5);
			frame.bg.fs = frame.bg:CreateFontString("$parentNRCTooltipFS", "ARTWORK");
			frame.bg.fs:SetPoint("CENTER", 0, 0);
			frame.bg.fs:SetFont(NRC.regionFont, 12);
			frame:Hide();
			raidStatusFrame.groupFrames[i] = frame;
		end
		NRC:updateRaidStatusFramesLayout();
	end
	--raidStatusFrame:SetBackdropColor(0, 0, 0, 0.9);
	--raidStatusFrame:SetBackdropBorderColor(1, 1, 1, 0.7);
	raidStatusFrame.descFrame:SetBackdropColor(0, 0, 0, 0.9);
	raidStatusFrame.descFrame:SetBackdropBorderColor(1, 1, 1, 0.7);
	--raidStatusFrame.descFrame:ClearAllPoints();
	--raidStatusFrame.descFrame:SetPoint("BOTTOM", raidStatusFrame, "TOP", 0, 0);
	raidStatusFrame.updateGridData(NRC:createRaidStatusData(true), true);
	raidStatusFrame.onUpdateFunction = "updateRaidStatusFrames";
	tinsert(UISpecialFrames, "NRCRaidStatusFrame");
	raidStatusFrame:HookScript("OnHide", function(self)
		--raidStatusFrame.showRes = nil;
		raidStatusFrame.lastbuttonID = nil;
	end)
	raidStatusFrame.topRight = CreateFrame("Frame", "NRCRaidStatusFrameTopRight", raidStatusFrame, "BackdropTemplate");
	raidStatusFrame.topRight:SetPoint("BOTTOMRIGHT", raidStatusFrame, "TOPRIGHT", 0, -13);
	raidStatusFrame.topRight:SetSize(150.5, 30);
	raidStatusFrame.topRight:SetFrameLevel(9);
	raidStatusFrame.topRight.borderFrame = CreateFrame("Frame", "$parentBorderFrame", raidStatusFrame.topRight, "BackdropTemplate");
	raidStatusFrame.topRight.borderFrame:SetFrameLevel(9);
	raidStatusFrame.topRight.borderFrame:SetPoint("TOP", 0, 3);
	raidStatusFrame.topRight.borderFrame:SetPoint("BOTTOM", 0, -3);
	raidStatusFrame.topRight.borderFrame:SetPoint("LEFT", -2, 0);
	raidStatusFrame.topRight.borderFrame:SetPoint("RIGHT", 3, 0);
	raidStatusFrame.topRight:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		insets = {top = 2, left = 2, bottom = 2, right = 2},
	});
	raidStatusFrame.topRight.borderFrame:SetBackdrop({
		edgeFile = "Interface\\Addons\\NovaRaidCompanion\\Media\\UI-Tooltip-Border-NoBottom",
		tileEdge = true,
		edgeSize = 16,
		insets = {top = 2, left = 2, bottom = -10, right = 2},
	});
	raidStatusFrame.topRight:SetBackdropColor(0, 0, 0, 0.9);
	raidStatusFrame.closeButton:SetPoint("TOPRIGHT", raidStatusFrame.topRight, 3.45, 3.8);
	raidStatusFrame.closeButton:SetSize(24, 24);
	--raidStatusFrame.button:SetPoint("TOPLEFT", raidStatusFrame.topRight, 14, 0);
	--raidStatusFrame.button:SetPoint("TOPRIGHT", raidStatusFrame.topRight, -36, 0);
	raidStatusFrame.button:SetPoint("TOPRIGHT", raidStatusFrame.topRight, -31, 0);
	raidStatusFrame.button:SetWidth(50);
	raidStatusFrame.button:SetHeight(15);
	raidStatusFrame.button:SetScale(1);
	raidStatusFrame.button:SetText("Expand"); --This text gets updated depending on what the button will do (More/Less).
	raidStatusFrame.button:Show();
	
	raidStatusFrame.button.arrowRight = CreateFrame("Frame", "$parentArrowRight", raidStatusFrame.button);
	raidStatusFrame.button.arrowRight:SetPoint("RIGHT", 5, -1);
	raidStatusFrame.button.arrowRight:SetSize(16, 16);
	raidStatusFrame.button.arrowRight.texture = raidStatusFrame.button.arrowRight:CreateTexture("$parentArrowRightTex", "OVERLAY");
	raidStatusFrame.button.arrowRight.texture:SetAllPoints();
	raidStatusFrame.button.arrowRight.texture:SetTexture("Interface\\Addons\\NovaRaidCompanion\\Media\\Right-Arrow");
	raidStatusFrame.button.arrowRight:Hide();
	
	raidStatusFrame.button.arrowLeft = CreateFrame("Frame", "$parentArrowLeft", raidStatusFrame.button);
	raidStatusFrame.button.arrowLeft:SetPoint("Left", -5, -1);
	raidStatusFrame.button.arrowLeft:SetSize(16, 16);
	raidStatusFrame.button.arrowLeft.texture = raidStatusFrame.button.arrowLeft:CreateTexture("$parentArrowLeftTex", "OVERLAY");
	raidStatusFrame.button.arrowLeft.texture:SetAllPoints();
	raidStatusFrame.button.arrowLeft.texture:SetTexture("Interface\\Addons\\NovaRaidCompanion\\Media\\Left-Arrow");
	raidStatusFrame.button.arrowLeft:Hide();
	raidStatusFrame.button:SetScript("OnClick", function(self, arg)
		if (raidStatusFrame.showRes) then
			raidStatusFrame.showRes = nil;
		else
			raidStatusFrame.showRes = true;
		end
		NRC:updateRaidStatusFrames(true);
		NRC:updateRaidStatusButtonText();
	end)
	raidStatusFrame.button.tooltip = CreateFrame("Frame", "$parentTooltip", raidStatusFrame.button, "TooltipBorderedFrameTemplate");
	raidStatusFrame.button.tooltip:SetPoint("BOTTOM", raidStatusFrame.button, "TOP", 0, 2);
	raidStatusFrame.button.tooltip:SetFrameStrata("TOOLTIP");
	raidStatusFrame.button.tooltip:SetFrameLevel(9);
	raidStatusFrame.button.tooltip.fs = raidStatusFrame.button.tooltip:CreateFontString("$parentNRCTooltipFS", "ARTWORK");
	raidStatusFrame.button.tooltip.fs:SetPoint("CENTER", 0, 0);
	raidStatusFrame.button.tooltip.fs:SetFont(NRC.regionFont, 12);
	raidStatusFrame.button.tooltip.fs:SetJustifyH("LEFT");
	raidStatusFrame.button.tooltip.fs:SetText(L["raidStatusExpandTooltip"]);
	raidStatusFrame.button:SetScript("OnEnter", function(self)
		if (raidStatusFrame.button.tooltip.fs:GetText() and raidStatusFrame.button.tooltip.fs:GetText() ~= "") then
			raidStatusFrame.button.tooltip:SetWidth(raidStatusFrame.button.tooltip.fs:GetStringWidth() + 18);
			raidStatusFrame.button.tooltip:SetHeight(raidStatusFrame.button.tooltip.fs:GetStringHeight() + 12);
			raidStatusFrame.button.tooltip:Show();
		end
	end)
	raidStatusFrame.button:SetScript("OnLeave", function(self)
		raidStatusFrame.button.tooltip:Hide();
	end)
	
	--raidStatusFrame.button2:SetPoint("TOPRIGHT", raidStatusFrame.topRight, -169, 0);
	raidStatusFrame.button2:SetPoint("TOPLEFT", raidStatusFrame.topRight, 14, 0);
	raidStatusFrame.button2:SetWidth(60);
	raidStatusFrame.button2:SetHeight(15);
	raidStatusFrame.button2:SetScale(1);
	raidStatusFrame.button2:SetText("Readycheck");
	raidStatusFrame.button2:SetScript("OnClick", function(self, arg)
		DoReadyCheck();
	end)
	raidStatusFrame.button2:Hide();
	
	raidStatusFrame.checkbox = CreateFrame("CheckButton", "NRCRaidStatusFrameCheckbox", raidStatusFrame, "ChatConfigCheckButtonTemplate");
	raidStatusFrame.checkbox.Text:SetText(L["Groups"]);
	raidStatusFrame.checkbox.Text:SetFont(NRC.regionFont, 11);
	raidStatusFrame.checkbox.Text:SetPoint("LEFT", raidStatusFrame.checkbox, "RIGHT", -2, 1);
	raidStatusFrame.checkbox.tooltip = L["sortByGroupsTooltip"];
	raidStatusFrame.checkbox:SetFrameStrata("HIGH");
	raidStatusFrame.checkbox:SetFrameLevel(9);
	raidStatusFrame.checkbox:SetWidth(20);
	raidStatusFrame.checkbox:SetHeight(20);
	raidStatusFrame.checkbox:SetPoint("TOPRIGHT", raidStatusFrame.topRight, -130, 2);
	raidStatusFrame.checkbox:SetHitRectInsets(0, 0, -10, 7);
	--raidStatusFrame.checkbox:SetBackdropBorderColor(0, 0, 0, 1);
	raidStatusFrame.checkbox:SetChecked(NRC.config.sortRaidStatusByGroups);
	raidStatusFrame.checkbox:SetScript("OnClick", function()
		local value = raidStatusFrame.checkbox:GetChecked();
		NRC.config.sortRaidStatusByGroups = value;
		NRC:updateRaidStatusFrames(true);
		--NRC.acr:NotifyChange("NovaRaidCompanion");
	end);
	
	raidStatusFrame.checkbox2 = CreateFrame("CheckButton", "NRCRaidStatusFrameCheckbox2", raidStatusFrame, "ChatConfigCheckButtonTemplate");
	raidStatusFrame.checkbox2.Text:SetText(L["Buff Durations"]);
	raidStatusFrame.checkbox2.Text:SetFont(NRC.regionFont, 11);
	raidStatusFrame.checkbox2.Text:SetPoint("LEFT", raidStatusFrame.checkbox2, "RIGHT", -2, 1);
	raidStatusFrame.checkbox2.tooltip = L["buffDurationsTooltip"];
	raidStatusFrame.checkbox2:SetFrameStrata("HIGH");
	raidStatusFrame.checkbox2:SetFrameLevel(9);
	raidStatusFrame.checkbox2:SetWidth(20);
	raidStatusFrame.checkbox2:SetHeight(20);
	raidStatusFrame.checkbox2:SetPoint("TOPRIGHT", raidStatusFrame.topRight, -229, 2);
	raidStatusFrame.checkbox2:SetHitRectInsets(0, 0, -10, 7);
	--raidStatusFrame.checkbox:SetBackdropBorderColor(0, 0, 0, 1);
	raidStatusFrame.checkbox2:SetChecked(NRC.config.raidStatusBuffSwipe);
	raidStatusFrame.checkbox2:SetScript("OnClick", function()
		local value = raidStatusFrame.checkbox2:GetChecked();
		NRC.config.raidStatusBuffSwipe = value;
		NRC:updateAllRaidStatusCooldownSwipes();
		--NRC.acr:NotifyChange("NovaRaidCompanion");
	end);
	
	NRC:updateRaidStatusGroupColors();
	NRC:updateRaidStatusFrameButtons();
	NRC:setRaidStatusSize();
	raidStatusFrame:Hide();
end

function NRC:updateRaidStatusFrameButtons()
	if (raidStatusFrame) then
		if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
			raidStatusFrame.button2:Show();
			--raidStatusFrame.topRight:SetSize(251, 30);
			raidStatusFrame.topRight:SetSize(350, 30);
			raidStatusFrame.button2:Show();
		else
			--raidStatusFrame.topRight:SetSize(150.5, 30);
			raidStatusFrame.topRight:SetSize(250.5, 30);
			raidStatusFrame.button2:Hide();
		end
	end
end

function NRC:reloadRaidStatusFrames()
	if (not raidStatusFrame) then
		return;
	end
	raidStatusFrame.updateGridData(NRC:createRaidStatusData(true), true);
	NRC:updateRaidStatusFrames(true);
end

function NRC:setRaidStatusSize()
	if (raidStatusFrame) then
		raidStatusFrame:SetScale(NRC.db.global.raidStatusScale);
	end
end

function NRC:updateRaidStatusFramesLayout()
	raidStatusFrame.subFrameFont = NRC.db.global.raidStatusFont;
	raidStatusFrame.subFrameFontSize = NRC.db.global.raidStatusFontSize;
	--raidStatusFrame.subFrameFontOutline = NRC.db.global.raidStatusFontOutline;
	for k, v in pairs(raidStatusFrame.subFrames) do
		v.fs:SetFont(NRC.LSM:Fetch("font", raidStatusFrame.subFrameFont), raidStatusFrame.subFrameFontSize, raidStatusFrame.subFrameFontOutline);
	end
end
			
local int, fort, spirit, shadow, motw, pal, weaponEnchants, worldBuffs = {}, {}, {}, {}, {}, {}, {}, {};
local aurasToTableCopy = {
	[349981] = true,
};
if (NRC.extraSlot1Data) then
	extraDataTable.extraSlot1Data = {};
	for k, v in pairs(NRC.extraSlot1Data) do
		extraDataTable.extraSlot1Data[k] = v;
		aurasToTableCopy[k] = v;
	end
end
if (NRC.extraSlot2Data) then
	extraDataTable.extraSlot2Data = {};
	for k, v in pairs(NRC.extraSlot2Data) do
		extraDataTable.extraSlot2Data[k] = v;
		aurasToTableCopy[k] = v;
	end
end
if (NRC.extraSlot3Data) then
	extraDataTable.extraSlot3Data = {};
	for k, v in pairs(NRC.extraSlot3Data) do
		extraDataTable.extraSlot3Data[k] = v;
		aurasToTableCopy[k] = v;
	end
end
for k, v in pairs(NRC.int) do
	int[k] = v;
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.fort) do
	fort[k] = v;
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.spirit) do
	spirit[k] = v;
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.shadow) do
	shadow[k] = v;
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.motw) do
	motw[k] = v;
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.pal) do
	pal[k] = v;
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.worldBuffs) do
	numWorldBuffs = numWorldBuffs + 1;
	worldBuffs[k] = v;
	aurasToTableCopy[k] = v;
end
--Just used for table copy purposes, tables not deleted.
for k, v in pairs(NRC.flasks) do
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.scrolls) do
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.battleElixirs) do
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.guardianElixirs) do
	aurasToTableCopy[k] = v;
end
for k, v in pairs(NRC.foods) do
	aurasToTableCopy[k] = v;
end
--This can't be lower than the max number of world buffs in Classic_DB file obtainable at once or frames won't exist and error.
NRC.numWorldBuffs = numWorldBuffs - 7; --Minus 7 duplicate dmf buffs and 1 duplicate spark of imagination buff, but +1 for chronoboon display slot.
for k, v in pairs(NRC.tempEnchants) do
	weaponEnchants[k] = v;
end
if (NRC.isSOD) then
	--If it's sod we need to reload these buffs from db so the sod phase can be detected properly and maxRank added.
	--This is called after logon.
	function NRC:logonUpdateRaidStatusDatabase()
		for k, v in pairs(NRC.int) do
			int[k] = v;
			aurasToTableCopy[k] = v;
		end
		for k, v in pairs(NRC.fort) do
			fort[k] = v;
			aurasToTableCopy[k] = v;
		end
		for k, v in pairs(NRC.spirit) do
			spirit[k] = v;
			aurasToTableCopy[k] = v;
		end
		for k, v in pairs(NRC.shadow) do
			shadow[k] = v;
			aurasToTableCopy[k] = v;
		end
		for k, v in pairs(NRC.motw) do
			motw[k] = v;
			aurasToTableCopy[k] = v;
		end
		for k, v in pairs(NRC.pal) do
			pal[k] = v;
			aurasToTableCopy[k] = v;
		end
		for k, v in pairs(NRC.tempEnchants) do
			weaponEnchants[k] = v;
		end
		NRC.int = nil;
		NRC.fort = nil;
		NRC.spirit = nil;
		NRC.shadow = nil;
		NRC.motw = nil;
		NRC.pal = nil;
		--NRC.worldBuffs = nil;
		NRC.tempEnchants = nil;
	end
else
	NRC.int = nil;
	NRC.fort = nil;
	NRC.spirit = nil;
	NRC.shadow = nil;
	NRC.motw = nil;
	NRC.pal = nil;
	--NRC.worldBuffs = nil;
	NRC.tempEnchants = nil;
end

--These are actual "Food" buff you get while eating, these are from buff food so the raid status can display when a player is eating.
--These match the well fed buffs in db.
local validFoods = {};
for k, v in pairs(NRC.eating) do
	validFoods[k] = v;
end
NRC.eating = nil;


--Future notes.
--[[if (wrath) then
	--If higher expansion remove max rank notes.
	for k, v in pairs(NRC.flasks) do
		v.maxRank = nil;
	end
	--Insert next expansion spells here.
end]]

function NRC:openRaidStatusFrame(showOnly, fromLog, buttonID)
	if (not fromLog) then
		NRC.raidStatusCache = nil;
	end
	if (not raidStatusFrame) then
		NRC:loadRaidStatusFrames();
	end
	--Delay used to split first load in to different frames if in combat.
	--if (NRC.firstRaidStatusUpdate and InCombatLockdown()) then
	--Just do every first load for now.
	if (NRC.firstRaidStatusUpdate) then
		C_Timer.After(0.01, function()
			if (not raidStatusFrame:IsShown() or fromLog) then
				if (buttonID and buttonID == raidStatusFrame.lastbuttonID) then
					--If we click the same button in raid log again then hide instead.
					raidStatusFrame.lastbuttonID = nil;
					raidStatusFrame:Hide();
				else
					if (fromLog) then
						--Make frame rise to the top.
						raidStatusFrame:Hide();
					end
					if (NRC.config.raidStatusExpandAlways) then
						raidStatusFrame.showRes = true;
					end
					raidStatusFrame:Show();
					raidStatusFrame.lastbuttonID = buttonID;
					--Set a last update time so it doesn't update twice on open and instead waits a second.
					raidStatusFrame.lastUpdate = GetTime();
					NRC:updateRaidStatusFrames(true);
					if (GetServerTime() - lastRaidRequest > 20 and not fromLog) then
						lastRaidRequest = GetServerTime();
						NRC:requestRaidData();
					end
				end
			elseif (not showOnly) then
				raidStatusFrame.lastbuttonID = nil;
				raidStatusFrame:Hide();
				--raidStatusFrame.showRes = nil;
			end
			--NRC:updateRaidStatusReadyCheckStatus(); --This is hooked OnShow;
			NRC:updateRaidStatusFrameButtons();
		end)
	else
		if (not raidStatusFrame:IsShown() or fromLog) then
			if (buttonID and buttonID == raidStatusFrame.lastbuttonID) then
				--If we click the same button in raid log again then hide instead.
				raidStatusFrame.lastbuttonID = nil;
				raidStatusFrame:Hide();
			else
				if (fromLog) then
					--Make frame rise to the top.
					raidStatusFrame:Hide();
				end
				if (NRC.config.raidStatusExpandAlways) then
					raidStatusFrame.showRes = true;
				end
				raidStatusFrame:Show();
				raidStatusFrame.lastbuttonID = buttonID;
				--Set a last update time so it doesn't update twice on open and instead waits a second.
				raidStatusFrame.lastUpdate = GetTime();
				NRC:updateRaidStatusFrames(true);
				if (GetServerTime() - lastRaidRequest > 3 and not fromLog) then
					lastRaidRequest = GetServerTime();
					NRC:requestRaidData();
				end
			end
		elseif (not showOnly) then
			raidStatusFrame.lastbuttonID = nil;
			raidStatusFrame:Hide();
			--raidStatusFrame.showRes = nil;
		end
		--NRC:updateRaidStatusReadyCheckStatus(); --This is hooked OnShow;
		NRC:updateRaidStatusFrameButtons();
	end
	NRC:updateRaidStatusReadyCheckState();
end

--[[local function updateGridTooltip(frame, localBuffData, buffData)
	local tooltipText = "";
	if (localBuffData.rank) then
		tooltipText = tooltipText .. tooltipText .. "|cFFDEDE42" .. buffData.name .. "|r |cFF9CD6DE(Rank " .. localBuffData.rank .. ")|r";
	else
		tooltipText = tooltipText .. "|cFFDEDE42" .. buffData.name .. "|r";
	end
	if (localBuffData.desc) then
		tooltipText = tooltipText .. "\n|cFF9CD6DE" .. localBuffData.desc .. "|r";
	end
	if (not NRC.raidStatusCache) then
		if (buffData.endTime and buffData.endTime > GetServerTime()) then
			local remaining = buffData.endTime - GetServerTime();
			tooltipText = tooltipText .. "\n" .. NRC:getShortTime(remaining) .. "|r";
			if (remaining < lowDurationTime) then
				tooltipText = tooltipText .. " |cFFFF0000Low Duration|r";
			end
		elseif (buffData.duration == 0) then
			--An aura, no duration.
			tooltipText = tooltipText .. "\nAura (No duration)|r";
		else
			tooltipText = tooltipText .. "\nDuration unknown (out of range?)|r";
		end
		if (buffData.source) then
			tooltipText = tooltipText .. " |cFFFF6900Cast by " .. buffData.source .. "|r";
		end
	else
		if (buffData.source) then
			tooltipText = tooltipText .. "\n|cFFFF6900Cast by " .. buffData.source .. "|r";
		end
	end
	if (not localBuffData.maxRank) then
		tooltipText = tooltipText .. "\n|cFFFF0000Not Max Rank|r";
	end
	frame.updateTooltip(tooltipText);
end]]

local function updateTooltipSpecialSlot(frame, name, classHex, tooltipString, prefixString)
	local nameString = "|c" .. classHex .. name .. "|r";
	local tooltipText = (prefixString or "") .. "|cFFDEDE42" .. nameString .. "|r";
	if (tooltipString) then
		tooltipText = tooltipText .. "\n" .. tooltipString;
	end
	frame.updateTooltip(tooltipText);
end

local function updateGridTooltipTalents(frame, name, classHex, talentCount, specName, specIcon, treeData, showOnyCloak, hasOnyCloak, hasDataShare, addonVersion, helperVersion)
	local nameString = "|c" .. classHex .. name .. "|r";
	local tooltipText = "|cFFDEDE42" .. nameString .. "|r";
	if (specName and specIcon) then
		--tooltipText = tooltipText .. "\n|cFFDEDE42" .. specName .. "|r";
		tooltipText = tooltipText .. "\n|T" .. specIcon .. ":12:12|t |cFFFFFF00" .. specName .. "|r";
	end
	if (treeData and treeData[3]) then
		tooltipText = tooltipText .. "\n|cFF9CD6DE" .. treeData[1] .. " / " .. treeData[2] .. " / " .. treeData[3] .. "|r";
	end
	tooltipText = tooltipText .. "\n|cFFFFAE42-Click To View Talents-|r";
	if (showOnyCloak) then
		if (hasOnyCloak) then
			tooltipText = tooltipText .. "\n\n|cFF00FF00Has onyxia cloak equipped.|r";
		else
			if (not hasDataShare) then
				tooltipText = tooltipText .. "\n\n|cFFFFFFFFUser doesn't have NRC addon\nor helper weakaura installed.\nwago.io/sof4ehBA6|r";
			else
				if (addonVersion and tonumber(addonVersion) and tonumber(addonVersion) < 1.07) then
					tooltipText = tooltipText .. "\n\n|cFFFF0000Players addon version too far out of date.|r";
				elseif (addonVersion and tonumber(addonVersion) and tonumber(addonVersion) < 1.53) then
					tooltipText = tooltipText .. "\n\n|cFFFF0000Weakaura helper version too far out of date.|r";
				else
					tooltipText = tooltipText .. "\n\n|cFFFF0000No onyxia cloak equipped.|r";
				end
			end
		end
	end
	frame.updateTooltip(tooltipText);
end

local function updateGridTooltipRes(frame, name, classHex, type, amount)
	local nameString = "|c" .. classHex .. name .. "|r";
	local tooltipText = "|cFFDEDE42" .. nameString .. "|r";
	if (type and amount) then
		tooltipText = tooltipText .. "\n" .. type .. " " .. amount .. "|r";
	else
		tooltipText = tooltipText .. "\n|cFF9CD6DEUnknown.|r";
	end
	frame.updateTooltip(tooltipText);
end

local function updateGridTooltip(frame, localBuffData, buffData)
	local tooltipText = "|T" .. localBuffData.icon .. ":13:13|t |cFFFFAE42[" .. buffData.name .. "]|r";
	if (localBuffData.desc and buffData.desc ~= "") then
		tooltipText = tooltipText .. " |cFF00FF00" .. localBuffData.desc .. "|r";
	end
	if (localBuffData.rank) then
		tooltipText = tooltipText .. " |cFFA0A0A0(Rank " .. localBuffData.rank .. ")|r";
	end
	if (not NRC.raidStatusCache) then
		local hasDuration;
		if (buffData.endTime and buffData.endTime > GetServerTime()) then
			local remaining = buffData.endTime - GetServerTime();
			tooltipText = tooltipText .. "\n|cFF9CD6DE" .. NRC:getShortTime(remaining) .. "|r";
			if (remaining < lowDurationTime) then
				tooltipText = tooltipText .. " |cFFFFFF00Low Duration|r";
			end
			hasDuration = true;
		elseif (buffData.duration == 0) then
			--An aura, no duration.
			--tooltipText = tooltipText .. "\n|cFF9CD6DENo duration|r";
		else
			tooltipText = tooltipText .. "\n|cFF9CD6DEDuration unknown (out of range?)|r";
			hasDuration = true;
		end
		if (buffData.source) then
			if (hasDuration) then
				tooltipText = tooltipText .. "  |cFFFFFFFFCast by " .. buffData.source .. "|r";
			else
				tooltipText = tooltipText .. "\n|cFFFFFFFFCast by " .. buffData.source .. "|r";
			end
		end
	else
		if (buffData.source) then
			tooltipText = tooltipText .. "\n|cFFFFFFFFCast by " .. buffData.source .. "|r";
		end
	end
	if (not localBuffData.maxRank) then
		tooltipText = tooltipText .. "\n|cFFFF0000Not Max Rank|r";
	end
	frame.updateTooltip(tooltipText);
end

local function getMultipleIconsTooltip(buffData, hideSource)
	local tooltipText;
	if (NRC.scrolls[buffData.buffID]) then
		tooltipText = "|T" .. NRC.scrolls[buffData.buffID].icon .. ":13:13|t |cFFFFAE42[" .. NRC.scrolls[buffData.buffID].name .. "]|r";
	else
		tooltipText = "|T" .. buffData.icon .. ":12:12|t |cFFFFAE42[" .. buffData.name .. "]|r";
	end
	if (buffData.desc and buffData.desc ~= "") then
		tooltipText = tooltipText .. " |cFF00FF00" .. buffData.desc .. "|r";
	end
	if (buffData.rank) then
		tooltipText = tooltipText .. " |cFFA0A0A0(Rank " .. buffData.rank .. ")|r";
	end
	if (not NRC.raidStatusCache) then
		local hasDuration;
		if (buffData.endTime and buffData.endTime > GetServerTime()) then
			local remaining = buffData.endTime - GetServerTime();
			tooltipText = tooltipText .. "\n|cFF9CD6DE" .. NRC:getShortTime(remaining) .. "|r";
			if (remaining < lowDurationTime) then
				tooltipText = tooltipText .. " |cFFFFFF00Low Duration|r";
			end
			hasDuration = true;
		elseif (buffData.duration == 0) then
			--An aura, no duration.
			--tooltipText = tooltipText .. "\n|cFF9CD6DENo duration|r";
		else
			tooltipText = tooltipText .. "\n|cFF9CD6DEDuration unknown (out of range?)|r";
			hasDuration = true;
		end
		--if (buffData.endTime) then
		--	tooltipText = tooltipText .. "\n" .. NRC:getShortTime(buffData.endTime - GetServerTime()) .. "|r";
		--end
		if (buffData.source and not hideSource) then
			if (hasDuration) then
				tooltipText = tooltipText .. "  |cFFFFFFFFCast by " .. buffData.source .. "|r";
			else
				tooltipText = tooltipText .. "\n|cFFFFFFFFCast by " .. buffData.source .. "|r";
			end
		end
	else
		if (buffData.source and not hideSource) then
			tooltipText = tooltipText .. "\n|cFFFFFFFFCast by " .. buffData.source .. "|r";
		end
	end
	if (not buffData.maxRank) then
		tooltipText = tooltipText .. "\n|cFFFF0000Not Max Rank|r";
	end
	return tooltipText;
end

local chronoIcons = {
	[L["Fengus' Ferocity"]] = 136109,
	[L["Mol'dar's Moxie"]] = 136054,
	[L["Slip'kik's Savvy"]] = 135930,
	[L["Rallying Cry of the Dragonslayer"]] = 134153,
	[L["Warchief's Blessing"]] = 135759,
	[L["Might of Stormwind"]] = 135759,
	[L["Spirit of Zandalar"]] = 132107,
	[L["Songflower Serenade"]] = 135934,
	[L["Boon of Blackfathom"]] = 236403,
	[L["Spark of Inspiration"]] = 236424, 
	[L["Fervor of the Temple Explorer"]] = 236368,
	[L["Sayge's Dark Fortune of Damage"]] = 134334,
	[L["Sayge's Dark Fortune of Resistance"]] = 134334,
	[L["Sayge's Dark Fortune of Armor"]] = 134334,
	[L["Sayge's Dark Fortune of Intelligence"]] = 134334,
	[L["Sayge's Dark Fortune of Spirit"]] = 134334,
	[L["Sayge's Dark Fortune of Stamina"]] = 134334,
	[L["Sayge's Dark Fortune of Strength"]] = 134334,
	[L["Sayge's Dark Fortune of Agility"]] = 134334,
};

local function getChronoboonTooltip(guid)
	local data;
	if (NRC.raidStatusCache and NRC.raidStatusCache.chronoCache) then
		data = NRC.raidStatusCache.chronoCache[guid];
	else
		data = NRC.chronoCache[guid];
	end
	local tooltipText = "";
	if (data) then
		--tooltipText = tooltipText .. "|cFFFFFF00-----------------------------------------------";
		--tooltipText = tooltipText .. "|T133881:13:13|t |cFFFFFF00" .. L["Chronobooned"] .. ":|r";
		tooltipText = tooltipText .. "|cFFFFFF00" .. L["Chronobooned"] .. "|r |T133881:13:13|t";
		--tooltipText = tooltipText .. "\n|cFFFFFF00-----------------------------------------------";
		for k, v in pairs(data) do
			if (chronoIcons[v.name]) then
				tooltipText = tooltipText .. "\n  |T" .. chronoIcons[v.name] .. ":12:12|t  |cFFFFAE42[" .. v.name .. "]|r  |cFF9CD6DE" .. NRC:getShortTime(v.duration) .. "|r";
			else
				tooltipText = tooltipText .. "\n  |cFFFFAE42[" .. v.name .. "]|r  |cFF9CD6DE" .. NRC:getShortTime(v.duration) .. "|r";
			end
		end
	end
	return tooltipText;
end

--[[local function getMultipleIconsTooltip(buffData)
	local tooltipText = "";
	if (buffData.rank) then
		tooltipText = tooltipText .. tooltipText .. "|cFFDEDE42" .. buffData.name .. "|r |cFF9CD6DE(Rank " .. buffData.rank .. ")|r";
	else
		if (NRC.scrolls[buffData.buffID]) then
			tooltipText = tooltipText .. "|cFFDEDE42" .. NRC.scrolls[buffData.buffID].name .. "|r";
		else
			tooltipText = tooltipText .. "|cFFDEDE42" .. buffData.name .. "|r";
		end
	end
	if (buffData.desc and buffData.desc ~= "") then
		tooltipText = tooltipText .. "\n|cFF9CD6DE" .. buffData.desc .. "|r";
	end
	if (not NRC.raidStatusCache) then
		if (buffData.endTime and buffData.endTime > GetServerTime()) then
			local remaining = buffData.endTime - GetServerTime();
			tooltipText = tooltipText .. "\nDuration: " .. NRC:getShortTime(remaining) .. "|r";
			if (remaining < lowDurationTime) then
				tooltipText = tooltipText .. " |cFFFF0000Low Duration|r";
			end
		elseif (buffData.duration == 0) then
			--An aura, no duration.
			tooltipText = tooltipText .. "\nAura (No duration)|r";
		else
			tooltipText = tooltipText .. "\nDuration unknown (out of range?)|r";
		end
		--if (buffData.endTime) then
		--	tooltipText = tooltipText .. "\n" .. NRC:getShortTime(buffData.endTime - GetServerTime()) .. "|r";
		--end
		if (buffData.source) then
			tooltipText = tooltipText .. " |cFFFF6900Cast by " .. buffData.source .. "|r";
		end
	else
		if (buffData.source) then
			tooltipText = tooltipText .. "\n|cFFFF6900Cast by " .. buffData.source .. "|r";
		end
	end
	if (not buffData.maxRank) then
		tooltipText = tooltipText .. "\n|cFFFF0000Not Max Rank|r";
	end
	return tooltipText;
end]]

function NRC:updateCharacterTooltip(frame, name, charData, auras, hasAlpha, hasGamma)
	if (not charData) then
		frame.updateTooltip();
		return;
	end
	local _, _, _, classHex = getClassColor(charData.class);
	local tooltipText = "|c" .. classHex .. name .. "|r";
	local zone = charData.zone or charData.lastKnownZone;
	if (zone) then
		tooltipText = tooltipText .. "\n|cFF9CD6DE" .. zone .. "|r";
	end
	if (charData.level) then
		tooltipText = tooltipText .. "\n|cFFFFFF00" .. charData.level .. "|r";
	end
	if (not charData.online and not NRC.raidStatusCache) then
		tooltipText = tooltipText .. "\n|cFF989898(Offline)|r";
	end
	local found;
	local count = 0;
	if (auras) then
		tooltipText = tooltipText .. "\n";
		for k, v in pairs(auras) do
			count = count + 1;
			found = true;
			tooltipText = tooltipText .. "|T" .. v.icon .. ":16:16|t";
			if (math.fmod(count, 6) == 0) then
				tooltipText = tooltipText .. "\n";
			end
		end
	end
	if (hasAlpha) then
		tooltipText = tooltipText .. "\n\n|T132203:16:16|t Has Spirit of the Alpha";
		local _, _, _, hex = NRC.getClassColor("SHAMAN");
		tooltipText = tooltipText .. "\n       Cast by |c" .. hex.. hasAlpha .. "|r";
	end
	if (hasGamma) then
		local gammaName, gammaIcon = "";
		if (gammaBuffs[hasGamma]) then
			gammaName = gammaBuffs[hasGamma].name;
			gammaIcon = gammaBuffs[hasGamma].icon;
		end
		tooltipText = tooltipText .. "\n\n|T" .. gammaIcon .. ":16:16|t Has " .. gammaName ..  " active.";
	end
	--Remove any trailing newline if buff counts matches exactly 6/12 etc.
	--tooltipText = string.gsub(tooltipText, "\n$", "");
	frame.updateTooltip(tooltipText);
	if (not InCombatLockdown()) then
		frame:SetAttribute("macrotext", "/target " .. name);
	end
end

local function updateDuraTooltip(frame, name, class, coloredDura, broken)
	local _, _, _, classHex = getClassColor(class);
	local tooltipText = "|c" .. classHex .. name .. "|r";
	tooltipText = tooltipText .. "\n|cFF9CD6DEDurability:|r " .. (coloredDura or "Error");
	if (broken and broken > 0) then
		broken = "|cFFFF2222" .. broken .. "|r";
	end
	tooltipText = tooltipText .. "\n|cFF9CD6DEBroken items:|r " .. (broken or 0);
	frame.updateTooltip(tooltipText);
end

local function colorizeRes(res)
	if (NRC.isSOD) then
		--MC heat levels.
		local color = "|cFF00C800";
		if (res < 96) then
			color = "|cFFFF2222";
		elseif (res < 226) then
			color = "|cFFDEDE42";
		end
		return color .. res .. "|r";
	else
		local color = "|cFF00C800";
		if (res < 1) then
			color = "|cFFFF2222";
		elseif (res < 200) then
			color = "|cFFDEDE42";
		end
		return color .. res .. "|r";
	end
end

function NRC:updateRaidStatusLowDurationTime()
	lowDurationTime = NRC.config.raidStatusLowDurationTime;
end

local function updateCooldownSwipe(texture, endTime, maxDuration)
	if (NRC.config.raidStatusBuffSwipe and endTime and maxDuration and maxDuration > 0) then
		local remaining = endTime - GetServerTime();
		local elapsedDuration = maxDuration - remaining;
		if (not texture.cooldown) then
			local cooldown = CreateFrame("Cooldown", texture:GetName() .. "Cooldown", texture:GetParent(), "CooldownFrameTemplate");
			cooldown:SetHideCountdownNumbers(true); --Hide cooldown number incase user has enabled it in options for hotbars.
			cooldown:ClearAllPoints();
			cooldown:SetSize(texture:GetSize());
			cooldown:SetPoint("CENTER", texture);
			cooldown:SetReverse(true);
			cooldown:SetDrawBling(false);
			cooldown.noCooldownCount = true; --Make omnicc respect the no cooldown text.
			cooldown:GetRegions():SetAlpha(0); --Make real sure the blizzard timer text doesn't display also, first region is the text apparently (from UI disc).
			texture.cooldown = cooldown;
		end
		--if (not texture.swipeRunning) then
		if (texture.swipeRunning ~= endTime) then
			texture.cooldown:SetCooldown(GetTime() - elapsedDuration, maxDuration);
			texture.swipeRunning = endTime;
		end
	end
end

local function stopCooldownSwipe(texture)
	--This is now handled in a OnHide hook for each texture.
	if (texture and texture.swipeRunning) then
		texture.cooldown:Clear();
		texture.swipeRunning = nil;
	end
end

function NRC:updateAllRaidStatusCooldownSwipes()
	if (not NRC.config.raidStatusBuffSwipe) then
		--[[for k, v in pairs(raidStatusFrame.subFrames) do
			if (v.texture and v.texture.swipeRunning) then
				stopCooldownSwipe(v.texture);
			end
			if (v.texture2 and v.texture2.swipeRunning) then
				stopCooldownSwipe(v.texture2);
			end
			if (v.texture3 and v.texture3.swipeRunning) then
				stopCooldownSwipe(v.texture3);
			end
			if (v.texture4 and v.texture4.swipeRunning) then
				stopCooldownSwipe(v.texture4);
			end
		end]]
		for k, v in pairs(raidStatusFrame.subFrames) do
			for i = 1, NRC.numWorldBuffs do
				if (i == 1) then
					if (v.texture and v.texture.swipeRunning) then
						stopCooldownSwipe(v.texture);
					end
				else
					if (v["texture" .. i] and v["texture" .. i].swipeRunning) then
						stopCooldownSwipe(v["texture" .. i]);
					end
				end
			end
		end
	end
	NRC:updateRaidStatusFrames(true);
end

--This needs changing to be a variable set in the main func instead.
local function getMaxNumGroupWorldBuffs()
	local maxBuffs = 0;
	local groupData, buffData;
	if (NRC.raidStatusCache) then
		groupData = NRC.raidStatusCache.auraCache;
		buffData = NRC.raidStatusCache.auraCache;
		for k, v in pairs(groupData) do
			local count = 0;
			if (buffData[k]) then
				for buffID, _ in pairs(buffData[k]) do
					if (worldBuffs[buffID] or buffID == 349981) then
						count = count + 1;
					end
				end
			end
			if (count > maxBuffs) then
				maxBuffs = count;
			end
		end
	else
		if (GetNumGroupMembers() > 1) then
				groupData = NRC.groupCache;
		else
			--If we're solo.
			groupData = {
				[UnitName("Player")] = {
					guid = UnitGUID("player"),
				},
			};
		end
		buffData = NRC.auraCache;
		for k, v in pairs(groupData) do
			local count = 0;
			if (v.guid and buffData[v.guid]) then
				for buffID, _ in pairs(buffData[v.guid]) do
					if (worldBuffs[buffID] or buffID == 349981) then
						count = count + 1;
					end
				end
			end
			if (count > maxBuffs) then
				maxBuffs = count;
			end
		end
	end
	return maxBuffs;
end

function NRC.checkWorldBuffCountChanged()
	local worldBuffCount = getMaxNumGroupWorldBuffs();
	if (worldBuffCount ~= currentMaxWorldbuffs) then
		currentMaxWorldbuffs = worldBuffCount;
		return true;
	end
end

local armorTypes = {
	["PRIEST"] = 132691, ["MAGE"] = 132691, ["WARLOCK"] = 132691, --inv_chest_cloth_50
	["ROGUE"] = 132722, ["DRUID"] = 132722, ["MONK"] = 132722, --[[["DEMONHUNTER"] = 132722,]] --inv_chest_leather_07
	["HUNTER"] = 132630, ["SHAMAN"] = 132630, --[[["EVOKER"] = 132630,]] --inv_chest_chain_08
	["WARRIOR"] = 132739, ["PALADIN"] = 132739, ["DEATHKNIGHT"] = 132739, --inv_chest_plate04
};

local function updateBackgroundColor(frame, notMaxRank, lowDuration, maxDuration)
	if (frame:IsMouseOver() and not frame.red) then
		frame:SetBackdropColor(0, 1, 0, 0.15);
		frame:SetBackdropBorderColor(1, 1, 1, 0.5);
		return;
	end
	if (maxDuration and maxDuration < 630) then
		lowDuration = false;
	end
	if (notMaxRank) then
		frame:SetBackdropColor(1, 0, 0, 0.25);
		frame:SetBackdropBorderColor(1, 0, 0, 0.7);
		frame.red = true;
	elseif (lowDuration) then
		frame:SetBackdropColor(1, 1, 0, 0.25);
		frame:SetBackdropBorderColor(1, 1, 0, 0.7);
		frame.red = true; --Actually yellow, but this flag name works for what we use it for.
	else
		frame.red = nil;
		frame:SetBackdropColor(0, 0, 0, 0);
		frame:SetBackdropBorderColor(1, 1, 1, 0);
	end
end

function NRC:updateRaidStatusFrames(updateLayout)
	--local pTime = debugprofilestop();
	if (not raidStatusFrame:IsShown()) then
		return;
	end
	--Updating the layout while moving caus the mouse to lose focus on the frame and moving stops.
	--In classic it will update layout a second after stopping drag.
	if (updateLayout ~= false and NRC.isClassic and NRC.config.raidStatusWorldBuffs and not raidStatusFrame.isMoving) then
		--Don't override updateLayout with false if we opened the frame with updateLayout true.
		--But we still need to run checkWorldBuffCountChanged anyway to set out local variable of max buff count shown atm.
		local buffsChanged = NRC.checkWorldBuffCountChanged();
		if (not updateLayout) then
			--Allow frame to grow/shrink while open if we're showing world buffs in classic and the max shown has changed.
			updateLayout = buffsChanged;
		end
	end
	--checkGamma is set here instead of being checked in the main file becaus of a 60 upvalue issue, this whole func needs rewriting badly, soon tm...
	local data, checkGamma = NRC:createRaidStatusData(updateLayout);
	--NRC:debug(data)
	if (updateLayout) then
		raidStatusFrame.updateGridData(data, updateLayout);
		for i = 1, 20 do
			if (raidStatusFrame.subFrames and raidStatusFrame.subFrames["a" .. i]) then
				local tooltipText;
				if (data.columns[i] and data.columns[i].tooltip) then
					tooltipText = data.columns[i].tooltip;
				end
				--Add tooltip if it's an icon, or clear tooltip if it's not so shift drag can be added.
				raidStatusFrame.subFrames["a" .. i].updateTooltip(tooltipText);
			end
		end
		local tooltipText = L["Hold Shift To Drag"];
		--No tooltip for the last 2 slots near the close button.
		for i = 1, slotCount - 2 do
			if (raidStatusFrame.subFrames and raidStatusFrame.subFrames["a" .. i] and not data.columns[i].tooltip) then
				raidStatusFrame.subFrames["a" .. i].updateTooltip(tooltipText);
				raidStatusFrame.subFrames["a" .. i].tooltip:SetPoint("BOTTOM", raidStatusFrame, "TOP", 0, 0);
			end
		end
		--Update resistances button.
		NRC:updateRaidStatusButtonText();
		for i = 1, 8 do
			raidStatusFrame.groupFrames[i]:Hide();
		end
		columCount = #data.columns;
		if (NRC.firstRaidStatusUpdate) then
			NRC.firstRaidStatusUpdate = nil;
			--On first open if the player is in combat and on a super slow pc it can exceed the 0.25 second script ran too long threshold.
			--So split up the creation of the frames and the calc to seperate frames.
			C_Timer.After(0.01, function()
				NRC:updateRaidStatusFrames(false);
			end)
			return;
		end
	end
	local usingCache = NRC.raidStatusCache and true;
	local showSwipe = NRC.config.raidStatusBuffSwipe;
	local enchantIgnoreList = NRC.enchantIgnoreList;
	local showOnyCloak = (isClassic and NRC.currentInstanceID == 469 and not usingCache);
	--local showOnyCloak = true;
	if (data) then
		local columnCount, maxColumnCount = 0, raidStatusFrame.maxColumnCount;
		local rowCount, maxRowCount = 1, raidStatusFrame.maxRowCount;
		local gridCount = maxColumnCount * maxRowCount;
		--local gridName = string.char(96 + rowCount) .. columnCount;
		local count = 0;
		local subGroups;
		if (data.chars and next(data.chars)) then
			if (NRC.config.sortRaidStatusByGroups) then
				subGroups = {};
				--Check to make sure all members have a subgroup.
				--This also helps with viewing snapshots before recording of subgroups were added.
				for k, v in pairs(data.chars) do
					if (not v.subGroup) then
						subGroups = nil;
					end
				end
				if (subGroups) then
					table.sort(data.chars, function(a, b) return a.subGroup < b.subGroup end);
				else
					table.sort(data.chars, function(a, b) return a.name < b.name end);
				end
			else
				table.sort(data.chars, function(a, b) return a.name < b.name end);
			end
			local usedGroupframes = {};
			for k, v in ipairs(data.chars) do
				local name = v.name;
				count = count + 1;
				rowCount = rowCount + 1;
				local rowName = string.char(96 + rowCount);
				local _, _, _, classHex = getClassColor(v.class);
				local nameString;
				local hasAlpha, hasGamma;
				--[[local fullName;
				if (v.realm) then
					fullName = name .. "-" .. v.realm;
				else
					fullName = name .. "-" .. NRC.realm;
				end]]
				if (not v.online and not NRC.raidStatusCache) then
					if (subGroups or readyCheckRunning or readyCheckEndedTimer or fadeOutTimer) then
						nameString = "|c" .. classHex .. strsub(name, 1, 6) .. "|r |cFF989898(Offline)|r";
					else
						nameString = count .. ". |c" .. classHex .. strsub(name, 1, 6) .. "|r |cFF989898(Offline)|r";
					end
				else
					if (subGroups or readyCheckRunning or readyCheckEndedTimer or fadeOutTimer) then
						nameString = "|c" .. classHex .. strsub(name, 1, 15) .. "|r";
					else
						nameString = count .. ". |c" .. classHex .. strsub(name, 1, 15) .. "|r";
					end
				end
				if (not raidStatusFrame.subFrames[rowName .. "1"]) then
					--Sometimes bug that happens when joining a group, just delay until the next tick 1 second later.
					return;
				end
				local nameFrame = raidStatusFrame.subFrames[rowName .. "1"];
				nameFrame.fs:SetText(nameString);
				nameFrame.name = name;
				if (subGroups) then
					local frame = raidStatusFrame.groupFrames[v.subGroup];
					if (not usedGroupframes[v.subGroup]) then
						frame:ClearAllPoints();
						if (not raidStatusFrame.subFrames[rowName .. columCount] or not nameFrame) then
							--Looking for a bug.
							NRC:debug(raidStatusFrame.subFrames[rowName .. columCount], nameFrame)
						end
						frame:SetPoint("TOPRIGHT", raidStatusFrame.subFrames[rowName .. columCount], "TOPRIGHT", 0, 0.6);
						frame:SetPoint("TOPLEFT", nameFrame, "TOPLEFT", -20, 0.6);
						frame:SetPoint("BOTTOMRIGHT", raidStatusFrame.subFrames[rowName .. columCount], "BOTTOMRIGHT", 0, -0.6);
						frame:SetPoint("BOTTOMLEFT", nameFrame, "BOTTOMLEFT", -20, -0.6);
						frame.bg.fs:SetText("G" .. v.subGroup);
						frame:Show();
						usedGroupframes[v.subGroup] = true;
					else
						frame:SetPoint("BOTTOMRIGHT", raidStatusFrame.subFrames[rowName .. columCount], "BOTTOMRIGHT", 0, -0.6);
						frame:SetPoint("BOTTOMLEFT", nameFrame, "BOTTOMLEFT", -20, -0.6);
					end
				end
				local hasFlask, hasBattle, hasGuardian, hasScroll, hasFood, hasInt, hasFort, hasSpirit, hasShadow, hasMotw, hasPal, hasWorldBuffs, hasChronoboon;
				local hasWeaponEnchant, hasTalents, auras, hasExtraSlot1, hasExtraSlot2, hasExtraSlot3;
				if (NRC.raidStatusCache) then
					auras = NRC.raidStatusCache.auraCache[v.guid];
				else
					auras = NRC.auraCache[v.guid];
				end
				local elixirs, pallyBuffs, foodBuffs, scrollBuffs, enchantBuffs, wBuffs = {}, {}, {}, {}, {}, {};
				local eating;
				if (auras and next(auras) and (v.online or NRC.raidStatusCache)) then
					if (isSOD) then
						nameFrame.texture:ClearAllPoints();
						nameFrame.texture:SetTexture();
						if (auras[408696]) then
							nameFrame.texture:SetPoint("RIGHT", -4, 0);
							nameFrame.texture:SetSize(16, 16);
							nameFrame.texture:SetTexture(132203);
							hasAlpha = auras[408696].source or "Unknown";
						end
					elseif (checkGamma) then
						local gammaID, gammaData;
						for k, v in pairs(checkGamma) do
							if (auras[k]) then
								gammaID = k;
								gammaData = v;
								break;
							end
						end
						nameFrame.texture:ClearAllPoints();
						nameFrame.texture:SetTexture();
						if (gammaID) then
							nameFrame.texture:SetPoint("RIGHT", -4, 0);
							nameFrame.texture:SetSize(16, 16);
							nameFrame.texture:SetTexture(gammaData.icon);
							hasGamma = gammaID;
						end
					end
					local elixirCount = 1;
					for buffID, buffData in pairs(auras) do
						if (isClassic) then
							--If classic then combine flasks and elixirs, they stack.
							--Bit of a messy fix for now but I plan on rewriting this whole function soon to be a lot more efficient.
							if (flaskSlot) then
								if (NRC.flasks[buffID]) then
									local t = buffData;
									t.buffID = buffID;
									t.buffID = buffID;
									t.icon = NRC.flasks[buffID].icon;
									t.rank = NRC.flasks[buffID].rank;
									t.desc = NRC.flasks[buffID].desc;
									t.maxRank = NRC.flasks[buffID].maxRank;
									t.order = NRC.flasks[buffID].order;
									--Keep flask in slot 1;
									tinsert(elixirs, 1, t);
									hasFlask = true;
								end
								if (NRC.battleElixirs[buffID]) then
									local t = buffData;
									t.buffID = buffID;
									t.icon = NRC.battleElixirs[buffID].icon;
									t.rank = NRC.battleElixirs[buffID].rank;
									t.desc = NRC.battleElixirs[buffID].desc;
									t.maxRank = NRC.battleElixirs[buffID].maxRank;
									t.order = NRC.battleElixirs[buffID].order;
									tinsert(elixirs, t);
									hasFlask = true;
								end
								if (NRC.guardianElixirs[buffID]) then
									local t = buffData;
									t.buffID = buffID;
									t.icon = NRC.guardianElixirs[buffID].icon;
									t.rank = NRC.guardianElixirs[buffID].rank;
									t.desc = NRC.guardianElixirs[buffID].desc;
									t.maxRank = NRC.guardianElixirs[buffID].maxRank;
									t.order = NRC.guardianElixirs[buffID].order;
									tinsert(elixirs, t);
									hasFlask = true;
								end
							end
						else
							if (flaskSlot and NRC.flasks[buffID]) then
								local frame = raidStatusFrame.subFrames[rowName .. flaskSlot];
								frame.fs:SetText("");
								--frame.fs2:SetText("");
								frame.texture:ClearAllPoints();
								frame.texture2:ClearAllPoints();
								frame.texture2:SetTexture();
								frame.texture:SetPoint("CENTER", 0, 0);
								frame.texture:SetTexture(NRC.flasks[buffID].icon);
								frame.texture:SetSize(16, 16);
								hasFlask = true;
								updateGridTooltip(frame, NRC.flasks[buffID], buffData);
								updateBackgroundColor(frame, not NRC.flasks[buffID].maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache);
								if (not InCombatLockdown()) then
									frame:SetAttribute("macrotext", "/target " .. name);
								end
								updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
							elseif (flaskSlot) then
								if (NRC.battleElixirs[buffID]) then
									elixirs[1] = buffData;
									elixirs[1].buffID = buffID;
									hasFlask = true;
								end
								if (NRC.guardianElixirs[buffID]) then
									elixirs[2] = buffData;
									elixirs[2].buffID = buffID;
									hasFlask = true;
								end
							end
						end
						if (scrollSlot and NRC.scrolls[buffID]) then
							tinsert(scrollBuffs, buffData);
							--Merge some db data with our player auras data.
							scrollBuffs[#scrollBuffs].buffID = buffID;
							scrollBuffs[#scrollBuffs].icon = NRC.scrolls[buffID].icon;
							scrollBuffs[#scrollBuffs].rank = NRC.scrolls[buffID].rank;
							scrollBuffs[#scrollBuffs].desc = NRC.scrolls[buffID].desc;
							scrollBuffs[#scrollBuffs].maxRank = NRC.scrolls[buffID].maxRank;
							scrollBuffs[#scrollBuffs].order = NRC.scrolls[buffID].order;
							hasScroll = true;
						end
						if (foodSlot and validFoods[buffID]) then
							eating = buffData.endTime or 0;
						elseif (foodSlot and NRC.foods[buffID]) then
							--local duration = buffData.endTime - GetServerTime();
							--if (duration <)
							tinsert(foodBuffs, buffData);
							--Merge some db data with our player auras data.
							foodBuffs[#foodBuffs].buffID = buffID;
							foodBuffs[#foodBuffs].icon = NRC.foods[buffID].icon;
							foodBuffs[#foodBuffs].rank = NRC.foods[buffID].rank;
							foodBuffs[#foodBuffs].desc = NRC.foods[buffID].desc;
							foodBuffs[#foodBuffs].maxRank = NRC.foods[buffID].maxRank;
							foodBuffs[#foodBuffs].order = NRC.foods[buffID].order;
							if (buffData.endTime) then
								hasFood = buffData.endTime - GetServerTime();
							end
							
							--A little hacky sorting for now, going to rewrite this whole func at some point.
							--Display chilli on the right always.
							if (foodBuffs[1] and foodBuffs[2] and foodBuffs[1].buffID == 15852) then
								local temp = foodBuffs[1];
								foodBuffs[1] = foodBuffs[2]
								foodBuffs[2] = temp;
							end
						end
						if (intSlot and int[buffID]) then
							local frame = raidStatusFrame.subFrames[rowName .. intSlot];
							frame.fs:SetText("");
							frame.texture:SetTexture(int[buffID].icon);
							frame.texture:SetSize(15, 15);
							hasInt = true;
							updateGridTooltip(frame, int[buffID], buffData);
							updateBackgroundColor(frame, not int[buffID].maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
							if (not InCombatLockdown()) then
								frame:SetAttribute("macrotext", "/target " .. name);
							end
							updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
						end
						if (fortSlot and fort[buffID]) then
							local frame = raidStatusFrame.subFrames[rowName .. fortSlot];
							frame.fs:SetText("");
							frame.texture:SetTexture(fort[buffID].icon);
							frame.texture:SetSize(16, 16);
							hasFort = true;
							updateGridTooltip(frame, fort[buffID], buffData);
							updateBackgroundColor(frame, not fort[buffID].maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
							if (not InCombatLockdown()) then
								frame:SetAttribute("macrotext", "/target " .. name);
							end
							updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
						end
						if (spiritSlot and spirit[buffID]) then
							local frame = raidStatusFrame.subFrames[rowName .. spiritSlot];
							frame.fs:SetText("");
							frame.texture:SetTexture(spirit[buffID].icon);
							frame.texture:SetSize(16, 16);
							hasSpirit = true;
							updateGridTooltip(frame, spirit[buffID], buffData);
							updateBackgroundColor(frame, not spirit[buffID].maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
							if (not InCombatLockdown()) then
								frame:SetAttribute("macrotext", "/target " .. name);
							end
							updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
						end
						if (shadowSlot and shadow[buffID]) then
							local frame = raidStatusFrame.subFrames[rowName .. shadowSlot];
							frame.fs:SetText("");
							frame.texture:SetTexture(shadow[buffID].icon);
							frame.texture:SetSize(16, 16);
							hasShadow = true;
							updateGridTooltip(frame, shadow[buffID], buffData);
							updateBackgroundColor(frame, not shadow[buffID].maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
							if (not InCombatLockdown()) then
								frame:SetAttribute("macrotext", "/target " .. name);
							end
							updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
						end
						if (motwSlot and motw[buffID]) then
							local frame = raidStatusFrame.subFrames[rowName .. motwSlot];
							frame.fs:SetText("");
							frame.texture:SetTexture(motw[buffID].icon);
							frame.texture:SetSize(16, 16);
							hasMotw = true;
							updateGridTooltip(frame, motw[buffID], buffData);
							updateBackgroundColor(frame, not motw[buffID].maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
							if (not InCombatLockdown()) then
								frame:SetAttribute("macrotext", "/target " .. name);
							end
							updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
						end
						if (expansionNum > 4) then
							if (extraDataTable.extraSlot1 and NRC.extraSlot1Data[buffID]) then
								--Ran our of upvalues to have to use a extraDataTable table until I clean this func up...
								local frame = raidStatusFrame.subFrames[rowName .. extraDataTable.extraSlot1];
								local extraSlotBuff = extraDataTable.extraSlot1Data[buffID];
								frame.fs:SetText("");
								frame.texture:SetTexture(extraSlotBuff.icon);
								frame.texture:SetSize(16, 16);
								hasExtraSlot1 = true;
								updateGridTooltip(frame, extraSlotBuff, buffData);
								updateBackgroundColor(frame, not extraSlotBuff.maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
								if (not InCombatLockdown()) then
									frame:SetAttribute("macrotext", "/target " .. name);
								end
								updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
							end
							if (extraDataTable.extraSlot2 and NRC.extraSlot2Data[buffID]) then
								--Ran our of upvalues to have to use a extraDataTable table until I clean this func up...
								local frame = raidStatusFrame.subFrames[rowName .. extraDataTable.extraSlot2];
								local extraSlotBuff = extraDataTable.extraSlot2Data[buffID];
								frame.fs:SetText("");
								frame.texture:SetTexture(extraSlotBuff.icon);
								frame.texture:SetSize(16, 16);
								hasExtraSlot2 = true;
								updateGridTooltip(frame, extraSlotBuff, buffData);
								updateBackgroundColor(frame, not extraSlotBuff.maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
								if (not InCombatLockdown()) then
									frame:SetAttribute("macrotext", "/target " .. name);
								end
								updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
							end
							if (extraDataTable.extraSlot3 and NRC.extraSlot3Data[buffID]) then
								--Ran our of upvalues to have to use a extraDataTable table until I clean this func up...
								local frame = raidStatusFrame.subFrames[rowName .. extraDataTable.extraSlot3];
								local extraSlotBuff = extraDataTable.extraSlot3Data[buffID];
								frame.fs:SetText("");
								frame.texture:SetTexture(extraSlotBuff.icon);
								frame.texture:SetSize(16, 16);
								hasExtraSlot3 = true;
								updateGridTooltip(frame, extraSlotBuff, buffData);
								updateBackgroundColor(frame, not extraSlotBuff.maxRank, buffData.endTime and buffData.endTime - GetServerTime() < lowDurationTime and not usingCache and buffData.duration ~= 0, buffData.duration);
								if (not InCombatLockdown()) then
									frame:SetAttribute("macrotext", "/target " .. name);
								end
								updateCooldownSwipe(frame.texture, buffData.endTime, buffData.duration);
							end
						end
						if (palSlot and pal[buffID]) then
							tinsert(pallyBuffs, buffData);
							--Merge some local data with our player auras data.
							pallyBuffs[#pallyBuffs].buffID = buffID;
							pallyBuffs[#pallyBuffs].icon = pal[buffID].icon;
							pallyBuffs[#pallyBuffs].rank = pal[buffID].rank;
							pallyBuffs[#pallyBuffs].desc = pal[buffID].desc;
							pallyBuffs[#pallyBuffs].maxRank = pal[buffID].maxRank;
							pallyBuffs[#pallyBuffs].order = pal[buffID].order;
							hasPal = true;
						end
						if (worldBuffsSlot) then
							--[[if (NRC.raidStatusCache and NRC.raidStatusCache.chronoCache) then
								tinsert(wBuffs, buffData);
								--Merge some local data with our player auras data.
								wBuffs[#wBuffs].buffID = buffID;
								wBuffs[#wBuffs].icon = 133881;
								wBuffs[#wBuffs].desc = "Suspended World Buffs";
								wBuffs[#wBuffs].maxRank = true;
								wBuffs[#wBuffs].order = 0;
								hasChronoboon = true;
								hasWorldBuffs = true;
							else]]
								if (buffID == 349981) then
									--Chronoboon.
									tinsert(wBuffs, buffData);
									--Merge some local data with our player auras data.
									wBuffs[#wBuffs].buffID = buffID;
									wBuffs[#wBuffs].icon = 133881;
									wBuffs[#wBuffs].desc = "Suspended World Buffs";
									wBuffs[#wBuffs].maxRank = true;
									wBuffs[#wBuffs].order = 0;
									hasChronoboon = true;
									hasWorldBuffs = true;
								end
								if (worldBuffs[buffID]) then
									tinsert(wBuffs, buffData);
									--Merge some local data with our player auras data.
									wBuffs[#wBuffs].buffID = buffID;
									wBuffs[#wBuffs].icon = worldBuffs[buffID].icon;
									wBuffs[#wBuffs].rank = worldBuffs[buffID].rank;
									wBuffs[#wBuffs].desc = worldBuffs[buffID].desc;
									wBuffs[#wBuffs].maxRank = worldBuffs[buffID].maxRank;
									wBuffs[#wBuffs].order = worldBuffs[buffID].order;
									hasWorldBuffs = true;
								end
							--end
						end
					end
				end
				if (duraSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. duraSlot];
					frame.texture:ClearAllPoints();
					frame.texture:SetPoint("CENTER", 0, 0);
					frame.texture:SetTexture();
					frame.texture:SetSize(16, 16);
					if (NRC.raidStatusCache) then
						local letterCount = count;
						if (count > 27) then
							letterCount = count - 27;
						elseif (count > 18) then
							letterCount = count - 18;
						elseif (count > 9) then
							letterCount = count - 9;
						end
						local letter = strsub("Snapshot ", letterCount, letterCount);
						frame.fs:SetText("|cFFFFFF00" .. letter);
					else
						local data = NRC.durability[name];
						--local data = {};
						--data.percent = math.random(50, 100);
						if (data) then
							local color = "|cFF00C800";
							if (data.percent < 31) then
								color = "|cFFFF2222";
							elseif (data.percent < 70) then
								color = "|cFFDEDE42";
							end
							local coloredDura = color .. data.percent .. "%|r";
							local text = coloredDura;
							if (data.broken and data.broken > 0) then
								text = text .. " |cFFFF0000(" .. data.broken .. ")|r";
							end
							frame.fs:SetText(text);
							updateDuraTooltip(frame, name, v.class, coloredDura, data.broken);
						else
							frame.fs:SetText("--");
							frame.updateTooltip();
						end
					end
				end
				if (shadowResSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. shadowResSlot];
					frame.texture:ClearAllPoints();
					frame.texture:SetPoint("CENTER", 0, 0);
					frame.texture:SetTexture();
					frame.texture:SetSize(16, 16);
					local data;
					if (NRC.raidStatusCache) then
						if (NRC.raidStatusCache.resCache) then
							data = NRC.raidStatusCache.resCache[name];
						end
					else
						data = NRC.resistances[name];
					end
					if (data) then
						local resString = colorizeRes(data[5]);
						frame.fs:SetText(resString);
						updateGridTooltipRes(frame, name, classHex, "|cffa44aa9Shadow Res:|r", resString);
					elseif (frame) then
						frame.fs:SetText("--");
						frame.updateTooltip();
					end
				end
				if (fireResSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. fireResSlot];
					frame.texture:ClearAllPoints();
					frame.texture:SetPoint("CENTER", 0, 0);
					frame.texture:SetTexture();
					frame.texture:SetSize(16, 16);
					local data;
					if (NRC.raidStatusCache) then
						if (NRC.raidStatusCache.resCache) then
							data = NRC.raidStatusCache.resCache[name];
						end
					else
						data = NRC.resistances[name];
					end
					if (data) then
						local resString = colorizeRes(data[2]);
						frame.fs:SetText(resString);
						updateGridTooltipRes(frame, name, classHex, "|cffba3434Fire Res:|r", resString);
					elseif (frame) then
						frame.fs:SetText("--");
						frame.updateTooltip();
					end
				end
				if (natureResSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. natureResSlot];
					frame.texture:ClearAllPoints();
					frame.texture:SetPoint("CENTER", 0, 0);
					frame.texture:SetTexture();
					frame.texture:SetSize(16, 16);
					local data;
					if (NRC.raidStatusCache) then
						if (NRC.raidStatusCache.resCache) then
							data = NRC.raidStatusCache.resCache[name];
						end
					else
						data = NRC.resistances[name];
					end
					if (data) then
						local resString = colorizeRes(data[3]);
						frame.fs:SetText(resString);
						updateGridTooltipRes(frame, name, classHex, "|cff42a229Nature Res:|r", resString);
					elseif (frame) then
						frame.fs:SetText("--");
						frame.updateTooltip();
					end
				end
				if (frostResSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. frostResSlot];
					frame.texture:ClearAllPoints();
					frame.texture:SetPoint("CENTER", 0, 0);
					frame.texture:SetTexture();
					frame.texture:SetSize(16, 16);
					local data;
					if (NRC.raidStatusCache) then
						if (NRC.raidStatusCache.resCache) then
							data = NRC.raidStatusCache.resCache[name];
						end
					else
						data = NRC.resistances[name];
						frame.updateTooltip();
					end
					if (data) then
						local resString = colorizeRes(data[4]);
						frame.fs:SetText(resString);
						updateGridTooltipRes(frame, name, classHex, "|cff0096FFFrost Res:|r", resString);
					elseif (frame) then
						frame.fs:SetText("--");
					end
				end
				if (arcaneResSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. arcaneResSlot];
					frame.texture:ClearAllPoints();
					frame.texture:SetPoint("CENTER", 0, 0);
					frame.texture:SetTexture();
					frame.texture:SetSize(16, 16);
					local data;
					if (NRC.raidStatusCache) then
						if (NRC.raidStatusCache.resCache) then
							data = NRC.raidStatusCache.resCache[name];
						end
					else
						data = NRC.resistances[name];
					end
					if (data) then
						local resString = colorizeRes(data[6]);
						frame.fs:SetText(resString);
						updateGridTooltipRes(frame, name, classHex, "|cfff7fbffArcane Res:|r", resString);
					elseif (frame) then
						frame.fs:SetText("--");
						frame.updateTooltip();
					end
				end
				--[[if (armorSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. armorSlot];
					frame.texture:ClearAllPoints();
					frame.texture:SetPoint("CENTER", 0, 0);
					frame.texture:SetTexture();
					frame.texture:SetSize(16, 16);
					local data;
					if (NRC.raidStatusCache) then
						data = NRC.raidStatusCache.resistances[name];
					else
						data = NRC.resistances[name];
					end
					if (data) then
						local color = "|cFFFF2222";
						if (data[0] > 1) then
							color = "|cFF00C800";
						--elseif (data.percent < 70) then
						--	color = "|cFFDEDE42";
						end
						frame.fs:SetText(color .. data[0] .. "|r");
					else
						frame.fs:SetText("--");
						frame.updateTooltip();
					end
				end]]
				if (weaponEnchantsSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. weaponEnchantsSlot];
					local data;
					if (NRC.raidStatusCache) then
						if (NRC.raidStatusCache.weaponEnchantCache) then
							data = NRC.raidStatusCache.weaponEnchantCache[name];
						end
					else
						data = NRC.weaponEnchants[name];
					end
					if (data) then
						if (data[1] and (data[2] > GetServerTime() or NRC.raidStatusCache)) then
							--Mainhand.
							if (not enchantIgnoreList[data[1]]) then
								if (weaponEnchants[data[1]]) then
									local t = {
										name = weaponEnchants[data[1]].name,
										icon = weaponEnchants[data[1]].icon,
										endTime = data[2],
										duration = weaponEnchants[data[1]].duration;
										maxRank = weaponEnchants[data[1]].maxRank;
										desc = weaponEnchants[data[1]].desc;
										order = 1,
									};
									tinsert(enchantBuffs, t);
									hasWeaponEnchant = true;
									
								else
									NRC:debug("unknown weapon enchant", name, data[1]);
								end
							end
						end
						if (data[3] and (data[4] > GetServerTime() or NRC.raidStatusCache)) then
							--Offhand.
							if (not enchantIgnoreList[data[3]]) then
								if (weaponEnchants[data[3]]) then
									local t = {
										name = weaponEnchants[data[3]].name,
										icon = weaponEnchants[data[3]].icon,
										endTime = data[4],
										duration = weaponEnchants[data[3]].duration;
										maxRank = weaponEnchants[data[3]].maxRank;
										desc = weaponEnchants[data[3]].desc;
										order = 2,
									};
									tinsert(enchantBuffs, t);
									hasWeaponEnchant = true;
								else
									NRC:debug("unknown weapon2 enchant", name, data[3]);
								end
							end
						end
					end
					if (frame and not hasWeaponEnchant) then
						frame.updateTooltip();
					end
				end
				if (talentsSlot) then
					local frame = raidStatusFrame.subFrames[rowName .. talentsSlot];
					local talentString;
					if (NRC.raidStatusCache) then
						if (NRC.raidStatusCache.talentCache) then
							talentString = NRC.raidStatusCache.talentCache[name];
							--talentString = NRC:getTalentsFromEncounter(name, NRC.raidStatusCache.logID, NRC.raidStatusCache.encounterID);
						end
					else
						talentString = NRC.talents[name];
					end
					if (talentString) then
						local specID, talentCount, specName, specIcon, specIconPath, treeData = NRC:getSpecFromTalentString(talentString);
						frame.fs:SetText("");
						frame.texture:SetTexture(specIcon);
						frame.texture:SetSize(16, 16);
						hasTalents = true;
						updateGridTooltipTalents(frame, name, classHex, talentCount, specName, specIcon, treeData, showOnyCloak, v.hasOnyCloak, v.hasDataShare, v.addonVersion, v.helperVersion);
						--We shouldn't have to remove this click onclick handler if the talents colum option is disabled.
						--This is the last column so this column won't be reused for any other type.
						frame:SetScript("OnClick", function(self)
							local fromRaidStatus = not NRC.raidStatusCache;
							NRC:openTalentFrame(name, talentString, nil, nil, nil, nil, nil, v.guid, nil, fromRaidStatus);
						end)
					elseif (frame) then
						frame.fs:SetText("--");
						frame.updateTooltip();
						frame:SetScript("OnClick", function(self)
							
						end)
					end
					if (isClassic) then
						if (showOnyCloak and not NRC.raidStatusCache) then
							if (v.hasDataShare) then
								if (v.hasOnyCloak) then
									frame.texture2:SetTexture(133757);
									frame.texture2:SetSize(16, 16);
									frame.texture:SetPoint("RIGHT", frame, "CENTER", -2.5, 0);
									frame.texture2:SetPoint("LEFT", frame, "CENTER", 2.5, 0);
									frame.fs:SetPoint("CENTER", -9, 0);
								else
									--Not sure if display a missing icon or just move talents icon back to middle yet.
									--frame.fs2:SetText("|cFFFF0000X|r");
									--frame.fs2:SetPoint("CENTER", 9, 0);
									frame.texture:ClearAllPoints();
									frame.texture:SetPoint("CENTER", 0, 0);
									frame.texture2:SetTexture();
									frame.fs:SetPoint("CENTER", 0, 0);
								end
							else
								frame.texture:ClearAllPoints();
								frame.texture:SetPoint("CENTER", 0, 0);
								frame.texture2:SetTexture();
								frame.fs:SetPoint("CENTER", 0, 0);
							end
						else
							frame.texture:ClearAllPoints();
							frame.texture:SetPoint("CENTER", 0, 0);
							frame.texture2:SetTexture();
							frame.fs:SetPoint("CENTER", 0, 0);
						end
					end
				end
				if (v.specialSlotData) then
					local frame = raidStatusFrame.subFrames[rowName .. specialSlot];
					local specialData = v.specialSlotData;
					if (specialData == true) then
						--If data is only true and not a table then no data for this special display was found, display it as missing.
						frame.fs:SetText("--");
						frame.updateTooltip();
						frame.texture:ClearAllPoints();
						frame.texture:SetPoint("CENTER", 0, 0);
						frame.fs:ClearAllPoints();
						frame.fs:SetPoint("CENTER", 0, 0);
						frame.texture:SetTexture();
					else
						if (specialData.type == "naxx") then
							--frame.texture:SetPoint("RIGHT", frame, "CENTER", -2.5, 0);
							frame.texture:SetPoint("LEFT", frame, "LEFT", 1, 0);
							frame.texture:SetSize(15, 15);
							frame.fs:SetPoint("CENTER", 9, 0);
							--frame.texture:SetTexture(specialData.icon);
							frame.texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
							local role = specialData.role;
							if (role == "Damage") then
								--UnitPopupSharedButtonMixins.lua
								--/dump INLINE_DAMAGER_ICON
								--Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:1:20
								frame.texture:SetTexCoord(GetTexCoordsForRoleSmallCircle("DAMAGER"));
							elseif (role == "Heals") then
								frame.texture:SetTexCoord(GetTexCoordsForRoleSmallCircle("HEALER"));
							else
								frame.texture:SetTexCoord(GetTexCoordsForRoleSmallCircle("TANK"));
							end
							frame.fs:ClearAllPoints();
							frame.fs:SetPoint("CENTER", 9, 0);
							frame.fs:SetFont(NRC.regionFont, 10);
							local percent = specialData.percent;
							local percentText;
							--[[if (percent > 37) then
								--Rank 10
								percentText = "|cFF00FF00" .. specialData.percent .. "%|r";
							elseif (percent > 28) then
								--Rank 8+
								percentText = "|cFFFFAE42" .. specialData.percent .. "%|r";
							elseif (percent > 16) then
								--Rank 6+
								percentText = "|cFFFFFF00" .. specialData.percent .. "%|r";
							elseif (percent > 6) then
								--Rank 3+
								percentText = "|cFF9CD6DE" .. specialData.percent .. "%|r";
							else
								percentText = "|cFFFFFFFF" .. specialData.percent .. "%|r";
							end]]
							--Show all as yellow for now, may adust colors based on level later.
							percentText = "|cFFFFFF00" .. specialData.percent .. "%|r";
							frame.fs:SetText(percentText);
							local tooltipString = specialData.name .. "\n+" .. percentText .. "\n|T" .. specialData.icon .. ":11:11|t |cFFFFFF00" .. specialData.role;
							updateTooltipSpecialSlot(frame, name, classHex, tooltipString);
						end
					end
				end
				if (v.specialSlotData2) then
					local frame = raidStatusFrame.subFrames[rowName .. specialSlot2];
					local specialData2 = v.specialSlotData2;
					if (specialData2 == true) then
						--If data is only true and not a table then no data for this special display was found, display it as missing.
						frame.fs:SetText("--");
						frame.updateTooltip();
						frame.texture:ClearAllPoints();
						frame.texture:SetPoint("CENTER", 0, 0);
						frame.fs:ClearAllPoints();
						frame.fs:SetPoint("CENTER", 0, 0);
						frame.texture:SetTexture();
					else
						local text;
						local tooltipString;
						if (specialData2 < 8) then
							text = "|cFFFFFF00" .. specialData2 .. "|cFF34FDF0 / 8";
							tooltipString = "|cFFFFFF00" .. specialData2 .. "|cFF34FDF0 / 8 sanctified pieces equipped";
						else
							text = "|cFF34FDF08|cFF34FDF0 / 8";
							tooltipString = "|cFF34FDF0" .. specialData2 .. "|cFF34FDF0 / 8 sanctified pieces equipped";
						end
						--frame.texture:SetPoint("CENTER", 0, 0);
						frame.fs:SetPoint("CENTER", 0, 0);
						frame.fs:SetText(text);
						frame.texture:SetTexture();
						updateTooltipSpecialSlot(frame, name, classHex, tooltipString);
					end
				end
				if (v.specialSlotData3) then
					local frame = raidStatusFrame.subFrames[rowName .. specialSlot3];
					local specialData3 = v.specialSlotData3;
					if (specialData3 == true) then
						--If data is only true and not a table then no data for this special display was found, display it as missing.
						frame.fs:SetText("--");
						frame.updateTooltip();
						frame.texture:ClearAllPoints();
						frame.texture:SetPoint("CENTER", 0, 0);
						frame.fs:ClearAllPoints();
						frame.fs:SetPoint("CENTER", 0, 0);
						frame.texture:SetTexture();
						local tooltipString = "|cFFFFFF00No found data yet.\n|cFFFFFFFFUpdating equip when in range of player...";
						updateTooltipSpecialSlot(frame, name, classHex, tooltipString);
					else
						--frame.texture:SetPoint("CENTER", 0, 0);
						frame.fs:SetPoint("CENTER", 0, 0);
						frame.fs:SetText("|cFF9CD6DE" .. v.specialSlotData3);
						frame.texture:SetTexture();
						local tooltipString = "|cFFFFFF00Average item level: |cFF9CD6DE" .. v.specialSlotData3;
						local gearCache = NRC.gearCache[v.guid];
						if (gearCache and gearCache.totalCurrentUpgradeLevels and gearCache.totalMaxUpgradeLevels and gearCache.totalMaxUpgradeLevels > 0) then
							local text = "\n|cFFFFFF00Total upgrade levels: ";
							if (gearCache.totalCurrentUpgradeLevels == 0) then
								text = text .. "|cFFFFFFFF" .. gearCache.totalCurrentUpgradeLevels .. "/" .. gearCache.totalMaxUpgradeLevels .. "|r";
							elseif (gearCache.totalCurrentUpgradeLevels == gearCache.totalMaxUpgradeLevels) then
								text = text .. "|cFFFFFF00" .. gearCache.totalCurrentUpgradeLevels .. "/" .. gearCache.totalMaxUpgradeLevels .. "|r";
							else
								text = text .. "|cFFFFFFFF" .. gearCache.totalCurrentUpgradeLevels .. "/" .. gearCache.totalMaxUpgradeLevels .. "|r";
							end
							tooltipString = tooltipString .. text;
						end
						updateTooltipSpecialSlot(frame, name, classHex, tooltipString);
					end
					--if (not InCombatLockdown()) then
					--	frame:SetAttribute("click");
					--	frame:SetScript("OnClick", function(self)
					--		NRC:openEquipmentFrame(v.guid);
					--	end)
					--end
				end
				if (v.specialSlotData4) then
					local frame = raidStatusFrame.subFrames[rowName .. specialSlot4];
					local specialData4 = v.specialSlotData4;
					if (specialData4 == true) then
						--If data is only true and not a table then no data for this special display was found, display it as missing.
						frame.fs:SetText("--");
						frame.updateTooltip();
						frame.texture:ClearAllPoints();
						frame.texture2:ClearAllPoints();
						frame.texture:SetPoint("CENTER", 0, 0);
						frame.fs:ClearAllPoints();
						frame.fs:SetPoint("CENTER", 0, 0);
						frame.texture:SetTexture();
						frame.texture2:SetTexture();
						local tooltipString = "|cFFFFFF00No found data yet.\n|cFFFFFFFFUpdating equip when in range of player...";
						updateTooltipSpecialSlot(frame, name, classHex, tooltipString);
					else
						frame.texture:SetPoint("CENTER", 0, 0);
						--local totalIssues = NRC:getTotalIssues(v.guid);
						local issues = NRC.issuesCache[v.guid];
						local gearCache = NRC.gearCache[v.guid];
						frame.texture:ClearAllPoints();
						frame.texture2:ClearAllPoints();
						frame.texture:SetSize(16, 16);
						--frame.texture2:SetSize(16, 16);
						frame.texture:Show();
						frame.texture2:Hide();
						--frame.texture2:Show();
						--frame.texture:SetTexture(626008);
						--frame.texture:SetTexture("Interface\\AddOns\\NovaRaidCompanion\\Media\\redsword.png");
						local tooltipString = "";
						if (issues and issues.totalIssues > 0) then
							local totalIssues = issues.totalIssues;
							frame.texture:SetPoint("CENTER", 0, 0);
							frame.fs:SetPoint("CENTER", -16.5, 0);
							frame.texture:SetTexture("Interface\\AddOns\\NovaRaidCompanion\\Media\\redsword.png");
							if (issues.gearMissingIssues and issues.gearMissingIssues > 0) then
								frame.fs:SetText("|cFFFF0000" .. totalIssues);
							else
								frame.fs:SetText("|cFFA1A1A1" .. totalIssues);
							end
							--Must use icons here that are also in TBC/Classic for thier issues.
							if (issues.fishingIssues and issues.fishingIssues > 0) then
								frame.texture2:SetPoint("CENTER", 16.5, 0);
								frame.texture2:SetSize(16, 16);
								frame.texture2:SetTexture(132931);
								frame.texture2:Show();
							elseif (issues.talentsMissing and issues.talentsMissing > 0) then
								frame.texture2:SetPoint("CENTER", 16.5, 0);
								frame.texture2:SetSize(16, 16);
								frame.texture2:SetTexture(132222);
								frame.texture2:Show();
							elseif (issues.enchantIssues and issues.enchantIssues > 0) then
								frame.texture2:SetPoint("CENTER", 16.5, 0);
								frame.texture2:SetSize(16, 16);
								frame.texture2:SetTexture(136244);
								frame.texture2:Show();
							elseif (issues.gemIssues and issues.gemIssues > 0) then
								frame.texture2:SetPoint("CENTER", 16.5, 0);
								frame.texture2:SetSize(16, 16);
								frame.texture2:SetTexture(133252);
								frame.texture2:Show();
							elseif (issues.beltBuckleIssues and issues.beltBuckleIssues > 0) then
								frame.texture2:SetPoint("CENTER", 16.5, 0);
								frame.texture2:SetSize(16, 16);
								frame.texture2:SetTexture(132525);
								frame.texture2:Show();
							elseif (issues.glyphIssues and issues.glyphIssues > 0) then
								frame.texture2:SetPoint("CENTER", 16.5, 0);
								frame.texture2:SetSize(16, 16);
								--frame.texture2:SetTexture(254290); --Green.
								--frame.texture2:SetTexture(254295); --Blue.
								frame.texture2:SetTexture(254288); --Red.
								frame.texture2:Show();
							end
							for k, v in ipairs(issues.otherIssues) do
								if (v == L["Water Treads equipped"]) then
									frame.texture2:SetPoint("CENTER", 16.5, 0);
									frame.texture2:SetSize(16, 16);
									frame.texture2:SetTexture(132539);
									frame.texture2:Show();
									break;
								end
								if (v == L["PvP Trinket equipped"]) then
									frame.texture2:SetPoint("CENTER", 16.5, 0);
									frame.texture2:SetSize(16, 16);
									frame.texture2:SetTexture(pvpTrinketIcon);
									frame.texture2:Show();
									break;
								end
							end
							--frame.texture:SetTexture(armorTypes[v.class] or 133831)
							tooltipString = tooltipString .. "|cFFFF6900Total issues found:|r |cFF9CD6DE" .. totalIssues .. "|r";
							tooltipString = tooltipString .. "\n" .. NRC:getIssuesString(v.guid);
						else
							--frame.fs:SetPoint("CENTER", 8.5, 0);
							frame.texture:SetPoint("CENTER", 0, 0);
							frame.fs:SetText("");
							frame.texture:SetTexture("Interface\\AddOns\\NovaRaidCompanion\\Media\\greensword.png");
							--frame.texture:SetTexture(armorTypes[v.class] or 133831);
							--frame.texture:SetTexture(132739);
							--frame.texture2:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");
							--frame.texture2:Show();
							tooltipString = tooltipString .. "|cFF00FF00No issues found";
						end
						--tooltipString = tooltipString .. "\n\n|cFFFFAE42[Click here to view equipment]\n";
						--tooltipString = tooltipString .. "\n\n|cFFFFFF00[Click here to view equipment]\n";
						if (gearCache and gearCache.totalCurrentUpgradeLevels and gearCache.totalMaxUpgradeLevels and gearCache.totalMaxUpgradeLevels > 0) then
							local text = "\n|cFFFFFF00Total upgrade levels: ";
							if (gearCache.totalCurrentUpgradeLevels == 0) then
								text = text .. "|cFFFFFFFF" .. gearCache.totalCurrentUpgradeLevels .. "/" .. gearCache.totalMaxUpgradeLevels .. "|r";
							elseif (gearCache.totalCurrentUpgradeLevels == gearCache.totalMaxUpgradeLevels) then
								text = text .. "|cFFFFFF00" .. gearCache.totalCurrentUpgradeLevels .. "/" .. gearCache.totalMaxUpgradeLevels .. "|r";
							else
								text = text .. "|cFFFFFFFF" .. gearCache.totalCurrentUpgradeLevels .. "/" .. gearCache.totalMaxUpgradeLevels .. "|r";
							end
							tooltipString = tooltipString .. text;
						end
						updateTooltipSpecialSlot(frame, name, classHex, tooltipString, "|cFFFFFF00(Click here to view equipment)\n");
					end
					if (not InCombatLockdown()) then
						--frame:SetAttribute("click");
						frame:SetScript("OnClick", function(self)
							NRC:openEquipmentFrame(v.guid);
						end)
					end
				end
				if (next(elixirs)) then
					--Sorting for max 2 icons only, and show X in missing slot (elixirs instead of a flask).
					local frame = raidStatusFrame.subFrames[rowName .. flaskSlot];
					frame.texture:SetTexCoord(0, 1, 0, 1); --Reset coords for first column, it shared some coord stuff with sod naxx column.
					--[[frame.fs:SetText("");
					local tooltipText = "";
					if (elixirs[1]) then
						frame.texture:SetPoint("RIGHT", frame, "CENTER", -0.5, 0);
						frame.texture:SetTexture(NRC.battleElixirs[elixirs[1].buffID].icon);
						frame.texture:SetSize(16, 16);
						if (not elixirs[2]) then
							--Has battle but not guardian.
							frame.texture2:SetTexture();
							frame.fs:SetText("|cFFFF0000X|r");
							frame.fs:SetPoint("CENTER", 9, 0);
						end
						tooltipText = tooltipText .. "|cFFFF6900Battle:|r |cFFDEDE42" .. elixirs[1].name .. "|r\n";
						tooltipText = tooltipText .. "|cFF9CD6DE" .. NRC.battleElixirs[elixirs[1].buffID].desc .. "|r\n";
						if (elixirs[1].endTime) then
							tooltipText = tooltipText .. NRC:getShortTime(elixirs[1].endTime - GetServerTime()) .. "|r";
						end
						updateCooldownSwipe(frame.texture, elixirs[1].endTime, elixirs[1].duration);
					else
						stopCooldownSwipe(frame.texture);
					end
					if (elixirs[2]) then
						frame.texture2:SetPoint("LEFT", frame, "CENTER", 0.5, 0);
						frame.texture2:SetTexture(NRC.guardianElixirs[elixirs[2].buffID].icon);
						frame.texture2:SetSize(16, 16);
						if (not elixirs[1]) then
							--Has guardian but not battle.
							frame.texture:SetTexture();
							frame.fs:SetText("|cFFFF0000X|r");
							frame.fs:SetPoint("CENTER", -9, 0);
						else
							tooltipText = tooltipText .. "\n";
						end
						tooltipText = tooltipText .. "|cFFFF6900Guardian:|r |cFFDEDE42" .. elixirs[2].name .. "|r\n";
						tooltipText = tooltipText .. "|cFF9CD6DE" .. NRC.guardianElixirs[elixirs[2].buffID].desc .. "|r\n";
						if (elixirs[2].endTime) then
							tooltipText = tooltipText .. NRC:getShortTime(elixirs[2].endTime - GetServerTime()) .. "|r";
						end
						updateCooldownSwipe(frame.texture2, elixirs[2].endTime, elixirs[2].duration);
					else
						stopCooldownSwipe(frame.texture);
					end
					frame.updateTooltip(tooltipText);]]
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					NRC:raidStatusSortMultipleIcons(frame, elixirs, 8, true, true);
					--[[for i = 1, 8 do
						if (elixirs[i]) then
							if (i == 1) then
								if (frame.texture.swipeRunning ~= elixirs[1].endTime) then
									stopCooldownSwipe(frame.texture);
								end
							else
								if (frame["texture" .. i] and frame["texture" .. i].swipeRunning ~= elixirs[i].endTime) then
									stopCooldownSwipe(frame["texture" .. i]);
								end
							end
						end
					end]]
					for k, v in pairs(elixirs) do
						if (k == 1) then
							if (frame.texture.swipeRunning ~= v.endTime) then
								updateCooldownSwipe(frame.texture, v.endTime, v.duration);
							end
						else
							if (frame["texture" .. k] and frame["texture" .. k].swipeRunning ~= v.endTime) then
								updateCooldownSwipe(frame["texture" .. k], v.endTime, v.duration);
							end
						end
					end
					--[[if (not elixirs[4]) then
						--Never add duration to 4th texture, they're too small to see properly if showing 4.
						if (elixirs[1]) then
							updateCooldownSwipe(frame.texture, elixirs[1].endTime, elixirs[1].duration);
						else
							stopCooldownSwipe(frame.texture);
						end
						if (elixirs[2]) then
							updateCooldownSwipe(frame.texture2, elixirs[2].endTime, elixirs[2].duration);
						else
							stopCooldownSwipe(frame.texture2);
						end
						if (elixirs[3]) then
							updateCooldownSwipe(frame.texture3, elixirs[3].endTime, elixirs[3].duration);
						else
							stopCooldownSwipe(frame.texture3);
						end
					else
						stopCooldownSwipe(frame.texture);
						stopCooldownSwipe(frame.texture2);
						stopCooldownSwipe(frame.texture3);
					end]]
				end
				--if (next(foodBuffs) and not eating) then
				if (next(foodBuffs)) then
					local frame = raidStatusFrame.subFrames[rowName .. foodSlot];
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					NRC:raidStatusSortMultipleIcons(frame, foodBuffs, 4, true, true, nil, isClassic and 60);
					if (foodBuffs[1]) then
						updateCooldownSwipe(frame.texture, foodBuffs[1].endTime, foodBuffs[1].duration);
					else
						stopCooldownSwipe(frame.texture);
					end
					if (foodBuffs[2]) then
						updateCooldownSwipe(frame.texture2, foodBuffs[2].endTime, foodBuffs[2].duration);
					else
						stopCooldownSwipe(frame.texture2);
					end
					if (foodBuffs[3]) then			
						updateCooldownSwipe(frame.texture3, foodBuffs[3].endTime, foodBuffs[3].duration);
					else
						stopCooldownSwipe(frame.texture3);
					end
					--Never add duration to 4th texture, they're too small to see properly if showing 4.
				elseif (eating) then
					local frame = raidStatusFrame.subFrames[rowName .. foodSlot];
					frame.texture:SetTexture();
					frame.texture2:SetTexture();
					frame.texture3:SetTexture();
					--frame.texture4:SetTexture();
					stopCooldownSwipe(frame.texture);
					stopCooldownSwipe(frame.texture2);
					stopCooldownSwipe(frame.texture3);		
				end
				if (next(scrollBuffs)) then
					local frame = raidStatusFrame.subFrames[rowName .. scrollSlot];
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					NRC:raidStatusSortMultipleIcons(frame, scrollBuffs, 4, true, true);
					if (scrollBuffs[1]) then
						updateCooldownSwipe(frame.texture, scrollBuffs[1].endTime, scrollBuffs[1].duration);
					else
						stopCooldownSwipe(frame.texture);
					end
					if (scrollBuffs[2]) then
						updateCooldownSwipe(frame.texture2, scrollBuffs[2].endTime, scrollBuffs[2].duration);
					else
						stopCooldownSwipe(frame.texture2);
					end
					if (scrollBuffs[3]) then			
						updateCooldownSwipe(frame.texture3, scrollBuffs[3].endTime, scrollBuffs[3].duration);
					else
						stopCooldownSwipe(frame.texture3);
					end
					--Never add duration to 4th texture, they're too small to see properly if showing 4.
				end
				if (next(pallyBuffs)) then
					local frame = raidStatusFrame.subFrames[rowName .. palSlot];
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					NRC:raidStatusSortMultipleIconsPally(frame, pallyBuffs, 4, true, true, true);
					if (not pallyBuffs[4]) then
						--Never add duration to 4th texture, they're too small to see properly if showing 4.
						if (pallyBuffs[1]) then
							updateCooldownSwipe(frame.texture, pallyBuffs[1].endTime, pallyBuffs[1].duration);
						else
							stopCooldownSwipe(frame.texture);
						end
						if (pallyBuffs[2]) then
							updateCooldownSwipe(frame.texture2, pallyBuffs[2].endTime, pallyBuffs[2].duration);
						else
							stopCooldownSwipe(frame.texture2);
						end
						if (pallyBuffs[3]) then
							updateCooldownSwipe(frame.texture3, pallyBuffs[3].endTime, pallyBuffs[3].duration);
						else
							stopCooldownSwipe(frame.texture3);
						end
					else
						stopCooldownSwipe(frame.texture);
						stopCooldownSwipe(frame.texture2);
						stopCooldownSwipe(frame.texture3);
					end
					--Never add duration to 4th texture, they're too small to see properly if showing 4.
				end
				if (next(wBuffs)) then
					local frame = raidStatusFrame.subFrames[rowName .. worldBuffsSlot];
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					NRC:raidStatusSortWorldBuffIcons(frame, wBuffs, #wBuffs, true, true, v.guid);
					if (worldBuffDurations and not hasChronoboon) then
						for i = 1, #wBuffs do
							if (i == 1) then
								if (wBuffs[i]) then
									updateCooldownSwipe(frame.texture, wBuffs[i].endTime, wBuffs[i].duration);
								else
									stopCooldownSwipe(frame.texture);
								end
							else
								if (wBuffs[i]) then
									updateCooldownSwipe(frame["texture" .. i], wBuffs[i].endTime, wBuffs[i].duration);
								else
									stopCooldownSwipe(frame["texture" .. i]);
								end
							end
						end
					else
						for i = 1, numWorldBuffs do
							if (i == 1) then
								stopCooldownSwipe(frame.texture);
							else
								if (frame["texture" .. i]) then
									stopCooldownSwipe(frame["texture" .. i]);
								end
							end
						end
					end
				end
				if (next(enchantBuffs)) then
					local frame = raidStatusFrame.subFrames[rowName .. weaponEnchantsSlot];
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					NRC:raidStatusSortMultipleIcons(frame, enchantBuffs, 2, true, true);
					if (enchantBuffs[1] and enchantBuffs[1].endTime and enchantBuffs[1].duration) then
						updateCooldownSwipe(frame.texture, enchantBuffs[1].endTime, enchantBuffs[1].duration);
					else
						stopCooldownSwipe(frame.texture);
					end
					if (enchantBuffs[2] and enchantBuffs[2].endTime and enchantBuffs[2].duration) then
						updateCooldownSwipe(frame.texture, enchantBuffs[2].endTime, enchantBuffs[2].duration);
					else
						stopCooldownSwipe(frame.texture2);
					end
				end
				if (flaskSlot and not hasFlask) then
					local frame = raidStatusFrame.subFrames[rowName .. flaskSlot];
					frame.texture:SetTexture();
					frame.texture2:SetTexture();
					frame.texture3:SetTexture();
					frame.texture4:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.fs:SetPoint("CENTER", 0, 0);
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
					stopCooldownSwipe(frame.texture2);
					stopCooldownSwipe(frame.texture3);
					stopCooldownSwipe(frame.texture4);
				end
				if (foodSlot and eating and (not hasFood or hasFood < 120)) then
					local frame = raidStatusFrame.subFrames[rowName .. foodSlot];
					frame.texture:SetTexture();
					frame.texture2:SetTexture();
					frame.texture3:SetTexture();
					frame.updateTooltip();
					local eatingString = L["Eating"];
					if (eating > 0 and not LOCALE_koKR and not LOCALE_zhCN and not LOCALE_zhTW) then
						if (not NRC.raidStatusCache) then
							eatingString = eatingString .. " " .. math.floor(eating - GetServerTime()) .. "s";
						end
					end
					frame.fs:SetText(eatingString);
				elseif (foodSlot and not hasFood) then
					local frame = raidStatusFrame.subFrames[rowName .. foodSlot];
					frame.texture:SetTexture();
					frame.texture2:SetTexture();
					frame.texture3:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
					stopCooldownSwipe(frame.texture2);
					stopCooldownSwipe(frame.texture3);
					--[[local frame = raidStatusFrame.subFrames[rowName .. foodSlot];
					frame.texture:SetTexture();
					--frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					if (foodSlot and eating) then
						local eatingString = L["Eating"];
						if (eating > 0 and not LOCALE_koKR and not LOCALE_zhCN and not LOCALE_zhTW) then
							if (not NRC.raidStatusCache) then
								eatingString = eatingString .. " " .. math.floor(eating - GetServerTime()) .. "s";
							end
						end
						frame.fs:SetText(eatingString);
					else
						frame.fs:SetText("|cFFFF0000X|r");
					end
					frame:SetBackdropColor(0, 0, 0, 0);
					frame:SetBackdropBorderColor(1, 1, 1, 0);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);]]
				end
				if (scrollSlot and not hasScroll) then
					local frame = raidStatusFrame.subFrames[rowName .. scrollSlot];
					frame.texture:SetTexture();
					frame.texture2:SetTexture();
					frame.texture3:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
					stopCooldownSwipe(frame.texture2);
					stopCooldownSwipe(frame.texture3);
				end
				if (intSlot and not hasInt) then
					local frame = raidStatusFrame.subFrames[rowName .. intSlot];
					frame.texture:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
				end
				if (fortSlot and not hasFort) then
					local frame = raidStatusFrame.subFrames[rowName .. fortSlot];
					frame.texture:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
				end
				if (spiritSlot and not hasSpirit) then
					local frame = raidStatusFrame.subFrames[rowName .. spiritSlot];
					frame.texture:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
				end
				if (shadowSlot and not hasShadow) then
					local frame = raidStatusFrame.subFrames[rowName .. shadowSlot];
					frame.texture:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
				end
				if (motwSlot and not hasMotw) then
					local frame = raidStatusFrame.subFrames[rowName .. motwSlot];
					frame.texture:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
				end
				if (expansionNum > 4) then
					if (extraDataTable.extraSlot1 and not hasExtraSlot1) then
						local frame = raidStatusFrame.subFrames[rowName .. extraDataTable.extraSlot1];
						frame.texture:SetTexture();
						frame.fs:SetText("|cFFFF0000X|r");
						frame.updateTooltip();
						updateBackgroundColor(frame);
						if (not InCombatLockdown()) then
							frame:SetAttribute("macrotext", "/target " .. name);
						end
						stopCooldownSwipe(frame.texture);
					end
					if (extraDataTable.extraSlot2 and not hasExtraSlot2) then
						local frame = raidStatusFrame.subFrames[rowName .. extraDataTable.extraSlot2];
						frame.texture:SetTexture();
						frame.fs:SetText("|cFFFF0000X|r");
						frame.updateTooltip();
						updateBackgroundColor(frame);
						if (not InCombatLockdown()) then
							frame:SetAttribute("macrotext", "/target " .. name);
						end
						stopCooldownSwipe(frame.texture);
					end
					if (extraDataTable.extraSlot3 and not hasExtraSlot3) then
						local frame = raidStatusFrame.subFrames[rowName .. extraDataTable.extraSlot3];
						frame.texture:SetTexture();
						frame.fs:SetText("|cFFFF0000X|r");
						frame.updateTooltip();
						updateBackgroundColor(frame);
						if (not InCombatLockdown()) then
							frame:SetAttribute("macrotext", "/target " .. name);
						end
						stopCooldownSwipe(frame.texture);
					end
				end
				if (palSlot and not hasPal) then
					local frame = raidStatusFrame.subFrames[rowName .. palSlot];
					frame.texture:SetTexture();
					frame.texture2:SetTexture();
					frame.texture3:SetTexture();
					frame.texture4:SetTexture();
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
					stopCooldownSwipe(frame.texture);
					stopCooldownSwipe(frame.texture2);
					stopCooldownSwipe(frame.texture3);
				end
				if (weaponEnchantsSlot and not hasWeaponEnchant) then
					local frame = raidStatusFrame.subFrames[rowName .. weaponEnchantsSlot];
					--There's a reported lua error here with this frame not existing but I can't reproduce it.
					--Add a check for now, it just happens when the frame is open and someone joins or is moved apparently.
					--I've also added some layout updates with roster_update and an extra one a couple secs later on player join.
					if (frame) then
						frame.texture:SetTexture();
						frame.texture2:SetTexture();
						frame.texture3:SetTexture();
						frame.texture4:SetTexture();
						if (v.hasDataShare) then
							frame.fs:SetText("|cFFFF0000X|r");
						else
							frame.fs:SetText("--");
						end
						frame.updateTooltip();
						updateBackgroundColor(frame);
						stopCooldownSwipe(frame.texture);
						stopCooldownSwipe(frame.texture2);
					end
				end
				if (talentsSlot and not hasTalents) then
					local frame = raidStatusFrame.subFrames[rowName .. talentsSlot];
					if (frame) then
						frame.texture:SetTexture();
						frame.texture2:SetTexture();
						frame.texture3:SetTexture();
						frame.texture4:SetTexture();
						if (v.hasDataShare) then
							frame.fs:SetText("|cFFFF0000X|r");
						else
							frame.fs:SetText("--");
						end
						frame.updateTooltip();
						updateBackgroundColor(frame);
						frame:SetScript("OnClick", function(self)
							
						end)
					end
				end
				--[[if (subGroups) then
					local frame = raidStatusFrame.groupFrames[v.subGroup];
					frame:ClearAllPoints();
					if (not usedGroupframes[v.subGroup]) then
						frame:SetPoint("TOPRIGHT", raidStatusFrame.subFrames[rowName .. columCount], "TOPRIGHT", 0, 0.6);
						frame:SetPoint("TOPLEFT", raidStatusFrame.subFrames[rowName .. "1"], "TOPLEFT", -20, 0.6);
						frame:SetPoint("BOTTOMRIGHT", raidStatusFrame.subFrames[rowName .. columCount], "BOTTOMRIGHT", 0, -0.6);
						frame:SetPoint("BOTTOMLEFT", raidStatusFrame.subFrames[rowName .. "1"], "BOTTOMLEFT", -20, -0.6);
						frame.bg.fs:SetText("G" .. v.subGroup);
						frame:Show();
						usedGroupframes[v.subGroup] = true;
					else
						frame:SetPoint("BOTTOMRIGHT", raidStatusFrame.subFrames[rowName .. columCount], "BOTTOMRIGHT", 0, -0.6);
						frame:SetPoint("BOTTOMLEFT", raidStatusFrame.subFrames[rowName .. "1"], "BOTTOMLEFT", -20, -0.6);
					end
				end]]
				if (worldBuffsSlot and not hasWorldBuffs) then
					local frame = raidStatusFrame.subFrames[rowName .. worldBuffsSlot];
					frame.texture:SetTexture();
					stopCooldownSwipe(frame.texture);
					for i = 2, numWorldBuffs do
						if (frame["texture" .. i]) then
							frame["texture" .. i]:SetTexture();
							stopCooldownSwipe(frame["texture" .. i]);
						end
					end
					frame.fs:SetText("|cFFFF0000X|r");
					frame.updateTooltip();
					updateBackgroundColor(frame);
					if (not InCombatLockdown()) then
						frame:SetAttribute("macrotext", "/target " .. name);
					end
				end
				NRC:updateCharacterTooltip(raidStatusFrame.subFrames[rowName .. "1"], name, v, auras, hasAlpha, hasGamma);
			end
			if (subGroups) then
				for i = 1, 8 do
					if (not usedGroupframes[i]) then
						raidStatusFrame.groupFrames[i]:Hide();
					end
				end
			end
		end
	end
	if (NRC.raidStatusCache) then
		local found;
		if (data) then
			local instance = NRC.db.global.instances[data.logID];
			if (instance) then
				local encounterName = NRC.getEncounterNameFromID(data.encounterID, data.logID);
				if (encounterName) then
					local success = "|cFFFF3333Wipe|r";
					if (data.success == 1) then
						success = "|cFF00C800Kill|r";
					end
					raidStatusFrame.descFrame:Show();
					if (NRC.raidStatusCache.startTime) then
						raidStatusFrame.descFrame.fs:SetText("|cFF9CD6DE(Snapshot at Boss Pull)|r  |cFFFFFF00" ..encounterName .. "|r - " .. success .. "  |cFF9CD6DE[" .. NRC:getTimeFormat(NRC.raidStatusCache.startTime, true) .. "]");
					else
						raidStatusFrame.descFrame.fs:SetText("|cFF9CD6DE(Snapshot at Boss Pull)|r  |cFFFFFF00" ..encounterName .. "|r - " .. success);
					end
					if (raidStatusFrame.descFrame.fs:GetStringWidth() > raidStatusFrame.descFrame.defaultWidth) then
						raidStatusFrame.descFrame:SetWidth(raidStatusFrame.descFrame.fs:GetStringWidth() + 50);
					else
						raidStatusFrame.descFrame:SetWidth(raidStatusFrame.descFrame.defaultWidth);
					end
					found = true;
				end
			end
		end
		if (not found) then
			raidStatusFrame.descFrame.fs:SetText("Error displaying boss name.");
		end
	else
		raidStatusFrame.descFrame:Hide();
	end
	--print("Elapsed:", pTime - debugprofilestop());
end

function NRC:raidStatusSortMultipleIcons(frame, spellData, maxPossible, checkMaxRank, checkDuration, isPallyBuffs, customLowDuration)
	--Sort spells by order.
	local order = true;
	for k, v in pairs(spellData) do
		if (not v.order) then
			order = nil;
		end
	end
	if (order) then
		table.sort(spellData, function(a, b) return a.order < b.order end);
	end
	local tooltipText = "";
	local buffCount = 0;
	local missingMaxRank, lowDurationFound;
	local lastTexture;
	local textures = {};
	frame.fs:SetText("");
	for k, v in ipairs(spellData) do
		buffCount = buffCount + 1;
		local texture;
		if (k == 1) then
			texture = frame.texture;
		else
			if (not frame["texture" .. k]) then
				--Semi rare bug the texture is missing not sure why yet, this should fix it for now.
				frame.createBuffTexture(k);
				NRC:debug("Created missing raid status texture:", k, frame:GetName())
			end
			texture = frame["texture" .. k];
		end
		if (texture) then
			if (tooltipText == "") then
				tooltipText = tooltipText .. getMultipleIconsTooltip(v);
			else
				tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(v);
			end
			if (not v.maxRank) then
				missingMaxRank = true;
			end
			if (v.endTime and v.endTime - GetServerTime() < (customLowDuration or lowDurationTime) and v.duration ~= 0) then
				if (not v.duration or v.duration and v.duration > 630) then
					lowDurationFound = true;
				end
			end
			texture:ClearAllPoints();
			texture:SetTexture(v.icon);
			texture:Show();
			tinsert(textures, texture);
		else
			NRC:debug("Error: missing raid status texture", k, maxPossible);
		end
		if (k == maxPossible) then
			break;
		end
	end
	for k, v in pairs(frame.textures) do
		if (k > buffCount and v:IsShown()) then
			v:Hide();
		end
	end
	local texturesize = 16;
	local overlap = 0;
	if (buffCount < 7) then
		for k, v in ipairs(textures) do
			v:SetSize(16, 16);
			if (k > 1) then
				v:SetPoint("LEFT", lastTexture, "RIGHT", 0, 0);
			end
			lastTexture = v;
		end
	elseif (buffCount < 8) then
		texturesize = 14;
		for k, v in ipairs(textures) do
			v:SetSize(14, 14);
			if (k > 1) then
				v:SetPoint("LEFT", lastTexture, "RIGHT", 0, 0);
			end
			lastTexture = v;
		end
	else
		texturesize = 12;
		overlap = 1; --Overlap needs to be the difference between actual texture size and what we set on the line above here, so icons can overlap slightly.
		for k, v in ipairs(textures) do
			v:SetSize(13, 13);
			if (k > 1) then
				v:SetPoint("LEFT", lastTexture, "RIGHT", 0 - overlap, 0);
			end
			lastTexture = v;
		end
	end
	--Half of combined textures width minus half of icon size to get middle position.
	frame.texture:SetPoint("CENTER", -(((buffCount * texturesize) / 2) - (texturesize / 2)), 0);
	frame.updateTooltip(tooltipText);
	updateBackgroundColor(frame, checkMaxRank and missingMaxRank, checkDuration and lowDurationFound and not NRC.raidStatusCache);
end

--Old function, leaving it here just for paladin buffs so they can be sorted differently in 2 rows of 2 instead of 4 in a line to fit the smaller box.
function NRC:raidStatusSortMultipleIconsPally(frame, spellData, maxPossible, checkMaxRank, checkDuration, isPallyBuffs, customLowDuration)
	--Sort spells by order.
	local order = true;
	for k, v in pairs(spellData) do
		if (not v.order) then
			order = nil;
		end
	end
	if (order) then
		table.sort(spellData, function(a, b) return a.order < b.order end);
	end
	local tooltipText = "";
	--local buffCount = #spellData;
	local missingMaxRank, lowDurationFound;
	local textures = {};
	frame.fs:SetText("");
	if (spellData[1]) then
		frame.texture.icon = spellData[1].icon;
		tinsert(textures, frame.texture);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[1]);
		end
		if (not spellData[1].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[1].endTime and spellData[1].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[1].duration ~= 0) then
			if (not spellData[1].duration or spellData[1].duration and spellData[1].duration > 630) then
				lowDurationFound = true;
			end
		end
	end
	if (spellData[2]) then
		frame.texture2.icon = spellData[2].icon;
		tinsert(textures, frame.texture2);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[2]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[2]);
		end
		if (not spellData[2].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[2].endTime and spellData[2].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[2].duration ~= 0) then
			if (not spellData[2].duration or spellData[2].duration and spellData[2].duration > 630) then
				lowDurationFound = true;
			end
		end
	end
	if (spellData[3]) then
		frame.texture3.icon = spellData[3].icon;
		tinsert(textures, frame.texture3);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[3]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[3]);
		end
		if (not spellData[3].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[3].endTime and spellData[3].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[3].duration ~= 0) then
			if (not spellData[3].duration or spellData[3].duration and spellData[3].duration > 630) then
				lowDurationFound = true;
			end
		end
	end
	if (spellData[4]) then
		frame.texture4.icon = spellData[4].icon;
		tinsert(textures, frame.texture4);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[4]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[4]);
		end
		if (not spellData[4].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[4].endTime and spellData[4].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[4].duration ~= 0) then
			if (not spellData[4].duration or spellData[4].duration and spellData[4].duration > 630) then
				lowDurationFound = true;
			end
		end
	end
	updateBackgroundColor(frame, checkMaxRank and missingMaxRank, checkDuration and lowDurationFound and not NRC.raidStatusCache);
	frame.texture:ClearAllPoints();
	frame.texture2:ClearAllPoints();
	frame.texture3:ClearAllPoints();
	frame.texture4:ClearAllPoints();
	frame.texture:SetTexture();
	frame.texture2:SetTexture();
	frame.texture3:SetTexture();
	frame.texture4:SetTexture();
	if (#textures == 1) then
		textures[1]:SetPoint("CENTER", 0, 0);
		textures[1]:SetTexture(textures[1].icon);
		textures[1]:SetSize(16, 16);
	elseif (#textures == 2) then
		textures[1]:SetPoint("CENTER", -8.5, 0);
		textures[1]:SetTexture(textures[1].icon);
		textures[1]:SetSize(16, 16);
		textures[2]:SetPoint("CENTER", 8.5, 0);
		textures[2]:SetTexture(textures[2].icon);
		textures[2]:SetSize(16, 16);
	elseif (#textures == 3) then
		textures[1]:SetPoint("RIGHT", frame, "CENTER", -8, 0);
		textures[1]:SetTexture(textures[1].icon);
		textures[1]:SetSize(16, 16);
		textures[2]:SetPoint("CENTER", 0, 0);
		textures[2]:SetTexture(textures[2].icon);
		textures[2]:SetSize(16, 16);
		textures[3]:SetPoint("LEFT", frame, "CENTER", 8, 0);
		textures[3]:SetTexture(textures[3].icon);
		textures[3]:SetSize(16, 16);
	elseif (#textures == 4) then
		if (isPallyBuffs) then
			--Leave pally display the old style, easy to see if 4 buffs aree out.
			textures[1]:SetPoint("BOTTOMRIGHT", frame, "CENTER", 0, 0);
			textures[1]:SetTexture(textures[1].icon);
			textures[1]:SetSize(8, 8);
			textures[2]:SetPoint("BOTTOMLEFT", frame, "CENTER", 0, 0);
			textures[2]:SetTexture(textures[3].icon);
			textures[2]:SetSize(8, 8);
			textures[3]:SetPoint("TOPRIGHT", frame, "CENTER", 0, 0);
			textures[3]:SetTexture(textures[3].icon);
			textures[3]:SetSize(8, 8);
			textures[4]:SetPoint("TOPLEFT", frame, "CENTER", 0, 0);
			textures[4]:SetTexture(textures[4].icon);
			textures[4]:SetSize(8, 8);
		else
			textures[1]:SetPoint("CENTER", -18, 0);
			textures[1]:SetTexture(textures[1].icon);
			textures[1]:SetSize(13, 13);
			textures[2]:SetPoint("CENTER", -6.5, 0);
			textures[2]:SetTexture(textures[2].icon);
			textures[2]:SetSize(13, 13);
			textures[3]:SetPoint("CENTER", 6.5, 0);
			textures[3]:SetTexture(textures[3].icon);
			textures[3]:SetSize(13, 13);
			textures[4]:SetPoint("CENTER", 18, 0);
			textures[4]:SetTexture(textures[4].icon);
			textures[4]:SetSize(13, 13);
		end
	end
	frame.updateTooltip(tooltipText);
	
	--if (maxPossible == 2 and count == 1) then
		--If this is a 2 icon slot but only 1 buff then show red X in missing 2nd slot;
	--end
end

--[[function NRC:raidStatusSortMultipleIcons(frame, spellData, maxPossible, checkMaxRank, checkDuration, isPallyBuffs, customLowDuration)
	--Sort spells by order.
	local order = true;
	for k, v in pairs(spellData) do
		if (not v.order) then
			order = nil;
		end
	end
	if (order) then
		table.sort(spellData, function(a, b) return a.order < b.order end);
	end
	local tooltipText = "";
	--local buffCount = #spellData;
	local missingMaxRank, lowDurationFound;
	local textures = {};
	frame.fs:SetText("");
	if (spellData[1]) then
		frame.texture.icon = spellData[1].icon;
		tinsert(textures, frame.texture);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[1]);
		end
		if (not spellData[1].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[1].endTime and spellData[1].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[1].duration ~= 0) then
			lowDurationFound = true;
		end
	end
	if (spellData[2]) then
		frame.texture2.icon = spellData[2].icon;
		tinsert(textures, frame.texture2);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[2]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[2]);
		end
		if (not spellData[2].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[2].endTime and spellData[2].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[2].duration ~= 0) then
			lowDurationFound = true;
		end
	end
	if (spellData[3]) then
		frame.texture3.icon = spellData[3].icon;
		tinsert(textures, frame.texture3);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[3]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[3]);
		end
		if (not spellData[3].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[3].endTime and spellData[3].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[3].duration ~= 0) then
			lowDurationFound = true;
		end
	end
	if (spellData[4]) then
		frame.texture4.icon = spellData[4].icon;
		tinsert(textures, frame.texture4);
		if (tooltipText == "") then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[4]);
		else
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[4]);
		end
		if (not spellData[4].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[4].endTime and spellData[4].endTime - GetServerTime() < (customLowDuration or lowDurationTime) and spellData[4].duration ~= 0) then
			lowDurationFound = true;
		end
	end
	updateBackgroundColor(frame, checkMaxRank and missingMaxRank, checkDuration and lowDurationFound and not NRC.raidStatusCache);
	frame.texture:ClearAllPoints();
	frame.texture2:ClearAllPoints();
	frame.texture3:ClearAllPoints();
	frame.texture4:ClearAllPoints();
	frame.texture:SetTexture();
	frame.texture2:SetTexture();
	frame.texture3:SetTexture();
	frame.texture4:SetTexture();
	if (#textures == 1) then
		textures[1]:SetPoint("CENTER", 0, 0);
		textures[1]:SetTexture(textures[1].icon);
		textures[1]:SetSize(16, 16);
	elseif (#textures == 2) then
		textures[1]:SetPoint("CENTER", -8.5, 0);
		textures[1]:SetTexture(textures[1].icon);
		textures[1]:SetSize(16, 16);
		textures[2]:SetPoint("CENTER", 8.5, 0);
		textures[2]:SetTexture(textures[2].icon);
		textures[2]:SetSize(16, 16);
	elseif (#textures == 3) then
		textures[1]:SetPoint("RIGHT", frame, "CENTER", -8, 0);
		textures[1]:SetTexture(textures[1].icon);
		textures[1]:SetSize(16, 16);
		textures[2]:SetPoint("CENTER", 0, 0);
		textures[2]:SetTexture(textures[2].icon);
		textures[2]:SetSize(16, 16);
		textures[3]:SetPoint("LEFT", frame, "CENTER", 8, 0);
		textures[3]:SetTexture(textures[3].icon);
		textures[3]:SetSize(16, 16);
	elseif (#textures == 4) then
		if (isPallyBuffs) then
			--Leave pally display the old style, easy to see if 4 buffs aree out.
			textures[1]:SetPoint("BOTTOMRIGHT", frame, "CENTER", 0, 0);
			textures[1]:SetTexture(textures[1].icon);
			textures[1]:SetSize(8, 8);
			textures[2]:SetPoint("BOTTOMLEFT", frame, "CENTER", 0, 0);
			textures[2]:SetTexture(textures[3].icon);
			textures[2]:SetSize(8, 8);
			textures[3]:SetPoint("TOPRIGHT", frame, "CENTER", 0, 0);
			textures[3]:SetTexture(textures[3].icon);
			textures[3]:SetSize(8, 8);
			textures[4]:SetPoint("TOPLEFT", frame, "CENTER", 0, 0);
			textures[4]:SetTexture(textures[4].icon);
			textures[4]:SetSize(8, 8);
		else
			textures[1]:SetPoint("CENTER", -18, 0);
			textures[1]:SetTexture(textures[1].icon);
			textures[1]:SetSize(13, 13);
			textures[2]:SetPoint("CENTER", -6.5, 0);
			textures[2]:SetTexture(textures[2].icon);
			textures[2]:SetSize(13, 13);
			textures[3]:SetPoint("CENTER", 6.5, 0);
			textures[3]:SetTexture(textures[3].icon);
			textures[3]:SetSize(13, 13);
			textures[4]:SetPoint("CENTER", 18, 0);
			textures[4]:SetTexture(textures[4].icon);
			textures[4]:SetSize(13, 13);
		end
	end
	frame.updateTooltip(tooltipText);
	
	--if (maxPossible == 2 and count == 1) then
		--If this is a 2 icon slot but only 1 buff then show red X in missing 2nd slot;
	--end
end]]

--[[function NRC:raidStatusSortMultipleIcons(frame, spellData, maxPossible, checkMaxRank, checkDuration)
	--Sort spells by order.
	local order = true;
	for k, v in pairs(spellData) do
		if (not v.order) then
			order = nil;
		end
	end
	if (order) then
		table.sort(spellData, function(a, b) return a.order < b.order end);
	end
	local tooltipText = "";
	local buffCount = #spellData;
	local missingMaxRank, lowDurationFound;
	if (buffCount == 1) then
		frame.fs:SetText("");
		frame.texture:ClearAllPoints();
		frame.texture2:ClearAllPoints();
		frame.texture3:ClearAllPoints();
		frame.texture4:ClearAllPoints();
		frame.texture:SetPoint("CENTER", 0, 0);
		frame.texture:SetTexture(spellData[1].icon);
		frame.texture2:SetTexture();
		frame.texture3:SetTexture();
		frame.texture4:SetTexture();
		frame.texture:SetSize(16, 16);
		tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1]);
		if (not spellData[1].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[1].endTime and spellData[1].endTime - GetServerTime() < lowDurationTime and spellData[1].duration ~= 0) then
			lowDurationFound = true;
		end
	elseif (buffCount == 2) then
		frame.fs:SetText("");
		frame.texture:ClearAllPoints();
		frame.texture2:ClearAllPoints();
		frame.texture3:ClearAllPoints();
		frame.texture4:ClearAllPoints();
		frame.texture:SetPoint("CENTER", -8.5, 0);
		frame.texture2:SetPoint("CENTER", 8.5, 0);
		frame.texture:SetTexture(spellData[1].icon);
		frame.texture2:SetTexture(spellData[2].icon);
		frame.texture3:SetTexture();
		frame.texture4:SetTexture();
		frame.texture:SetSize(16, 16);
		frame.texture2:SetSize(16, 16);
		tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1]);
		tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[2]);
		if (not spellData[1].maxRank or not spellData[2].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[2].endTime and spellData[2].endTime - GetServerTime() < lowDurationTime and spellData[2].duration ~= 0) then
			lowDurationFound = true;
		end
	elseif (buffCount == 3) then
		frame.fs:SetText("");
		frame.texture:ClearAllPoints();
		frame.texture2:ClearAllPoints();
		frame.texture3:ClearAllPoints();
		frame.texture4:ClearAllPoints();
		frame.texture:SetPoint("RIGHT", frame, "CENTER", -8, 0);
		frame.texture2:SetPoint("CENTER", 0, 0);
		frame.texture3:SetPoint("LEFT", frame, "CENTER", 8, 0);
		frame.texture:SetTexture(spellData[1].icon);
		frame.texture2:SetTexture(spellData[2].icon);
		frame.texture3:SetTexture(spellData[3].icon);
		frame.texture4:SetTexture();
		frame.texture:SetSize(16, 16);
		frame.texture2:SetSize(16, 16);
		frame.texture3:SetSize(16, 16);
		tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1]);
		tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[2]);
		tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[3]);
		if (not spellData[1].maxRank or not spellData[2].maxRank or not spellData[3].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[3].endTime and spellData[3].endTime - GetServerTime() < lowDurationTime and spellData[3].duration ~= 0) then
			lowDurationFound = true;
		end
	elseif (buffCount == 4) then
		frame.fs:SetText("");
		frame.texture:ClearAllPoints();
		frame.texture2:ClearAllPoints();
		frame.texture3:ClearAllPoints();
		frame.texture4:ClearAllPoints();
		frame.texture:SetPoint("BOTTOMRIGHT", frame, "CENTER", 0, 0);
		frame.texture2:SetPoint("BOTTOMLEFT", frame, "CENTER", 0, 0);
		frame.texture3:SetPoint("TOPRIGHT", frame, "CENTER", 0, 0);
		frame.texture4:SetPoint("TOPLEFT", frame, "CENTER", 0, 0);
		frame.texture:SetTexture(spellData[1].icon);
		frame.texture2:SetTexture(spellData[2].icon);
		frame.texture3:SetTexture(spellData[3].icon);
		frame.texture4:SetTexture(spellData[4].icon);
		frame.texture:SetSize(8, 8);
		frame.texture2:SetSize(8, 8);
		frame.texture3:SetSize(8, 8);
		frame.texture4:SetSize(8, 8);
		tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1]);
		tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[2]);
		tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[3]);
		tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[4]);
		if (not spellData[1].maxRank or not spellData[2].maxRank or not spellData[3].maxRank or not spellData[4].maxRank) then
			missingMaxRank = true;
		end
		if (spellData[4].endTime and spellData[4].endTime - GetServerTime() < lowDurationTime and spellData[4].duration ~= 0) then
			lowDurationFound = true;
		end
	end
	if (checkMaxRank and missingMaxRank) then
		frame:SetBackdropColor(1, 0, 0, 0.25);
		frame:SetBackdropBorderColor(1, 0, 0, 0.7);
		frame.red = true;
	elseif (checkDuration and lowDurationFound and not NRC.raidStatusCache) then
		frame:SetBackdropColor(1, 1, 0, 0.25);
		frame:SetBackdropBorderColor(1, 1, 0, 0.7);
		frame.red = true;
	else
		frame.red = nil;
		frame:SetBackdropColor(0, 0, 0, 0);
		frame:SetBackdropBorderColor(1, 1, 1, 0);
	end
	frame.updateTooltip(tooltipText);
	--if (maxPossible == 2 and count == 1) then
		--If this is a 2 icon slot but only 1 buff then show red X in missing 2nd slot;
	--end
end]]

function NRC:raidStatusSortWorldBuffIcons(frame, spellData, maxPossible, checkMaxRank, checkDuration, guid)
	--Sort spells by order.
	local order = true;
	for k, v in pairs(spellData) do
		if (not v.order) then
			order = nil;
		end
	end
	if (order) then
		table.sort(spellData, function(a, b) return a.order < b.order end);
	end
	local tooltipText = "";
	local buffCount = #spellData;
	frame.fs:SetText("");
	--NRC:debug(spellData)
	local lastTexture;
	frame.texture:ClearAllPoints();
	for i = 1, NRC.numWorldBuffs do
		if (frame["texture" .. i]) then
			frame["texture" .. i]:ClearAllPoints();
			frame["texture" .. i]:SetTexture();
		end
	end
	if (buffCount == 1) then
		frame.fs:SetText("");
		frame.texture:SetPoint("CENTER", 0, 0);
		frame.texture:SetTexture(spellData[1].icon);
		frame.texture:SetSize(16, 16);
		frame.texture:Show();
		if (spellData[1].buffID ~= 349981) then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1], true);
		end
	elseif (buffCount == 2) then
		frame.fs:SetText("");
		frame.texture:SetPoint("CENTER", -8.5, 0);
		frame.texture2:SetPoint("CENTER", 8.5, 0);
		frame.texture:SetTexture(spellData[1].icon);
		frame.texture2:SetTexture(spellData[2].icon);
		frame.texture:SetSize(16, 16);
		frame.texture2:SetSize(16, 16);
		frame.texture:Show();
		frame.texture2:Show();
		if (spellData[1].buffID ~= 349981) then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1], true);
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[2], true);
		else
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[2], true);
		end
	elseif (buffCount == 3) then
		frame.fs:SetText("");
		frame.texture:SetPoint("RIGHT", frame, "CENTER", -8, 0);
		frame.texture2:SetPoint("CENTER", 0, 0);
		frame.texture3:SetPoint("LEFT", frame, "CENTER", 8, 0);
		frame.texture:SetTexture(spellData[1].icon);
		frame.texture2:SetTexture(spellData[2].icon);
		frame.texture3:SetTexture(spellData[3].icon);
		frame.texture:SetSize(16, 16);
		frame.texture2:SetSize(16, 16);
		frame.texture3:SetSize(16, 16);
		frame.texture:Show();
		frame.texture2:Show();
		frame.texture3:Show();
		--Chronoboon is always first slot so we can jut ignore the first slot tooltip if it is, chrono data is shown at the bottom of the tooltip instead.
		if (spellData[1].buffID ~= 349981) then
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1], true);
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[2], true);
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[3], true);
		else
			tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[2], true);
			tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[3], true);
		end
	else
		for i = 1, #spellData do
			if (i == 1) then
				frame.texture:SetPoint("LEFT", frame, "LEFT", 1, 0);
				--frame.texture:SetPoint("CENTER", 0, 0);
				frame.texture:SetTexture(spellData[1].icon);
				frame.texture:SetSize(16, 16);
				frame.texture:Show();
				tooltipText = tooltipText .. getMultipleIconsTooltip(spellData[1], true);
				lastTexture = frame.texture;
			else
				if (not frame["texture" .. i]) then
					--Semi rare bug the texture is missing not sure why yet, this should fix it for now.
					frame.createBuffTexture(i);
					NRC:debug("Created missing raid status texture2:", i, frame:GetName())
				end
				frame["texture" .. i]:SetPoint("LEFT", lastTexture, "RIGHT", 1, 0);
				--frame["texture" .. i]:SetPoint("CENTER", 0, 0);
				frame["texture" .. i]:SetTexture(spellData[i].icon);
				frame["texture" .. i]:SetSize(16, 16);
				frame["texture" .. i]:Show();
				tooltipText = tooltipText .. "\n" .. getMultipleIconsTooltip(spellData[i], true);
				lastTexture = frame["texture" .. i];
			end
		end
	end
	if (tooltipText == "") then
		tooltipText = tooltipText .. getChronoboonTooltip(guid);
	else
		tooltipText = tooltipText .. "\n\n" .. getChronoboonTooltip(guid);
	end
	tooltipText = gsub(tooltipText, "\n$", "");
	frame.updateTooltip(tooltipText);
end

local raidStatusShadowRes, raidStatusFireRes, raidStatusNatureRes, raidStatusFrostRes, raidStatusArcaneRes, raidStatusHolyRes, raidStatusArmorRes;
local raidStatusWeaponEnchants, raidStatusTalents;
local function setResColumns()
	raidStatusShadowRes, raidStatusFireRes, raidStatusNatureRes, raidStatusFrostRes, raidStatusArcaneRes, raidStatusHolyRes,
			raidStatusArmorRes, raidStatusWeaponEnchants, raidStatusTalents = nil, nil, nil, nil, nil, nil, nil, nil, nil;
	local config = NRC.config;
	if (config.raidStatusShadowRes) then
		raidStatusShadowRes = true;
	end
	if (config.raidStatusFireRes) then
		raidStatusFireRes = true;
	end
	if (config.raidStatusNatureRes) then
		raidStatusNatureRes = true;
	end
	if (config.raidStatusFrostRes) then
		raidStatusFrostRes = true;
	end
	if (config.raidStatusArcaneRes) then
		raidStatusArcaneRes = true;
	end
	--if (config.raidStatusHolyRes) then
	--	raidStatusHolyRes = true;
	--end
	--if (config.raidStatusArmorRes) then
	--	raidStatusArmorRes = true;
	--end
	if (config.raidStatusWeaponEnchants) then
		raidStatusWeaponEnchants = true;
	end
	if (config.raidStatusTalents) then
		raidStatusTalents = true;
	end
end

local function addChar(v, guid, name)
	--This fixes viewing old snapshots before subgroup was added.
	--if (not v.subgroup) then
	--	v.subgroup = 0;
	--end
	if (NRC.raidStatusCache) then
		return {
			name = name,
			class = v.class,
			guid = guid,
			level = v.level,
			realm = v.realm,
			subGroup = v.subGroup,
			auras = {},
		};
	else
		return {
			name = name,
			class = v.class,
			zone = v.zone,
			lastKnownZone = v.lastKnownZone,
			online = v.online,
			guid = guid,
			level = v.level,
			realm = v.realm,
			subGroup = v.subGroup,
			auras = {},
		};
	end
end

local naxxSealLevels = {};
if (NRC.isSOD) then
	naxxSealLevels = {
		--Level 1.
		[1219539] = {
			name = "|cFFFFFFFF[Aspirant's Seal of the Dawn]|r",
			icon = 236690,
			percent = 1.25,
			role = "Damage",
			itemID = 236354,
		},
		[1219548] = {
			name = "|cFFFFFFFF[Aspirant's Seal of the Dawn]|r",
			icon = 134501,
			percent = 1.25,
			role = "Heals",
			itemID = 236385,
		},
		[1220514] = {
			name = "|cFFFFFFFF[Aspirant's Seal of the Dawn]|r",
			icon = 236689,
			percent = 1.25,
			role = "Tank",
			itemID = 236396,
		},
		--Level 2.
		[1223348] = {
			name = "|cFFFFFFFF[Initiate's Seal of the Dawn]|r",
			icon = 236690,
			percent = 4.38,
			role = "Damage",
			itemID = 236355,
		},
		[1223379] = {
			name = "|cFFFFFFFF[Initiate's Seal of the Dawn]|r",
			icon = 134501,
			percent = 4.38,
			role = "Heals",
			itemID = 1223379,
		},
		[1223367] = {
			name = "|cFFFFFFFF[Initiate's Seal of the Dawn]|r",
			icon = 236689,
			percent = 4.38,
			role = "Tank",
			itemID = 236395,
		},
		--Level 3.
		[1223349] = {
			name = "|cFF1eff00[Squire's Seal of the Dawn]|r",
			icon = 236690,
			percent = 6.25,
			role = "Damage",
			itemID = 236356,
		},
		[1223380] = {
			name = "|cFF1eff00[Squire's Seal of the Dawn]|r",
			icon = 134501,
			percent = 6.25,
			role = "Heals",
			itemID = 236383,
		},
		[1223368] = {
			name = "|cFF1eff00[Squire's Seal of the Dawn]|r",
			icon = 236689,
			percent = 6.25,
			role = "Tank",
			itemID = 236394,
		},
		--Level 4.
		[1223350] = {
			name = "|cFF1eff00[Knight's Seal of the Dawn]|r",
			icon = 236690,
			percent = 10,
			role = "Damage",
			itemID = 236357,
		},
		[1223381] = {
			name = "|cFF1eff00[Knight's Seal of the Dawn]|r",
			icon = 134501,
			percent = 10,
			role = "Heals",
			itemID = 236382,
		},
		[1223370] = {
			name = "|cFF1eff00[Knight's Seal of the Dawn]|r",
			icon = 236689,
			percent = 10,
			role = "Tank",
			itemID = 236393,
		},
		--Level 5.
		[1223351] = {
			name = "|cFF0070dd[Templar's Seal of the Dawn]|r",
			icon = 236690,
			percent = 12.50,
			role = "Damage",
			itemID = 236358,
		},
		[1223382] = {
			name = "|cFF0070dd[Templar's Seal of the Dawn]|r",
			icon = 134501,
			percent = 12.50,
			role = "Heals",
			itemID = 236380,
		},
		[1223371] = {
			name = "|cFF0070dd[Templar's Seal of the Dawn]|r",
			icon = 236689,
			percent = 12.50,
			role = "Tank",
			itemID = 236392,
		},
		--Level 6.
		[1223352] = {
			name = "|cFF0070dd[Champion's Seal of the Dawn]|r",
			icon = 236690,
			percent = 18.13,
			role = "Damage",
			itemID = 236360,
		},
		[1223383] = {
			name = "|cFF0070dd[Champion's Seal of the Dawn]|r",
			icon = 134501,
			percent = 18.13,
			role = "Heals",
			itemID = 236379,
		},
		[1223372] = {
			name = "|cFF0070dd[Champion's Seal of the Dawn]|r",
			icon = 236689,
			percent = 18.13,
			role = "Tank",
			itemID = 236391,
		},
		--Level 7.
		[1223353] = {
			name = "|cFFa335ee[Vanguard's Seal of the Dawn]|r",
			icon = 236690,
			percent = 21.25,
			role = "Damage",
			itemID = 236361,
		},
		[1223384] = {
			name = "|cFFa335ee[Vanguard's Seal of the Dawn]|r",
			icon = 134501,
			percent = 21.25,
			role = "Heals",
			itemID = 236378,
		},
		[1223373] = {
			name = "|cFFa335ee[Vanguard's Seal of the Dawn]|r",
			icon = 236689,
			percent = 21.25,
			role = "Tank",
			itemID = 236390,
		},
		--Level 8.
		[1223354] = {
			name = "|cFFa335ee[Crusader's Seal of the Dawn]|r",
			icon = 236690,
			percent = 28.13,
			role = "Damage",
			itemID = 236362,
		},
		[1223385] = {
			name = "|cFFa335ee[Crusader's Seal of the Dawn]|r",
			icon = 134501,
			percent = 28.13,
			role = "Heals",
			itemID = 236376,
		},
		[1223374] = {
			name = "|cFFa335ee[Crusader's Seal of the Dawn]|r",
			icon = 236689,
			percent = 28.13,
			role = "Tank",
			itemID = 236389,
		},
		--Level 9.
		[1223355] = {
			name = "|cFFa335ee[Commander's Seal of the Dawn]|r",
			icon = 236690,
			percent = 32.50,
			role = "Damage",
			itemID = 236363,
		},
		[1223386] = {
			name = "|cFFa335ee[Commander's Seal of the Dawn]|r",
			icon = 134501,
			percent = 32.50,
			role = "Heals",
			itemID = 236374,
		},
		[1223375] = {
			name = "|cFFa335ee[Commander's Seal of the Dawn]|r",
			icon = 236689,
			percent = 32.50,
			role = "Tank",
			itemID = 236388,
		},
		--Level 10.
		[1223357] = {
			name = "|cFFa335ee[Highlord's Seal of the Dawn]|r",
			icon = 236690,
			percent = 37.50,
			role = "Damage",
			itemID = 236364,
		},
		[1223387] = {
			name = "|cFFa335ee[Highlord's Seal of the Dawn]|r",
			icon = 134501,
			percent = 37.50,
			role = "Heals",
			itemID = 236375,
		},
		[1223376] = {
			name = "|cFFa335ee[Highlord's Seal of the Dawn]|r",
			icon = 236689,
			percent = 37.50,
			role = "Tank",
			itemID = 236386,
		},
	};
end

function NRC:createRaidStatusData(updateLayout)
	local data = {};
	data.rows = {};
	data.chars = {};
	local usingSpecialSlot, usingSpecialSlot2, usingSpecialSlot3, usingSpecialSlot4;
	local sanctifiedCache = NRC.sanctifiedCache;
	local gearCache = NRC.gearCache;
	local config = NRC.config;
	local gamma;
	if (not NRC.raidStatusCache) then
		if (isSOD) then
			--For now it's only in classic and going to track seal of dawn mechanic in SoD.
			--Track even while outside the raid for now.
			--if (NRC.currentInstanceID == 533 and not NRC.raidStatusCache) then
				--Set header name.
				if (config.raidStatusNaxx) then
					usingSpecialSlot = "|T236690:12:12:0:-1|t|cFF00FF00Naxx";
				end
				if (config.raidStatusSanc) then
					usingSpecialSlot2 = "|cFF34FDF0Sanc";
				end
				--usingSpecialSlot3 = "|cFF34FDF0Runes";
			--end
		end
		if (config.raidStatusIlvl) then
			usingSpecialSlot3 = "|cFF9CD6DEiLvl";
		end
		if (config.raidStatusEquip) then
			usingSpecialSlot4 = "|cFFFFFF00Equip";
		end
	end
	if (updateLayout) then
		raidStatusFrame.hideAllRows();
		specialSlot, specialSlot2, specialSlot3, specialSlot4, flaskSlot, foodSlot, scrollSlot, intSlot, fortSlot, spiritSlot = nil, nil, nil, nil, nil, nil, nil, nil;
		shadowSlot, motwSlot, palSlot, duraSlot, worldBuffsSlot = nil, nil, nil, nil, nil;
		armorSlot, holyResSlot, fireResSlot, natureResSlot, frostResSlot, shadowResSlot, arcaneResSlot = nil, nil, nil, nil, nil, nil, nil;
		slotCount = 0;
		data.firstH = 25; --Header (first row).
		data.firstV = 100; --Character names (first column).
		data.spacingV = 50;
		data.spacingH = 18;
		data.columns = {
			--Column names, printed in first row (header).
			[1] = {
				name = L["|cFFFF6900NRC Raid Status"],
			},
		};
		slotCount = slotCount + 1;
		
		--Extra column for tracking special per instance stuff.
		if (usingSpecialSlot) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = usingSpecialSlot,
			};
			specialSlot = slot;
			slotCount = slotCount + 1;
		end
		if (usingSpecialSlot2) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = usingSpecialSlot2,
			};
			specialSlot2 = slot;
			slotCount = slotCount + 1;
		end
		if (usingSpecialSlot3) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = usingSpecialSlot3,
			};
			specialSlot3 = slot;
			slotCount = slotCount + 1;
		end
		if (usingSpecialSlot4) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = usingSpecialSlot4,
			};
			specialSlot4 = slot;
			slotCount = slotCount + 1;
		end
		
		if (config.raidStatusFlask) then
			local slot = #data.columns + 1;
			if (isClassic) then
				data.columns[slot] = {
					name = L["Flask / Potions"],
					width = 100,
					textureCount = 8,
				};
			else
				data.columns[slot] = {
					name = L["Flask"],
				};
			end
			flaskSlot = slot;
			slotCount = slotCount + 1;
		end
		if (config.raidStatusFood) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = L["Food"],
			};
			foodSlot = slot;
			slotCount = slotCount + 1;
		end
		if (config.raidStatusScroll) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = L["Scroll"],
				};
			scrollSlot = slot;
			slotCount = slotCount + 1;
		end
		if (expansionNum < 5) then
			if (config.raidStatusInt) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Int"],
				};
				intSlot = slot;
				slotCount = slotCount + 1;
			end
		end
		if (config.raidStatusFort) then
			local slot = #data.columns + 1;
			if (expansionNum > 4) then
				data.columns[slot] = {
					name = L["Stam"],
				};
			else
				data.columns[slot] = {
					name = L["Fort"],
				};
			end
			fortSlot = slot;
			slotCount = slotCount + 1;
		end
		if (config.raidStatusSpirit) then --Removed in cata.
			if (expansionNum > 4) then
				--Repurpose the spirit column in MoP.
				--We'll simply rename the options and enable them by default in MoP.
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Crit"],
				};
				spiritSlot = slot;
				slotCount = slotCount + 1;
			elseif (expansionNum < 4) then	--Removed in cata.
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Spirit"],
				};
				spiritSlot = slot;
				slotCount = slotCount + 1;
			end
		end
		if (config.raidStatusShadow) then
			if (expansionNum > 4) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Mast"],
				};
				shadowSlot = slot;
				slotCount = slotCount + 1;
			elseif (expansionNum < 5) then	--Removed in MoP.
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Shadow"],
				};
				shadowSlot = slot;
				slotCount = slotCount + 1;
			end
		end
		if (config.raidStatusMotw) then
			if (expansionNum > 4) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Stats"],
				};
				motwSlot = slot;
				slotCount = slotCount + 1;
			else
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Motw"],
				};
				motwSlot = slot;
				slotCount = slotCount + 1;
			end
		end
		if (expansionNum > 4) then
			--Move this culn further right on th display for MoP+ so it sits beside attack power.
			if (config.raidStatusInt) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["SP"],
				};
				intSlot = slot;
				slotCount = slotCount + 1;
			end
		end
		if (expansionNum > 4) then
			if (config.raidStatusExtraSlot1) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["AP"],
					};
				extraDataTable.extraSlot1 = slot;
				slotCount = slotCount + 1;
			end
			if (config.raidStatusExtraSlot2) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Haste"],
					};
				extraDataTable.extraSlot2 = slot;
				slotCount = slotCount + 1;
			end
			if (config.raidStatusExtraSlot3) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Speed"],
					};
				extraDataTable.extraSlot3 = slot;
				slotCount = slotCount + 1;
			end
		end
		if (config.raidStatusPal and expansionNum < 5) then
			--[[if (expansionNum > 4) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Auras"],
				};
				palSlot = slot;
				slotCount = slotCount + 1;
			else]]
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Pal"],
				};
				palSlot = slot;
				slotCount = slotCount + 1;
			--end
		end
		if (NRC.raidStatusCache) then
			--Last column is shared between durability and snapshot text.
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = "",
			};
			duraSlot = slot;
			slotCount = slotCount + 1;
		elseif (config.raidStatusDura) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = L["Durability"],
			};
			duraSlot = slot;
			slotCount = slotCount + 1;
		end
		if (config.raidStatusTalents) then
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = L["Talents"],
				tooltip = "|cFFDEDE42Click a players talent icon\nto show full talent tree.",
			};
			talentsSlot = slot;
			slotCount = slotCount + 1;
		end
		if (raidStatusFrame.showRes) then
			setResColumns();
			if (raidStatusShadowRes) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = "Shadow",
					tex = 136568, --Interface\PaperDollInfoFrame\UI-Character-ResistanceIcons.
					texCoords = {0, 1.0, 0.453125, 0.56640625},
					tooltip = "|cFFDEDE42Shadow Resistance",
				};
				shadowResSlot = slot;
				slotCount = slotCount + 1;
			end
			if (raidStatusFireRes) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = "Fire",
					tex = 136568,
					texCoords = {0, 1.0, 0, 0.11328125},
					tooltip = "|cFFDEDE42Fire Resistance",
				};
				fireResSlot = slot;
				slotCount = slotCount + 1;
			end
			if (raidStatusNatureRes) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = "Nature",
					tex = 136568,
					texCoords = {0, 1.0, 0.11328125, 0.2265625},
					tooltip = "|cFFDEDE42Nature Resistance",
				};
				natureResSlot = slot;
				slotCount = slotCount + 1;
			end
			if (raidStatusFrostRes) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = "Frost",
					tex = 136568,
					texCoords = {0, 1.0, 0.33984375, 0.453125},
					tooltip = "|cFFDEDE42Frost Resistance",
				};
				frostResSlot = slot;
				slotCount = slotCount + 1;
			end
			if (raidStatusArcaneRes) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = "Arcane",
					tex = 136568,
					texCoords = {0, 1.0, 0.2265625, 0.33984375},
					tooltip = "|cFFDEDE42Arcane Resistance",
				};
				arcaneResSlot = slot;
				slotCount = slotCount + 1;
			end
			--[[if (raidStatusHolyRes) then --Holy doesn't exist on players? The API exists but there's no gear or textures.
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = "Holy",
					tex = 136568,
					texCoords = {},
					tooltip = "|cFFDEDE42Holy Resistance",
				};
				holyResSlot = slot;
				slotCount = slotCount + 1;
			end]]
			if (raidStatusWeaponEnchants) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Weapon"],
					tooltip = "|cFFDEDE42Temporary Weapon Enchants",
				};
				weaponEnchantsSlot = slot;
				slotCount = slotCount + 1;
			end
			--[[if (raidStatusTalents) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = L["Talents"],
					tooltip = "|cFFDEDE42Click a players talent icon\nto show full talent tree.",
				};
				talentsSlot = slot;
				slotCount = slotCount + 1;
			end]]
			--[[if (raidStatusArmorRes) then
				local slot = #data.columns + 1;
				data.columns[slot] = {
					name = "Armor",
				};
				armorSlot = slot;
				slotCount = slotCount + 1;
			end]]
		end
		if (NRC.isClassic and config.raidStatusWorldBuffs) then
			local buffCount = 4;
			local numBuffs = currentMaxWorldbuffs;
			if (numBuffs > buffCount) then
				buffCount = numBuffs;
			end
			local slot = #data.columns + 1;
			data.columns[slot] = {
				name = "|cFFFFFF00" .. L["World Buffs"],
				--customWidth only works with the last column atm, it needs rewriting in Frames.lua at some point.
				--This is no longer true, any column can now use "width" as an arg, this world buff stuff needs merging into that sometime soon.
				customWidth = buffCount * 16.1 + (numBuffs - 1), -- 4 textures wide by default, grows when more buffs.
				--customWidth = 10 * 16.1 + (numBuffs - 1),
				textureCount = NRC.numWorldBuffs;
			};
			worldBuffsSlot = slot;
			slotCount = slotCount + 1;
		end
		data.adjustHeight = true;
		data.adjustWidth = true;
	end
	--If we open this from the raid log window then load the cached data instead.
	if (NRC.raidStatusCache) then
		local count = 0;
		data.rows[1] = "Header";
		data.logID = NRC.raidStatusCache.logID;
		data.encounterID = NRC.raidStatusCache.encounterID;
		data.success = NRC.raidStatusCache.success;
		if (NRC.raidStatusCache.group and next(NRC.raidStatusCache.group)) then
			for k, v in pairs(NRC.raidStatusCache.group) do
				local auraCache = NRC.raidStatusCache.auraCache[k];
				if (auraCache) then
					count = count + 1;
					if (count > 60) then
						break;
					end
					--The counts here are different becaus the first row is the header, second row is the first char, so chars is 1 row count more.
					data.rows[count + 1] = v.name;
					data.chars[count] = addChar(v, k, v.name);
					for buffID, buffData in NRC:pairsByKeys(auraCache) do
						if (NRC.flasks[buffID]) then
							data.chars[count].flask = buffData;
						end
						if (NRC.foods[buffID]) then
							data.chars[count].food = buffData;
						end
						if (int[buffID]) then
							data.chars[count].int = buffData;
						end
						if (fort[buffID]) then
							data.chars[count].fort = buffData;
						end
						if (spirit[buffID]) then
							data.chars[count].spirit = buffData;
						end
						if (shadow[buffID]) then
							data.chars[count].shadow = buffData;
						end
						if (motw[buffID]) then
							data.chars[count].motw = buffData;
						end
						if (pal[buffID]) then
							data.chars[count].pal = buffData;
						end
						--if (worldBuffs[count]) then
						--	data.chars[count].worldBuffs = buffData;
						--end
					end
				end
				if (NRC.raidStatusCache.resCache) then
					local resCache = NRC.raidStatusCache.resCache[k];
					if (resCache) then
						if (not data.chars[count]) then
							count = count + 1;
							if (count > 60) then
								break;
							end
							data.rows[count + 1] = v.name;
							data.chars[count] = addChar(v, k, v.name);
						end
						data.chars[count].resCache = resCache;
					end
				end
				if (NRC.raidStatusCache.weaponEnchantCache) then
					local weaponEnchantCache = NRC.raidStatusCache.weaponEnchantCache[k];
					if (weaponEnchantCache) then
						if (not data.chars[count]) then
							count = count + 1;
							if (count > 60) then
								break;
							end
							data.rows[count + 1] = v.name;
							data.chars[count] = addChar(v, k, v.name);
						end
						data.chars[count].weaponEnchantCache = weaponEnchantCache;
					end
				end
				if (NRC.raidStatusCache.talentCache) then
					local talentCache;
					local encounters = NRC.db.global.instances[NRC.raidStatusCache.logID].encounters;
					for k, v in ipairs(encounters) do
						--Get last recorded talents before this encounter.
						if (v.talentCache) then
							talentCache = v.talentCache;
						end
						if (v.encounterID == NRC.raidStatusCache.encounterID) then
							break;
						end
					end
					if (talentCache) then
						if (not data.chars[count]) then
							count = count + 1;
							if (count > 60) then
								break;
							end
							data.rows[count + 1] = v.name;
							data.chars[count] = addChar(v, k, v.name);
						end
						data.chars[count].talentCache = talentCache[v.name];
					end
				end
			end
		else
			--We're soloing, no group.
			local me = NRC.raidStatusCache.playerName;
			local k = NRC:getGUIDFromMyAltName(me);
			local charData = {};
			count = count + 1;
			local k = charData.guid or NRC:getGUIDFromMyAltName(me);
			if (k) then
				local auraCache = NRC.raidStatusCache.auraCache[k];
				local v = {
					--Mock up a fake group cache for this char when solo.
					class = charData.englishClass;
					name = me;
					race = charData.race;
					realm = charData.realm;
				};
				if (auraCache) then
					data.rows[count + 1] = me;
					data.chars[count] = addChar(v, k, me);
					for buffID, buffData in NRC:pairsByKeys(auraCache) do
						if (NRC.flasks[buffID]) then
							data.chars[count].flask = buffData;
						end
						if (NRC.foods[buffID]) then
							data.chars[count].food = buffData;
						end
						if (int[buffID]) then
							data.chars[count].int = buffData;
						end
						if (fort[buffID]) then
							data.chars[count].fort = buffData;
						end
						if (spirit[buffID]) then
							data.chars[count].spirit = buffData;
						end
						if (shadow[buffID]) then
							data.chars[count].shadow = buffData;
						end
						if (motw[buffID]) then
							data.chars[count].motw = buffData;
						end
						if (pal[buffID]) then
							data.chars[count].pal = buffData;
						end
						--if (worldBuffs[count]) then
						--	data.chars[count].worldBuffs = buffData;
						--end
					end
				end
				if (NRC.raidStatusCache.resCache) then
					local resCache = NRC.raidStatusCache.resCache[me];
					if (resCache) then
						if (not data.chars[count]) then
							data.rows[count + 1] = me;
							data.chars[count] = addChar(v, k, me);
						end
						data.chars[count].resCache = resCache;
					end
				end
				if (NRC.raidStatusCache.weaponEnchantCache) then
					local weaponEnchantCache = NRC.raidStatusCache.weaponEnchantCache[me];
					if (weaponEnchantCache) then
						if (not data.chars[count]) then
							data.rows[count + 1] = me;
							data.chars[count] = addChar(v, k, me);
						end
						data.chars[count].weaponEnchantCache = weaponEnchantCache;
					end
				end
				local talents, glyphs = NRC:getAllTalentsFromEncounter(NRC.raidStatusCache.logID, NRC.raidStatusCache.encounterID, NRC.raidStatusCache.attemptID);
				if (talents) then
					for kk, vv in pairs(talents) do
						if (kk == me) then
							if (not data.chars[count]) then
								data.rows[count + 1] = me;
								data.chars[count] = addChar(v, k, me);
							end
							data.chars[count].talentCache = vv;
							if (not NRC.raidStatusCache.talentCache) then
								--Not even sure this is used... I think it just uses NRC.raidStatusCache.talentCache? wrote this a long time ago.
								NRC.raidStatusCache.talentCache = {};
							end
							NRC.raidStatusCache.talentCache[me] = vv;
						end
					end
				end
				--[[if (NRC.raidStatusCache.talentCache) then
					local talentCache;
					local encounters = NRC.db.global.instances[NRC.raidStatusCache.logID].encounters;
					for k, v in ipairs(encounters) do
						--Get last recorded talents before this encounter.
						if (v.talentCache) then
							talentCache = v.talentCache;
						end
						if (v.encounterID == NRC.raidStatusCache.encounterID) then
							break;
						end
					end
					if (talentCache) then
						if (not data.chars[count]) then
							data.rows[count + 1] = me;
							data.chars[count] = addChar(v, k, me);
						end
						data.chars[count].talentCache = talentCache[me];
					end
				end]]
			end
		end
	else
		local groupData;
		local equipCache = NRC.equipCache;
		local hasAddon = NRC.hasAddon;
		local hasAddonHelper = NRC.hasAddonHelper;
		if (GetNumGroupMembers() > 1) then
			groupData = NRC.groupCache;
		else
			--If we're solo.
			local _, class = UnitClass("player");
			groupData = {
				[UnitName("Player")] = {
					guid = UnitGUID("player"),
					class = class,
					online = true,
				},
			};
		end
		local count = 0;
		data.rows[1] = "Header";
		for k, v in pairs(groupData) do
			count = count + 1;
			data.rows[count + 1] = k;
			data.chars[count] = addChar(v, v.guid, k);
			local char = data.chars[count];
			local auraCache = NRC.auraCache[v.guid];
			if (usingSpecialSlot) then
				--If this is still true when it reaches the frame recalc then it merans there was no data to display, it's "missing" for this char;
				char.specialSlotData = true;
			end
			if (usingSpecialSlot2) then
				--If this is still true when it reaches the frame recalc then it merans there was no data to display, it's "missing" for this char;
				char.specialSlotData2 = true;
			end
			local fullName;
			if (v.realm) then
				fullName = k .. "-" .. v.realm;
			else
				if (GetNormalizedRealmName()) then
					fullName = k .. "-" .. GetNormalizedRealmName();
				else
					fullName = k;
				end
			end
			if (auraCache) then
				--for buffID, buffData in NRC:pairsByKeys(auraCache) do
				for buffID, buffData in pairs(auraCache) do
					if (NRC.flasks[buffID]) then
						char.flask = buffData;
					elseif (NRC.foods[buffID]) then
						char.food = buffData;
					elseif (int[buffID]) then
						char.int = buffData;
					elseif (fort[buffID]) then
						char.fort = buffData;
					elseif (spirit[buffID]) then
						char.spirit = buffData;
					elseif (shadow[buffID]) then
						char.shadow = buffData;
					elseif (motw[buffID]) then
						char.motw = buffData;
					elseif (pal[buffID]) then
						char.pal = buffData;
					elseif (usingSpecialSlot and naxxSealLevels[buffID]) then
						char.specialSlotData = naxxSealLevels[buffID];
						char.specialSlotData.type = "naxx";
					end
					--if (worldBuffs[buffID]) then
					--	char.worldBuffs = buffData;
					--end
				end
				if (usingSpecialSlot2) then
					if (sanctifiedCache[v.guid]) then
						char.specialSlotData2 = sanctifiedCache[v.guid];
					else
						char.specialSlotData2 = true;
					end
				end
				if (usingSpecialSlot3) then
					local ilvl = NRC:getAverageItemLevel(v.guid);
					if (ilvl > 0) then
						char.specialSlotData3 = ilvl;
					else
						char.specialSlotData3 = true;
					end
				end
				if (usingSpecialSlot4) then
					if (gearCache[v.guid]) then
						char.specialSlotData4 = v.guid;
					else
						char.specialSlotData4 = true;
					end
				end
				if (isClassic) then
					local equip = equipCache[k];
					if (equip) then
						if (equip[15] and equip[15] == 15138) then
							char.hasOnyCloak = true;
						end
					end
				end
				if (hasAddon[fullName] or hasAddonHelper[fullName]) then
					char.hasDataShare = true;
					char.addonVersion = hasAddon[fullName];
					char.helperVerson = hasAddonHelper[fullName];
				end
			end
		end
		gamma = gammaBuffs;
	end
	return data, gamma;
end

--https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function NRC:tableCopyAuras(orig)
	local data = copy(orig);
	for guid, auras in pairs(data) do
		for spellID, spellData in pairs(auras) do
			--Remove any we aren't tracking to save saved variables space.
			auras[spellID].auraInstanceID = nil;
			auras[spellID].buff = nil;
			auras[spellID].source = nil;
			if (not aurasToTableCopy[spellID]) then
				auras[spellID] = nil;
			end
		end
	end
	return data;
end

--[[function NRC:tableCopyAuras(orig)
	local data = copy(orig);
	local flasks = NRC.flasks;
	local scrolls = NRC.scrolls;
	local battleElixirs = NRC.battleElixirs;
	local guardianElixirs = NRC.guardianElixirs;
	local foods = NRC.foods;
	for guid, auras in pairs(data) do
		for spellID, spellData in pairs(auras) do
			--Remove any we aren't tracking to save saved variables space.
			if (not int[spellID]
			and not fort[spellID]
			and not spirit[spellID]
			and not shadow[spellID]
			and not motw[spellID]
			and not pal[spellID]
			and not flasks[spellID]
			and not scrolls[spellID]
			and not battleElixirs[spellID]
			and not guardianElixirs[spellID]
			and not foods[spellID]) then
				auras[spellID] = nil;
			end
		end
	end
	return data;
end]]

--[[local specialSlot, flaskSlot, foodSlot, scrollSlot, intSlot, fortSlot, spiritSlot, shadowSlot, motwSlot, palSlot, duraSlot, worldBuffsSlot;
local armorSlot, holyResSlot, fireResSlot, natureResSlot, frostResSlot, shadowResSlot, arcaneResSlot, weaponEnchantsSlot, talentsSlot;
function NRC.updateRaidStatusSettings()
	flaskSloconfig.fig.raidStatusFlask;
end

local function displayBuffMissing(frame)

end

local function displayFlasks(frame, data)

end

local function displayGeneric(frame, data)

end

local gridData = NRC.gridData;
local showMore;

local function updateRaidStatusFramesLayout()

end]]

--function NRC:updateRaidStatusFramesLayout()
--	updateRaidStatusFramesLayout();
--end

--function NRC:updateRaidStatusFrames()
--
--end

--tooltips load on enter and not always like before