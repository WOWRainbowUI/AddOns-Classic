local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local B = Cell.bFuncs

local generalTab = Cell.CreateFrame("CellOptionsFrame_GeneralTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.generalTab = generalTab
generalTab:SetAllPoints(Cell.frames.optionsFrame)
generalTab:Hide()

-------------------------------------------------
-- visibility
-------------------------------------------------
local hideBlizzardPartyCB, hideBlizzardRaidCB

local function CreateVisibilityPane()
    local visibilityPane = Cell.CreateTitledPane(generalTab, L["Visibility"], 205, 80)
    visibilityPane:SetPoint("TOPLEFT", generalTab, "TOPLEFT", 5, -5)

    -- showSoloCB = Cell.CreateCheckButton(visibilityPane, L["Show Solo"], function(checked, self)
    --     CellDB["general"]["showSolo"] = checked
    --     Cell.Fire("UpdateVisibility", "solo")
    -- end, L["Show Solo"], L["Show while not in a group"], L["To open options frame, use /cell options"])
    -- showSoloCB:SetPoint("TOPLEFT", visibilityPane, "TOPLEFT", 5, -27)

    -- showPartyCB = Cell.CreateCheckButton(visibilityPane, L["Show Party"], function(checked, self)
    --     CellDB["general"]["showParty"] = checked
    --     Cell.Fire("UpdateVisibility", "party")
    -- end, L["Show Party"], L["Show while in a party"], L["To open options frame, use /cell options"])
    -- showPartyCB:SetPoint("TOPLEFT", showSoloCB, "BOTTOMLEFT", 0, -7)

    -- showRaidCB = Cell.CreateCheckButton(visibilityPane, L["Show Raid"], function(checked, self)
    --     CellDB["general"]["showRaid"] = checked
    --     Cell.Fire("UpdateVisibility", "raid")
    -- end, L["Show Raid"], L["Show while in a raid"], L["To open options frame, use /cell options"])
    -- showRaidCB:SetPoint("TOPLEFT", showPartyCB, "BOTTOMLEFT", 0, -7)

    hideBlizzardPartyCB = Cell.CreateCheckButton(visibilityPane, L["Hide Blizzard Party"], function(checked, self)
        CellDB["general"]["hideBlizzardParty"] = checked

        local popup = Cell.CreateConfirmPopup(generalTab, 200, L["A UI reload is required.\nDo it now?"], function()
            ReloadUI()
        end, nil, true)
        popup:SetPoint("TOPLEFT", generalTab, 117, -77)
    end, L["Hide Blizzard Frames"], L["Require reload of the UI"])
    hideBlizzardPartyCB:SetPoint("TOPLEFT", visibilityPane, 5, -27)

    hideBlizzardRaidCB = Cell.CreateCheckButton(visibilityPane, L["Hide Blizzard Raid"], function(checked, self)
        CellDB["general"]["hideBlizzardRaid"] = checked

        local popup = Cell.CreateConfirmPopup(generalTab, 200, L["A UI reload is required.\nDo it now?"], function()
            ReloadUI()
        end, nil, true)
        popup:SetPoint("TOPLEFT", generalTab, 117, -77)
    end, L["Hide Blizzard Frames"], L["Require reload of the UI"])
    hideBlizzardRaidCB:SetPoint("TOPLEFT", hideBlizzardPartyCB, "BOTTOMLEFT", 0, -7)
end

-------------------------------------------------
-- tooltip
-------------------------------------------------
local enableTooltipsCB, hideTooltipsInCombatCB, tooltipsAnchor, tooltipsAnchorText, tooltipsAnchoredTo, tooltipsAnchoredToText, tooltipsX, tooltipsY

local function UpdateTooltipsOptions()
    if strfind(CellDB["general"]["tooltipsPosition"][2], "Cursor") or CellDB["general"]["tooltipsPosition"][2] == "Default" then
        tooltipsAnchor:SetEnabled(false)
        tooltipsAnchorText:SetTextColor(0.4, 0.4, 0.4)
    else
        tooltipsAnchor:SetEnabled(true)
        tooltipsAnchorText:SetTextColor(1, 1, 1)
    end

    if CellDB["general"]["tooltipsPosition"][2] == "Cursor" or CellDB["general"]["tooltipsPosition"][2] == "Default" then
        tooltipsX:SetEnabled(false)
        tooltipsY:SetEnabled(false)
    else
        tooltipsX:SetEnabled(true)
        tooltipsY:SetEnabled(true)
    end
end

local function CreateTooltipsPane()
    local tooltipsPane = Cell.CreateTitledPane(generalTab, L["Tooltips"], 205, 270)
    tooltipsPane:SetPoint("TOPLEFT", generalTab, "TOPLEFT", 222, -5)

    enableTooltipsCB = Cell.CreateCheckButton(tooltipsPane, L["Enabled"], function(checked, self)
        CellDB["general"]["enableTooltips"] = checked
        hideTooltipsInCombatCB:SetEnabled(checked)
        -- enableAuraTooltipsCB:SetEnabled(checked)
        tooltipsAnchor:SetEnabled(checked)
        tooltipsAnchoredTo:SetEnabled(checked)
        tooltipsX:SetEnabled(checked)
        tooltipsY:SetEnabled(checked)
        if checked then
            tooltipsAnchorText:SetTextColor(1, 1, 1)
            tooltipsAnchoredToText:SetTextColor(1, 1, 1)
            UpdateTooltipsOptions()
        else
            tooltipsAnchorText:SetTextColor(0.4, 0.4, 0.4)
            tooltipsAnchoredToText:SetTextColor(0.4, 0.4, 0.4)
        end
    end)
    enableTooltipsCB:SetPoint("TOPLEFT", tooltipsPane, "TOPLEFT", 5, -27)

    hideTooltipsInCombatCB = Cell.CreateCheckButton(tooltipsPane, L["Hide in Combat"], function(checked, self)
        CellDB["general"]["hideTooltipsInCombat"] = checked
    end, L["Hide in Combat"], L["Hide tooltips for units"], L["This will not affect aura tooltips"])
    hideTooltipsInCombatCB:SetPoint("TOPLEFT", enableTooltipsCB, "BOTTOMLEFT", 0, -7)

    -- auras tooltips
    -- enableAuraTooltipsCB = Cell.CreateCheckButton(tooltipsPane, L["Enable Auras Tooltips"].." (pending)", function(checked, self)
    -- end)
    -- enableAuraTooltipsCB:SetPoint("TOPLEFT", hideTooltipsInCombatCB, "BOTTOMLEFT", 0, -7)
    -- enableAuraTooltipsCB:SetEnabled(false)

    -- position
    tooltipsAnchor = Cell.CreateDropdown(tooltipsPane, 137)
    tooltipsAnchor:SetPoint("TOPLEFT", hideTooltipsInCombatCB, "BOTTOMLEFT", 0, -25)
    local points = {"BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "TOPLEFT", "TOPRIGHT"}
    local relativePoints = {"TOP", "TOPLEFT", "TOPRIGHT", "RIGHT", "LEFT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT"}
    local anchorItems = {}
    for i, point in pairs(points) do
        tinsert(anchorItems, {
            ["text"] = L[point],
            ["value"] = point,
            ["onClick"] = function()
                CellDB["general"]["tooltipsPosition"][1] = point
                CellDB["general"]["tooltipsPosition"][3] = relativePoints[i]
            end,
        })
    end
    tooltipsAnchor:SetItems(anchorItems)

    tooltipsAnchorText = tooltipsPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    tooltipsAnchorText:SetText(L["Anchor Point"])
    tooltipsAnchorText:SetPoint("BOTTOMLEFT", tooltipsAnchor, "TOPLEFT", 0, 1)

    tooltipsAnchoredTo = Cell.CreateDropdown(tooltipsPane, 137)
    tooltipsAnchoredTo:SetPoint("TOPLEFT", tooltipsAnchor, "BOTTOMLEFT", 0, -25)
    local relatives = {"Default", "Cell", "Unit Button", "Cursor", "Cursor Left", "Cursor Right"}
    local relativeToItems = {}
    for _, relative in pairs(relatives) do
        tinsert(relativeToItems, {
            ["text"] = L[relative],
            ["value"] = relative,
            ["onClick"] = function()
                CellDB["general"]["tooltipsPosition"][2] = relative
                UpdateTooltipsOptions()
            end,
        })
    end
    tooltipsAnchoredTo:SetItems(relativeToItems)

    tooltipsAnchoredToText = tooltipsPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    tooltipsAnchoredToText:SetText(L["Anchored To"])
    tooltipsAnchoredToText:SetPoint("BOTTOMLEFT", tooltipsAnchoredTo, "TOPLEFT", 0, 1)

    tooltipsX = Cell.CreateSlider(L["X Offset"], tooltipsPane, -100, 100, 137, 1)
    tooltipsX:SetPoint("TOPLEFT", tooltipsAnchoredTo, "BOTTOMLEFT", 0, -25)
    tooltipsX.afterValueChangedFn = function(value)
        CellDB["general"]["tooltipsPosition"][4] = value
    end

    tooltipsY = Cell.CreateSlider(L["Y Offset"], tooltipsPane, -100, 100, 137, 1)
    tooltipsY:SetPoint("TOPLEFT", tooltipsX, "BOTTOMLEFT", 0, -40)
    tooltipsY.afterValueChangedFn = function(value)
        CellDB["general"]["tooltipsPosition"][5] = value
    end
end

-------------------------------------------------
-- position
-------------------------------------------------
local lockCB, fadeOutCB, menuPositionDD

local function CreatePositionPane()
    local positionPane = Cell.CreateTitledPane(generalTab, L["Position"], 205, 120)
    positionPane:SetPoint("TOPLEFT", generalTab, 5, -120)

    lockCB = Cell.CreateCheckButton(positionPane, L["Lock Cell Frames"], function(checked, self)
        CellDB["general"]["locked"] = checked
        Cell.Fire("UpdateMenu", "lock")
    end)
    lockCB:SetPoint("TOPLEFT", 5, -27)

    fadeOutCB = Cell.CreateCheckButton(positionPane, L["Fade Out Menu"], function(checked, self)
        CellDB["general"]["fadeOut"] = checked
        Cell.Fire("UpdateMenu", "fadeOut")
    end, L["Fade Out Menu"], L["Fade out menu buttons on mouseout"])
    fadeOutCB:SetPoint("TOPLEFT", lockCB, "BOTTOMLEFT", 0, -7)

    menuPositionDD = Cell.CreateDropdown(positionPane, 137)
    menuPositionDD:SetPoint("TOPLEFT", fadeOutCB, "BOTTOMLEFT", 0, -25)
    menuPositionDD:SetItems({
        {
            ["text"] = L["TOP"].." / "..L["BOTTOM"],
            ["value"] = "top_bottom",
            ["onClick"] = function()
                CellDB["general"]["menuPosition"] = "top_bottom"
                Cell.Fire("UpdateMenu", "position")
            end,
        },
        {
            ["text"] = L["LEFT"].." / "..L["RIGHT"],
            ["value"] = "left_right",
            ["onClick"] = function()
                CellDB["general"]["menuPosition"] = "left_right"
                Cell.Fire("UpdateMenu", "position")
            end,
        },
    })

    local menuPositionText = positionPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    menuPositionText:SetText(L["Menu Position"])
    menuPositionText:SetPoint("BOTTOMLEFT", menuPositionDD, "TOPLEFT", 0, 1)
end

-------------------------------------------------
-- nickname
-------------------------------------------------
local nicknameEB, syncCB
local function CreateNicknamePane()
    local nicknamePane = Cell.CreateTitledPane(generalTab, L["Nickname"], 205, 130)
    nicknamePane:SetPoint("TOPLEFT", generalTab, 5, -300)

    -- my nickname
    nicknameEB = Cell.CreateEditBox(nicknamePane, 195, 20)
    nicknameEB:SetPoint("TOPLEFT", 5, -27)
    nicknameEB:SetScript("OnTextChanged", function(self, userChanged)
        local text = strtrim(nicknameEB:GetText())
        nicknameEB.tip:SetShown(text == "")

        if userChanged then
            if CellDB["nicknames"]["mine"] ~= "" then -- already set a nickname
                if text ~= CellDB["nicknames"]["mine"] then -- not the same nickname
                    nicknameEB.confirmBtn:Show()
                else
                    nicknameEB.confirmBtn:Hide()
                end
            elseif text ~= "" then -- nickname not set, expect a non-empty string
                nicknameEB.confirmBtn:Show()
            else
                nicknameEB.confirmBtn:Hide()
            end
        end
    end)

    nicknameEB.confirmBtn = Cell.CreateButton(nicknameEB, "OK", "accent", {50, 20})
    nicknameEB.confirmBtn:SetPoint("TOPRIGHT", nicknameEB)
    nicknameEB.confirmBtn:Hide()
    nicknameEB.confirmBtn:SetScript("OnHide", function()
        nicknameEB.confirmBtn:Hide()
    end)
    nicknameEB.confirmBtn:SetScript("OnClick", function()
        local text = strtrim(nicknameEB:GetText())
        nicknameEB:SetText(text)
        CellDB["nicknames"]["mine"] = text
        Cell.Fire("UpdateNicknames", "mine", text)
        nicknameEB.confirmBtn:Hide()
        nicknameEB:ClearFocus()
    end)

    nicknameEB.tip = nicknameEB:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    nicknameEB.tip:SetPoint("LEFT", 5, 0)
    nicknameEB.tip:SetTextColor(0.4, 0.4, 0.4, 1)
    nicknameEB.tip:SetText(L["My Nickname"])

    -- sync with others
    syncCB = Cell.CreateCheckButton(nicknamePane, L["Nickname Sync"], function(checked, self)
        CellDB["nicknames"]["sync"] = checked
        Cell.Fire("UpdateNicknames", "sync", checked)
    end)
    syncCB:SetPoint("TOPLEFT", nicknameEB, "BOTTOMLEFT", 0, -7)

    -- custom nicknames
    local customNicknamesBtn = Cell.CreateButton(nicknamePane, L["Custom Nicknames"], "accent-hover", {137, 20})
    customNicknamesBtn:SetPoint("TOPLEFT", syncCB, "BOTTOMLEFT", 0, -7)
    Cell.frames.generalTab.customNicknamesBtn = customNicknamesBtn
    customNicknamesBtn:SetScript("OnClick", function()
        F.ShowCustomNicknames()
    end)

    -- custom
    local blacklistBtn = Cell.CreateButton(nicknamePane, L["Nickname Blacklist"], "accent-hover", {137, 20})
    blacklistBtn:SetPoint("TOPLEFT", customNicknamesBtn, "BOTTOMLEFT", 0, -7)
    Cell.frames.generalTab.nicknameBlacklistBtn = blacklistBtn
    blacklistBtn:SetScript("OnClick", function()
        F.ShowNicknameBlacklist()
    end)
end

-------------------------------------------------
-- misc
-------------------------------------------------
local alwaysUpdateAurasCB, useCleuCB, translitCB

local function CreateMiscPane()
    local miscPane = Cell.CreateTitledPane(generalTab, L["Misc"], 205, 130)
    miscPane:SetPoint("TOPLEFT", generalTab, 222, -300)

    alwaysUpdateAurasCB = Cell.CreateCheckButton(miscPane, L["Always Update Auras"], function(checked, self)
        CellDB["general"]["alwaysUpdateAuras"] = checked
        Cell.vars.alwaysUpdateAuras = checked
    end, L["Ignore UNIT_AURA payloads"], L["This may help solve issues of indicators not updating correctly"])
    alwaysUpdateAurasCB:SetPoint("TOPLEFT", 5, -27)
    alwaysUpdateAurasCB:SetEnabled(Cell.isRetail or Cell.isMists)

    useCleuCB = Cell.CreateCheckButton(miscPane, L["Faster Health Updates"], function(checked, self)
        CellDB["general"]["useCleuHealthUpdater"] = checked
        Cell.Fire("UpdateCLEU")
    end, "|cffff2727"..L["HIGH CPU USAGE"].." (EXPERIMENTAL)", L["Use CLEU events to increase health update rate"])
    useCleuCB:SetPoint("TOPLEFT", alwaysUpdateAurasCB, "BOTTOMLEFT", 0, -9)

    translitCB = Cell.CreateCheckButton(miscPane, L["Translit Cyrillic to Latin"], function(checked, self)
        CellDB["general"]["translit"] = checked
        Cell.Fire("TranslitNames")
    end)
    translitCB:SetPoint("TOPLEFT", useCleuCB, "BOTTOMLEFT", 0, -9)
end

-------------------------------------------------
-- LibGetFrame
-------------------------------------------------
local framePriorityWidget

-- TODO: move to Widgets.lua
local function CreateFramePriorityWidget(parent)
    local f = CreateFrame("Frame", nil, parent)
    P.Size(f, 336, 20)

    local function GetPriority(name)
        for i, t in pairs(CellDB["general"]["framePriority"]) do
            if t[1] == name then
                return i
            end
        end
    end

    local buttons = {}

    local function Comparator(a, b)
        if a[2] ~= b[2] then
            return a[2]
        end

        return buttons[a[1]]._priority < buttons[b[1]]._priority
    end

    for _, name in pairs({"Main", "Spotlight", "Quick Assist"}) do
        buttons[name] = Cell.CreateButton(f, L[name], "accent-hover", {110, 20})
        buttons[name]._priorityName = name

        buttons[name].cb = Cell.CreateCheckButton(buttons[name], "", function(checked, self)
            CellDB["general"]["framePriority"][GetPriority(name)][2] = checked
            buttons[name]:SetEnabled(checked)
            buttons[name]._enabled = checked
            sort(CellDB["general"]["framePriority"], Comparator)
            f:Load(CellDB["general"]["framePriority"])
            F.UpdateFramePriority()
        end)
        buttons[name].cb:SetPoint("LEFT", 3, 0)

        buttons[name].fs:SetPoint("LEFT", buttons[name].cb, "RIGHT", 3, 0)
        buttons[name].fs:SetJustifyH("LEFT")

        buttons[name]:SetMovable(true)
        buttons[name]:RegisterForDrag("LeftButton")

        buttons[name]:SetScript("OnDragStart", function(self)
            self:SetFrameStrata("TOOLTIP")
            self:StartMoving()
            self:SetUserPlaced(false)
        end)

        buttons[name]:SetScript("OnDragStop", function(self)
            if not self._enabled then return end
            self:StopMovingOrSizing()
            self:SetFrameStrata("LOW")
            -- self:Hide() --! Hide() will cause OnDragStop trigger TWICE!!!
            C_Timer.After(0.05, function()
                local b = F.GetMouseFocus()
                if b ~= self and b and b._priority and b._enabled then
                    -- print(self._priorityName, "->", b._priorityName)

                    local temp = CellDB["general"]["framePriority"][self._priority]
                    tremove(CellDB["general"]["framePriority"], self._priority)
                    tinsert(CellDB["general"]["framePriority"], b._priority, temp)
                end
                f:Load(CellDB["general"]["framePriority"])
                F.UpdateFramePriority()
            end)
        end)
    end

    function f:Load(t)
        for i, p in pairs(t) do
            buttons[p[1]]:SetFrameStrata(parent:GetFrameStrata())
            buttons[p[1]]:Show()
            buttons[p[1]]:ClearAllPoints()
            buttons[p[1]]:SetPoint("TOPLEFT", (i-1)*(P.Scale(110)+P.Scale(3)), 0)
            buttons[p[1]]._enabled = p[2]
            buttons[p[1]]:SetEnabled(p[2])
            buttons[p[1]].cb:SetChecked(p[2])
            buttons[p[1]]._priority = i
        end
    end

    return f
end

local function CreateLibGetFramePane()
    local miscPane = Cell.CreateTitledPane(generalTab, "LibGetFrame", 422, 80)
    miscPane:SetPoint("TOPLEFT", generalTab, 5, -450)

    framePriorityWidget = CreateFramePriorityWidget(miscPane)
    framePriorityWidget:SetPoint("TOPLEFT", 5, -45)

    -- framePriorityDD = Cell.CreateDropdown(miscPane, 250)
    -- framePriorityDD:SetPoint("TOPLEFT", alwaysUpdateAurasCB, "BOTTOMLEFT", 0, -29)
    -- framePriorityDD:SetItems({
    --     {
    --         ["text"] = L["Main"].." > "..L["Spotlight"].." > "..L["Quick Assist"],
    --         ["value"] = "normal_spotlight_quickassist",
    --         ["onClick"] = function()
    --             CellDB["general"]["framePriority"] = "normal_spotlight_quickassist"
    --         end,
    --     },
    --     {
    --         ["text"] = L["Spotlight"].." > "..L["Main"].." > "..L["Quick Assist"],
    --         ["value"] = "spotlight_normal_quickassist",
    --         ["onClick"] = function()
    --             CellDB["general"]["framePriority"] = "spotlight_normal_quickassist"
    --         end,
    --     },
    --     {
    --         ["text"] = L["Quick Assist"].." > "..L["Main"].." > "..L["Spotlight"],
    --         ["value"] = "quickassist_normal_spotlight",
    --         ["onClick"] = function()
    --             CellDB["general"]["framePriority"] = "quickassist_normal_spotlight"
    --         end,
    --     },
    -- })

    local framePriorityText = miscPane:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET")
    framePriorityText:SetPoint("BOTTOMLEFT", framePriorityWidget, "TOPLEFT", 0, 7)
    framePriorityText:SetText(L["Frame priorities for LibGetFrame"])
end

-------------------------------------------------
-- functions
-------------------------------------------------
local init
local function ShowTab(tab)
    if tab == "general" then
        if not init then
            CreateVisibilityPane()
            CreateTooltipsPane()
            CreatePositionPane()
            CreateNicknamePane()
            CreateMiscPane()
            CreateLibGetFramePane()

            -- mask
            F.ApplyCombatProtectionToFrame(generalTab)
            Cell.CreateMask(generalTab, nil, {1, -1, -1, 1})
            generalTab.mask:Hide()
        end

        generalTab:Show()

        if init then return end
        init = true

        -- tooltips
        enableTooltipsCB:SetChecked(CellDB["general"]["enableTooltips"])
        hideTooltipsInCombatCB:SetEnabled(CellDB["general"]["enableTooltips"])
        hideTooltipsInCombatCB:SetChecked(CellDB["general"]["hideTooltipsInCombat"])
        -- enableAuraTooltipsCB:SetEnabled(CellDB["general"]["enableTooltips"])
        -- enableAuraTooltipsCB:SetChecked(CellDB["general"]["enableAurasTooltips"])
        tooltipsAnchor:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsAnchor:SetSelectedValue(CellDB["general"]["tooltipsPosition"][1])
        tooltipsAnchoredTo:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsAnchoredTo:SetSelectedValue(CellDB["general"]["tooltipsPosition"][2])
        tooltipsX:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsX:SetValue(CellDB["general"]["tooltipsPosition"][4])
        tooltipsY:SetEnabled(CellDB["general"]["enableTooltips"])
        tooltipsY:SetValue(CellDB["general"]["tooltipsPosition"][5])
        if CellDB["general"]["enableTooltips"] then
            tooltipsAnchorText:SetTextColor(1, 1, 1)
            tooltipsAnchoredToText:SetTextColor(1, 1, 1)
            UpdateTooltipsOptions()
        else
            tooltipsAnchorText:SetTextColor(0.4, 0.4, 0.4)
            tooltipsAnchoredToText:SetTextColor(0.4, 0.4, 0.4)
        end

        -- visibility
        hideBlizzardPartyCB:SetChecked(CellDB["general"]["hideBlizzardParty"])
        hideBlizzardRaidCB:SetChecked(CellDB["general"]["hideBlizzardRaid"])

        -- position
        lockCB:SetChecked(CellDB["general"]["locked"])
        fadeOutCB:SetChecked(CellDB["general"]["fadeOut"])
        menuPositionDD:SetSelectedValue(CellDB["general"]["menuPosition"])

        -- nickname
        nicknameEB:SetText(CellDB["nicknames"]["mine"])
        syncCB:SetChecked(CellDB["nicknames"]["sync"])

        -- misc
        alwaysUpdateAurasCB:SetChecked(CellDB["general"]["alwaysUpdateAuras"])
        framePriorityWidget:Load(CellDB["general"]["framePriority"])
        useCleuCB:SetChecked(CellDB["general"]["useCleuHealthUpdater"])
        translitCB:SetChecked(CellDB["general"]["translit"])

    else
        generalTab:Hide()
    end
end
Cell.RegisterCallback("ShowOptionsTab", "GeneralTab_ShowTab", ShowTab)