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

    This file was last updated on 2025-07-11T09:58:15Z
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
if not T._LoadedFiles or not T._LoadedFiles["enUS.lua"] then
    if not DecursiveInstallCorrupted then T._FatalError("Decursive installation is corrupted! (enUS.lua not loaded)"); end;
    DecursiveInstallCorrupted = true;
    return;
end
T._LoadedFiles["DCR_init.lua"] = false;

local D;
local _G                    = _G;
local select                = _G.select;
local GetSpellInfo          = _G.C_Spell and _G.C_Spell.GetSpellInfo or _G.GetSpellInfo;
local GetSpellName          = _G.C_Spell and _G.C_Spell.GetSpellName or function (spellId) return (GetSpellInfo(spellId)) end;
local IsSpellKnown          = nil; -- use D:isSpellReady instead
local GetSpecialization     = _G.GetSpecialization;
local IsPlayerSpell         = _G.IsPlayerSpell;
local GetAddOnMetadata      = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata;
local GetItemInfo           = _G.C_Item and _G.C_Item.GetItemInfo or _G.GetItemInfo;

local function RegisterDecursive_Once() -- {{{

    T.Dcr = LibStub("AceAddon-3.0"):NewAddon("Decursive", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0"); -- XXX test this when a library is missing
    D     = T.Dcr;

    --[==[@debug@
    --Dcr = T.Dcr;
    --@end-debug@]==]

    D.name = "Decursive";
    D.version = "2.7.29";
    D.author = "John Wellesz";

    D.DcrFullyInitialized = false;

    RegisterDecursive_Once = nil;

end -- }}}

local function RegisterLocals_Once() -- {{{

    D.L         = LibStub("AceLocale-3.0"):GetLocale("Decursive", true);

    -- Make sure to never crash if some locals are missing (seen this happen on
    -- Chinese clients when relying on LOCALIZED_CLASS_NAMES_MALE constant)
    -- While that was probably caused by a badd-on redefining the constant,
    -- it's best to stay on the safe side...

    D.LC = setmetatable((FillLocalizedClassList or LocalizedClassList)({}, false), {__index = function(t,k) return k end});

    RegisterLocals_Once = nil;
end -- }}}

local function SetBasicConstants_Once() -- these are constants that may be used at parsing time in other .lua and .xml {{{

    BINDING_HEADER_DECURSIVE = D.L["Decursive"];

    local DC = T._C;

    DC.IconON = "Interface\\AddOns\\Decursive\\iconON.tga";
    DC.IconOFF = "Interface\\AddOns\\Decursive\\iconOFF.tga";

    DC.MFSIZE = 20;

    -- This value is returned by UnitName when the name of a unit is not available yet
    DC.UNKNOWN = UNKNOWNOBJECT;

    -- Get the translation for "pet"
    DC.PET = SPELL_TARGET_TYPE8_DESC;

    DC.DevVersionExpired = false; -- may be used early by the debugger

    DC.MAGIC        = 1;
    DC.ENEMYMAGIC   = 2;
    DC.CURSE        = 4;
    DC.POISON       = 8;
    DC.DISEASE      = 16;
    DC.CHARMED      = 32;
    DC.BLEED        = 64;
    DC.NOTYPE       = 128;

    DC.CLASS_DRUID       = 'DRUID';
    DC.CLASS_HUNTER      = 'HUNTER';
    DC.CLASS_MAGE        = 'MAGE';
    DC.CLASS_PALADIN     = 'PALADIN';
    DC.CLASS_PRIEST      = 'PRIEST';
    DC.CLASS_ROGUE       = 'ROGUE';
    DC.CLASS_SHAMAN      = 'SHAMAN';
    DC.CLASS_WARLOCK     = 'WARLOCK';
    DC.CLASS_WARRIOR     = 'WARRIOR';
    DC.CLASS_DEATHKNIGHT = 'DEATHKNIGHT';
    DC.CLASS_MONK        = 'MONK';
    DC.CLASS_DEMONHUNTER = 'DEMONHUNTER';
    DC.CLASS_EVOKER      = 'EVOKER';

    DC.MyClass = "NOCLASS";
    DC.MyName = "NONAME";
    DC.MyGUID = "NONE";

    DC.NORMAL                   = 8;
    DC.ABSENT                   = 16;
    DC.FAR                      = 32;
    DC.STEALTHED                = 64;
    DC.BLACKLISTED              = 128;
    DC.AFFLICTED                = 256;
    DC.AFFLICTED_NIR            = 512;
    DC.CHARMED_STATUS           = 1024;
    DC.AFFLICTED_AND_CHARMED    = bit.bor(DC.AFFLICTED, DC.CHARMED_STATUS);

    DC.AfflictionSound = "Interface\\AddOns\\Decursive\\Sounds\\AfflictionAlert.ogg";
    DC.FailedSound = "Interface\\AddOns\\Decursive\\Sounds\\FailedSpell.ogg";
    DC.DeadlyDebuffAlert = "Interface\\AddOns\\Decursive\\Sounds\\G_NecropolisWound-fast.ogg";
    --DC.AfflictionSound = 566027

    DC.EMPTY_TABLE = {};


    SetBasicConstants_Once = nil;
end -- }}}

local function SetRuntimeConstants_Once () -- {{{

    D.CONF = {}; -- this table is only used in dcr opt through a function
    D.CONF.TEXT_LIFETIME = 4.0;
    D.CONF.MAX_LIVE_SLOTS = 10;
    D.CONF.MACRONAME = "Decursive";
    D.CONF.MACROCOMMAND = "MACRO " .. D.CONF.MACRONAME;

    local DC = T._C;

    DC.DebuffHistoryLength = 40; -- we use a rather high value to avoid garbage creation

    -- Create MUFs number fontinstance
    DC.NumberFontFileName = _G.NumberFont_Shadow_Small:GetFont(); -- XXX only used during MUFs creation

    DC.RAID_ICON_LIST = _G.ICON_LIST;
    if not DC.RAID_ICON_LIST then
        T._AddDebugText("DCR_init.lua: Couldn't get Raid Target Icon List!");
        DC.RAID_ICON_LIST = {};
    end

    DC.RAID_ICON_TEXTURE_LIST = {};

    for i,v in ipairs(DC.RAID_ICON_LIST) do
        DC.RAID_ICON_TEXTURE_LIST[i] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i;
    end

    DC.TypeNames = {
        [DC.MAGIC]      = "Magic",
        [DC.ENEMYMAGIC] = "Magic",
        [DC.CURSE]      = "Curse",
        [DC.POISON]     = "Poison",
        [DC.DISEASE]    = "Disease",
        [DC.CHARMED]    = "Charm",
        [DC.BLEED]      = "Bleed",
    }

    DC.NameToTypes = D:tReverse(DC.TypeNames);
    DC.NameToTypes["Magic"] = DC.MAGIC; -- make sure 'Magic' is set to DC.MAGIC and not to DC.ENEMYMAGIC

    DC.TypeToLocalizableTypeNames = {
        [DC.MAGIC]      = "MAGIC",
        [DC.ENEMYMAGIC] = "MAGICCHARMED",
        [DC.CURSE]      = "CURSE",
        [DC.POISON]     = "POISON",
        [DC.DISEASE]    = "DISEASE",
        [DC.CHARMED]    = "CHARM",
        [DC.BLEED]      = "BLEED",
    }
    DC.LocalizableTypeNamesToTypes = D:tReverse(DC.TypeToLocalizableTypeNames);

    -- Create some useful cache tables

    local DS = T._C.DS;
    local DSI = T._C.DSI;


    if not DC.WOWC then
        DC.IS_STEALTH_BUFF = D:tReverse({DS["Prowl"], DS["Stealth"], DS["Shadowmeld"],  DS["Invisibility"], DS["Lesser Invisibility"], DS['Greater Invisibility']});

        DC.IS_HARMFULL_DEBUFF = D:tReverse({DC.DS["Unstable Affliction"], DC.DS["Vampiric Touch"], DC.DS["MUTATINGINJECTION"]}); --, , DC.DS["Fluidity"]}); --, "Test item"});
        DC.IS_DEADLY_DEBUFF   = D:tReverse({DC.DSI["Fluidity"]});

        DC.IS_OMNI_DEBUFF     = D:tReverse({DC.DSI["DEBUFF_VOID_RIFT"]});

        -- SPELL TABLE -- must be parsed after spell translations have been loaded {{{
        DC.SpellsToUse = {
            -- Druids
            [DSI["SPELL_CYCLONE"]] = {
                Types = {DC.CHARMED},
                Better = 0,
                Pet = false,
            },
            -- Mages
            [DSI["SPELL_REMOVE_CURSE_MAGE"]] = {
                Types = {DC.CURSE},
                Better = 0,
                Pet = false,
            },
            -- Shamans http://www.wowhead.com/?spell=51514
            [DSI["SPELL_HEX"]] = {
                Types = {DC.CHARMED},
                Better = 0,
                Pet = false,
            },
            -- Shamans
            [DSI["SPELL_PURGE"]] = {
                Types = {DC.ENEMYMAGIC},
                Better = 0,
                Pet = false,
            },
            -- Hunters http://www.wowhead.com/?spell=212640
            [DSI["SPELL_MENDINGBANDAGE"]] = { -- PVP
                Types = {DC.DISEASE, DC.POISON},
                Better = 0,
                Pet = false,
            },
            -- Monks
            [DSI["SPELL_DETOX_1"]] = {
                Types = {DC.MAGIC},
                Better = 3,
                Pet = false,
                EnhancedBy = 'talent',
                EnhancedByCheck = function ()
                    return (IsPlayerSpell(DSI["SPELL_IMPROVED_DETOX"]));
                end,
                Enhancements = {
                    Types = {DC.MAGIC, DC.DISEASE, DC.POISON},
                }
            },
            [DSI["SPELL_DETOX_2"]] = {
                Types = {DC.DISEASE, DC.POISON},
                Better = 2,
                Pet = false,

            },
            -- Monks
            [DSI["SPELL_DIFFUSEMAGIC"]] = {
                Types = {DC.MAGIC},
                Better = 0,
                Pet = false,
                UnitFiltering = {
                    [DC.MAGIC]  = 1,
                },
            },
            -- Paladins
            [DSI["SPELL_CLEANSE_TOXINS"]] = {
                Types = {DC.DISEASE, DC.POISON},
                Better = 0,
                Pet = false,
            },
            [DSI["SPELL_CLEANSE"]] = {
                Types = {DC.MAGIC, DC.DISEASE, DC.POISON},
                Better = 2,
                Pet = false,
            },
            -- Shaman
            [DSI["CLEANSE_SPIRIT"]] = { -- same name as PURIFY_SPIRIT in ruRU XXX
                Types = {DC.CURSE},
                Better = 3,
                Pet = false,
                -- detect resto spec and enhance this spell
                EnhancedBy = 'resto',
                EnhancedByCheck = function ()
                    return (GetSpecialization() == 3) and true or false; -- restoration?
                end,
                Enhancements = {
                    Types = {DC.CURSE, DC.MAGIC}, -- see PURIFY_SPIRIT
                }
            },

            --[=[
            i=1; while GetSpellBookItemInfo(i, 'spell') do if (select(2, GetSpellBookItemInfo(i, 'spell'))) == 77130 then print(i) end; i = i + 1; end
            --]=]

            -- Shaman resto
            [DSI["PURIFY_SPIRIT"]] = { -- same name as CLEANSE_SPIRIT in ruRU XXX -- IsSpellKnown(DSI["PURIFY_SPIRIT"]) actually fails in all situaions...
                Types = {DC.MAGIC},
                Better = 4,
                Pet = false,
                -- detect improved purify spirit
                EnhancedBy = 'talent',
                EnhancedByCheck = function ()
                    return (IsPlayerSpell(DSI["IMPROVED_PURIFY_SPIRIT"]));
                end,
                Enhancements = {
                    Types = {DC.CURSE, DC.MAGIC}, -- see PURIFY_SPIRIT
                }
            },
            -- Warlocks (Imp)
            [DSI["PET_SINGE_MAGIC"]] = {
                Types = {DC.MAGIC},
                Better = 0,
                Pet = true,
            },
            [DSI["PET_SINGE_MAGIC_PVP"]] = { -- PVP
                Types = {DC.MAGIC},
                Better = 0,
                Pet = true,
            },
            -- Warlocks (Fel-Imp)
            [DSI["PET_SEAR_MAGIC"]] = {
                Types = {DC.MAGIC},
                Better = 0,
                Pet = true,
            },
            -- Warlocks (Imp singe magic ability when used with Grimoire of Sacrifice)
            [DSI["SPELL_COMMAND_DEMON"]] = {
                Types = {}, -- does nothing by default
                Better = 1, -- the Imp takes time to disappear when sacrificed, during that interlude, Singe Magic is still there
                Pet = false,

                EnhancedBy = true,
                EnhancedByCheck = function ()
                    return (GetSpellName(DS["SPELL_COMMAND_DEMON"])) == DS["PET_SINGE_MAGIC"] or (GetSpellName(DS["SPELL_COMMAND_DEMON"])) == DS["PET_SEAR_MAGIC"];
                end,
                Enhancements = {
                    Types = {DC.MAGIC},
                }
            },
            -- Warlock
            [DSI["SPELL_FEAR"]] = {
                Types = {DC.CHARMED},
                Better = 1,
                Pet = false,
                UnitFiltering = {
                    [DC.CHARMED]  = 2,
                },
            },
            -- Warlocks
            [DSI["PET_TORCH_MAGIC"]] = {
                Types = {DC.ENEMYMAGIC},
                Better = 0,
                Pet = true,
            },
            [DSI["PET_DEVOUR_MAGIC"]] = {
                Types = {DC.ENEMYMAGIC},
                Better = 0,
                Pet = true,
            },
            -- Mages
            [DSI["SPELL_POLYMORPH"]] = {
                Types = {DC.CHARMED},
                Better = 0,
                Pet = false,
            },
            -- Druids (Balance Feral Guardian)
            [DSI["SPELL_REMOVE_CORRUPTION"]] = {
                Types = {DC.POISON, DC.CURSE},
                Better = 0,
                Pet = false,

            },
            -- SPELL_POISON_CLEANSING_TOTEM
            [DSI["SPELL_POISON_CLEANSING_TOTEM"]] = {
                Types = {DC.POISON},
                Better = 1,
                Pet = false,

            },
            -- Druids (Restoration)
            [DSI["SPELL_NATURES_CURE"]] = {
                Types = {DC.MAGIC, DC.POISON, DC.CURSE},
                Better = 3,
                Pet = false,
            },
            -- Priests (global)
            [DSI["SPELL_DISPELL_MAGIC"]] = {
                Types = {DC.ENEMYMAGIC},
                Better = 0,
                Pet = false,
            },
            -- Demon Hunters (global)
            [DSI["SPELL_CONSUME_MAGIC"]] = {
                Types = {DC.ENEMYMAGIC},
                Better = 0,
                Pet = false,
            },
            -- Mages (global)
            [DSI["SPELL_SPELLSTEAL"]] = {
                Types = {DC.ENEMYMAGIC},
                Better = 1,
                Pet = false,
            },
            -- Priests (Discipline, Holy)
            [DSI["SPELL_PURIFY"]] = {
                Types = {DC.MAGIC},
                Better = 1,
                Pet = false,
                EnhancedBy = 'talent',
                EnhancedByCheck = function ()
                    return (IsPlayerSpell(DSI["IMPROVED_PURIFY"]));
                end,
                Enhancements = {
                    Types = {DC.MAGIC, DC.DISEASE},
                }
            },
            [DSI["SPELL_PURIFY_DISEASE"]] = {
                Types = {DC.DISEASE},
                Better = 0,
                Pet = false,
            },
            -- Demon hunters
            [DSI["SPELL_REVERSEMAGIC"]] = { -- PVP
                Types = {DC.MAGIC},
                Better = 1,
                Pet = false,
            },
            -- Evoker
            [DSI["SPELL_EXPUNGE"]] = {
                Types = {DC.POISON},
                Better = 1,
                Pet = false,
            },
            [DSI["SPELL_CAUTERIZING_FLAME"]] = {
                Types = {DC.POISON, DC.CURSE, DC.DISEASE, DC.BLEED},
                Better = 0,
                Pet = false,
            },
            [DSI["SPELL_NATURALIZE"]] = {
                Types = {DC.POISON, DC.MAGIC},
                Better = 2,
                Pet = false,
            },
            -- undead racial
            [DSI["SPELL_WILL_OF_THE_FORSAKEN"]] = {
                Types = {DC.CHARMED},
                Better = 0,
                Pet = false,
                UnitFiltering = {
                    [DC.CHARMED] = 1, -- player only
                },
            }
        };

        -- }}}
    else -- WOW CLASSIC
        if not DC.CATACLYSM then
            DC.IS_STEALTH_BUFF = D:tReverse({DS["Prowl"], DS["Stealth"], DS["Shadowmeld"], DS["Lesser Invisibility"]});
            DC.IS_HARMFULL_DEBUFF = D:tReverse({DC.DS["MUTATINGINJECTION"]}); --, "Test item"});
            DC.IS_DEADLY_DEBUFF   = D:tReverse({});
            DC.IS_OMNI_DEBUFF     = D:tReverse({});

            -- SPELL TABLE -- must be parsed after spell translations have been loaded {{{
            DC.SpellsToUse = {
                -- Druid
                [DSI["SPELL_REMOVE_CURSE_DRUID"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=475/remove-lesser-curse
                    Types = {DC.CURSE},
                    Better = 0,
                    Pet = false,
                },
                -- Mage
                [DSI["SPELL_REMOVE_CURSE_MAGE"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=2782/remove-curse
                    Types = {DC.CURSE},
                    Better = 0,
                    Pet = false,
                },
                [DSI["SPELL_REMOVE_GREATER_CURSE"]] = { -- WOW CLASSIC https://www.wowhead.com/classic/spell=412113/remove-greater-curse
                    Types = {DC.CURSE, DC.MAGIC},
                    Better = 1,
                    Pet = false,
                },
                -- Shaman
                [DSI["SPELL_PURGE"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=370/purge
                    Types = {DC.ENEMYMAGIC},
                    Better = 0,
                    Pet = false,
                },
                -- Paladin
                [DSI["SPELL_CLEANSE"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=4987/cleanse
                    Types =  {DC.MAGIC, DC.DISEASE, DC.POISON},
                    Better = 2,
                    Pet = false,

                },
                -- Warlock
                [DSI["SPELL_FEAR"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=5782/fear
                    Types = {DC.CHARMED},
                    Better = 1,
                    Pet = false,
                    UnitFiltering = {
                        [DC.CHARMED]  = 2,
                    },
                },
                -- Mages
                [DSI["SPELL_POLYMORPH"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=118/polymorph
                    Types = {DC.CHARMED},
                    Better = 0,
                    Pet = false,
                    UnitFiltering = {
                        [DC.CHARMED]  = 2,
                    },
                },
                -- Priests (global)
                [DSI["SPELL_DISPELL_MAGIC"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=527/dispel-magic
                    Types = {DC.MAGIC, DC.ENEMYMAGIC},
                    Better = 0,
                    Pet = false,
                },
                -- Priests (rank 1 is no longer detected once rank 2 is learned apprently)
                [DSI["SPELL_DISPELL_MAGIC_PRIEST_R2"]] = { -- WOW CLASSIC  https://www.wowhead.com/wotlk/spell=988/dispel-magic
                    Types = {DC.MAGIC, DC.ENEMYMAGIC},
                    Better = 1,
                    Pet = false,
                },
                -- Paladin or priests on MoP
                [DSI["SPELL_PURIFY"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=1152/purify
                    Types = {DC.POISON, DC.DISEASE},
                    Better = 1,
                    Pet = false,
                },
                -- Priest
                [DSI["SPELL_ABOLISH_DISEASE"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=552/abolish-disease
                    Types = {DC.DISEASE},
                    Better = 2,
                    Pet = false,
                },
                -- Priest
                [DSI["SPELL_CURE_DISEASE_PRIEST"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=528/cure-disease
                    Types = {DC.DISEASE},
                    Better = 0,
                    Pet = false,
                },
                -- Priest
                [DSI["SPELL_CURE_DISEASE_SHAMAN"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=2870/cure-disease
                    Types = {DC.DISEASE},
                    Better = 0,
                    Pet = false,
                },
                -- Druid
                [DSI["SPELL_ABOLISH_POISON"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=2893/abolish-poison
                    Types = {DC.POISON},
                    Better = 2,
                    Pet = false,
                },
                -- Shaman
                [DSI["SPELL_CURE_POISON_SHAMAN"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=526/cure-poison
                    Types = {DC.POISON},
                    Better = 0,
                    Pet = false,
                },
                -- Druid
                [DSI["SPELL_CURE_POISON_DRUID"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=8946/cure-poison
                    Types = {DC.POISON},
                    Better = 0,
                    Pet = false,
                },
                -- Warlock
                [DSI["PET_DEVOUR_MAGIC"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=19505/devour-magic
                    Types = {DC.MAGIC, DC.ENEMYMAGIC},
                    Better = 0,
                    Pet = true,
                },
                -- undead racial
                [DSI["SPELL_WILL_OF_THE_FORSAKEN"]] = {
                    Types = {DC.CHARMED},
                    Better = 0,
                    Pet = false,
                    UnitFiltering = {
                        [DC.CHARMED] = 1, -- player only
                    },
                },
            }
        else -- this is the current Classic expansion
            -- MoP
            DC.IS_STEALTH_BUFF = D:tReverse({DS["Prowl"], DS["Stealth"], DS["Shadowmeld"],  DS["Invisibility"], DS["Lesser Invisibility"], DS["Camouflage"], DS["SHROUD_OF_CONCEALMENT"], DS['Greater Invisibility']});

            DC.IS_HARMFULL_DEBUFF = D:tReverse({DC.DS["Unstable Affliction"], DC.DS["Vampiric Touch"]}); --, , DC.DS["Fluidity"]}); --, "Test item"});
            DC.IS_DEADLY_DEBUFF   = D:tReverse({DC.DSI["Fluidity"]});
            DC.IS_OMNI_DEBUFF     = D:tReverse({});

            local SymbiosisNamesToIDs = {
                [DS["SPELL_CYCLONE_FROM_SYMBIOSIS"]]    =  DSI["SPELL_CYCLONE_FROM_SYMBIOSIS"],
                [DS["SPELL_PURGE_FROM_SYMBIOSIS"]]      =  DSI["SPELL_PURGE_FROM_SYMBIOSIS"],
                [DS["SPELL_CLEANSE_FROM_SYMBIOSIS"]]    =  DSI["SPELL_CLEANSE_FROM_SYMBIOSIS"],
            }
            -- special meta table to handle Druid's Symbiosis
            local SymbiosisEnhancement_mt = {
                __index = function (self, key)
                    if key == 'Types' and SymbiosisNamesToIDs[GetSpellInfo(DS["SPELL_SYMBIOSIS"])] then
                        return DC.SpellsToUse[SymbiosisNamesToIDs[GetSpellInfo(DS["SPELL_SYMBIOSIS"])]].Types;
                    else
                        return {};
                    end
                end
            }

            -- MoP
            DC.SpellsToUse = {
                -- Druids
                [DSI["SPELL_CYCLONE"]] = {
                    Types = {DC.CHARMED},
                    Better = 0,
                    Pet = false,
                },
                -- Priests
                [DSI["SPELL_CYCLONE_FROM_SYMBIOSIS"]] = {
                    Types = {DC.CHARMED},
                    Better = 0,
                    Pet = false,
                },
                -- Mage
                [DSI["SPELL_REMOVE_CURSE"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=2782/remove-curse
                    Types = {DC.CURSE},
                    Better = 0,
                    Pet = false,
                },
                -- Shamans http://www.wowhead.com/?spell=51514
                [DSI["SPELL_HEX"]] = {
                    Types = {DC.CHARMED},
                    Better = 0,
                    Pet = false,
                },
                -- Shaman
                [DSI["SPELL_PURGE"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=370/purge
                    Types = {DC.ENEMYMAGIC},
                    Better = 0,
                    Pet = false,
                },
                -- HUNTERS http://www.wowhead.com/?spell=19801
                [DSI["SPELL_TRANQUILIZING_SHOT"]]    = {
                    Types = {DC.ENEMYMAGIC},
                    Better = 0,
                    Pet = false,
                },
                -- Monks
                [DSI["SPELL_DETOX"]] = {
                    Types = {DC.DISEASE, DC.POISON},
                    Better = 2,
                    Pet = false,

                    EnhancedBy = DS["PASSIVE_INTERNAL_MEDICINE"],
                    EnhancedByCheck = function ()
                        return IsPlayerSpell(DSI["PASSIVE_INTERNAL_MEDICINE"]);
                    end,
                    Enhancements = {
                        Types = {DC.MAGIC, DC.DISEASE, DC.POISON},
                    }
                },
                -- Monks
                [DSI["SPELL_DIFFUSEMAGIC"]] = {
                    Types = {DC.MAGIC},
                    Better = 0,
                    Pet = false,
                    UnitFiltering = {
                        [DC.MAGIC]  = 1,
                    },
                },
                -- Paladin
                [DSI["SPELL_CLEANSE"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=4987/cleanse
                    Types =  {DC.DISEASE, DC.POISON},
                    Better = 2,
                    Pet = false,
                    EnhancedBy =DS["PASSIVE_SACRED_CLEANSING"] ~= nil,
                    EnhancedByCheck = function ()
                        return IsPlayerSpell(DSI["PASSIVE_SACRED_CLEANSING"])
                    end,
                    Enhancements = {
                        Types = {DC.MAGIC, DC.DISEASE, DC.POISON},
                    }
                },
                [DSI["SPELL_HAND_OF_SACRIFICE"]] = {
                    Types = {},
                    Better = 1,
                    Pet = false,

                    EnhancedBy = DS["PASSIVE_ABSOLVE"], -- http://www.wowhead.com/talent#srrrdkdz
                    EnhancedByCheck = function ()
                        return IsPlayerSpell(DSI["PASSIVE_ABSOLVE"]);
                    end,
                    Enhancements = {
                        Types = {DC.MAGIC},
                        UnitFiltering = {
                            [DC.MAGIC]  = 2, -- on raid/party only
                        },
                    }

                },
                -- Druids
                [DSI["SPELL_CLEANSE_FROM_SYMBIOSIS"]] = {
                    Types = {DC.DISEASE, DC.POISON},
                    Better = 2,
                    Pet = false,
                },
                -- Druids
                [DSI["SPELL_PURGE_FROM_SYMBIOSIS"]] = {
                    Types = {DC.ENEMYMAGIC},
                    Better = 2,
                    Pet = false,
                },
                -- Shaman
                [DSI["CLEANSE_SPIRIT"]] = { -- same name as PURIFY_SPIRIT in ruRU XXX
                    Types = {DC.CURSE},
                    Better = 3,
                    Pet = false,
                    EnhancedBy = DS["PURIFY_SPIRIT"] ~= nil,
                    EnhancedByCheck = function ()
                        return IsPlayerSpell(DSI["PURIFY_SPIRIT"])
                    end,
                    Enhancements = {
                        Types = {DC.MAGIC, DC.CURSE},
                    }
                },
                -- Shaman resto
                [DSI["PURIFY_SPIRIT"]] = { -- same name as CLEANSE_SPIRIT in ruRU XXX -- IsSpellKnown(DSI["PURIFY_SPIRIT"]) actually fails in all situaions...
                    -- BUG in MOP BETA and 5.2 (2012-07-08): /dump GetSpellBookItemInfo('Purify Spirit') == nil while /dump (GetSpellInfo('Cleanse Spirit')) == 'Purify Spirit'
                    Types = {DC.CURSE, DC.MAGIC},
                    Better = 4,
                    Pet = false,
                },
                -- Warlocks (Imp)
                [DSI["SPELL_SINGE_MAGIC"]] = {
                    Types = {DC.MAGIC},
                    Better = 0,
                    Pet = true,
                },
                -- Warlocks (Imp singe magic ability when used with Grimoire of Sacrifice)
                [DSI["SPELL_COMMAND_DEMON"]] = {
                    Types = {}, -- does nothing by default
                    Better = 1, -- the Imp takes time to disappear when sacrificed, during that interlude, Singe Magic is still there
                    Pet = false,

                    EnhancedBy = true,
                    EnhancedByCheck = function ()
                        return (GetSpellInfo(DS["SPELL_COMMAND_DEMON"]) == DS["SPELL_SINGE_MAGIC"]);
                    end,
                    Enhancements = {
                        Types = {DC.MAGIC},
                    }
                },
                -- Druids (copied for Priests see after table declaration)
                [DSI["SPELL_SYMBIOSIS"]] = {
                    Types = {}, -- does nothing by default
                    Better = 1,
                    Pet = false,

                    EnhancedBy = true,
                    EnhancedByCheck = function ()
                        if (GetSpellInfo(DS["SPELL_SYMBIOSIS"])) ~= DS["SPELL_SYMBIOSIS"] and SymbiosisNamesToIDs[GetSpellInfo(DS["SPELL_SYMBIOSIS"])] then
                            --  DC.SpellsToUse[DSI["SPELL_SYMBIOSIS"]].Enhancements = setmetatable({}, SymbiosisEnhancement_mt);
                            --  DC.SpellsToUse[DSI["SPELL_SYMBIOSIS_PRIEST"]].Enhancements = setmetatable({}, SymbiosisEnhancement_mt);
                            return true;
                        else
                            return false;
                        end
                    end,
                    Enhancements = {}, -- placeholder, replaced by a metatable when active
                },
                -- Warlock
                [DSI["SPELL_FEAR"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=5782/fear
                    Types = {DC.CHARMED},
                    Better = 1,
                    Pet = false,
                    UnitFiltering = {
                        [DC.CHARMED]  = 2,
                    },
                },
                -- Warlocks
                [DSI["PET_FEL_CAST"]] = {
                    Types = {DC.ENEMYMAGIC},
                    Better = 0,
                    Pet = true,
                },
                -- Mages
                [DSI["SPELL_POLYMORPH"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=118/polymorph
                    Types = {DC.CHARMED},
                    Better = 0,
                    Pet = false,
                    UnitFiltering = {
                        [DC.CHARMED]  = 2,
                    },
                },
                -- Druids (Balance Feral Guardian)
                [DSI["SPELL_REMOVE_CORRUPTION"]] = {
                    Types = {DC.POISON, DC.CURSE},
                    Better = 0,
                    Pet = false,
                },
                -- Druids (Restoration)
                [DSI["SPELL_NATURES_CURE"]] = {
                    Types = {DC.MAGIC, DC.POISON, DC.CURSE},
                    Better = 3,
                    Pet = false,
                },
                -- Priests (global)
                [DSI["SPELL_DISPELL_MAGIC"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=527/dispel-magic
                    Types ={DC.ENEMYMAGIC},
                    Better = 0,
                    Pet = false,
                },

                -- Paladin or priests on MoP
                [DSI["SPELL_PURIFY"]] = { -- WOW CLASSIC  https://classic.wowhead.com/spell=1152/purify
                    Types = {DC.MAGIC, DC.DISEASE},
                    Better = 0,
                    Pet = false,
                },
                -- undead racial
                [DSI["SPELL_WILL_OF_THE_FORSAKEN"]] = {
                    Types = {DC.CHARMED},
                    Better = 0,
                    Pet = false,
                    UnitFiltering = {
                        [DC.CHARMED] = 1, -- player only
                    },
                },
                -- Deakth Knights
                [DSI["SPELL_ICY_TOUCH"]] = {
                    Types = {},
                    Better = 1,
                    Pet = false,

                    EnhancedBy = DS["GLYPH_OF_ICY_TOUCH"],
                    EnhancedByCheck = function ()
                        return (IsPlayerSpell(DSI["GLYPH_OF_ICY_TOUCH"])) and true or false;
                    end,
                    Enhancements = {
                        Types = {DC.ENEMYMAGIC},
                    }

                },
            }

            DC.SpellsToUse[DSI["SPELL_SYMBIOSIS"]].Enhancements = setmetatable({}, SymbiosisEnhancement_mt);
            DC.SpellsToUse[DSI["SPELL_SYMBIOSIS_PRIEST"]] = DC.SpellsToUse[DSI["SPELL_SYMBIOSIS"]];
        end
        DC.SpellsToUse[false] = nil; -- cleanup compatible layer invalid spells
        -- }}}
    end
    D:CreateClassColorTables();

    SetRuntimeConstants_Once = nil;

end -- }}}

local function InitVariables_Once() -- {{{


    D.MFContainer = false;
    D.LLContainer = false;

    D.Status = {}; -- might be used by some script in xml files

    -- An acces the debuff table
    D.ManagedDebuffUnitCache = {};
    -- A table UnitID=>IsDebuffed (boolean)
    D.UnitDebuffed = {};

    D.Revision = "d388340"; -- not used here but some other add-on may request it from outside
    D.date = "2025-07-20T23:08:26Z";
    D.version = "2.7.29";

    if D.date ~= "@project".."-date-iso@" then
        -- 1753052906 doesn't work

        --local example =  "2008-05-01T12:34:56Z";

        local year, month, day, hour, min, sec = string.match( D.date, "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)");
        local projectDate = {["year"] = year, ["month"] = month, ["day"] = day, ["hour"] = hour, ["min"] = min, ["sec"] = sec, ["isdst"] = false };

        D.VersionTimeStamp = time(projectDate);
    else
        D.VersionTimeStamp = 0;
    end

    InitVariables_Once = nil;
end -- }}}

-- Basic initialization functions, if they fail nothing will work. T._CatchAllErrors allows the debugger to also grab errors happening in libraries
T._CatchAllErrors = "RegisterDecursive_Once";   RegisterDecursive_Once();
T._CatchAllErrors = "RegisterLocals_Once";      RegisterLocals_Once();

T._CatchAllErrors = "SetBasicConstants_Once";   SetBasicConstants_Once();
T._CatchAllErrors = "InitVariables_Once";       InitVariables_Once();

-- Upvalues for faster access
local L  = D.L;
local LC = D.LC;
local DC = T._C;

local select            = _G.select;
local pairs             = _G.pairs;
local ipairs            = _G.ipairs;
local next              = _G.next;
local InCombatLockdown  = _G.InCombatLockdown;
local UnitClass         = _G.UnitClass;
local time              = _G.time;

function D:AddDebugText(a1, ...)
    T._AddDebugText(a1, ...);
end

function D:VersionWarnings(forceDisplay) -- {{{

    local alpha = false;
    local debug = false;
    local fromCheckOut = false;
    --[=[@alpha@
    alpha = true;
    --@end-alpha@]=]
    --[==[@debug@
    debug = true;
    --@end-debug@]==]


    -- test if WoW's TOC version is superior to Decursive's, wait 40 days and warn the users that this version has expired
    local DcrMaxTOC = tonumber(GetAddOnMetadata("Decursive", "X-Max-Interface") or math.huge); -- once GetAddOnMetadata() was bugged and returned nil...
    if DcrMaxTOC < T._tocversion then

        -- store the detection of this problem
        if not self.db.global.TocExpiredDetection then
            self.db.global.TocExpiredDetection = time();

        elseif time() - self.db.global.TocExpiredDetection > 3600 * 24 * 40 or debug then -- if more than 40 days elapsed since the detection

            DC.DevVersionExpired = true; -- disable error reports

            if time() - self.db.global.LastExpirationAlert > 48 * 3600 or forceDisplay or debug then

                T._ShowNotice ("|cff00ff00Decursive version: 2.7.29|r\n\n" .. "|cFFFFAA66" .. L["TOC_VERSION_EXPIRED"] .. "|r");

                self.db.global.LastExpirationAlert = time();
            end
        end
    else
        self.db.global.TocExpiredDetection = false;
    end

    if (("2.7.29"):lower()):find("beta") or ("2.7.29"):find("RC") or ("2.7.29"):find("Candidate") or alpha then

        D.RunningADevVersion = true;

        -- check for expiration of this dev version
        if D.VersionTimeStamp ~= 0 then

            local VersionLifeTime  = 3600 * 24 * 30; -- 30 days

            if time() > D.VersionTimeStamp + VersionLifeTime then
                DC.DevVersionExpired = true;
                -- Display the expiration notice only once evry 48 hours
                if time() - self.db.global.LastExpirationAlert > 48 * 3600 or forceDisplay then
                    T._ShowNotice ("|cff00ff00Decursive version: 2.7.29|r\n\n" .. "|cFFFFAA66" .. L["DEV_VERSION_EXPIRED"] .. "|r");

                    self.db.global.LastExpirationAlert = time();
                end

                return;
            end

        end

        -- display a warning if this is a developpment version (avoid insults from people who don't know what they're doing)
        if self.db.global.NonRelease ~= "2.7.29" then
            self.db.global.NonRelease = "2.7.29";
            T._ShowNotice ("|cff00ff00Decursive version: 2.7.29|r\n\n" .. "|cFFFFAA66" .. L["DEV_VERSION_ALERT"] .. "|r");
        end
    end

    --[==[@debug@
    fromCheckOut = true;
    if time() - self.db.global.LastUnpackagedAlert > 24 * 3600  then
        T._ShowNotice ("|cff00ff00Decursive version: 2.7.29|r\n\n" .. "|cFFFFAA66" ..
        [[
        |cFFFF0000You're using an unpackaged version of Decursive.|r
        Decursive is not meant to be used this way.
        Annoying and invasive debugging messages will be displayed.
        More resources (memory and CPU) will be used due to debug routines and sanity test code being executed.
        Localisation is not working and English text may be wrong.

        Using Decursive in this state will bring you nothing but troubles.

        |cFF00FF00Alpha versions of Decursive are automatically packaged. You should use those instead.|r

        ]]
        .. "|r");

        self.db.global.LastUnpackagedAlert = time();
    end
    --@end-debug@]==]

    -- re-enable new version pop-up alerts when a newer version is installed
    if D.db.global.NewVersionsBugMeNot and D.db.global.NewVersionsBugMeNot < D.VersionTimeStamp then
        D.db.global.NewVersionsBugMeNot = false;
    end


    -- Prevent time travelers from blocking the system
    if D.db.global.NewerVersionDetected > time() then
        D.db.global.NewerVersionDetected = D.VersionTimeStamp;
        D.db.global.NewerVersionName = false;
        D.db.global.NewerVersionAlert = 0;
        D:Debug("|cFFFF0000TIME TRAVELER DETECTED!|r");
    end

    -- if not fromCheckOut then -- this version is properly packaged
    if D.db.global.NewerVersionName then -- a new version was detected some time ago
        if D.db.global.NewerVersionDetected > D.VersionTimeStamp and D.db.global.NewerVersionName ~= D.version then -- it's still newer than this one
            if time() - D.db.global.NewerVersionAlert > 3600 * 24 * 4 then -- it's been more than 4 days since the new version alert was shown
                if not D.db.global.NewVersionsBugMeNot then -- the user did not disable new version alerts
                    T._ShowNotice ("|cff55ff55Decursive version: 2.7.29|r\n\n" .. "|cFF55FFFF" .. (L["NEW_VERSION_ALERT"]):format(D.db.global.NewerVersionName or "none", date("%Y-%m-%d", D.db.global.NewerVersionDetected)) .. "|r");
                    D.db.global.NewerVersionAlert = time();
                end
            end
        else
            D.db.global.NewerVersionDetected = D.VersionTimeStamp;
            D.db.global.NewerVersionName = false;
        end
    end
--    end

end -- }}}


function D:OnInitialize() -- Called on ADDON_LOADED by AceAddon -- {{{

    if T._SelfDiagnostic() == 2 then
        return false;
    end

    T._CatchAllErrors = "OnInitialize"; -- During init we catch all the errors else, if a library fails we won't know it.

    D:LocalizeBindings ();

    D:SetSpellsTranslations(false); -- Register spell translations

    D.defaults = D:GetDefaultsSettings();

    self.db = LibStub("AceDB-3.0"):New("DecursiveDB", D.defaults, true);

    self.db.RegisterCallback(self, "OnProfileChanged", "SetConfiguration")
    self.db.RegisterCallback(self, "OnProfileCopied", "SetConfiguration")
    self.db.RegisterCallback(self, "OnProfileReset", "SetConfiguration")


    -- Register slashes command {{{
    self:RegisterChatCommand("dcrdiag"      ,function() T._SelfDiagnostic(true, true)               end         );
    self:RegisterChatCommand("decursive"    ,function() LibStub("AceConfigDialog-3.0"):Open(D.name) end         );
    self:RegisterChatCommand("dcrpradd"     ,function() D:AddTargetToPriorityList()                 end, false  );
    self:RegisterChatCommand("dcrprclear"   ,function() D:ClearPriorityList()                       end, false  );
    self:RegisterChatCommand("dcrprshow"    ,function() D:ShowHidePriorityListUI()                  end, false  );
    self:RegisterChatCommand("dcrskadd"     ,function() D:AddTargetToSkipList()                     end, false  );
    self:RegisterChatCommand("dcrskclear"   ,function() D:ClearSkipList()                           end, false  );
    self:RegisterChatCommand("dcrskshow"    ,function() D:ShowHideSkipListUI()                      end, false  );
    self:RegisterChatCommand("dcrreset"     ,function() D:ResetWindow()                             end, false  );
    self:RegisterChatCommand("dcrshow"      ,function() D:HideBar(0)                                end, false  );
    self:RegisterChatCommand("dcrhide"      ,function() D:HideBar(1)                                end, false  );
    self:RegisterChatCommand("dcrshoworder" ,function() D:Show_Cure_Order()                         end, false  );
    self:RegisterChatCommand("dcrreport"    ,function() T._ShowDebugReport()                         end, false  );
    -- }}}


    -- Shortcuts to xml created objects
    D.MFContainer       = DcrMUFsContainer;
    D.MFContainerHandle = DcrMUFsContainerDragButton;
    D.MicroUnitF.Frame  = D.MFContainer;
    D.LLContainer       = DcrLiveList;
    D.LiveList.Frame    = DcrLiveList;

    D.DebuffHistory = {};

    SetRuntimeConstants_Once();

    LibStub("AceComm-3.0"):RegisterComm("DecursiveVersion", D.OnCommReceived);

    -- Handle events directly without relying on AceEvent to prevent undue
    -- "script ran too long" errors caused by the queuing of event handler
    -- calls into a per-event dispatcher for ALL add-ons registering an event...
    -- (The more add-ons registering an event the more chances to get a random
    -- "script ran too long" error)
    D.eventFrame = CreateFrame("Frame");
    D.eventFrame:Hide();

    T._CatchAllErrors = false;

end -- // }}}

local FirstEnable = true;
function D:OnEnable() -- called after PLAYER_LOGIN -- {{{

    if T._SelfDiagnostic() == 2 then
        return false;
    end

    -- call _HookErrorHandler() a second time because of BugGrabber versions anerior to the
    -- alpha of 2012-11-23 which fail to make their callback available for
    -- registration b4 PLAYER_LOGIN...
    if not T._HookErrorHandler() then
        T._AddDebugText("BG's callbacks were not available after PLAYER_LOGIN. Make sure you are using the very latest version of BugGrabber available at: https://www.wowace.com/projects/bug-grabber/files or disable it.");
    end

    T._CatchAllErrors = "OnEnable"; -- During init we catch all the errors else, if a library fails we won't know it.
    D.debug = D.db.global.debug;


    if (FirstEnable) then
        D:ExportOptions ();
        -- configure the message frame for Decursive
        DecursiveTextFrame:SetFading(true);
        DecursiveTextFrame:SetFadeDuration(D.CONF.TEXT_LIFETIME / 3);
        DecursiveTextFrame:SetTimeVisible(D.CONF.TEXT_LIFETIME);

    end

    -- hook the load macro thing {{{
    -- So Decursive will re-update its macro when the macro UI is closed
    D:SecureHook("ShowMacroFrame", function ()
        if not D:IsHooked(MacroPopupFrame, "Hide") then
            D:Debug("Hooking MacroPopupFrame:Hide()");
            D:SecureHook(MacroPopupFrame, "Hide", function () D:UpdateMacro(); end);
        end
    end); -- }}}

    D:SecureHook("CastSpellByName", "HOOK_CastSpellByName");
    D:SecureHook(C_Item, "UseItemByName",   "HOOK_UseItemByName");

    -- these events are automatically stopped when the addon is disabled by Ace

    -- Spell changes events
    D.eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB");
    D.eventFrame:RegisterEvent("SPELLS_CHANGED");
    D.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    D.eventFrame:RegisterEvent("BAG_UPDATE_DELAYED");
    D.eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
    if not DC.WOWC or DC.CATACLYSM then
        D.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE");
    end
    D.eventFrame:RegisterEvent("PLAYER_ALIVE"); -- talents SHOULD be available
    D.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    D.eventFrame:RegisterEvent("PLAYER_LEAVING_WORLD");

    -- Combat detection events
    D.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
    D.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");

    -- Raid/Group changes events
    D.eventFrame:RegisterEvent("PARTY_LEADER_CHANGED");

    D.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");

    if not DC.WOWC or DC.CATACLYSM then
        D.eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
    end

    -- Player pet detection event (used to find pet spells)
    D.eventFrame:RegisterEvent("UNIT_PET");

    D.eventFrame:RegisterEvent("UNIT_AURA");

    D.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");

    D.eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

    D.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    D.eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN");

    self:RegisterMessage("DECURSIVE_TALENTS_AVAILABLE");

    D:ScheduleRepeatedCall("ScheduledTasks", D.ScheduledTasks, 0.3, D);

    -- Configure specific profile dependent data
    D:SetConfiguration();

    -- if FirstEnable and not D.db.global.NoStartMessages then
    --    D:ColorPrint(0.3, 0.5, 1, L["IS_HERE_MSG"]);
        -- D:ColorPrint(0.3, 0.5, 1, L["SHOW_MSG"]);
    -- end

    FirstEnable = false;

    D:StartTalentAvaibilityPolling();

    D.eventFrame:SetScript("OnEvent", D.OnEvent);

    T._CatchAllErrors = false;

end -- // }}}

function D:SetConfiguration() -- {{{

    if T._SelfDiagnostic() == 2 then
        return false;
    end
    T._CatchAllErrors = "SetConfiguration"; -- During init we catch all the errors else, if a library fails we won't know it.

    D.DcrFullyInitialized = false;
    D:CancelDelayedCall("Dcr_LLupdate");
    D:CancelDelayedCall("Dcr_MUFupdate");
    D:CancelDelayedCall("Dcr_ScanEverybody");

    D.Groups_datas_are_invalid = true;
    D.Status = {};
    D.Status.FoundSpells = {};
    --FoundSpells is {1: Pet?, 2: spellID, 3: IsEnhanced, 4: spell prio, 5: user MacroText, 6: unit filter};
    D.Status.UnitFilteringTypes = {};
    D.Status.CuringSpells = {};
    D.Status.CuringSpellsPrio = {};
    D.Status.Blacklisted_Array = {};
    D.Status.UnitNum = 0;
    D.Status.DelayedFunctionCalls = {};
    D.Status.DelayedFunctionCallsCount = 0;
    D.Status.MaxConcurentUpdateDebuff = 0;
    D.Status.PrioChanged = true;
    D.Status.last_focus_GUID = false;
    D.Status.GroupUpdatedOn = 0;
    D.Status.GroupUpdateEvent = 0;
    D.Status.UpdateCooldown = 0;
    D.Status.MouseOveringMUF = false;
    D.Status.TestLayout = false;
    D.Status.TestLayoutUNum = 25;
    D.Status.Unit_Array_GUIDToUnit = {};
    D.Status.Unit_Array_UnitToGUID = {};
    D.Status.Unit_Array = {};
    D.Status.InternalPrioList = {};
    D.Status.InternalSkipList = {};
    D.Status.WaitingForSpellInfo = false;
    D.Status.t_CheckBleedDebuffsActiveIDs = {};
    D.Status.delayedDebuffReportDisabled = true; -- reenabled in the ScanEverybody function
    D.Status.delayedDebuffOccurences = 0;
    D.Status.delayedUnDebuffOccurences = 0;
    D.Status.prio_macro = {};

    D.Stealthed_Units = {};

    -- if we log in and we are already fighting...
    if InCombatLockdown() then
        D.Status.Combat = true;
    end

    D.profile = D.db.profile; -- shortcut
    D.classprofile = D.db.class; -- shortcut
    -- reset: /run  LibStub("AceAddon-3.0"):GetAddon("Decursive").db.class.CureOrder = {}
    -- reset: /run  LibStub("AceAddon-3.0"):GetAddon("Decursive").db.class["CureOrder-"..(GetSpecialization or GetActiveTalentGroup)()][64] = nil

    D:reset_t_CheckBleedDebuffsActiveIDs();


    if D.db.locale.BleedEffectsKeywords:trim() ~= "" then
        D.Status.P_BleedEffectsKeywords_noCase = D:makeNoCasePattern(D.db.locale.BleedEffectsKeywords);
    else
        D.Status.P_BleedEffectsKeywords_noCase = false;
    end

    -- Upgrade layer for versions of Decursive prior to 2013-03-03
    for spell, spellData in pairs(D.classprofile.UserSpells) do
        if type(spell) == 'string' then

            if not D.classprofile.oldUserSpells then
                D.classprofile.oldUserSpells = {};
            end

            -- store the string-indexed in the old spell table
            D.classprofile.oldUserSpells[spell] = spellData;

            -- remove it from its original location
            D.classprofile.UserSpells[spell] = nil;
        end
    end

    if D.classprofile.oldUserSpells then
        local itemNum = 0;

        for spell, spellData in pairs(D.classprofile.oldUserSpells) do

            itemNum = itemNum + 1;

            if type(spell) == 'string' and tonumber(spell) then
                D.classprofile.oldUserSpells[spell] = nil;

                if tonumber(spell) ~= 2139 and not D.classprofile.UserSpells[tonumber(spell)] then
                    D.classprofile.UserSpells[tonumber(spell)] = spellData;
                end
                --[=[@alpha@
                D:AddDebugText('Sanity check error: string-number (',spell,') found in ', 'oldUserSpells' );
                --@end-alpha@]=]

            elseif type(spell) == 'string' then -- necessary due to fuck up in previous release

                local spellId = D:GetSpellUsefulInfoIfKnown(spell); -- attempt to get the spell id from the name

                if spellId then -- the spell is known to the player

                    if not D.classprofile.UserSpells[spellId] then
                        D.classprofile.UserSpells[spellId] = spellData;
                    else
                        D.classprofile.oldUserSpells[spell] = nil; -- remove it from its origin
                    end
                end
            else
                D.classprofile.oldUserSpells[spell] = nil; -- remove it since it's already a numbered spell
            end

        end

        if itemNum == 0 then
            D.classprofile.oldUserSpells = nil;
        end

    end

    -- Remove invalid spell ids from D.classprofile.UserSpells
    for spellOrItemID, spellData in pairs(D.classprofile.UserSpells) do
        -- IsSpellKnown and isItemUsable crash on > 32 bit signed integers
        -- It seems that the maximum value of a spell id is 24 bits
        -- Try the id on the functions directly and remove them if they crash (they can return nothing at an early game loading stage)
        if not (pcall(
            function ()
                return spellData.IsItem and (GetItemInfo(spellOrItemID * -1)) or (GetSpellName(spellOrItemID))
            end)) then
            D.classprofile.UserSpells[spellOrItemID] = nil;
            --[==[@debug@
            D:AddDebugText("Invalid spell/item id detected and removed:", spellOrItemID, spellData.MacroText)
            --@end-debug@]==]
        end
    end


    -- update layer for debuff filtering from version prior to 2020-03-19
    local oldDebuffsSkipList = {};
    -- make a copy of the table since we may add new keys while iterating with pairs()
    D:tcopy(oldDebuffsSkipList, D.profile.DebuffsSkipList);
    for key, debuffName in pairs(oldDebuffsSkipList) do
        if type(key) == 'number' then
            -- Let's associate a fake spell ID to existing user added names since
            -- there is no way to retrieve this ID from the debuff tranlated name
            if not D.defaults.profile.DebuffsSkipList[debuffName] then
                D.profile.DebuffsSkipList[debuffName] = 0;
            end
            D.profile.DebuffsSkipList[key] = nil;
        end
    end
    oldDebuffsSkipList = nil;


    if type (D.profile.OutputWindow) == "string" then
        D.Status.OutputWindow = _G[D.profile.OutputWindow];
    end

    --D.debugFrame = D.Status.OutputWindow;
    --D.printFrame = D.Status.OutputWindow;

    D:Debug("Loading profile datas...");

    D:Init(); -- initialize Dcr core (set frames display, scans available cleansing spells)

    D.MicroUnitF.MaxUnit = D.profile.DebuffsFrameMaxCount;

    if D.profile.MF_colors['Chronometers'] then
        D.profile.MF_colors[ "COLORCHRONOS"] = D.profile.MF_colors['Chronometers'];
        D.profile.MF_colors['Chronometers'] = nil;
    end

    D.MicroUnitF:RegisterMUFcolors(D.profile.MF_colors); -- set the colors as set in the profile

    D.Status.Enabled = true;

    -- set Icon
    if not D.Status.HasSpell or D.profile.HideLiveList and not D.profile.ShowDebuffsFrame then
        D:SetIcon(DC.IconOFF);
    else
        D:SetIcon(DC.IconON);
    end

    -- put the updater events at the end of the init so there is no chance they could be called before everything is ready (even if LUA is not multi-threaded... just to stay logical )
    if not D.profile.HideLiveList then
        self:ScheduleRepeatedCall("Dcr_LLupdate", D.LiveList.Update_Display, D.profile.ScanTime, D.LiveList);
    end

    if D.profile.ShowDebuffsFrame then
        self:ScheduleRepeatedCall("Dcr_MUFupdate", self.DebuffsFrame_Update, self.db.global.DebuffsFrameRefreshRate, self);

        if self.db.global.MFScanEverybodyTimer > 0 then
            self:ScheduleRepeatedCall("Dcr_ScanEverybody", self.ScanEveryBody, self.db.global.MFScanEverybodyTimer, self, self.db.global.ScanEverybodyReport);
        end
    end

    D.DcrFullyInitialized = true; -- everything should be OK
    D:ShowHideButtons(true);
    D:AutoHideShowMUFs();


    D.MicroUnitF:Delayed_Force_FullUpdate(); -- schedule all attributes of exixting MUF to update

    D:SetMinimapIcon();

    -- code for backward compatibility
    if     ((not next(D.profile.PrioGUIDtoNAME)) and #D.profile.PriorityList ~= 0)
        or ((not next(D.profile.SkipGUIDtoNAME)) and #D.profile.SkipList ~= 0) then
        D:ClearPriorityList();
        D:ClearSkipList();
    end


    T._CatchAllErrors = false; -- During init we catch all the errors else, if a library fails we won't know it.
    D:VersionWarnings();
end -- }}}

function D:OnDisable() -- When the addon is disabled by Ace -- {{{
    D.Status.Enabled = false;
    D.DcrFullyInitialized = false;

    D:SetIcon("Interface\\AddOns\\Decursive\\iconOFF.tga");

    if ( D.profile.ShowDebuffsFrame) then
        D.MFContainer:Hide();
    end

    D:CancelAllTimedCalls();
    D:Debug(D:GetTimersInfo());

    -- the disable warning popup : {{{ -
    StaticPopupDialogs["Decursive_OnDisableWarning"] = {
        text = L["DISABLEWARNING"],
        button1 = "OK",
        OnAccept = function()
            return false;
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = false,
        showAlert = 1,
        preferredIndex = 3,
    }; -- }}}

    LibStub("AceConfigRegistry-3.0"):NotifyChange(D.name);
    D.eventFrame:SetScript("OnEvent", nil);
    StaticPopup_Show("Decursive_OnDisableWarning");
end -- }}}

-------------------------------------------------------------------------------
-- init functions and configuration functions {{{
-------------------------------------------------------------------------------
function D:Init() --{{{

    if (D.profile.OutputWindow == nil or not D.profile.OutputWindow) then
        D.Status.OutputWindow = DEFAULT_CHAT_FRAME;
        D.profile.OutputWindow =  "DEFAULT_CHAT_FRAME";
    end

    -- if not D.db.global.NoStartMessages then
    --    D:Println("%s %s by %s", D.name, D.version, D.author);
    -- end

    D:Debug( "Decursive Initialization started!");


    -- SET MF FRAME AS WRITTEN IN THE CURRENT PROFILE {{{
    -- Set the scale and place the MF container correctly
    if D.profile.ShowDebuffsFrame then
        D.MicroUnitF:Show();
    else
        D.MFContainer:Hide();
    end
    D.MFContainerHandle:EnableMouse(not D.profile.HideMUFsHandle);

    -- }}}


    -- SET THE LIVE_LIST FRAME AS WRITTEN IN THE CURRENT PROFILE {{{

    -- Set poristion and scale
    DecursiveMainBar:SetScale(D.profile.LiveListScale);
    DecursiveMainBar:Show();
    DcrLiveList:SetScale(D.profile.LiveListScale);
    DcrLiveList:Show();
    D:PlaceLL();

    if D.profile.BarHidden then
        DecursiveMainBar:Hide();
    else
        DecursiveMainBar:Show();
    end

    -- displays frame according to the current profile
    if (D.profile.HideLiveList) then
        DcrLiveList:Hide();
    else
        DcrLiveList:ClearAllPoints();
        DcrLiveList:SetPoint("TOPLEFT", "DecursiveMainBar", "BOTTOMLEFT");
        DcrLiveList:Show();
    end

    -- set Alpha
    DecursiveMainBar:SetAlpha(D.profile.LiveListAlpha);
    -- }}}

    if (D.db.global.MacroBind == "NONE") then
        D.db.global.MacroBind = false;
    end


    D:ChangeTextFrameDirection(D.profile.CustomeFrameInsertBottom);


    -- Configure spells
    D:Configure();

end --}}}

local function SpellIterator() -- {{{
    local currentSpellTable = DC.SpellsToUse;
    local currentKey = nil;
    local iter

    iter = function()
        local ST

        currentKey, ST = next(currentSpellTable, currentKey);

        -- we reached the end of a table
        if currentKey == nil and currentSpellTable == DC.SpellsToUse then
            -- it was the base table now use the user defined one
            currentSpellTable = D.classprofile.UserSpells;
            --[==[@debug@
            D:Debug("|cFF00FF00Shifting to user spells|r");
            --@end-debug@]==]
            return iter(); -- continue with the other table
        elseif currentSpellTable == DC.SpellsToUse and D.classprofile.UserSpells[currentKey] and not D.classprofile.UserSpells[currentKey].Hidden and not D.classprofile.UserSpells[currentKey].Disabled and currentSpellTable[currentKey].MacroText then
            -- if the user actively redefined that spell then skip the default one
            --[==[@debug@
            D:Debug("Skipping default", currentKey);
            --@end-debug@]==]
            return iter(); -- aka 'continue'
        end

        -- if it's already defined in the base table (but not editable) or if it's hidden, skip it
        if ST and (currentSpellTable ~= DC.SpellsToUse and (DC.SpellsToUse[currentKey] and not currentSpellTable[currentKey].MacroText or currentSpellTable[currentKey].Hidden)) then
            --[==[@debug@
            D:Debug("Skipping", currentKey);
            if currentSpellTable ~= DC.SpellsToUse and DC.SpellsToUse[currentKey] then
                D:Print("|cFFFF0000Ignored custom spell id|r", currentKey, "remove this spell from the custom spells list or re-add it with the edit macro option checked.");
            end
            --@end-debug@]==]

            return iter(); -- aka 'continue'
        end

        return currentKey, ST;
    end;

    return iter;
end -- }}}

function D:ReConfigure() --{{{

    D:Debug("|cFFFF0000D:ReConfigure was called!|r");
    if not D.DcrFullyInitialized then
        D:Debug("|cFFFF0000D:ReConfigure aborted, init incomplete!|r");
        return false;
    end

    if InCombatLockdown() then
        D:Debug("|cFFFF0000D:ReConfigure postponed, in combat!|r");
        D:AddDelayedFunctionCall (
        "Configure", self.ReConfigure,
        self);
        return false;
    end

    local SpellName = "";

    local Reconfigure = false;
    for spellID, spell in SpellIterator() do repeat

        SpellName = D.GetSpellOrItemInfo(spellID);

        spell.IsItem = (spellID < 0); -- pre-emptive fix for erroneous configuration -- this *-1 thing was a bad idea...

        -- if item info not available yet
        if spell.IsItem and not SpellName then
            self.Status.WaitingForSpellInfo = -1 * spellID;
            self:Debug("Item name not available yet");
            break;
        end

        -- Do we have that spell?
        if not spell.IsItem and D:isSpellReady(spellID, spell.Pet)
            or spell.IsItem and D:isItemUsable(-1 * spellID) then

            -- We had it but it's been disabled
            if spell.Disabled and D.Status.FoundSpells[SpellName] then
                D:Debug("D:ReConfigure:", SpellName, 'has been disabled');
                Reconfigure = true;
                break;
                -- is it new?
            elseif not spell.Disabled and not D.Status.FoundSpells[SpellName] then -- yes
                D:Debug("D:ReConfigure:", SpellName, 'is new');
                Reconfigure = true;
                break;
            elseif spell.EnhancedBy then -- it's not new but there is an enhancement available...

                -- Workaround to the fact that function are not serialized upon storage to the DB
                if not spell.EnhancedByCheck and D.classprofile.UserSpells[spellID] then
                    spell.EnhancedByCheck = DC.SpellsToUse[spellID].EnhancedByCheck;
                    D.classprofile.UserSpells[spellID].EnhancedByCheck = spell.EnhancedByCheck;
                end

                if spell.EnhancedByCheck() then -- we have it now
                    if not D.Status.FoundSpells[SpellName][3] then -- but not then :)
                        D:Debug("D:ReConfigure:", SpellName, 'has an enhancement that was not available b4');
                        Reconfigure = true;
                        break;
                    end
                else -- we do no not
                    if D.Status.FoundSpells[SpellName][3] then -- but we used to :'(
                        D:Debug("D:ReConfigure:", SpellName, 'had an enhancement that is no longer available');
                        Reconfigure = true;
                        break;
                    end
                end
            end

        elseif D.Status.FoundSpells[SpellName] then -- we don't have it anymore...
            D:Debug("D:ReConfigure:", SpellName, 'is no longer available', spellID);
            Reconfigure = true;
            break;
        end
    break until true if Reconfigure then break end end -- a continue statement would have been nice in Lua...

    if Reconfigure == true then
        D:Debug("D:ReConfigure RECONFIGURATION!");
        D:Configure();
        return true;
    end
    D:Debug("D:ReConfigure No reconfiguration required!");

end --}}}



function D:Configure() --{{{


    if InCombatLockdown() then
        D:Debug("|cFFFF0000D:Configure postponed, in combat!|r");
        D:AddDelayedFunctionCall (
        "Configure", self.Configure,
        self);
        return false;
    end

    -- first empty out the old "spellbook"
    self.Status.HasSpell = false;
    self.Status.FoundSpells = {};
    self.Status.delayedDebuffReportDisabled = true;


    local CuringSpells = self.Status.CuringSpells;

    CuringSpells[DC.MAGIC]      = false;
    CuringSpells[DC.ENEMYMAGIC] = false;
    CuringSpells[DC.CURSE]      = false;
    CuringSpells[DC.POISON]     = false;
    CuringSpells[DC.DISEASE]    = false;
    CuringSpells[DC.CHARMED]    = false;
    CuringSpells[DC.BLEED]      = false;

    local Type, _;
    local IsSpellKnown = nil; -- use D:isSpellReady instead
    local Types = {};
    local UnitFiltering = false;
    local ActualUnitFiltering = false;
    local PermanentUnitFiltering = false;
    local IsEnhanced = false;
    local SpellName = "";

    self:Debug("Configuring Decursive...");

    for spellID, spell in SpellIterator() do repeat
        if not spell.Disabled then
            -- self:Debug("trying spell", spellID);

            spell.IsItem = (spellID < 0); -- pre-emptive fix for erroneous configuration -- this *-1 thing was a bad idea...

            -- Do we have that spell?
            if not spell.IsItem and D:isSpellReady(spellID, spell.Pet)
                or spell.IsItem and D:isItemUsable(-1 * spellID) then

                SpellName = D.GetSpellOrItemInfo(spellID);

                -- if item info not available yet
                if spell.IsItem and not SpellName then
                    self.Status.WaitingForSpellInfo = -1 * spellID;
                    self:Debug("Item name not available yet");
                    break;
                end

                Types = spell.Types;
                UnitFiltering = false;
                ActualUnitFiltering = false;
                IsEnhanced = false;

                if spell.UnitFiltering then
                    UnitFiltering = spell.UnitFiltering;
                end

                -- Could it be enhanced by something (a talent for example)?
                if spell.EnhancedBy then
                    --[=[@alpha@
                    self:Debug("Enhancement for ", SpellName);
                    --@end-alpha@]=]

                    -- Workaround to the fact that function are not serialized upon storage to the DB
                    if not spell.EnhancedByCheck and D.classprofile.UserSpells[spellID] and DC.SpellsToUse[spellID] then -- XXX
                        spell.EnhancedByCheck = DC.SpellsToUse[spellID].EnhancedByCheck;
                        D.classprofile.UserSpells[spellID].EnhancedByCheck = spell.EnhancedByCheck;
                    end

                    if spell.EnhancedByCheck and spell.EnhancedByCheck() then -- we have the enhancement
                        IsEnhanced = true;

                        Types = spell.Enhancements.Types; -- set the type to scan to the new ones

                        if spell.Enhancements.UnitFiltering then -- On the 'player' unit only?
                            --[=[@alpha@
                            self:Debug("Enhancement for %s is for player only", SpellName);
                            --@end-alpha@]=]
                            UnitFiltering = spell.Enhancements.UnitFiltering;
                        end
                    end
                end

                -- register it
                self.Status.FoundSpells[SpellName] = {spell.Pet, spellID, IsEnhanced, spell.Better, spell.MacroText, nil};
                for _, Type in ipairs (Types) do

                    if not CuringSpells[Type]
                        or spell.Better > self.Status.FoundSpells[CuringSpells[Type]][4]
                        or not spell.UnitFiltering and self.Status.FoundSpells[CuringSpells[Type]][6] then
                        -- we did not already register this spell
                        -- or it's not the best spell for this type
                        -- or there the it has no unit filtering while the previous one had one.

                        CuringSpells[Type] = SpellName;

                        if UnitFiltering and UnitFiltering[Type] then
                            self:Debug("Spell with unit filtering added :", Type, UnitFiltering[Type]);
                            self.Status.UnitFilteringTypes[Type] = UnitFiltering[Type];

                            if not ActualUnitFiltering then
                                ActualUnitFiltering = {};
                            end

                            ActualUnitFiltering[Type] = UnitFiltering[Type];
                        else
                            self.Status.UnitFilteringTypes[Type] = false;
                        end

                        self:Debug("Spell \"%s\" (%s) registered for type %d ( %s ), PetSpell: ", SpellName, D.Status.FoundSpells[SpellName][2], Type, DC.TypeNames[Type], D.Status.FoundSpells[SpellName][1]);
                        self.Status.HasSpell = true;
                    end
                end

                if ActualUnitFiltering then
                    local filteredTypeCount = 0;
                    local lastfilter = false;
                    -- check if the filters are identical for every type
                    for Type, filter in pairs(ActualUnitFiltering) do

                        if not lastfilter then
                            lastfilter = filter;
                        elseif lastfilter ~= filter then
                            lastfilter = false;
                            break;
                        end

                        filteredTypeCount = filteredTypeCount + 1;
                    end

                    if lastfilter and filteredTypeCount == #Types then -- we have the same filter everywhere and all the types managed by this spell are affected
                        D.Status.FoundSpells[SpellName][6] = lastfilter;
                        --[=[@alpha@
                        self:Debug("permanent filter added for spell",SpellName, lastfilter);
                        --@end-alpha@]=]
                    end

                end

            end
        end
    break until true end

    -- Verify the cure order list (if it was damaged)
    self:CheckCureOrder ();
    -- Set the appropriate priorities according to debuffs types
    self:SetCureOrder ();

    LibStub("AceConfigRegistry-3.0"):NotifyChange(D.name);

    return true;

end --}}}

function D:SetSpellsTranslations(FromDIAG) -- {{{

    if not T._C.DS then
        T._C.DS = {};
        T._C.EXPECTED_DUPLICATES = {};

        T._C.DSI = { -- Main spell table for WoW Retail {{{
            ["SPELL_POLYMORPH"]             =  118,
            ["SPELL_COUNTERSPELL"]          =  2139,
            ["SPELL_CYCLONE"]               =  33786,
            ["SPELL_REMOVE_CURSE_MAGE"]     =  475,
            ["SPELL_CONSUME_MAGIC"]         =  278326,
            ["SPELL_SPELLSTEAL"]            =  30449, -- mages, not sure about this one
            ["SPELL_CLEANSE"]               =  4987,
            ["SPELL_CLEANSE_TOXINS"]        =  213644,
            ['SPELL_HEX']                   =  51514, -- shamans
            ["CLEANSE_SPIRIT"]              =  51886,
            ["SPELL_PURGE"]                 =  370,
            ["PET_TORCH_MAGIC"]             =  171021,
          --["PET_CLONE_MAGIC"]             =  115284, -- XXX disappeared in 7.2.5, devour magic seems to have returned...
            ["PET_DEVOUR_MAGIC"]            =  19505,
            ["SPELL_FEAR"]                  =  5782,
            ["DCR_LOC_SILENCE"]             =  15487,
            ["DCR_LOC_MINDVISION"]          =  2096,
            ["DREAMLESSSLEEP"]              =  15822,
            ["GDREAMLESSSLEEP"]             =  24360,
            ["MDREAMLESSSLEEP"]             =  28504,
            ["ANCIENTHYSTERIA"]             =  19372,
            ["IGNITE"]                      =  19659,
            ["TAINTEDMIND"]                 =  16567,
            ["MAGMASHAKLES"]                =  19496,
            ["CRIPLES"]                     =  33787,
            ["DUSTCLOUD"]                   =  26072,
            ["WIDOWSEMBRACE"]               =  28732,
            ["SONICBURST"]                  =  39052,
            ["DELUSIONOFJINDO"]             =  24306,
            ["MUTATINGINJECTION"]           =  28169,
            ['Banish']                      =  710,
            ['Frost Trap Aura']             =  13810,
            ['Arcane Blast']                =  30451,
            ['Prowl']                       =  5215,
            ['Stealth']                     =  1784,
            ['Shadowmeld']                  =  58984,
            ['Invisibility']                =  66,
            ['Lesser Invisibility']         =  7870,
            ['Unstable Affliction']         =  30108,
            ['Fluidity']                    =  138002,
            ['Vampiric Touch']              =  34914,
            ["SPELL_REMOVE_CORRUPTION"]     =  2782,
            ["PET_SINGE_MAGIC"]             =  89808, -- Warlock imp
            ["PET_SINGE_MAGIC_PVP"]         =  212623, -- Warlock imp PVP
            ["PET_SEAR_MAGIC"]              =  115276, -- Warlock Fel imp
            ["SPELL_PURIFY"]                =  527,
            ["SPELL_PURIFY_DISEASE"]        =  213634,
            ["IMPROVED_PURIFY"]             =  390632,
            ["SPELL_DISPELL_MAGIC"]         =  528,
            ["PURIFY_SPIRIT"]               =  77130, -- resto shaman
            ["IMPROVED_PURIFY_SPIRIT"]      =  383016, -- resto shaman
            ["SPELL_NATURES_CURE"]          =  88423,
            ["SPELL_DETOX_1"]               =  115450, -- monk mistweaver
            ["SPELL_DETOX_2"]               =  218164, -- monk brewmaster and windwaker
            ["SPELL_IMPROVED_DETOX"]        =  388874, -- monk's talent
            ["SPELL_DIFFUSEMAGIC"]          =  122783, -- monk
            ["SPELL_COMMAND_DEMON"]         =  119898, -- warlock
            ['Greater Invisibility']        =  110959,
            ['SPELL_MENDINGBANDAGE']        =  212640,
            ['SPELL_REVERSEMAGIC']          =  205604,
            ['SPELL_WILL_OF_THE_FORSAKEN']  =  7744,
            ['SPELL_EXPUNGE']               =  365585,
            ['SPELL_NATURALIZE']            =  360823,
            ['SPELL_CAUTERIZING_FLAME']     =  374251,
            ['SPELL_POISON_CLEANSING_TOTEM']=  383013, -- shaman
            ['DEBUFF_VOID_RIFT']            =  440313, -- omni-debuff dispellable by any spell
        }; --- }}}

        T._C.EXPECTED_DUPLICATES = {
            {"SPELL_DETOX_1", "SPELL_DETOX_2"},
            {"PET_SINGE_MAGIC", "PET_SINGE_MAGIC_PVP"},
        }

        -- if running in WoW Classic, we need to adjust the main spell table
        if DC.WOWC then
            if not DC.CATACLYSM then
                local DSI_REMOVED_OR_CHANGED_IN_CLASSIC = { -- {{{
                    ['Invisibility']            = 66,
                    ['Shadowmeld']              = 58984,
                    ["SPELL_DISPELL_MAGIC"]     = 528,
                    ["SPELL_PURIFY"]            = 527,
                    ["Fluidity"]	            = 138002,
                    ["SPELL_SPELLSTEAL"]	    = 30449,
                    ["SPELL_CONSUME_MAGIC"]	    = 278326,
                    ["PET_TORCH_MAGIC"]	        = 171021,
                    ["SPELL_HEX"]	            = 51514,
                    ["SPELL_CYCLONE"]	        = 33786,
                    ["SPELL_DETOX_1"]	        = 115450,
                    ["Unstable Affliction"]	    = 30108,
                    ["SPELL_REVERSEMAGIC"]	    = 205604,
                    ["PET_SEAR_MAGIC"]	        = 115276,
                    ["SPELL_COMMAND_DEMON"]	    = 119898,
                    ["Greater Invisibility"]    = 110959,
                    ["SPELL_MENDINGBANDAGE"]    = 212640,
                    ["CRIPLES"]	                = 33787,
                    ["Arcane Blast"]	        = 30451,
                    ["SPELL_DETOX_2"]	        = 218164,
                    ["SPELL_IMPROVED_DETOX"]    = 388874,
                    ["MDREAMLESSSLEEP"]	        = 28504,
                    ["PURIFY_SPIRIT"]	        = 77130,
                    ["SONICBURST"]	            = 39052,
                    ["SPELL_PURIFY_DISEASE"]    = 213634,
                    ["IMPROVED_PURIFY"]         = 390632,
                    ["Vampiric Touch"]	        = 34914,
                    ["CLEANSE_SPIRIT"]	        = 51886,
                    ["SPELL_NATURES_CURE"]	    = 88423,
                    ["PET_SINGE_MAGIC"]	        = 89808,
                    ["PET_SINGE_MAGIC_PVP"]	    = 212623,
                    ["SPELL_CLEANSE_TOXINS"]    = 213644,
                    ["SPELL_DIFFUSEMAGIC"]	    = 122783,
                    ["SPELL_REMOVE_CORRUPTION"] = 2782,
                    ['SPELL_EXPUNGE']           = 365585,
                    ['SPELL_NATURALIZE']        = 360823,
                    ['SPELL_CAUTERIZING_FLAME'] = 374251,
                    ["IMPROVED_PURIFY_SPIRIT"]  = 383016, -- resto shaman
                    ['SPELL_POISON_CLEANSING_TOTEM']= 383013, -- shaman
                    ['DEBUFF_VOID_RIFT']            =  440313, -- omni-debuff dispellable by any spell
                } -- }}}

                -- remove invalid spells from the spell table
                for name, sid in pairs(DSI_REMOVED_OR_CHANGED_IN_CLASSIC) do
                    T._C.DSI[name] = nil;
                end

                -- reassign the proper spells
                -- The new and changed spells in classic {{{
                T._C.DSI["SPELL_REMOVE_CURSE_DRUID"]  = 2782;
                T._C.DSI["SPELL_REMOVE_CURSE_MAGE"]   = 475;
                T._C.DSI["SPELL_REMOVE_GREATER_CURSE"]= 412113; --  WoW SoD
                T._C.DSI["SPELL_PURGE"]               = 370;
                T._C.DSI["SPELL_CLEANSE"]             = 4987;
                T._C.DSI["SPELL_FEAR"]                = 5782;
                T._C.DSI["SPELL_POLYMORPH"]           = 118;
                T._C.DSI["SPELL_DISPELL_MAGIC"]       = 527;
                T._C.DSI["SPELL_PURIFY"]              = 1152;
                T._C.DSI["SPELL_ABOLISH_DISEASE"]     = 552;
                T._C.DSI["SPELL_ABOLISH_POISON"]      = 2893;
                T._C.DSI["SPELL_CURE_DISEASE_PRIEST"] = 528;
                T._C.DSI["SPELL_CURE_DISEASE_SHAMAN"] = 2870;
                T._C.DSI["SPELL_CURE_POISON_SHAMAN"]  = 526;
                T._C.DSI["SPELL_CURE_POISON_DRUID"]   = 8946;
                T._C.DSI["PET_DEVOUR_MAGIC"]          = 19505;
                T._C.DSI["SONICBURST"]                = 8281;
                T._C.DSI["CRIPLES"]                   = 11443;
                T._C.DSI["Shadowmeld"]                = 20580;
                T._C.DSI["SPELL_DISPELL_MAGIC_PRIEST_R2"] = 988;
                -- }}}

                T._C.EXPECTED_DUPLICATES = {
                    {"SPELL_CURE_DISEASE_PRIEST", "SPELL_CURE_DISEASE_SHAMAN"},
                    {"SPELL_CURE_POISON_SHAMAN", "SPELL_CURE_POISON_DRUID"},
                    {"SPELL_DISPELL_MAGIC", "SPELL_DISPELL_MAGIC_PRIEST_R2"},
                }

            else
                T._C.DSI = {
                    ["SPELL_POLYMORPH"]             =  118,
                    ["SPELL_COUNTERSPELL"]          =  2139,
                    ["SPELL_CYCLONE"]               =  33786,
                    ["SPELL_CLEANSE"]               =  4987,
                    ["SPELL_HAND_OF_SACRIFICE"]     =  6940,
                    ["PASSIVE_ABSOLVE"]             =  140333,
                    ["SPELL_CLEANSE_FROM_SYMBIOSIS"]=  122288,
                    ["SPELL_PURGE_FROM_SYMBIOSIS"]  =  110802,
                    ["SPELL_CYCLONE_FROM_SYMBIOSIS"]=  113506,
                    ['SPELL_TRANQUILIZING_SHOT']    =  19801,
                    ['SPELL_HEX']                   =  51514, -- shamans
                    ["CLEANSE_SPIRIT"]              =  51886,
                    ["SPELL_PURGE"]                 =  370,
                    ["PET_FEL_CAST"]                =  19505,
                    ["SPELL_FEAR"]                  =  5782,
                    ["DCR_LOC_SILENCE"]             =  15487,
                    ["DCR_LOC_MINDVISION"]          =  2096,
                    ["DREAMLESSSLEEP"]              =  15822,
                    ["GDREAMLESSSLEEP"]             =  24360,
                    ["MDREAMLESSSLEEP"]             =  28504,
                    ["ANCIENTHYSTERIA"]             =  19372,
                    ["IGNITE"]                      =  19659,
                    ["TAINTEDMIND"]                 =  16567,
                    ["MAGMASHAKLES"]                =  19496,
                    ["CRIPLES"]                     =  33787,
                    ["DUSTCLOUD"]                   =  26072,
                    ["WIDOWSEMBRACE"]               =  28732,
                    ["SONICBURST"]                  =  39052,
                    ["DELUSIONOFJINDO"]             =  24306,
                    ["MUTATINGINJECTION"]           =  28169,
                    ['Banish']                      =  710,
                    ['Frost Trap Aura']             =  13810,
                    ['Arcane Blast']                =  30451,
                    ['Prowl']                       =  5215,
                    ['Stealth']                     =  1784,
                    ['Camouflage']                  =  51755,
                    ['Shadowmeld']                  =  58984,
                    ['Invisibility']                =  66,
                    ['Lesser Invisibility']         =  7870,
                    ['Ice Armor']                   =  7302,
                    ['Unstable Affliction']         =  30108,
                    ['Fluidity']                    =  138002,
                    ['Vampiric Touch']              =  34914,
                    ['Flame Shock']                 =  8050,
                    ["SPELL_REMOVE_CURSE"]          =  475, -- Druids/Mages
                    ["SPELL_REMOVE_CORRUPTION"]     =  2782,
                    ["SPELL_SINGE_MAGIC"]           =  89808, -- Warlock imp
                    ["SPELL_PURIFY"]                =  527,
                    ["SPELL_DISPELL_MAGIC"]         =  528,
                    ["PURIFY_SPIRIT"]               =  77130, -- resto shaman
                    ["PASSIVE_SACRED_CLEANSING"]    =  53551,
                    ["PASSIVE_INTERNAL_MEDICINE"]   =  115451,
                    ["SPELL_NATURES_CURE"]          =  88423,
                    ["SHROUD_OF_CONCEALMENT"]       =  115834, -- rogue
                    ["SPELL_DETOX"]                 =  115450, -- monk
                    ["SPELL_DIFFUSEMAGIC"]          =  122783, -- monk
                    ["SPELL_COMMAND_DEMON"]         =  119898, -- warlock
                    ["SPELL_SYMBIOSIS"]             =  110309, -- this is the Druid ability
                    ["SPELL_SYMBIOSIS_PRIEST"]      =  110502, -- this is the Priest ability
                    ['Greater Invisibility']        =  110959,
                    ['GLYPH_OF_ICY_TOUCH']          =  58631, --DK
                    ['SPELL_ICY_TOUCH']             =  45477, --DK
                    ['SPELL_WILL_OF_THE_FORSAKEN']  =  7744,
                }

                T._C.EXPECTED_DUPLICATES = {
                     {"SPELL_CYCLONE", "SPELL_CYCLONE_FROM_SYMBIOSIS"},
                     {"SPELL_PURGE", "SPELL_PURGE_FROM_SYMBIOSIS"},
                     {"SPELL_CLEANSE", "SPELL_CLEANSE_FROM_SYMBIOSIS"},
                     {"SPELL_SYMBIOSIS", "SPELL_SYMBIOSIS_PRIEST"},
                }
            end

        end
    end

    local DS  = T._C.DS;
    local DSI = T._C.DSI;

    -- /spew DecursiveRootTable._C.DS

    -- Note to self: The truth is not unique, there can be several truths. The world is not binary. (epiphany on 2011-02-25)

    local duplicates = {};
    local alpha = false;
    --[=[@alpha@
    alpha = true;
    --@end-alpha@]=]
    local Sname, Sids, Sid, _, ok;
    ok = true;
    for Sname, Sid in pairs(DSI) do

        DS[Sname] = (GetSpellName(Sid));

        if FromDIAG and DS[Sname] then
            if not duplicates[DS[Sname]] then
                duplicates[DS[Sname]] = {Sname};
            else
                duplicates[DS[Sname]][#duplicates[DS[Sname]] + 1] = Sname;
            end

        end

        if not DS[Sname] then
            if random (1, 15000) == 2323 or FromDIAG then
                D:AddDebugText("SpellID:|cffff0000", Sid, "no longer exists.|r This was supposed to represent the spell", Sname);
                D:errln("SpellID:", Sid, "no longer exists. This was supposed to represent the spell", Sname);
            end
            DS[Sname] = "_LOST SPELL_";
        end
    end

    if FromDIAG then
        -- Do not report expected duplicates {{{
        local compareDuplicates = function (d1, d2)
            if #d1 ~= #d2 then
                return false;
            end
            table.sort(d1);
            table.sort(d2);

            for i, _ in ipairs(d1) do
                if d1[i] ~= d2[i] then
                    return false;
                end
            end

            return true;
        end
        for _, Snames in ipairs(T._C.EXPECTED_DUPLICATES) do
            if DS[Snames[1]] and duplicates[DS[Snames[1]]] then
                if compareDuplicates(Snames, duplicates[DS[Snames[1]]]) then
                    duplicates[DS[Snames[1]]] = nil;
                else
                    D:AddDebugText("Expected duplicates diverges for", Snames[1]);
                end
            else
                D:AddDebugText("Expected duplicates not found for", Snames[1]);
            end
        end -- }}}
        for spell, ids in pairs(duplicates) do
            if #ids > 1 then
                local dub = "";

                for _, id in ipairs(ids) do
                    dub = dub .. ", " .. id;
                end
                D:AddDebugText("|cffffAA22Unexpected duplicates found for", spell, ':|r ', dub);
            end
        end
    end

    return ok;

end -- }}}


-- Create the macro for Decursive
-- This macro will cast the first spell (priority)

local MAX_ACCOUNT_MACROS = _G.MAX_ACCOUNT_MACROS;

do

    local BlizzardIsAnnoyingComment = "# Ask Blizzard to re-add support for macrotext attribute dropped in wow 11 if you do not want to see this macro...\n"

    local function updateMacroByName(macroName, icon, macroText, notEditable) -- {{{
        if not D.Status.createdMacros then
            D.Status.createdMacros = {};
        end

        local createdMacros = D.Status.createdMacros

        local updatedMacroText = notEditable and BlizzardIsAnnoyingComment..macroText or macroText

        if (updatedMacroText:len() > 256) then
            updatedMacroText = macroText
        end

        local catchAllErrorBackup = T._CatchAllErrors;
        T._CatchAllErrors = false; -- the API calls below fire some WoW events (UPDATE_MACRO), we don't want to catch errors done by bugged handlers from other add-ons

        --D:PrintLiteral(GetMacroIndexByName(D.CONF.MACRONAME));
        if GetMacroIndexByName(macroName) ~= 0 then
            if notEditable or not D.profile.AllowMacroEdit then
                EditMacro(GetMacroIndexByName(macroName), macroName, icon, updatedMacroText);
                if notEditable then
                    createdMacros[macroName] = true
                end
                D:Debug(("Macro '%s' updated"):format(macroName));
            else
                D:Debug(("Macro '%s' not updated due to AllowMacroEdit"):format(macroName));
            end
        elseif (GetNumMacros()) < MAX_ACCOUNT_MACROS then
            CreateMacro(macroName, icon, updatedMacroText);
            if notEditable then
                createdMacros[macroName] = true
            end
        else
            D:errln(("Too many macros exist, Decursive cannot create its '%s' macro"):format(macroName));
            T._CatchAllErrors = catchAllErrorBackup;
            return false;
        end

        T._CatchAllErrors = catchAllErrorBackup;

        return true;
    end -- }}}

    function D:SetMacrosPerPrioTable(unit)
        local prio_macro = D.Status.prio_macro;
        local tmp;

        for Spell, Prio in pairs(D.Status.CuringSpellsPrio) do

            if not D.Status.FoundSpells[Spell][5] then -- if using the default macro mechanism

                    --the [target=%s, help][target=%s, harm] prevents the 'please select a unit' cursor problem (Blizzard should fix this...)
                    prio_macro[Prio] = {
                        macroText = ("%s/%s [@%s, help][@%s, harm] %s"):format(
                          not D.Status.FoundSpells[Spell][1] and "/stopcasting\n" or "", -- pet test
                          D.Status.FoundSpells[Spell][2] > 0 and "cast" or "use", -- item test
                          unit, unit,
                          Spell
                        ),
                        unitFiltering = D.Status.FoundSpells[Spell][6]
                    }
            else
                tmp = D.Status.FoundSpells[Spell][5];
                tmp = tmp:gsub("UNITID", unit);
                if tmp:len() < 256 then -- last chance protection, shouldn't happen
                    prio_macro[Prio] = {
                        macroText = tmp,
                        unitFiltering = D.Status.FoundSpells[Spell][6]
                    }
                else
                    D:errln("Macro too long for prio", Prio);
                end
            end

        end

    end

    function D:UpdateMacro () -- {{{


        if D.profile.DisableMacroCreation then
            return false;
        end

        if InCombatLockdown() then
            D:AddDelayedFunctionCall (
            "UpdateMacro", self.UpdateMacro,
            self);
            return false;
        end
        D:Debug("UpdateMacro called");

        local CuringSpellsPrio  = D.Status.CuringSpellsPrio;
        local ReversedCureOrder = D.Status.ReversedCureOrder;
        local CuringSpells      = D.Status.CuringSpells;


        -- Get an ordered spell table
        local Spells = {};
        for Spell, Prio in pairs(D.Status.CuringSpellsPrio) do -- XXX MACROUPDATE
            Spells[Prio] = Spell;
        end

        if (next (Spells)) then
            for i=1,4 do
                if (not Spells[i]) then
                    table.insert (Spells, CuringSpells[ReversedCureOrder[1] ]);
                end
            end
        end

        local MacroParameters = {
            D.CONF.MACRONAME,
            "INV_MISC_QUESTIONMARK", -- icon
            next(Spells) and string.format("/stopcasting\n/cast [@mouseover,nomod,exists] %s;  [@mouseover,exists,mod:ctrl] %s; [@mouseover,exists,mod:shift] %s", unpack(Spells)) or "/script DecursiveRootTable.Dcr:Println('"..L["NOSPELL"].."')",
        };

        local catchAllErrorBackup = T._CatchAllErrors;
        T._CatchAllErrors = false; -- the API calls below fire some WoW events (UPDATE_MACRO), we don't want to catch errors done by bugged handlers

        updateMacroByName(unpack(MacroParameters));

        D:SetMacroKey(D.db.global.MacroBind);

        T._CatchAllErrors = catchAllErrorBackup;
        return true;

    end -- }}}
end



-- }}}

function D:LocalizeBindings () -- {{{

    BINDING_NAME_DCRSHOW    = L["BINDING_NAME_DCRSHOW"];
    BINDING_NAME_DCRMUFSHOWHIDE = L["BINDING_NAME_DCRMUFSHOWHIDE"];
    BINDING_NAME_DCRPRADD     = L["BINDING_NAME_DCRPRADD"];
    BINDING_NAME_DCRPRCLEAR   = L["BINDING_NAME_DCRPRCLEAR"];
    BINDING_NAME_DCRPRLIST    = L["BINDING_NAME_DCRPRLIST"];
    BINDING_NAME_DCRPRSHOW    = L["BINDING_NAME_DCRPRSHOW"];
    BINDING_NAME_DCRSKADD   = L["BINDING_NAME_DCRSKADD"];
    BINDING_NAME_DCRSKCLEAR = L["BINDING_NAME_DCRSKCLEAR"];
    BINDING_NAME_DCRSKLIST  = L["BINDING_NAME_DCRSKLIST"];
    BINDING_NAME_DCRSKSHOW  = L["BINDING_NAME_DCRSKSHOW"];
    BINDING_NAME_DCRSHOWOPTION = L["BINDING_NAME_DCRSHOWOPTION"];

end -- }}}



T._LoadedFiles["DCR_init.lua"] = "2.7.29";

-------------------------------------------------------------------------------

--[======[
TEST to see what keyword substitutions are actually working....

Simple replacements

1162
    Turns into the current revision of the file in integer form. e.g. 1234
    Note: does not work for git
1163
    Turns into the highest revision of the entire project in integer form. e.g. 1234
    Note: does not work for git
25fb07d720cc473cd07551f1b2586c32de8ddcd2
    Turns into the hash of the file in hex form. e.g. 106c634df4b3dd4691bf24e148a23e9af35165ea
    Note: does not work for svn
d3883409b4c465994613669a1cb96d7235a25b3a
    Turns into the hash of the entire project in hex form. e.g. 106c634df4b3dd4691bf24e148a23e9af35165ea
    Note: does not work for svn
25fb07d
    Turns into the abbreviated hash of the file in hex form. e.g. 106c63 Note: does not work for svn
d388340
    Turns into the abbreviated hash of the entire project in hex form. e.g. 106c63
    Note: does not work for svn
Archarodim
    Turns into the last author of the file. e.g. ckknight
Archarodim
    Turns into the last author of the entire project. e.g. ckknight
2025-07-11T09:58:15Z
    Turns into the last changed date (by UTC) of the file in ISO 8601. e.g. 2008-05-01T12:34:56Z
2025-07-20T23:08:26Z
    Turns into the last changed date (by UTC) of the entire project in ISO 8601. e.g. 2008-05-01T12:34:56Z
20250711095815
    Turns into the last changed date (by UTC) of the file in a readable integer fashion. e.g. 20080501123456
20250720230826
    Turns into the last changed date (by UTC) of the entire project in a readable integer fashion. e.g. 2008050123456
1752227895
    Turns into the last changed date (by UTC) of the file in POSIX timestamp. e.g. 1209663296
    Note: does not work for git
1753052906
    Turns into the last changed date (by UTC) of the entire project in POSIX timestamp. e.g. 1209663296
    Note: does not work for git
2.7.29
    Turns into an approximate version of the project. The tag name if on a tag, otherwise it's up to the repo.
    :SVN returns something like "r1234"
    :Git returns something like "v0.1-873fc1"
    :Mercurial returns something like "r1234".

--]======]
