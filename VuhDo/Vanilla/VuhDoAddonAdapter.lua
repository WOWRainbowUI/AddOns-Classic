local _;
local LoadAddOn = C_AddOns.LoadAddOn or LoadAddOn;
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded;

-- For initializing the minimap
VUHDO_MM_SETTINGS = VUHDO_MM_SETTINGS or { };

VUHDO_LibSharedMedia = LibStub("LibSharedMedia-3.0");
VUHDO_LibDataBroker = LibStub("LibDataBroker-1.1", true);
VUHDO_LibDBIcon = LibStub("LibDBIcon-1.0");

VUHDO_LibButtonFacade = nil;

VUHDO_LibCompress = LibStub:GetLibrary("LibCompress");
VUHDO_LibCompressEncode = VUHDO_LibCompress:GetAddonEncodeTable();

VUHDO_LibBase64 = LibStub:GetLibrary("LibBase64-1.0");
VUHDO_LibCustomGlow = LibStub("LibCustomGlow-1.0");
VUHDO_LibNickTag = LibStub("NickTag-1.0");
VUHDO_LibSpec = LibStub("LibSpecialization", true);

VUHDO_LibHealComm = nil;

VUHDO_LibClassicDurations = LibStub("LibClassicDurations");

if VUHDO_LibClassicDurations then
	VUHDO_LibClassicDurations:Register("VuhDo");
end

VUHDO_LibSharedMedia:Register("font", "Arial Black",  "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf");
VUHDO_LibSharedMedia:Register("font", "Emblem",	"Interface\\AddOns\\VuhDo\\Fonts\\Emblem.ttf");
VUHDO_LibSharedMedia:Register("font", "Vixar",	"Interface\\AddOns\\VuhDo\\Fonts\\vixar.ttf");

local function VUHDO_registerLsmBar(...)
	for tCnt = 1, select('#', ...) do
		VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - " .. select(tCnt, ...), "Interface\\AddOns\\VuhDo\\Images\\bar" .. tCnt .. ".tga");
	end
end

VUHDO_registerLsmBar("Rhombs", "Twirls", "Pipe, dark", "Concave, dark", "Pipe, light", "Flat", "Concave, light",
	"Convex", "Textile", "Mirrorfinish", "Diagonals", "Zebra", "Marble", "Modern Art", "Polished Wood", "Plain",
	"Minimalist", "Aluminium", "Gradient");

VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Bar Highlighter", "Interface\\AddOns\\VuhDo\\Images\\highlight.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Plain White", "Interface\\AddOns\\VuhDo\\Images\\plain_white.tga");
VUHDO_LibSharedMedia:Register("statusbar", "LiteStepLite", "Interface\\AddOns\\VuhDo\\Images\\LiteStepLite.tga");
VUHDO_LibSharedMedia:Register("statusbar", "Tukui", "Interface\\AddOns\\VuhDo\\Images\\tukuibar.tga");

VUHDO_LibSharedMedia:Register("sound", "Tribal Bass Drum", 566027);
VUHDO_LibSharedMedia:Register("sound", "Thorns", 569022);
VUHDO_LibSharedMedia:Register("sound", "Elf Bell Toll", 566558);

VUHDO_LibSharedMedia:Register("border", "Plain White", "Interface\\AddOns\\VuhDo\\Images\\white_square_16_16");

LoadAddOn("FuBarPlugin-3.0");



--
function VUHDO_initAddonMessages()
	if not C_ChatInfo.IsAddonMessagePrefixRegistered("CTRA") then C_ChatInfo.RegisterAddonMessagePrefix("CTRA"); end
	if not C_ChatInfo.IsAddonMessagePrefixRegistered(VUHDO_COMMS_PREFIX) then C_ChatInfo.RegisterAddonMessagePrefix(VUHDO_COMMS_PREFIX); end
end



--
local tHasShownError = false;
function VUHDO_parseAddonMessage(aPrefix, aMessage, aUnitName)
	if VUHDO_COMMS_PREFIX == aPrefix then

		if VUHDO_parseVuhDoMessage then
			VUHDO_parseVuhDoMessage(aUnitName, aMessage);
		elseif not tHasShownError then
			VUHDO_Msg("VuhDo 設定選項模組沒有載入：無法接收來自其他玩家的資料。", 1, 0.4, 0.4);
			tHasShownError = true;
		end

	elseif "CTRA" == aPrefix then
		if strfind(aMessage, "#") then
			local tFragments = VUHDO_splitString(aMessage, "#");
			for _, tCommand in pairs(tFragments) do
				VUHDO_parseCtraMessage(aUnitName, tCommand);
			end
		else
			VUHDO_parseCtraMessage(aUnitName, aMessage);
		end
	end
end



--
function VUHDO_initFuBar()
	-- libDataBroker
	if VUHDO_LibDataBroker then
		local minimapObject = VUHDO_LibDataBroker:NewDataObject("VuhDo", {
			type = "launcher",
			icon = VUHDO_STANDARD_ICON,
			OnClick = function(aClickedFrame, aButton)
				if aButton == "RightButton" then
					if AddonCompartmentFrame and aClickedFrame:GetParent() == DropDownList1 then
						ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, "cursor", 0, 0);
					else
						ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, aClickedFrame:GetName(), 0, -5);
					end
				else
					VUHDO_slashCmd("opt");
				end
			end,
			OnTooltipShow = function(aTooltip)
				aTooltip:AddLine("巫毒團隊框架")
				aTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_1)
				aTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_2)
			end,
		});

		-- Minimap icon provided by LibDBIcon
		if VUHDO_LibDBIcon then
			-- if the old configuration still exists, migrate to the LibDBIcon database
			if VUHDO_CONFIG["SHOW_MINIMAP"] ~= nil then
				VUHDO_MM_SETTINGS["hide"] = not VUHDO_forceBooleanValue(VUHDO_CONFIG["SHOW_MINIMAP"]);
				VUHDO_CONFIG["SHOW_MINIMAP"] = nil;
			end

			VUHDO_LibDBIcon:Register("VuhDo", minimapObject, VUHDO_MM_SETTINGS);

			VUHDO_initMinimap();
		end
	end

	-- Native FuBar
	if LibStub:GetLibrary("LibFuBarPlugin-3.0", true)
		and IsAddOnLoaded("FuBar")
		and not IsAddOnLoaded("FuBar2Broker")
		and not IsAddOnLoaded("Broker2FuBar") then

		local tLibFuBarPlugin = LibStub:GetLibrary("LibFuBarPlugin-3.0");
		LibStub("AceAddon-3.0"):EmbedLibrary(VuhDo, "LibFuBarPlugin-3.0");
		VuhDo:SetFuBarOption("tooltipType", "GameTooltip");
		VuhDo:SetFuBarOption("hasNoColor", true);
		VuhDo:SetFuBarOption("cannotDetachTooltip", true);
		VuhDo:SetFuBarOption("hideWithoutStandby", true);
		VuhDo:SetFuBarOption("iconPath", VUHDO_STANDARD_ICON);
		VuhDo:SetFuBarOption("hasIcon", true);
		VuhDo:SetFuBarOption("defaultPosition", "RIGHT");
		VuhDo:SetFuBarOption("tooltipHiddenWhenEmpty", true);
		VuhDo:SetFuBarOption("configType", "None");
		VuhDo.title = "VuhDo";
		VuhDo.name = "VuhDo";
		tLibFuBarPlugin:OnEmbedInitialize(VuhDo, VuhDo);
		function VuhDo:OnUpdateFuBarTooltip()
			if not GameTooltip:IsForbidden() then
				GameTooltip:AddLine("VuhDo");
				GameTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_1);
				GameTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_2);
			end
		end
		VuhDo:Show();
		function VuhDo:OnFuBarClick(aButton)
			if "LeftButton" == aButton then
				VUHDO_slashCmd("opt");
			elseif "RightButton" == aButton then
				ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, VuhDo:GetFrame():GetName(), 0, -5);
			end
		end
	end
end



--
function VUHDO_initSharedMedia()
	-- fonts
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List("font")) do
		VUHDO_FONTS[tIndex] = { VUHDO_LibSharedMedia:Fetch("font", tValue), tValue };
	end

	-- status bars
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List("statusbar")) do
		VUHDO_STATUS_BARS[tIndex] = { tValue, tValue };
	end

	-- sounds
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List("sound")) do
		VUHDO_SOUNDS[tIndex] = { VUHDO_LibSharedMedia:Fetch("sound", tValue), tValue };
	end
	tinsert(VUHDO_SOUNDS, 1, { nil, "-- " .. VUHDO_I18N_OFF .. " --" } );

	-- borders
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List("border")) do
		VUHDO_BORDERS[tIndex] = { VUHDO_LibSharedMedia:Fetch("border", tValue) or "", tValue };
	end
end



--
function VUHDO_initCliqueSupport()
	if not VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"] then return; end

	if not IsAddOnLoaded("Clique") then
		VUHDO_Msg("警告：Clique 相容模式已經啟用，但是 Clique 似乎尚未載入!", 1, 0.4, 0.4);
	end

	ClickCastFrames = ClickCastFrames or {};

	local tBtnName;
	local tIcon;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		for tButtonNum = 1, 51 do -- VUHDO_MAX_BUTTONS_PANEL
			tBtnName = format("Vd%dH%d", tPanelNum, tButtonNum);
			if _G[tBtnName] then
				ClickCastFrames[_G[tBtnName]] = true;
				ClickCastFrames[_G[tBtnName .. "Tg"]] = true;
				ClickCastFrames[_G[tBtnName .. "Tot"]] = true;
				for tIconNum = 40, 44 do
					tIcon = _G[format("%sBgBarIcBarHlBarIc%d", tBtnName, tIconNum)];
					if tIcon then ClickCastFrames[tIcon] = true; end
				end
			end
		end
	end
end



--
function VUHDO_initButtonFacade(anInstance)
	VUHDO_LibButtonFacade = VUHDO_CONFIG["IS_USE_BUTTON_FACADE"] and LibStub("Masque", true) or nil;

	if VUHDO_LibButtonFacade then
		VUHDO_LibButtonFacade:Group("VuhDo", VUHDO_I18N_BUFF_WATCH);
		VUHDO_LibButtonFacade:Group("VuhDo", VUHDO_I18N_HOTS);
	end
end



--
local tLibSpec = { };
function VUHDO_initLibSpecialization()

	if not VUHDO_LibSpec or not tLibSpec then
		return;
	end

	VUHDO_LibSpec.RegisterGroup(tLibSpec, VUHDO_updateRoleBySpecialization);

end



--
function VUHDO_initMinimap()

	VUHDO_initShowMinimap();
	VUHDO_initShowAddOnCompartment();

end



--
function VUHDO_initShowMinimap()

	if VUHDO_LibDataBroker and VUHDO_LibDBIcon then
		if not VUHDO_MM_SETTINGS["hide"] then
			VUHDO_LibDBIcon:Show("VuhDo");
		else
			VUHDO_LibDBIcon:Hide("VuhDo");
		end
	end

end



--
function VUHDO_initShowAddOnCompartment()

	if VUHDO_LibDataBroker and VUHDO_LibDBIcon then
		if not VUHDO_MM_SETTINGS["addon_compartment_hide"] then
			VUHDO_LibDBIcon:AddButtonToCompartment("VuhDo");
		else
			VUHDO_LibDBIcon:RemoveButtonFromCompartment("VuhDo");
		end
	end

end



--
function VUHDO_initLibHealComm()

	VUHDO_LibHealComm = VUHDO_CONFIG["SHOW_LIBHEALCOMM_INCOMING"] and LibStub("LibHealComm-4.0", true) or nil;

	if VUHDO_LibHealComm then
		local tInstance = _G["VuhDo"];

		local function HealComm_HealUpdated(aEvent, aCasterGUID, aSpellID, aHealType, aEndTime, ...)
			local tTargets = { n = select("#", ...), ... };

			for i = 1, tTargets.n do
				local tTarget = VUHDO_RAID_GUIDS[tTargets[i]];

				if (VUHDO_RAID or tEmptyRaid)[tTarget] then -- auch target, focus
					VUHDO_updateHealth(tTarget, 9); -- VUHDO_UPDATE_INC
					VUHDO_updateBouquetsForEvent(tTarget, 9); -- VUHDO_UPDATE_ALT_POWER
				end
			end
		end
		tInstance.HealComm_HealUpdated = HealComm_HealUpdated;

		VUHDO_LibHealComm.RegisterCallback(tInstance, "HealComm_HealStarted", HealComm_HealUpdated);
		VUHDO_LibHealComm.RegisterCallback(tInstance, "HealComm_HealStopped", HealComm_HealUpdated);
		VUHDO_LibHealComm.RegisterCallback(tInstance, "HealComm_HealDelayed", HealComm_HealUpdated);
		VUHDO_LibHealComm.RegisterCallback(tInstance, "HealComm_HealUpdated", HealComm_HealUpdated);

		local function HealComm_HealModified(aEvent, aTargetGUID)
			local tTarget = VUHDO_RAID_GUIDS[aTargetGUID];

			if (VUHDO_RAID or tEmptyRaid)[tTarget] then -- auch target, focus
				VUHDO_updateHealth(tTarget, 9); -- VUHDO_UPDATE_INC
				VUHDO_updateBouquetsForEvent(tTarget, 9); -- VUHDO_UPDATE_ALT_POWER
			end
		end
		tInstance.HealComm_HealModified = HealComm_HealModified;

		VUHDO_LibHealComm.RegisterCallback(tInstance, "HealComm_ModifierChanged", HealComm_HealModified);
		VUHDO_LibHealComm.RegisterCallback(tInstance, "HealComm_GUIDDisappeared", HealComm_HealModified);
	elseif VUHDO_CONFIG["SHOW_LIBHEALCOMM_INCOMING"] then
		VUHDO_Msg("WARNING: Use LibHealComm is enabled but LibHealComm-4.0 doesn't seem to be loaded!", 1, 0.4, 0.4);
	end

end
