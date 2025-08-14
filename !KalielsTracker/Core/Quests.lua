--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local _, KT = ...

local questsCache = {}

local function QuestCache_CreateRecord(info, headerTitle, prevRecord)
    return {
        title = info.title,
        level = info.level,
        zone = headerTitle,
        startMapID = prevRecord and prevRecord.startMapID or 0,
        state = prevRecord and prevRecord.state or ""
    }
end

function KT.QuestsCache_Rebuild(isForced, isHard)
    ExpandQuestHeader(0)
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local headerTitle
    local validIDs = {}

    for i = 1, numEntries do
        local questInfo = C_QuestLog.GetInfo(i)
        if not questInfo.isHidden then
            if questInfo.isHeader then
                headerTitle = questInfo.title
            else
                if not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) then
                    if not questsCache[questInfo.questID] or isForced then
                        questsCache[questInfo.questID] = QuestCache_CreateRecord(questInfo, headerTitle, not isHard and questsCache[questInfo.questID])
                    end
                    validIDs[questInfo.questID] = true
                end
            end
        end
    end

    for questID in pairs(questsCache) do
        if not validIDs[questID] then
            questsCache[questID] = nil
        end
    end
end

function KT.QuestsCache_AddUpdateQuest(questID)
    ExpandQuestHeader(0)
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local headerTitle

    for i = 1, numEntries do
        local questInfo = C_QuestLog.GetInfo(i)
        if not questInfo.isHidden then
            if questInfo.isHeader then
                headerTitle = questInfo.title
            elseif questInfo.questID == questID then
                if not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) then
                    questsCache[questID] = QuestCache_CreateRecord(questInfo, headerTitle, questsCache[questID])
                    break
                end
            end
        end
    end

    local record = questsCache[questID]
    if record and record.startMapID == 0 then
        record.startMapID = C_Map.GetBestMapForUnit("player") or 0
    end
end

function KT.QuestsCache_RemoveQuest(questID)
    questsCache[questID] = nil
end

function KT.QuestsCache_GetInfo(questID)
    return questsCache[questID]
end

function KT.QuestsCache_GetProperty(questID, key)
    local quest = questsCache[questID]
    return quest and quest[key]
end

function KT.QuestsCache_SetProperty(questID, key, value)
    local result = false
    local quest = questsCache[questID]
    if quest and quest[key] ~= nil then
        quest[key] = value
        result = true
    end
    return result
end

function KT.QuestsCache_Init(storage)
    if storage then
        questsCache = storage
    end

    KT:RegEvent("QUEST_LOG_UPDATE", function(eventID)
        local numEntries = C_QuestLog.GetNumQuestLogEntries()
        if numEntries > 1 then
            KT.QuestsCache_Rebuild(true)
            KT:UnregEvent(eventID)
        end
    end)
end