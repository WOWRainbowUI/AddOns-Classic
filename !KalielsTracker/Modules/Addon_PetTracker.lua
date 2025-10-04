--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonPetTracker
local M = KT:NewModule("AddonPetTracker")
KT.AddonPetTracker = M

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local OTF = KT_ObjectiveTrackerFrame
local PetTracker = PetTracker

local header, content
local contentWidth = 232

OBJECTIVE_TRACKER_UPDATE_MODULE_PETTRACKER = 0x1000000
OBJECTIVE_TRACKER_UPDATE_PETTRACKER = 0x2000000
PETTRACKER_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable()

M.Texts = {
    TrackPets = C_Spell.GetSpellName(122026),
    CapturedPets = "Show Captured",
    DisplayCondition = "Display Condition",
    DisplayAlways = "Always",
    DisplayMissingRares = "Missing Rares",
    DisplayMissingPets = "Missing Pets"
}

--------------
-- Internal --
--------------

local function SetHooks_Init()
    if not db.addonPetTracker and PetTracker then
        PetTracker.Objectives.OnLoad = function() end
    end
end

local function SetHooks()
    hooksecurefunc("ObjectiveTracker_Initialize", function(self)
        tinsert(self.MODULES, PETTRACKER_TRACKER_MODULE)
        tinsert(self.MODULES_UI_ORDER, PETTRACKER_TRACKER_MODULE)
    end)

    function PetTracker.Objectives:OnLoad()  -- R
        self:RegisterEvent("QUEST_LOG_UPDATE")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Layout")
        self:RegisterEvent("ZONE_CHANGED_INDOORS")
        self:RegisterEvent("ZONE_CHANGED")
        self:RegisterSignal("COLLECTION_CHANGED", "Layout")
        self:RegisterSignal("OPTIONS_CHANGED", "Layout")

        self.MaxEntries = 200
    end

    function PetTracker.Objectives:QUEST_LOG_UPDATE()  -- N
        if PetTracker.sets.zoneTracker then
            C_Timer.After(0, function()
                KT.forceExpand = not KT.inInstance and not KT.initCollapsed and KT:IsTrackerEmpty()
            end)
        end
        self:UnregisterEvent("QUEST_LOG_UPDATE")
    end

    function PetTracker.Objectives:ZONE_CHANGED_INDOORS()  -- N
        self:UnregisterEvent("ZONE_CHANGED")
        self:RegisterEvent("ZONE_CHANGED")
    end

    function PetTracker.Objectives:ZONE_CHANGED()  -- N
        self:Layout()
        self:UnregisterEvent("ZONE_CHANGED")
    end

    function PetTracker.Objectives:Layout()  -- R
        local hasContent = false
        if PetTracker.sets.zoneTracker then
            self:Hide()
            self:Update()
            hasContent = not self.Bar:IsMaximized()
        end
        PETTRACKER_TRACKER_MODULE.PThasContent = hasContent
        ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_PETTRACKER)
    end

    local bck_PetTracker_SpecieLine_New = PetTracker.SpecieLine.New
    function PetTracker.SpecieLine:New(parent, text, icon, subicon, r, g, b)
        local line = bck_PetTracker_SpecieLine_New(self, parent, text, icon, subicon, r, g, b)
        if line.KTskinID ~= KT.skinID then
            line:SetWidth(contentWidth)
            line.SubIcon:ClearAllPoints()
            line.SubIcon:SetPoint("TOPLEFT", 0, -1)
            line.Icon:ClearAllPoints()
            line.Icon:SetPoint("LEFT", line.SubIcon, "RIGHT", 5, 0)
            line.Text:ClearAllPoints()
			line.Text:SetPoint("LEFT", line.Icon, "RIGHT", 5, 0)
			line.Text:SetPoint("RIGHT")
            line.Text:SetFont(KT.font, db.fontSize, db.fontFlag)
            line.Text:SetShadowColor(0, 0, 0, db.fontShadow)
            line.Text:SetWordWrap(false)
            line.KTskinID = KT.skinID
        end
        return line
    end

    local bck_PetTracker_Pet_Display = PetTracker.Pet.Display
    function PetTracker.Pet:Display()
        if not KT.InCombatBlocked() then
            bck_PetTracker_Pet_Display(self)
        end
    end

    hooksecurefunc(PetTracker.ProgressBar, "SetProgress", function(self, progress)
        if self.KTskinID ~= KT.skinID then
            for _, bar in ipairs(self.Bars) do
                bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
            end
            self.KTskinID = KT.skinID
        end
    end)
end

local function SetHooks_PetTracker_Journal()
    if not db.addonPetTracker and PetTracker then
        PetTrackerTrackToggle:Disable()
        PetTrackerTrackToggle.Text:SetTextColor(0.5, 0.5, 0.5)
        local infoFrame = CreateFrame("Frame", nil, PetJournal)
        infoFrame:SetSize(PetTrackerTrackToggle:GetWidth() + PetTrackerTrackToggle.Text:GetWidth(), PetTrackerTrackToggle:GetHeight())
        infoFrame:SetPoint("TOPLEFT", PetTrackerTrackToggle, 0, 0)
        infoFrame:SetFrameLevel(PetTrackerTrackToggle:GetFrameLevel() + 1)
        infoFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:AddLine(M.Texts.TrackPets, 1, 1, 1)
            GameTooltip:AddLine("Support can be enabled inside addon "..KT.TITLE, 1, 0, 0, true)
            GameTooltip:Show()
        end)
        infoFrame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    else
        PetTrackerTrackToggle:HookScript("OnClick", function()
            if dbChar.collapsed and PetTracker.sets.zoneTracker then
                KT:MinimizeButton_OnClick()
            end
        end)
    end
end

local function Event_PLAYER_ENTERING_WORLD(eventID)
    KT:RegEvent("PET_JOURNAL_LIST_UPDATE", function()
        M:SetPetsHeaderText()
    end)
    KT:UnregEvent(eventID)
end

local function SetEvents_Init()
    if not C_AddOns.IsAddOnLoaded("PetTracker_Journal") then
        KT:RegEvent("ADDON_LOADED", function(eventID, addon)
            if addon == "PetTracker_Journal" then
                C_Timer.After(0, function()
                    SetHooks_PetTracker_Journal()
                end)
                KT:UnregEvent(eventID)
            end
        end)
    end
end

local function SetFrames()
    -- Header frame
    header = CreateFrame("Frame", nil, OTF.BlocksFrame, "ObjectiveTrackerHeaderTemplate")
    header:Hide()

    -- Content frame
    content = CreateFrame("Frame", nil, OTF.BlocksFrame)
    content:SetSize(232 - PETTRACKER_TRACKER_MODULE.blockOffsetX, 10)
    content:Hide()

    -- Objectives
    local objectives = PetTracker.Objectives
    objectives:SetParent(content)
    objectives:Hide()
    objectives.Header = header

    -- Progress bar
    objectives.Bar:SetSize(contentWidth - 4, 13)
    objectives.Bar:SetPoint("TOPLEFT", content, -8, -4)
    objectives.Bar.xOff = -2
    objectives.Bar:EnableMouse(false)

    objectives.Bar.Overlay.BorderLeft:Hide()
    objectives.Bar.Overlay.BorderRight:Hide()
    objectives.Bar.Overlay.BorderCenter:Hide()

    local border1 = objectives.Bar:CreateTexture(nil, "BACKGROUND", nil, -2)
    border1:SetPoint("TOPLEFT", -1, 1)
    border1:SetPoint("BOTTOMRIGHT", 1, -1)
    border1:SetColorTexture(0, 0, 0)

    local border2 = objectives.Bar:CreateTexture(nil, "BACKGROUND", nil, -3)
    border2:SetPoint("TOPLEFT", -2, 2)
    border2:SetPoint("BOTTOMRIGHT", 2, -2)
    border2:SetColorTexture(0.4, 0.4, 0.4)

    objectives.Bar.Overlay.Text:SetPoint("CENTER", 0, 0.5)
    objectives.Bar.Overlay.Text:SetFont(LSM:Fetch("font", "Arial Narrow"), 13, "")
end

--------------
-- External --
--------------

function PETTRACKER_TRACKER_MODULE:GetBlock()
    local block = content
    block.module = self
    block.used = true
    block.height = 0
    block.lineWidth = OBJECTIVE_TRACKER_TEXT_WIDTH - self.blockOffsetX
    block.currentLine = nil
    if block.lines then
        for _, line in ipairs(block.lines) do
            line.used = nil
        end
    else
        block.lines = {}
    end
    return block
end

function PETTRACKER_TRACKER_MODULE:MarkBlocksUnused()
    content.used = nil
end

function PETTRACKER_TRACKER_MODULE:FreeUnusedBlocks()
    if not content.used then
        content:Hide()
    end
end

function PETTRACKER_TRACKER_MODULE:Update()
    self:BeginLayout()
    if self.PThasContent then
        local block = self:GetBlock()
        block.height = PetTracker.Objectives:GetHeight() - 41
        block:SetHeight(block.height)
        local blockAdded = ObjectiveTracker_AddBlock(block)
        if blockAdded then
            block:Show()
            self:FreeUnusedLines(block)
        else
            block.used = nil
        end
        PetTracker.Objectives:SetShown(blockAdded)
    end
    self:EndLayout()
end

function M:Update(forced)
    self:SetForced(forced)
    PetTracker.Objectives:Update()
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isLoaded = (KT:CheckAddOn("PetTracker", "11.2") and db.addonPetTracker)

    if self.isLoaded then
        KT:Alert_IncompatibleAddon("PetTracker", "11.2")

        tinsert(KT.db.defaults.profile.modulesOrder, "PETTRACKER_TRACKER_MODULE")
        KT.db:RegisterDefaults(KT.db.defaults)
    end

    SetEvents_Init()
    SetHooks_Init()
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetFrames()
    SetHooks()

    PETTRACKER_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_PETTRACKER
    PETTRACKER_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_PETTRACKER
    PETTRACKER_TRACKER_MODULE.PThasContent = false
    PETTRACKER_TRACKER_MODULE:SetHeader(header, PETS)

    KT:RegSignal("OPTIONS_CHANGED", "Update", self)
    KT:RegEvent("PLAYER_ENTERING_WORLD", Event_PLAYER_ENTERING_WORLD)
end

function M:IsShown()
    return (self.isLoaded and
            (PetTracker.sets and PetTracker.sets.zoneTracker) and
            PetTracker.Objectives:IsShown())
end

function M:SetPetsHeaderText(reset)
    if self.isLoaded and db.pettrackerHeaderTitleAppend then
        local _, numPetsOwned = C_PetJournal.GetNumPets()
        KT:SetHeaderText(PETTRACKER_TRACKER_MODULE, numPetsOwned)
    elseif reset then
        KT:SetHeaderText(PETTRACKER_TRACKER_MODULE)
    end
end