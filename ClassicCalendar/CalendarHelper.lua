-- CalendarHelper.lua
-- Helper functions for reading calendar data from saved variables

local CalendarHelper = {}
_G.CalendarHelper = CalendarHelper  -- Export immediately

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

-- Check if an event with the same title and date already exists
function CalendarHelper:EventAlreadyExists(eventTitle, month, day, year, hour, minute)
    -- Get the month offset for the target date
    local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
    local currentYear = currentCalendarTime.year
    local currentMonth = currentCalendarTime.month
    
    local yearDiff = year - currentYear
    local monthOffset = yearDiff * 12 + (month - currentMonth)
    
    -- Get number of events on that day
    local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day)
    
    -- Check each event on that day
    for i = 1, numEvents do
        local event = C_Calendar.GetDayEvent(monthOffset, day, i)
        if event and event.calendarType == "GUILD_EVENT" then
            local existingTitle = event.isCustomTitle and event.title or (event.title and _G[event.title] or "")
            
            -- Check if title matches (case-insensitive)
            if existingTitle and existingTitle:lower() == eventTitle:lower() then
                -- Check if time matches (within 5 minutes tolerance)
                local eventTime = event.startTime
                if eventTime and eventTime.hour == hour and math.abs(eventTime.minute - minute) <= 5 then
                    if DEBUG_MODE then
                        print("CalendarHelper: Duplicate event found - '" .. existingTitle .. "' at " .. hour .. ":" .. string.format("%02d", minute))
                    end
                    return true
                end
            end
        end
    end
    
    return false
end

-- Create guild event with specified date (based on WorldBuffs implementation)
function CalendarHelper:CreateGuildEventWithDate(eventData, selectedDate)
    -- Check for duplicate events first
    local eventTitle = self:SanitizeEventTitle(eventData.title)
    if self:EventAlreadyExists(eventTitle, selectedDate.month, selectedDate.day, selectedDate.year, selectedDate.hour, selectedDate.minute) then
        print("CalendarHelper: Déjà vu! '" .. eventTitle .. "' is already etched into the annals of " .. selectedDate.month .. "/" .. selectedDate.day .. "/" .. selectedDate.year .. ". Rally thyself elsewhere, brave adventurer.")
        return
    end
    
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
        
        -- Wait longer for UI to fully load before setting fields
        C_Timer.After(0.5, function()
            -- Set the event date explicitly
            if C_Calendar and C_Calendar.EventSetDate then
                C_Calendar.EventSetDate(selectedDate.month, selectedDate.day, selectedDate.year)
                
                if DEBUG_MODE then
                    print("CalendarHelper: Set event date to " .. selectedDate.month .. "/" .. selectedDate.day .. "/" .. selectedDate.year)
                end
            end
            
            -- Set event type to Raid
            if C_Calendar and C_Calendar.EventSetType then
                C_Calendar.EventSetType(Enum.CalendarEventType.Raid)
                CalendarCreateEventFrame.selectedEventType = Enum.CalendarEventType.Raid
                
                if DEBUG_MODE then
                    print("CalendarHelper: Set event type to Raid")
                end
                
                -- Update the event type dropdown to reflect the change
                if CalendarCreateEvent_UpdateEventType then
                    CalendarCreateEvent_UpdateEventType()
                end
            end
            
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
            
            -- Actually set the description via API
            if C_Calendar and C_Calendar.EventSetDescription then
                C_Calendar.EventSetDescription(description)
                if DEBUG_MODE then
                    print("CalendarHelper: Set event description (" .. string.len(description) .. " chars)")
                end
            end
            
            -- Set the lock event checkbox to checked
            if CalendarCreateEventLockEventCheck then
                CalendarCreateEventLockEventCheck:SetChecked(true)
                if CalendarCreateEvent_SetLockEvent then
                    CalendarCreateEvent_SetLockEvent()
                end
            end
            
            -- Wait a bit more, then set time after event is fully initialized
            C_Timer.After(0.3, function()
                -- CRITICAL: WoW Calendar uses 12-hour format internally
                -- Need to convert 24-hour time from SavedVariables to 12-hour + AM/PM
                local hour24 = selectedDate.hour
                local minute = selectedDate.minute
                
                -- Convert 24-hour to 12-hour + AM/PM
                local hour12, isAM
                if hour24 == 0 then
                    hour12 = 12
                    isAM = true  -- midnight
                elseif hour24 < 12 then
                    hour12 = hour24
                    isAM = true  -- morning
                elseif hour24 == 12 then
                    hour12 = 12
                    isAM = false  -- noon
                else
                    hour12 = hour24 - 12
                    isAM = false  -- afternoon/evening
                end
                
                if DEBUG_MODE then
                    local timeLabel = ""
                    if hour24 == 12 then
                        timeLabel = "noon"
                    elseif hour24 == 0 then
                        timeLabel = "midnight"
                    end
                    print("CalendarHelper: Converting 24-hour " .. hour24 .. ":" .. string.format("%02d", minute) .. " to 12-hour " .. hour12 .. ":" .. string.format("%02d", minute) .. " " .. (isAM and "AM" or "PM") .. " (" .. timeLabel .. ")")
                end
                
                -- Set the UI fields directly before calling the API
                if CalendarCreateEventFrame then
                    CalendarCreateEventFrame.selectedHour = hour12
                    CalendarCreateEventFrame.selectedMinute = minute
                    CalendarCreateEventFrame.selectedAM = isAM
                    
                    if DEBUG_MODE then
                        print("CalendarHelper: Set UI fields - Hour: " .. hour12 .. ", Minute: " .. minute .. ", AM: " .. tostring(isAM))
                    end
                    
                    -- Update the dropdowns to reflect the new values
                    if CalendarCreateEvent_UpdateEventTime then
                        CalendarCreateEvent_UpdateEventTime()
                        
                        if DEBUG_MODE then
                            print("CalendarHelper: Updated dropdowns via CalendarCreateEvent_UpdateEventTime()")
                        end
                    end
                end
                
                -- Now call the API to set the time
                -- We need to use CalendarCreateEvent_SetEventTime() which properly converts 12-hour + AM/PM to 24-hour
                if CalendarCreateEvent_SetEventTime then
                    if DEBUG_MODE then
                        print("CalendarHelper: Calling CalendarCreateEvent_SetEventTime() to convert and set time")
                    end
                    CalendarCreateEvent_SetEventTime()
                    
                    -- Wait a moment for the time to be set, then verify
                    C_Timer.After(0.1, function()
                        if DEBUG_MODE then
                            -- Try to read back the time from the event form fields
                            if CalendarCreateEventFrame and CalendarCreateEventFrame.selectedHour then
                                local uiHour = CalendarCreateEventFrame.selectedHour
                                local uiMinute = CalendarCreateEventFrame.selectedMinute
                                local uiAM = CalendarCreateEventFrame.selectedAM
                                print("CalendarHelper: UI shows - Hour: " .. uiHour .. ", Minute: " .. uiMinute .. ", AM: " .. tostring(uiAM))
                                
                                -- Calculate what 24-hour value this represents
                                local ui24Hour = uiHour
                                if not CalendarFrame.militaryTime then
                                    -- Convert from 12-hour + AM/PM to 24-hour
                                    if uiAM then
                                        if uiHour == 12 then
                                            ui24Hour = 0  -- 12 AM = midnight = 0
                                        else
                                            ui24Hour = uiHour  -- 1-11 AM stays same
                                        end
                                    else
                                        if uiHour == 12 then
                                            ui24Hour = 12  -- 12 PM = noon = 12
                                        else
                                            ui24Hour = uiHour + 12  -- 1-11 PM adds 12
                                        end
                                    end
                                end
                                print("CalendarHelper: UI represents 24-hour: " .. ui24Hour .. ":" .. string.format("%02d", uiMinute))
                            end
                        end
                    end)
                    
                    -- Verify what time was actually set
                    if DEBUG_MODE and C_Calendar.EventGetTime then
                        local setHour, setMinute = C_Calendar.EventGetTime()
                        print("CalendarHelper: Verified time after set: " .. (setHour or "nil") .. ":" .. (setMinute or "nil"))
                    end
                    
                    -- Force UI refresh
                    if CalendarCreateEventFrame and CalendarCreateEventFrame.Update then
                        CalendarCreateEventFrame:Update()
                    end
                    
                    if DEBUG_MODE then
                        print("CalendarHelper: Time set via API")
                    end
                end
                
                -- Add comprehensive event validation logging
                C_Timer.After(0.1, function()
                    print("=== CalendarHelper: Event Form State Before Create ===")
                    print("  Title: " .. (CalendarCreateEventTitleEdit and CalendarCreateEventTitleEdit:GetText() or "nil"))
                    print("  Type: " .. (CalendarCreateEventFrame.selectedEventType or "nil"))
                    print("  Hour: " .. (CalendarCreateEventFrame.selectedHour or "nil"))
                    print("  Minute: " .. (CalendarCreateEventFrame.selectedMinute or "nil"))
                    print("  AM: " .. tostring(CalendarCreateEventFrame.selectedAM))
                    
                    if C_Calendar.EventGetDate then
                        local month, day, year = C_Calendar.EventGetDate()
                        print("  Date from API: " .. (month or "nil") .. "/" .. (day or "nil") .. "/" .. (year or "nil"))
                    end
                    
                    if CalendarCreateEventDescriptionContainer and CalendarCreateEventDescriptionContainer.ScrollingEditBox then
                        local desc = CalendarCreateEventDescriptionContainer.ScrollingEditBox:GetText()
                        print("  Description length: " .. (desc and string.len(desc) or 0))
                    end
                    
                    print("  Calendar view month/year: " .. (CalendarFrame.viewedMonth or "nil") .. "/" .. (CalendarFrame.viewedYear or "nil"))
                    print("  Target event month/year: " .. selectedDate.month .. "/" .. selectedDate.year)
                    print("=== End Event Form State ===")
                end)
            end)
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
    
    -- Remove any emojis and special UTF-8 characters that WoW can't handle
    -- Keep only ASCII printable characters, newlines, and basic punctuation
    description = description:gsub("[^\32-\126\n\r]", "")
    
    -- Ensure description doesn't exceed 256 characters
    if #description > 256 then
        description = description:sub(1, 253) .. "..."
    end
    
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

-- Get raid-specific witty descriptions (max 256 chars)
function CalendarHelper:GetRaidDescriptions()
    return {
        Horde = {
            MOLTEN_CORE = "Heroes of the Horde! Molten Core awaits!\nGather your finest gear - Ragnaros trembles!\nRally at Blackrock Mountain on time.\n\nLok'tar Ogar!",
            
            BLACKWING_LAIR = "Nefarian's domain beckons the brave!\nSharpen your blades - dragon bones await!\nVenture to Blackrock Spire prepared.\n\nVictory or death!",
            
            ONYXIA = "The Broodmother's lair awaits the Horde!\nSteel yourselves - Onyxia's flames shall fall!\nJourney to Dustwallow Marsh on time.\n\nLok'tar!",
            
            ZUL_GURUB = "Zul'Gurub's secrets await discovery!\nPrepare for jungle warfare and glory!\nNavigate to Stranglethorn Vale ready.\n\nVictory to the Horde!",
            
            AQ20 = "The Ruins of Ahn'Qiraj await the worthy!\nTwenty champions shall claim ancient treasures!\nJourney to Silithus prepared.\n\nFor the Horde!",
            
            AQ40 = "The Temple of Ahn'Qiraj opens to the mighty!\nForty heroes shall face C'Thun's corruption!\nVenture to Silithus on time.\n\nLok'tar Ogar!",
            
            NAXXRAMAS = "Naxxramas floats above - answer the challenge!\nOnly elite warriors face the Lich King's servants!\nSteel yourselves for the Plaguelands.\n\nFor the Horde!",
            
            DEFAULT = "Champions of the Horde unite!\n<title> awaits your legendary prowess!\nGather your courage and arrive on time.\n\nLok'tar Ogar!"
        },
        
        Alliance = {
            MOLTEN_CORE = "Champions of the Alliance! Molten Core awaits!\nDon your finest armor - Ragnaros faces justice!\nGather at Blackrock Mountain on time.\n\nFor the Alliance!",
            
            BLACKWING_LAIR = "Nefarian's corruption ends now!\nPrepare for battle against the Black Dragonflight!\nJourney to Blackrock Spire ready.\n\nLight guide us!",
            
            ONYXIA = "Justice comes for the Broodmother!\nReady your weapons - the dragoness shall fall!\nVenture to Dustwallow Marsh on time.\n\nBy the Light!",
            
            ZUL_GURUB = "The cursed troll empire faces Alliance justice!\nPrepare for jungle combat against ancient evils!\nNavigate to Stranglethorn Vale ready.\n\nLight guide us!",
            
            AQ20 = "The Ruins of Ahn'Qiraj yield their secrets!\nTwenty heroes shall brave ancient treasures!\nJourney to Silithus prepared.\n\nFor the Alliance!",
            
            AQ40 = "The Temple of Ahn'Qiraj opens to the finest!\nForty heroes shall face C'Thun's madness!\nVenture to Silithus on time.\n\nFor the Alliance!",
            
            NAXXRAMAS = "The floating necropolis challenges the brave!\nOnly the most dedicated face Kel'Thuzad's domain!\nPrepare for the Plaguelands.\n\nLight preserve us!",
            
            DEFAULT = "Noble heroes of the Alliance!\n<title> calls for your legendary skill!\nGather your courage and arrive on time.\n\nFor the Alliance!"
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
    if not calendarData then
        print("CalendarHelper: CalendarHelperDB not loaded")
        print("CalendarHelper: Make sure CalendarHelper.lua exists in SavedVariables folder")
        return {}
    end
    
    if not calendarData.events then
        print("CalendarHelper: CalendarHelperDB loaded but no 'events' table found")
        print("CalendarHelper: Data structure: " .. tostring(calendarData))
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
        
        -- Additional debugging info
        if CalendarHelperDB then
            print("CalendarHelperDB exists")
            if CalendarHelperDB.events then
                local count = 0
                for _ in pairs(CalendarHelperDB.events) do
                    count = count + 1
                end
                print("  Events table found with " .. count .. " entries")
            else
                print("  Events table NOT found")
            end
            if CalendarHelperDB.metadata then
                print("  Metadata found - Last import: " .. (CalendarHelperDB.metadata.last_import or "unknown"))
            end
        else
            print("CalendarHelperDB does NOT exist - check SavedVariables folder")
        end
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
