local addon = ...

local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local function FindLine(tooltip, keyword)
    local line, text
    for i = 2, tooltip:NumLines() do
        line = _G[tooltip:GetName() .. "TextLeft" .. i]
        text = line:GetText() or ""
        if (string.find(text, keyword)) then
            return line, i, _G[tooltip:GetName() .. "TextRight" .. i]
        end
    end
end

local LevelLabel = STAT_AVERAGE_ITEM_LEVEL .. ": "
local SpecLabel = SPECIALIZATION .. ": "

local function AppendToGameTooltip(guid, ilevel, spec, weaponLevel, isArtifact)
    spec = spec or ""
    if (TinyInspectReforgedDB and not TinyInspectReforgedDB.EnableMouseSpecialization) then spec = "" end
    local _, unit = GameTooltip:GetUnit()
    if (not unit or UnitGUID(unit) ~= guid) then return end
    local ilvlLine, _, lineRight = FindLine(GameTooltip, LevelLabel)
    local ilvlText = format("%s|cffffffff%s|r", LevelLabel, ilevel)
    local specText = format("|cffb8b8b8%s|r", spec)
    if (weaponLevel and weaponLevel > 0 and TinyInspectReforgedDB.EnableMouseWeaponLevel) then
        ilvlText = ilvlText .. format(" (%s)", weaponLevel)
    end
    if (ilvlLine) then
        ilvlLine:SetText(ilvlText)
        lineRight:SetText(specText)
    else
        GameTooltip:AddDoubleLine(ilvlText, specText)
    end
    GameTooltip:Show()
end
--[[
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    if (TinyInspectReforgedDB and TinyInspectReforgedDB.EnableItemLevel) then
        local _, link = self:GetItem()
		if not link then return end -- 暫時修正，副本戰利品查詢的專業製作物品會是 nil
        local _, _, _, itemLevel,_,_,_,_,_,_,_, classID,_ = GetItemInfo(link)
        if (itemLevel and itemLevel>1) then
            local left = _G[GameTooltip:GetName() .. 'TextLeft' .. 2]
            local leftText = left:GetText()
            left:SetText("|cffffd100".. STAT_AVERAGE_ITEM_LEVEL .." ".. itemLevel .. "|r")
            GameTooltip:Show()
        end
    end
end)
--]]
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    if (TinyInspectReforgedDB and (TinyInspectReforgedDB.EnableMouseItemLevel or TinyInspectReforgedDB.EnableMouseSpecialization)) then
        local _, unit = self:GetUnit()
        if (not unit) then return end
        if (not UnitIsPlayer(unit)) then return end
        local guid = UnitGUID(unit)
        if (not guid) then return end
        local hp = UnitHealthMax(unit)
        local data = GetInspectInfo(unit)
        if (data and data.hp == hp and data.ilevel > 0) then
            return AppendToGameTooltip(guid, floor(data.ilevel), data.spec, data.weaponLevel, data.isArtifact)
        end
        if (not CanInspect(unit) or not UnitIsVisible(unit)) then return end
        local inspecting = GetInspecting()
        if (inspecting) then
            if (inspecting.guid ~= guid) then
                return AppendToGameTooltip(guid, "n/a")
            else
                return AppendToGameTooltip(guid, "....")
            end
        end
        ClearInspectPlayer()
        NotifyInspect(unit)
        AppendToGameTooltip(guid, "...")
    end
end)

LibEvent:attachTrigger("UNIT_INSPECT_READY", function(self, data)
    if (TinyInspectReforgedDB and not TinyInspectReforgedDB.EnableMouseItemLevel) then return end
    if (data.guid == UnitGUID("mouseover")) then
        AppendToGameTooltip(data.guid, floor(data.ilevel), data.spec, data.weaponLevel, data.isArtifact)
    end
end)

