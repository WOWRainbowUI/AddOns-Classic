-- WorldBuff.lua
-- World Buff tracking and management for Classic Calendar

local AddonName, AddonTable = ...

-- Get Ace3 libraries
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

-- World Buff data and functions (global for DataSync access)
WorldBuffs = {}

-- Saved variables for world buff data - separate table for each buff type
WorldBuffRendData = WorldBuffRendData or {}
WorldBuffHakkarData = WorldBuffHakkarData or {}
WorldBuffOnyxiaData = WorldBuffOnyxiaData or {}
WorldBuffNefarianData = WorldBuffNefarianData or {}

-- Item types for world buffs
local WORLD_BUFF_ITEMS = {
    ["REND_HEAD"] = { name = "Rend's Head", texture = "Interface\\Icons\\INV_Misc_Head_Orc_02" },
    ["HAKKAR_HEART"] = { name = "Heart of Hakkar", texture = "Interface\\Icons\\INV_Misc_Organ_03" },
    ["ONYXIA_HEAD"] = { name = "Onyxia's Head", texture = "Interface\\Icons\\INV_Misc_Head_Dragon_01" },
    ["NEFARIAN_HEAD"] = { name = "Nefarian's Head", texture = "Interface\\Icons\\INV_Misc_Head_Dragon_Black" }
}

-- Helper function to get the appropriate data table for each buff type
function WorldBuffs:GetWorldBuffDataTable(itemType)
    if itemType == "REND_HEAD" then
        return WorldBuffRendData
    elseif itemType == "HAKKAR_HEART" then
        return WorldBuffHakkarData
    elseif itemType == "ONYXIA_HEAD" then
        return WorldBuffOnyxiaData
    elseif itemType == "NEFARIAN_HEAD" then
        return WorldBuffNefarianData
    else
        error("Unknown world buff itemType: " .. tostring(itemType))
    end
end

-- Check if player has officer privileges
local function IsOfficer()
    local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
    if not guildName then
        return false
    end

    if guildRankIndex and guildRankIndex <= 2 then
        return true
    end
    
    return false
end

-- Get guild member list with autocomplete functionality
local function GetGuildMembers()
    local members = {}
    local numMembers = GetNumGuildMembers()
    
    for i = 1, numMembers do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i)
        if name then
            table.insert(members, {
                name = name,
                rank = rank,
                rankIndex = rankIndex,
                level = level,
                class = class,
                online = online
            })
        end
    end
    
    return members
end

-- Update player name autocomplete suggestions
function WorldBuffs:UpdatePlayerAutocomplete(inputText, targetInput)
    if not self.addDialog or not self.addDialog.autocompleteFrame then return end
    
    -- Store which input field we're autocompleting for
    self.addDialog.autocompleteTarget = targetInput or self.addDialog.playerInput
    
    -- Position autocomplete frame relative to the active input field
    self.addDialog.autocompleteFrame:ClearAllPoints()
    self.addDialog.autocompleteFrame:SetPoint("TOPLEFT", self.addDialog.autocompleteTarget, "BOTTOMLEFT", 0, 0)
    
    -- Hide if no input text
    if not inputText or inputText == "" then
        self.addDialog.autocompleteFrame:Hide()
        return
    end
    
    -- Get guild members and filter by input text
    local guildMembers = GetGuildMembers()
    local filteredMembers = {}
    local inputLower = string.lower(inputText)
    
    for _, member in ipairs(guildMembers) do
        -- Strip realm name from member name for both filtering and display
        local cleanName = string.match(member.name, "([^-]+)") or member.name
        if string.find(string.lower(cleanName), inputLower, 1, true) then
            -- Store both the original member data and the clean name
            local filteredMember = {
                name = member.name,
                cleanName = cleanName,
                online = member.online,
                level = member.level,
                class = member.class
            }
            table.insert(filteredMembers, filteredMember)
        end
    end
    
    -- Limit to 10 suggestions
    if #filteredMembers > 10 then
        for i = #filteredMembers, 11, -1 do
            filteredMembers[i] = nil
        end
    end
    
    -- Clear existing buttons
    for _, button in ipairs(self.addDialog.memberButtons) do
        button:Hide()
    end
    
    -- Show suggestions if any matches found
    if #filteredMembers > 0 then
        self:CreateAutocompleteButtons(filteredMembers)
        self.addDialog.autocompleteFrame:Show()
    else
        self.addDialog.autocompleteFrame:Hide()
    end
end

-- Create autocomplete suggestion buttons
function WorldBuffs:CreateAutocompleteButtons(members)
    local yOffset = 0
    local buttonHeight = 20
    
    for i, member in ipairs(members) do
        local button = self.addDialog.memberButtons[i]
        
        if not button then
            button = CreateFrame("Button", nil, self.addDialog.autocompleteContent)
            button:SetSize(170, buttonHeight)
            button:SetNormalFontObject("GameFontNormalSmall")
            button:SetHighlightFontObject("GameFontHighlightSmall")
            
            -- Create highlight texture
            local highlight = button:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(0.3, 0.3, 1, 0.3)
            
            self.addDialog.memberButtons[i] = button
        end
        
        -- Set button properties
        button:SetPoint("TOPLEFT", self.addDialog.autocompleteContent, "TOPLEFT", 0, -yOffset)
        
        -- Format display text with online status and class color using clean name
        local displayName = member.cleanName or member.name
        if member.online then
            -- Use normal white text for better readability instead of class colors
            button:SetText("|cffffffff" .. displayName .. "|r") -- White for online
        else
            -- Use light gray instead of dark gray for better readability
            button:SetText("|cffcccccc" .. displayName .. "|r") -- Light gray for offline
        end
        
        -- Set click handler to use clean name
        button:SetScript("OnClick", function()
            local targetInput = self.addDialog.autocompleteTarget or self.addDialog.playerInput
            targetInput:SetText(displayName)
            self.addDialog.autocompleteFrame:Hide()
            targetInput:ClearFocus()
        end)
        
        button:Show()
        yOffset = yOffset + buttonHeight
    end
    
    -- Update scroll content height
    self.addDialog.autocompleteContent:SetHeight(math.max(yOffset, 1))
    
    -- Adjust autocomplete frame height
    local frameHeight = math.min(yOffset + 10, 100)
    self.addDialog.autocompleteFrame:SetHeight(frameHeight)
end

-- Main WorldBuff management frame (global for DataSync access)
WorldBuffFrame = nil

-- Helper function to close all WorldBuff popups
function WorldBuffs:CloseAllPopups()
    if self.addDialog and self.addDialog:IsShown() then
        self.addDialog:Hide()
    end
    if self.datePickerPopup and self.datePickerPopup:IsShown() then
        self.datePickerPopup:Hide()
    end
end

-- Helper function to hide frame backgrounds
function WorldBuffs:HideFrameBackground(frame)
    -- Hide NineSlice background elements
    if frame.NineSlice then
        frame.NineSlice:SetAlpha(0)
    end
    if frame.Inset and frame.Inset.NineSlice then
        frame.Inset.NineSlice:SetAlpha(0)
    end
    -- Hide common background element names
    if frame.Bg then
        frame.Bg:SetAlpha(0)
    end
    if frame.Inset and frame.Inset.Bg then
        frame.Inset.Bg:SetAlpha(0)
    end
    -- Hide all background textures by searching regions
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region and region:GetObjectType() == "Texture" then
            local name = region:GetName()
            if name and (string.find(name:lower(), "bg") or string.find(name:lower(), "background")) then
                region:SetAlpha(0)
            end
        end
    end
    -- Also check inset regions
    if frame.Inset then
        for i = 1, frame.Inset:GetNumRegions() do
            local region = select(i, frame.Inset:GetRegions())
            if region and region:GetObjectType() == "Texture" then
                local name = region:GetName()
                if name and (string.find(name:lower(), "bg") or string.find(name:lower(), "background")) then
                    region:SetAlpha(0)
                end
            end
        end
    end
end

-- Helper function to style buttons with ClassicCalendar appearance
function WorldBuffs:StyleCalendarButton(button, width)
    if not button then return end
    
    -- Remove any existing background textures 
    button:SetNormalTexture("")
    button:SetPushedTexture("")
    button:SetDisabledTexture("")
    
    -- Hide all existing textures from GameMenuButtonTemplate
    for i = 1, button:GetNumRegions() do
        local region = select(i, button:GetRegions())
        if region and region:GetObjectType() == "Texture" then
            -- Hide all existing textures except the font string
            if region ~= button:GetFontString() then
                region:SetAlpha(0)
            end
        end
    end
    
    -- Set size (keep existing height, use provided width or existing width)
    local _, currentHeight = button:GetSize()
    button:SetSize(width or button:GetWidth(), currentHeight)
    
    -- Create left border texture
    local leftTex = button:CreateTexture(nil, "BACKGROUND")
    leftTex:SetTexture("Interface\\Common\\Common-Input-Border")
    leftTex:SetSize(8, 16)
    leftTex:SetPoint("LEFT", button, "LEFT", -5, 0)
    leftTex:SetTexCoord(0, 0.0625, 0, 0.625)
    
    -- Create right border texture
    local rightTex = button:CreateTexture(nil, "BACKGROUND")
    rightTex:SetTexture("Interface\\Common\\Common-Input-Border")
    rightTex:SetSize(8, 16)
    rightTex:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    rightTex:SetTexCoord(0.9375, 1.0, 0, 0.625)
    
    -- Create middle texture
    local middleTex = button:CreateTexture(nil, "BACKGROUND")
    middleTex:SetTexture("Interface\\Common\\Common-Input-Border")
    middleTex:SetSize(10, 16)
    middleTex:SetPoint("LEFT", leftTex, "RIGHT")
    middleTex:SetPoint("RIGHT", rightTex, "LEFT")
    middleTex:SetTexCoord(0.0625, 0.9375, 0, 0.625)
    
    -- Update font to match calendar style
    if button:GetFontString() then
        button:GetFontString():SetFontObject(GameFontHighlightSmall)
    end
    
    -- Add hover highlight
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    highlight:SetAllPoints(button)
    highlight:SetBlendMode("ADD")
end

-- Save WorldBuff frame position
function WorldBuffs:SaveFramePosition()
    if not WorldBuffFrame or not CCConfig then return end
    
    local point, relativeTo, relativePoint, xOfs, yOfs = WorldBuffFrame:GetPoint()
    CCConfig.WorldBuffFramePos = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
end

-- Restore WorldBuff frame position
function WorldBuffs:RestoreFramePosition()
    if not WorldBuffFrame or not CCConfig or not CCConfig.WorldBuffFramePos then
        WorldBuffFrame:SetPoint("CENTER")
        return
    end
    
    local pos = CCConfig.WorldBuffFramePos
    if pos.point and pos.relativePoint and pos.xOfs and pos.yOfs then
        WorldBuffFrame:ClearAllPoints()
        WorldBuffFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    else
        WorldBuffFrame:SetPoint("CENTER")
    end
end

-- Create the main WorldBuff window
function WorldBuffs:CreateMainFrame()
    if WorldBuffFrame then
        return WorldBuffFrame
    end
    
    -- Create main frame
    WorldBuffFrame = CreateFrame("Frame", "ClassicCalendarWorldBuffFrame", UIParent, "BasicFrameTemplateWithInset")
    WorldBuffFrame:SetSize(600, 450)
    WorldBuffFrame:SetMovable(true)
    WorldBuffFrame:EnableMouse(true)
    WorldBuffFrame:RegisterForDrag("LeftButton")
    WorldBuffFrame:SetScript("OnDragStart", WorldBuffFrame.StartMoving)
    WorldBuffFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        WorldBuffs:SaveFramePosition()
    end)
    WorldBuffFrame:Hide()
    
    -- Restore saved position or default to center
    WorldBuffs:RestoreFramePosition()
    
    -- Make background transparent
    self:HideFrameBackground(WorldBuffFrame)
    
    -- Set title
    WorldBuffFrame.title = WorldBuffFrame:CreateFontString(nil, "OVERLAY")
    WorldBuffFrame.title:SetFontObject("GameFontHighlight")
    WorldBuffFrame.title:SetPoint("TOP", WorldBuffFrame, "TOP", 0, -8)
    WorldBuffFrame.title:SetText("World Buff Management")
    
    -- Create tab system
    WorldBuffFrame.tabs = {}
    WorldBuffFrame.numTabs = 4
    WorldBuffFrame.selectedTab = 1
    local tabNames = {"REND_HEAD", "HAKKAR_HEART", "ONYXIA_HEAD", "NEFARIAN_HEAD"}
    
    for i, itemType in ipairs(tabNames) do
        local tab = CreateFrame("Button", "WorldBuffTab"..i, WorldBuffFrame, "CharacterFrameTabButtonTemplate")
        tab:SetPoint("TOPLEFT", WorldBuffFrame, "BOTTOMLEFT", (i-1) * 120 + 10, 0)
        tab:SetText(WORLD_BUFF_ITEMS[itemType].name)
        tab.itemType = itemType
        tab:SetID(i)
        tab:SetScript("OnClick", function(self)
            WorldBuffs:ShowTab(self.itemType)
        end)
        WorldBuffFrame.tabs[i] = tab
        
        -- Initialize tab state
        PanelTemplates_TabResize(tab, 0)
        if i == 1 then
            PanelTemplates_SelectTab(tab)
        else
            PanelTemplates_DeselectTab(tab)
        end
    end
    
    -- Add New Entry button (positioned at top-right inside the inset area)
    WorldBuffFrame.addButton = CreateFrame("Button", nil, WorldBuffFrame, "GameMenuButtonTemplate")
    WorldBuffFrame.addButton:SetPoint("TOPRIGHT", WorldBuffFrame, "TOPRIGHT", -25, -35)
    WorldBuffFrame.addButton:SetSize(100, 22)
    WorldBuffFrame.addButton:SetText("Add Entry")
    WorldBuffFrame.addButton:SetScript("OnClick", function()
        -- Clear edit mode when adding new entry
        WorldBuffs.editMode = false
        WorldBuffs.editIndex = nil
        WorldBuffs.editOriginalData = nil
        WorldBuffs:ShowAddEntryDialog()
    end)
    
    -- Apply ClassicCalendar styling
    WorldBuffs:StyleCalendarButton(WorldBuffFrame.addButton, 100)
    
    -- Create scrollable table for current tab (positioned below the button, within inset bounds)
    WorldBuffFrame.scrollFrame = CreateFrame("ScrollFrame", "ClassicCalendarWorldBuffScrollFrame", WorldBuffFrame, "UIPanelScrollFrameTemplate")
    WorldBuffFrame.scrollFrame:SetPoint("TOPLEFT", WorldBuffFrame, "TOPLEFT", 15, -65)
    WorldBuffFrame.scrollFrame:SetPoint("BOTTOMRIGHT", WorldBuffFrame, "BOTTOMRIGHT", -35, 55) -- Leave space for placeholder button
    
    WorldBuffFrame.scrollChild = CreateFrame("Frame", nil, WorldBuffFrame.scrollFrame)
    WorldBuffFrame.scrollChild:SetSize(1, 1)
    WorldBuffFrame.scrollFrame:SetScrollChild(WorldBuffFrame.scrollChild)
    
    -- Create Placeholder button (positioned below the scroll frame)
    WorldBuffFrame.placeholderButton = CreateFrame("Button", nil, WorldBuffFrame, "UIPanelButtonTemplate")
    WorldBuffFrame.placeholderButton:SetPoint("BOTTOMRIGHT", WorldBuffFrame, "BOTTOMRIGHT", -25, 20)
    WorldBuffFrame.placeholderButton:SetSize(130, 22)
    WorldBuffFrame.placeholderButton:SetText("Create Placeholder")
    WorldBuffFrame.placeholderButton:SetScript("OnClick", function()
        WorldBuffs:ShowPlaceholderDialog()
    end)
    WorldBuffFrame.scrollChild:SetSize(1, 1)
    WorldBuffFrame.scrollFrame:SetScrollChild(WorldBuffFrame.scrollChild)
    
    -- Close button functionality
    WorldBuffFrame:SetScript("OnHide", function()
        -- Close all open popup windows when main window closes
        WorldBuffs:CloseAllPopups()
    end)
    
    return WorldBuffFrame
end

-- Show specific tab content
function WorldBuffs:ShowTab(itemType)
    if not WorldBuffFrame then return end
    
    -- Update tab appearances using PanelTemplates for proper tab behavior
    for i, tab in ipairs(WorldBuffFrame.tabs) do
        if tab.itemType == itemType then
            PanelTemplates_SelectTab(tab)
            WorldBuffFrame.selectedTab = i
        else
            PanelTemplates_DeselectTab(tab)
        end
    end
    
    -- Clear current content
    for i = 1, WorldBuffFrame.scrollChild:GetNumChildren() do
        local child = select(i, WorldBuffFrame.scrollChild:GetChildren())
        child:Hide()
    end
    
    -- Display entries for this item type
    self:DisplayEntriesForItem(itemType)
end

-- Display entries for a specific item type
function WorldBuffs:DisplayEntriesForItem(itemType)
    local dataTable = self:GetWorldBuffDataTable(itemType)
    
    local yOffset = -5
    local rowHeight = 20 -- Reduced from 25 to 20 for less padding
    
    -- Ensure frame exists
    if not WorldBuffFrame or not WorldBuffFrame.scrollChild then
        return
    end
    
    -- Create header
    local header = self:CreateTableRow(WorldBuffFrame.scrollChild, 0, yOffset, true)
    header.playerName:SetText("Player Name")
    header.mainName:SetText("Main Name")
    header.receivedDate:SetText("Date Received")
    header.dropped:SetText("Dropped")
    
    yOffset = yOffset - rowHeight
    
    -- Create sorted list of non-deleted entries (oldest first by date received)
    local sortedEntries = {}
    for i, entry in ipairs(dataTable) do
        if not entry.deleted then
            table.insert(sortedEntries, {index = i, entry = entry})
        end
    end
    
    -- Sort by date received (oldest first)
    table.sort(sortedEntries, function(a, b)
        -- Parse dates for comparison (MM/DD/YYYY format)
        local function parseDate(dateStr)
            if not dateStr then return 0 end
            local month, day, year = dateStr:match("(%d+)/(%d+)/(%d+)")
            if month and day and year then
                -- Convert to comparable number: YYYYMMDD
                return tonumber(year) * 10000 + tonumber(month) * 100 + tonumber(day)
            end
            return 0
        end
        
        local dateA = parseDate(a.entry.receivedDate or a.entry.playerNameedDate or a.entry.droppededDate or "01/01/1970")
        local dateB = parseDate(b.entry.receivedDate or b.entry.playerNameedDate or b.entry.droppededDate or "01/01/1970")
        return dateA < dateB -- Oldest first
    end)
    
    -- Create rows for sorted entries
    for _, sortedEntry in ipairs(sortedEntries) do
        local row = self:CreateTableRow(WorldBuffFrame.scrollChild, sortedEntry.index, yOffset, false, sortedEntry.entry)
        yOffset = yOffset - rowHeight
    end
    
    -- Update scroll child size
    WorldBuffFrame.scrollChild:SetHeight(math.abs(yOffset))
end

-- Create a table row for display
function WorldBuffs:CreateTableRow(parent, index, yOffset, isHeader, data)
    local rowFrame = CreateFrame("Frame", nil, parent)
    rowFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    rowFrame:SetSize(500, 20) -- Reduced from 25 to 20
    
    -- Player name column
    if isHeader then
        rowFrame.playerName = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    else
        rowFrame.playerName = CreateFrame("Button", nil, rowFrame)
        rowFrame.playerName:SetSize(150, 20)
        rowFrame.playerName:SetNormalFontObject("GameFontNormalSmall")
        local displayName = (data and data.playerName and data.playerName ~= "") and data.playerName or "[Unknown Player]"
        rowFrame.playerName:SetText(displayName)
        
        -- Try to control text positioning within the button
        local fontString = rowFrame.playerName:GetFontString()
        if fontString then
            fontString:SetJustifyH("LEFT")
            -- Position the fontstring within the button frame
            fontString:ClearAllPoints()
            fontString:SetPoint("LEFT", rowFrame.playerName, "LEFT", 0, 0)
            fontString:SetPoint("RIGHT", rowFrame.playerName, "RIGHT", 0, 0)
        end
        
        -- Left click to edit
        rowFrame.playerName:SetScript("OnClick", function(clickedFrame, button)
            if button == "LeftButton" then
                WorldBuffs:EditEntry(index, data)
            elseif button == "RightButton" then
                WorldBuffs:CreateGuildEvent(data)
            end
        end)
        rowFrame.playerName:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    
    -- Use same positioning for both header and button
    rowFrame.playerName:SetPoint("LEFT", rowFrame, "LEFT", 10, 0)
    
    -- Main Name column
    if isHeader then
        rowFrame.mainName = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    else
        rowFrame.mainName = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowFrame.mainName:SetText(data and data.mainName or "")
    end
    rowFrame.mainName:SetPoint("LEFT", rowFrame, "LEFT", 170, 0)
    
    -- Date received column  
    if isHeader then
        rowFrame.receivedDate = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    else
        rowFrame.receivedDate = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        local displayDate = (data and (data.receivedDate or data.playerNameedDate or data.droppededDate)) or ""
        rowFrame.receivedDate:SetText(displayDate)
    end
    rowFrame.receivedDate:SetPoint("LEFT", rowFrame, "LEFT", 330, 0)
    
    -- Dropped column
    if isHeader then
        rowFrame.dropped = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    else
        rowFrame.dropped = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowFrame.dropped:SetText(data and data.dropped or "No")
        -- Color coding: Green for No, Red for Yes
        if data and data.dropped == "Yes" then
            rowFrame.dropped:SetTextColor(1, 0.2, 0.2) -- Red
        else
            rowFrame.dropped:SetTextColor(0.2, 1, 0.2) -- Green
        end
    end
    rowFrame.dropped:SetPoint("LEFT", rowFrame, "LEFT", 490, 0)
    
    return rowFrame
end

-- Show add entry dialog
function WorldBuffs:ShowAddEntryDialog()
    -- Create or show existing dialog
    if not self.addDialog then
        self.addDialog = CreateFrame("Frame", "ClassicCalendarWorldBuffAddDialog", UIParent, "BasicFrameTemplateWithInset")
        self.addDialog:SetSize(300, 280)
        self.addDialog:SetFrameStrata("HIGH")
        self.addDialog:SetToplevel(true)
        -- Position snapped to the right of the WorldBuff window (like ClassicCalendar guild event popup)
        if WorldBuffFrame then
            self.addDialog:SetPoint("TOPLEFT", WorldBuffFrame, "TOPRIGHT", 0, -24)
        else
            self.addDialog:SetPoint("CENTER")
        end
        self.addDialog:SetMovable(true)
        self.addDialog:EnableMouse(true)
        self.addDialog:RegisterForDrag("LeftButton")
        self.addDialog:SetScript("OnDragStart", self.addDialog.StartMoving)
        self.addDialog:SetScript("OnDragStop", self.addDialog.StopMovingOrSizing)
        
        -- Close cascade behavior - when addDialog closes, close datePickerPopup if open
        self.addDialog:SetScript("OnHide", function()
            if WorldBuffs.datePickerPopup and WorldBuffs.datePickerPopup:IsShown() then
                WorldBuffs.datePickerPopup:Hide()
            end
        end)
        
        -- Make background transparent
        WorldBuffs:HideFrameBackground(self.addDialog)
        
        -- Set title using the template's TitleText element
        self.addDialog.TitleText:SetText("Add World Buff Entry")
        
        -- Player name input with autocomplete
        self.addDialog.playerLabel = self.addDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.addDialog.playerLabel:SetPoint("TOPLEFT", self.addDialog, "TOPLEFT", 20, -35)
        self.addDialog.playerLabel:SetText("Player Name:")
        
        self.addDialog.playerInput = CreateFrame("EditBox", nil, self.addDialog, "InputBoxTemplate")
        self.addDialog.playerInput:SetPoint("TOPLEFT", self.addDialog.playerLabel, "BOTTOMLEFT", 0, -5)
        self.addDialog.playerInput:SetSize(200, 20)
        self.addDialog.playerInput:SetAutoFocus(false)
        
        -- Guild member autocomplete dropdown - made wider for better readability
        self.addDialog.autocompleteFrame = CreateFrame("Frame", nil, self.addDialog, "BackdropTemplate")
        self.addDialog.autocompleteFrame:SetPoint("TOPLEFT", self.addDialog.playerInput, "BOTTOMLEFT", 0, 0)
        self.addDialog.autocompleteFrame:SetSize(250, 120) -- Wider and taller for better readability
        self.addDialog.autocompleteFrame:SetFrameStrata("DIALOG")
        
        local backdropInfo = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, 
            tileSize = 8, 
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        }
        self.addDialog.autocompleteFrame:SetBackdrop(backdropInfo)
        self.addDialog.autocompleteFrame:SetBackdropColor(0, 0, 0, 0)  -- Transparent background
        self.addDialog.autocompleteFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.3)  -- Semi-transparent border
        self.addDialog.autocompleteFrame:Hide()
        
        -- Autocomplete scroll frame
        self.addDialog.autocompleteScroll = CreateFrame("ScrollFrame", nil, self.addDialog.autocompleteFrame, "UIPanelScrollFrameTemplate")
        self.addDialog.autocompleteScroll:SetPoint("TOPLEFT", 5, -5)
        self.addDialog.autocompleteScroll:SetPoint("BOTTOMRIGHT", -25, 5)
        
        self.addDialog.autocompleteContent = CreateFrame("Frame", nil, self.addDialog.autocompleteScroll)
        self.addDialog.autocompleteContent:SetSize(220, 1) -- Wider to match the larger frame
        self.addDialog.autocompleteScroll:SetScrollChild(self.addDialog.autocompleteContent)
        
        -- Store guild member buttons for reuse
        self.addDialog.memberButtons = {}
        
        -- Set up autocomplete functionality
        self.addDialog.playerInput:SetScript("OnTextChanged", function(editbox)
            WorldBuffs:UpdatePlayerAutocomplete(editbox:GetText(), editbox)
        end)
        
        self.addDialog.playerInput:SetScript("OnEditFocusLost", function()
            -- Hide autocomplete after a short delay to allow clicking on suggestions
            C_Timer.After(0.2, function()
                if WorldBuffs.addDialog and WorldBuffs.addDialog.autocompleteFrame then
                    WorldBuffs.addDialog.autocompleteFrame:Hide()
                end
            end)
        end)
        
        -- Main name input
        self.addDialog.mainNameLabel = self.addDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.addDialog.mainNameLabel:SetPoint("TOPLEFT", self.addDialog.playerInput, "BOTTOMLEFT", 0, -15)
        self.addDialog.mainNameLabel:SetText("Main Name:")
        
        self.addDialog.mainNameInput = CreateFrame("EditBox", nil, self.addDialog, "InputBoxTemplate")
        self.addDialog.mainNameInput:SetPoint("TOPLEFT", self.addDialog.mainNameLabel, "BOTTOMLEFT", 0, -5)
        self.addDialog.mainNameInput:SetSize(200, 20)
        self.addDialog.mainNameInput:SetAutoFocus(false)
        
        -- Set up autocomplete functionality for Main Name
        self.addDialog.mainNameInput:SetScript("OnTextChanged", function(editbox)
            WorldBuffs:UpdatePlayerAutocomplete(editbox:GetText(), editbox)
        end)
        
        self.addDialog.mainNameInput:SetScript("OnEditFocusLost", function()
            -- Hide autocomplete after a short delay to allow clicking on suggestions
            C_Timer.After(0.2, function()
                if WorldBuffs.addDialog and WorldBuffs.addDialog.autocompleteFrame then
                    WorldBuffs.addDialog.autocompleteFrame:Hide()
                end
            end)
        end)
        
        -- Date input
        self.addDialog.dateLabel = self.addDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.addDialog.dateLabel:SetPoint("TOPLEFT", self.addDialog.mainNameInput, "BOTTOMLEFT", 0, -15)
        self.addDialog.dateLabel:SetText("Date Received:")
        
        -- Date picker button (instead of EditBox)
        self.addDialog.dateButton = CreateFrame("Button", nil, self.addDialog, "GameMenuButtonTemplate")
        self.addDialog.dateButton:SetPoint("TOPLEFT", self.addDialog.dateLabel, "BOTTOMLEFT", 0, -5)
        self.addDialog.dateButton:SetSize(150, 25)
        self.addDialog.dateButton:SetText(tostring(date("%m/%d/%Y"))) -- Default to today
        
        -- Apply ClassicCalendar styling
        self:StyleCalendarButton(self.addDialog.dateButton, 150)
        
        -- Store selected date
        self.addDialog.selectedDate = {
            month = tonumber(date("%m")),
            day = tonumber(date("%d")),
            year = tonumber(date("%Y"))
        }
        
        -- Calendar popup frame
        self.addDialog.calendarFrame = CreateFrame("Frame", nil, self.addDialog, "BackdropTemplate")
        self.addDialog.calendarFrame:SetSize(200, 180)
        self.addDialog.calendarFrame:SetPoint("TOPLEFT", self.addDialog.dateButton, "BOTTOMLEFT", 0, -5)
        self.addDialog.calendarFrame:SetFrameStrata("DIALOG")
        local calendarBackdrop = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, 
            tileSize = 8, 
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        }
        self.addDialog.calendarFrame:SetBackdrop(calendarBackdrop)
        self.addDialog.calendarFrame:SetBackdropColor(0, 0, 0, 0)  -- Transparent background
        self.addDialog.calendarFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.3)  -- Semi-transparent border
        self.addDialog.calendarFrame:Hide()
        
        -- Create calendar controls
        WorldBuffs:CreateCalendarControls()
        
        -- Date button click handler
        self.addDialog.dateButton:SetScript("OnClick", function()
            if self.addDialog.calendarFrame:IsShown() then
                self.addDialog.calendarFrame:Hide()
            else
                WorldBuffs:UpdateCalendar()
                self.addDialog.calendarFrame:Show()
            end
        end)
        
        -- Dropped status dropdown (for editing entries)
        self.addDialog.droppedLabel = self.addDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.addDialog.droppedLabel:SetPoint("TOPLEFT", self.addDialog.dateButton, "BOTTOMLEFT", 0, -10)
        self.addDialog.droppedLabel:SetText("Dropped:")
        
        self.addDialog.droppedDropdown = CreateFrame("Frame", "ClassicCalendarWorldBuffDroppedDropdown", self.addDialog, "UIDropDownMenuTemplate")
        self.addDialog.droppedDropdown:SetPoint("TOPLEFT", self.addDialog.droppedLabel, "BOTTOMLEFT", -15, -5)
        UIDropDownMenu_SetWidth(self.addDialog.droppedDropdown, 100)
        UIDropDownMenu_SetText(self.addDialog.droppedDropdown, "No")
        
        UIDropDownMenu_Initialize(self.addDialog.droppedDropdown, function(self, level)
            -- Create "No" option
            local info = UIDropDownMenu_CreateInfo()
            info.text = "No"
            info.value = "No"
            info.func = function() 
                UIDropDownMenu_SetSelectedValue(WorldBuffs.addDialog.droppedDropdown, "No")
                UIDropDownMenu_SetText(WorldBuffs.addDialog.droppedDropdown, "No")
            end
            UIDropDownMenu_AddButton(info)
            
            -- Create "Yes" option
            local yesInfo = UIDropDownMenu_CreateInfo()
            yesInfo.text = "Yes"
            yesInfo.value = "Yes"
            yesInfo.func = function() 
                UIDropDownMenu_SetSelectedValue(WorldBuffs.addDialog.droppedDropdown, "Yes")
                UIDropDownMenu_SetText(WorldBuffs.addDialog.droppedDropdown, "Yes")
            end
            UIDropDownMenu_AddButton(yesInfo)
        end)
        
        -- Buttons
        self.addDialog.saveButton = CreateFrame("Button", nil, self.addDialog, "GameMenuButtonTemplate")
        self.addDialog.saveButton:SetPoint("BOTTOMRIGHT", self.addDialog, "BOTTOMRIGHT", -25, 15)
        self.addDialog.saveButton:SetSize(60, 22)
        self.addDialog.saveButton:SetText("Save")
        self.addDialog.saveButton:SetScript("OnClick", function()
            WorldBuffs:SaveEntry()
        end)
        
        self.addDialog.cancelButton = CreateFrame("Button", nil, self.addDialog, "GameMenuButtonTemplate")
        self.addDialog.cancelButton:SetPoint("RIGHT", self.addDialog.saveButton, "LEFT", -5, 0)
        self.addDialog.cancelButton:SetSize(60, 22)
        self.addDialog.cancelButton:SetText("Cancel")
        self.addDialog.cancelButton:SetScript("OnClick", function()
            self.addDialog:Hide()
        end)
        
        -- Delete button (only shown in edit mode)
        self.addDialog.deleteButton = CreateFrame("Button", nil, self.addDialog, "GameMenuButtonTemplate")
        self.addDialog.deleteButton:SetPoint("RIGHT", self.addDialog.cancelButton, "LEFT", -5, 0)
        self.addDialog.deleteButton:SetSize(60, 22)
        self.addDialog.deleteButton:SetText("Delete")
        self.addDialog.deleteButton:SetScript("OnClick", function()
            WorldBuffs:DeleteEntry()
        end)
        self.addDialog.deleteButton:Hide() -- Hidden by default
        
        -- Apply ClassicCalendar styling to all dialog buttons
        self:StyleCalendarButton(self.addDialog.saveButton, 60)
        self:StyleCalendarButton(self.addDialog.cancelButton, 60)
        self:StyleCalendarButton(self.addDialog.deleteButton, 60)
    end
    
    -- Clear inputs and show
    self.addDialog.playerInput:SetText("")
    self.addDialog.mainNameInput:SetText("")
    
    -- Reset to today's date
    self.addDialog.selectedDate = {
        month = tonumber(date("%m")),
        day = tonumber(date("%d")),
        year = tonumber(date("%Y"))
    }
    self.addDialog.dateButton:SetText(tostring(date("%m/%d/%Y")))
    
    -- Reset title and button visibility based on edit mode
    if not self.editMode then
        self.addDialog.TitleText:SetText("Add World Buff Entry")
        -- Always hide delete button in add mode
        if self.addDialog.deleteButton then
            self.addDialog.deleteButton:Hide()
        end
    else
        -- Show delete button in edit mode
        if self.addDialog.deleteButton then
            self.addDialog.deleteButton:Show()
        end
    end
    
    -- Update positioning to snap directly to the right (like ClassicCalendar guild event popup)
    if WorldBuffFrame and WorldBuffFrame:IsShown() then
        self.addDialog:ClearAllPoints()
        self.addDialog:SetPoint("TOPLEFT", WorldBuffFrame, "TOPRIGHT", 0, -24)
    end
    
    self.addDialog:Show()
end

-- Show placeholder dialog (same as add dialog but with TBD pre-filled)
function WorldBuffs:ShowPlaceholderDialog()
    -- Get current tab to determine item type
    local currentTab = nil
    local itemType = nil
    if WorldBuffFrame and WorldBuffFrame.selectedTab and WorldBuffFrame.tabs[WorldBuffFrame.selectedTab] then
        currentTab = WorldBuffFrame.tabs[WorldBuffFrame.selectedTab].itemType
        itemType = currentTab
    end
    
    if not itemType then
        print("Error: Could not determine item type for placeholder event")
        return
    end
    
    -- Create placeholder data with "TBD" as player name
    local placeholderData = {
        playerName = "TBD",
        mainName = "",
        receivedDate = date("%m/%d/%Y"),
        dropped = "No"
    }
    
    -- Show date picker popup for the placeholder event (same flow as normal event)
    self:ShowDatePickerPopup(itemType, placeholderData)
end



-- Save entry from dialog
function WorldBuffs:SaveEntry()
    local fullPlayerName = self.addDialog.playerInput:GetText()
    local playerName = string.match(fullPlayerName, "([^-]+)") or fullPlayerName -- Remove realm portion
    local mainName = self.addDialog.mainNameInput:GetText()
    local receivedDate = string.format("%02d/%02d/%d", 
        self.addDialog.selectedDate.month, 
        self.addDialog.selectedDate.day, 
        self.addDialog.selectedDate.year)

    -- Require valid player name
    if playerName == "" or playerName == nil or playerName:match("^%s*$") then
        print("|cFFFF0000ClassicCalendar:|r Player name is required.")
        return
    end
    
    -- Get current tab using selectedTab property
    local currentTab = nil
    if WorldBuffFrame and WorldBuffFrame.selectedTab and WorldBuffFrame.tabs[WorldBuffFrame.selectedTab] then
        currentTab = WorldBuffFrame.tabs[WorldBuffFrame.selectedTab].itemType
    end
    
    if not currentTab then
        currentTab = "REND_HEAD" -- Default
    end
    
    -- Get the appropriate data table
    local dataTable = self:GetWorldBuffDataTable(currentTab)
    
    if self.editMode then
        -- Edit existing entry - safely get dropped value
        local dropped = "No" -- Default value
        if self.addDialog.droppedDropdown then
            local dropdownText = UIDropDownMenu_GetText(self.addDialog.droppedDropdown)
            if dropdownText and dropdownText ~= "" then
                dropped = dropdownText
            end
        end
        -- Fall back to original data if dropdown doesn't exist
        if not self.addDialog.droppedDropdown and self.editOriginalData and self.editOriginalData.dropped then
            dropped = self.editOriginalData.dropped
        end
        
        dataTable[self.editIndex] = {
            playerName = tostring(playerName or ""),
            mainName = tostring(mainName or ""),
            receivedDate = tostring(receivedDate or ""),
            dropped = tostring(dropped or "No"),
            lastModified = time()
        }
        
        -- Clear edit mode
        self.editMode = false
        self.editIndex = nil
        self.editOriginalData = nil
        
        print("Updated entry for " .. playerName)
    else
        -- Add new entry
        local dropped = "No" -- Default to No for new entries
        
        table.insert(dataTable, {
            playerName = tostring(playerName or ""),
            mainName = tostring(mainName or ""),
            receivedDate = tostring(receivedDate or ""),
            dropped = tostring(dropped or "No"),
            lastModified = time()
        })
        
        print("Added new entry for " .. playerName)
    end
    
    -- Refresh display
    self:ShowTab(currentTab)
    
    -- Hide dialog and reset title and buttons
    self.addDialog:Hide()
    self.addDialog.TitleText:SetText("Add World Buff Entry")
    
    -- Hide delete button when closing
    if self.addDialog.deleteButton then
        self.addDialog.deleteButton:Hide()
    end
    
    print("World buff entry saved for " .. playerName)
    
    -- Trigger guild sync
    if ClassicCalendarDataSync then
        ClassicCalendarDataSync:TriggerSync()
    end
end

-- Edit existing entry
function WorldBuffs:EditEntry(index, data)
    -- Validate input parameters
    if not index or not data then
        print("Cannot edit entry: missing index or data")
        return
    end
    
    -- Don't allow editing deleted entries
    if data.deleted then
        print("Cannot edit deleted entry")
        return
    end
    
    -- Store edit context
    self.editMode = true
    self.editIndex = index
    self.editOriginalData = data
    
    -- Show the add dialog but pre-populate with existing data
    self:ShowAddEntryDialog()
    
    -- Pre-populate the fields with current data
    if self.addDialog and self.addDialog.playerInput then
        self.addDialog.playerInput:SetText(data.playerName or "")
        self.addDialog.mainNameInput:SetText(data.mainName or "")
        
        -- Hide autocomplete dropdown since we're pre-populating with existing data
        if self.addDialog.autocompleteFrame then
            self.addDialog.autocompleteFrame:Hide()
        end
        
        -- Parse the date and set it - handle potentially missing or misnamed date field
        local dateString = data.receivedDate or data.playerNameedDate or data.droppededDate or ""
        if dateString and dateString ~= "" then
            local month, day, year = dateString:match("(%d+)/(%d+)/(%d+)")
            if month and day and year then
                self.addDialog.selectedDate = {
                    month = tonumber(month),
                    day = tonumber(day), 
                    year = tonumber(year)
                }
                -- Update the date button display
                self.addDialog.dateButton:SetText(dateString)
            end
        else
            -- Default to today's date if no date is available
            local currentDate = date("*t")
            self.addDialog.selectedDate = {
                month = currentDate.month,
                day = currentDate.day,
                year = currentDate.year
            }
            local defaultDate = string.format("%02d/%02d/%d", currentDate.month, currentDate.day, currentDate.year)
            self.addDialog.dateButton:SetText(defaultDate)
        end
        
        -- Set dropped status - properly set both selected value and display text
        if self.addDialog.droppedDropdown then
            local droppedValue = data.dropped or "No"
            UIDropDownMenu_SetSelectedValue(self.addDialog.droppedDropdown, droppedValue)
            UIDropDownMenu_SetText(self.addDialog.droppedDropdown, droppedValue)
        end
        
        -- Change dialog title to indicate edit mode
        self.addDialog.TitleText:SetText("Edit World Buff Entry")
        
        -- Show delete button in edit mode
        if self.addDialog.deleteButton then
            self.addDialog.deleteButton:Show()
        end
    end
end



-- Create guild event for world buff drop
function WorldBuffs:CreateGuildEvent(data)
    -- Get current tab to determine item type
    local currentTab = nil
    local itemType = nil
    if WorldBuffFrame and WorldBuffFrame.selectedTab and WorldBuffFrame.tabs[WorldBuffFrame.selectedTab] then
        currentTab = WorldBuffFrame.tabs[WorldBuffFrame.selectedTab].itemType
        itemType = currentTab
    end
    
    if not itemType then
        print("Error: Could not determine item type for guild event")
        return
    end
    
    -- Show date picker popup first
    self:ShowDatePickerPopup(itemType, data)
end

function WorldBuffs:ShowDatePickerPopup(itemType, data)
    if DEBUG_MODE then
        print("WorldBuffs Debug: ShowDatePickerPopup called for", itemType)
    end
    
    -- Create date picker popup if it doesn't exist
    if not self.datePickerPopup then
        self.datePickerPopup = CreateFrame("Frame", "ClassicCalendarWorldBuffDatePicker", UIParent, "BasicFrameTemplateWithInset")
        self.datePickerPopup:SetSize(250, 300)
        self.datePickerPopup:SetFrameStrata("HIGH")
        self.datePickerPopup:SetClampedToScreen(true)
        self.datePickerPopup:SetToplevel(true)
        self.datePickerPopup.TitleText:SetText("Select Event Date")
        
        -- Make background transparent
        WorldBuffs:HideFrameBackground(self.datePickerPopup)
        
        -- Store selected date
        self.datePickerPopup.selectedDate = {
            month = tonumber(date("%m")),
            day = tonumber(date("%d")),
            year = tonumber(date("%Y"))
        }
        
        -- Date display button
        self.datePickerPopup.dateButton = CreateFrame("Button", nil, self.datePickerPopup, "GameMenuButtonTemplate")
        self.datePickerPopup.dateButton:SetPoint("TOP", self.datePickerPopup, "TOP", 0, -35)
        self.datePickerPopup.dateButton:SetSize(150, 25)
        self.datePickerPopup.dateButton:SetFrameLevel(self.datePickerPopup:GetFrameLevel() + 1)
        self.datePickerPopup.dateButton:SetText(tostring(date("%m/%d/%Y")))
        
        -- Calendar popup frame
        self.datePickerPopup.calendarFrame = CreateFrame("Frame", nil, self.datePickerPopup, "BackdropTemplate")
        self.datePickerPopup.calendarFrame:SetSize(220, 170)
        self.datePickerPopup.calendarFrame:SetPoint("TOP", self.datePickerPopup, "TOP", 0, -70)
        local calendarBackdrop = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, 
            tileSize = 8, 
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        }
        self.datePickerPopup.calendarFrame:SetBackdrop(calendarBackdrop)
        self.datePickerPopup.calendarFrame:SetBackdropColor(0, 0, 0, 0)  -- Transparent background
        self.datePickerPopup.calendarFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.3)  -- Semi-transparent border
        self.datePickerPopup.calendarFrame:SetFrameLevel(self.datePickerPopup:GetFrameLevel() + 1)
        self.datePickerPopup.calendarFrame:Show() -- Always show calendar in picker
        
        -- Create calendar controls for date picker
        if DEBUG_MODE then
            print("WorldBuffs Debug: Creating calendar controls")
        end
        self:CreateDatePickerCalendarControls()
        
        -- Set up OnShow handler to update calendar when popup is shown
        self.datePickerPopup:SetScript("OnShow", function()
            if DEBUG_MODE then
                print("WorldBuffs Debug: Date picker popup shown, updating calendar")
            end
            self:UpdateDatePickerCalendar()
        end)
        
        -- Set up OnHide handler for cleanup
        self.datePickerPopup:SetScript("OnHide", function()
            if DEBUG_MODE then
                print("WorldBuffs Debug: Date picker popup hidden")
            end
            -- Additional cleanup can be added here if needed
        end)
        
        -- Date button click handler (toggle calendar visibility)
        self.datePickerPopup.dateButton:SetScript("OnClick", function()
            if self.datePickerPopup.calendarFrame:IsShown() then
                self.datePickerPopup.calendarFrame:Hide()
            else
                self:UpdateDatePickerCalendar()
                self.datePickerPopup.calendarFrame:Show()
            end
        end)
        
        -- Confirm button
        self.datePickerPopup.confirmButton = CreateFrame("Button", nil, self.datePickerPopup, "GameMenuButtonTemplate")
        self.datePickerPopup.confirmButton:SetPoint("BOTTOMRIGHT", self.datePickerPopup, "BOTTOMRIGHT", -25, 15)
        self.datePickerPopup.confirmButton:SetSize(80, 22)
        self.datePickerPopup.confirmButton:SetText("Create Event")
        
        -- Cancel button
        self.datePickerPopup.cancelButton = CreateFrame("Button", nil, self.datePickerPopup, "GameMenuButtonTemplate")
        self.datePickerPopup.cancelButton:SetPoint("RIGHT", self.datePickerPopup.confirmButton, "LEFT", -5, 0)
        self.datePickerPopup.cancelButton:SetSize(60, 22)
        self.datePickerPopup.cancelButton:SetText("Cancel")
        self.datePickerPopup.cancelButton:SetScript("OnClick", function()
            self.datePickerPopup:Hide()
        end)
        
        -- Apply ClassicCalendar styling to date picker buttons
        self:StyleCalendarButton(self.datePickerPopup.dateButton, 150)
        self:StyleCalendarButton(self.datePickerPopup.confirmButton, 80)
        self:StyleCalendarButton(self.datePickerPopup.cancelButton, 60)
    end
    
    -- Reset to today's date
    self.datePickerPopup.selectedDate = {
        month = tonumber(date("%m")),
        day = tonumber(date("%d")),
        year = tonumber(date("%Y"))
    }
    self.datePickerPopup.dateButton:SetText(tostring(date("%m/%d/%Y")))
    
    -- Update calendar display
    self:UpdateDatePickerCalendar()
    
    -- Set up confirm button for this specific event
    self.datePickerPopup.confirmButton:SetScript("OnClick", function()
        self.datePickerPopup:Hide()
        WorldBuffs:CreateGuildEventWithDate(itemType, data, self.datePickerPopup.selectedDate)
    end)
    
    -- Position and show popup snapped to the right (like ClassicCalendar guild event popup)
    self.datePickerPopup:ClearAllPoints()
    if self.addDialog and self.addDialog:IsShown() then
        -- If addDialog is open, calculate position to ensure top alignment
        -- Position relative to WorldBuffFrame but offset by addDialog width to stack horizontally
        local addDialogWidth = self.addDialog:GetWidth()
        self.datePickerPopup:SetPoint("TOPLEFT", WorldBuffFrame, "TOPRIGHT", addDialogWidth, -24)
    elseif WorldBuffFrame and WorldBuffFrame:IsShown() then
        -- Otherwise position relative to the main WorldBuff window
        self.datePickerPopup:SetPoint("TOPLEFT", WorldBuffFrame, "TOPRIGHT", 0, -24)
    else
        -- Fallback to center screen
        self.datePickerPopup:SetPoint("CENTER")
    end
    
    if DEBUG_MODE then
        print("WorldBuffs Debug: Showing date picker popup")
    end
    self.datePickerPopup:Show()
end

function WorldBuffs:CreateGuildEventWithDate(itemType, data, selectedDate)
    -- Ensure the calendar window is open first
    if not CalendarFrame or not CalendarFrame:IsShown() then
        if ShowUIPanel and CalendarFrame then
            ShowUIPanel(CalendarFrame)
        else
            print("Error: Cannot open calendar window")
            return
        end
    end
    
    -- Navigate to the selected month first - check what month calendar is currently displaying
    local calendarMonthInfo = C_Calendar.GetMonthInfo()
    local displayedMonth = calendarMonthInfo and calendarMonthInfo.month or tonumber(date("%m"))
    local displayedYear = calendarMonthInfo and calendarMonthInfo.year or tonumber(date("%Y"))
    
    -- Calculate how many months to navigate from displayed month to selected month
    local yearDiff = selectedDate.year - displayedYear
    local monthDiff = selectedDate.month - displayedMonth
    local monthOffset = yearDiff * 12 + monthDiff
    
    -- Only navigate if we're not already displaying the correct month
    if monthOffset ~= 0 then
        CalendarFrame_OffsetMonth(monthOffset)
    end
    
    -- Create a simple fake day button for the event
    local fakeDayButton = {
        day = selectedDate.day,
        monthOffset = 0, -- No additional offset needed after navigation
        GetID = function(self) return 1 end,
        LockHighlight = function() end,
        UnlockHighlight = function() end,
        GetHighlightTexture = function() 
            return { SetAlpha = function() end }
        end
    }
    
    -- Create guild event directly (skip the day selection which causes UI errors with fake buttons)
    if C_Calendar and CalendarFrame_ShowEventFrame and CalendarCreateEventFrame then
        -- Close any existing events and hide event frame (same as CalendarDayContextMenu_ClearEvent but skip day selection)
        C_Calendar.CloseEvent()
        CalendarFrame_HideEventFrame()
        
        -- Create guild event (same as CalendarDayContextMenu_CreateGuildEvent but skip problematic day button calls)
        C_Calendar.CreateGuildSignUpEvent()
        CalendarCreateEventFrame.mode = "create"
        CalendarCreateEventFrame.dayButton = fakeDayButton  -- Store the day info for the event
        
        -- Set the event date to exactly what was selected (no calculations needed)
        C_Calendar.EventSetDate(selectedDate.month, selectedDate.day, selectedDate.year)
        
        CalendarFrame_ShowEventFrame(CalendarCreateEventFrame)
        
        -- Get item display names and descriptions (avoid apostrophes for calendar compatibility)
        local itemNames = {
            REND_HEAD = "Rend Head",
            NEFARIAN_HEAD = "Nefarian Head", 
            ONYXIA_HEAD = "Onyxia Head",
            HAKKAR_HEART = "Heart of Hakkar"
        }
        
        -- Ensure World Buffs filter is enabled so our events are visible
        if GetCVar("calendarShowWorldBuffs") == "0" then
            SetCVar("calendarShowWorldBuffs", "1")
            CalendarFrame_Update() -- Refresh calendar to show our events
        end
        
        -- Enhanced WoW-style descriptions with faction-specific text
        local eventDescriptionTemplates = {
            Horde = {
                REND_HEAD = "Heed the call, heroes of the Horde! <playername> has conquered the mighty Rend Blackhand and shall present his severed head as tribute to our great Warchief!\n\n" ..
                           "Rally at Orgrimmar or the Crossroads for this momentous ceremony!\n" ..
                           "The Rallying Cry of the Dragonslayer awaits - granting +140 Attack Power and +5% Critical Strike!\n" ..
                           "Arrive 5 minutes early to secure your place in this glorious gathering!\n\n" ..
                           "For the Horde! Lok'tar Ogar!",
                
                NEFARIAN_HEAD = "Witness the fall of a dragon! <playername> has slain the dread Nefarian, Lord of Blackrock, and returns with proof of this legendary victory!\n\n" ..
                                "Gather at Orgrimmar or the Crossroads to honor this heroic deed!\n" ..
                                "The Dragonslayer's blessing shall flow through all present - +140 Attack Power and +5% Critical Strike!\n" ..
                                "Be present 5 minutes before the ceremony begins!\n\n" ..
                                "The Black Dragonflight trembles! Victory to the Horde!",
                
                ONYXIA_HEAD = "Behold! <playername> returns victorious from the depths of Onyxia's Lair, bearing the head of the Broodmother herself!\n\n" ..
                              "All members of the Horde are summoned to Orgrimmar or the Crossroads!\n" ..
                              "Receive the Rallying Cry of the Dragonslayer - +140 Attack Power and +5% Critical Strike chance!\n" ..
                              "Assemble 5 minutes prior to witness this triumph!\n\n" ..
                              "Let the Alliance tremble at our might! For the Horde!",
                
                HAKKAR_HEART = "The Soulflayer has fallen! <playername> has ventured into the accursed depths of Zul'Gurub and torn the very heart from the blood god Hakkar!\n\n" ..
                               "Journey to Booty Bay or the sacred grounds of Zandalar Isle!\n" ..
                               "The Spirit of Zandalar shall bless all who attend - +15% to all stats!\n" ..
                               "Arrive early to partake in this ancient Trollish ritual!\n\n" ..
                               "May the loa smile upon us! Victory to those who dare!"
            },
            Alliance = {
                REND_HEAD = "Citizens of the Alliance! <playername> has struck down the orc warlord Rend Blackhand and returns bearing proof of this noble victory!\n\n" ..
                           "Gather at Stormwind City or Ironforge to witness this heroic display!\n" ..
                           "The Rallying Cry of the Dragonslayer shall inspire all - +140 Attack Power and +5% Critical Strike!\n" ..
                           "Arrive 5 minutes early to honor this champion of justice!\n\n" ..
                           "For the Alliance! For honor and glory!",
                
                NEFARIAN_HEAD = "A great evil has fallen! <playername> has vanquished Nefarian, the corrupted dragon lord, and brings forth evidence of this legendary triumph!\n\n" ..
                                "All Alliance members are called to Stormwind City or Ironforge!\n" ..
                                "Receive the Dragonslayer's blessing - +140 Attack Power and +5% Critical Strike!\n" ..
                                "Assemble 5 minutes before this ceremony of valor!\n\n" ..
                                "Light be with us! The Alliance stands strong!",
                
                ONYXIA_HEAD = "Victory is ours! <playername> has conquered the dreaded Onyxia in her own lair and returns with the head of the Broodmother!\n\n" ..
                              "Citizens of the Alliance, gather at Stormwind City or Ironforge!\n" ..
                              "The Rallying Cry of the Dragonslayer will strengthen all who attend - +140 Attack Power and +5% Critical Strike!\n" ..
                              "Be present 5 minutes early to witness this triumph over darkness!\n\n" ..
                              "By the Light, the Alliance prevails!",
                
                HAKKAR_HEART = "The blood god falls! <playername> has braved the cursed halls of Zul'Gurub and ripped the heart from Hakkar the Soulflayer!\n\n" ..
                               "Journey to Booty Bay or brave the wilds of Stranglethorn!\n" ..
                               "All shall receive the Spirit of Zandalar - +15% to all attributes!\n" ..
                               "Gather early for this ancient ritual of power!\n\n" ..
                               "May the Light guide us to victory!"
            }
        }
        
        -- Helper function to replace placeholders with actual values
        local function ProcessEventText(template, playerName, itemName)
            local processed = template:gsub("<playername>", playerName)
            processed = processed:gsub("<item>", itemName)
            return processed
        end
        
        -- Helper function to sanitize calendar event titles
        local function SanitizeEventTitle(title)
            -- Remove problematic characters that might cause CALENDAR_EVENT_NEEDS_TITLE error
            local sanitized = title:gsub("'", "") -- Remove apostrophes
            sanitized = sanitized:gsub('"', '') -- Remove quotes  
            sanitized = sanitized:gsub("[%c%z]", "") -- Remove control characters
            sanitized = sanitized:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
            -- Limit length to 64 characters (common WoW limit)
            if #sanitized > 64 then
                sanitized = sanitized:sub(1, 61) .. "..."
            end
            -- Ensure title is not empty
            if sanitized == "" then
                sanitized = "World Buff Drop"
            end
            return sanitized
        end
        
        -- Get player's faction for appropriate text
        local playerFaction = UnitFactionGroup("player")
        
        -- Wait for the UI to load, then populate the fields
        C_Timer.After(0.3, function()
            -- Get player name and item name, strip realm from player name
            local fullPlayerName = data.playerName or UnitName("player")
            local playerName = string.match(fullPlayerName, "([^-]+)") or fullPlayerName -- Remove realm portion
            local itemName = itemNames[itemType] or "World Buff Item"
            
            -- Set the enhanced event title with sanitization (no metadata in title due to visibility issues)
            local rawTitle = playerName .. " Dropping " .. itemName
            local eventTitle = SanitizeEventTitle(rawTitle)
            local eventTitleWithMetadata = eventTitle
            
            if CalendarCreateEventTitleEdit then
                CalendarCreateEventTitleEdit:SetText(eventTitleWithMetadata)
                CalendarCreateEventTitleEdit:SetCursorPosition(0)
                
                -- Manually trigger the calendar system to register the title
                -- because programmatic SetText doesn't trigger userChanged=true
                C_Calendar.EventSetTitle(eventTitleWithMetadata)
                
                -- Validate that the title was set correctly
                local setTitle = CalendarCreateEventTitleEdit:GetText()
                print("WorldBuffs Debug: Setting event title:", eventTitleWithMetadata)
                print("WorldBuffs Debug: Title field contains:", setTitle)
            else
                print("WorldBuffs Debug: CalendarCreateEventTitleEdit not found!")
            end
            
            -- Set the enhanced event description with player name and faction-specific text
            local factionTemplates = eventDescriptionTemplates[playerFaction] or eventDescriptionTemplates["Horde"]
            local descriptionTemplate = factionTemplates[itemType] or "World buff drop event by <playername>."
            local description = ProcessEventText(descriptionTemplate, playerName, itemName)
            
            -- Set the description (no metadata needed - title patterns work fine)
            if CalendarCreateEventDescriptionContainer and CalendarCreateEventDescriptionContainer.ScrollingEditBox then
                CalendarCreateEventDescriptionContainer.ScrollingEditBox:SetText(description)
            end
            
            -- Set the lock event checkbox to checked
            if CalendarCreateEventLockEventCheck then
                CalendarCreateEventLockEventCheck:SetChecked(true)
                if CalendarCreateEvent_SetLockEvent then
                    CalendarCreateEvent_SetLockEvent()
                end
            end
            
            print("Guild event pre-filled for " .. itemName .. " drop by " .. (data.playerName or "Unknown"))
        end)
        
        print("Opening guild event creation for " .. (itemNames[itemType] or "World Buff Item") .. " drop on " .. selectedDate.month .. "/" .. selectedDate.day .. "/" .. selectedDate.year)
    else
        print("Error: Calendar system functions not available. Make sure the main calendar is loaded and visible.")
    end
end

-- Slash command to open WorldBuff management
SLASH_WORLDBUFF1 = "/worldbuff"
SLASH_WORLDBUFF2 = "/wb"
SlashCmdList["WORLDBUFF"] = function()
    -- Debug output (only if DEBUG_MODE is enabled)
    if DEBUG_MODE then
        local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
        print("WorldBuff Debug: Guild Name:", guildName or "None")
        print("WorldBuff Debug: Guild Rank:", guildRankName or "None")
        print("WorldBuff Debug: Guild Rank Index:", guildRankIndex or "None")
        print("WorldBuff Debug: Can Guild Invite:", CanGuildInvite and (CanGuildInvite() and "Yes" or "No") or "Function not available")
        print("WorldBuff Debug: IsOfficer():", IsOfficer() and "Yes" or "No")
    end
    
    if not IsOfficer() then
        print("World Buff management is only available to guild officers.")
        return
    end
    
    WorldBuffs:CreateMainFrame()
    if WorldBuffFrame and WorldBuffFrame:IsShown() then
        WorldBuffFrame:Hide()
    elseif WorldBuffFrame then
        WorldBuffFrame:Show()
        WorldBuffs:ShowTab("REND_HEAD") -- Default to first tab
        
        -- Run garbage collection on deleted entries when window is opened
        WorldBuffs:GarbageCollectDeletedEntries(7) -- Keep deleted entries for 7 days
    end
end

-- Sanitize an entry by removing invalid fields and creating a clean copy
function WorldBuffs:SanitizeEntry(entry)
    if not entry then return nil end
    
    -- Valid field names that should exist in a world buff entry
    local validFields = {
        playerName = true,
        mainName = true,
        receivedDate = true,
        dropped = true,
        lastModified = true,
        deleted = true,
        deletedTime = true
    }
    
    -- Create a clean new entry with only valid fields (with explicit string copies)
    local cleanEntry = {}
    
    for key, value in pairs(entry) do
        if validFields[key] then
            -- Force string copy to prevent memory corruption
            if type(value) == "string" then
                cleanEntry[key] = tostring(value)
            else
                cleanEntry[key] = value
            end
        elseif DEBUG_MODE then
            print("WorldBuff Debug: Removing invalid field '" .. tostring(key) .. "' from entry")
        end
    end
    
    -- Validate and fix data types
    if cleanEntry.lastModified and type(cleanEntry.lastModified) ~= "number" then
        cleanEntry.lastModified = time()
    end
    
    if cleanEntry.deletedTime and type(cleanEntry.deletedTime) ~= "number" then
        cleanEntry.deletedTime = time()
    end
    
    -- Ensure required fields exist
    if not cleanEntry.playerName or cleanEntry.playerName == "" or cleanEntry.playerName:match("^%s*$") then
        -- Entry has no valid player name, reject it
        if DEBUG_MODE then
            print("WorldBuff Debug: Rejecting entry with no valid player name")
        end
        return nil
    end
    
    -- Reject [Alt of X] placeholder entries from old design
    if cleanEntry.playerName:match("^%[Alt of .+%]$") then
        if DEBUG_MODE then
            print("WorldBuff Debug: Rejecting [Alt of X] placeholder entry")
        end
        return nil
    end
    
    if not cleanEntry.mainName or cleanEntry.mainName == "" then
        cleanEntry.mainName = cleanEntry.playerName
    end
    
    -- Validate mainName for corruption patterns
    if cleanEntry.mainName then
        local mName = cleanEntry.mainName
        
        -- Reject if mainName is corrupted (dates, truncated [Alt of X], timestamp digits)
        if mName:match("%d%d?/%d%d?/%d%d%d%d") or  -- Date pattern
           mName:match("%d%d%d%d%d%d") or          -- 6+ consecutive digits (timestamp)
           mName:match("^%[Alt of [^%]]*$") or     -- Truncated [Alt of X]
           mName:match("/%d") or                    -- Slash followed by digit (date fragment)
           #mName < 2 then                          -- Too short
            if DEBUG_MODE then
                print("WorldBuff Debug: Rejecting entry with corrupted mainName: " .. mName)
            end
            return nil
        end
    end
    
    -- Reject entries with "Unknown Player" as the name
    if cleanEntry.playerName == "Unknown Player" or cleanEntry.mainName == "Unknown Player" then
        if DEBUG_MODE then
            print("WorldBuff Debug: Rejecting Unknown Player entry")
        end
        return nil
    end
    
    -- Reject obviously corrupted player names (dates, short names, weird characters)
    if cleanEntry.playerName then
        local pName = cleanEntry.playerName
        
        -- Reject if playerName looks like a date (contains / or has year pattern)
        if pName:match("%d%d?/%d%d?/%d%d%d%d") or pName:match("20%d%d") then
            if DEBUG_MODE then
                print("WorldBuff Debug: Rejecting entry with date in playerName: " .. pName)
            end
            return nil
        end
        
        -- Reject very short names - likely truncated
        if #pName < 3 then
            if DEBUG_MODE then
                print("WorldBuff Debug: Rejecting entry with truncated playerName: " .. pName)
            end
            return nil
        end
        
        -- Reject names with 6+ consecutive digits (timestamp fragments)
        if pName:match("%d%d%d%d%d%d") then
            if DEBUG_MODE then
                print("WorldBuff Debug: Rejecting entry with timestamp digits in playerName: " .. pName)
            end
            return nil
        end
        
        -- Reject truncated [Alt of X] entries (missing closing bracket or too short after "Alt of")
        if pName:match("^%[Alt of [^%]]*$") or pName:match("^%[Alt of .?.?%]$") then
            if DEBUG_MODE then
                print("WorldBuff Debug: Rejecting truncated [Alt of X] entry: " .. pName)
            end
            return nil
        end
        
        -- Reject names with slash followed by digits (date fragments like H/2025)
        if pName:match("/%d") then
            if DEBUG_MODE then
                print("WorldBuff Debug: Rejecting entry with date fragment in playerName: " .. pName)
            end
            return nil
        end
    end
    
    -- Validate lastModified timestamp (should be reasonable unix timestamp)
    if cleanEntry.lastModified and (cleanEntry.lastModified < 1700000000 or cleanEntry.lastModified > 2000000000) then
        if DEBUG_MODE then
            print("WorldBuff Debug: Fixing corrupted timestamp: " .. cleanEntry.lastModified)
        end
        cleanEntry.lastModified = time()
    end
    
    -- Validate and fix receivedDate format
    if not cleanEntry.receivedDate or cleanEntry.receivedDate == "" then
        cleanEntry.receivedDate = date("%m/%d/%Y")
    elseif type(cleanEntry.receivedDate) == "number" then
        -- Convert Unix timestamp to date string
        cleanEntry.receivedDate = date("%m/%d/%Y", cleanEntry.receivedDate)
        if DEBUG_MODE then
            print("WorldBuff Debug: Converted timestamp receivedDate to date string")
        end
    else
        -- Check if date format is valid (MM/DD/YYYY)
        local month, day, year = cleanEntry.receivedDate:match("^(%d%d?)/(%d%d?)/(%d%d%d%d)$")
        if not month or not day or not year then
            if DEBUG_MODE then
                print("WorldBuff Debug: Fixing malformed receivedDate: " .. cleanEntry.receivedDate)
            end
            cleanEntry.receivedDate = date("%m/%d/%Y")
        else
            -- Validate date ranges
            month = tonumber(month)
            day = tonumber(day)
            year = tonumber(year)
            if month < 1 or month > 12 or day < 1 or day > 31 or year < 2019 or year > 2030 then
                if DEBUG_MODE then
                    print("WorldBuff Debug: Fixing out-of-range receivedDate: " .. cleanEntry.receivedDate)
                end
                cleanEntry.receivedDate = date("%m/%d/%Y")
            end
        end
    end
    
    if not cleanEntry.dropped then
        cleanEntry.dropped = "No"
    end
    
    if not cleanEntry.lastModified then
        cleanEntry.lastModified = time()
    end
    
    return cleanEntry
end

-- Clean up corrupted data entries
function WorldBuffs:CleanupCorruptedData()
    local tables = {
        {name = "WorldBuffRendData", data = WorldBuffRendData},
        {name = "WorldBuffHakkarData", data = WorldBuffHakkarData},
        {name = "WorldBuffOnyxiaData", data = WorldBuffOnyxiaData},
        {name = "WorldBuffNefarianData", data = WorldBuffNefarianData}
    }
    
    local totalCleaned = 0
    local totalRemoved = 0
    local corruptionTypes = {
        ["[Alt of X]"] = 0,
        ["Unknown Player"] = 0,
        ["Date as Name"] = 0,
        ["Timestamp Digits"] = 0,
        ["Invalid Fields"] = 0,
        ["Truncated"] = 0
    }
    
    for _, tableInfo in ipairs(tables) do
        if tableInfo.data then
            local i = 1
            local tableRemoved = 0
            while i <= #tableInfo.data do
                local entry = tableInfo.data[i]
                local removed = false
                
                -- Track corruption types
                if entry.playerName then
                    if entry.playerName:match("^%[Alt of .+%]$") then
                        corruptionTypes["[Alt of X]"] = corruptionTypes["[Alt of X]"] + 1
                        removed = true
                    elseif entry.playerName == "Unknown Player" then
                        corruptionTypes["Unknown Player"] = corruptionTypes["Unknown Player"] + 1
                        removed = true
                    elseif entry.playerName:match("%d%d?/%d%d?/%d%d%d%d") then
                        corruptionTypes["Date as Name"] = corruptionTypes["Date as Name"] + 1
                        removed = true
                    elseif entry.playerName:match("%d%d%d%d%d%d") then
                        corruptionTypes["Timestamp Digits"] = corruptionTypes["Timestamp Digits"] + 1
                        removed = true
                    elseif #entry.playerName < 3 then
                        corruptionTypes["Truncated"] = corruptionTypes["Truncated"] + 1
                        removed = true
                    end
                end
                
                -- Sanitize the entry to remove corrupted fields
                local cleanEntry = self:SanitizeEntry(entry)
                
                if cleanEntry and not removed then
                    -- Replace with clean entry
                    tableInfo.data[i] = cleanEntry
                    totalCleaned = totalCleaned + 1
                    i = i + 1
                else
                    -- Entry is too corrupted, remove it
                    if DEBUG_MODE and entry.playerName then
                        print("WorldBuff Debug: Removing corrupted entry from " .. tableInfo.name .. ": " .. tostring(entry.playerName))
                    end
                    table.remove(tableInfo.data, i)
                    totalRemoved = totalRemoved + 1
                    tableRemoved = tableRemoved + 1
                end
            end
            
            if tableRemoved > 0 and DEBUG_MODE then
                print("WorldBuff Debug: Removed " .. tableRemoved .. " corrupted entries from " .. tableInfo.name)
            end
        end
    end
    
    -- Print summary
    if totalRemoved > 0 then
        print("|cFFFF9900ClassicCalendar:|r Cleaned up " .. totalRemoved .. " corrupted world buff entries")
        
        if DEBUG_MODE then
            for cType, count in pairs(corruptionTypes) do
                if count > 0 then
                    print("  - " .. cType .. ": " .. count)
                end
            end
        end
    end
    
    if totalCleaned > 0 and DEBUG_MODE then
        print("WorldBuff Debug: Sanitized " .. totalCleaned .. " entries (removed invalid fields)")
    end
end

-- Fix corrupted saved variable data (legacy function - now uses sanitization)
function WorldBuffs:FixCorruptedData()
    -- Just call the cleanup function which now includes sanitization
    self:CleanupCorruptedData()
end

-- Migrate old WorldBuffData format to new separate tables
function WorldBuffs:MigrateOldData()
    if WorldBuffData then
        print("WorldBuff Debug: Migrating old WorldBuffData to separate tables...")
        
        -- Migrate each item type to its own table
        if WorldBuffData["REND_HEAD"] and #WorldBuffData["REND_HEAD"] > 0 then
            for _, entry in ipairs(WorldBuffData["REND_HEAD"]) do
                table.insert(WorldBuffRendData, entry)
            end
            print("WorldBuff Debug: Migrated", #WorldBuffData["REND_HEAD"], "REND_HEAD entries")
        end
        
        if WorldBuffData["HAKKAR_HEART"] and #WorldBuffData["HAKKAR_HEART"] > 0 then
            for _, entry in ipairs(WorldBuffData["HAKKAR_HEART"]) do
                table.insert(WorldBuffHakkarData, entry)
            end
            print("WorldBuff Debug: Migrated", #WorldBuffData["HAKKAR_HEART"], "HAKKAR_HEART entries")
        end
        
        if WorldBuffData["ONYXIA_HEAD"] and #WorldBuffData["ONYXIA_HEAD"] > 0 then
            for _, entry in ipairs(WorldBuffData["ONYXIA_HEAD"]) do
                table.insert(WorldBuffOnyxiaData, entry)
            end
            print("WorldBuff Debug: Migrated", #WorldBuffData["ONYXIA_HEAD"], "ONYXIA_HEAD entries")
        end
        
        if WorldBuffData["NEFARIAN_HEAD"] and #WorldBuffData["NEFARIAN_HEAD"] > 0 then
            for _, entry in ipairs(WorldBuffData["NEFARIAN_HEAD"]) do
                table.insert(WorldBuffNefarianData, entry)
            end
            print("WorldBuff Debug: Migrated", #WorldBuffData["NEFARIAN_HEAD"], "NEFARIAN_HEAD entries")
        end
        
        -- Clear old data after migration
        WorldBuffData = nil
        print("WorldBuff Debug: Migration complete, old WorldBuffData cleared")
    end
end

-- Initialize WorldBuff module
function WorldBuffs:Initialize()
    print("ClassicCalendar: WorldBuff module loaded")
    
	-- Initialize World Buffs filter in saved variables instead of CVar
	if not CCConfig then
		CCConfig = {}
	end
	if CCConfig.calendarShowWorldBuffs == nil then
		CCConfig.calendarShowWorldBuffs = true -- Default to enabled
		print("WorldBuff Debug: Initialized calendarShowWorldBuffs in CCConfig with default value true")
	else
		print("WorldBuff Debug: calendarShowWorldBuffs already exists in CCConfig, value:", CCConfig.calendarShowWorldBuffs)
	end
	
	-- Initialize WorldBuff frame position storage
	if not CCConfig.WorldBuffFramePos then
		CCConfig.WorldBuffFramePos = {}
	end
	
    -- Initialize saved variables - separate tables for each buff type
    WorldBuffRendData = WorldBuffRendData or {}
    WorldBuffHakkarData = WorldBuffHakkarData or {}
    WorldBuffOnyxiaData = WorldBuffOnyxiaData or {}
    WorldBuffNefarianData = WorldBuffNefarianData or {}
    
    -- Migrate old WorldBuffData format to new separate tables
    self:MigrateOldData()
    
    -- Clean up any corrupted data
    self:CleanupCorruptedData()
    
    print("WorldBuff Debug: Initialized separate data tables for each buff type")
    
    -- Initialize DataSync system
    if ClassicCalendarDataSync then
        ClassicCalendarDataSync:Initialize()
    end
    
    -- Run garbage collection on addon startup
    self:GarbageCollectDeletedEntries(7) -- Keep deleted entries for 7 days
end

-- Export to addon table for access from other files
AddonTable.WorldBuffs = WorldBuffs
_G.WorldBuffs = WorldBuffs

-- Initialize when addon loads
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == AddonName then
        WorldBuffs:Initialize()
    elseif event == "VARIABLES_LOADED" then
        -- Ensure saved variables are properly loaded - separate tables for each buff type
        WorldBuffRendData = WorldBuffRendData or {}
        WorldBuffHakkarData = WorldBuffHakkarData or {}
        WorldBuffOnyxiaData = WorldBuffOnyxiaData or {}
        WorldBuffNefarianData = WorldBuffNefarianData or {}
    elseif event == "PLAYER_LOGOUT" then
        -- Close all popups on logout for clean shutdown
        WorldBuffs:CloseAllPopups()
    end
end)

-- Create calendar controls
function WorldBuffs:CreateCalendarControls()
    local calFrame = self.addDialog.calendarFrame
    
    -- Month/Year header
    calFrame.header = calFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    calFrame.header:SetPoint("TOP", calFrame, "TOP", 0, -10)
    calFrame.header:SetTextColor(1, 1, 1)
    
    -- Previous month button
    calFrame.prevButton = CreateFrame("Button", nil, calFrame, "GameMenuButtonTemplate")
    calFrame.prevButton:SetPoint("LEFT", calFrame.header, "LEFT", -40, 0)
    calFrame.prevButton:SetSize(20, 20)
    calFrame.prevButton:SetText("<")
    calFrame.prevButton:SetScript("OnClick", function()
        self:ChangeMonth(-1)
    end)
    
    -- Next month button
    calFrame.nextButton = CreateFrame("Button", nil, calFrame, "GameMenuButtonTemplate")
    calFrame.nextButton:SetPoint("RIGHT", calFrame.header, "RIGHT", 40, 0)
    calFrame.nextButton:SetSize(20, 20)
    calFrame.nextButton:SetText(">")
    calFrame.nextButton:SetScript("OnClick", function()
        self:ChangeMonth(1)
    end)
    
    -- Apply ClassicCalendar styling to navigation buttons
    self:StyleCalendarButton(calFrame.prevButton, 20)
    self:StyleCalendarButton(calFrame.nextButton, 20)
    
    -- Day of week headers
    local dayHeaders = {"S", "M", "T", "W", "T", "F", "S"}
    calFrame.dayHeaders = {}
    for i = 1, 7 do
        local header = calFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", calFrame, "TOPLEFT", 10 + (i-1) * 25, -35)
        header:SetText(dayHeaders[i])
        header:SetTextColor(1, 1, 1)
        calFrame.dayHeaders[i] = header
    end
    
    -- Day buttons (6 rows x 7 columns = 42 buttons)
    calFrame.dayButtons = {}
    for row = 1, 6 do
        calFrame.dayButtons[row] = {}
        for col = 1, 7 do
            local button = CreateFrame("Button", nil, calFrame)
            button:SetPoint("TOPLEFT", calFrame, "TOPLEFT", 5 + (col-1) * 25, -50 - (row-1) * 20)
            button:SetSize(20, 18)
            
            -- Button text
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetPoint("CENTER")
            button.text:SetTextColor(1, 1, 1)
            
            -- Button background
            button.bg = button:CreateTexture(nil, "BACKGROUND")
            button.bg:SetAllPoints()
            button.bg:SetColorTexture(0, 0, 0, 0)
            
            -- Hover effect
            button:SetScript("OnEnter", function()
                button.bg:SetColorTexture(0.3, 0.3, 0.3, 0.5)
            end)
            
            button:SetScript("OnLeave", function()
                if not button.isSelected then
                    button.bg:SetColorTexture(0, 0, 0, 0)
                end
            end)
            
            -- Click handler
            button:SetScript("OnClick", function()
                if button.day and button.day > 0 then
                    self:SelectDate(button.day)
                    calFrame:Hide()
                end
            end)
            
            calFrame.dayButtons[row][col] = button
        end
    end
end

-- Change month
function WorldBuffs:ChangeMonth(delta)
    local selectedDate = self.addDialog.selectedDate
    selectedDate.month = selectedDate.month + delta
    
    if selectedDate.month > 12 then
        selectedDate.month = 1
        selectedDate.year = selectedDate.year + 1
    elseif selectedDate.month < 1 then
        selectedDate.month = 12
        selectedDate.year = selectedDate.year - 1
    end
    
    self:UpdateCalendar()
end

-- Select a specific date
function WorldBuffs:SelectDate(day)
    local selectedDate = self.addDialog.selectedDate
    selectedDate.day = day
    
    -- Update button text
    local dateStr = string.format("%02d/%02d/%d", selectedDate.month, selectedDate.day, selectedDate.year)
    self.addDialog.dateButton:SetText(dateStr)
end

-- Update calendar display
function WorldBuffs:UpdateCalendar()
    local calFrame = self.addDialog.calendarFrame
    local selectedDate = self.addDialog.selectedDate
    
    -- Month names
    local monthNames = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    }
    
    -- Update header
    calFrame.header:SetText(monthNames[selectedDate.month] .. " " .. selectedDate.year)
    
    -- Get first day of month and number of days
    local daysInMonth = self:GetDaysInMonth(selectedDate.month, selectedDate.year)
    local firstDay = self:GetFirstDayOfWeek(selectedDate.month, selectedDate.year)
    
    -- Clear all buttons first
    for row = 1, 6 do
        for col = 1, 7 do
            local button = calFrame.dayButtons[row][col]
            button.text:SetText("")
            button.day = 0
            button.isSelected = false
            button.bg:SetColorTexture(0, 0, 0, 0)
        end
    end
    
    -- Fill in the days
    local day = 1
    for row = 1, 6 do
        for col = 1, 7 do
            local dayIndex = (row - 1) * 7 + col
            if dayIndex >= firstDay and day <= daysInMonth then
                local button = calFrame.dayButtons[row][col]
                button.text:SetText(tostring(day))
                button.day = day
                
                -- Highlight selected day
                if day == selectedDate.day then
                    button.isSelected = true
                    button.bg:SetColorTexture(0.2, 0.6, 1, 0.5)
                end
                
                day = day + 1
            end
        end
    end
end

-- Helper function to get days in month
function WorldBuffs:GetDaysInMonth(month, year)
    local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    
    -- Check for leap year
    if month == 2 and ((year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)) then
        return 29
    end
    
    return daysInMonth[month]
end

-- Helper function to get first day of week (0=Sunday, 1=Monday, etc.)
function WorldBuffs:GetFirstDayOfWeek(month, year)
    -- Use Zeller's congruence to calculate day of week
    local m = month
    local y = year
    
    if m < 3 then
        m = m + 12
        y = y - 1
    end
    
    local k = y % 100
    local j = math.floor(y / 100)
    
    local h = (1 + math.floor((13 * (m + 1)) / 5) + k + math.floor(k / 4) + math.floor(j / 4) - 2 * j) % 7
    
    -- Convert to 1-based where 1=Sunday, 2=Monday, etc.
    return ((h + 6) % 7) + 1
end

-- Delete entry function
function WorldBuffs:DeleteEntry(index)
    -- Use stored edit index if no index provided (called from delete button)
    local entryIndex = index or self.editIndex
    
    if not entryIndex then
        print("No entry selected for deletion")
        return
    end
    
    -- Get current tab using selectedTab property
    local currentTab = nil
    if WorldBuffFrame and WorldBuffFrame.selectedTab and WorldBuffFrame.tabs[WorldBuffFrame.selectedTab] then
        currentTab = WorldBuffFrame.tabs[WorldBuffFrame.selectedTab].itemType
    end
    
    if currentTab then
        local dataTable = self:GetWorldBuffDataTable(currentTab)
        if dataTable[entryIndex] then
            local playerName = dataTable[entryIndex].playerName
            
            -- Mark as deleted instead of removing from table
            dataTable[entryIndex].deleted = true
            dataTable[entryIndex].deletedTime = time()
            dataTable[entryIndex].lastModified = time()
            
            -- Clear edit mode if we're in it
            if self.editMode then
                self.editMode = false
                self.editIndex = nil
                self.editOriginalData = nil
            end
            
            -- Refresh display
            self:ShowTab(currentTab)
            
            -- Hide add dialog
            if self.addDialog and self.addDialog:IsShown() then
                self.addDialog:Hide()
                -- Reset title back to add mode
                self.addDialog.TitleText:SetText("Add World Buff Entry")
            end
            
            print("World buff entry deleted for " .. playerName)
        end
        
        -- Trigger guild sync
        if ClassicCalendarDataSync then
            ClassicCalendarDataSync:TriggerSync()
        end
    end
end

-- Garbage collection: Remove deleted entries older than specified days
function WorldBuffs:GarbageCollectDeletedEntries(daysToKeep)
    daysToKeep = daysToKeep or 7 -- Default to 7 days
    local cutoffTime = time() - (daysToKeep * 24 * 60 * 60) -- Convert days to seconds
    local totalCleaned = 0
    
    -- Process each data table separately
    local dataTables = {
        REND_HEAD = WorldBuffRendData,
        HAKKAR_HEART = WorldBuffHakkarData,
        ONYXIA_HEAD = WorldBuffOnyxiaData,
        NEFARIAN_HEAD = WorldBuffNefarianData
    }
    
    for itemType, entries in pairs(dataTables) do
        local i = 1
        while i <= #entries do
            local entry = entries[i]
            -- Remove if deleted and older than cutoff time
            if entry.deleted and entry.deletedTime and entry.deletedTime < cutoffTime then
                table.remove(entries, i)
                totalCleaned = totalCleaned + 1
                -- Don't increment i since we removed an element
            else
                i = i + 1
            end
        end
    end
    
    if totalCleaned > 0 then
        print("Cleaned up " .. totalCleaned .. " old deleted world buff entries")
    end
    
    return totalCleaned
end




-- Create calendar controls for date picker popup
function WorldBuffs:CreateDatePickerCalendarControls()
    local calFrame = self.datePickerPopup.calendarFrame
    
    if DEBUG_MODE then
        print("WorldBuffs Debug: CreateDatePickerCalendarControls - calFrame exists:", calFrame ~= nil)
    end
    
    -- Month/Year header
    calFrame.header = calFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    calFrame.header:SetPoint("TOP", calFrame, "TOP", 0, -10)
    calFrame.header:SetTextColor(1, 1, 1)
    calFrame.header:Show()
    
    -- Previous month button
    calFrame.prevButton = CreateFrame("Button", nil, calFrame, "GameMenuButtonTemplate")
    calFrame.prevButton:SetPoint("LEFT", calFrame.header, "LEFT", -40, 0)
    calFrame.prevButton:SetSize(20, 20)
    calFrame.prevButton:SetText("<")
    calFrame.prevButton:SetScript("OnClick", function()
        self:ChangeDatePickerMonth(-1)
    end)
    calFrame.prevButton:Show()
    
    -- Next month button
    calFrame.nextButton = CreateFrame("Button", nil, calFrame, "GameMenuButtonTemplate")
    calFrame.nextButton:SetPoint("RIGHT", calFrame.header, "RIGHT", 40, 0)
    calFrame.nextButton:SetSize(20, 20)
    calFrame.nextButton:SetText(">")
    calFrame.nextButton:SetScript("OnClick", function()
        self:ChangeDatePickerMonth(1)
    end)
    calFrame.nextButton:Show()
    
    -- Apply ClassicCalendar styling to date picker navigation buttons
    self:StyleCalendarButton(calFrame.prevButton, 20)
    self:StyleCalendarButton(calFrame.nextButton, 20)
    
    -- Day of week headers
    local dayHeaders = {"S", "M", "T", "W", "T", "F", "S"}
    calFrame.dayHeaders = {}
    
    -- Calculate starting position to center the 7-day grid
    local gridWidth = 7 * 24 + 6 * 2 -- 7 buttons * 24px + 6 gaps * 2px = 180px
    local startX = (220 - gridWidth) / 2 -- Center within 220px calendar frame
    
    for i = 1, 7 do
        local header = calFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if i == 1 then
            header:SetPoint("TOPLEFT", calFrame, "TOPLEFT", startX + 12, -35) -- +12 to center text in 24px button
        else
            -- Position each header to center over its corresponding button
            -- Button spacing: 24px width + 2px gap = 26px between button centers
            header:SetPoint("TOPLEFT", calFrame, "TOPLEFT", startX + 12 + ((i-1) * 26), -35)
        end
        header:SetText(dayHeaders[i])
        header:SetTextColor(1, 1, 1)
        header:Show()
        calFrame.dayHeaders[i] = header
    end
    
    -- Day buttons (6 rows x 7 columns = 42 buttons)
    calFrame.dayButtons = {}
    for row = 1, 6 do
        calFrame.dayButtons[row] = {}
        for col = 1, 7 do
            local button = CreateFrame("Button", nil, calFrame)
            if row == 1 and col == 1 then
                button:SetPoint("TOPLEFT", calFrame, "TOPLEFT", startX, -50)
            elseif col == 1 then
                button:SetPoint("TOP", calFrame.dayButtons[row-1][1], "BOTTOM", 0, -2)
            else
                button:SetPoint("LEFT", calFrame.dayButtons[row][col-1], "RIGHT", 2, 0)
            end
            button:SetSize(24, 16)
            
            -- Button text
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetPoint("CENTER")
            button.text:SetTextColor(1, 1, 1)
            
            -- Button background
            button.bg = button:CreateTexture(nil, "BACKGROUND")
            button.bg:SetAllPoints()
            button.bg:SetColorTexture(0, 0, 0, 0)
            
            -- Hover effect
            button:SetScript("OnEnter", function()
                button.bg:SetColorTexture(0.3, 0.3, 0.3, 0.5)
            end)
            
            button:SetScript("OnLeave", function()
                if not button.isSelected then
                    button.bg:SetColorTexture(0, 0, 0, 0)
                end
            end)
            
            -- Click handler
            button:SetScript("OnClick", function()
                if button.day and button.day > 0 then
                    self:SelectDatePickerDate(button.day)
                end
            end)
            
            calFrame.dayButtons[row][col] = button
        end
    end
end

-- Change month for date picker calendar
function WorldBuffs:ChangeDatePickerMonth(delta)
    local selectedDate = self.datePickerPopup.selectedDate
    selectedDate.month = selectedDate.month + delta
    
    if selectedDate.month > 12 then
        selectedDate.month = 1
        selectedDate.year = selectedDate.year + 1
    elseif selectedDate.month < 1 then
        selectedDate.month = 12
        selectedDate.year = selectedDate.year - 1
    end
    
    self:UpdateDatePickerCalendar()
end

-- Select a specific date in date picker calendar
function WorldBuffs:SelectDatePickerDate(day)
    local selectedDate = self.datePickerPopup.selectedDate
    selectedDate.day = day
    
    -- Update button text
    local dateStr = string.format("%02d/%02d/%d", selectedDate.month, selectedDate.day, selectedDate.year)
    self.datePickerPopup.dateButton:SetText(dateStr)
    
    -- Update calendar display to show selection
    self:UpdateDatePickerCalendar()
end

-- Update date picker calendar display
function WorldBuffs:UpdateDatePickerCalendar()
    local calFrame = self.datePickerPopup.calendarFrame
    local selectedDate = self.datePickerPopup.selectedDate
    
    if DEBUG_MODE then
        print("WorldBuffs Debug: UpdateDatePickerCalendar called")
        print("WorldBuffs Debug: selectedDate:", selectedDate and string.format("%d/%d/%d", selectedDate.month, selectedDate.day, selectedDate.year) or "nil")
        print("WorldBuffs Debug: calFrame exists:", calFrame ~= nil)
        print("WorldBuffs Debug: dayButtons exists:", calFrame and calFrame.dayButtons ~= nil or false)
    end
    
    -- Month names
    local monthNames = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    }
    
    -- Update header
    calFrame.header:SetText(monthNames[selectedDate.month] .. " " .. selectedDate.year)
    
    -- Get first day of month and number of days
    local daysInMonth = self:GetDaysInMonth(selectedDate.month, selectedDate.year)
    local firstDay = self:GetFirstDayOfWeek(selectedDate.month, selectedDate.year)
    
    -- Clear all buttons first
    for row = 1, 6 do
        for col = 1, 7 do
            local button = calFrame.dayButtons[row][col]
            button.text:SetText("")
            button.day = 0
            button.isSelected = false
            button.bg:SetColorTexture(0, 0, 0, 0)
        end
    end
    
    -- Fill in the days
    local day = 1
    for row = 1, 6 do
        for col = 1, 7 do
            local dayIndex = (row - 1) * 7 + col
            if dayIndex >= firstDay and day <= daysInMonth then
                local button = calFrame.dayButtons[row][col]
                button.text:SetText(tostring(day))
                button.day = day
                
                -- Highlight selected day
                if day == selectedDate.day then
                    button.isSelected = true
                    button.bg:SetColorTexture(0.2, 0.6, 1, 0.5)
                end
                
                day = day + 1
            end
        end
    end
end
