---@class MapIconTooltip
local MapIconTooltip = QuestieLoader:CreateModule("MapIconTooltip");
local _MapIconTooltip = {}
local tinsert = table.insert;

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestXP
local QuestXP = QuestieLoader:ImportModule("QuestXP")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local GetCoinTextureString = C_CurrencyInfo.GetCoinTextureString or GetCoinTextureString


local REPUTATION_ICON_PATH = QuestieLib.AddonPath .. "Icons\\reputation.blp"
local REPUTATION_ICON_TEXTURE = "|T" .. REPUTATION_ICON_PATH .. ":14:14:2:0|t"

local TRANSPARENT_ICON_PATH = "Interface\\Minimap\\UI-bonusobjectiveblob-inside.blp"
local TRANSPARENT_ICON_TEXTURE = "|T" .. TRANSPARENT_ICON_PATH .. ":14:14:2:0|t"

local DEFAULT_WAYPOINT_HOVER_COLOR = { 0.93, 0.46, 0.13, 0.8 }

local lastTooltipShowTimestamp = GetTime()

function MapIconTooltip:Show()
    local _, _, _, alpha = self.texture:GetVertexColor();
    if alpha == 0 then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[MapIconTooltip:Show] Alpha of texture is 0, nothing to show")
        return
    end
    if GetTime() - lastTooltipShowTimestamp < 0.05 and GameTooltip:IsShown() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[MapIconTooltip:Show] Call has been too fast, not showing again")
        return
    end
    lastTooltipShowTimestamp = GetTime()

    local Tooltip = GameTooltip;
    Tooltip._owner = self;
    Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

    local maxDistCluster = 1
    local mapId = WorldMapFrame:GetMapID();

    if C_Map and C_Map.GetMapInfo then
        local mapInfo = C_Map.GetMapInfo(mapId)
        if mapInfo then
            if (mapInfo.mapType == 0 or mapInfo.mapType == 1) then -- Cosmic or World
                maxDistCluster = 6
            elseif mapInfo.mapType == 2 then                       -- Continent
                maxDistCluster = 4
            end
        end
    end

    if self.miniMapIcon then
        if _MapIconTooltip:IsMinimapInside() then
            maxDistCluster = 0.3 / (1 + Minimap:GetZoom())
        else
            maxDistCluster = 0.5 / (1 + Minimap:GetZoom())
        end
    end

    local r, g, b, a = unpack(QuestieMap.zoneWaypointHoverColorOverrides[self.AreaID] or DEFAULT_WAYPOINT_HOVER_COLOR)
    --Highlight waypoints if they exist.
    for _, lineFrame in pairs(self.data.lineFrames or {}) do
        lineFrame.line:SetColorTexture(r, g, b, a)
    end

    -- FIXME: `data` can be nil here which leads to an error, will have to debug:
    -- https://discordapp.com/channels/263036731165638656/263040777658171392/627808795715960842
    -- happens when a note doesn't get removed after a quest has been finished, see #1170
    -- TODO: change how the logic works, so this [ObjectiveIndex?] can be nil
    -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an number here for duplicate checks
    if not self.data.ObjectiveIndex then
        self.data.ObjectiveIndex = 0
    end

    --for k,v in pairs(self.data.tooltip) do
    --Tooltip:AddLine(v);
    --end

    local usedText = {}
    local npcAndObjectOrder = {};
    local questOrder = {};
    local manualOrder = {}

    self.data.touchedPins = {}
    ---@param icon IconFrame
    local function handleMapIcon(icon)
        local iconData = icon.data

        if not iconData then
            Questie:Error("[MapIconTooltip:Show] handleMapIcon - iconData is nil! self.data.Id =", self.data.Id, "- Aborting!")
            return
        end

        -- Do not recolor MiniMap, Available and Completed Quest Icons.
        if (not icon.miniMapIcon) and not (iconData.Type == "available" or iconData.Type == "complete") and self.data.Id == iconData.Id then -- Recolor hovered icons
            local entry = {}
            entry.color = { icon.texture.r, icon.texture.g, icon.texture.b, icon.texture.a };
            entry.icon = icon;
            if Questie.db.profile.questObjectiveColors then
                icon.texture:SetVertexColor(1, 1, 1, 1);   -- If different colors are active simply change it to the regular icon color
            else
                icon.texture:SetVertexColor(0.6, 1, 1, 1); -- Without colors make it blueish
            end
            tinsert(self.data.touchedPins, entry);
        end
        if icon.x and icon.AreaID == self.AreaID then
            local dist = QuestieLib:Maxdist(icon.x, icon.y, self.x, self.y);
            if dist < maxDistCluster then
                if iconData.Type == "available" or iconData.Type == "complete" then
                    if not npcAndObjectOrder[iconData.Name] then
                        npcAndObjectOrder[iconData.Name] = {};
                    end

                    local tip = _MapIconTooltip:GetAvailableOrCompleteTooltip(icon)
                    npcAndObjectOrder[iconData.Name][tip.title] = tip
                elseif iconData.ObjectiveData and iconData.ObjectiveData.Description then
                    local key = iconData.Id
                    if not questOrder[key] then
                        questOrder[key] = {};
                    end

                    local orderedTooltips = {}
                    iconData.ObjectiveData:Update()
                    if iconData.Type == "event" then
                        local tip = _MapIconTooltip:GetEventObjectiveTooltip(icon.data)

                        -- We need to check for duplicates.
                        local add = true;
                        for _, data in pairs(questOrder[key]) do
                            for text, _ in pairs(data) do
                                if (text == iconData.ObjectiveData.Description) then
                                    add = false;
                                    break;
                                end
                            end
                        end
                        if add then
                            questOrder[key] = tip
                        end
                    else
                        local tooltips = _MapIconTooltip:GetObjectiveTooltip(icon)
                        for _, tip in pairs(tooltips) do
                            tinsert(orderedTooltips, 1, tip);
                        end
                        for _, tip in pairs(orderedTooltips) do
                            local quest = questOrder[key]
                            _MapIconTooltip:AddTooltipsForQuest(icon, tip, quest, usedText)
                        end
                    end
                elseif iconData.CustomTooltipData then
                    questOrder[iconData.CustomTooltipData.Title] = {}
                    tinsert(questOrder[iconData.CustomTooltipData.Title], iconData.CustomTooltipData.Body);
                elseif iconData.ManualTooltipData then
                    manualOrder[iconData.ManualTooltipData.Title] = iconData.ManualTooltipData
                end
            end
        end
    end

    if self.miniMapIcon then
        for icon, _ in pairs(HBDPins.activeMinimapPins) do
            handleMapIcon(icon)
        end
    else
        for pin in HBDPins.worldmapProvider:GetMap():EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
            handleMapIcon(pin.icon)
        end
    end

    Tooltip.npcAndObjectOrder = npcAndObjectOrder
    Tooltip.questOrder = questOrder
    Tooltip.manualOrder = manualOrder
    Tooltip.miniMapIcon = self.miniMapIcon
    Tooltip._Rebuild = function(self)
        -- generate the tooltips
        local xpString = l10n('xp');
        local shift = IsShiftKeyDown()
        local haveGiver = false -- hack
        local firstLine = true;
        local playerIsHuman = QuestiePlayer.HasRequiredRace(QuestieDB.raceKeys.HUMAN)
        local playerIsHonoredWithShaTar = (not QuestieReputation:HasReputation(nil, { 935, 8999 }))

        -- tooltips for quest icons on the map
        for npcOrObjectName, quests in pairs(self.npcAndObjectOrder) do -- this logic really needs to be improved
            haveGiver = true
            if shift and (not firstLine) then
                -- Spacer between NPCs
                self:AddLine("             ")
            end
            if (firstLine and not shift) then
                self:AddDoubleLine(npcOrObjectName, "(" .. l10n('Hold Shift') .. ")", 0.2, 1, 0.2, 0.43, 0.43, 0.43);
                firstLine = false;
            elseif (firstLine and shift) then
                self:AddLine(npcOrObjectName, 0.2, 1, 0.2);
                firstLine = false;
            else
                self:AddLine(npcOrObjectName, 0.2, 1, 0.2);
            end

            for _, questData in pairs(quests) do
                local reputationReward = QuestieReputation.GetReputationReward(questData.questId)

                if questData.title ~= nil then
                    local quest = QuestieDB.GetQuest(questData.questId)
                    local rewardString = ""
                    if (quest and shift) then
                        local xpReward = QuestXP:GetQuestLogRewardXP(questData.questId, Questie.db.profile.showQuestXpAtMaxLevel)
                        if xpReward > 0 then
                            rewardString = QuestieLib:PrintDifficultyColor(quest.level, "(" .. FormatLargeNumber(xpReward) .. xpString .. ") ", QuestieDB.IsRepeatable(questData.questId), QuestieDB.IsActiveEventQuest(questData.questId), QuestieDB.IsPvPQuest(questData.questId))
                        end

                        local moneyReward = QuestXP.GetQuestRewardMoney(questData.questId)
                        if moneyReward > 0 then
                            rewardString = rewardString .. Questie:Colorize("(" .. GetCoinTextureString(moneyReward) .. ") ", "white")
                        end
                    end
                    rewardString = rewardString .. questData.type

                    if (not shift) and next(reputationReward) then
                        self:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
                    else
                        if shift then
                            self:AddDoubleLine(questData.title, rewardString, 1, 1, 1, 1, 1, 0);
                        else
                            -- We use a transparent icon because this eases setting the correct margin
                            self:AddDoubleLine(TRANSPARENT_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
                        end
                    end
                end
                if questData.subData and shift then
                    local dataType = type(questData.subData)
                    if dataType == "table" then
                        for _, rawLine in pairs(questData.subData) do
                            local lines = QuestieLib:TextWrap(rawLine, "  ", false, math.max(375, Tooltip:GetWidth()), questData.questId) --275 is the default questlog width
                            for _, line in pairs(lines) do
                                self:AddLine(line, 0.86, 0.86, 0.86);
                            end
                        end
                    elseif dataType == "string" then
                        local lines = QuestieLib:TextWrap(questData.subData, "  ", false, math.max(375, Tooltip:GetWidth())) --275 is the default questlog width
                        for _, line in pairs(lines) do
                            self:AddLine(line, 0.86, 0.86, 0.86);
                        end
                    end
                end

                if Questie.db.profile.enableTooltipsNextInChain then
                    local nextQuestInChain = QuestieDB.QueryQuestSingle(questData.questId, "nextQuestInChain")
                    if shift and nextQuestInChain > 0 and (not Questie.db.char.hidden[nextQuestInChain]) then
                        -- add quest chain info
                        local nextQuest = QuestieDB.GetQuest(nextQuestInChain)
                        local firstInChain = true;
                        while nextQuest ~= nil and (not Questie.db.char.hidden[nextQuest.Id]) do

                            local nextQuestTitleString;
                            local nextQuestXpRewardString = "";
                            local nextQuestMoneyRewardString = "";
                            local nextQuestIdString = "";
                            local nextQuestTagString = "";
                            if firstInChain then
                                self:AddLine("  |TInterface\\Addons\\Questie\\Icons\\nextquest.blp:16|t " .. l10n("Next in chain:"), 0.86, 0.86, 0.86)
                                firstInChain = false
                            end

                            if Questie.db.profile.enableTooltipsQuestLevel then
                                nextQuestTitleString = string.format("%s", QuestieLib:GetLevelString(nextQuest.Id, nextQuest.level, true) .. nextQuest.name)
                            else
                                nextQuestTitleString = string.format("%s", nextQuest.name)
                            end

                            if Questie.db.profile.enableTooltipsQuestID then
                                nextQuestIdString = string.format(" (%d)", nextQuest.Id)
                            end

                            local nextQuestXpReward = QuestXP:GetQuestLogRewardXP(nextQuest.Id, Questie.db.profile.showQuestXpAtMaxLevel)
                            if nextQuestXpReward > 0 then
                                nextQuestXpRewardString = string.format(" (%s%s)", FormatLargeNumber(nextQuestXpReward), xpString)
                            end

                            local nextQuestMoneyReward = QuestXP:GetQuestRewardMoney(nextQuest.Id);
                            if nextQuestMoneyReward > 0 then
                                nextQuestMoneyRewardString = Questie:Colorize(string.format(" (%s)", GetCoinTextureString(nextQuestMoneyReward)), "white")
                            end

                            if (QuestieDB.IsGroupQuest(nextQuest.Id) or QuestieDB.IsDungeonQuest(nextQuest.Id) or QuestieDB.IsRaidQuest(nextQuest.Id)) then
                                local _, nextQuestTag = QuestieDB.GetQuestTagInfo(nextQuest.Id)
                                nextQuestTagString = Questie:Colorize(string.format(" (%s)", nextQuestTag))
                            end

                            local nextQuestString = string.format("      %s%s%s%s%s", nextQuestTitleString, nextQuestIdString, nextQuestXpRewardString, nextQuestMoneyRewardString, nextQuestTagString) -- we need an offset to align with description
                            self:AddLine(QuestieLib:PrintDifficultyColor(nextQuest.level, nextQuestString, QuestieDB.IsRepeatable(nextQuest.Id), QuestieDB.IsActiveEventQuest(nextQuest.Id), QuestieDB.IsPvPQuest(nextQuest.Id)), 1, 1, 1)
                            if nextQuest.nextQuestInChain > 0 then
                                nextQuest = QuestieDB.GetQuest(nextQuest.nextQuestInChain)
                            else
                                break
                            end
                        end
                    end
                end

                if shift and next(reputationReward) then
                    local rewardTable = {}
                    local factionId, factionName
                    local rewardValue
                    local aldorPenalty, scryersPenalty
                    for _, rewardPair in pairs(reputationReward) do
                        factionId = rewardPair[1]

                        if factionId == 935 and playerIsHonoredWithShaTar and (scryersPenalty or aldorPenalty) then
                            -- Quests for Aldor and Scryers gives reputation to the Sha'tar but only before being Honored
                            -- with the Sha'tar
                            break
                        end

                        factionName = select(1, GetFactionInfoByID(factionId))
                        if factionName then
                            rewardValue = rewardPair[2]

                            if playerIsHuman and rewardValue > 0 then
                                -- Humans get 10% more reputation
                                rewardValue = math.floor(rewardValue * 1.1)
                            end

                            if factionId == 932 then     -- Aldor
                                scryersPenalty = 0 - math.floor(rewardValue * 1.1)
                            elseif factionId == 934 then -- Scryers
                                aldorPenalty = 0 - math.floor(rewardValue * 1.1)
                            end

                            rewardTable[#rewardTable + 1] = (rewardValue > 0 and "+" or "") .. rewardValue .. " " .. factionName
                        end
                    end

                    if aldorPenalty then
                        factionName = select(1, GetFactionInfoByID(932))
                        rewardTable[#rewardTable + 1] = aldorPenalty .. " " .. factionName
                    elseif scryersPenalty then
                        factionName = select(1, GetFactionInfoByID(934))
                        rewardTable[#rewardTable + 1] = scryersPenalty .. " " .. factionName
                    end

                    self:AddLine(REPUTATION_ICON_TEXTURE .. " " .. Questie:Colorize(table.concat(rewardTable, " / "), "reputationBlue"), 1, 1, 1, 1, 1, 0)
                end
            end
        end

        -- tooltips for objectives of active quests
        ---@param questId number
        for questId, textList in pairs(self.questOrder) do -- this logic really needs to be improved
            ---@type Quest
            local quest = QuestieDB.GetQuest(questId);
            local questTitle = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, true, true);
            local xpReward = QuestXP:GetQuestLogRewardXP(questId, Questie.db.profile.showQuestXpAtMaxLevel);
            r, g, b = QuestieLib:GetDifficultyColorPercent(quest.level);
            if haveGiver then
                if shift and xpReward then
                    self:AddLine(" ");
                    self:AddDoubleLine(questTitle, "(" .. FormatLargeNumber(xpReward) .. xpString .. ") (" .. l10n("Active") .. ")", 0.2, 1, 0.2, 1, 1, 0);
                    haveGiver = false -- looks better when only the first one shows (active)
                else
                    self:AddLine(" ");
                    self:AddDoubleLine(questTitle, "(" .. l10n("Active") .. ")", 1, 1, 1, 1, 1, 0);
                    haveGiver = false -- looks better when only the first one shows (active)
                end
            else
                if (quest and shift and xpReward > 0) then
                    self:AddDoubleLine(questTitle, "(" .. FormatLargeNumber(xpReward) .. xpString .. ")", 0.2, 1, 0.2, r, g, b);
                    firstLine = false;
                elseif (firstLine and not shift) then
                    self:AddDoubleLine(questTitle, "(" .. l10n('Hold Shift') .. ")", 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
                    firstLine = false;
                else
                    self:AddLine(questTitle);
                end
            end

            local function _GetLevelString(creatureLevels, name)
                local levelString = name
                if creatureLevels[name] then
                    local minLevel = creatureLevels[name][1]
                    local maxLevel = creatureLevels[name][2]
                    local rank = creatureLevels[name][3]
                    if minLevel == maxLevel then
                        levelString = name .. " (" .. minLevel
                    else
                        levelString = name .. " (" .. minLevel .. "-" .. maxLevel
                    end

                    if rank and rank == 1 then
                        levelString = levelString .. "+"
                    end

                    levelString = levelString .. ")"
                end
                return levelString
            end

            -- Used to get the white color for the quests which don't have anything to collect
            local defaultQuestColor = QuestieLib:GetRGBForObjective({})
            if shift then
                local creatureLevels = QuestieDB:GetCreatureLevels(quest) -- Data for min and max level
                local addedCreatureNames = {}
                for _, textData in pairs(textList) do
                    for textLine, nameData in pairs(textData) do
                        local dataType = type(nameData)
                        if dataType == "table" then
                            for name in pairs(nameData) do
                                if (not addedCreatureNames[name]) then
                                    addedCreatureNames[name] = true
                                    name = _GetLevelString(creatureLevels, name)
                                    self:AddLine("   |cFFDDDDDD" .. name);
                                end
                            end
                        elseif dataType == "string" and (not addedCreatureNames[nameData]) then
                            addedCreatureNames[nameData] = true
                            nameData = _GetLevelString(creatureLevels, nameData)
                            self:AddLine("   |cFFDDDDDD" .. nameData);
                        end
                        self:AddLine("      " .. defaultQuestColor .. textLine);
                    end
                end
            else
                for _, textData in pairs(textList) do
                    for textLine, _ in pairs(textData) do
                        self:AddLine("   " .. defaultQuestColor .. textLine);
                    end
                end
            end
        end

        if next(self.npcAndObjectOrder) and next(self.manualOrder) then
            -- Spacer before townsfolk
            self:AddLine("             ")
        end

        for title, data in pairs(self.manualOrder) do
            local body = data.Body
            self:AddLine(title)
            for _, stringOrTable in ipairs(body) do
                local dataType = type(stringOrTable)
                if dataType == "string" then
                    self:AddLine(stringOrTable)
                elseif dataType == "table" then
                    self:AddDoubleLine(stringOrTable[1], '|cFFffffff' .. stringOrTable[2] .. '|r') --normal, white
                end
            end
            if self.miniMapIcon == false and not data.disableShiftToRemove then
                self:AddLine('|cFFa6a6a6Shift-click to hide|r') -- grey
            end
        end
    end
    Tooltip:_Rebuild() -- we separate this so things like MODIFIER_STATE_CHANGED can redraw the tooltip
    Tooltip:SetFrameStrata("TOOLTIP");
    Tooltip.ShownAsMapIcon = true
    Tooltip:Show();
end

local isLastMinimapInside, lastMinimapInsideCheckTimestamp

function _MapIconTooltip:IsMinimapInside()
    if lastMinimapInsideCheckTimestamp and GetTime() - lastMinimapInsideCheckTimestamp < 1 then
        return isLastMinimapInside
    end
    local tempzoom = 0;
    if (GetCVar("minimapZoom") == GetCVar("minimapInsideZoom")) then
        if (GetCVar("minimapInsideZoom") + 0 >= 3) then
            Minimap:SetZoom(Minimap:GetZoom() - 1);
            tempzoom = 1;
        else
            Minimap:SetZoom(Minimap:GetZoom() + 1);
            tempzoom = -1;
        end
    end
    if (GetCVar("minimapInsideZoom") + 0 == Minimap:GetZoom()) then
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        isLastMinimapInside = true
        lastMinimapInsideCheckTimestamp = GetTime()
        return true
    else
        isLastMinimapInside = false
        lastMinimapInsideCheckTimestamp = GetTime()
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        return false
    end
end

--- Get the quest tag to display in the tooltip
---@param quest Quest
---@return string tag
local function _GetQuestTag(quest)
    if quest.Type == "complete" then
        return "(" .. l10n("Complete") .. ")";
    else
        local questType, questTag = QuestieDB.GetQuestTagInfo(quest.Id)

        if (QuestieEvent and QuestieEvent.activeQuests[quest.Id]) then
            return "(" .. l10n("Event") .. ")";
        elseif (questType == 41) then
            return "(" .. l10n("PvP") .. ")";
        elseif (QuestieDB.IsWeeklyQuest(quest.Id)) then
            return "(" .. (WEEKLY or l10n("Weekly")) .. ")";
        elseif (QuestieDB.IsDailyQuest(quest.Id)) then
            return "(" .. (DAILY or l10n("Daily")) .. ")";
        elseif (QuestieDB.IsRepeatable(quest.Id)) then
            return "(" .. l10n("Repeatable") .. ")";
        elseif (questType == 81 or questType == 83 or questType == 62 or questType == 1) then
            -- Dungeon or Legendary or Raid or Group(Elite)
            return "(" .. questTag .. ")";
        elseif (Questie.IsSoD and QuestieDB.IsSoDRuneQuest(quest.Id)) then
            return "(" .. l10n("Rune") .. ")";
        else
            return "(" .. l10n("Available") .. ")";
        end
    end
end

function _MapIconTooltip:GetAvailableOrCompleteTooltip(icon)
    local tip = {};
    tip.type = _GetQuestTag(icon.data)
    tip.title = QuestieLib:GetColoredQuestName(icon.data.Id, Questie.db.profile.enableTooltipsQuestLevel, false, true)
    tip.subData = icon.data.QuestData.Description
    tip.questId = icon.data.Id;

    return tip
end

function _MapIconTooltip:GetEventObjectiveTooltip(iconData)
    if iconData.Name then
        return {
            [iconData.ObjectiveData.Index] = {
                [iconData.ObjectiveData.Description] = {
                    [iconData.Name] = true
                }
            }
        }
    else
        return {
            [iconData.ObjectiveData.Index] = {
                [iconData.ObjectiveData.Description] = true
            }
        }
    end
end

function _MapIconTooltip:GetObjectiveTooltip(icon)
    local tooltips = {}
    local iconData = icon.data
    local text = iconData.ObjectiveData.Description
    local color = QuestieLib:GetRGBForObjective(iconData.ObjectiveData)
    if iconData.ObjectiveData.Needed then
        if iconData.ObjectiveData.Type == "spell" and iconData.ObjectiveData.spawnList[iconData.ObjectiveTargetId].ItemId then
            text = color .. tostring(QuestieDB.QueryItemSingle(iconData.ObjectiveData.spawnList[iconData.ObjectiveTargetId].ItemId, "name"))
        else
            text = color .. tostring(iconData.ObjectiveData.Collected) .. "/" .. tostring(iconData.ObjectiveData.Needed) .. " " .. text
        end
    end
    if QuestieComms then
        local anotherPlayer = false;
        local quest = QuestieComms:GetQuest(iconData.Id)
        if quest then
            for playerName, objectiveData in pairs(quest) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName)
                local playerColor
                local playerType = ""
                if playerInfo then
                    playerColor = "|c" .. playerInfo.colorHex
                else
                    playerColor = QuestieComms.remotePlayerClasses[playerName]
                    if playerColor then
                        playerColor = Questie:GetClassColor(playerColor)
                        playerType = " (" .. l10n("Nearby") .. ")"
                    end
                end
                if playerColor then
                    local objectiveEntry = objectiveData[iconData.ObjectiveIndex]
                    if not objectiveEntry then
                        Questie:Debug(Questie.DEBUG_DEVELOP, "[_MapIconTooltip:GetObjectiveTooltip] No objective data for quest", quest.Id)
                        objectiveEntry = {} -- This will make "GetRGBForObjective" return default color
                    end
                    local remoteColor = QuestieLib:GetRGBForObjective(objectiveEntry)
                    local colorizedPlayerName = " (" .. playerColor .. playerName .. "|r" .. remoteColor .. ")|r" .. playerType
                    local remoteText = iconData.ObjectiveData.Description

                    if objectiveEntry and objectiveEntry.fulfilled and objectiveEntry.required then
                        local fulfilled = objectiveEntry.fulfilled;
                        local required = objectiveEntry.required;
                        remoteText = remoteColor .. tostring(fulfilled) .. "/" .. tostring(required) .. " " .. remoteText .. colorizedPlayerName;
                    else
                        remoteText = remoteColor .. remoteText .. colorizedPlayerName;
                    end
                    local partyMemberTip = {
                        [remoteText] = {},
                    }
                    if iconData.Name then
                        partyMemberTip[remoteText][iconData.Name] = true;
                    end
                    tinsert(tooltips, partyMemberTip);
                    anotherPlayer = true;
                end
            end
            if anotherPlayer then
                local name = UnitName("player");
                local _, classFilename = UnitClass("player");
                local _, _, _, argbHex = GetClassColor(classFilename)
                name = " (|c" .. argbHex .. name .. "|r" .. color .. ")|r";
                text = text .. name;
            end
        end
    end

    local t = {
        [text] = {},
    }
    if iconData.Name then
        t[text][iconData.Name] = true;
    end
    tinsert(tooltips, 1, t);
    return tooltips
end

function _MapIconTooltip:AddTooltipsForQuest(icon, tip, quest, usedText)
    for text, nameTable in pairs(tip) do
        local data = {}
        data[text] = nameTable
        -- Add the data for the first time
        if not usedText[icon.data.Id] then
            usedText[icon.data.Id] = {
                [text] = true
            }
            tinsert(quest, data)
            -- add another line to an existing entry
        elseif not usedText[icon.data.Id][text] then
            tinsert(quest, data)
            usedText[icon.data.Id][text] = true
        else
            --We want to add more NPCs as possible candidates when shift is pressed.
            if icon.data.Name then
                for dataIndex, _ in pairs(quest) do
                    if quest[dataIndex][text] then
                        quest[dataIndex][text][icon.data.Name] = true;
                    end
                end
            end
        end
    end
end
