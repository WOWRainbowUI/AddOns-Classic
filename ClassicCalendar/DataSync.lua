-- DataSync.lua
-- Guild synchronization system for World Buff data using Ace3

local AddonName, AddonTable = ...

-- Get Ace3 libraries
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

-- Guild sync constants
local SYNC_PREFIX = "CCWB"
local SYNC_VERSION = 1

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

-- Send world buff data to guild members
function DataSync:SendGuildSync()
    if not self:CanSync() then return end
    
    local syncData = {
        version = SYNC_VERSION,
        timestamp = time(),
        data = WorldBuffData
    }
    
    local message = AceSerializer:Serialize("SYNC", syncData)
    AceComm:SendCommMessage(SYNC_PREFIX, message, "GUILD")
    
    if DEBUG_MODE then
        print("ClassicCalendar: World buff data synced to guild members")
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
    end
end

-- Merge incoming guild sync data
function DataSync:MergeGuildSyncData(syncData, sender)
    if not syncData or not syncData.data then return end
    if syncData.version ~= SYNC_VERSION then return end
    
    local hasChanges = false
    
    -- Merge each buff type
    for buffType, entries in pairs(syncData.data) do
        if not WorldBuffData[buffType] then
            WorldBuffData[buffType] = {}
        end
        
        -- Merge entries based on player name, using timestamps to resolve conflicts
        for _, entry in ipairs(entries) do
            local foundIndex = nil
            for i, ourEntry in ipairs(WorldBuffData[buffType]) do
                if ourEntry.playerName == entry.playerName then
                    foundIndex = i
                    break
                end
            end
            
            if foundIndex then
                -- Player exists, check timestamps to see if we should update
                local ourTimestamp = WorldBuffData[buffType][foundIndex].lastModified or 0
                local entryTimestamp = entry.lastModified or 0
                
                if entryTimestamp > ourTimestamp then
                    -- Incoming entry is newer, replace our entry
                    WorldBuffData[buffType][foundIndex] = entry
                    hasChanges = true
                end
            else
                -- New player, add the entry
                table.insert(WorldBuffData[buffType], entry)
                hasChanges = true
            end
        end
    end
    
    if hasChanges then
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

-- Public API for triggering sync after data changes
function DataSync:TriggerSync()
    if not self:CanSync() then return end
    
    C_Timer.After(1, function()
        self:SendGuildSync()
    end)
end

-- Make DataSync globally accessible
_G.ClassicCalendarDataSync = DataSync