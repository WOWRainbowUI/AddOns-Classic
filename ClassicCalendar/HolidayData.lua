local L = CLASSIC_CALENDAR_L
local localeString = tostring(GetLocale())
local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
local SECONDS_IN_DAY = 24 * 60 * 60
local date = date
local time = time
local floor = floor
local tinsert = tinsert
local CopyTable = CopyTable

local region = GetCVar("portal")
if string.find(GetRealmName(), '(AU)') ~= nil then
	region = "AU"
end

local resetHour
if region == "EU" then
	resetHour = 5
elseif region == "KR" then
	resetHour = 6
else
	resetHour = 7
end

local WEEKDAYS = {
	Sunday = 1,
	Monday = 2,
	Tuesday = 3,
	Wednesday = 4,
	Thursday = 5,
	Friday = 6,
	Saturday = 7
}

local isSoD = C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.Placeholder) -- "Placeholder" = SoD

local function addDaysToDate(eventDate, dayCount)
	local dateSeconds = time(eventDate)
	dateSeconds = dateSeconds + dayCount * SECONDS_IN_DAY
	return date("*t", dateSeconds)
end


function SetMinTime(dateD)
	local newDate = {}
	for k, v in pairs(dateD) do
		newDate[k] = v
	end
	newDate.hour = 0
	newDate.min = 1
	return newDate
end


function SetMaxTime(dateD)
	local newDate = {}
	for k, v in pairs(dateD) do
		newDate[k] = v
	end
	newDate.hour = 23
	newDate.min = 59
	return newDate
end

local function changeWeekdayOfDate(dateD, weekday, weekAdjustment)
	-- Change date to the chosen weekday of the same week
	local dateTime = time(dateD)
	local dateWeekday = date("*t", dateTime)["wday"]

	local delta = (dateWeekday - weekday) * SECONDS_IN_DAY
	local result = dateTime - delta
	if weekAdjustment ~= nil then
		result = result + (weekAdjustment * (7 * SECONDS_IN_DAY))
	end
	return date("*t", result)
end

local function GetEasterDate(year)
	local leap_year
	if year % 4 == 0 then
		if year % 100 == 0 then
			if year % 400 == 0 then
				leap_year = true
			else
				leap_year = false
			end
		else
			leap_year = true
		end
	else
		leap_year = false
	end
	local a = year % 19
	local b = floor(year / 100)
	local c = year % 100
	local d = floor(b / 4)
	local e = b % 4
	local f = floor((b + 8) / 25)
	local g = floor((b - f + 1) / 3)
	local h = (19 * a + b - d - g + 15) % 30
	local i = floor(c / 4)
	local k = c % 4
	local n = (32 + 2 * e + 2 * i - h - k) %7
	local m = floor((a + 11 * h + 22 * n) / 451)
	local month = floor((h + n - 7 * m + 114) / 31)
	local day = (h + n - 7 * m + 114) % 31 + 1
	if month == 2 then	--adjust dates in February
		day = leap_year and day - 2 or day - 3
	end
	return { year=year, month=month, day=day }
end

local function GetNewMoons(dateD)
	local LUNAR_MONTH = 29.5305888531  -- https://en.wikipedia.org/wiki/Lunar_month
	local y = dateD.year
	local m = dateD.month
	local d = dateD.day
	-- https://www.subsystems.us/uploads/9/8/9/4/98948044/moonphase.pdf
	if (m <= 2) then
		y = y - 1
		m = m + 12
	end
	local a = floor(y / 100)
	local b = floor(a / 4)
	local c = 2 - a + b
	local e = floor(365.25 * (y + 4716))
	local f = floor(30.6001 * (m + 1))
	local julian_day = c + d + e + f - 1524.5
	local days_since_last_new_moon = julian_day - 2451549.5
	local new_moons = days_since_last_new_moon / LUNAR_MONTH
	-- local days_into_cycle = (new_moons % 1) * LUNAR_MONTH
	return new_moons
end

local function InChineseNewYear(dateD)
	--[[ The date is decided by the Chinese Lunar Calendar, which is based on the
	cycles of the moon and sun and is generally 21–51 days behind the Gregorian
	(internationally-used) calendar. The date of Chinese New Year changes every
	year, but it always falls between January 21st and February 20th. --]]
	return floor(GetNewMoons(dateD)) > floor(GetNewMoons({ year=dateD.year, month=1, day=20 }))
end

local function GetChineseNewYear(year)
	-- Does not quite line up with https://www.travelchinaguide.com/essential/holidays/new-year/dates.htm
	for i=0, 30 do
		local start = { year=year, month=1, day=21 }
		start = addDaysToDate(start, i)
		if(InChineseNewYear(start)) then
			return start
		end
	end
end

local function GetLunarFestivalStart(year)
	local cny = GetChineseNewYear(year)
	cny = addDaysToDate(cny, -7)
	cny.hour = 9
	cny.min = 0
	return cny
end

local function GetLunarFestivalEnd(year)
	local cny = GetChineseNewYear(year)
	cny = addDaysToDate(cny, 7)
	cny.hour = 9
	cny.min = 0
	return cny
end


local function GetFollowingSunday(dateD)
	return changeWeekdayOfDate(dateD, WEEKDAYS.Sunday, 1)
end

local function adjustMonthByOffset(dateD, offset)
	dateD.month = dateD.month + offset
	if dateD.month > 12 then
		dateD.year = dateD.year + 1
		dateD.month = 1
	elseif dateD.month == 0 then
		dateD.year = dateD.year - 1
		dateD.month = 12
	end
end

local ZIndexes = {
	lowest=1,
	low=2,
	medium=3,
	high=4,
	highest=5
}

local CLASSIC_CALENDAR_HOLIDAYS = {
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["LunarFestival"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["LunarFestival"]["description"],
		startDate={ year=2025, month=2, day=1, hour=9, min=0 },
		endDate={ year=2025, month=2, day=15, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_LunarFestivalStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_LunarFestivalOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_LunarFestivalEnd",
		ZIndex=ZIndexes.high
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["LoveisintheAir"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["LoveisintheAir"]["description"],
		startDate={ year=2025, month=2, day=7, hour=9, min=0 },
		endDate={ year=2025, month=2, day=20, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_LoveIsInTheAirStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_LoveIsInTheAirOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_LoveIsInTheAirEnd",
		ZIndex=ZIndexes.high
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["Noblegarden"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["Noblegarden"]["description"],
		startDate={ year=2025, month=4, day=20, hour=9, min=0 },
		endDate={ year=2025, month=4, day=27, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_NoblegardenStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_NoblegardenOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_NoblegardenEnd",
		ZIndex=ZIndexes.high
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["ChildrensWeek"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["ChildrensWeek"]["description"],
		startDate={ year=2025, month=5, day=1, hour=9, min=0 },
		endDate={ year=2025, month=5, day=7, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_ChildrensWeekStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_ChildrensWeekOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_ChildrensWeekEnd",
		ZIndex=ZIndexes.high
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["MidsummerFireFestival"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["MidsummerFireFestival"]["description"],
		startDate={ year=2025, month=6, day=21, hour=9, min=0 },
		endDate={ year=2025, month=7, day=5, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_MidsummerFireFestivalStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_MidsummerFireFestivalOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_MidsummerFireFestivalEnd",
		ZIndex=ZIndexes.high
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["HarvestFestival"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["HarvestFestival"]["description"],
		startDate={ year=2025, month=9, day=27, hour=9, min=0 },
		endDate={ year=2025, month=10, day=4, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalEnd",
		ZIndex=ZIndexes.high
	},
	--[[
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["Brewfest"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["Brewfest"]["description"],
		startDate={ year=2025, month=9, day=20, hour=9, min=0 },
		endDate={ year=2025, month=10, day=4, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_BrewfestStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_BrewfestOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_BrewfestEnd",
		ZIndex=ZIndexes.high
	},
	--]]
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["HallowsEnd"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["HallowsEnd"]["description"],
		startDate={ year=2025, month=10, day=18, hour=9, min=0 },
		endDate={ year=2025, month=11, day=1, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_HallowsEndStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_HallowsEndOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_HallowsEndEnd",
		ZIndex=ZIndexes.high
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["PilgrimsBounty"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["PilgrimsBounty"]["description"],
		startDate={ year=2025, month=11, day=22, hour=9, min=0 },
		endDate={ year=2025, month=11, day=28, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalEnd",
		ZIndex=ZIndexes.high
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["WintersVeil"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["WintersVeil"]["description"],
		startDate={ year=2025, month=12, day=15, hour=9, min=0 },
		endDate={ year=2026, month=1, day=2, hour=23, min=59 },
		startTexture="Interface/Calendar/Holidays/Calendar_WinterVeilStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WinterVeilOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_WinterVeilEnd",
		ZIndex=ZIndexes.high
	},
	 {
		-- Confirmed, coincides with Easter Sunday, lasts 1 day
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["Noblegarden"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["Noblegarden"]["description"],
		startDate=SetMinTime(GetEasterDate(currentCalendarTime.year)),
		endDate=SetMaxTime(GetEasterDate(currentCalendarTime.year)),
		startTexture="Interface/Calendar/Holidays/Calendar_NoblegardenStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_NoblegardenOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_NoblegardenEnd",
		ZIndex=ZIndexes.high
	},
	{
		-- Unconfirmed, no basis in reality for dates known
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["ChildrensWeek"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["ChildrensWeek"]["description"],
		startDate={ year=2024, month=5, day=1, hour=13, min=0 },
		endDate={ year=2024, month=5, day=8, hour=13, min=0 },
		artConfig="ChildrensWeekArt",
		startTexture="Interface/Calendar/Holidays/Calendar_ChildrensWeekStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_ChildrensWeekOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_ChildrensWeekEnd",
		ZIndex=ZIndexes.medium
	},
	{
		-- Uncofirmed. No basis in reality for dates known
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["HarvestFestival"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["HarvestFestival"]["description"],
		startDate={ year=2024, month=9, day=13, hour=3, min=0 },
		endDate={ year=2024, month=9, day=20, hour=3, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_HarvestFestivalEnd",
		ZIndex=ZIndexes.high
	},
	{
		-- Confirmed, static dates
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["HallowsEnd"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["HallowsEnd"]["description"],
		startDate={ year=2024, month=10, day=18, hour=4, min=0 },
		endDate={ year=2024, month=11, day=1, hour=3, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_HallowsEndStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_HallowsEndOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_HallowsEndEnd",
		ZIndex=ZIndexes.high
	},
	{
		-- Unconfirmed, sorta coincides with Chinese New Year, lasts 2 weeks
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["LunarFestival"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["LunarFestival"]["description"],
		-- startDate=GetLunarFestivalStart(currentCalendarTime.year),
		-- endDate=GetLunarFestivalEnd(currentCalendarTime.year),
		startDate={ year=2024, month=2, day=3, hour=resetHour, min=0 },
		endDate={ year=2024, month=2, day=23, hour=resetHour, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_LunarFestivalStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_LunarFestivalOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_LunarFestivalEnd",
		ZIndex=ZIndexes.high
	},
	{
		-- Confirmed, coincides with Valentine's Day, static dates
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["LoveisintheAir"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["LoveisintheAir"]["description"],
		startDate={ year=2024, month=2, day=11, hour=13, min=0 },
		endDate={ year=2024, month=2, day=16, hour=13, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_LoveInTheAirStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_LoveInTheAirOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_LoveInTheAirEnd",
		ZIndex=ZIndexes.medium
	},
	{
		-- Confirmed, coincides with Summer Solstice for North America, starts the following day and lasts a week
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["MidsummerFireFestival"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["MidsummerFireFestival"]["description"],
		startDate={ year=2024, month=6, day=21, hour=7, min=0 },
		endDate={ year=2024, month=6, day=28, hour=7, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_MidsummerStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_MidsummerOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_MidsummerEnd",
		ZIndex=ZIndexes.highest
	},
	{
		-- Confirmed, always the last day/night of Midsummer Fire Festival
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["FireworksSpectacular"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["FireworksSpectacular"]["description"],
		startDate={ year=2024, month=6, day=27, hour=9, min=0 },
		endDate={ year=2024, month=6, day=28, hour=3, min=0 },
		artConfig="FireworksSpectacularArt",
		startTexture="Interface/Calendar/Holidays/Calendar_Fireworks",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_Fireworks",
		endTexture="Interface/Calendar/Holidays/Calendar_Fireworks",
		ZIndex=ZIndexes.low
	},
}

local WeeklyHolidays = 	{
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["description"],
		startDate={ year=2024, month=2, day=11, hour=14, min=0 },
		endDate={ year=2024, month=2, day=11, hour=16, min=0 },
		frequency=7,
		CVar="calendarShowWeeklyHolidays",
		startTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		endTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		ZIndex=ZIndexes.low,
		calendarType = "HOLIDAY"
	,sequenceType = "START"
	},
}

local SoDWeeklyHolidays = {
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["description"],
		startDate={ year=2024, month=2, day=14, hour=19, min=0 },
		endDate={ year=2024, month=2, day=14, hour=21, min=0 },
		frequency=7,
		CVar="calendarShowWeeklyHolidays",
		startTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		endTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		ZIndex=ZIndexes.low,
		calendarType = "HOLIDAY"
	,sequenceType = "START"
	},
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["description"],
		startDate={ year=2024, month=2, day=11, hour=14, min=0 },
		endDate={ year=2024, month=2, day=11, hour=16, min=0 },
		frequency=7,
		CVar="calendarShowWeeklyHolidays",
		startTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		endTexture="Interface/Calendar/Holidays/Calendar_FishingExtravaganza",
		ZIndex=ZIndexes.low,
		calendarType = "HOLIDAY"
	,sequenceType = "START"
	},
}

local battlegroundWeekends = {
	arathiBasin={
		name=L.HolidayLocalization[localeString]["CalendarPVP"]["ArathiBasin"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarPVP"]["ArathiBasin"]["description"],
		startDate={ year=2025, month=8, day=29, hour=0, min=0 }, -- last weekend (Friday, midnight, server time)
		endDate={ year=2025, month=9, day=2, hour=resetHour, min=0 },
		frequency=21,
		CVar="calendarShowBattlegrounds",
		artConfig="BattlegroundsArt",
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsEnd",
		ZIndex=ZIndexes.medium
	},
	alteracValley={
		name=L.HolidayLocalization[localeString]["CalendarPVP"]["AlteracValley"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarPVP"]["AlteracValley"]["description"],
		startDate={ year=2025, month=9, day=5, hour=0, min=0 }, -- this coming weekend (Friday, midnight, server time)
		endDate={ year=2025, month=9, day=9, hour=resetHour, min=0 },
		frequency=21,
		CVar="calendarShowBattlegrounds",
		artConfig="BattlegroundsArt",
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsEnd",
		ZIndex=ZIndexes.medium
	},
	warsongGulch={
		name=L.HolidayLocalization[localeString]["CalendarPVP"]["WarsongGulch"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarPVP"]["WarsongGulch"]["description"],
		startDate={ year=2025, month=9, day=12, hour=0, min=0 }, -- following weekend (Friday, midnight, server time)
		endDate={ year=2025, month=9, day=16, hour=resetHour, min=0 },
		frequency=21,
		CVar="calendarShowBattlegrounds",
		artConfig="BattlegroundsArt",
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsEnd",
		ZIndex=ZIndexes.medium
	},
}

local SoDBattlegroundWeekends = {
	warsongGulch={
		name=L.HolidayLocalization[localeString]["CalendarPVP"]["WarsongGulch"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarPVP"]["WarsongGulch"]["description"],
		startDate={ year=2024, month=2, day=2, hour=0, min=1 },
		endDate={ year=2024, month=2, day=6, hour=resetHour, min=0 },
		frequency=28,
		CVar="calendarShowBattlegrounds",
		artConfig="BattlegroundsArt",
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsEnd",
		ZIndex=ZIndexes.medium
	},
	arathiBasin={
		name=L.HolidayLocalization[localeString]["CalendarPVP"]["ArathiBasin"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarPVP"]["ArathiBasin"]["description"],
		startDate={ year=2024, month=2, day=9, hour=0, min=1 },
		endDate={ year=2024, month=2, day=13, hour=resetHour, min=0 },
		frequency=28,
		CVar="calendarShowBattlegrounds",
		artConfig="BattlegroundsArt",
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendBattlegroundsEnd",
		ZIndex=ZIndexes.medium
	}
}

-- Hardcoded Darkmoon Faire schedule for 2025 (based on official Wowhead schedule)
local ClassicDarkmoonSchedule2025 = {
	-- January - Elwynn Forest
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["description"],
		startDate={ year=2025, month=1, day=7, hour=0, min=1 },
		endDate={ year=2025, month=1, day=13, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnEnd",
		ZIndex=ZIndexes.medium
	},
	-- February - Mulgore
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["description"],
		startDate={ year=2025, month=2, day=10, hour=0, min=1 },
		endDate={ year=2025, month=2, day=16, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreEnd",
		ZIndex=ZIndexes.medium
	},
	-- March - Elwynn Forest
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["description"],
		startDate={ year=2025, month=3, day=10, hour=0, min=1 },
		endDate={ year=2025, month=3, day=16, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnEnd",
		ZIndex=ZIndexes.medium
	},
	-- April - Mulgore
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["description"],
		startDate={ year=2025, month=4, day=7, hour=0, min=1 },
		endDate={ year=2025, month=4, day=13, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreEnd",
		ZIndex=ZIndexes.medium
	},
	-- May - Elwynn Forest
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["description"],
		startDate={ year=2025, month=5, day=5, hour=0, min=1 },
		endDate={ year=2025, month=5, day=11, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnEnd",
		ZIndex=ZIndexes.medium
	},
	-- June - Mulgore
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["description"],
		startDate={ year=2025, month=6, day=9, hour=0, min=1 },
		endDate={ year=2025, month=6, day=15, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreEnd",
		ZIndex=ZIndexes.medium
	},
	-- July - Elwynn Forest
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["description"],
		startDate={ year=2025, month=7, day=7, hour=0, min=1 },
		endDate={ year=2025, month=7, day=13, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnEnd",
		ZIndex=ZIndexes.medium
	},
	-- August - Mulgore
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["description"],
		startDate={ year=2025, month=8, day=4, hour=0, min=1 },
		endDate={ year=2025, month=8, day=10, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreEnd",
		ZIndex=ZIndexes.medium
	},
	-- September - Elwynn Forest
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["description"],
		startDate={ year=2025, month=9, day=8, hour=0, min=1 },
		endDate={ year=2025, month=9, day=14, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnEnd",
		ZIndex=ZIndexes.medium
	},
	-- October - Mulgore
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["description"],
		startDate={ year=2025, month=10, day=6, hour=0, min=1 },
		endDate={ year=2025, month=10, day=12, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreEnd",
		ZIndex=ZIndexes.medium
	},
	-- November - Elwynn Forest
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireElwynn"]["description"],
		startDate={ year=2025, month=11, day=10, hour=0, min=1 },
		endDate={ year=2025, month=11, day=16, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireElwynnEnd",
		ZIndex=ZIndexes.medium
	},
	-- December - Mulgore
	{
		name=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["name"],
		description=L.HolidayLocalization[localeString]["CalendarHolidays"]["DarkmoonFaireMulgore"]["description"],
		startDate={ year=2025, month=12, day=8, hour=0, min=1 },
		endDate={ year=2025, month=12, day=14, hour=23, min=59 },
		CVar="calendarShowDarkmoon",
		startTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreOngoing",
		endTexture="Interface/Calendar/Holidays/Calendar_DarkmoonFaireMulgoreEnd",
		ZIndex=ZIndexes.medium
	}
}

local SoDEvents = {
	{
		name="SoD Launch",
		description="Season of Discovery officialy launched!",
		startDate={ year=2023, month=11, day=30, hour=14, min=0 },
		endDate={ year=2023, month=11, day=30, hour=14, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		endTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ZIndex=ZIndexes.highest
	},
	{
		name="Phase 2 Launch",
		description="Season of Discovery Phase 2 officially arrives! And with it came the Arathi Basin battleground, the Stranglethorn Fishing Extravaganza, the Gnomeregan raid, and the Stranglethorn Vale PvP event!",
		startDate={ year=2024, month=2, day=8, hour=14, min=0 },
		endDate={ year=2024, month=2, day=8, hour=14, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		endTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ZIndex=ZIndexes.highest
	},
	{
		name="Phase 3 Launch",
		description="Season of Discovery Phase 3 officially arrives with level 50, Nightmare Incursions, and the Sunken Temple 20 man raid!",
		startDate={ year=2024, month=4, day=4, hour=14, min=0 },
		endDate={ year=2024, month=4, day=4, hour=14, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		endTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ZIndex=ZIndexes.highest
	},
	{
		name="Phase 4 Launch",
		description="Season of Discovery Phase 4 officially arrives with level 60 and all original classic content, plus some new experiences unique to Season of Discovery! World bosses will arrive 1 week later, and initial level 60 raids 2 weeks later.",
		startDate={ year=2024, month=7, day=11, hour=14, min=0 },
		endDate={ year=2024, month=7, day=11, hour=14, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		endTexture="Interface/Calendar/Holidays/Calendar_AnniversaryStart",
		ZIndex=ZIndexes.highest
	},
	{
		name="World Bosses Launch",
		description="Lord Kazzak and Azuregos world bosses become available globally as instanced raids, resetting twice weekly on Tuesdays and Saturdays.",
		startDate={ year=2024, month=7, day=18, hour=14, min=0 },
		endDate={ year=2024, month=7, day=18, hour=14, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		ZIndex=ZIndexes.highest
	},
	{
		name="Onyxia and Molten Core Launch",
		description="Onyxia and Molten Core raids become available globally, resetting twice weekly on Tuesdays and Saturdays.",
		startDate={ year=2024, month=7, day=25, hour=14, min=0 },
		endDate={ year=2024, month=7, day=25, hour=14, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		ZIndex=ZIndexes.highest
	},
	{
		name="Phase 5 Launch",
		description="Season of Discovery phase 5 officially arrives with Blackwing Lair and Zul'Gurub raids, and Prince Thunderaan world boss!",
		startDate={ year=2024, month=9, day=26, hour=14, min=0 },
		endDate={ year=2024, month=9, day=26, hour=14, min=0 },
		startTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		ongoingTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		endTexture="Interface/Calendar/Holidays/Calendar_WeekendWorldQuestStart",
		ZIndex=ZIndexes.highest
	}
}

local function getSoDEvents()
	-- these events are universal, so we need to adjust from server time
	-- events are defined with NA's times (MST = UTC-7, MDT = UTC-6)
	local events = SoDEvents
	local adjustment = 0

	if region == "EU" then
		-- CET = UTC + 1, CEST = UTC+2
		-- On Feb 8th, EU is 8 hours ahead
		adjustment = 8
	elseif region == "AU" then
		-- AEST = UTC+10, AEDT = UTC+11
		-- On Feb 8th, AU is 18 hours ahead
		adjustment = 18
	end

	for _, event in next, SoDEvents do
		event.startDate = date("*t", time(event.startDate) + (adjustment * 60 * 60))
		event.endDate = date("*t", time(event.endDate) + (adjustment * 60 * 60))
	end

	return events
end

local holidaySchedule = {}
local lastCacheDate = nil

local function getDSTDates(year)
	-- Start of DST is 2nd Sunday of March
	local firstDayMarch = {year=year, month=3, day=1}
	local weekAdjustment = 1
	if date("*t", time(firstDayMarch)).wday ~= WEEKDAYS.Sunday then
		weekAdjustment = weekAdjustment + 1
	end
	local secondSundayMarch = changeWeekdayOfDate(firstDayMarch, WEEKDAYS.Sunday, weekAdjustment)
	secondSundayMarch.hour = 2

	-- End of DST is 1st Sunday of November
	local firstDayNov = {year=year, month=11, day=1}
	weekAdjustment = 0
	if date("*t", time(firstDayNov)).wday ~= WEEKDAYS.Sunday then
		weekAdjustment = weekAdjustment + 1
	end
	local firstSundayNov = changeWeekdayOfDate(firstDayNov, WEEKDAYS.Sunday, weekAdjustment)
	firstSundayNov.hour = 2


	return secondSundayMarch, firstSundayNov
end

local function adjustDST(dateTime)
	local dateD = date("*t", dateTime)
	local dstStart, dstEnd = getDSTDates(dateD.year)
	if dateTime > time(dstStart) and dateTime < time(dstEnd) then
		dateTime = dateTime - (60*60)
	end
	return dateTime
end

local function addHolidayToSchedule(holiday, schedule)
	local startTime = time(holiday.startDate)
	local endTime = time(holiday.endDate)

	if holiday.artConfig == "BattlegroundsArt" or holiday.CVar == "calendarShowDarkmoon" then
		holiday.startDate = date("*t", startTime)
		holiday.endDate = date("*t", endTime)
	else
		holiday.startDate = date("*t", adjustDST(startTime))
		holiday.endDate = date("*t", adjustDST(endTime))
	end
	-- Force fishing event times to 2pm–4pm
	if holiday.name == L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["name"] then
		holiday.startDate.hour = 14
		holiday.startDate.min = 0
		holiday.endDate.hour = 16
		holiday.endDate.min = 0
	end
	-- Force BG holiday event times to fixed hours and prevent DST offset
	if holiday.artConfig == "BattlegroundsArt" then
		-- Example: 12:00 to 23:59, adjust as needed for your server/event
		holiday.startDate.hour = 12
		holiday.startDate.min = 0
		holiday.endDate.hour = 23
		holiday.endDate.min = 59
	end
	-- Force Darkmoon Faire event times to fixed hours and prevent DST offset
	if holiday.CVar == "calendarShowDarkmoon" then
		-- DMF runs Monday 00:01 to Sunday 23:59
		holiday.startDate.hour = 0
		holiday.startDate.min = 1
		holiday.endDate.hour = 23
		holiday.endDate.min = 59
	end
	-- Set iconTexture for battleground weekends
	if holiday.calendarType == "HOLIDAY" and holiday.artConfig == "BattlegroundsArt" then
		if holiday.sequenceType == "START" and holiday.startTexture then
			holiday.iconTexture = holiday.startTexture
		elseif holiday.sequenceType == "ONGOING" and holiday.ongoingTexture then
			holiday.iconTexture = holiday.ongoingTexture
		elseif holiday.sequenceType == "END" and holiday.endTexture then
			holiday.iconTexture = holiday.endTexture
		end
	end
	tinsert(schedule, holiday)
	if holiday.frequency ~= nil then
		local currentTime = time(currentCalendarTime)
		local oneYearFromNow = currentTime + (365 * SECONDS_IN_DAY)
		
		-- Generate recurring events for 1 year rolling window from current date
		while startTime < oneYearFromNow do
			local eventCopy = CopyTable(holiday)
			startTime = startTime + (SECONDS_IN_DAY * holiday.frequency)
			endTime = endTime + (SECONDS_IN_DAY * holiday.frequency)
			
			-- Skip events that are too far in the future
			if startTime > oneYearFromNow then
				break
			end
			
			eventCopy.startDate = date("*t", startTime)
			eventCopy.endDate = date("*t", endTime)
			-- Force fishing event times to 2pm–4pm
			if eventCopy.name == L.HolidayLocalization[localeString]["CalendarHolidays"]["StranglethornFishingExtravaganza"]["name"] then
				eventCopy.startDate.hour = 14
				eventCopy.startDate.min = 0
				eventCopy.endDate.hour = 16
				eventCopy.endDate.min = 0
			end
			-- Force BG holiday event times to fixed hours for recurring events
			if eventCopy.artConfig == "BattlegroundsArt" then
				-- Ensure start is Friday
				local d = eventCopy.startDate
				local weekday = date("*t", time(d)).wday
				-- WoW Lua: Sunday=1, Friday=6
				if weekday ~= 6 then
					local daysToFriday = (6 - weekday) % 7
					local newTime = time(d) + (daysToFriday * SECONDS_IN_DAY)
					eventCopy.startDate = date("*t", newTime)
				end
				eventCopy.startDate.hour = 0
				eventCopy.startDate.min = 1
				-- Ensure end is Tuesday at 7:00am
				local dEnd = eventCopy.endDate
				local weekdayEnd = date("*t", time(dEnd)).wday
				-- WoW Lua: Sunday=1, Tuesday=3
				if weekdayEnd ~= 3 then
					local daysToTuesday = (3 - weekdayEnd) % 7
					local newEndTime = time(dEnd) + (daysToTuesday * SECONDS_IN_DAY)
					eventCopy.endDate = date("*t", newEndTime)
				end
				eventCopy.endDate.hour = 7
				eventCopy.endDate.min = 0
			end
			-- Set iconTexture for battleground weekends (recurring)
			if eventCopy.calendarType == "HOLIDAY" and eventCopy.artConfig == "BattlegroundsArt" then
				if eventCopy.sequenceType == "START" and eventCopy.startTexture then
					eventCopy.iconTexture = eventCopy.startTexture
				elseif eventCopy.sequenceType == "ONGOING" and eventCopy.ongoingTexture then
					eventCopy.iconTexture = eventCopy.ongoingTexture
				elseif eventCopy.sequenceType == "END" and eventCopy.endTexture then
					eventCopy.iconTexture = eventCopy.endTexture
				end
			end
			tinsert(schedule, eventCopy)
		end
	end
end

local function GetClassicDarkmoons()
	-- Return the hardcoded 2025 schedule
	return ClassicDarkmoonSchedule2025
end

function GetClassicHolidays()
	-- Clear cache if it's a new day or if it has too many entries (indicates old buggy generation)
	local currentDate = string.format("%d-%d-%d", currentCalendarTime.year, currentCalendarTime.month, currentCalendarTime.day)
	if (lastCacheDate ~= currentDate) or (next(holidaySchedule) ~= nil and #holidaySchedule > 500) then
		if DEBUG_MODE and next(holidaySchedule) ~= nil then
			print("ClassicCalendar: Refreshing holiday cache (" .. (#holidaySchedule > 500 and "oversized: " .. #holidaySchedule .. " entries" or "new day") .. ")")
		end
		holidaySchedule = {}
		lastCacheDate = currentDate
	end
	
	if next(holidaySchedule) ~= nil then
		return holidaySchedule
	end

	-- Seasonal holidays
	for _, holiday in next, CLASSIC_CALENDAR_HOLIDAYS do
		addHolidayToSchedule(holiday, holidaySchedule)
	end

	-- Weekly holidays
	if isSoD then
		for _, holiday in next, SoDWeeklyHolidays do
			addHolidayToSchedule(holiday, holidaySchedule)
		end
	else
		for _, holiday in next, WeeklyHolidays do
			addHolidayToSchedule(holiday, holidaySchedule)
		end
	end

	-- Darkmoon
	-- TODO: For SoD, would need a separate SoD schedule with twice-monthly events
	-- For now, using Classic schedule for both
	for _, holiday in next, GetClassicDarkmoons() do
		addHolidayToSchedule(holiday, holidaySchedule)
	end

	-- Battleground weekends
	-- if isSoD then
		-- Disabling bg weekends in SoD because Blizz changed their schedule
		-- addHolidayToSchedule(SoDBattlegroundWeekends.warsongGulch, holidaySchedule)
		-- addHolidayToSchedule(SoDBattlegroundWeekends.arathiBasin, holidaySchedule)
	if not isSoD then
		addHolidayToSchedule(battlegroundWeekends.warsongGulch, holidaySchedule)
		addHolidayToSchedule(battlegroundWeekends.arathiBasin, holidaySchedule)
		addHolidayToSchedule(battlegroundWeekends.alteracValley, holidaySchedule)
	end

	-- SoD Events
	if isSoD then
		for _, holiday in next, getSoDEvents() do
			addHolidayToSchedule(holiday, holidaySchedule)
		end
	end

	-- Sort by ascending date
	table.sort(holidaySchedule, function(a,b)
		if (a.startDate.year ~= b.startDate.year) then
			return a.startDate.year < b.startDate.year
		end

		return a.startDate.yday < b.startDate.yday
	end)

	return holidaySchedule
end

function GetClassicRaidResets()
	local raidResets
	if isSoD then
		local bfdName, _ = L.DungeonLocalization[localeString][136325][1]
		local gnomerName, _ = L.DungeonLocalization[localeString][136336][1]
		local templeName, _ = L.DungeonLocalization[localeString][136360][1]
		local azuregosName = "Azuregos" -- WIP, to be replaced with proper localization if possible?
		local kazzakName = "Kazzak" -- WIP, to be replaced with proper localization if possible?
		local thunderName = "Prince Thunderaan" -- WIP, to be replaced with proper localization if possible?
		local mcName = L.RaidLocalization[localeString][136346]
		local onyName = L.RaidLocalization[localeString][136351]
		local bwlName = L.RaidLocalization[localeString][136329]
		local zgName = L.RaidLocalization[localeString][136369]
		raidResets = {
			{
				name=bfdName,
				firstReset = {
					year=2023,
					month=12,
					day=3,
					hour=resetHour,
					min=0
				},
				frequency=3
			},
			-- First 2 Gnomer resets are weekly, before the 3-day reset starts
			-- All 3-day reset raids reset at the same time
			{
				name=gnomerName,
				firstReset = {
					year=2024,
					month=2,
					day=13,
					hour=resetHour,
					min=0
				},
				frequency=0
			},
			{
				name=gnomerName,
				firstReset = {
					year=2024,
					month=2,
					day=20,
					hour=resetHour,
					min=0
				},
				frequency=0
			},
			{
				name=gnomerName,
				firstReset = {
					year=2024,
					month=2,
					day=22,
					hour=resetHour,
					min=0
				},
				frequency=3
			},
			-- Weekly raids
			-- {
			-- 	name=templeName,
			-- 	firstReset = {
			-- 		year=2024,
			-- 		month=4,
			-- 		day=9,
			-- 		hour=resetHour,
			-- 		min=0
			-- 	},
			-- 	frequency=7
			-- },
			-- Twice-weekly raids
			-- (one entry for Tuesdays, another for Saturdays)
			{
				name=templeName,
				firstReset = {
					year=2024,
					month=7,
					day=9,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=templeName,
				firstReset = {
					year=2024,
					month=7,
					day=13,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=azuregosName,
				firstReset = {
					year=2024,
					month=7,
					day=20,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=azuregosName,
				firstReset = {
					year=2024,
					month=7,
					day=23,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=kazzakName,
				firstReset = {
					year=2024,
					month=7,
					day=20,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=kazzakName,
				firstReset = {
					year=2024,
					month=7,
					day=23,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=mcName,
				firstReset = {
					year=2024,
					month=7,
					day=30,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=onyName,
				firstReset = {
					year=2024,
					month=7,
					day=27,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=onyName,
				firstReset = {
					year=2024,
					month=7,
					day=30,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=bwlName,
				firstReset = {
					year=2024,
					month=10,
					day=1,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=zgName,
				firstReset = {
					year=2024,
					month=9,
					day=28,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=zgName,
				firstReset = {
					year=2024,
					month=10,
					day=1,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=thunderName,
				firstReset = {
					year=2024,
					month=9,
					day=28,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=thunderName,
				firstReset = {
					year=2024,
					month=10,
					day=1,
					hour=resetHour,
					min=0
				},
				frequency=7
			}
		}
		if CCConfig.HideLevelUpRaidResets then
			for i = #raidResets, 1, -1 do
				if raidResets[i].name == bfdName or raidResets[i].name == gnomerName or raidResets[i].name == templeName then
					table.remove(raidResets, i)
				end
			end
		end
	else
		local MCName, _ = L.RaidLocalization[localeString][136346]
		local OnyName, _ = L.RaidLocalization[localeString][136351]
		local NaxxName, _ = L.RaidLocalization[localeString][136347]
		local AQTempleName, _ = L.RaidLocalization[localeString][136321]
		local AQRuinsName, _ = L.RaidLocalization[localeString][136320]
		local BWLName, _ = L.RaidLocalization[localeString][136329]
		local ZGName, _ = L.RaidLocalization[localeString][136369]
		local UBRSName, _ = L.RaidLocalization[localeString][136327]
		local regionHourAdjustment = 1
		if region == "EU" then
			regionHourAdjustment = -2
		end
		raidResets = {
			{
				name=MCName,
				firstReset = {
					year=2024,
					month=1,
					day=2,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=BWLName,
				firstReset = {
					year=2024,
					month=1,
					day=2,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=OnyName,
				firstReset = {
					year=2024,
					month=1,
					day=4,
					hour=resetHour,
					min=0
				},
				frequency=5
			},
			{
				name=ZGName,
				firstReset = {
					year=2024,
					month=1,
					day=2,
					hour=resetHour + regionHourAdjustment,
					min=0
				},
				frequency=3
			},
			{
				name=NaxxName,
				firstReset = {
					year=2024,
					month=1,
					day=2,
					hour=resetHour,
					min=0
				},
				frequency=7
			},
			{
				name=AQRuinsName,
				firstReset = {
					year=2024,
					month=1,
					day=2,
					hour=resetHour + regionHourAdjustment,
					min=0
				},
				frequency=3
			},
			{
				name=AQTempleName,
				firstReset = {
					year=2024,
					month=1,
					day=2,
					hour=resetHour,
					min=0
				},
				frequency=7
			}
		}
	end

	-- EU weekly reset is on Wednesdays, so move forward all weekly raid resets by a day
	if region == "EU" then
		for _, reset in next, raidResets do
			if reset.frequency == 7 then
				reset.firstReset = addDaysToDate(reset.firstReset, 1)
			end
		end
	end

	-- AU reset is 18 hours after NA, so it's in the following day
	if region == "AU" then
		for _, reset in next, raidResets do
			local dateSeconds = time(reset.firstReset)
			local SECONDS_IN_HOUR = 60 * 60
			local hour_offset = 18
			-- Do we need to adjust this offset based on DST?
			dateSeconds = dateSeconds + hour_offset * SECONDS_IN_HOUR
			reset.firstReset = date("*t", dateSeconds)
		end
	end

	return raidResets
end
