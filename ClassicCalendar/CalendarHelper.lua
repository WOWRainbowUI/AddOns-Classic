-- CalendarHelper.lua
-- Helper functions for reading calendar data from saved variables

local CalendarHelper = {}

-- Initialize the CalendarHelper
function CalendarHelper:Initialize()
    if DEBUG_MODE then
        print("CalendarHelper: Initialized - Ready to read saved variable data")
    end
end

-- Read CalendarHelper saved variable data
function CalendarHelper:ReadCalendarHelperData()
    if CalendarHelperDB then
        return CalendarHelperDB
    else
        if DEBUG_MODE then
            print("CalendarHelper: CalendarHelperDB not found or not loaded yet")
        end
        return nil
    end
end

-- Read existing ClassicCalendar saved variables
function CalendarHelper:ReadCCConfig()
    if CCConfig then
        return CCConfig
    else
        if DEBUG_MODE then
            print("CalendarHelper: CCConfig not found or not loaded yet")
        end
        return nil
    end
end

-- Read World Buff data
function CalendarHelper:ReadWorldBuffData()
    local worldBuffData = {
        rend = WorldBuffRendData,
        hakkar = WorldBuffHakkarData,
        onyxia = WorldBuffOnyxiaData,
        nefarian = WorldBuffNefarianData
    }
    
    return worldBuffData
end

-- Read ClassicCalendarDB (minimap and other settings)
function CalendarHelper:ReadClassicCalendarDB()
    if ClassicCalendarDB then
        return ClassicCalendarDB
    else
        if DEBUG_MODE then
            print("CalendarHelper: ClassicCalendarDB not found or not loaded yet")
        end
        return nil
    end
end

-- Get all saved variable data in one function
function CalendarHelper:ReadAllSavedData()
    local allData = {
        calendarHelper = self:ReadCalendarHelperData(),
        ccConfig = self:ReadCCConfig(),
        worldBuffs = self:ReadWorldBuffData(),
        classicCalendarDB = self:ReadClassicCalendarDB()
    }
    
    return allData
end

-- Helper function to check if saved variables are loaded
function CalendarHelper:AreSavedVariablesLoaded()
    local loaded = {
        CalendarHelperDB = CalendarHelperDB ~= nil,
        CCConfig = CCConfig ~= nil,
        WorldBuffRendData = WorldBuffRendData ~= nil,
        WorldBuffHakkarData = WorldBuffHakkarData ~= nil,
        WorldBuffOnyxiaData = WorldBuffOnyxiaData ~= nil,
        WorldBuffNefarianData = WorldBuffNefarianData ~= nil,
        ClassicCalendarDB = ClassicCalendarDB ~= nil
    }
    
    return loaded
end

-- Print saved variable status for debugging
function CalendarHelper:PrintSavedVariableStatus()
    if DEBUG_MODE then
        local status = self:AreSavedVariablesLoaded()
        
        print("CalendarHelper: Saved Variables Status:")
        for varName, isLoaded in pairs(status) do
            print("  " .. varName .. ": " .. (isLoaded and "LOADED" or "NOT LOADED"))
        end
    end
end

-- Get specific data from world buff tables
function CalendarHelper:GetWorldBuffEntries(buffType)
    local dataTable = nil
    
    if buffType == "rend" then
        dataTable = WorldBuffRendData
    elseif buffType == "hakkar" then
        dataTable = WorldBuffHakkarData
    elseif buffType == "onyxia" then
        dataTable = WorldBuffOnyxiaData
    elseif buffType == "nefarian" then
        dataTable = WorldBuffNefarianData
    end
    
    if dataTable then
        return dataTable
    else
        if DEBUG_MODE then
            print("CalendarHelper: World buff data for '" .. (buffType or "unknown") .. "' not found")
        end
        return {}
    end
end

-- Convert UTC/Zulu time to PST (Pacific Standard Time)
function CalendarHelper:ConvertUTCtoPST(utcYear, utcMonth, utcDay, utcHour, utcMinute)
    -- Create UTC timestamp
    local utcTime = time({
        year = utcYear,
        month = utcMonth,
        day = utcDay,
        hour = utcHour,
        min = utcMinute,
        sec = 0
    })
    
    -- PST is UTC-8, PDT is UTC-7
    -- For simplicity, we'll assume PST (UTC-8) - you can enhance this for DST detection
    local pstOffset = -8 * 3600 -- 8 hours in seconds
    local pstTime = utcTime + pstOffset
    
    -- Convert back to date components
    local pstDate = date("*t", pstTime)
    
    return {
        year = pstDate.year,
        month = pstDate.month,
        day = pstDate.day,
        hour = pstDate.hour,
        minute = pstDate.min
    }
end

-- Enhanced DST-aware UTC to PST conversion
function CalendarHelper:ConvertUTCtoPSTWithDST(utcYear, utcMonth, utcDay, utcHour, utcMinute)
    -- Create UTC timestamp
    local utcTime = time({
        year = utcYear,
        month = utcMonth,
        day = utcDay,
        hour = utcHour,
        min = utcMinute,
        sec = 0
    })
    
    -- Determine if we're in DST period
    -- DST in Pacific timezone typically runs from 2nd Sunday in March to 1st Sunday in November
    local isDST = self:IsPacificDST(utcYear, utcMonth, utcDay)
    
    -- PST is UTC-8, PDT is UTC-7
    local offset = isDST and -7 * 3600 or -8 * 3600
    local localTime = utcTime + offset
    
    -- Convert back to date components
    local localDate = date("*t", localTime)
    
    return {
        year = localDate.year,
        month = localDate.month,
        day = localDate.day,
        hour = localDate.hour,
        minute = localDate.min,
        timezone = isDST and "PDT" or "PST"
    }
end

-- Check if a given date falls within Pacific Daylight Time
function CalendarHelper:IsPacificDST(year, month, day)
    -- DST starts on the 2nd Sunday in March
    local marchStart = self:GetNthSundayOfMonth(year, 3, 2)
    
    -- DST ends on the 1st Sunday in November
    local novemberEnd = self:GetNthSundayOfMonth(year, 11, 1)
    
    -- Create timestamp for the given date
    local checkTime = time({year = year, month = month, day = day, hour = 12})
    local startTime = time({year = year, month = 3, day = marchStart, hour = 2})
    local endTime = time({year = year, month = 11, day = novemberEnd, hour = 2})
    
    return checkTime >= startTime and checkTime < endTime
end

-- Get the Nth Sunday of a given month/year
function CalendarHelper:GetNthSundayOfMonth(year, month, n)
    -- Find the first day of the month
    local firstDay = time({year = year, month = month, day = 1, hour = 12})
    local firstDayInfo = date("*t", firstDay)
    
    -- Sunday is day 1, Monday is 2, etc. (in Lua's date system)
    local firstSunday = 1 + (7 - firstDayInfo.wday + 1) % 7
    if firstSunday == 8 then firstSunday = 1 end
    
    -- Calculate the Nth Sunday
    return firstSunday + (n - 1) * 7
end

-- Create guild event from CalendarHelper saved data
function CalendarHelper:CreateGuildEventFromData(eventID)
    -- Get the event data from saved variables
    local calendarData = self:ReadCalendarHelperData()
    if not calendarData or not calendarData.events or not calendarData.events[eventID] then
        print("CalendarHelper: Event not found - " .. (eventID or "nil"))
        return false
    end
    
    local eventData = calendarData.events[eventID]
    
    -- Parse the date and time (assuming UTC/Zulu time from saved file)
    local dateStr = eventData.date -- Format: "2025-11-02"
    local timeStr = eventData.time -- Format: "18:00"
    
    if not dateStr or not timeStr then
        print("CalendarHelper: Invalid date/time data for event " .. eventID)
        return false
    end
    
    -- Parse date components
    local year, month, day = dateStr:match("(%d+)-(%d+)-(%d+)")
    if not year or not month or not day then
        print("CalendarHelper: Could not parse date " .. dateStr)
        return false
    end
    
    -- Parse time components  
    local hour, minute = timeStr:match("(%d+):(%d+)")
    if not hour or not minute then
        print("CalendarHelper: Could not parse time " .. timeStr)
        return false
    end
    
    -- Use the saved time directly as server time (no conversion needed)
    local serverDate = {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        minute = tonumber(minute),
        timezone = "PST" -- Assuming PST server time
    }
    
    if DEBUG_MODE then
        print(string.format("CalendarHelper: Using server time %02d/%02d/%04d %02d:%02d %s", 
            serverDate.month, serverDate.day, serverDate.year, serverDate.hour, serverDate.minute, serverDate.timezone))
    end
    
    -- Create the guild event with server time
    self:CreateGuildEventWithDate(eventData, serverDate)
    return true
end

-- Create guild event with specified date (based on WorldBuffs implementation)
function CalendarHelper:CreateGuildEventWithDate(eventData, selectedDate)
    -- Ensure the calendar window is open first
    if not CalendarFrame or not CalendarFrame:IsShown() then
        if ShowUIPanel and CalendarFrame then
            ShowUIPanel(CalendarFrame)
        else
            print("CalendarHelper: Error - Cannot open calendar window")
            return
        end
    end
    
    -- Calculate month offset from current calendar view to selected month/year
    -- Note: We need to calculate offset from the calendar's current view, not just current date
    local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
    local currentYear = currentCalendarTime.year
    local currentMonth = currentCalendarTime.month
    
    -- Get the calendar's currently displayed month (might be different from current month)
    local calendarMonthInfo = C_Calendar.GetMonthInfo()
    local displayedMonth = calendarMonthInfo and calendarMonthInfo.month or currentMonth
    local displayedYear = calendarMonthInfo and calendarMonthInfo.year or currentYear
    
    local yearDiff = selectedDate.year - displayedYear
    local monthDiff = selectedDate.month - displayedMonth
    local monthOffset = yearDiff * 12 + monthDiff
    
    if DEBUG_MODE then
        print("CalendarHelper: Current system date: " .. currentMonth .. "/" .. currentYear)
        print("CalendarHelper: Calendar displaying: " .. displayedMonth .. "/" .. displayedYear)
        print("CalendarHelper: Target date: " .. selectedDate.month .. "/" .. selectedDate.year)
        print("CalendarHelper: Calculated month offset: " .. monthOffset)
    end
    
    -- Create a simulated day button with the same structure as real calendar day buttons
    local fakeDayButton = {
        day = selectedDate.day,
        monthOffset = monthOffset,
        -- Add GetID method that returns a calculated grid position
        GetID = function(self)
            -- Calculate what day of the week this date falls on
            local monthInfo = C_Calendar.GetMonthInfo(monthOffset)
            if monthInfo then
                local firstWeekday = monthInfo.firstWeekday or 1
                -- Calculate grid position (1-42) based on day and first weekday
                local gridPosition = selectedDate.day + firstWeekday - 1
                return gridPosition
            end
            return 1 -- fallback
        end,
        -- Add stub methods for UI button methods that might be called
        LockHighlight = function() end,
        UnlockHighlight = function() end,
        GetHighlightTexture = function() 
            return { SetAlpha = function() end }
        end
    }
    
    -- Navigate to the correct month if needed (this sets the calendar to show the target month)
    -- First, make sure we're at the current month (reset any previous navigation)
    if calendarMonthInfo and (calendarMonthInfo.month ~= currentMonth or calendarMonthInfo.year ~= currentYear) then
        local resetOffset = (currentYear - displayedYear) * 12 + (currentMonth - displayedMonth)
        if DEBUG_MODE then
            print("CalendarHelper: Resetting calendar to current month with offset: " .. resetOffset)
        end
        CalendarFrame_OffsetMonth(resetOffset)
    end
    
    -- Now navigate to target month from current month
    local finalOffset = yearDiff * 12 + (selectedDate.month - currentMonth)
    if finalOffset ~= 0 then
        if DEBUG_MODE then
            print("CalendarHelper: Navigating to target month with offset: " .. finalOffset)
        end
        CalendarFrame_OffsetMonth(finalOffset)
    end
    
    if DEBUG_MODE then
        print("CalendarHelper: Setting calendar to " .. selectedDate.month .. "/" .. selectedDate.day .. "/" .. selectedDate.year .. " (final offset: " .. finalOffset .. ")")
    end
    
    -- Create guild event directly
    if C_Calendar and CalendarFrame_ShowEventFrame and CalendarCreateEventFrame then
        -- Close any existing events and hide event frame
        C_Calendar.CloseEvent()
        CalendarFrame_HideEventFrame()
        
        -- Create guild event
        C_Calendar.CreateGuildSignUpEvent()
        CalendarCreateEventFrame.mode = "create"
        CalendarCreateEventFrame.dayButton = fakeDayButton
        CalendarFrame_ShowEventFrame(CalendarCreateEventFrame)
        
        -- Generate witty canonical descriptions based on raid type
        local raidDescriptions = self:GetRaidDescriptions()
        
        -- Wait for UI to load, then populate fields
        C_Timer.After(0.3, function()
            -- Set the event title
            local eventTitle = self:SanitizeEventTitle(eventData.title)
            
            if CalendarCreateEventTitleEdit then
                CalendarCreateEventTitleEdit:SetText(eventTitle)
                CalendarCreateEventTitleEdit:SetCursorPosition(0)
                C_Calendar.EventSetTitle(eventTitle)
                if DEBUG_MODE then
                    print("CalendarHelper: Setting event title: " .. eventTitle)
                end
            end
            
            -- Set the event description with witty canonical blurb
            local description = self:GenerateEventDescription(eventData)
            
            if CalendarCreateEventDescriptionContainer and CalendarCreateEventDescriptionContainer.ScrollingEditBox then
                CalendarCreateEventDescriptionContainer.ScrollingEditBox:SetText(description)
            end
            
            -- Set the event time using WoW's calendar system
            -- Convert hour to 12-hour format for the dropdown
            local hour12 = selectedDate.hour
            local isAM = true
            
            if selectedDate.hour == 0 then
                hour12 = 12
                isAM = true
            elseif selectedDate.hour == 12 then
                hour12 = 12
                isAM = false
            elseif selectedDate.hour > 12 then
                hour12 = selectedDate.hour - 12
                isAM = false
            else
                isAM = true
            end
            
            -- Set time using Calendar API
            if C_Calendar and C_Calendar.EventSetTime then
                C_Calendar.EventSetTime(selectedDate.hour, selectedDate.minute)
                if DEBUG_MODE then
                    print("CalendarHelper: Setting event time to " .. selectedDate.hour .. ":" .. string.format("%02d", selectedDate.minute) .. " (" .. selectedDate.timezone .. ")")
                end
            end
            
            -- Alternative method: try to set dropdown values directly
            if CalendarCreateEventHourDropDown and CalendarCreateEventMinuteDropDown then
                -- Set hour (try both 24-hour and 12-hour formats)
                UIDropDownMenu_SetSelectedValue(CalendarCreateEventHourDropDown, selectedDate.hour)
                UIDropDownMenu_SetSelectedValue(CalendarCreateEventMinuteDropDown, selectedDate.minute)
                
                -- Also try 12-hour format if 24-hour doesn't work
                if not UIDropDownMenu_GetSelectedValue(CalendarCreateEventHourDropDown) then
                    UIDropDownMenu_SetSelectedValue(CalendarCreateEventHourDropDown, hour12)
                end
            end
            
            -- Set AM/PM if there's a separate control
            if CalendarCreateEventAMPMDropDown then
                UIDropDownMenu_SetSelectedValue(CalendarCreateEventAMPMDropDown, isAM and 1 or 2)
            end
            
            -- Set the lock event checkbox to checked
            if CalendarCreateEventLockEventCheck then
                CalendarCreateEventLockEventCheck:SetChecked(true)
                if CalendarCreateEvent_SetLockEvent then
                    CalendarCreateEvent_SetLockEvent()
                end
            end
            
            if DEBUG_MODE then
                print("CalendarHelper: Guild event created for " .. eventData.title .. " on " .. selectedDate.month .. "/" .. selectedDate.day .. "/" .. selectedDate.year .. " at " .. selectedDate.hour .. ":" .. string.format("%02d", selectedDate.minute) .. " " .. (selectedDate.timezone or "PST"))
            end
        end)
        
    else
        print("CalendarHelper: Error - Calendar system functions not available")
    end
end

-- Generate witty canonical event descriptions
function CalendarHelper:GenerateEventDescription(eventData)
    local playerFaction = UnitFactionGroup("player")
    local raidType = self:IdentifyRaidType(eventData.title)
    local descriptions = self:GetRaidDescriptions()
    
    local factionDescriptions = descriptions[playerFaction] or descriptions["Horde"]
    local template = factionDescriptions[raidType] or factionDescriptions["DEFAULT"]
    
    -- Process template with event data
    local description = template:gsub("<title>", eventData.title)
    description = description:gsub("<time>", eventData.time)
    description = description:gsub("<date>", eventData.date)
    
    return description
end

-- Identify raid type from title
function CalendarHelper:IdentifyRaidType(title)
    if not title then return "DEFAULT" end
    
    local titleLower = title:lower()
    
    if titleLower:find("molten core") or titleLower:find("mc") then
        return "MOLTEN_CORE"
    elseif titleLower:find("blackwing") or titleLower:find("bwl") or titleLower:find("black wing") then
        return "BLACKWING_LAIR"
    elseif titleLower:find("onyxia") then
        return "ONYXIA"
    elseif titleLower:find("zul'?gurub") or titleLower:find("zg") then
        return "ZUL_GURUB"
    elseif titleLower:find("aq20") or titleLower:find("ruins") then
        return "AQ20"
    elseif titleLower:find("aq40") or titleLower:find("temple") then
        return "AQ40"
    elseif titleLower:find("naxxramas") or titleLower:find("naxx") then
        return "NAXXRAMAS"
    else
        return "DEFAULT"
    end
end

-- Get raid-specific witty descriptions
function CalendarHelper:GetRaidDescriptions()
    return {
        Horde = {
            MOLTEN_CORE = "🔥 Heroes of the Horde! The fiery depths of Molten Core await your conquest!\n\n" ..
                         "⚔️ Gather your courage and finest gear - Ragnaros himself trembles at our approach!\n" ..
                         "🏺 Rally at Blackrock Mountain - the Dark Iron dwarves shall witness Horde supremacy!\n" ..
                         "⏰ Arrive prepared and on time - legends are forged in the flames of battle!\n\n" ..
                         "Lok'tar Ogar! For the Horde!",
            
            BLACKWING_LAIR = "🐲 The Black Dragonflight shall know fear! Nefarian's domain beckons the bravest of the Horde!\n\n" ..
                            "⚔️ Sharpen your blades and steady your hearts - dragon bones await our collection!\n" ..
                            "🏔️ Venture to Blackrock Spire where darkness shall be purged by Horde might!\n" ..
                            "⏰ Punctuality is the mark of a true warrior - be ready for glorious battle!\n\n" ..
                            "Victory or death! The Horde endures!",
            
            ONYXIA = "🐲 Behold! The Broodmother's lair shall echo with the roars of the Horde!\n\n" ..
                    "⚔️ Steel yourselves, warriors - Onyxia's flames shall be extinguished by our valor!\n" ..
                    "🏺 Journey to Dustwallow Marsh where legends are born and dragons fall!\n" ..
                    "⏰ Time waits for no orc - arrive ready for the hunt of a lifetime!\n\n" ..
                    "For honor and glory! Lok'tar!",
            
            ZUL_GURUB = "🌴 The ancient troll empire calls to the Horde! Zul'Gurub's secrets await our discovery!\n\n" ..
                       "⚔️ Prepare for jungle warfare - the Gurubashi trolls respect only strength!\n" ..
                       "🗡️ Navigate to Stranglethorn Vale where blood and gold flow in equal measure!\n" ..
                       "⏰ The jungle keeps its own time - arrive early to claim your destiny!\n\n" ..
                       "May the loa guide our blades! Victory to the Horde!",
            
            AQ20 = "🏺 The Ruins of Ahn'Qiraj call to the worthy! Ancient treasures await the bold!\n\n" ..
                  "⚔️ Twenty champions shall delve where lesser beings fear to tread!\n" ..
                  "🏜️ Journey to Silithus where the sands hide both fortune and peril!\n" ..
                  "⏰ Desert winds shift swiftly - be present when opportunity calls!\n\n" ..
                  "For the Horde's eternal glory!",
            
            AQ40 = "👑 The Temple of Ahn'Qiraj opens its forbidden halls to the mightiest of the Horde!\n\n" ..
                  "⚔️ Forty heroes shall face the Old God's corruption - are you among them?\n" ..
                  "🏜️ Venture to Silithus where C'Thun's whispers drive mortals to madness!\n" ..
                  "⏰ Time itself bends in those accursed halls - arrive promptly or be lost!\n\n" ..
                  "Death to the Old Gods! Lok'tar Ogar!",
            
            NAXXRAMAS = "💀 The necropolis of Naxxramas floats above - will you answer death's challenge?\n\n" ..
                       "⚔️ Only the most elite warriors dare face the Lich King's chosen servants!\n" ..
                       "❄️ Steel yourselves for the Eastern Plaguelands' ultimate test!\n" ..
                       "⏰ In death's domain, tardiness means true death - be ready!\n\n" ..
                       "Victory over undeath! For the living Horde!",
            
            DEFAULT = "⚔️ Champions of the Horde unite! <title> awaits your legendary prowess!\n\n" ..
                     "🏺 Gather your courage and finest equipment for this epic endeavor!\n" ..
                     "⏰ Punctuality is the hallmark of true warriors - arrive ready for glory!\n\n" ..
                     "For honor, for glory, for the Horde! Lok'tar Ogar!"
        },
        
        Alliance = {
            MOLTEN_CORE = "🔥 Champions of the Alliance! The fires of Molten Core shall test our mettle!\n\n" ..
                         "⚔️ Don your finest armor and steel your hearts - Ragnaros awaits justice!\n" ..
                         "🏺 Gather at Blackrock Mountain where Light shall triumph over darkness!\n" ..
                         "⏰ Arrive prepared and punctual - honor demands nothing less!\n\n" ..
                         "For the Alliance! By the Light!",
            
            BLACKWING_LAIR = "🐲 The corruption of Nefarian ends now! The Alliance shall cleanse Blackwing Lair!\n\n" ..
                            "⚔️ Prepare for battle against the Black Dragonflight's vilest spawn!\n" ..
                            "🏔️ Journey to Blackrock Spire where righteousness shall prevail!\n" ..
                            "⏰ Discipline and timing are our strengths - be ready for victory!\n\n" ..
                            "Light guide our blades! For the Alliance!",
            
            ONYXIA = "🐲 Justice comes for the Broodmother! Onyxia's reign of terror ends today!\n\n" ..
                    "⚔️ Ready your weapons, heroes - the dragoness shall face Alliance might!\n" ..
                    "🏺 Venture to Dustwallow Marsh where legends are forged in dragonfire!\n" ..
                    "⏰ Valor waits for no one - arrive ready to claim victory!\n\n" ..
                    "By the Light, we shall prevail!",
            
            ZUL_GURUB = "🌴 The cursed troll empire shall know Alliance justice! Zul'Gurub awaits liberation!\n\n" ..
                       "⚔️ Prepare for jungle combat - ancient evils lurk in every shadow!\n" ..
                       "🗡️ Navigate to Stranglethorn Vale where courage conquers corruption!\n" ..
                       "⏰ The jungle hides many dangers - arrive early to ensure success!\n\n" ..
                       "May the Light illuminate our path to victory!",
            
            AQ20 = "🏺 The Ruins of Ahn'Qiraj yield their secrets to the worthy Alliance!\n\n" ..
                  "⚔️ Twenty heroes shall brave what lesser mortals dare not face!\n" ..
                  "🏜️ Journey to Silithus where ancient treasures await the bold!\n" ..
                  "⏰ Desert sands shift with time - be present when glory calls!\n\n" ..
                  "For the Alliance's eternal honor!",
            
            AQ40 = "👑 The Temple of Ahn'Qiraj opens to the Alliance's finest champions!\n\n" ..
                  "⚔️ Forty heroes shall face the Old God's madness - stand with us!\n" ..
                  "🏜️ Venture to Silithus where C'Thun's corruption shall be cleansed!\n" ..
                  "⏰ In the Old Gods' realm, precision is survival - arrive on time!\n\n" ..
                  "Light triumph over shadow! For the Alliance!",
            
            NAXXRAMAS = "💀 The floating necropolis challenges the Alliance's bravest souls!\n\n" ..
                       "⚔️ Only the most dedicated heroes can face Kel'Thuzad's domain!\n" ..
                       "❄️ Prepare for the Eastern Plaguelands' ultimate confrontation!\n" ..
                       "⏰ Death waits for no one - arrive ready to defy the grave!\n\n" ..
                       "Light preserve us! Victory over the undead!",
            
            DEFAULT = "⚔️ Noble heroes of the Alliance! <title> calls for your legendary skill!\n\n" ..
                     "🏺 Gather your courage and finest gear for this noble quest!\n" ..
                     "⏰ Honor demands punctuality - arrive ready for glory!\n\n" ..
                     "For king and country! For the Alliance!"
        }
    }
end

-- Helper function to sanitize calendar event titles (from WorldBuffs)
function CalendarHelper:SanitizeEventTitle(title)
    if not title then return "Raid Event" end
    
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
        sanitized = "Raid Event"
    end
    return sanitized
end

-- List all available events from saved data
function CalendarHelper:ListAvailableEvents()
    local calendarData = self:ReadCalendarHelperData()
    if not calendarData or not calendarData.events then
        print("CalendarHelper: No events found in saved data")
        return {}
    end
    
    local eventList = {}
    for eventID, eventData in pairs(calendarData.events) do
        table.insert(eventList, {
            id = eventID,
            title = eventData.title,
            date = eventData.date,
            time = eventData.time,
            status = eventData.status
        })
    end
    
    -- Sort by date
    table.sort(eventList, function(a, b)
        return a.date < b.date
    end)
    
    print("CalendarHelper: Available Events (Server Time):")
    for i, event in ipairs(eventList) do
        print(string.format("  %d. %s - %s at %s PST (%s)", i, event.title, event.date, event.time, event.status))
    end
    
    return eventList
end

-- Create guild event by index from the list
function CalendarHelper:CreateEventByIndex(index)
    local eventList = self:ListAvailableEvents()
    if not eventList[index] then
        print("CalendarHelper: Invalid event index " .. (index or "nil"))
        return false
    end
    
    local event = eventList[index]
    print("CalendarHelper: Creating guild event for: " .. event.title)
    return self:CreateGuildEventFromData(event.id)
end

-- Slash command to manage CalendarHelper events
SLASH_CALENDARHELPER1 = "/calendarhelper"
SLASH_CALENDARHELPER2 = "/ch"
SlashCmdList["CALENDARHELPER"] = function(msg)
    if not msg or msg == "" then
        print("CalendarHelper Commands:")
        print("  /ch list - List all available events")
        print("  /ch create <index> - Create guild event by index number")
        print("  /ch status - Show saved variable status")
        return
    end
    
    local command, arg = msg:match("^(%S+)%s*(.*)$")
    
    if command == "list" then
        CalendarHelper:ListAvailableEvents()
    elseif command == "create" then
        local index = tonumber(arg)
        if index then
            CalendarHelper:CreateEventByIndex(index)
        else
            print("CalendarHelper: Invalid index. Use /ch list to see available events")
        end
    elseif command == "status" then
        CalendarHelper:PrintSavedVariableStatus()
    else
        print("CalendarHelper: Unknown command '" .. command .. "'. Use /ch for help.")
    end
end

-- Initialize CalendarHelper when the addon loads
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "ClassicCalendar" then
        CalendarHelper:Initialize()
    elseif event == "PLAYER_LOGIN" then
        -- Print status after login when all saved variables should be loaded
        C_Timer.After(2, function()
            CalendarHelper:PrintSavedVariableStatus()
            print("CalendarHelper: Use '/ch list' to see available events for guild event creation")
        end)
    end
end)

-- Make CalendarHelper globally available
_G.CalendarHelper = CalendarHelper

-- Initialize CalendarHelper when the addon loads
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "ClassicCalendar" then
        CalendarHelper:Initialize()
    elseif event == "PLAYER_LOGIN" then
        -- Print status after login when all saved variables should be loaded
        C_Timer.After(2, function()
            CalendarHelper:PrintSavedVariableStatus()
            print("CalendarHelper: Use '/ch list' to see available events for guild event creation")
        end)
    end
end)

-- Make CalendarHelper globally available
_G.CalendarHelper = CalendarHelper
