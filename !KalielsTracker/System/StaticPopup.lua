--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local DIALOG_TITLE = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:0:0|t"..NORMAL_FONT_COLOR_CODE..KT.TITLE.."|r"

function KT.StaticPopup_Show(token, text, subText, ...)
    local data = select("#", ...) > 0 and { ... } or nil
    return StaticPopup_Show(addonName.."_"..token, nil, nil, {
        text = text,
        subText = subText,
        data = data
    })
end

function KT.StaticPopup_ShowURL(token, param1, value1, param2, value2)
    return StaticPopup_Show(addonName.."_"..token, nil, nil, {
        param1 = param1,
        value1 = value1,
        param2 = param2,
        value2 = value2
    })
end

-- ---------------------------------------------------------------------------------------------------------------------

local function StaticPopup_OnShow(self)
    local text = self.data.text
    local subText = self.data.subText
    if text then
        self:SetText(self:GetText().." - "..text)
    end
    if subText then
        local data = self.data.data
        if data then
            self.SubText:SetFormattedText(subText, unpack(data))
        else
            self.SubText:SetText(subText)
        end
    end
    self.SubText:SetTextColor(1, 1, 1)
end

StaticPopupDialogs[addonName.."_Info"] = {
    text = DIALOG_TITLE,
    subText = "...",
    button2 = CLOSE,
    OnShow = StaticPopup_OnShow,
    timeout = 0,
    whileDead = 1
}

StaticPopupDialogs[addonName.."_ReloadUI"] = {
    text = DIALOG_TITLE,
    subText = "...",
    button1 = RELOADUI,
    OnShow = StaticPopup_OnShow,
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = 1
}

StaticPopupDialogs[addonName.."_WowheadURL"] = {
    text = DIALOG_TITLE.." - Wowhead URL",
    button2 = CLOSE,
    hasEditBox = 1,
    editBoxWidth = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and 300 or 380,
    maxLetters = 0,
    maxBytes = 0,
    countInvisibleLetters = false,
    EditBoxOnTextChanged = function(self)
        local text = self.text
        if text and self:GetText() ~= text then
            self:SetText(text)
        end
        self:HighlightText()
    end,
    EditBoxOnEnterPressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    OnShow = function(self)
        local type, id = self.data.param1, self.data.value1
        if not type or not id then return end

        local name = "..."
        local url = "https://www.wowhead.com/"
        local param = type.."="..id

        if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
            url = url.."classic/"
        elseif WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
            url = url.."mop-classic/"
        elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
            url = url.."cata/"
        elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
            url = url.."wotlk/"
        elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
            url = url.."tbc/"
        end

        if type == "quest" then
            name = QuestUtils_GetQuestName(id)
        elseif type == "achievement" then
            name = select(2, GetAchievementInfo(id))
        elseif type == "spell" then
            name = C_Spell.GetSpellName(id)
        elseif type == "activity" then
            local activityInfo = C_PerksActivities.GetPerksActivityInfo(id)
            if activityInfo then
                name = activityInfo.activityName
            end
            param = "trading-post-activity/"..id
        end

        local lang = KT.LOCALE:sub(1, 2)
        if lang ~= "en" then
            if lang == "zh" then lang = "cn" end
            url = url..lang.."/"
        end

        local text = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and self.text or self
        text:SetText(text:GetText().."\n|cffff7f00"..name.."|r")
        local editBox = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and self.editBox or self:GetEditBox()
        editBox.text = url..param
        editBox:SetText(editBox.text)
        editBox:SetFocus()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
}