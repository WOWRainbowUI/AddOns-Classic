--[[
    This file is part of Decursive.

    Decursive (v 2.7.29) add-on for World of Warcraft UI
    Copyright (C) 2006-2025 John Wellesz (Decursive AT 2072productions.com) ( http://www.2072productions.com/to/decursive.php )

    Decursive is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Decursive is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Decursive.  If not, see <https://www.gnu.org/licenses/>.


    Decursive is inspired from the original "Decursive v1.9.4" by Patrick Bohnet (Quu).
    The original "Decursive 1.9.4" is in public domain ( www.quutar.com )

    Decursive is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY.

    This file was last updated on 2025-03-16T19:58:01Z
--]]
-------------------------------------------------------------------------------

local addonName, T = ...;
-- big ugly scary fatal error message display function {{{
if not T._FatalError then
-- the beautiful error popup : {{{ -
StaticPopupDialogs["DECURSIVE_ERROR_FRAME"] = {
    text = "|cFFFF0000Decursive Error:|r\n%s",
    button1 = "OK",
    OnAccept = function()
        return false;
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    showAlert = 1,
    preferredIndex = 3,
    }; -- }}}
T._FatalError = function (TheError) StaticPopup_Show ("DECURSIVE_ERROR_FRAME", TheError); end
end
-- }}}
if not T._LoadedFiles or not T._LoadedFiles["Dcr_utils.lua"] then
    if not DecursiveInstallCorrupted then T._FatalError("Decursive installation is corrupted! (Dcr_utils.lua not loaded)"); end;
    DecursiveInstallCorrupted = true;
    return;
end
T._LoadedFiles["Dcr_opt.lua"] = false;

local D = T.Dcr;

local function RegisterClassLocals_Once() -- {{{


    -- Make sure to never crash if some locals are missing (seen this happen on
    -- Chinese clients when relying on LOCALIZED_CLASS_NAMES_MALE constant)
    -- While that was probably caused by a badd-on redefining the constant,
    -- it's best to stay on the safe side...

    local localizedClasses = {};

    D:tcopy(localizedClasses, LocalizedClassList and LocalizedClassList(false) or FillLocalizedClassList({}, false));


    -- D.LC = setmetatable((FillLocalizedClassList or LocalizedClassList)(false), {__index = function(t,k) return k end});
    D.LC = setmetatable(localizedClasses, {__index = function(t,k) return k end});

    RegisterLocals_Once = nil;
end -- }}}

T._CatchAllErrors = "RegisterClassLocals_Once";      RegisterClassLocals_Once();


local L  = D.L;
local LC = D.LC;
local DC = T._C;
T._CatchAllErrors = "LibDBIcon";
local icon = LibStub("LibDBIcon-1.0", true)
T._CatchAllErrors = false;

local pairs             = _G.pairs;
local ipairs            = _G.ipairs;
local type              = _G.type;
local table             = _G.table;
local str_format        = _G.string.format;
local str_gsub          = _G.string.gsub;
local str_sub           = _G.string.sub;
local abs               = _G.math.abs;
local GetNumRaidMembers = DC.GetNumRaidMembers;
local GetNumPartyMembers= _G.GetNumSubgroupMembers;
local InCombatLockdown  = _G.InCombatLockdown;
local GetItemInfo           = _G.C_Item and _G.C_Item.GetItemInfo or _G.GetItemInfo;
local GetSpellInfo          = _G.C_Spell and _G.C_Spell.GetSpellInfo or _G.GetSpellInfo;
local GetSpellName          = _G.C_Spell and _G.C_Spell.GetSpellName or function (spellId) return (GetSpellInfo(spellId)) end;
local GetSpellDescription = _G.C_Spell and _G.C_Spell.GetSpellDescription or _G.GetSpellDescription;
local GetSpecialization = _G.GetSpecialization or (GetActiveTalentGroup or function () return nil; end);
local GetAddOnMetadata  = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata;
local _;
local tonumber          = _G.tonumber;
local TN                = function(string) return tonumber(string) or nil; end;
local C_Spell           = C_Spell;
-- Default values for the option


function D:GetDefaultsSettings()
    local DS = DC.DS;
    local DSI = DC.DSI;

    return {
        -- default settings {{{
        class = {
            -- Curring order (1 is the most important, 7 the lesser...)
            CureOrder = {
                [DC.MAGIC]      = 1,
                [DC.CURSE]      = 2,
                [DC.POISON]     = 3,
                [DC.DISEASE]    = 4,
                [DC.ENEMYMAGIC] = 5,
                [DC.CHARMED]    = 6,
                [DC.BLEED]      = 7,
            },

            UserSpells = {
                --Exemple / defaults
                [T._C.DSI["SPELL_COUNTERSPELL"]] = {
                    Types = {DC.CHARMED},
                    Better = 10,
                    Pet = false,
                    Disabled = true,
                    IsDefault = true,
                    IsItem = false,
                },
            },
        },
        locale = {
            BleedEffectsKeywords = D:GetDefaultBleedEffectsKeywords(),
        },
        global = {
            SRTLerrors = {
                ["total"] = 0
                -- "file:line" = {date, ...}
            },
            debug = false,
            NonRelease = false,
            TocExpiredDetection = false,
            LastExpirationAlert = 0,
            NewerVersionDetected = D.VersionTimeStamp,
            NewerVersionName = false,
            NewerVersionAlert = 0,
            NewVersionsBugMeNot = false,
            LastVersionAnnounce = 0,
            LastUnpackagedAlert = 0,

            -- the key to bind the macro to
            MacroBind = false,
            NoStartMessages = false,

            MouseButtons = {
                "*%s1", -- left mouse button
                "*%s2", -- right mouse button
                "ctrl-%s1",
                "ctrl-%s2",
                "shift-%s1",
                "shift-%s2",
                "shift-%s3",
                "alt-%s1",
                "alt-%s2",
                "alt-%s3",
                "*%s4",
                "ctrl-%s4",
                "shift-%s4",
                "alt-%s4",
                "*%s5",
                "ctrl-%s5",
                "shift-%s5",
                "alt-%s5",
                "*%s3",       -- the last two entries are always target and focus
                "ctrl-%s3",
            },
            BleedAutoDetection = true,
            t_BleedEffectsIDCheck = {
                [396007] = true, -- Vicious Peck
                [396093] = true, -- Savage Leap
                [193092] = true, -- Bloodletting Sweep
                [375937] = true, -- Rending Strike
                [376997] = true, -- Savage Peck
                [381683] = true, -- Swift Stab
                [388911] = true, -- Severing Slash
                [371005] = true, -- arcane but dispellable with cauterizing flame
                [384134] = true, -- Pierce
                [394628] = true, -- Peck
                [372860] = true, -- Searing Wounds
                [393444] = true, -- Gushing Wound
                [413131] = true, -- Whirling Dagger
                [413136] = true, -- Whirling Dagger
            },
            -- The time between each MUF update
            DebuffsFrameRefreshRate = 0.10,

            -- The number of MUFs updated every DebuffsFrameRefreshRate
            DebuffsFramePerUPdate = 10,

            MFScanEverybodyTimer = 1,
            MFScanEverybodyReport = false,
            --[=[@alpha@
            -- MFScanEverybodyReport = true, -- UNdebuff is triggered very often, not sure when. No more need for reporting though.
            --@end-alpha@]=]

            delayedDebuffOccurences = 0,
            delayedUnDebuffOccurences = 0,

        },

        profile = {
            -- this is the priority list of people to cure
            PriorityList = { },
            PriorityListClass = { },
            PrioGUIDtoNAME = { },

            -- this is the people to skip
            SkipList = { },
            SkipListClass = { },
            SkipGUIDtoNAME = { },

            -- The micro units debuffs frame
            ShowDebuffsFrame = true,

            -- Setting to hide the MUF handle (render it mouse-non-interactive)
            HideMUFsHandle = false,

            AutoHideMUFs = 1,

            -- The maximum number of MUFs to be displayed
            DebuffsFrameMaxCount = 80,

            DebuffsFrameElemScale = 1,

            DebuffsFrameElemAlpha = .35,

            DebuffsFrameElemBorderShow = true,

            DebuffsFrameElemBorderAlpha = .2,

            DebuffsFrameElemTieTransparency = true,

            DebuffsFramePerline = 10,

            DebuffsFrameTieSpacing = true,

            DebuffsFrameXSpacing = 3,

            DebuffsFrameYSpacing = 3,

            DebuffsFrameStickToRight = false,

            DebuffsFrameShowHelp = true,

            -- position x save
            DebuffsFrameContainer_x = false,

            -- position y save
            DebuffsFrameContainer_y = false,

            -- reverse MUFs disaplay
            DebuffsFrameGrowToTop = false,

            DebuffsFrameVerticalDisplay = false,

            -- Center text displayed on MUFs, defaults to time left
            CenterTextDisplay = '1_TLEFT',

            -- this is wether or not to show the live-list
            HideLiveList = false,

            LiveListAlpha = 0.7,

            LiveListScale = 1.0,

            -- position of the "Decursive" main bar, the live-list is anchored to this bar.
            MainBarX = false,

            MainBarY = false,

            -- This will turn on and off the sending of messages to the default chat frame
            Print_ChatFrame = true,

            -- this will send the messages to a custom frame that is moveable
            Print_CustomFrame = true,

            -- this will disable error messages
            Print_Error = true,

            -- should we scan pets
            Scan_Pets = true,

            -- should we ignore stealthed units? A useless option since a very long time.
            Ingore_Stealthed = false,

            Show_Stealthed_Status = true,

            -- how many to show in the livelist
            Amount_Of_Afflicted = 3,

            -- The live-list will only display units in range of your curring spell
            LV_OnlyInRange = true,

            -- how many seconds to "black list" someone with a failed spell
            CureBlacklist = 5.0,

            -- how often to poll for afflictions in seconds (for the live-list only)
            ScanTime = 0.3,

            -- Are prio list members protected from blacklisting?
            DoNot_Blacklist_Prio_List = false,

            -- Play a sound when there is something to decurse
            PlaySound = true,

            -- The sound file to use
            SoundFile = DC.AfflictionSound,

            -- Hide the buttons
            HideButtons = false,

            -- Display text above in the custom frame
            CustomeFrameInsertBottom = false,

            -- Disable tooltips in affliction list
            AfflictionTooltips = true,

            -- Reverse LiveList Display
            ReverseLiveDisplay = false,

            -- Hide the "Decursive" bar
            BarHidden = true,

            -- if true then the live list will show only if the "Decursive" bar is shown
            LiveListTied = false,

            -- allow to changes the default output window
            OutputWindow = "DEFAULT_CHAT_FRAME", -- ACEDB CRASHES if we set it directly


            MiniMapIcon = {hide=true},

            -- Display a warning if no key is mapped.
            NoKeyWarn = false,

            -- Disable macro creation
            DisableMacroCreation = false,

            -- Allow Decursive's macro editing
            AllowMacroEdit = false,

            -- Those are the different colors used for the MUFs main textures
            MF_colors = {
                [1]                 =   {  .8 , 0   , 0    ,  1     }, -- red
                [2]                 =   {  .3 ,  .3 ,  .8  ,  1     }, -- blue
                [3]                 =   {  .8 ,  .5 ,  .25 ,  1     }, -- orange
                [4]                 =   { 1   , 0   , 1    ,  1     }, -- purple
                [5]                 =   { 1   , 1   , 1    ,  1     }, -- white for undefined
                [6]                 =   { 1   , 1   , 1    ,  1     }, -- white for undefined
                [7]                 =   { 1   , 1   , 1    ,  1     }, -- white for undefined
                [DC.NORMAL]         =   {  .0 ,  .3 ,  .1  ,   .9   }, -- dark green
                [DC.BLACKLISTED]    =   { 0   , 0   , 0    ,  1     }, -- black
                [DC.ABSENT]         =   {  .4 ,  .4 ,  .4  ,   .9   }, -- transparent grey
                [DC.FAR]            =   {  .4 ,  .1 ,  .4  ,   .85  }, -- transparent purple
                [DC.STEALTHED]      =   {  .4 ,  .6 ,  .4  ,  1     }, -- pale green
                [DC.CHARMED_STATUS] =   { 0   , 1   , 0    ,  1     }, -- full green
                ["COLORCHRONOS"]    =   { 0.6 , 0.1 , 0.2  ,   .6   }, -- medium red
            },

            TypeColors = {
                [DC.MAGIC]      = "FF1887DD",
                [DC.ENEMYMAGIC] = "FF98F9FF",
                [DC.CURSE]      = "FFDD22DD",
                [DC.POISON]     = "FF22DD22",
                [DC.DISEASE]    = "FF995533",
                [DC.CHARMED]    = "FFFF0000",
                [DC.BLEED]      = "FFC0B0B0",
                [DC.NOTYPE]     = "FFAAAAAA",
            },

            -- Debuffs {{{
            -- those debuffs prevent us from curing the unit
            DebuffsToIgnore = {
                [DS["Banish"]]                  = true,
                [DS["Frost Trap Aura"]]         = true,
            },

            -- thoses debuffs are in fact buffs...
            BuffDebuff = {
                [DS["DREAMLESSSLEEP"]]          = true,
                [DS["GDREAMLESSSLEEP"]]         = true,
                [(not DC.WOWC) and DS["MDREAMLESSSLEEP"] or "NONE"]         = (not DC.WOWC) and true or nil,
                [DS["DCR_LOC_MINDVISION"]]      = true,
                [(not DC.WOWC) and DS["Arcane Blast"] or "NONE"]            = (not DC.WOWC) and true or nil,
            },

            DebuffAlwaysSkipList = {
            },
            DebuffsSkipList = {
                [DS["ANCIENTHYSTERIA"]] =
                DSI["ANCIENTHYSTERIA"],
                [DS["CRIPLES"]]         =
                DSI["CRIPLES"],
                [DS["DELUSIONOFJINDO"]] =
                DSI["DELUSIONOFJINDO"],
                [DS["DUSTCLOUD"]]       =
                DSI["DUSTCLOUD"],
                [DS["IGNITE"]]          =
                DSI["IGNITE"],
                [DS["MAGMASHAKLES"]]    =
                DSI["MAGMASHAKLES"],
                [DS["DCR_LOC_SILENCE"]] =
                DSI["DCR_LOC_SILENCE"],
                [DS["SONICBURST"]]      =
                DSI["SONICBURST"],
                [DS["TAINTEDMIND"]]     =
                DSI["TAINTEDMIND"],
                [DS["WIDOWSEMBRACE"]]   =
                DSI["WIDOWSEMBRACE"],
            },

            skipByClass = {
                ["WARRIOR"] = {
                    [DS["ANCIENTHYSTERIA"]]     = true,
                    [DS["IGNITE"]]              = true,
                    [DS["TAINTEDMIND"]]         = true,
                    [DS["WIDOWSEMBRACE"]]       = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["ROGUE"] = {
                    [DS["DCR_LOC_SILENCE"]]     = true,
                    [DS["ANCIENTHYSTERIA"]]     = true,
                    [DS["IGNITE"]]              = true,
                    [DS["TAINTEDMIND"]]         = true,
                    [DS["WIDOWSEMBRACE"]]       = true,
                    [DS["SONICBURST"]]          = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["HUNTER"] = {
                    [DS["MAGMASHAKLES"]]        = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["MAGE"] = {
                    [DS["MAGMASHAKLES"]]        = true,
                    [DS["CRIPLES"]]             = true,
                    [DS["DUSTCLOUD"]]           = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["WARLOCK"] = {
                    [DS["CRIPLES"]]             = true,
                    [DS["DUSTCLOUD"]]           = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["DRUID"] = {
                    [DS["CRIPLES"]]             = true,
                    [DS["DUSTCLOUD"]]           = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["PALADIN"] = {
                    [DS["CRIPLES"]]             = true,
                    [DS["DUSTCLOUD"]]           = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["PRIEST"] = {
                    [DS["CRIPLES"]]             = true,
                    [DS["DUSTCLOUD"]]           = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["SHAMAN"] = {
                    [DS["CRIPLES"]]             = true,
                    [DS["DUSTCLOUD"]]           = true,
                    [DS["DELUSIONOFJINDO"]]     = true,
                },
                ["DEATHKNIGHT"] = {
                },
                ["MONK"] = {
                },
                ["DEMONHUNTER"] = {
                },
                ["EVOKER"] = {
                }
            },
            -- }}}




        }
    } -- }}}
end

local OptionsPostSetActions = { -- {{{
    ["debug"] = function(v)  D.debug = v end,
    ["HideMUFsHandle"] = function(v) D.MFContainerHandle:EnableMouse(not v); D:Print(v and "MUFs handle disabled" or "MUFs handle enabled"); end,
    ["AfflictionTooltips"] = function(v) for id,lvitem in ipairs(D.LiveList.ExistingPerID) do lvitem.Frame:EnableMouse(v); end end,
    ["Amount_Of_Afflicted"] = function(v) D.LiveList:RestAllPosition(); end,
    ["ScanTime"] = function(v) D:ScheduleRepeatedCall("Dcr_LLupdate", D.LiveList.Update_Display, v, D.LiveList); D:Debug("LV scan delay changed:", v); end,
    ["ReverseLiveDisplay"] = function(v) D.LiveList:RestAllPosition(); end,
    ["LiveListScale"] = function(v) D:SetLLScale(v); end,
    ["AutoHideMUFs"] = function(v) D:AutoHideShowMUFs(); end,
    ["DebuffsFrameGrowToTop"] = function(v) D.MicroUnitF:SavePos(); D.MicroUnitF:ResetAllPositions (); end,
    ["DebuffsFrameStickToRight"] = function(v) D.MicroUnitF:SavePos(); D.MicroUnitF:ResetAllPositions (); end,
    ["DebuffsFrameVerticalDisplay"] = function(v) D.MicroUnitF:ResetAllPositions (); end,
    ["DebuffsFrameMaxCount"] = function(v) D.MicroUnitF.MaxUnit = v; D.MicroUnitF:Delayed_MFsDisplay_Update(); end, -- just the number of MUFs is changed MFsDisplay_Update() is enough
    ["DebuffsFramePerline"] = function(v)  D.MicroUnitF:ResetAllPositions (); end,
    ["DebuffsFrameElemScale"] = function(v) D.MicroUnitF:SetScale(D.profile.DebuffsFrameElemScale); end,
    ["DebuffsFrameRefreshRate"] = function(v) D:ScheduleRepeatedCall("Dcr_MUFupdate", D.DebuffsFrame_Update, D.db.global.DebuffsFrameRefreshRate, D); D:Debug("MUFs refresh rate changed:", D.db.global.DebuffsFrameRefreshRate, v); end,
    ["MFScanEverybodyTimer"] = function(v)
        if v > 0 then
            D:ScheduleRepeatedCall("Dcr_ScanEverybody", D.ScanEveryBody, D.db.global.MFScanEverybodyTimer, D);
            D:Debug("MUFs scan every body timer changed:", D.db.global.MFScanEverybodyTimer, v);
        else
            D:CancelDelayedCall("Dcr_ScanEverybody")
            D:Debug("MUFs scan every body canceled", D.db.global.MFScanEverybodyTimer, v);
        end
    end,
    ["MFScanEverybodyReport"] = function(v)
        if D.db.global.MFScanEverybodyTimer > 0 then
            D:ScheduleRepeatedCall("Dcr_ScanEverybody", D.ScanEveryBody, D.db.global.MFScanEverybodyTimer, D);
        end
        D:Debug("MUFs scan every body reporting changed:", D.db.global.MFScanEverybodyReport, v);
    end,

    ["Scan_Pets"] = function(v) D:GroupChanged ("opt CURE_PETS"); end,
    ["DisableMacroCreation"] = function(v) if v then D:SetMacroKey (nil); D:Debug("SetMacroKey (nil)"); end end,
} -- }}}

function D.GetHandler (info, value) -- {{{
    local source = D.db.global;

    if D.db.profile[info[#info]]~=nil then

        source = D.db.profile;

    elseif D.db.class[info[#info]]~=nil then

        source = D.db.class;

    end

    return source[info[#info]];

end -- }}}
-- Used in Ace3 option table to get feedback when setting options through command line
function D.SetHandler (info, value) -- {{{


    local target = D.db.global;

    if D.db.profile[info[#info]]~=nil then

        target = D.db.profile;

    elseif D.db.class[info[#info]]~=nil then

        target = D.db.class;

    end

    target[info[#info]] = value;

    if OptionsPostSetActions[info[#info]] then
        OptionsPostSetActions[info[#info]](value);
        D:Debug("PostAction executed");
    end

    if info["uiType"] == "cmd" then

        if value == true then
            value = L["OPT_CMD_ENABLED"];
        elseif value == false then
            value = L["OPT_CMD_DISBLED"];
        end

        D:Print(D:ColorText(D:GetOPtionPath(info), "FF00DD00"), "=>", D:ColorText(value, "FF3399EE"));
    end
end -- }}}

local CombatWarning = {
    type = "description",
    name = D:ColorText(L["OPT_OPTIONS_DISABLED_WHILE_IN_COMBAT"], "FFFF0000"),
    order = 0,
    disabled = false,
    hidden = function() return not D.Status.Combat end,
};

local SpellAssignmentsTexts = {};
local CustomSpellMacroEditingAllowed = false;
local function GetStaticOptions ()

    local function validateSpellInput(info, v)  -- {{{

        D:Debug("Validating spell id", v);
        local error = function (m) D:ColorPrint(1, 0, 0, m); return m; end;

        local isItem = nil;
        local isPetAbility = nil;

        -- We got a spell ID directly
        if tonumber(v) then
            v = tonumber(v);
            -- test if it's valid
            if not GetSpellName(v) and not (GetItemInfo(v)) then
                return error(L["OPT_INPUT_SPELL_BAD_INPUT_ID"]);
            end

            isItem = not GetSpellName(v);

        elseif D:GetSpellFromLink(v) then
            -- We got a spell link!
            v, isPetAbility = D:GetSpellFromLink(v);
        elseif D:GetItemFromLink(v) then
            -- We got a item link!
            isItem = true;
            v = D:GetItemFromLink(v);
        elseif type(v) == 'string' and (D:GetSpellUsefulInfoIfKnown(v)) then -- not a number, not a spell link, then a spell name?
            -- We got a spell name!
            D:Debug(v, "is a spell name in our book:", D:GetSpellUsefulInfoIfKnown(v));
            local id, isPet = D:GetSpellUsefulInfoIfKnown(v);
            v = id;
            isPetAbility = isPet;
        elseif type(v) == 'string' and (GetItemInfo(v)) then
            D:Debug(v, "is a item name:", GetItemInfo(v));
            -- We got an item name!
            isItem = true;
            v = D:GetItemFromLink(select(2, GetItemInfo(v)));
        else
            return error(L["OPT_INPUT_SPELL_BAD_INPUT_NOT_SPELL"]);
        end

        if not isItem and v > 0xfffff then
            v = bit.band(0xfffff, v);
        end

        -- avoid spellID/itemID collisions
        if isItem then
            v = -1 * v;
        end

        -- It's a deleted default spell
        if D.classprofile.UserSpells[v] and not D.classprofile.UserSpells[v].Hidden then
            D:Debug(v);
            return error(L["OPT_INPUT_SPELL_BAD_INPUT_ALREADY_HERE"]);
        end

        -- The spell is part of the default set and the user doesn't want to change the macro
        if DC.SpellsToUse[v] and not CustomSpellMacroEditingAllowed then
            return error(L["OPT_INPUT_SPELL_BAD_INPUT_DEFAULT_SPELL"]);
        end

        return 0, v, isItem, isPetAbility;
    end -- }}}

    return {
        -- {{{
        type = "group",
        name = L["Decursive"],

        get = D.GetHandler,
        set = D.SetHandler,
        hidden = function () return not D:IsEnabled(); end,
        disabled = function () return not D:IsEnabled(); end,
        args = {
            -- Command line only {{{
            -- enable and disable
            enable = {
                type = 'toggle',
                name = L["OPT_ENABLEDECURSIVE"],
                hidden = function() return D:IsEnabled(); end,
                disabled = function() return D:IsEnabled(); end,
                set = function() D.Status.Enabled = D:Enable(); return D.Status.Enabled; end,
                get = function() return D:IsEnabled(); end,
                order = -2,
            },
            disable = {
                type = 'toggle',
                guiHidden  = true,
                disabled = function() return not D:IsEnabled(); end,
                name = 'disable',
                set = function() D.Status.Enabled = not D:Disable(); return not D.Status.Enabled; end,
                get = function() return not D:IsEnabled(); end,
                order = -3,
            },
            HideMUFsHandle = {
                type = 'toggle',
                name = L["OPT_HIDEMUFSHANDLE"],
                desc = L["OPT_HIDEMUFSHANDLE_DESC"],
                guiHidden = D.profile and not D.profile.HideMUFsHandle,
                disabled = function() return not D:IsEnabled() or not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1; end,
                get = function(info) return not D.MFContainerHandle:IsMouseEnabled(); end,
                order = -4,
            },
            debug = {
                type = "toggle",
                guiHidden = not D.debug,
                name = L["OPT_ENABLEDEBUG"],
                desc = L["OPT_ENABLEDEBUG_DESC"],
                order = -5,
            },
            -- Atticus Ross rules!
            -- }}}

            general = {
                -- {{{
                type = 'group',
                name = L["OPT_GENERAL"],
                order = 0,
                icon = DC.IconON,
                args = {
                    version = {
                        type = 'description',
                        name = D.version,
                        image = DC.IconON,
                        order = 0,
                    },
                    newVersion = {
                        type = 'description',
                        name = "|cFFEE0022" .. (L["NEW_VERSION_ALERT"]):format(D.db.global.NewerVersionName or "none", date("%Y-%m-%d", D.db.global.NewerVersionDetected)) .. "|r",
                        hidden = function() return not D.db.global.NewerVersionName end,
                        order = 2,
                    },
                    ShowDebuffsFrame = {
                        type = "toggle",
                        name = L["OPT_SHOWMFS"],
                        desc = L["OPT_SHOWMFS_DESC"],
                        set = function()
                            D:ShowHideDebuffsFrame ();
                            if D.profile.AutoHideMUFs ~= 1 then
                                D.profile.AutoHideMUFs = 1;
                                D:ColorPrint(1, 0, 0, L["OPT_AUTOHIDEMFS"] .. " -> " .. L["OPT_HIDEMFS_NEVER"]);
                            end
                        end,
                        disabled = function() return D.Status.Combat end,
                        order = 5,
                    },
                    AutoHideMUFs = {
                        type = "select",
                        style = "dropdown",
                        name = L["OPT_AUTOHIDEMFS"],
                        desc = L["OPT_AUTOHIDEMFS_DESC"] .. "\n\n" .. ("%s: %s\n%s: %s\n%s: %s\n%s: %s"):format(
                            D:ColorText(L["OPT_HIDEMFS_NEVER"], "FF88CCAA"), L["OPT_HIDEMFS_NEVER_DESC"]
                            , D:ColorText(L["OPT_HIDEMFS_SOLO"], "FF88CCAA"), L["OPT_HIDEMFS_SOLO_DESC"]
                            , D:ColorText(L["OPT_HIDEMFS_GROUP"], "FF88CCAA"), L["OPT_HIDEMFS_GROUP_DESC"]
                            , D:ColorText(L["OPT_HIDEMFS_RAID"], "FF88CCAA"), L["OPT_HIDEMFS_RAID_DESC"]),
                        values = {L["OPT_HIDEMFS_NEVER"], L["OPT_HIDEMFS_SOLO"], L["OPT_HIDEMFS_GROUP"], L["OPT_HIDEMFS_RAID"]},
                        order = 6,
                    },
                    HideLiveList = {
                        type = "toggle",
                        name = L["OPT_ENABLE_LIVELIST"],
                        desc = L["OPT_ENABLE_LIVELIST_DESC"],
                        set = function()
                            D:ShowHideLiveList()
                            if D.profile.HideLiveList and not D.profile.ShowDebuffsFrame or not D.Status.HasSpell then
                                D:SetIcon(DC.IconOFF);
                            else
                                D:SetIcon(DC.IconON);
                            end
                        end,
                        get = function () return not D.profile.HideLiveList end,
                        order = 7,
                    },
                    PlaySound = {
                        type = "toggle",
                        disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1 or not D:IsEnabled(); end,
                        name = L["PLAY_SOUND"],
                        desc = L["OPT_PLAYSOUND_DESC"],

                        order = 10,
                    },
                    AfflictionTooltips = {
                        type = "toggle",
                        disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1 or not D:IsEnabled(); end,
                        name = L["SHOW_TOOLTIP"],
                        desc = L["OPT_SHOWTOOLTIP_DESC"],
                        order = 20,
                    },
                    minimap = {
                        type = "toggle",
                        name = L["OPT_SHOWMINIMAPICON"],
                        desc = L["OPT_SHOWMINIMAPICON_DESC"],
                        get = function() return not D.profile.MiniMapIcon or not D.profile.MiniMapIcon.hide end,
                        set = function(info,v)
                            local hide = not v;
                            D.profile.MiniMapIcon.hide = hide;
                            if hide then
                                icon:Hide("Decursive");
                            else
                                icon:Show("Decursive");
                            end
                        end,
                        order = 30,
                    },
                    CureBlacklist = {
                        type = 'range',
                        name = L["BLACK_LENGTH"],
                        desc = L["OPT_BLACKLENTGH_DESC"],
                        min = 0,
                        max = 20,
                        step = 0.1,
                        order = 40,
                    },
                    SysOps = {
                        type = 'header',
                        name = "",
                        order = 50
                    },
                    TestItemDisplayed = {
                        type = "toggle",
                        name = L["OPT_CREATE_VIRTUAL_DEBUFF"],
                        desc = L["OPT_CREATE_VIRTUAL_DEBUFF_DESC"],
                        get = function() return  D.LiveList.TestItemDisplayed end,
                        set = function()
                            if not D.LiveList.TestItemDisplayed then
                                D.LiveList:DisplayTestItem();
                            else
                                D.LiveList:HideTestItem();
                            end
                        end,
                        disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame or not D.Status.HasSpell or not D.Status.Enabled end,
                        order = 60
                    },
                    NoStartMessages = {
                        type = "toggle",
                        name = L["OPT_NOSTARTMESSAGES"],
                        desc = L["OPT_NOSTARTMESSAGES_DESC"],
                        order = 70
                    },
                    NewerVersionAlerts ={
                        type = "toggle",
                        name = L["OPT_NEWVERSIONBUGMENOT"],
                        desc = L["OPT_NEWVERSIONBUGMENOT_DESC"],
                        get = function() return not D.db.global.NewVersionsBugMeNot end,
                        set = function(info,v)
                            D.db.global.NewVersionsBugMeNot = v == false and D.VersionTimeStamp or false;
                        end,
                        order = 75
                    },
                    report = {
                        type = "execute",
                        name = D:ColorText(L["DECURSIVE_DEBUG_REPORT_SHOW"], "FFFF0000"),
                        desc = L["DECURSIVE_DEBUG_REPORT_SHOW_DESC"],
                        func = function ()
                            LibStub("AceConfigDialog-3.0"):Close(D.name);
                            if GameTooltip:IsShown() then GameTooltip:Hide(); end
                            T._ShowDebugReport();
                        end,
                        hidden = function() return  #T._DebugTextTable < 1 end,
                        order = 1000
                    },

                    GlorfindalMemorium = {
                        type = "execute",
                        name = D:ColorText(L["GLOR1"], "FF" .. D:GetClassHexColor( "WARRIOR" )),
                        desc = L["GLOR2"],
                        width = 'double',
                        func = function ()

                        -- {{{
                            LibStub("AceConfigDialog-3.0"):Close(D.name);
                            if GameTooltip:IsShown() then GameTooltip:Hide(); end
                            if not D.MemoriumFrame then
                                D.MemoriumFrame = CreateFrame("Frame", nil, UIParent);
                                local f = D.MemoriumFrame;
                                local w = 512; local h = 390;

                                f:SetFrameStrata("TOOLTIP");
                                f:EnableKeyboard(true);
                                f:SetScript("OnKeyUp", function (frame, event, arg1, arg2) D.MemoriumFrame:Hide(); end);
                                --[[
                                f:SetScript("OnShow",
                                function ()
                                -- I wanted to make the shadow to move over the marble very slowly as clouds
                                -- I tried to make it rotate but the way I found would only make it rotate around its origin (which is rarely useful)
                                -- so leaving it staedy for now... if someone got an idea, let me know.
                                D:ScheduleRepeatingEvent("Dcr_GlorMoveShadow",
                                function (f)
                                local cos, sin = math.cos, math.sin;
                                f.Shadow.Angle = f.Shadow.Angle + 1;
                                if f.Shadow.Angle == 360 then f.Shadow.Angle = 0; end
                                local angle = math.rad(f.Shadow.Angle);
                                D:SetCoords(f.Shadow, cos(angle), sin(angle), 0, -sin(angle), cos(angle), 0);

                                end
                                , 1/50, f);
                                end);
                                f:SetScript("OnHide", function() D:CancelDelayedCall("Dcr_GlorMoveShadow"); end)
                                --]]

                                f:SetWidth(w);
                                f:SetHeight(h);
                                f.tTL = f:CreateTexture(nil,"BACKGROUND")
                                f.tTL:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-TopLeft")
                                f.tTL:SetWidth(w - w / 5);
                                f.tTL:SetHeight(h - h / 3);
                                f.tTL:SetTexCoord(0, 1, 5/256, 1);
                                f.tTL:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -10);

                                f.tTR = f:CreateTexture(nil,"BACKGROUND")
                                f.tTR:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-TopRight")
                                f.tTR:SetWidth(w / 5 - 3);
                                f.tTR:SetHeight(h - h / 3);
                                f.tTR:SetTexCoord(0, 1, 5/256, 1);
                                f.tTR:SetPoint("TOPLEFT", f.tTL, "TOPRIGHT", 0, 0);

                                f.tBL = f:CreateTexture(nil,"BACKGROUND")
                                f.tBL:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-BotLeft")
                                f.tBL:SetWidth(w - w / 5);
                                f.tBL:SetHeight(h / 3 - 20);
                                f.tBL:SetTexCoord(0,1,0, 408/512);
                                f.tBL:SetPoint("TOPLEFT", f.tTL, "BOTTOMLEFT", 0, 0);

                                f.tBR = f:CreateTexture(nil,"BACKGROUND")
                                f.tBR:SetTexture("Interface\\ItemTextFrame\\ItemText-Marble-BotRight")
                                f.tBR:SetWidth(w / 5 - 3);
                                f.tBR:SetHeight(h / 3 - 20);
                                f.tBR:SetTexCoord(0,1,0, 408/512);
                                f.tBR:SetPoint("TOPLEFT", f.tBL, "TOPRIGHT", 0, 0);

                                f.Shadow = f:CreateTexture(nil, "ARTWORK");
                                f.Shadow:SetTexture("Interface\\TabardFrame\\TabardFrameBackground")
                                f.Shadow:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -9);
                                f.Shadow:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 9);
                                f.Shadow:SetAlpha(0.1);

                                ---[[
                                f.fB = f:CreateTexture(nil,"OVERLAY")
                                f.fB:SetTexture("Interface\\AddOns\\Decursive\\Textures\\GoldBorder")
                                f.fB:SetTexCoord(5/512, 324/512, 6/512, 287/512);
                                f.fB:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
                                f.fB:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
                                --]]

                                f.FSt = f:CreateFontString(nil,"OVERLAY", "MailTextFontNormal");
                                f.FSt:SetFont(STANDARD_TEXT_FONT, 18 );
                                f.FSt:SetTextColor(0.18, 0.12, 0.06, 1);
                                f.FSt:SetPoint("TOPLEFT", f.tTL, "TOPLEFT", 5, -20);
                                f.FSt:SetPoint("TOPRIGHT", f.tTR, "TOPRIGHT", -5, -20);
                                f.FSt:SetJustifyH("CENTER");
                                f.FSt:SetText(L["GLOR3"]);
                                f.FSt:SetAlpha(0.80);

                                f.FSc = f:CreateFontString(nil,"OVERLAY", "MailTextFontNormal");
                                f.FSc:SetFont(STANDARD_TEXT_FONT, 15 );
                                f.FSc:SetTextColor(0.18, 0.12, 0.06, 1);
                                f.FSc:SetHeight(h - 30 - 60);
                                f.FSc:SetPoint("TOP", f.FSt, "BOTTOM", 0, -28);
                                f.FSc:SetPoint("LEFT", f.tTL, "LEFT", 30, 0);
                                f.FSc:SetPoint("RIGHT", f.tTR, "RIGHT", -30, 0);
                                f.FSc:SetJustifyH("CENTER");
                                f.FSc:SetJustifyV("TOP");
                                f.FSc:SetSpacing(5);

                                f.FSc:SetText(L["GLOR4"]);


                                f.FSc:SetAlpha(0.80);

                                f.FSl = f:CreateFontString(nil,"OVERLAY", "MailTextFontNormal");
                                f.FSl:SetFont(STANDARD_TEXT_FONT, 15 );
                                f.FSl:SetTextColor(0.18, 0.12, 0.06, 1);
                                f.FSl:SetJustifyH("LEFT");
                                f.FSl:SetJustifyV("BOTTOM");
                                f.FSl:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 30, 33);
                                f.FSl:SetAlpha(0.80);
                                f.FSl:SetText(L["GLOR5"]);

                                f:SetPoint("CENTER",0,0);

                            end
                            D.MemoriumFrame:Show();

                            --[[

                            In remembrance of Bertrand Sense
                            1969 - 2007


                            Friendship and affection can take their roots anywhere, those
                            who met Glorfindal in World of Warcraft knew a man of great
                            commitment and a charismatic leader.

                            He was in life as he was in game, selfless, generous, dedicated
                            to his friends and most of all, a passionate man.

                            He left us at the age of 38 leaving behind him not just
                            anonymous players in a virtual world, but a group of true
                            friends who will miss him forever.

                            He will always be remembered...

                            --

                            En souvenir de Bertrand Sense
                            1969 - 2007

                            L'amitié et l'affection peuvent prendre naissance n'importe où,
                            ceux qui ont rencontré Glorfindal dans World Of Warcraft on
                            connu un homme engagé et un leader charismatique.

                            Il était dans la vie comme dans le jeux, désintéressé,
                            généreux, dévoué envers les siens et surtout un homme passionné.

                            Il nous a quitté à l'âge de 38 ans laissant derrière lui pas
                            seulement des joueurs anonymes dans un monde virtuel, mais un
                            groupe de véritables amis à qui il manquera eternellement.

                            On ne l'oubliera jamais...

                            --]]
                            -- }}}
                        end,
                        order = 100,
                    },
                }
            }, -- }}}

            livelistoptions = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_LIVELIST"], "FF22EE33"),
                desc = L["OPT_LIVELIST_DESC"] .. "\n",
                hidden = function () return not D:IsEnabled(); end,
                disabled = function () return not D:IsEnabled(); end,
                handler = {
                    ["disabled"] = function() return D.profile.HideLiveList; end,
                },
                order = 10,

                args = {
                    description = {
                        type = "description",
                        name = L["OPT_LIVELIST_DESC"],
                        order = 0,
                    },
                    TestItemDisplayed = {
                        type = "toggle",
                        name = L["OPT_CREATE_VIRTUAL_DEBUFF"],
                        desc = L["OPT_CREATE_VIRTUAL_DEBUFF_DESC"],
                        get = function() return  D.LiveList.TestItemDisplayed end,
                        set = function()
                            if not D.LiveList.TestItemDisplayed then
                                D.LiveList:DisplayTestItem();
                            else
                                D.LiveList:HideTestItem();
                            end
                        end,
                        disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame or not D.Status.HasSpell or not D.Status.Enabled end,
                        order = -1
                    },
                    LV_OnlyInRange = {
                        type = "toggle",
                        name = L["OPT_LVONLYINRANGE"],
                        desc = L["OPT_LVONLYINRANGE_DESC"],
                        disabled = "disabled",
                        order = 100
                    },
                    Amount_Of_Afflicted = {
                        type = 'range',
                        name = L["AMOUNT_AFFLIC"],
                        desc = L["OPT_AMOUNT_AFFLIC_DESC"],
                        min = 1,
                        max = D.CONF.MAX_LIVE_SLOTS,
                        step = 1,
                        disabled = "disabled",
                        order = 104,
                    },
                    ScanTime = {
                        type = 'range',
                        name = L["SCAN_LENGTH"],
                        desc = L["OPT_SCANLENGTH_DESC"],
                        min = 0.1,
                        max = 1,
                        step = 0.1,
                        disabled = "disabled",
                        order = 106,
                    },
                    ReverseLiveDisplay = {
                        type = "toggle",
                        name = L["REVERSE_LIVELIST"],
                        desc = L["OPT_REVERSE_LIVELIST_DESC"],
                        disabled = "disabled",
                        order = 107
                    },
                    LiveListScale = {
                        type = 'range',
                        disabled = function() return D.profile.HideLiveList or D.profile.BarHidden end,
                        name = L["OPT_LLSCALE"],
                        desc = L["OPT_LLSCALE_DESC"],
                        min = 0.3,
                        max = 4,
                        step = 0.01,
                        isPercent = true,
                        order = 1009,
                    },
                    AlphaLL = {
                        type = 'range',
                        disabled = function() return D.profile.HideLiveList or D.profile.BarHidden end,
                        name = L["OPT_LLALPHA"],
                        desc = L["OPT_LLALPHA_DESC"],
                        get = function() return 1 - D.profile.LiveListAlpha end,
                        set = function(info,v)
                            if (v ~= D.profile.LiveListAlpha) then
                                D.profile.LiveListAlpha = 1 - v;
                                DecursiveMainBar:SetAlpha(D.profile.LiveListAlpha);
                                DcrLiveList:SetAlpha(D.profile.LiveListAlpha);
                            end
                        end,
                        min = 0,
                        max = 0.8,
                        step = 0.01,
                        isPercent = true,
                        order = 1010,
                    },
                },
            }, -- // }}}

            MessageOptions = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_MESSAGES"], "FF229966"),
                desc = L["OPT_MESSAGES_DESC"],
                order = 20,
                disabled = function() return  not D.Status.Enabled end,
                args = {
                    description = {name = L["OPT_MESSAGES_DESC"], order = 1, type = "description"},
                    Print_ChatFrame = {
                        type = "toggle",
                        width = 'full',
                        name =  L["PRINT_CHATFRAME"],
                        desc = L["OPT_CHATFRAME_DESC"],
                        order = 120
                    },
                    Print_CustomFrame = {
                        type = "toggle",
                        width = 'full',
                        name =  L["PRINT_CUSTOM"],
                        desc = L["OPT_PRINT_CUSTOM_DESC"],
                        order = 121
                    },
                    Print_Error = {
                        type = "toggle",
                        width = 'full',
                        name =  L["PRINT_ERRORS"],
                        desc =  L["OPT_PRINT_ERRORS_DESC"],
                        order = 122
                    },
                    ShowCustomFAnchor = {
                        type = "toggle",
                        width = 'full',
                        name =  L["ANCHOR"],
                        desc = L["OPT_ANCHOR_DESC"],
                        get = function() return DecursiveAnchor:IsVisible() end,
                        set = function()
                            D:ShowHideTextAnchor();
                        end,
                        order = 123
                    },
                }
            }, -- }}}

            MicroFrameOpt = {
                -- {{{
                type = "group",
                --childGroups = "tab",
                name = D:ColorText(L["OPT_MFSETTINGS"], "FFBBCC33"),
                desc = L["OPT_MFSETTINGS_DESC"],
                disabled = function () return not D:IsEnabled(); end,
                hidden = function () return not D:IsEnabled() end,
                order = 30,
                args = {
                    hint = {
                        type = 'description',
                        name = D:ColorText(L["OPT_MUFHANDLE_HINT"], "FF00EF00"),
                        order = 0,
                    },
                    displayOpts = {
                        type = "group",
                        inline = true,
                        name = L["OPT_DISPLAYOPTIONS"],
                        desc = L["OPT_MFSETTINGS_DESC"],
                        handler = {
                            ["disabled"] = function () return D.Status.Combat; end,
                        },
                        order = 1,
                        disabled = function () return not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1; end,
                        args = {
                            -- {{{
                            DebuffsFrameGrowToTop = {
                                type = "toggle",
                                name = L["OPT_GROWDIRECTION"],
                                desc = L["OPT_GROWDIRECTION_DESC"],
                                disabled = "disabled",
                                order = 1300,
                            },
                            DebuffsFrameStickToRight = {
                                type = "toggle",
                                name = L["OPT_STICKTORIGHT"],
                                desc = L["OPT_STICKTORIGHT_DESC"],
                                disabled = "disabled",
                                order = 1310,
                            },
                            DebuffsFrameVerticalDisplay = {
                                type = "toggle",
                                name = L["OPT_MUFSVERTICALDISPLAY"],
                                desc = L["OPT_MUFSVERTICALDISPLAY_DESC"],
                                disabled = "disabled",
                                order = 1315,
                            },
                            DebuffsFrameElemBorderShow = {
                                type = "toggle",
                                name = L["OPT_SHOWBORDER"],
                                desc = L["OPT_SHOWBORDER_DESC"],
                                order = 1350,
                            },
                            CenterTextDisplay = {
                                type = "select",
                                style = "dropdown",
                                name = L["OPT_CENTERTEXT"],
                                desc = L["OPT_CENTERTEXT_DESC"],
                                values = {["1_TLEFT"] = L["OPT_CENTERTEXT_TIMELEFT"], ["2_TELAPSED"] = L["OPT_CENTERTEXT_ELAPSED"], ["3_STACKS"] = L["OPT_CENTERTEXT_STACKS"], ["4_NONE"] = L["OPT_CENTERTEXT_DISABLED"]},
                                order = 1360,
                            },
                            Show_Stealthed_Status = {
                                type = "toggle",
                                name =  L["OPT_SHOW_STEALTH_STATUS"],
                                desc = L["OPT_SHOW_STEALTH_STATUS_DESC"],
                                order = 1370,
                                disabled = false,
                            },
                            AfflictionTooltips = {
                                type = "toggle",
                                name = L["SHOW_TOOLTIP"],
                                desc = L["OPT_SHOWTOOLTIP_DESC"],
                                disabled = function() return D.profile.HideLiveList and not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1 end,
                                order = 1400,
                            },
                            DebuffsFrameShowHelp = {
                                type = "toggle",
                                name = L["OPT_SHOWHELP"],
                                desc = L["OPT_SHOWHELP_DESC"],
                                disabled = false,
                                order = 1450,
                            },
                            DebuffsFrameMaxCount = {
                                type = 'range',
                                name = L["OPT_MAXMFS"],
                                desc = L["OPT_MAXMFS_DESC"],
                                min = 1,
                                max = 82,
                                step = 1,
                                disabled = "disabled",
                                order = 1500,
                            },
                            DebuffsFramePerline = {
                                type = 'range',
                                name = L["OPT_UNITPERLINES"],
                                desc = L["OPT_UNITPERLINES_DESC"],
                                min = 1,
                                max = 40,
                                step = 1,
                                disabled = "disabled",
                                order = 1600,
                            },
                            DebuffsFrameElemScale = {
                                type = 'range',
                                name = L["OPT_MFSCALE"],
                                desc = L["OPT_MFSCALE_DESC"],
                                min = 0.3,
                                max = 4,
                                step = 0.01,
                                isPercent = true,
                                disabled = "disabled",
                                order = 1800,
                            },
                            DebuffsFrameElemAlpha = {
                                type = 'range',
                                name = L["OPT_MFALPHA"],
                                desc = L["OPT_MFALPHA_DESC"],
                                get = function() return 1 - D.profile.DebuffsFrameElemAlpha end,
                                set = function(info,v)
                                    D.SetHandler(info, 1 - v);
                                    D.profile.DebuffsFrameElemBorderAlpha = (1 - v) / 2;
                                end,
                                disabled = function() return D.Status.Combat or not D.profile.DebuffsFrameElemTieTransparency end,
                                min = 0,
                                max = 1,
                                step = 0.01,
                                isPercent = true,
                                order = 1900,
                            },
                            TestLayout = {
                                type = "toggle",
                                name = L["OPT_TESTLAYOUT"],
                                desc = L["OPT_TESTLAYOUT_DESC"],
                                get = function() return D.Status.TestLayout end,
                                set = function(info,v)
                                    D.Status.TestLayout = v;
                                    D:GroupChanged("Test Layout");
                                end,
                                disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame end,
                                order = 1950,
                            },
                            TestLayoutUNum = {
                                type = 'range',
                                name = L["OPT_TESTLAYOUTUNUM"],
                                desc = L["OPT_TESTLAYOUTUNUM_DESC"],
                                get = function() return D.Status.TestLayoutUNum end,
                                set = function(info,v)
                                    D.Status.TestLayoutUNum = v;
                                    D:GroupChanged("Test Layout num changed");
                                end,
                                disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame or not D.Status.TestLayout end,
                                min = 1,
                                max = 82,
                                step = 1,
                                order = 2000,
                            },
                            -- }}}
                        },
                    },

                    AdvDispOptions = {
                        type = "group",
                        inline = true,
                        name = L["OPT_ADVDISP"],
                        desc = L["OPT_ADVDISP_DESC"],
                        order = 2,
                        disabled = function () return not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1; end,
                        args = {
                            -- {{{
                            TransparencyOpts = {
                                type = 'group',
                                inline = true,
                                order = 1,
                                name = " ",
                                args = {
                                    DebuffsFrameElemTieTransparency = {
                                        type = "toggle",
                                        name = L["OPT_TIECENTERANDBORDER"],
                                        desc = L["OPT_TIECENTERANDBORDER_OPT"],
                                        set = function(info,v)
                                            D.SetHandler(info,v);
                                            if v then
                                                D.profile.DebuffsFrameElemBorderAlpha = (D.profile.DebuffsFrameElemAlpha / 2);
                                            end
                                        end,
                                        order = 100
                                    },
                                    DebuffsFrameElemBorderAlpha = {
                                        type = 'range',
                                        name = L["OPT_BORDERTRANSP"],
                                        desc = L["OPT_BORDERTRANSP_DESC"],
                                        get = function() return 1 - D.profile.DebuffsFrameElemBorderAlpha end,
                                        set = function(info,v)
                                            D.SetHandler(info,1 - v);
                                        end,
                                        disabled = function() return D.profile.DebuffsFrameElemTieTransparency end,
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        isPercent = true,
                                        order = 102,
                                    },
                                    DebuffsFrameElemAlpha = {
                                        type = 'range',
                                        name = L["OPT_CENTERTRANSP"],
                                        desc = L["OPT_CENTERTRANSP_DESC"],
                                        get = function() return 1 - D.profile.DebuffsFrameElemAlpha end,
                                        set = function(info,v)
                                            D.SetHandler(info,1 - v);

                                            if D.profile.DebuffsFrameElemTieTransparency then
                                                D.profile.DebuffsFrameElemBorderAlpha = (1 - v) / 2;
                                            end
                                        end,
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        isPercent = true,
                                        order = 101,
                                    },
                                },
                            },
                            SpacingOpts = {
                                type = 'group',
                                inline = true,
                                name = " ",
                                order = 2,
                                disabled = function() return D.Status.Combat end,
                                args = {
                                    combatwarning = CombatWarning,
                                    DebuffsFrameTieSpacing = {
                                        type = "toggle",
                                        name = L["OPT_TIEXYSPACING"],
                                        desc = L["OPT_TIEXYSPACING_DESC"],
                                        set = function(info,v)
                                            D.SetHandler(info, v);
                                            if v then
                                                D.profile.DebuffsFrameYSpacing = D.profile.DebuffsFrameXSpacing;
                                            end
                                            D.MicroUnitF:ResetAllPositions ();
                                        end,
                                        order = 104
                                    },
                                    DebuffsFrameXSpacing = {
                                        type = 'range',
                                        name = L["OPT_XSPACING"],
                                        desc = L["OPT_XSPACING_DESC"],
                                        set = function(info,v)
                                            D.SetHandler(info, v);
                                            if D.profile.DebuffsFrameTieSpacing then
                                                D.profile.DebuffsFrameYSpacing = v;
                                            end
                                            D.MicroUnitF:ResetAllPositions ();
                                        end,
                                        min = 0,
                                        max = 100,
                                        step = 1,
                                        order = 105,
                                    },
                                    DebuffsFrameYSpacing = {
                                        type = 'range',
                                        name = L["OPT_YSPACING"],
                                        desc = L["OPT_YSPACING_DESC"],
                                        set = function(info,v)
                                            D.SetHandler(info, v);

                                            D.MicroUnitF:ResetAllPositions ();
                                        end,
                                        disabled = function() return D.Status.Combat or D.profile.DebuffsFrameTieSpacing end,
                                        min = 0,
                                        max = 100,
                                        step = 1,
                                        order = 106,
                                    }, -- }}}
                                },
                            },
                        },
                    },

                    MUFsMouseButtons = {
                        type = "group",
                        name = L["OPT_MUFMOUSEBUTTONS"],
                        desc = L["OPT_MUFMOUSEBUTTONS_DESC"],
                        order = 3,
                        disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1;end,
                        hidden = function () return not D:IsEnabled(); end,
                        args = {},
                    },

                    MUFsColors = {
                        type = "group",
                        name = L["OPT_MUFSCOLORS"],
                        desc = L["OPT_MUFSCOLORS_DESC"],
                        order = 3,
                        disabled = function() return D.Status.Combat or not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1;end,
                        hidden = function () return not D:IsEnabled(); end,
                        args = {
                            description = {
                                type = 'description',
                                name = L["OPT_MUFSCOLORS_DESC"],
                                order = 0,
                            },
                            separationLine = {
                                type = 'header',
                                name = "",
                                order = 1,
                            },
                        },
                    },

                    PerfOptions = {
                        type = "group",
                        name = L["OPT_MFPERFOPT"],
                        order = 3,
                        disabled = function () return not D.profile.ShowDebuffsFrame and D.profile.AutoHideMUFs == 1; end,
                        args = {
                            -- {{{
                            Warning = {
                                type = "description",
                                name = D:ColorText(L["OPT_PERFOPTIONWARNING"], "FFFF0000"),
                                order = 2500,
                            },
                            DebuffsFrameRefreshRate = {
                                type = 'range',
                                name = L["OPT_MFREFRESHRATE"],
                                desc = L["OPT_MFREFRESHRATE_DESC"],
                                min = 0.017,
                                max = 0.2,
                                step = 0.01,
                                order = 2600,
                            },
                            DebuffsFramePerUPdate = {
                                type = 'range',
                                name = L["OPT_MFREFRESHSPEED"],
                                desc = L["OPT_MFREFRESHSPEED_DESC"],
                                min = 1,
                                max = 82,
                                step = 1,
                                order = 2700,
                            },
                            MFScanEverybodyTimer = {
                                type = 'range',
                                name = L["OPT_PERIODICRESCAN"],
                                desc = L["OPT_PERIODICRESCAN_DESC"],
                                min = 0, -- 0 will disable it
                                max = 60,
                                step = 1,
                                order = 2800,
                            },
                            MFScanEverybodyReport = {
                                type = "toggle",
                                name = L["OPT_PERIODICRESCAN_REPORT"],
                                desc = L["OPT_PERIODICRESCAN_REPORT_DESC"],
                                order = 2900,
                            },
                        },
                    }, -- }}}
                },
            }, -- }}}

            CureOptions = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_CURINGOPTIONS"], "FFFF5533"),
                desc = L["OPT_CURINGOPTIONS_DESC"],
                order = 40,
                disabled = function(info)
                    if info[#info] ~= "CureOptions" then
                        return D.Status.Combat
                    else
                        return false;
                    end
                end,
                --childGroups = 'tab',
                args = {
                    description = {name = L["OPT_CURINGOPTIONS_DESC"], order = 1, type = "description", disabled = false,},
                    DoNot_Blacklist_Prio_List = {
                        type = "toggle",
                        width = 'full',
                        name =  L["DONOT_BL_PRIO"],
                        desc = L["OPT_DONOTBLPRIO_DESC"],
                        order = 131
                    },
                    Scan_Pets = {
                        type = "toggle",
                        width = 'full',
                        name = L["CURE_PETS"],
                        desc = L["OPT_CUREPETS_DESC"],
                        order = 133
                    },

                    CureOrder = {
                        type="group",
                        name = L["OPT_CURINGORDEROPTIONS"],
                        order = 139,
                        inline = true,
                        disabled = function(info)
                            if info[#info] ~= "CureOrder" then
                                return D.Status.Combat
                            else
                                return false;
                            end
                        end,
                        args = {
                            combatwarning = CombatWarning,
                            description = {
                                type = "description",
                                name = L["OPT_CURINGOPTIONS_EXPLANATION"],
                                order = 140,
                            },
                            CureMagic = {
                                type = "toggle",
                                name = "  "..L["MAGIC"],
                                desc = L["OPT_MAGICCHECK_DESC"],
                                get = function() return D:GetCureTypeStatus(DC.MAGIC) end,
                                set = function()
                                    D:SetCureOrder (DC.MAGIC);
                                end,
                                disabled = function() return not D.Status.CuringSpells[DC.MAGIC] or D.Status.Combat end,
                                order = 141
                            },
                            CureEnemyMagic = {
                                type = "toggle",
                                name = "  "..L["MAGICCHARMED"],
                                desc = L["OPT_MAGICCHARMEDCHECK_DESC"],
                                get = function() return D:GetCureTypeStatus(DC.ENEMYMAGIC) end,
                                set = function()
                                    D:SetCureOrder (DC.ENEMYMAGIC);
                                end,
                                disabled = function() return not D.Status.CuringSpells[DC.ENEMYMAGIC] or D.Status.Combat end,
                                order = 142
                            },
                            CurePoison = {
                                type = "toggle",
                                name = "  "..L["POISON"],
                                desc = L["OPT_POISONCHECK_DESC"],
                                get = function() return D:GetCureTypeStatus(DC.POISON) end,
                                set = function()
                                    D:SetCureOrder (DC.POISON);
                                end,
                                disabled = function() return not D.Status.CuringSpells[DC.POISON] or D.Status.Combat end,
                                order = 143
                            },
                            CureDisease = {
                                type = "toggle",
                                name = "  "..L["DISEASE"],
                                desc = L["OPT_DISEASECHECK_DESC"],
                                get = function() return D:GetCureTypeStatus(DC.DISEASE) end,
                                set = function()
                                    D:SetCureOrder (DC.DISEASE);
                                end,
                                disabled = function() return not D.Status.CuringSpells[DC.DISEASE] or D.Status.Combat end,
                                order = 144
                            },
                            CureCurse = {
                                type = "toggle",
                                name = "  "..L["CURSE"],
                                desc = L["OPT_CURSECHECK_DESC"],
                                get = function() return D:GetCureTypeStatus(DC.CURSE) end,
                                set = function()
                                    D:SetCureOrder (DC.CURSE);
                                end,
                                disabled = function() return not D.Status.CuringSpells[DC.CURSE] or D.Status.Combat end,
                                order = 145
                            },
                            CureCharmed = {
                                type = "toggle",
                                name = "  "..L["CHARM"],
                                desc = L["OPT_CHARMEDCHECK_DESC"],
                                get = function() return D:GetCureTypeStatus(DC.CHARMED) end,
                                set = function()
                                    D:SetCureOrder (DC.CHARMED);
                                end,
                                disabled = function() return not D.Status.CuringSpells[DC.CHARMED] or D.Status.Combat end,
                                order = 146
                            },
                            CureBleed = {
                                type = "toggle",
                                name = "  "..L["BLEED"],
                                desc = L["OPT_BLEEDCHECK_DESC"],
                                get = function() return D:GetCureTypeStatus(DC.BLEED) end,
                                set = function()
                                    D:SetCureOrder (DC.BLEED);
                                end,
                                disabled = function() return not D.Status.CuringSpells[DC.BLEED] or D.Status.Combat end,
                                order = 147
                            },

                        },
                    },
                    BleedEffects = {
                        type = 'group',
                        name = L["OPT_BLEED_EFFECT_HOLDER"],
                        desc = L["OPT_BLEED_EFFECT_HOLDER_DESC"],
                        order = 175,
                        --inline = true,
                        childGroups = 'tab',
                        args = {
                            enableDetection = {
                                type = 'toggle',
                                width = 'full',
                                name = L["OPT_ENABLE_BLEED_EFFECTS_DETECTION"],
                                desc = L["OPT_ENABLE_BLEED_EFFECTS_DETECTION_DESC"],
                                get = function() return D.db.global.BleedAutoDetection; end,
                                set = function(info, v) D.db.global.BleedAutoDetection = v end,
                                disabled = function () return not D.Status.CuringSpells[DC.BLEED] end,
                                order = 0,
                            },
                            bleedkeywords = {
                                type = 'input',
                                multiline = true,
                                name = L["OPT_BLEED_EFFECT_IDENTIFIERS"],
                                desc = L["OPT_BLEED_EFFECT_IDENTIFIERS_DESC"],
                                width = 1.5,
                                get = function(info)
                                    return D.db.locale.BleedEffectsKeywords and D.db.locale.BleedEffectsKeywords or "";
                                end,
                                set = function(info, v)
                                    local oldValue = D.db.locale.BleedEffectsKeywords;
                                    local value = v:trim() ~= "" and v:trim() or false;

                                    -- remove empty lines and trim each line
                                    local cleanedValue = value and value:gsub("[\n\r]%s*[\n\r]", "\n"):gsub("[\n\r]%s+", "\n"):gsub("%s+[\n\r]", "\n") or false;

                                    D.db.locale.BleedEffectsKeywords = cleanedValue and cleanedValue or D.defaults.locale.BleedEffectsKeywords;

                                    local newValueOrDefault = D.db.locale.BleedEffectsKeywords;

                                    if newValueOrDefault:trim() ~= "" then
                                        if oldValue ~= newValueOrDefault then
                                            D.Status.P_BleedEffectsKeywords_noCase = D:makeNoCasePattern(newValueOrDefault);
                                            -- if the identifier changes we need to reset the active table
                                            -- so that new stuff can be found if previously ignored
                                            D:reset_t_CheckBleedDebuffsActiveIDs();
                                        end
                                    else
                                        D.Status.P_BleedEffectsKeywords_noCase = false;
                                    end
                                end,
                                validate = function(info, v)
                                    -- test for pattern match exceptions
                                    -- Note that Lua does not validate patterns before using them so they may crash depending
                                    -- on the string being search so we search the provided input text to increase our changes
                                    -- of getting a match but there is no guarantee, there are protections embeded in hasDescBleedEffectkeyword
                                    local _, errorMessage = D:hasDescBleedEffectkeyword(v, D:makeNoCasePattern(v), true);
                                    if not errorMessage then
                                        return true;
                                    else
                                        local cleanedError = errorMessage:gsub("^[^:]+:%d+:%s*", "");
                                        T._ShowNotice(cleanedError);
                                        return cleanedError
                                    end
                                end,
                                disabled = function() return not D.db.global.BleedAutoDetection or not D.Status.CuringSpells[DC.BLEED]; end,

                                order = 10,
                            },
                            sep1 = {
                                type = 'header',
                                name = "",
                                order = 11,
                            },
                            addBleedEffect = {
                                type = 'input',
                                name = L["OPT_ADD_BLEED_EFFECT_ID"],
                                desc = L["OPT_ADD_BLEED_EFFECT_ID_DESC"],
                                set = function(info, v)
                                    D.db.global.t_BleedEffectsIDCheck[TN(v)] = true;
                                    D.Status.t_CheckBleedDebuffsActiveIDs[TN(v)] = true;
                                end,
                                validate = function(info, v)
                                    return TN(v) ~= nil and C_Spell.DoesSpellExist(TN(v)) and 0 or D:ColorPrint(1, 0, 0, L["OPT_BLEED_EFFECT_BAD_SPELLID"]);
                                end,
                                disabled = function () return not D.Status.CuringSpells[DC.BLEED] end,
                                order = 20,
                            },
                            knownBleedingEffects = {
                                type = 'group',
                                width = 'full',
                                name = L["OPT_KNOWN_BLEED_EFFECTS"],
                                order = 40,
                                args = {},

                            },
                        },
                    },
                },
            }, -- }}}

            CustomSpells = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_CUSTOMSPELLS"], "FF00DDDD"),
                desc = L["OPT_CUSTOMSPELLS_DESC"],
                order = 50,
                childGroups = 'tab',
                cmdHidden = true,
                disabled = function(info)
                    if info[#info] ~= "CustomSpells" then
                        return D.Status.Combat
                    else
                        return false;
                    end
                end,
                args = {
                    combatwarning = CombatWarning,
                    explanation = {
                        type = 'description',
                        name = L["OPT_CUSTOMSPELLS_DESC"],
                        order = 1,
                        disabled = false,
                    },
                   CurrentAssignments = {
                        type = 'description',
                        name = function()
                            local MouseButtons = D.db.global.MouseButtons;
                             table.wipe(SpellAssignmentsTexts);
                             SpellAssignmentsTexts[1] = "\n" .. D:ColorText(L["OPT_CUSTOMSPELLS_EFFECTIVE_ASSIGNMENTS"], "FFEEEE33");

                              for Spell, Prio in pairs(D.Status.CuringSpellsPrio) do

                                  local SpellCuredTypes = {};
                                  for typeprio, afflictionType in ipairs(D.Status.ReversedCureOrder) do

                                      if D.Status.CuringSpells[afflictionType] == Spell then
                                          table.insert(SpellCuredTypes, L[DC.TypeToLocalizableTypeNames[afflictionType]])
                                      end
                                  end

                                  SpellCuredTypes = table.concat (SpellCuredTypes, " - ");

                                  SpellAssignmentsTexts[Prio + 1] = str_format("\n    %s -> %s%s", D:ColorText(("%s - %s - (%s)"):format( L["OPT_CURE_PRIORITY_NUM"]:format(Prio), SpellCuredTypes, DC.MouseButtonsReadable[MouseButtons[Prio]]), D:NumToHexColor(D.profile.MF_colors[Prio])), Spell, (D.Status.FoundSpells[Spell] and D.Status.FoundSpells[Spell][5]) and "|cFFFF0000*|r" or "");
                              end
                              return table.concat(SpellAssignmentsTexts, "\n");
                        end,
                        order = 2,
                    },

                    AddCustomSpell = { -- {{{
                        type = 'input',
                        name = L["OPT_ADD_A_CUSTOM_SPELL"],
                        usage = L["OPT_ADD_A_CUSTOM_SPELL_DESC"],
                        order = 155,
                        width = 'double',
                        set = function(info, v)

                            local errorn, isItem, isPetAbility;
                            errorn, v, isItem, isPetAbility = validateSpellInput(info, v);
                            if errorn ~= 0 then D:Debug("XXXX AHHHHHHHHHHHHHHH!!!!!", errorn); return false end

                            if not D.classprofile.UserSpells[v] or D.classprofile.UserSpells[v].Hidden and CustomSpellMacroEditingAllowed then
                                D:Debug("Adding", v);
                                D.classprofile.UserSpells[v] = {
                                    Types = {},
                                    Better = 10,
                                    Pet = isPetAbility,
                                    Disabled = false,
                                    IsItem = isItem,
                                };

                                if CustomSpellMacroEditingAllowed then

                                    D.classprofile.UserSpells[v].MacroText = ("/stopcasting\n/%s [@UNITID,help][@UNITID,harm]%s"):format(
                                        isItem and "use" or "cast",
                                        D.GetSpellOrItemInfo(v)
                                    );

                                    -- If it's a default spell, then copy the spell settings
                                    if DC.SpellsToUse[v] then
                                        D:tcopy(D.classprofile.UserSpells[v].Types, DC.SpellsToUse[v].Types) -- Types is a table, protect the original
                                        D.classprofile.UserSpells[v].Pet                = DC.SpellsToUse[v].Pet;
                                        D.classprofile.UserSpells[v].EnhancedBy         = DC.SpellsToUse[v].EnhancedBy;
                                        D.classprofile.UserSpells[v].EnhancedByCheck    = DC.SpellsToUse[v].EnhancedByCheck;
                                        D.classprofile.UserSpells[v].Enhancements       = DC.SpellsToUse[v].Enhancements;
                                        if DC.SpellsToUse[v].UnitFiltering then
                                            D.classprofile.UserSpells[v].UnitFiltering = {};
                                            D:tcopy(D.classprofile.UserSpells[v].UnitFiltering, DC.SpellsToUse[v].UnitFiltering) -- UnitFiltering is a table, protect the original
                                        end
                                    end

                                end

                            elseif D.classprofile.UserSpells[v].IsDefault and D.classprofile.UserSpells[v].Hidden then
                                D:Debug("Reactivating", v);
                                D.classprofile.UserSpells[v].Hidden = false;
                                D.classprofile.UserSpells[v].MacroText = nil;
                            end

                            CustomSpellMacroEditingAllowed = false; -- reset macro check box
                        end,
                        validate = validateSpellInput,
                    }, -- }}}

                    IsMacro = {
                        type = 'toggle',
                        name = L["OPT_CUSTOM_SPELL_ALLOW_EDITING"],
                        desc = L["OPT_CUSTOM_SPELL_ALLOW_EDITING_DESC"],
                        order = 160,
                        width = 'full',
                        get = function() return CustomSpellMacroEditingAllowed; end,
                        set = function(info, v) CustomSpellMacroEditingAllowed = v; end,
                    },



                    CustomSpellsHolder = {
                        type = 'group',
                        name = L["OPT_CUSTOMSPELLS"],
                        order = 165,
                        args = {},
                    }
                },
            }, -- }}}

            DebuffSkip = {
                -- {{{
                type = "group",
                hidden = function () return not D:IsEnabled(); end,
                disabled = function () return not D:IsEnabled(); end,
                name = D:ColorText(L["OPT_DEBUFFFILTER"], "FF99CCAA"),
                desc = L["OPT_DEBUFFFILTER_DESC"],
                order = 60,
                childGroups= "tab",
                args = {}
            }, -- }}}

            Macro = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_MACROOPTIONS"], "FFCC99BB"),
                desc = L["OPT_MACROOPTIONS_DESC"],
                order = 70,
                disabled = function() return not D.Status.Enabled or D.Status.Combat end,
                args = {
                    description = {name = L["OPT_MACROOPTIONS_DESC"], order = 1, type = "description"},
                    SetKey = {
                        type = "keybinding",
                        name = L["OPT_MACROBIND"],
                        desc = L["OPT_MACROBIND_DESC"],
                        get = function ()
                            local key = (GetBindingKey(D.CONF.MACROCOMMAND));
                            D.db.global.MacroBind = key;
                            return key;
                        end,
                        set = function (info,key)
                            if key ~= "BUTTON1" and key ~= "BUTTON2" then
                                D:SetMacroKey ( key );
                            end
                        end,
                        disabled = function () return D.profile.DisableMacroCreation end,
                        order = 200,
                    },
                    NoKeyWarn = {
                        type = "toggle",
                        name = L["OPT_NOKEYWARN"],
                        desc = L["OPT_NOKEYWARN_DESC"],
                        disabled = function () return D.profile.DisableMacroCreation end,
                        order = 300
                    },
                    AllowMacroEdit = {
                        type = "toggle",
                        name = L["OPT_ALLOWMACROEDIT"],
                        desc = L["OPT_ALLOWMACROEDIT_DESC"],
                        disabled = function () return D.profile.DisableMacroCreation end,
                        order = 350
                    },
                    DisableMacroCreation = {
                        type = "toggle",
                        name = L["OPT_DISABLEMACROCREATION"],
                        desc = L["OPT_DISABLEMACROCREATION_DESC"],
                        order = 400
                    }
                }
            }, -- }}}

            About = {
                -- {{{
                type = "group",
                name = D:ColorText(L["OPT_ABOUT"], "FFFFFFFF"),
                order = -1,
                args = {
                    -- Decursive vxx by x released on XX
                    Title = {
                        type = 'description',
                        name = (
                                    "\n\n\n\nDecursive |cFFDD0000 v%s |r by |cFFDD0000 %s |r released on |cFFDD0000 %s |r"..
                                    "\n\n      |cFF55DDDD %s |r"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s"..
                                    "\n\n|cFFDDDD00 %s|r:\n   %s\n\n   %s"
                                ):format(
                                    "2.7.29", "John Wellesz", ("2025-07-20T23:08:26Z"):sub(1,10),
                                    L["ABOUT_NOTES"],
                                    L["ABOUT_LICENSE"],         GetAddOnMetadata("Decursive", "X-License") or 'All Rights Reserved',
                                    L["ABOUT_SHAREDLIBS"],      GetAddOnMetadata("Decursive", "X-Embeds")  or 'GetAddOnMetadata() failure',
                                    L["ABOUT_OFFICIALWEBSITE"], GetAddOnMetadata("Decursive", "X-Website") or 'GetAddOnMetadata() failure',
                                    L["ABOUT_AUTHOREMAIL"],     GetAddOnMetadata("Decursive", "X-eMail")   or 'GetAddOnMetadata() failure',
                                    L["ABOUT_CREDITS"]
                                    ,    "Decursive is inspired from the original \"Decursive v1.9.4\" released in 2006 by Patrick Bohnet (Quutar of Earthen Ring (US))"
                                    ,    GetAddOnMetadata("Decursive", "X-Credits") or 'GetAddOnMetadata() failure'
                                ),
                        order = 0,
                    },
                    Sep1 = {
                        type = "header",
                        name = "",
                        order = 5,
                    },
                    CheckVersions = {
                        type = "execute",
                        name = L["OPT_CHECKOTHERPLAYERS"],
                        desc = L["OPT_CHECKOTHERPLAYERS_DESC"],
                        disabled = function () return InCombatLockdown() or GetTime() - T.LastVCheck < 60; end,
                        func = function ()
                            if D:AskVersion() then D.versions = false; end
                            if GameTooltip:IsShown() then GameTooltip:Hide(); end
                        end,
                        order = 10,
                    },
                    VersionsDisplay = {
                        type = "description",
                        name = D.ReturnVersions,
                        hidden = function () return not D.versions; end,
                        order = 30,
                    },

                },
            }, -- }}}
        },
    } -- }}}
end

local function GetOptions()

    local options = GetStaticOptions();

    local CureCheckBoxes = {
        [DC.ENEMYMAGIC]     = options.args.CureOptions.args.CureOrder.args.CureEnemyMagic,
        [DC.MAGIC]          = options.args.CureOptions.args.CureOrder.args.CureMagic,
        [DC.CURSE]          = options.args.CureOptions.args.CureOrder.args.CureCurse,
        [DC.POISON]         = options.args.CureOptions.args.CureOrder.args.CurePoison,
        [DC.DISEASE]        = options.args.CureOptions.args.CureOrder.args.CureDisease,
        [DC.CHARMED]        = options.args.CureOptions.args.CureOrder.args.CureCharmed,
        [DC.BLEED]          = options.args.CureOptions.args.CureOrder.args.CureBleed,
    }

    -- Add the number infront of the checkboxes
    for Type, CheckBox in pairs(CureCheckBoxes) do
        D:SetCureCheckBoxNum(Type, CheckBox);
    end

    -- create per class filters menus
    options.args.DebuffSkip.args = D:CreateFiltersMenu();
    -- create MUF color configuration menus
    D:CreateDropDownMUFcolorsMenu(options.args.MicroFrameOpt.args.MUFsColors.args);
    -- add the affliction color pickers there too
    D:CreateAfflictionColorsMenu(options.args.MicroFrameOpt.args.MUFsColors.args);
    -- create MUF's mouse buttons configuration menus
    options.args.MicroFrameOpt.args.MUFsMouseButtons.args = D:CreateModifierOptionMenu();
    -- create curring spells addition submenus
    D:CreateAddedSpellsOptionMenu(options.args.CustomSpells.args.CustomSpellsHolder.args);
    -- create bleeding debuffs addition submenus
    D:CreateBleedingDebuffsOptionMenu(options.args.CureOptions.args.BleedEffects.args.knownBleedingEffects.args);

    -- Create profile options
    options.args.general.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(D.db);
    options.args.general.args.profiles.order = -1;
    options.args.general.args.profiles.inline = true;
    options.args.general.args.profiles.hidden = function() return not D:IsEnabled(); end;
    options.args.general.args.profiles.disabled = function() return D.Status.Combat or not D:IsEnabled(); end;

    if DC.CATACLYSM or not DC.WOWC then
        -- Add dual-spec support
        local LibDualSpec = LibStub('LibDualSpec-1.0');
        LibDualSpec:EnhanceDatabase(D.db, "DecursiveDB");
        LibDualSpec:EnhanceOptions(options.args.general.args.profiles, D.db);
    end

    return options;

end

function D:ExportOptions ()
    -- Export the option table to Blizz option UI and to Ace3 option UI

    T._CatchAllErrors = "ExportOptions";
    LibStub("AceConfig-3.0"):RegisterOptionsTable(D.name,  GetOptions, 'dcr');
    T._CatchAllErrors = false;


    -- Don't feed the interface option panel until Blizz fixes the taint issue...
    --[=[
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(D.name, D.name, nil, "general");

    local SubGroups_ToBlizzOptions = {
        { D:ColorText(L["OPT_LIVELIST"], "FF22EE33"), "livelistoptions"},
        { D:ColorText(L["OPT_MESSAGES"], "FF229966"), "MessageOptions"},
        { D:ColorText(L["OPT_MFSETTINGS"], "FFBBCC33"), "MicroFrameOpt"},
        { D:ColorText(L["OPT_CURINGOPTIONS"], "FFFF5533"), "CureOptions"},
        { D:ColorText(L["OPT_CUSTOMSPELLS"], "FF00DDDD"), "CustomSpells"},
        { D:ColorText(L["OPT_DEBUFFFILTER"], "FF99CCAA"), "DebuffSkip"},
        { D:ColorText(L["OPT_MACROOPTIONS"], "FFCC99BB"), "Macro"},
        { D:ColorText(L["OPT_ABOUT"], "FFFFFFFF"), "About"},
    };

    for key,values in ipairs(SubGroups_ToBlizzOptions) do
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(D.name, values[1], D.name, values[2]);
    end
    --]=]
end



function D:GetCureTypeStatus (Type)
    return self:GetCureOrderTable()[Type];
end

local TypesToUName = {
    [DC.ENEMYMAGIC]     = "MAGICCHARMED",
    [DC.MAGIC]          = "MAGIC",
    [DC.CURSE]          = "CURSE",
    [DC.POISON]         = "POISON",
    [DC.DISEASE]        = "DISEASE",
    [DC.CHARMED]        = "CHARM",
    [DC.BLEED]          = "BLEED",
}

local CureCheckBoxes = false;
function D:SetCureCheckBoxNum (Type, checkBox)
    local cureOrders = self:GetCureOrderTable();
    -- add the priority in front of the name
    if (cureOrders[Type]) then
        local cureOrder = abs(cureOrders[Type])
        checkBox.name = D:ColorText(cureOrder, cureOrders[Type] > 0 and "FF00FF00" or "FF3030F0") .. " " .. L[TypesToUName[Type]];
    else
        checkBox.name = "  " .. L[TypesToUName[Type]];
    end

end

function D:GetCureOrderTable ()
    local activeSpec = GetSpecialization();
    local generalCureOrder = D.classprofile.CureOrder;

    if not activeSpec or activeSpec == 5 then
        --[==[@debug@
        --D:Debug("No active spec, returning general cure order table:", D:tAsString(generalCureOrder));
        --@end-debug@]==]
        return generalCureOrder;
    else
        local specCureOrder = "CureOrder-"..activeSpec;

        if not D.classprofile[specCureOrder] then
            D:Debug("Creating specific cureorder table ", specCureOrder, " for spec:", activeSpec);
            D.classprofile[specCureOrder] = {};
            self:tcopy(D.classprofile[specCureOrder], generalCureOrder);
        end

        --[==[@debug@
        --D:Debug("returning specific cure order table ", specCureOrder, " for spec:", activeSpec, "table:", D:tAsString(D.classprofile[specCureOrder]));
        --@end-debug@]==]
        return D.classprofile[specCureOrder];
    end
end

function D:CheckCureOrder ()

    D:Debug("Verifying CureOrder...");

    local TempTable = {};
    local AuthorizedKeys = {
        [DC.ENEMYMAGIC]   = 1,
        [DC.MAGIC]          = 2,
        [DC.CURSE]          = 3,
        [DC.POISON]         = 4,
        [DC.DISEASE]        = 5,
        [DC.CHARMED]        = 6,
        [DC.BLEED]          = 7,
    };
    local AuthorizedValues = {
        [false] = true; -- LOL Yes, it's TRUE that FALSE is an authorized value xD
        -- Other <0  values are used when there used to be a spell...
        [1]     = DC.ENEMYMAGIC,
        [-11]   = DC.ENEMYMAGIC,
        [2]     = DC.MAGIC,
        [-12]   = DC.MAGIC,
        [3]     = DC.CURSE,
        [-13]   = DC.CURSE,
        [4]     = DC.POISON,
        [-14]   = DC.POISON,
        [5]     = DC.DISEASE,
        [-15]   = DC.DISEASE,
        [6]     = DC.CHARMED,
        [-16]   = DC.CHARMED,
        [7]     = DC.BLEED,
        [-17]   = DC.BLEED,
    };
    local GivenValues = {};


    local cureOrder = self:GetCureOrderTable();
    -- add missing entries...
    for key, value in pairs(AuthorizedKeys) do
        if nil == cureOrder[key] then
            cureOrder[key] = D.defaults.class.CureOrder[key];
        end
    end

    -- Validate existing entries
    local WrongValue = 0;
    for key, value in pairs(cureOrder) do

        if (AuthorizedKeys[key]) then -- is this a correct type ?
            if (AuthorizedValues[value] and not GivenValues[value]) then -- is this value authorized and not already given?
                GivenValues[value] = true;

            elseif (value) then -- FALSE is the only value that can be given several times
                D:Debug("Incoherent value for (key, value, Duplicate?)", key, value, GivenValues[value]);

                cureOrder[key] = -20 - WrongValue; -- if the value was wrong or already given to another type
                WrongValue = WrongValue + 1;
            end
        else
            cureOrder[key] = nil; -- remove it from the table
        end
    end

end

function D:SetCureOrder (ToChange)


    local CureOrder = self:GetCureOrderTable();
    local tmpTable = {};
    D:Debug("SetCureOrder called for prio ", CureOrder[ToChange]);

    if (ToChange) then
        -- if there is a positive value, it means we want to disable this type, set it to false (see GetCureTypeStatus())
        if (D:GetCureTypeStatus(ToChange)) then
            CureOrder[ToChange] = false;
            D:Debug("SetCureOrder(): set to false");
        else -- else if there was no value (or a negative one), add this type at the end (see GetCureTypeStatus())
            CureOrder[ToChange] = 20; -- this will cause the spell to be added at the end
            D:Debug("SetCureOrder(): set to 20");
        end
    end

    local LostSpells = {}; -- an orphanage for the lost spells :'(
    local FoundSpell = 0;

    -- re-compute the position of each spell type
    for Type, Num in pairs (CureOrder) do

        -- if we have a spell or if we did not unchecked the checkbox (note the difference between "checked" and "not unchecked")
        if (D.Status.CuringSpells[Type] and CureOrder[Type]) then
            tmpTable[abs(CureOrder[Type])] = Type; -- CureOrder[Type] can have a <0 value if the spell was lost
            FoundSpell = FoundSpell + 1;
        elseif (CureOrder[Type]) then -- if we don't have a spell for this type
            --[==[@debug@
            D:Debug("SetCureOrder(): Adding lost spell", CureOrder[Type], Type)
            --@end-debug@]==]
            LostSpells[abs(CureOrder[Type])] = Type;  -- save the position
        end
    end

   -- take care of the lost spells here
   -- Sort the lost spells so that they can be read in the correct order
   LostSpells = D:tSortUsingKeys(LostSpells);

   -- Place the lost spells after the found ones but with <0 values so they
   -- can be readded later using their former priorities
   local AvailableSpot = (FoundSpell + 10 + 1) * -1; -- we add 10 so that they'll be re-added after any not-lost spell...


   -- if the user requested this change, then we update the saved data else we
   -- leave it as it is so that it can go back to the previous state if the old
   -- conditions are met again
   local newCureOrder = {}
   if (ToChange) then
       newCureOrder = CureOrder
   else
        D:tcopy(newCureOrder, CureOrder)
   end

   -- D:PrintLiteral(LostSpells);
   for FormerPrio, Type in ipairs(LostSpells) do
       newCureOrder[Type] = AvailableSpot
        --[==[@debug@
        D:Debug("SetCureOrder(): old lost spell prio:", CureOrder[Type], Type)
        --@end-debug@]==]
       AvailableSpot = AvailableSpot - 1;
   end

    -- we sort the tables
    tmpTable = D:tSortUsingKeys(tmpTable);

    -- apply the new priority to the types we can handle, leave their negative
    -- value to the other
    for Num, Type in ipairs (tmpTable) do
        newCureOrder[Type] = Num;
    end

    --[==[@debug@
    D:Debug("SetCureOrder(): updated cure order table:", D:tAsString(newCureOrder), ToChange and "(saved)" or "(unsaved)" );
    --@end-debug@]==]


    -- create / update the ReversedCureOrder table (prio => type, ..., )
    D.Status.ReversedCureOrder = D:tReverse(newCureOrder);

    -- Create spell priority table
    D.Status.CuringSpellsPrio = {};

    -- some shortcuts
    local CuringSpellsPrio = D.Status.CuringSpellsPrio;
    local ReversedCureOrder = D.Status.ReversedCureOrder;
    local CuringSpells  = D.Status.CuringSpells;

    local DebuffType;
    -- set the priority for each spell, Micro frames will use this to determine which button to map
    local affected = 1;
    for i=1,7 do
        DebuffType = ReversedCureOrder[i]; -- there is no gap between indexes
        if (DebuffType and not CuringSpellsPrio[ CuringSpells[DebuffType] ] ) then
            CuringSpellsPrio[ CuringSpells[DebuffType] ] = affected;
            affected = affected + 1;
        end
    end

    -- Set the spells shortcut (former decurse key)
    D:AddDelayedFunctionCall(
        "UpdateMacro", self.UpdateMacro,  -- dangerous call many add-ons hook APIs call there this should be delayed
        self)

    D:Debug("Spell changed");
    D.Status.SpellsChanged = GetTime();
    D.Status.delayedDebuffReportDisabled = true;
    if self.db.global.MFScanEverybodyTimer == 0 or self.db.global.MFScanEverybodyTimer > 1 then
        D:Debug("ScanEveryBody delayed call scheduled by SetCureOrder")
        D:ScheduleDelayedCall("scanEverybodyAfterSpellChanged", D.ScanEveryBody, 1, D)
    end

    -- If no spell is selected or none is available set Decursive icon to off
    if FoundSpell ~= 0 then
        D:Debug("icon changed to ON");
        D:SetIcon(DC.IconON);
    else
        D:Debug("icon changed to OFF");
        D:SetIcon(DC.IconOFF);
    end

    self:SetMacrosPerPrioTable("mouseover");

end

function D:ShowHideDebuffsFrame ()

    if InCombatLockdown() or not D.DcrFullyInitialized or D.Status.TestLayout then
        return
    end

    D.profile.ShowDebuffsFrame = not D.profile.ShowDebuffsFrame;

    if (D.MFContainer:IsVisible()) then
        D.MFContainer:Hide();
        D.profile.ShowDebuffsFrame = false;
    else
        D.MicroUnitF:Show();
    end

    if (not D.profile.ShowDebuffsFrame) then
        D:CancelDelayedCall("Dcr_MUFupdate");
        D:CancelDelayedCall("Dcr_ScanEverybody");
        if D.profile.HideLiveList then
            D.Status.SoundPlayed = false;
            D:Debug("ShowHideDebuffsFrame(): sound re-enabled");
        end
    else
        D:ScheduleRepeatedCall("Dcr_MUFupdate", D.DebuffsFrame_Update, D.db.global.DebuffsFrameRefreshRate, D);

        if D.db.global.MFScanEverybodyTimer > 0 then
            self:ScheduleRepeatedCall("Dcr_ScanEverybody", D.ScanEveryBody, D.db.global.MFScanEverybodyTimer, D);
        end

        D.MicroUnitF:Force_FullUpdate();
    end

    -- set Icon
    if not D.Status.HasSpell or D.profile.HideLiveList and not D.profile.ShowDebuffsFrame then
        D:SetIcon(DC.IconOFF);
    else
        D:SetIcon(DC.IconON);
    end

end

function D:ShowHideTextAnchor() --{{{
    if (DecursiveAnchor:IsVisible()) then
        DecursiveAnchor:Hide();
    else
        DecursiveAnchor:Show();
    end
end --}}}

function D:ChangeTextFrameDirection(bottom) --{{{
    local button = DecursiveAnchorDirection;
    if (bottom) then
        DecursiveTextFrame:SetInsertMode("BOTTOM");
        button:SetText("v");
    else
        DecursiveTextFrame:SetInsertMode("TOP");
        button:SetText("^");
    end
end --}}}

do -- All this block predates Ace3, it could be recoded in a much more effecicent and cleaner way now (memory POV) thanks to the "info" table given to all callbacks in Ace3.
   -- A good example would be the code creating the MUF color configuration menu or the click assigment settings right after this block.

    local DebuffsSkipList, DefaultDebuffsSkipList, skipByClass, DebuffAlwaysSkipList, DefaultSkipByClass;

    local spacer = function(num) return { name="",type="header", order = 100 + num } end;

    local error = function (...) D:ColorPrint(1, 0, 0, ...); end;

    local RemoveFunc = function (handler)


        if DefaultDebuffsSkipList[handler["Debuff"]] then
            D.profile.DebuffsSkipList[handler["Debuff"]] = false;
        else
            D.profile.DebuffsSkipList[handler["Debuff"]] = nil;
        end
        D:Debug("Removing ", handler["Debuff"], D.profile.DebuffsSkipList[handler["Debuff"]], DefaultDebuffsSkipList[handler["Debuff"]]);

        skipByClass  = D.profile.skipByClass;
        for class, debuffs in pairs (skipByClass) do
            skipByClass[class][handler["Debuff"]] = nil;
        end

        D.profile.DebuffAlwaysSkipList[handler["Debuff"]] = nil; -- remove it from the table

        D:Debug("%s removed!", handler["Debuff"]);

    end

    local AddToAlwaysSkippFunc = function (handler, v)
        DebuffAlwaysSkipList[handler["Debuff"]] = v;
    end

    local ResetFunc = function (handler)
        local DebuffName = handler["Debuff"];

        D:Debug("Resetting '%s'...", handler["Debuff"]);

        skipByClass  = D.profile.skipByClass;
        for Classe, Debuffs in pairs(skipByClass) do
            if (DefaultSkipByClass[Classe][DebuffName]) then
                skipByClass[Classe][DebuffName] = true;
            else
                skipByClass[Classe][DebuffName] = nil; -- Removes it
            end
        end
    end

    local function ClassValues(DebuffName)
        local values = {};

        for i, class in pairs (DC.ClassNumToUName) do
            if LC[class] ~= class then -- skip non existant classes in WoW classic
                values[i] = D:ColorText( LC[class], "FF"..DC.HexClassColor[class]) ..
                (DefaultSkipByClass[class][DebuffName] and D:ColorText("  *", "FFFFAA00") or "");
            end
        end

        --D:Debug(unpack (values));
        return values;

    end

    local function DebuffSubmenu (DebuffName, num, spellID)
        local classes = {};

        classes["header1"] = {
            type = "description",
            name = (L["OPT_FILTEROUTCLASSES_FOR_X"]):format(D:ColorText(DebuffName, "FF77CC33")),
            order = num,
        }
        num = num + 1;

        classes["header2"] = {
            type = "description",
            name = function ()
                local spellDesc = GetSpellDescription(spellID);
                local desc;

                --D:Debug("Dealing with spell description for ", spellID);
                if spellID ~= 0 then
                    if spellDesc == "" or not spellDesc then
                        if not C_Spell.IsSpellDataCached(spellID) then
                            C_Spell.RequestLoadSpellData(spellID);
                            desc = L["OPT_SPELL_DESCRIPTION_LOADING"];
                        else
                            desc = L["OPT_SPELL_DESCRIPTION_UNAVAILABLE"];
                        end
                    else
                        desc = spellDesc;
                    end
                else
                    desc = L["OPT_SPELLID_MISSING_READD"];
                end

                return "\n" .. D:ColorText(desc, "FFD09050");
            end,
            order = num,
        }
        num = num + 1;

        skipByClass = D.profile.skipByClass;
         classes[DebuffName] = {
             type = "multiselect",
             name = "",
             --desc = "test desc",
             values = ClassValues(DebuffName),
             order = num,
             get = "get",
             set = "set",

             handler = {
                ["Debuff"]=DebuffName,
                ["get"] = function  (handler, info, Classnum)
                    return skipByClass[DC.ClassNumToUName[Classnum]][handler["Debuff"]];
                end,
                ["set"] = function  (handler, info, Classnum, state)
                    skipByClass[DC.ClassNumToUName[Classnum]][string.trim(handler["Debuff"])] = state;
                end
            };

         };

        --classes["spacer1"] = spacer(num);

        num = num + 1;

        classes["PermIgnore"] = {
            type = "toggle",
            name = D:ColorText(L["OPT_ALWAYSIGNORE"], "FFFF9900"),
            desc = str_format(L["OPT_ALWAYSIGNORE_DESC"], DebuffName),
            handler = {
                ["Debuff"] = DebuffName,
                ["get"] = function (handler)
                    return DebuffAlwaysSkipList[handler["Debuff"]];
                end,
                ["set"] = function (handler,info,v) AddToAlwaysSkippFunc(handler,v) end,
            },
            get = "get",
            set = "set",
            order = 100 + num;

        };

        num = num + 1;

        --classes["spacer1p5"] = spacer(num);

        num = num + 1;

        classes["remove"] = {
            type = "execute",
            name = D:ColorText(L["OPT_REMOVETHISDEBUFF"], "FFFF0000"),
            desc = str_format(L["OPT_REMOVETHISDEBUFF_DESC"], DebuffName),
            handler = {
                ["Debuff"] = DebuffName,
                ["remove"] = RemoveFunc,
            },
            confirm = true,
            func = "remove",
            order = 100 + num,

        };

        num = num + 1;

        --classes["spacer2"] = spacer(num);

        num = num + 1;

        local resetDisabled = false;

        if not DefaultDebuffsSkipList[DebuffName] then
            resetDisabled = true;
        end

        classes["reset"] = {
            type = "execute",
            -- the two statements below are like (()?:) in C
            name = not resetDisabled and D:ColorText(L["OPT_RESETDEBUFF"], "FF11FF00") or L["OPT_RESETDEBUFF"],
            desc = not resetDisabled and str_format(L["OPT_RESETDTDCRDEFAULT"], DebuffName) or L["OPT_USERDEBUFF"],
            handler = {
                ["Debuff"] = DebuffName,
                ["reset"] = ResetFunc,
            },
            func = "reset";
            disabled = resetDisabled,
            order = 100 + num;

        };

        num = num + 1;

        --classes["spacer3"] = spacer(num);

        return classes;
    end



    --Entry Templates
    local function DebuffEntryGroup (DebuffName, num, spellID)
        local IsADefault = DefaultDebuffsSkipList[DebuffName] and true;
        return {
            type = "group",
            name = IsADefault and D:ColorText(DebuffName, "FFFFFFFF") or D:ColorText(DebuffName, "FF99FFFF"),
            desc = L["OPT_DEBUFFENTRY_DESC"],
            order = num,
            args = DebuffSubmenu(DebuffName, num, spellID),
        }
    end

    local AddFunc = function (spellID)
        local newDebuff = GetSpellName(spellID);
        if newDebuff then
            DebuffsSkipList[newDebuff] = spellID;
            D:Debug("'%s' added to debuff skip list", newDebuff, spellID);
        elseif not newDebuff then
            error("Can't add debuff, invalid spellID:", spellID);
        end
    end


    local ReAddDefaultsDebuffs = function ()

        for Debuff, spellID in pairs(DefaultDebuffsSkipList) do

            if not DebuffsSkipList[Debuff] then

                DebuffsSkipList[Debuff] = spellID;

                ResetFunc({["Debuff"] = Debuff});

            end
        end

    end

    local CheckDefaultsPresence = function ()
        for Debuff, _ in pairs(DefaultDebuffsSkipList) do
            if not DebuffsSkipList[Debuff] then
                return false;
            end
        end
        return true;
    end

    local DebuffHistTable = {};
    local First = "";

    local GetHistoryDebuff = function ()
        local coloredDebuffName, exists, spellID, index;

        for index=1, DC.DebuffHistoryLength do
            coloredDebuffName, spellID, exists = D:Debuff_History_Get (index, true);

            if not exists or index == 1 and coloredDebuffName == First then
                break;
            end

            if index == 1 then
                First = coloredDebuffName;
            end

            DebuffHistTable[index] = {coloredDebuffName, spellID};
            index = index + 1;
        end

        return DebuffHistTable;
    end

    local updateFilteredDebuffNames_ONCE;
    local noop = function() D:Debug("no op"); end;
    updateFilteredDebuffNames_ONCE = function ()
        local debuffSkipListCopy = {};
        local realName;
        D:tcopy(debuffSkipListCopy, DebuffsSkipList);
        for debuffName, spellID in pairs(debuffSkipListCopy) do
            if spellID ~= false then -- leave removed default spells
                if spellID ~= 0 and not C_Spell.DoesSpellExist(spellID) then
                    RemoveFunc({["Debuff"] = debuffName});
                else
                    realName = GetSpellName(spellID);
                    if realName and realName ~= debuffName then
                        DebuffsSkipList[debuffName] = nil;
                        DebuffsSkipList[realName] = spellID;
                        D:Debug(debuffName, "replaced by", realName, "for DebuffsSkipList");

                        if DebuffAlwaysSkipList[debuffName] then
                            DebuffAlwaysSkipList[debuffName] = nil;
                            DebuffAlwaysSkipList[realName] = true;
                            D:Debug(debuffName, "replaced by", realName, "for DebuffAlwaysSkipList");
                        end

                        for class, debuffs in pairs(skipByClass) do
                            if debuffs[debuffName] then
                                debuffs[debuffName] = nil;
                                debuffs[realName] = true;
                                D:Debug(debuffName, "replaced by", realName, "for class:", class);
                            end
                        end

                        D:Print((L["OPT_FILTERED_DEBUFF_RENAMED"]):format(debuffName, realName, spellID));
                    elseif not realName then
                        D:Debug(realName, "no name for spell ID", spellID, GetSpellName(spellID))
                    end
                end
            end
        end
        debuffSkipListCopy = nil;
        if realName then
            updateFilteredDebuffNames_ONCE = noop;
        end
    end

    function D:CreateFiltersMenu()
        DebuffsSkipList             = D.profile.DebuffsSkipList;
        DefaultDebuffsSkipList      = D.defaults.profile.DebuffsSkipList;

        skipByClass                 = D.profile.skipByClass;
        DebuffAlwaysSkipList        = D.profile.DebuffAlwaysSkipList;
        DefaultSkipByClass          = D.defaults.profile.skipByClass;

        local DebuffsSubMenu = {};
        local num = 1;


        DebuffsSubMenu["debuffHolder"] = {
            name = L["OPT_DEBUFFFILTER"],
            type = "group",
            order = 200,
            args = {}
        }

       updateFilteredDebuffNames_ONCE();

        for debuffName, spellID in pairs(DebuffsSkipList) do
            if false ~= spellID then
                DebuffsSubMenu.debuffHolder.args[str_gsub(debuffName, " ", "")] = DebuffEntryGroup(debuffName, num, spellID);
                num = num + 1;
            end
        end

        DebuffsSubMenu["description"] = {
            type = "description",
            name = L["OPT_DEBUFFFILTER_DESC"],
            order = 0,
        };
        num = num + 1;

        DebuffsSubMenu["add"] = {
            type = "input",
            name = D:ColorText(L["OPT_ADDDEBUFF"], "FFFF3300"),
            desc = L["OPT_ADDDEBUFF_DESC"],
            usage = L["OPT_ADDDEBUFF_USAGE"],
            get = false,
            set = function(info,v) AddFunc(tonumber(v)) end,
            validate = function(info, v)

                if tonumber(v) and C_Spell.DoesSpellExist(tonumber(v)) then
                    return 0;
                else
                    return error("'", v, "'", L["OPT_ISNOTVALID_SPELLID"]);
                end
            end,
            order = 100 + num,
        };

        num = num + 1;

        DebuffsSubMenu["addFromHist"] = {
            type = "select",
            name = L["OPT_ADDDEBUFFFHIST"], --"Add from Debuff history",
            desc = L["OPT_ADDDEBUFFFHIST_DESC"], --"Add a recently dispelled debuff",
            disabled = function () GetHistoryDebuff(); return (#DebuffHistTable == 0) end,
            values = function () return D:tMap(GetHistoryDebuff(), function (debuff) return debuff[1] end) end;
            get = function() GetHistoryDebuff(); return false; end,
            set = function(info,value)
                local debuffName, spellID = unpack(GetHistoryDebuff()[value]);
                AddFunc(spellID ~= 0 and spellID or (D:RemoveColor(debuffName) == "Test item" and 1243 or 0));
            end,
            order = 100 + num,
        };


        local ReaddIsDisabled = CheckDefaultsPresence();
        num = num + 1;
        DebuffsSubMenu["ReAddDefaults"] = {
            type = "execute",
            name = not ReaddIsDisabled and D:ColorText(L["OPT_READDDEFAULTSD"], "FFA75728") or L["OPT_READDDEFAULTSD"],
            desc = not ReaddIsDisabled and L["OPT_READDDEFAULTSD_DESC1"]
            or L["OPT_READDDEFAULTSD_DESC2"],
            func = ReAddDefaultsDebuffs,
            disabled = CheckDefaultsPresence;
            order = 100 + num,
        };

        return DebuffsSubMenu;
    end
end

do

    local tonumber = _G.tonumber;
    local L_MF_colors = {};

    local function GetNameAndDesc (ColorReason) -- {{{
        local name, desc;

        L_MF_colors = D.profile.MF_colors;

        if (type(ColorReason) == "number" and ColorReason <= 7) then

            name = D:ColorText(  ("%s (%s)"):format( L["OPT_CURE_PRIORITY_NUM"]:format(ColorReason), DC.MouseButtonsReadable[D.db.global.MouseButtons[ColorReason] ])  , D:NumToHexColor(L_MF_colors[ColorReason]));
            desc = (L["COLORALERT"]):format(DC.MouseButtonsReadable[D.db.global.MouseButtons[ColorReason] ]);

        elseif (type(ColorReason) == "number")      then
            local Text = "";

            if (ColorReason == DC.NORMAL)           then
                Text =  L["NORMAL"];

            elseif (ColorReason == DC.ABSENT)       then
                Text =  L["MISSINGUNIT"];

            elseif (ColorReason == DC.FAR)          then
                Text =  L["TOOFAR"];

            elseif (ColorReason == DC.STEALTHED)    then
                Text =  L["STEALTHED"];

            elseif (ColorReason == DC.BLACKLISTED)  then
                Text =  L["BLACKLISTED"];

            elseif (ColorReason == DC.CHARMED_STATUS) then
                Text =  L["CHARM"];
            end

            name = ("%s %s"):format(L["UNITSTATUS"], D:ColorText(Text, D:NumToHexColor(L_MF_colors[ColorReason])) );
            desc = (L["COLORSTATUS"]):format(Text);

        elseif (type(ColorReason) == "string") then


            if ColorReason == "COLORCHRONOS" then
                name = L[ColorReason];
                desc = L["COLORCHRONOS_DESC"];
            else
                name = "AceConfigCmd-3.0 is bugged";
                desc = "type /decursive to use the graphical UI";
                --D:Debug("ColorReason:", ColorReason);
            end
        end

        return {name, desc};
    end -- }}}

    local retrieveColorReason = function(info)
        local ColorReason = str_sub(info[#info], 2);

        if tonumber(ColorReason) then
            return tonumber(ColorReason);
        else
            return ColorReason;
        end
    end

    local GetName = function (info)
        --D:Debug(GetNameAndDesc(retrieveColorReason(info))[1]);
        return GetNameAndDesc(retrieveColorReason(info))[1];
    end

    local GetDesc = function (info)
        return GetNameAndDesc(retrieveColorReason(info))[2];
    end

    local GetOrder = function (info)
        local ColorReason = retrieveColorReason(info);
        return 100 + (type(ColorReason) == "number" and ColorReason * 2 or 4096);
    end

    local function GetColor (info)
        return unpack(D.profile.MF_colors[retrieveColorReason(info)]);
    end

    local function SetColor (info, r, g, b, a)

        local ColorReason = retrieveColorReason(info);

        D.profile.MF_colors[ColorReason] = {r, g, b, (a and a or 1)};
        D.MicroUnitF:RegisterMUFcolors();
        L_MF_colors = D.profile.MF_colors;

        D.MicroUnitF:Delayed_Force_FullUpdate();

        D:Debug("MUF color setting changed:", ColorReason);
    end

    local ColorPicker = {
        type = "color",
        name = GetName,
        desc = GetDesc,
        hasAlpha = true,
        order = GetOrder,

        get = GetColor,
        set = SetColor,
    };

    function D:CreateDropDownMUFcolorsMenu(MUFsColors_args)
        L_MF_colors = D.profile.MF_colors;
        -- /dump  LibStub("AceAddon-3.0"):GetAddon("Decursive").db.profile.MF_colors
        for ColorReason, Color in pairs(L_MF_colors) do

            if not L_MF_colors[ColorReason][4] then
                D.profile.MF_colors[ColorReason][4] = 1;
            end

            -- add a separator for the different color typs when necessary.
            if (type(ColorReason) == "number" and ColorReason == DC.NORMAL) or (type(ColorReason) == "string" and ColorReason == "COLORCHRONOS") then
                MUFsColors_args["S" .. ColorReason] = {
                    type = "header",
                    name = "",
                    order = function (info) return GetOrder(info) - 1 end,
                }
                --D:Debug("Created space ", "Space" .. ColorReason, "at ", MUFsColors_args["S" .. ColorReason].order);
            end


            MUFsColors_args["c"..ColorReason] = ColorPicker;

        end
    end
end
do
    local infoPrefix = "cAffliction_";
    local orderStart = 4096 + 200;

    local function retrieveAffTypeFromInfo(info)
        return tonumber((info[#info]):sub(#infoPrefix + 1));
    end

    local function GetAffTypeName(info)
        return L[DC.TypeToLocalizableTypeNames[retrieveAffTypeFromInfo(info)]];
    end

    local function GetAffTypeDesc(info)
        local affName = L[DC.TypeToLocalizableTypeNames[retrieveAffTypeFromInfo(info)]];
        return L["OPT_SETAFFTYPECOLOR_DESC"]:format(affName);
    end

    local function GetAffTypeOrder(info)
        return orderStart + retrieveAffTypeFromInfo(info);
    end

    local function GetAffTypeColor(info)
        return unpack( D:HexColorToNum(D.profile.TypeColors[retrieveAffTypeFromInfo(info)]));
    end

    local function SetAffTypeColor(info, r, g, b, a)
        local affType = retrieveAffTypeFromInfo(info);

        D.profile.TypeColors[affType] = D:NumToHexColor({r, g, b, (a and a or 1)});
        D:Debug("Affliction type color ", affType, "set to", D.profile.TypeColors[affType]);
    end

    local afflictionColorPicker = {
        type = "color",
        name = GetAffTypeName,
        desc = GetAffTypeDesc,
        hasAlpha = true,
        order = GetAffTypeOrder,

        get = GetAffTypeColor,
        set = SetAffTypeColor,
    };

    function D:CreateAfflictionColorsMenu(MUFsColors_args)
        local TypeColors = D.profile.TypeColors;

        MUFsColors_args[infoPrefix.."0"] = {
            type = "header",
            name = "",
            order = GetAffTypeOrder,
        }

        for afflictionType, Color in pairs(TypeColors) do
            if afflictionType ~= DC.NOTYPE then
                MUFsColors_args[infoPrefix..afflictionType] = afflictionColorPicker;
            end
        end
    end

end

-- Modifiers order choosing dynamic menu creation
do

    local orderStart = 152;
    local tonumber = _G.tonumber;

    local TempTable = {};
    local i = 1;

    local function retrieveKeyComboNum (info)
        return tonumber(str_sub(info[#info], 9));
        -- #"KeyCombo" == 8
    end

    local function GetValues (info) -- {{{

        if retrieveKeyComboNum (info) == 1 then
            table.wipe(TempTable);

            for i=1, #D.db.global.MouseButtons do
                TempTable[i] = D:ColorText(DC.MouseButtonsReadable[D.db.global.MouseButtons[i]],
                        i < 7 and D:NumToHexColor(D.profile.MF_colors[i]) -- defined priorities
                        or (i >= #D.db.global.MouseButtons - 1 and "FFFFFFFF" -- target and focus
                        or "FFBBBBBB") -- other unused buttons
                    );
            end
        end

        return TempTable;
    end -- }}}

    local function GetOrder (info)
        return orderStart + retrieveKeyComboNum (info);
    end

    local OptionPrototype = {
        -- {{{
        type = "select",
        name = function (info)
            if not retrieveKeyComboNum (info) then return "" end -- needed because when called by command line, info is set to the parent

            if retrieveKeyComboNum (info) < #D.db.global.MouseButtons - 1 then
                return D:ColorText(L["OPT_CURE_PRIORITY_NUM"]:format(retrieveKeyComboNum (info)),  D:NumToHexColor(D.profile.MF_colors[retrieveKeyComboNum (info)]));
            elseif  retrieveKeyComboNum (info) == #D.db.global.MouseButtons - 1 then
                return L["OPT_MUFTARGETBUTTON"];
            else
                return L["OPT_MUFFOCUSBUTTON"];
            end
        end,
        values = GetValues,
        order = GetOrder,
        get = function (info)
            return retrieveKeyComboNum (info);
        end,
        set = function (info, value)

            local ThisKeyComboNum = retrieveKeyComboNum (info);


            if value ~= ThisKeyComboNum then -- we would destroy the table

                D:tSwap(D.db.global.MouseButtons, ThisKeyComboNum, value);

                -- force all MUFs to update their attributes
                D.Status.SpellsChanged = GetTime();
            end
        end,
        style = "dropdown",
        -- }}}
    };

    function D:CreateModifierOptionMenu ()
        local key_Combos_Select = {
            -- {{{
            ClicksAdssigmentsDesc = {
                type = "description",
                name = L["OPT_MUFMOUSEBUTTONS_DESC"],
                order = 151,
            },
            ResetClicksAdssigments = {
                type = "execute",
                confirm = true,
                name = L["OPT_RESETMUFMOUSEBUTTONS"],
                desc = L["OPT_RESETMUFMOUSEBUTTONS_DESC"],
                func = function ()
                    table.wipe(D.db.global.MouseButtons);
                    D:tcopy(D.db.global.MouseButtons, D.defaults.global.MouseButtons);
                    -- force all MUFs to update their attributes
                    D.Status.SpellsChanged = GetTime();
                end,
                order = -1,
            },
            -- }}}
        };

        for i = 1, 7 do
            key_Combos_Select["KeyCombo" .. i] = OptionPrototype;
        end

        -- create choice munu for targeting (it's always the last but one available button)
        key_Combos_Select["KeyCombo" .. #D.db.global.MouseButtons - 1] = OptionPrototype;
        -- create choice munu for focusing (it's always the last available button)
        key_Combos_Select["KeyCombo" .. #D.db.global.MouseButtons] = OptionPrototype;

        return key_Combos_Select;
    end

end

do

    local t_insert      = _G.table.insert;
    local IsSpellKnown  = nil; -- use D:isSpellReady instead

    local order = 160;

    local function isSpellUSable (spellID)

        local spell = D.classprofile.UserSpells[spellID];

        if not spell.IsItem and spellID > 0 then
            return D:isSpellReady(spellID, spell.Pet)
        else
            return D:isItemUsable(spellID * -1)
        end
    end


    local function GetColoredName(spellID)
        local spell = D.classprofile.UserSpells[spellID];

        if not spell then
            D:AddDebugText('GetColoredName(): invalid spellID:', spellID);
            return tostring(spellID);
        end

        local name = D.GetSpellOrItemInfo(spellID) or "WTF!?!";
        local color = 'FFFFFFFF';

        if spell.Disabled then
            color = 'FFAA0000';
        elseif not D.Status.CuringSpellsPrio[name] then
            color = 'FF909090';
        else
            color = 'FF00D000';
        end

        if not isSpellUSable(spellID) then
            name = ("(%s) %s"):format(L["OPT_CUSTOM_SPELL_UNAVAILABLE"], name);
            color = 'FF606060';
        end

        return D:ColorText(name .. ((spell and spell.MacroText) and "|cFFFF0000*|r" or ""), color);

    end

    local TypeOption = {
        type = "toggle",
        name = function(info) return L[info[#info]] end,
        get = function(info)
            return D:tcheckforval(D.classprofile.UserSpells[TN(info[#info-2])].Types,  DC.LocalizableTypeNamesToTypes[info[#info]])
        end,
        set = function(info, v)
            local spellTableTypes = D.classprofile.UserSpells[TN(info[#info-2])].Types
            local curetype = DC.LocalizableTypeNamesToTypes[info[#info]]
            D:Debug("TypeOption: checkingtable named:", info[#info-2], "for", info[#info], "CureType:", curetype);

            if v and not D:tcheckforval(spellTableTypes, curetype) then
                t_insert(spellTableTypes, curetype)
            elseif not v then
                D:tremovebyval(spellTableTypes, curetype);
                -- also clear the unit filtering settings if it exists
                if D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering then
                    D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering[DC.LocalizableTypeNamesToTypes[info[#info]]] = nil;
                end
            end
            if not D.classprofile.UserSpells[TN(info[#info-2])].Disabled and isSpellUSable(TN(info[#info-2])) then
                D:ScheduleDelayedCall("Dcr_Delayed_Configure", D.Configure, 2, D);
            end
        end,
        disabled = function (info) -- disable types edition if an enhancement is active (default types are not used in that case)
            if D.classprofile.UserSpells[TN(info[#info-2])] and D.classprofile.UserSpells[TN(info[#info-2])].EnhancedByCheck then
                return D.classprofile.UserSpells[TN(info[#info-2])].EnhancedByCheck();
            end

            --if DC.SpellsToUse[TN(info[#info-2])] and D:tcheckforval(DC.SpellsToUse[TN(info[#info-2])].Types, DC.LocalizableTypeNamesToTypes[info[#info]]) then
            --    return true;
            --end

            return false;
        end,
        order = function() return order; end,
    }

    local typeUnitFilteringOption = {
        type = 'select',
        style = "dropdown",
        name = function(info) return L[info[#info]] end,
        desc = L["OPT_CUSTOM_SPELL_UNIT_FILTER_DESC"],
        values = {[0] = L["OPT_CUSTOM_SPELL_UNIT_FILTER_NONE"], [1] = L["OPT_CUSTOM_SPELL_UNIT_FILTER_PLAYER"], [2] = L["OPT_CUSTOM_SPELL_UNIT_FILTER_NONPLAYER"]},
        order = function() return order; end,

        hidden = function (info)
            -- hide the option when the type is not enabled for this spell
            return not D:tcheckforval(D.classprofile.UserSpells[TN(info[#info-2])].Types,  DC.LocalizableTypeNamesToTypes[info[#info]])
        end,

        get = function(info)
            if not D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering
                or not D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering[DC.LocalizableTypeNamesToTypes[info[#info]]] then
                return 0;
            else
                return D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering[DC.LocalizableTypeNamesToTypes[info[#info]]];
            end
        end,
        set = function(info, v)
            if not D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering then
                D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering = {};
            end

            D.classprofile.UserSpells[TN(info[#info-2])].UnitFiltering[DC.LocalizableTypeNamesToTypes[info[#info]]] = v ~= 0 and v or nil;

            if not D.classprofile.UserSpells[TN(info[#info-2])].Disabled and isSpellUSable(TN(info[#info-2])) then
                D:ScheduleDelayedCall("Dcr_Delayed_Configure", D.Configure, 2, D);
            end
        end,

    }

    local SpellSubOptions = {
        type = 'group',
        name = function(info) return GetColoredName(TN(info[#info])) end,
        desc = function(info)
            if DC.SpellsToUse[TN(info[#info])] then
                return L["OPT_CUSTOM_SPELL_IS_DEFAULT"];
            end
            return "";
        end,
        order = function() return order; end,
        args = {
            -- an enable checkbox
            header = {
                type = 'header',
                name = function (info) return ("%s  (id: %d)"):format(GetColoredName(TN(info[#info - 1])), TN(info[#info - 1])); end,
                order = 0,
            },
            enable = {
                type = "toggle",
                name = L["OPT_ENABLE_A_CUSTOM_SPELL"],
                set = function(info,v)
                    D.classprofile.UserSpells[TN(info[#info-1])].Disabled = not v;
                    if v and DC.SpellsToUse[TN(info[#info-1])] then
                        D:Configure();
                        return;
                    end

                    if isSpellUSable(TN(info[#info-1])) then
                        D:ReConfigure();
                    end
                end,
                get = function(info,v)
                    return not D.classprofile.UserSpells[TN(info[#info-1])].Disabled;
                end,
                order = 100
            },
            isPet = {
                type = "toggle",
                name = L["OPT_CUSTOM_SPELL_ISPET"],
                desc = L["OPT_CUSTOM_SPELL_ISPET_DESC"];
                set = function(info,v)

                    D.classprofile.UserSpells[TN(info[#info-1])].Pet = v;

                    --if isSpellUSable(TN(info[#info-1])) then
                    D:ScheduleDelayedCall("Dcr_Delayed_Configure", D.Configure, 2, D);
                    --end
                end,
                get = function(info,v)
                    return D.classprofile.UserSpells[TN(info[#info-1])].Pet;
                end,
                hidden = function (info) return D.classprofile.UserSpells[TN(info[#info-1])].IsItem end,
                order = 105
            },
            cureTypes = {
                type = 'group',
                name = L["OPT_CUSTOM_SPELL_CURE_TYPES"],
                order = 105,
                inline = true,

                args={},
                order = 106
            },
            UnitFiltering = {
                type = 'group',
                name = L["OPT_CUSTOM_SPELL_UNIT_FILTER"],
                order = 107,
                inline = true,

                args={},
                order = 107
            },
            priority = {
                type = 'range',
                name = L["OPT_CUSTOM_SPELL_PRIORITY"],
                desc = L["OPT_CUSTOM_SPELL_PRIORITY_DESC"],
                get = function (info) return D.classprofile.UserSpells[TN(info[#info-1])].Better end,
                set = function (info, v)
                    D.classprofile.UserSpells[TN(info[#info-1])].Better = v;
                    if not D.classprofile.UserSpells[TN(info[#info-1])].Disabled then
                        D:ScheduleDelayedCall("Dcr_Delayed_Configure", D.Configure, 2, D);
                    end
                end,
                min = -10,
                max = 30,
                step = 1,
                order = 110,
            },


            MacroEdition = {
                type = 'input',
                name = L["OPT_CUSTOM_SPELL_MACRO_TEXT"],
                usage = L["OPT_CUSTOM_SPELL_MACRO_TEXT_DESC"],
                multiline = true,
                width = 'full',
                hidden = function(info,v) return not D.classprofile.UserSpells[TN(info[#info-1])].MacroText end,

                get = function(info,v)
                    return D.classprofile.UserSpells[TN(info[#info-1])].MacroText;
                end,

                set = function (info,v)
                    if v:find("UNITID") and (v:gsub("UNITID", "PARTYPET5")):len() < 256 then
                        D.classprofile.UserSpells[TN(info[#info-1])].MacroText = v;

                        if D.Status.FoundSpells[D.GetSpellOrItemInfo(TN(info[#info - 1]))] then
                            D.Status.FoundSpells[D.GetSpellOrItemInfo(TN(info[#info-1]))][5] = v;
                            D.Status.SpellsChanged = GetTime(); -- will force an update of all MUFs attributes
                            D:Debug("Attribute update triggered");
                        end
                    end
                end,

                validate = function (info, v)
                    local error = function (m) D:ColorPrint(1, 0, 0, m); return m; end;

                    if type(v) ~= 'string' then -- this should be impossible
                        return error("What did you do?!?");
                    end

                    local length = (v:gsub("UNITID", "PARTYPET5")):len()

                    if length > 255 then
                        return error((L["OPT_CUSTOM_SPELL_MACRO_TOO_LONG"]):format( length - 255));
                    end

                    if not v:find("UNITID") then
                        return error(L["OPT_CUSTOM_SPELL_MACRO_MISSING_UNITID_KEYWORD"]);
                    end

                    if not v:find(D.GetSpellOrItemInfo(TN(info[#info-1])), 0, true) then
                        T._ShowNotice(error((L["OPT_CUSTOM_SPELL_MACRO_MISSING_NOMINAL_SPELL"]):format((D.GetSpellOrItemInfo(TN(info[#info-1]))))));
                    end

                    return 0;
                end,

                order = 115
            },
            -- a delete button
            delete = {
                type = 'execute',
                name = function(info) return ("%s %q"):format(L["OPT_DELETE_A_CUSTOM_SPELL"], D.GetSpellOrItemInfo(TN(info[#info - 1])) or "BAD SPELL!") end,
                confirm = true,
                width = 'double',
                func = function (info)

                    if (#info ~= 0) then -- prevent a bug from Ace3 when someone pushes several times on the delete without confirming
                        if D.classprofile.UserSpells[TN(info[#info - 1])].IsDefault then
                            D.classprofile.UserSpells[TN(info[#info - 1])].Types = {};
                            D.classprofile.UserSpells[TN(info[#info - 1])].Hidden = true;
                        else
                            D.classprofile.UserSpells[TN(info[#info - 1])] = nil;
                        end

                        if D.Status.FoundSpells[D.GetSpellOrItemInfo(TN(info[#info - 1]))] then
                            D:Configure();
                        end
                    end
                end,
                order = -1,
            },
            -- one checkbox per type
        },

    };

    function D:CreateAddedSpellsOptionMenu (where)

        -- create type slectors
        local TypesSelector = {};

        for localizableTypeName, curetype in pairs(DC.LocalizableTypeNamesToTypes) do
            TypesSelector[localizableTypeName] = TypeOption;
            order = order + 1;
        end

        SpellSubOptions.args.cureTypes.args = TypesSelector;

        -- create unitFiltering by type
        local UnitFilteringTypeSelector = {};
        for localizableTypeName, curetype in pairs(DC.LocalizableTypeNamesToTypes) do
            UnitFilteringTypeSelector[localizableTypeName] = typeUnitFilteringOption;
            order = order + 1;
        end

        SpellSubOptions.args.UnitFiltering.args = UnitFilteringTypeSelector;

        -- create each spell option table
        for spellID, spellTable in pairs(self.classprofile.UserSpells) do
            if not spellTable.Hidden then
                where[tostring(spellID)] = SpellSubOptions;
                order = order + 1;
            end
        end

    end
end

do
    local t_BleedEffectsIDCheck = {};
    local t_DefaultBleedEffectsIDCheck = {};
    local t_CheckBleedDebuffsActiveIDs = {};
    local noCasekeywordPatterns = "";

    local tw_spell_desc_cache = setmetatable({}, {
        __index = function(table, spellID)
            --D:Debug("metatable __index called with ", spellID);
            local desc = C_Spell.DoesSpellExist(spellID) and GetSpellDescription(spellID) or L["OPT_BLEED_EFFECT_UNKNOWN_SPELL"]:format(spellID);

            if desc ~= "" then
                table[spellID] = desc;
            elseif not C_Spell.IsSpellDataCached(spellID) then
                C_Spell.RequestLoadSpellData(spellID);
                desc =  L["OPT_SPELL_DESCRIPTION_LOADING"];

                D:Debug("delayed Bleed Effect option panel refresh scheduled because of spellID: ", spellID);
                D:ScheduleDelayedCall("refreshBleedEffectList", function () LibStub("AceConfigRegistry-3.0"):NotifyChange(D.name) end, 2);

            else
                desc = L["OPT_SPELL_DESCRIPTION_UNAVAILABLE"];
                table[spellID] = desc;
            end
            --D:Debug("metatable __index called with ", spellID, "desc:", desc);
            return desc;
        end;
    });

    local tw_spell_name_cache = setmetatable({}, {
        __index = function(table, spellID)
            local spellName = C_Spell.DoesSpellExist(spellID) and D.GetSpellOrItemInfo(spellID) or false;
            table[spellID] = spellName;
            return spellName;
        end
    });
    local order = 0;

    function D:hasDescBleedEffectkeyword(desc, test_pattern, testAll)
        local P_BleedEffectsKeywords_noCase = test_pattern and test_pattern or D.Status.P_BleedEffectsKeywords_noCase;

        local hasMatch = false;

        local success, errorMessage = pcall(function()
            for pattern in P_BleedEffectsKeywords_noCase:gmatch("[^\n\r]+") do
                if desc:find(pattern) then
                    hasMatch = true;
                    if not testAll then
                        break;
                    end
                end
            end
        end);

        return hasMatch, errorMessage;
    end

    local function higlightkeywords(desc, test_pattern)
        local highlightedDesc = desc;

        if D.Status.P_BleedEffectsKeywords_noCase ~= false then
            for pattern in D.Status.P_BleedEffectsKeywords_noCase:gmatch("[^\n\r]+") do
                pcall(function()
                    highlightedDesc =
                    highlightedDesc:gsub(pattern, function (identifier) return ("|cFFFF0077%s|r"):format(identifier) end);
                end)
            end
        end

        return highlightedDesc;
    end

    local function GetBleedEffectColoredName(spellID) -- {{{
        local descHasID = D:hasDescBleedEffectkeyword(tw_spell_desc_cache[spellID]);
        local name = tw_spell_name_cache[spellID];
        local color = 'FFFFFFFF';

        if name then
            if not t_BleedEffectsIDCheck[spellID] then
                color = 'FFAA0000';
            else
                color = 'FF00D000';
            end
        else
            color = 'FFA0A0A0';
        end

        return D:ColorText(name and ((not descHasID and "|cFFFF0000?|r " or "") .. name) or L["OPT_BLEED_EFFECT_UNKNOWN_SPELL"]:format(spellID), color);
    end -- }}}

    local bleedEffectEntry = { -- {{{
        type = 'group',
        name = function(info) return GetBleedEffectColoredName(TN(info[#info])) end,
        desc = function () return false; end,
        order = function() return order; end,
        args = {
            header = {
                type = 'header',
                name = function (info)
                    return L["OPT_BLEED_EFFECT_DESCRIPTION"]:format(info[#info - 1]);
                end,
                order = 0,
            },
            desc = {
                type = 'description',
                name = function (info)
                    return higlightkeywords(tw_spell_desc_cache[TN(info[#info - 1])])
                end,
                order = 10,
            },
            isBleedEffect = {
                type = 'toggle',
                name = L["OPT_IS_BLEED_EFFECT"],
                desc = L["OPT_IS_BLEED_EFFECT_DESC"],
                set = function(info, v)
                    t_BleedEffectsIDCheck[TN(info[#info - 1])] = v;
                    t_CheckBleedDebuffsActiveIDs[TN(info[#info - 1])] = v;

                    return t_BleedEffectsIDCheck[TN(info[#info - 1])];
                end,
                get = function(info)
                    return t_BleedEffectsIDCheck[TN(info[#info - 1])];
                end,
                order = 20,
            },
            remove = {
                type = 'execute',
                name = L["OPT_DELETE_A_CUSTOM_SPELL"],
                set = function(info, v)
                    return t_BleedEffectsIDCheck[TN(info[#info - 1])]
                end,
                confirm = true,
                func = function (info)
                    local toRemove = TN(info[#info - 1]);
                    t_BleedEffectsIDCheck[toRemove] = t_DefaultBleedEffectsIDCheck[toRemove] and -1 or nil;
                    D:Debug('XXXX',t_BleedEffectsIDCheck[toRemove]  );
                    t_CheckBleedDebuffsActiveIDs[toRemove] = nil;
                end,
                order = 30,
            },


        },
    }; -- }}}

    function D:CreateBleedingDebuffsOptionMenu(where)
        t_BleedEffectsIDCheck = D.db.global.t_BleedEffectsIDCheck;
        t_DefaultBleedEffectsIDCheck = D.defaults.global.t_BleedEffectsIDCheck;
        t_CheckBleedDebuffsActiveIDs = D.Status.t_CheckBleedDebuffsActiveIDs;
        noCasekeywordPatterns = D.Status.P_BleedEffectsKeywords_noCase

        for spellID, enabled in pairs(t_BleedEffectsIDCheck) do
            if enabled ~= -1 then
                where[tostring(spellID)] = bleedEffectEntry;
            end
        end

        where["resetListToDefaults"] = {
            type = 'execute',
            name = "|cFFFF0000" .. L["OPT_RESET_DEFAULT_BLEED_EFFECTS"] .. "|r",
            desc = L["OPT_RESET_DEFAULT_BLEED_EFFECTS_DESC"],
            func = function()
                D.Status.t_CheckBleedDebuffsActiveIDs = {};
                table.wipe(D.db.global.t_BleedEffectsIDCheck);

                D:readdDefaultsBleedEffects();
            end,
            confirm = true,
            disabled = function () return not D.Status.CuringSpells[DC.BLEED] end,
            order = -1,
        };
        where["readdDefaults"] = {
            type = 'execute',
            confirm = true,
            name = L["OPT_READD_DEFAULT_BLEED_EFFECTS"],
            desc = L["OPT_READD_DEFAULT_BLEED_EFFECTS_DESC"],
            func = function()
                D:readdDefaultsBleedEffects();
            end,
            disabled = function () return not D.Status.CuringSpells[DC.BLEED] end,
            order = 0,
        };
    end

    function D:reset_t_CheckBleedDebuffsActiveIDs()
        D.Status.t_CheckBleedDebuffsActiveIDs = {};
        for spellID, isBleed in pairs(D.db.global.t_BleedEffectsIDCheck) do
            if isBleed ~= -1 then
                D.Status.t_CheckBleedDebuffsActiveIDs[spellID] = isBleed;
            end
        end
    end

    function D:GetDefaultBleedEffectsKeywords()
        local keywords;

        -- ENCOUNTER_JOURNAL_SECTION_FLAG13 is equal to Bleed but it appears that
        -- many "bleeding" effect do not contain this term but rather 'Physical' so we use both.
        if _G.STRING_SCHOOL_PHYSICAL then
            local cleanedSchoolPhysical = (_G.STRING_SCHOOL_PHYSICAL:gsub("%A", ""))

            keywords = cleanedSchoolPhysical ~= "" and cleanedSchoolPhysical or _G.STRING_SCHOOL_PHYSICAL;

            if _G.ENCOUNTER_JOURNAL_SECTION_FLAG13 then
                local cleanedEJSF13 = (_G.ENCOUNTER_JOURNAL_SECTION_FLAG13:gsub("%A", ""))

                keywords = keywords .. "\n" .. (cleanedEJSF13 ~= "" and cleanedEJSF13 or _G.ENCOUNTER_JOURNAL_SECTION_FLAG13);
            else
                keywords = keywords .. "\n" .. L["BLEED"]
            end
        end

        return keywords:trim();
    end

    function D:readdDefaultsBleedEffects()
        local defaults = D.defaults.global.t_BleedEffectsIDCheck;
        local t_BleedEffectsIDCheck = D.db.global.t_BleedEffectsIDCheck;
        local t_CheckBleedDebuffsActiveIDs = D.Status.t_CheckBleedDebuffsActiveIDs;

        for spellID, isBleed in pairs(defaults) do
            t_BleedEffectsIDCheck[spellID] = isBleed;
            t_CheckBleedDebuffsActiveIDs[spellID] = isBleed;
        end
    end
end

-- to test on 2.3 : /script D:PrintLiteral(GetBindingAction(D.db.global.MacroBind));
-- to test on 2.3 : /script D:PrintLiteral(GetBindingKey(D.CONF.MACROCOMMAND));
local SaveBindings = _G.SaveBindings or _G.AttemptToSaveBindings; -- was renamed for WOW Classic, it might happen too on retail...

function D:SetMacroKey ( key )

    -- if the key is already correctly mapped, return here.
    --if (key and key == D.db.global.MacroBind and GetBindingAction(key) == D.CONF.MACROCOMMAND) then
    if D.profile.DisableMacroCreation or key and key == D.db.global.MacroBind and D:tcheckforval({GetBindingKey(D.CONF.MACROCOMMAND)}, key) then -- change for 2.3 where GetBindingAction() is no longer working
        return;
    end

    -- if the current set key is currently mapped to Decursive macro (it means we are changing the key)
    --if (D.profile.MacroBind and GetBindingAction(D.profile.MacroBind) == D.CONF.MACROCOMMAND) then
    if (D.db.global.MacroBind and D:tcheckforval({GetBindingKey(D.CONF.MACROCOMMAND)}, D.db.global.MacroBind) ) then -- change for 2.3 where GetBindingAction() is no longer working

        -- clearing redudent mapping to Decursive macro.
        local MappedKeys = {GetBindingKey(D.CONF.MACROCOMMAND)};
        for _, key in pairs(MappedKeys) do
            D:Debug("Unlinking [%s]", key);
            SetBinding(key, nil); -- clear the binding
        end

        -- Restore previous key state
        if (D.profile.PreviousMacroKeyAction) then
            D:Debug("Previous key action restored:", D.profile.PreviousMacroKeyAction);
            if not SetBinding(D.db.global.MacroBind, D.profile.PreviousMacroKeyAction) then
                --  /script SetBinding ("BUTTON1", "CAMERAORSELECTORMOVE"); to communicate to people who accidently set BUUTON1 to our macro.
                D:Debug("Restoration failed");
            end
        end
    end


    if (key) then
        if (GetBindingAction(key) ~= "" and GetBindingAction(key) ~= D.CONF.MACROCOMMAND) then
            -- save current key assignement
            D.profile.PreviousMacroKeyAction = GetBindingAction(key)
            D:Debug("Old key action saved:", D.profile.PreviousMacroKeyAction);
            D:errln(L["MACROKEYALREADYMAPPED"], key, D.profile.PreviousMacroKeyAction);
        else
            D.profile.PreviousMacroKeyAction = false;
            D:Debug("Old key action not saved because it was mapped to nothing");
        end

        -- set
        if (SetBindingMacro(key, D.CONF.MACRONAME)) then
            D.db.global.MacroBind = key;
            D:Println(L["MACROKEYMAPPINGSUCCESS"], key);
        else
            D:errln(L["MACROKEYMAPPINGFAILED"], key);
        end
    else
        D.db.global.MacroBind = false;
        if D.profile.NoKeyWarn and not GetBindingKey(D.CONF.MACROCOMMAND) then
            D:errln(L["MACROKEYNOTMAPPED"]);
        end
    end

    -- save the bindings to disk
    if GetCurrentBindingSet()==1 or GetCurrentBindingSet()==2 then -- GetCurrentBindingSet() may return strange values when the game is loaded without WTF folder.
        SaveBindings(GetCurrentBindingSet());
    end

end

function D:AutoHideShowMUFs ()

    -- This function cannot do anything if we are fighting
    if (InCombatLockdown()) then
        -- if we are fighting, postpone the call
        D:AddDelayedFunctionCall (
        "CheckIfHideShow", self.AutoHideShowMUFs,
        self);
        return false;
    end

    if D.profile.AutoHideMUFs == 1 then
        return false;
    else
        local hideBecauseInSolo          = D.profile.AutoHideMUFs == 2 and GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0
        local hideBecauseInSoloOrParty   = D.profile.AutoHideMUFs == 3 and GetNumRaidMembers() == 0
        local hideBecauseInRaids         = D.profile.AutoHideMUFs == 4 and GetNumRaidMembers() ~= 0

        local shouldHide = hideBecauseInSolo or hideBecauseInSoloOrParty or hideBecauseInRaids

        -- local InGroup = (GetNumRaidMembers() ~= 0 or (D.profile.AutoHideMUFs ~= 3 and GetNumPartyMembers() ~= 0) );
        D:Debug("AutoHideShowMUFs:", shouldHide, hideBecauseInSolo, hideBecauseInSoloOrParty, hideBecauseInRaids);

        if shouldHide then
            -- if the frame is displayed
            if D.profile.ShowDebuffsFrame then
                -- hide it
                D:ShowHideDebuffsFrame ();
            end
        else
            -- if the frame is not displayed
            if not D.profile.ShowDebuffsFrame then
                -- show it
                D:ShowHideDebuffsFrame ();
            end
        end

        return true;
    end
end

function D:QuickAccess (CallingObject, button) -- {{{
    --D:Debug("clicked");

    if (not CallingObject) then
        CallingObject = "noframe";
    end

    if (button == "RightButton" and not IsShiftKeyDown()) then

        if (not IsAltKeyDown()) then
            D:Println(L["DEWDROPISGONE"]);
        else
            LibStub("AceConfigDialog-3.0"):Open(D.name);
        end

    elseif (button == "RightButton" and IsShiftKeyDown()) then
        D:HideBar();
    elseif (button == "LeftButton" and IsControlKeyDown()) then
        D:ShowHidePriorityListUI();
    elseif (button == "LeftButton" and IsShiftKeyDown()) then
        D:ShowHideSkipListUI();
    end

end -- }}}


T._LoadedFiles["Dcr_opt.lua"] = "2.7.29";

-- Closer
