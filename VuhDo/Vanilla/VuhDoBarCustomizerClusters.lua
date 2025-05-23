local _;
local _G = _G;

local VUHDO_HIGLIGHT_CLUSTER = { };
local VUHDO_HIGLIGHT_NUM = 0;
local VUHDO_ICON_CLUSTER = { };
local VUHDO_NUM_IN_UNIT_CLUSTER = { };
local sClusterConfig;

local VUHDO_CLUSTER_UNIT = nil;

--
local twipe = table.wipe;
local pairs = pairs;

local VUHDO_RAID = { };

local VUHDO_getUnitsInRadialClusterWith;
local VUHDO_getUnitsInChainClusterWith;
local VUHDO_getUnitButtons;
local VUHDO_getClusterBorderFrame;
local VUHDO_updateBouquetsForEvent;
local VUHDO_getBarIcon;
local VUHDO_getBarIconTimer;
local VUHDO_isInConeInFrontOf;
local VUHDO_backColor;
local VUHDO_getUnitButtonsSafe;

local sHealthLimit;
local sIsRaid;
local sThreshFair;
local sThreshGood;
local sColorFair;
local sColorGood;
local sIsSourcePlayer;
local sRangePow;
local sNumMaxJumps;
local sIsRadial;
local sClusterSlots;
local sIsClusterSlotActive;
local sCdSpell;
local sCone;
local sJumpRangePow;
local sAreTargetsRandom;
function VUHDO_customClustersInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];

	VUHDO_getUnitsInRadialClusterWith = _G["VUHDO_getUnitsInRadialClusterWith"];
	VUHDO_getUnitsInChainClusterWith = _G["VUHDO_getUnitsInChainClusterWith"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_getClusterBorderFrame = _G["VUHDO_getClusterBorderFrame"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_getBarIcon = _G["VUHDO_getBarIcon"];
	VUHDO_getBarIconTimer = _G["VUHDO_getBarIconTimer"];
	VUHDO_isInConeInFrontOf = _G["VUHDO_isInConeInFrontOf"];
	VUHDO_backColor = _G["VUHDO_backColor"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];

	sClusterConfig = VUHDO_CONFIG["CLUSTER"];
	sHealthLimit = sClusterConfig["BELOW_HEALTH_PERC"] * 0.01;
	sIsRaid = sClusterConfig["DISPLAY_DESTINATION"] == 2;
	sThreshFair = sClusterConfig["THRESH_FAIR"];
	sThreshGood = sClusterConfig["THRESH_GOOD"];
	sColorFair = VUHDO_PANEL_SETUP["BAR_COLORS"]["CLUSTER_FAIR"];
	sColorGood = VUHDO_PANEL_SETUP["BAR_COLORS"]["CLUSTER_GOOD"];
	sIsSourcePlayer = sClusterConfig["DISPLAY_SOURCE"] == 1;
	sRangePow = sClusterConfig["RANGE"] * sClusterConfig["RANGE"];
	sNumMaxJumps = sClusterConfig["CHAIN_MAX_JUMP"];
	sIsRadial = sClusterConfig["MODE"] == 1;
	sCone = sClusterConfig["CONE_DEGREES"];
	sCdSpell = sClusterConfig["COOLDOWN_SPELL"];
	sJumpRangePow = sClusterConfig["RANGE_JUMP"] * sClusterConfig["RANGE_JUMP"];
	sAreTargetsRandom = sClusterConfig["ARE_TARGETS_RANDOM"];
	if (sCdSpell or "") == "" or not VUHDO_isSpellKnown(sCdSpell) then
		sCdSpell = nil;
	end

	sClusterSlots = { };
	sIsClusterSlotActive = false;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		for tIndex, tHotName in pairs(VUHDO_PANEL_SETUP[tPanelNum]["HOTS"]["SLOTS"]) do
			if "CLUSTER" == tHotName and (tIndex < 6 or tIndex > 8) then
				sClusterSlots[tPanelNum] = tIndex;

				sIsClusterSlotActive = true;
			end
		end
	end

end



--
local tDestCluster = { };
local tInfo, tSrcInfo;
local tSrcGroup;
function VUHDO_getCustomDestCluster(aUnit, anArray, anIsSourcePlayer, anIsRadial, aRangePow, aNumMaxTargets, aHealthLimit, anIsRaid, aCdSpell, aCone, aJumpRangePow, aAreTargetsRandom)
	-- If targets are random, return ALL targets in range, so the caller can determine the average heals
	if aAreTargetsRandom then aNumMaxTargets = 100; end

	twipe(anArray);
	if anIsSourcePlayer and aUnit ~= "player" then return 0; end

	tSrcInfo = VUHDO_RAID[aUnit];
	if not tSrcInfo or tSrcInfo["isPet"] or "focus" == aUnit or "target" == aUnit then return 0; end

	if anIsRadial then VUHDO_getUnitsInRadialClusterWith(aUnit, aRangePow, tDestCluster, aCdSpell);
	else VUHDO_getUnitsInChainClusterWith(aUnit, aJumpRangePow, tDestCluster, aNumMaxTargets, aCdSpell); end

	tSrcGroup = tSrcInfo["group"];
	for _, tUnit in pairs(tDestCluster) do
		tInfo = VUHDO_RAID[tUnit];
		if tInfo and tInfo["healthmax"] > 0 and not tInfo["dead"] and tInfo["health"] / tInfo["healthmax"] <= aHealthLimit then
			if (anIsRaid or tInfo["group"] == tSrcGroup) and VUHDO_isInConeInFrontOf(tUnit, aCone) then -- all raid members or in same group
				anArray[#anArray + 1] = tUnit;
				if #anArray == aNumMaxTargets then break; end
			end
		end
	end

	return #anArray;
end
local VUHDO_getCustomDestCluster = VUHDO_getCustomDestCluster;



--
local function VUHDO_getDestCluster(aUnit, anArray)
	return VUHDO_getCustomDestCluster(aUnit, anArray, sIsSourcePlayer, sIsRadial, sRangePow, sNumMaxJumps, sHealthLimit, sIsRaid, sCdSpell, sCone, sJumpRangePow, sAreTargetsRandom);
end



--
local tNumLow;
local tAllButtons;
local tClusterSlot;
local tPanelUnitButtons;
function VUHDO_updateAllClusterIcons(aUnit, anInfo)

	if not sIsClusterSlotActive then
		return;
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if not tAllButtons then
		return;
	end

	tNumLow = VUHDO_getDestCluster(aUnit, VUHDO_ICON_CLUSTER);
	if VUHDO_NUM_IN_UNIT_CLUSTER[aUnit] ~= tNumLow then
		VUHDO_NUM_IN_UNIT_CLUSTER[aUnit] = tNumLow;
		VUHDO_updateBouquetsForEvent(aUnit, 16); -- VUHDO_UPDATE_NUM_CLUSTER
	end

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		tClusterSlot = sClusterSlots[tPanelNum];
		tPanelUnitButtons = VUHDO_getUnitButtonsPanel(aUnit, tPanelNum);

		for _, tButton in pairs(tPanelUnitButtons) do
			-- FIXME: right after spec change the bar icon frame for "CLUSTER" is nil
			-- FIXME: not entirely sure why but this will prevent nil reference until next update
			if not VUHDO_getBarIcon(tButton, tClusterSlot) then
				return;
			end

			if tNumLow < sThreshFair or not anInfo["range"] then
				VUHDO_getBarIconFrame(tButton, tClusterSlot):Hide();
				VUHDO_getBarIconTimer(tButton, tClusterSlot):SetText("");
			else
				VUHDO_getBarIcon(tButton, tClusterSlot):SetVertexColor(VUHDO_backColor(tNumLow < sThreshGood and sColorFair or sColorGood));
				VUHDO_getBarIconFrame(tButton, tClusterSlot):Show();
				if sClusterConfig["IS_NUMBER"] then
					VUHDO_getBarIconTimer(tButton, tClusterSlot):SetText(tNumLow);
				end
			end
		end
	end

end



--
function VUHDO_removeAllClusterHighlights()
	for _, tUnit in pairs(VUHDO_HIGLIGHT_CLUSTER) do
		VUHDO_updateBouquetsForEvent(tUnit, 18); -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
	end

	twipe(VUHDO_HIGLIGHT_CLUSTER);
end
local VUHDO_removeAllClusterHighlights = VUHDO_removeAllClusterHighlights;



--
function VUHDO_highlightClusterFor(aUnit)
	VUHDO_CLUSTER_UNIT = aUnit;
	if VUHDO_HIGLIGHT_NUM ~= 0 then
		VUHDO_removeAllClusterHighlights();
	end

	VUHDO_HIGLIGHT_NUM = VUHDO_getDestCluster(aUnit, VUHDO_HIGLIGHT_CLUSTER);

	for _, tUnit in pairs(VUHDO_HIGLIGHT_CLUSTER) do
		VUHDO_HIGLIGHT_CLUSTER[tUnit] = true;
		VUHDO_updateBouquetsForEvent(tUnit, 18); -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
	end
end



--
function VUHDO_updateClusterHighlights()
	if VUHDO_CLUSTER_UNIT then
		VUHDO_highlightClusterFor(VUHDO_CLUSTER_UNIT);
	end
end



--
function VUHDO_resetClusterUnit()
	VUHDO_CLUSTER_UNIT = nil;
end



--
function VUHDO_getNumInUnitCluster(aUnit)
	return VUHDO_NUM_IN_UNIT_CLUSTER[aUnit] or 0;
end



--
function VUHDO_getIsInHiglightCluster(aUnit)
	if VUHDO_HIGLIGHT_NUM < sThreshFair then return false; end
	return VUHDO_HIGLIGHT_CLUSTER[aUnit];
end



--
local tBorder;
function VUHDO_clusterBorderBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName)

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		if VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["CLUSTER_BORDER"] == aBouquetName then
			tBorder = VUHDO_getClusterBorderFrame(tButton);

			if aColor then
				tBorder:SetBackdropBorderColor(VUHDO_backColorWithFallback(aColor));

				tBorder:Show();
			else
				tBorder:Hide();
			end
		end
	end

end



--
function VUHDO_getIsClusterSlotActive()

	return sIsClusterSlotActive;

end
