-- Patch: Add debug print to GameTime_GetFormattedTime
function GameTime_GetFormattedTime(hour, minute, showAMPM)
    print("[ClassicCalendar] GameTime_GetFormattedTime called with hour:", hour, "minute:", minute, "showAMPM:", showAMPM)
    -- Example implementation: 24-hour format, optionally with AM/PM
    if showAMPM then
        local suffix = "AM"
        local displayHour = hour
        if hour == 0 then
            displayHour = 12
        elseif hour == 12 then
            suffix = "PM"
        elseif hour > 12 then
            displayHour = hour - 12
            suffix = "PM"
        end
        return string.format("%d:%02d %s", displayHour, minute, suffix)
    else
        return string.format("%02d:%02d", hour, minute)
    end
end-- Patch: Add debug print to GameTime_GetFormattedTime
-- This function is missing in the codebase, so we will define it here for debugging purposes.
function GameTime_GetFormattedTime(hour, minute, showAMPM)
    print("[ClassicCalendar] GameTime_GetFormattedTime called with hour:", hour, "minute:", minute, "showAMPM:", showAMPM)
    -- Basic formatting for demonstration; adjust as needed for your locale
    local ampm = ""
    local displayHour = hour
    if showAMPM then
        if hour == 0 then
            displayHour = 12
            ampm = "AM"
        elseif hour == 12 then
            displayHour = 12
            ampm = "PM"
        elseif hour > 12 then
            displayHour = hour - 12
            ampm = "PM"
        else
            ampm = "AM"
        end
    end
    return string.format("%d:%02d %s", displayHour, minute, ampm)
end
