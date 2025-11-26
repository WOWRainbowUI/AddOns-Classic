-- DataSync.lua
-- Guild synchronization system for World Buff data using Ace3

local AddonName, AddonTable = ...

-- Get Ace3 libraries
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

-- Guild sync constants
local SYNC_PREFIX = "CCWB"
local SYNC_VERSION = 1  -- Keep at 1 for backwards compatibility with old versions

-- DataSync module
local DataSync = {}

-- Initialize guild sync system
function DataSync:Initialize()
    -- Register communication prefix
    AceComm:RegisterComm(SYNC_PREFIX, function(prefix, message, distribution, sender)
        self:OnSyncMessage(prefix, message, distribution, sender)
    end)
    
    -- Register events
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("GUILD_ROSTER_UPDATE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            DataSync:RequestGuildSync()
        end
    end)
    
    if DEBUG_MODE then
        print("ClassicCalendar: DataSync initialized")
    end
end

-- Check if player can participate in data sync
-- Allow all guild members to sync data for better availability and redundancy
function DataSync:CanSync()
    return IsInGuild()
end

-- Send sync request to guild members
function DataSync:RequestGuildSync()
    if not self:CanSync() then return end
    
    local message = AceSerializer:Serialize("REQUEST", SYNC_VERSION, time())
    AceComm:SendCommMessage(SYNC_PREFIX, message, "GUILD")
end

-- Send world buff data to guild members (one message per table)
function DataSync:SendGuildSync()
    if not self:CanSync() then return end
    
    local timestamp = time()
    
    -- Send separate message for each buff type to prevent cross-table corruption
    local buffTypes = {
        {name = "REND_HEAD", data = WorldBuffRendData},
        {name = "HAKKAR_HEART", data = WorldBuffHakkarData},
        {name = "ONYXIA_HEAD", data = WorldBuffOnyxiaData},
        {name = "NEFARIAN_HEAD", data = WorldBuffNefarianData}
    }
    
    for _, buffInfo in ipairs(buffTypes) do
        local syncData = {
            version = SYNC_VERSION,
            timestamp = timestamp,
            buffType = buffInfo.name,
            entries = buffInfo.data or {}
        }
        
        local message = AceSerializer:Serialize("SYNC", syncData)
        AceComm:SendCommMessage(SYNC_PREFIX, message, "GUILD")
        
        if DEBUG_MODE then
            print("ClassicCalendar: Synced " .. buffInfo.name .. " data to guild (" .. #syncData.entries .. " entries)")
        end
    end
end

-- Handle incoming sync messages
function DataSync:OnSyncMessage(prefix, message, distribution, sender)
    if not self:CanSync() then return end
    if sender == UnitName("player") then return end -- Don't process our own messages
    
    local success, msgType, data = AceSerializer:Deserialize(message)
    if not success then return end
    
    if msgType == "REQUEST" then
        -- Someone is requesting sync data, send ours
        C_Timer.After(math.random(1, 3), function() -- Random delay to avoid spam
            self:SendGuildSync()
        end)
        
    elseif msgType == "SYNC" then
        -- Received sync data, merge it with ours
        self:MergeGuildSyncData(data, sender)
        
    elseif msgType == "WIPE" then
        -- Officer-initiated guild-wide data wipe
        self:HandleGuildWipe(data, sender)
    end
end

-- Merge incoming guild sync data (single table per message)
function DataSync:MergeGuildSyncData(syncData, sender)
    if not syncData or not syncData.buffType or not syncData.entries then return end
    if syncData.version ~= SYNC_VERSION then return end
    
    local hasChanges = false
    local buffType = syncData.buffType
    local entries = syncData.entries
    
    -- Get the correct table for this buff type
    local buffDataTable
    
    -- Safety check - use direct table access if WorldBuffs isn't available yet
    if WorldBuffs and WorldBuffs.GetWorldBuffDataTable then
        local success, result = pcall(WorldBuffs.GetWorldBuffDataTable, WorldBuffs, buffType)
        if success then
            buffDataTable = result
        end
    else
        -- Direct table access fallback
        if buffType == "REND_HEAD" then
            WorldBuffRendData = WorldBuffRendData or {}
            buffDataTable = WorldBuffRendData
        elseif buffType == "HAKKAR_HEART" then
            WorldBuffHakkarData = WorldBuffHakkarData or {}
            buffDataTable = WorldBuffHakkarData
        elseif buffType == "ONYXIA_HEAD" then
            WorldBuffOnyxiaData = WorldBuffOnyxiaData or {}
            buffDataTable = WorldBuffOnyxiaData
        elseif buffType == "NEFARIAN_HEAD" then
            WorldBuffNefarianData = WorldBuffNefarianData or {}
            buffDataTable = WorldBuffNefarianData
        end
    end
    
    if not buffDataTable then
        if DEBUG_MODE then
            print("ClassicCalendar: Unknown buff type in sync data:", buffType)
        end
        return
    end
    
    -- Merge entries based on player name, using timestamps to resolve conflicts
    for _, entry in ipairs(entries) do
        local shouldProcess = true
        
        -- Sanitize incoming entry to prevent corruption
        if not WorldBuffs or not WorldBuffs.SanitizeEntry then
            if DEBUG_MODE then
                print("ClassicCalendar: WorldBuffs not ready, skipping sync entry")
            end
            shouldProcess = false
        end
        
        if shouldProcess then
            local cleanEntry = WorldBuffs:SanitizeEntry(entry)
            
            if not cleanEntry then
                -- Entry is too corrupted, skip it and log in debug mode
                if DEBUG_MODE then
                    local playerName = entry.playerName or "unknown"
                    print("ClassicCalendar: Rejected corrupted sync entry for " .. buffType .. ": " .. tostring(playerName))
                end
                shouldProcess = false
            end
            
            -- Additional validation: ensure entry has required fields after sanitization
            if shouldProcess and cleanEntry and (not cleanEntry.playerName or not cleanEntry.lastModified) then
                if DEBUG_MODE then
                    print("ClassicCalendar: Rejected sync entry for " .. buffType .. " missing required fields")
                end
                shouldProcess = false
            end
            
            if shouldProcess and cleanEntry then
                local foundIndex = nil
                for i, ourEntry in ipairs(buffDataTable) do
                    if ourEntry.playerName == cleanEntry.playerName then
                        foundIndex = i
                        break
                    end
                end
                
                if foundIndex then
                    -- Player exists, check timestamps to see if we should update
                    local ourTimestamp = buffDataTable[foundIndex].lastModified or 0
                    local entryTimestamp = cleanEntry.lastModified or 0
                    
                    if entryTimestamp > ourTimestamp then
                        -- Incoming entry is newer, replace our entry with clean copy
                        buffDataTable[foundIndex] = cleanEntry
                        hasChanges = true
                        if DEBUG_MODE then
                            print("ClassicCalendar: Updated " .. buffType .. " entry for " .. cleanEntry.playerName)
                        end
                    end
                else
                    -- New player, add the clean entry
                    table.insert(buffDataTable, cleanEntry)
                    hasChanges = true
                    if DEBUG_MODE then
                        print("ClassicCalendar: Added new " .. buffType .. " entry for " .. cleanEntry.playerName)
                    end
                end
            end
        end
    end
    
    if hasChanges then
        -- Run cleanup to catch any corruption that slipped through
        if WorldBuffs and WorldBuffs.CleanupCorruptedData then
            WorldBuffs:CleanupCorruptedData()
        end
        
        -- Refresh display if WorldBuffs frame is available and shown
        if WorldBuffFrame and WorldBuffFrame:IsShown() and WorldBuffs then
            local currentTab = nil
            if WorldBuffFrame.selectedTab and WorldBuffFrame.tabs[WorldBuffFrame.selectedTab] then
                currentTab = WorldBuffFrame.tabs[WorldBuffFrame.selectedTab].itemType
            end
            if currentTab then
                WorldBuffs:ShowTab(currentTab)
            end
        end
        
        if DEBUG_MODE then
            print("ClassicCalendar: Received world buff updates from " .. sender)
        end
    end
end

-- Handle guild-wide wipe command (officer only)
function DataSync:HandleGuildWipe(data, sender)
    if not data or not data.timestamp then return end
    
    -- Verify sender is an officer
    local guildName, guildRankName, guildRankIndex = GetGuildInfo(sender)
    if not guildRankIndex or guildRankIndex > 2 then
        print("ClassicCalendar: Ignoring wipe command from non-officer: " .. sender)
        return
    end
    
    -- Wipe all tables
    WorldBuffRendData = {}
    WorldBuffHakkarData = {}
    WorldBuffOnyxiaData = {}
    WorldBuffNefarianData = {}
    
    print("ClassicCalendar: Guild officer " .. sender .. " wiped all WorldBuff data")
    
    -- Refresh display if open
    if WorldBuffFrame and WorldBuffFrame:IsShown() and WorldBuffs then
        local currentTab = nil
        if WorldBuffFrame.selectedTab and WorldBuffFrame.tabs[WorldBuffFrame.selectedTab] then
            currentTab = WorldBuffFrame.tabs[WorldBuffFrame.selectedTab].itemType
        end
        if currentTab then
            WorldBuffs:ShowTab(currentTab)
        end
    end
end

-- Send guild-wide wipe command (officer only)
function DataSync:SendGuildWipe()
    if not self:CanSync() then return end
    
    -- Check if player is an officer
    local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
    if not guildRankIndex or guildRankIndex > 2 then
        print("ClassicCalendar: Only guild officers can wipe WorldBuff data")
        return
    end
    
    -- Wipe locally first
    WorldBuffRendData = {}
    WorldBuffHakkarData = {}
    WorldBuffOnyxiaData = {}
    WorldBuffNefarianData = {}
    
    -- Send WIPE message to guild
    local wipeData = {
        timestamp = time()
    }
    local wipeMessage = AceSerializer:Serialize("WIPE", wipeData)
    AceComm:SendCommMessage(SYNC_PREFIX, wipeMessage, "GUILD")
    
    print("ClassicCalendar: Guild-wide WorldBuff data wipe sent")
    print("Note: Only affects guild members with updated addon version")
    
    -- Refresh display if open
    if WorldBuffFrame and WorldBuffFrame:IsShown() and WorldBuffs then
        local currentTab = nil
        if WorldBuffFrame.selectedTab and WorldBuffFrame.tabs[WorldBuffFrame.selectedTab] then
            currentTab = WorldBuffFrame.tabs[WorldBuffFrame.selectedTab].itemType
        end
        if currentTab then
            WorldBuffs:ShowTab(currentTab)
        end
    end
end

-- Public API for triggering sync after data changes
function DataSync:TriggerSync()
    if not self:CanSync() then return end
    
    C_Timer.After(1, function()
        self:SendGuildSync()
    end)
end

-- Make DataSync globally accessible
_G.ClassicCalendarDataSync = DataSync