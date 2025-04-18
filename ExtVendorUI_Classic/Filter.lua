local L = LibStub("AceLocale-3.0"):GetLocale("ExtVendor", true);
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local SLOT_FILTERS = {
    [1] = {"INVTYPE_HEAD", "INVTYPE_SHOULDER", "INVTYPE_CLOAK", "INVTYPE_CHEST", "INVTYPE_ROBE", "INVTYPE_WRIST", "INVTYPE_HAND", "INVTYPE_WAIST", "INVTYPE_LEGS", "INVTYPE_FEET"},
    [2] = {"INVTYPE_HEAD"},
    [3] = {"INVTYPE_SHOULDER"},
    [4] = {"INVTYPE_CLOAK"},
    [5] = {"INVTYPE_CHEST", "INVTYPE_ROBE"},
    [6] = {"INVTYPE_WRIST"},
    [7] = {"INVTYPE_HAND"},
    [8] = {"INVTYPE_WAIST"},
    [9] = {"INVTYPE_LEGS"},
    [10] = {"INVTYPE_FEET"},

    [20] = {"INVTYPE_NECK", "INVTYPE_BODY", "INVTYPE_TABARD", "INVTYPE_FINGER", "INVTYPE_TRINKET"},
    [21] = {"INVTYPE_NECK"},
    [22] = {"INVTYPE_BODY"},
    [23] = {"INVTYPE_TABARD"},
    [24] = {"INVTYPE_FINGER"},
    [25] = {"INVTYPE_TRINKET"},

    [30] = {"INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONOFFHAND", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT"},
    [31] = {"INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND"},
    [32] = {"INVTYPE_2HWEAPON"},
    [33] = {"INVTYPE_WEAPONOFFHAND"},
    [34] = {"INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT"},

    [40] = {"INVTYPE_HOLDABLE", "INVTYPE_SHIELD"},
    [41] = {"INVTYPE_HOLDABLE"},
    [42] = {"INVTYPE_SHIELD"},
};

--========================================
-- Show the filter options dropdown menu
--========================================
function ExtVendor_DisplayFilterDropDown(self)

    local menu = {
        { text = L["HIDE_FILTERED"], checked = EXTVENDOR_DATA['config']['hide_filtered'], func = function() ExtVendor_ToggleSetting("hide_filtered"); ExtVendor_UpdateDisplay(); end },
		{ text = "", notCheckable = true, notClickable = true, disabled = true },
        { text = L["HIDE_UNUSABLE"], checked = EXTVENDOR_DATA['config']['usable_items'], func = function() ExtVendor_ToggleSetting("usable_items"); ExtVendor_UpdateDisplay(); end },
        { text = L["FILTER_SUBOPTIMAL"], checked = EXTVENDOR_DATA['config']['optimal_armor'], func = function() ExtVendor_ToggleSetting("optimal_armor"); ExtVendor_UpdateDisplay(); end },
        { text = L["FILTER_RECIPES"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = L["FILTER_ALREADY_KNOWN"], checked = EXTVENDOR_DATA['config']['hide_known_recipes'], func = function() ExtVendor_ToggleSetting("hide_known_recipes"); ExtVendor_UpdateDisplay(); end, disabled = EXTVENDOR_DATA['config']['high_performance'] },
                { text = L["FILTER_PURCHASED"], checked = EXTVENDOR_DATA['config']['filter_purchased_recipes'], func = function() ExtVendor_ToggleSetting("filter_purchased_recipes"); ExtVendor_UpdateDisplay(); end },
            },
        },
        { text = L["FILTER_SLOT"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = ALL,                   checked = (EXTVENDOR.SlotFilterIndex == 0),  func = function() ExtVendor_SetSlotFilter(0); end },
                { text = L["SLOT_CAT_ARMOR"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (EXTVENDOR.SlotFilterIndex == 1),  func = function() ExtVendor_SetSlotFilter(1); end },
                        { text = L["SLOT_HEAD"],        checked = (EXTVENDOR.SlotFilterIndex == 2),  func = function() ExtVendor_SetSlotFilter(2); end },
                        { text = L["SLOT_SHOULDER"],    checked = (EXTVENDOR.SlotFilterIndex == 3),  func = function() ExtVendor_SetSlotFilter(3); end },
                        { text = L["SLOT_BACK"],        checked = (EXTVENDOR.SlotFilterIndex == 4),  func = function() ExtVendor_SetSlotFilter(4); end },
                        { text = L["SLOT_CHEST"],       checked = (EXTVENDOR.SlotFilterIndex == 5),  func = function() ExtVendor_SetSlotFilter(5); end },
                        { text = L["SLOT_WRIST"],       checked = (EXTVENDOR.SlotFilterIndex == 6),  func = function() ExtVendor_SetSlotFilter(6); end },
                        { text = L["SLOT_HANDS"],       checked = (EXTVENDOR.SlotFilterIndex == 7),  func = function() ExtVendor_SetSlotFilter(7); end },
                        { text = L["SLOT_WAIST"],       checked = (EXTVENDOR.SlotFilterIndex == 8),  func = function() ExtVendor_SetSlotFilter(8); end },
                        { text = L["SLOT_LEGS"],        checked = (EXTVENDOR.SlotFilterIndex == 9),  func = function() ExtVendor_SetSlotFilter(9); end },
                        { text = L["SLOT_FEET"],        checked = (EXTVENDOR.SlotFilterIndex == 10), func = function() ExtVendor_SetSlotFilter(10); end },
                    },
                },
                { text = L["SLOT_CAT_ACCESSORIES"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (EXTVENDOR.SlotFilterIndex == 20), func = function() ExtVendor_SetSlotFilter(20); end },
                        { text = L["SLOT_NECK"],        checked = (EXTVENDOR.SlotFilterIndex == 21), func = function() ExtVendor_SetSlotFilter(21); end },
                        { text = L["SLOT_SHIRT"],       checked = (EXTVENDOR.SlotFilterIndex == 22), func = function() ExtVendor_SetSlotFilter(22); end },
                        { text = L["SLOT_TABARD"],      checked = (EXTVENDOR.SlotFilterIndex == 23), func = function() ExtVendor_SetSlotFilter(23); end },
                        { text = L["SLOT_FINGER"],      checked = (EXTVENDOR.SlotFilterIndex == 24), func = function() ExtVendor_SetSlotFilter(24); end },
                        { text = L["SLOT_TRINKET"],     checked = (EXTVENDOR.SlotFilterIndex == 25), func = function() ExtVendor_SetSlotFilter(25); end },
                    },
                },
                { text = L["SLOT_CAT_WEAPONS"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (EXTVENDOR.SlotFilterIndex == 30), func = function() ExtVendor_SetSlotFilter(30); end },
                        { text = L["SLOT_WEAPON1H"],    checked = (EXTVENDOR.SlotFilterIndex == 31), func = function() ExtVendor_SetSlotFilter(31); end },
                        { text = L["SLOT_WEAPON2H"],    checked = (EXTVENDOR.SlotFilterIndex == 32), func = function() ExtVendor_SetSlotFilter(32); end },
                        { text = L["SLOT_WEAPONOH"],    checked = (EXTVENDOR.SlotFilterIndex == 33), func = function() ExtVendor_SetSlotFilter(33); end },
                        { text = L["SLOT_RANGED"],      checked = (EXTVENDOR.SlotFilterIndex == 34), func = function() ExtVendor_SetSlotFilter(34); end },
                    },
                },
                { text = L["SLOT_CAT_OFFHAND"], hasArrow = true, notCheckable = true,
                    menuList = {
                        { text = ALL,                   checked = (EXTVENDOR.SlotFilterIndex == 40), func = function() ExtVendor_SetSlotFilter(40); end },
                        { text = L["SLOT_OFFHAND"],     checked = (EXTVENDOR.SlotFilterIndex == 41), func = function() ExtVendor_SetSlotFilter(41); end },
                        { text = L["SLOT_SHIELD"],      checked = (EXTVENDOR.SlotFilterIndex == 42), func = function() ExtVendor_SetSlotFilter(42); end },
                    },
                },
            },
        },
        { text = L["QUALITY_FILTER_MINIMUM"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = ALL, checked = (EXTVENDOR.SelectedQuality == 0), func = function() ExtVendor_SetMinimumQuality(0); end },
                { text = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC, checked = (EXTVENDOR.SelectedQuality == 2), func = function() ExtVendor_SetMinimumQuality(2); end },
                { text = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC, checked = (EXTVENDOR.SelectedQuality == 3), func = function() ExtVendor_SetMinimumQuality(3); end },
                { text = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC, checked = (EXTVENDOR.SelectedQuality == 4), func = function() ExtVendor_SetMinimumQuality(4); end },
            },
        },
        { text = L["QUALITY_FILTER_SPECIFIC"], hasArrow = true, notCheckable = true,
            menuList = {
                { text = ALL, checked = (EXTVENDOR.SelectedQuality == 0), func = function() ExtVendor_SetMinimumQuality(0); end },
                { text = ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC, checked = (EXTVENDOR.SelectedQuality == 1), func = function() ExtVendor_SetSpecificQuality(1); end },
                { text = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC, checked = (EXTVENDOR.SelectedQuality == 2), func = function() ExtVendor_SetSpecificQuality(2); end },
                { text = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC, checked = (EXTVENDOR.SelectedQuality == 3), func = function() ExtVendor_SetSpecificQuality(3); end },
                { text = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC, checked = (EXTVENDOR.SelectedQuality == 4), func = function() ExtVendor_SetSpecificQuality(4); end },
            },
        },
		{ text = "", notCheckable = true, notClickable = true, disabled = true },
        { text = L["CONFIGURE_QUICKVENDOR"], notCheckable = true, func = function() ExtVendor_QVConfigFrame:Show(); end },
        { text = L["CONFIGURE_ADDON"], notCheckable = true, func = function() ExtVendor_ShowMainConfig(); end },
    };
    LibDD:EasyMenu(menu, MerchantFrameFilterDropDown, self, 0, 0, "MENU", 1);
end


--========================================
-- Sets the 'stock' filter and updates
-- the vendor display
--========================================
function ExtVendor_SetStockFilter(index)
    SetMerchantFilter(index);
    ExtVendor_UpdateDisplay();
end

--========================================
-- Sets the minimum quality filter
--========================================
function ExtVendor_SetMinimumQuality(quality)
    EXTVENDOR.SelectedQuality = math.max(0, math.min(7, quality));
    EXTVENDOR.SpecificQuality = false;
    ExtVendor_UpdateDisplay();
end

--========================================
-- Sets the specific quality filter
--========================================
function ExtVendor_SetSpecificQuality(quality)
    EXTVENDOR.SelectedQuality = math.max(0, math.min(7, quality));
    EXTVENDOR.SpecificQuality = true;
    ExtVendor_UpdateDisplay();
end

--========================================
-- Changes the equipment slot filter
--========================================
function ExtVendor_SetSlotFilter(index)
    EXTVENDOR.SlotFilterIndex = index;
    ExtVendor_UpdateDisplay();
end


--========================================
-- Checks item information against search
-- and filter criteria
--========================================
function ExtVendor_IsItemFiltered(itemId, searchString, itemName, itemQuality, itemClassId, itemSubClassId, itemEquipLoc, isKnown, isPurchasable, isUsable, filterSuboptimal)

    local isFiltered = false;
    local whyFiltered = "";

    if (itemClassId == LE_ITEM_CLASS_RECIPE) then
        -- filter known recipes
        if (EXTVENDOR_DATA['config']['hide_known_recipes'] and isKnown) then
            return true, L["FILTER_REASON_ALREADY_KNOWN"];
        end
        -- filter purchased recipes
        if (itemId) then
            if (EXTVENDOR_DATA['config']['filter_purchased_recipes']) then
                if (GetItemCount(itemId, true) > 0) then
                    return true, L["FILTER_REASON_ALREADY_OWNED"];
                end
            end
        end
    end
    -- check search filter
    if (string.len(searchString) > 0) then
        if (not string.find(string.lower(itemName), string.lower(searchString), 1, true)) then
            return true, L["FILTER_REASON_SEARCH_FILTER"];
        end
    end
    -- check quality filter
    if (EXTVENDOR.SelectedQuality > 0) then
        if ((itemQuality < EXTVENDOR.SelectedQuality) or ((itemQuality > EXTVENDOR.SelectedQuality) and EXTVENDOR.SpecificQuality)) then
            return true, L["FILTER_REASON_QUALITY_FILTER"];
        end
    end
    -- check usability filter
    if (EXTVENDOR_DATA['config']['usable_items'] and ((not isPurchasable) or (not isUsable))) then
        return true, L["FILTER_REASON_NOT_USABLE"];
    end
    -- check optimal armor filter
    if (filterSuboptimal) then
        local sf, sfr = ExtVendor_IsItemFilteredSuboptimal(itemId, itemQuality, itemClassId, itemSubClassId, itemEquipLoc, isUsable);
        if (sf) then
            return true, sfr;
        end
    end
    -- check slot filter
    if (EXTVENDOR.SlotFilterIndex > 0) then
        if (SLOT_FILTERS[EXTVENDOR.SlotFilterIndex]) then
            local validSlot = false;
            local j, slot;
            for j, slot in pairs(SLOT_FILTERS[EXTVENDOR.SlotFilterIndex]) do
                if (slot == itemEquipLoc) then
                    validSlot = true;
                end
            end
            if (not validSlot) then
                return true, L["FILTER_REASON_SLOT_FILTER"];
            end
        end
    end
    
    return false;

end

--========================================
-- Checks if an item should be filtered
-- as sub-optimal armor
--========================================
function ExtVendor_IsItemFilteredSuboptimal(itemId, itemQuality, itemClassId, itemSubClassId, itemEquipLoc, isUsable)
    if (isUsable) then
        if (not ExtVendor_IsOptimalArmor(itemClassId, itemSubClassId, itemEquipLoc)) then
            return true, L["FILTER_REASON_SUBOPTIMAL"];
        end
    end
    return false;
end
