--[[--------------------------------------------------------------------------
--  TomTom - A navigational assistant for World of Warcraft
--
--  CrazyTaxi: A crazy-taxi style arrow used for waypoint navigation.
--    concept taken from MapNotes2 (Thanks to Mery for the idea, along
--    with the artwork.)
----------------------------------------------------------------------------]]

local addonName, addon = ...

local sformat = string.format
local L = TomTomLocals
local ldb = LibStub("LibDataBroker-1.1")
local ldd = LibStub('LibDropDown')

local IMAGE_ARROW = "Interface\\Addons\\TomTom\\Images\\Arrow-1024"
local IMAGE_ARROW_UP = "Interface\\AddOns\\TomTom\\Images\\Arrow-UP-1024"
local IMAGE_STATIC_ARROW = "Interface\\Addons\\TomTom\\Images\\StaticArrow"

local function ColorGradient(perc, ...)
	local num = select("#", ...)
	local hexes = type(select(1, ...)) == "string"

	if perc == 1 then
		return select(num-2, ...), select(num-1, ...), select(num, ...)
	end

	num = num / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2
	r1, g1, b1 = select((segment*3)+1, ...), select((segment*3)+2, ...), select((segment*3)+3, ...)
	r2, g2, b2 = select((segment*3)+4, ...), select((segment*3)+5, ...), select((segment*3)+6, ...)

	if not r2 or not g2 or not b2 then
		return r1, g1, b1
	else
		return r1 + (r2-r1)*relperc,
		g1 + (g2-g1)*relperc,
		b1 + (b2-b1)*relperc
	end
end

local twopi = math.pi * 2

local wayframe = CreateFrame("Button", "TomTomCrazyArrow", UIParent)
wayframe:SetHeight(42)
wayframe:SetWidth(56)
wayframe:EnableMouse(true)
wayframe:SetMovable(true)
wayframe:SetClampedToScreen(true)
wayframe:Hide()

-- Frame used to control the scaling of the title and friends
local titleframe = CreateFrame("Frame", nil, wayframe)

wayframe.title = titleframe:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
wayframe.status = titleframe:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
wayframe.tta = titleframe:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
wayframe.title:SetPoint("TOP", wayframe, "BOTTOM", 0, 0)
wayframe.status:SetPoint("TOP", wayframe.title, "BOTTOM", 0, 0)
wayframe.tta:SetPoint("TOP", wayframe.status, "BOTTOM", 0, 0)

local function OnDragStart(self, button)
	if not TomTom.db.profile.arrow.lock then
		self:StartMoving()
	end
end

local function OnDragStop(self, button)
	self:StopMovingOrSizing()
	self:SetUserPlaced(false)
	-- point, relativeTo, relativePoint, xOfs, yOfs
	TomTom.profile.arrow.position = { self:GetPoint() }
	TomTom.profile.arrow.position[2] = nil  -- Note we are relative to UIParent
end

local function OnEvent(self, event, ...)
	if (event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") and TomTom.profile.arrow.enable then
		self:Show()
		return
	end
	if (event == "PLAYER_ENTERING_WORLD") then
        wayframe:ClearAllPoints()
        if not TomTom.profile.arrow.position then
            TomTom.profile.arrow.position = {"CENTER", nil , "CENTER", 0, 300}
        end
        local pos = TomTom.profile.arrow.position
        wayframe:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
    end
end

wayframe:SetScript("OnDragStart", OnDragStart)
wayframe:SetScript("OnDragStop", OnDragStop)
wayframe:RegisterForDrag("LeftButton")
wayframe:RegisterEvent("ZONE_CHANGED_NEW_AREA")
wayframe:RegisterEvent("ZONE_CHANGED")
wayframe:RegisterEvent("PLAYER_ENTERING_WORLD")
wayframe:SetScript("OnEvent", OnEvent)

wayframe.arrow = wayframe:CreateTexture(nil, "OVERLAY")
wayframe.arrow:SetTexture(IMAGE_ARROW)
wayframe.arrow:SetAllPoints()

local active_point, arrive_distance, showDownArrow, point_title

function TomTom:SetCrazyArrow(uid, dist, title)
	if active_point and active_point.corpse and self.db.profile.arrow.stickycorpse then
		-- do not change the waypoint arrow from corpse
		return
	end

	active_point = uid
	arrive_distance = dist
	point_title = title

	if self.profile.arrow.enable then
		wayframe.title:SetText(title or L["Unknown waypoint"])
		wayframe:Show()
		if wayframe.crazyFeedFrame then
			wayframe.crazyFeedFrame:Show()
		end
	end
end

function TomTom:IsCrazyArrowEmpty()
    return not active_point
end

local status = wayframe.status
local tta = wayframe.tta
local arrow = wayframe.arrow
local count = 0
local last_distance = 0
local tta_throttle = 0
local speed = 0
local speed_count = 0

local function OnUpdate(self, elapsed)
	if not active_point then
		self:Hide()
		return
	end

	local dist,x,y = TomTom:GetDistanceToWaypoint(active_point)

	-- The only time we cannot calculate the distance is when the waypoint
	-- is on another continent, or we are in an instance
	if not dist then
		if not TomTom:IsValidWaypoint(active_point) then
			active_point = nil
			-- Change the crazy arrow to point at the closest waypoint
			if TomTom.profile.arrow.setclosest then
				TomTom:SetClosestWaypoint()
				return
			end
		end

		self:Hide()
		return
	end

	status:SetText(addon:GetFormattedDistance(dist))

	local cell

	-- Showing the arrival arrow?
	if dist <= arrive_distance then
		if not showDownArrow then
			arrow:SetHeight(70)
			arrow:SetWidth(53)
			arrow:SetTexture(IMAGE_ARROW_UP)
			arrow:SetVertexColor(unpack(TomTom.db.profile.arrow.goodcolor))
			showDownArrow = true
		end

		count = count + 1
		if count >= 55 then
			count = 0
		end

		local cell = count
		local column = cell % 9
		local row = floor(cell / 9)

		local xstart = (column * 53) / 512
		local ystart = (row * 70) / 512
		local xend = ((column + 1) * 53) / 512
		local yend = ((row + 1) * 70) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
	else
		if showDownArrow then
			arrow:SetHeight(56)
			arrow:SetWidth(42)
			arrow:SetTexture(IMAGE_ARROW)
			showDownArrow = false
		end

		local angle = TomTom:GetDirectionToWaypoint(active_point)
		local player = GetPlayerFacing()

		if not player then
			if not TomTom:IsValidWaypoint(active_point) then
				active_point = nil
				-- Change the crazy arrow to point at the closest waypoint
				if TomTom.profile.arrow.setclosest then
					TomTom:SetClosestWaypoint()
					return
				end
			end
			self:Hide()
			return
        end

		angle = angle - player

		local perc = math.abs((math.pi - math.abs(angle)) / math.pi)

		local gr,gg,gb = unpack(TomTom.db.profile.arrow.goodcolor)
		local mr,mg,mb = unpack(TomTom.db.profile.arrow.middlecolor)
		local br,bg,bb = unpack(TomTom.db.profile.arrow.badcolor)
		local r,g,b = ColorGradient(perc, br, bg, bb, mr, mg, mb, gr, gg, gb)

		-- If we're 98% heading in the right direction, then use the exact
		-- color instead of the gradient. This allows us to distinguish 'good'
		-- from 'on target'. Thanks to Gregor_Curse for the suggestion.
		if perc > 0.98 then
			r,g,b = unpack(TomTom.db.profile.arrow.exactcolor)
		end
		arrow:SetVertexColor(r,g,b)

		local cell = floor(angle / twopi * 108 + 0.5) % 108
		local column = cell % 9
		local row = floor(cell / 9)

		local xstart = (column * 56) / 512
		local ystart = (row * 42) / 512
		local xend = ((column + 1) * 56) / 512
		local yend = ((row + 1) * 42) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
	end

	-- Calculate the TTA every second  (%01d:%02d)

	tta_throttle = tta_throttle + elapsed

	if tta_throttle >= 1.0 then
		-- Calculate the speed in yards per sec at which we're moving
		local current_speed = (last_distance - dist) / tta_throttle

		if last_distance == 0 then
			current_speed = 0
		end

		if speed_count < 2 then
			speed = (speed + current_speed) / 2
			speed_count = speed_count + 1
		else
			speed_count = 0
			speed = current_speed
		end

		if speed > 0 then
			local eta = math.abs(dist / speed)
			tta:SetFormattedText("%s:%02d", math.floor(eta / 60), math.floor(eta % 60))
		else
			tta:SetText("***")
		end

		last_distance = dist
		tta_throttle = 0
	end
end

function TomTom:ShowHideCrazyArrow()
	if self.profile.arrow.enable then
		if self.profile.arrow.hideDuringPetBattles and C_PetBattles and C_PetBattles.IsInBattle() then
			wayframe:Hide()
			return
		end

		wayframe:Show()

		if self.profile.arrow.noclick then
			wayframe:EnableMouse(false)
		else
			wayframe:EnableMouse(true)
		end

		-- Set the scale and alpha
		wayframe:SetScale(TomTom.db.profile.arrow.scale)
		-- Do not allow the arrow to be invisible
		if TomTom.db.profile.arrow.alpha < 0.1 then
		    TomTom.db.profile.arrow.alpha = 1.0
		end
		-- Set the stratum
		if TomTom.db.profile.arrow.highstrata then
		    wayframe:SetFrameStrata("HIGH")
		else
		    wayframe:SetFrameStrata("MEDIUM")
		end
		wayframe:SetAlpha(TomTom.db.profile.arrow.alpha)
		local width = TomTom.db.profile.arrow.title_width
		local height = TomTom.db.profile.arrow.title_height
		local scale = TomTom.db.profile.arrow.title_scale

		wayframe.title:SetWidth(width)
		wayframe.title:SetHeight(height)
		titleframe:SetScale(scale)
		titleframe:SetAlpha(TomTom.db.profile.arrow.title_alpha)

		if self.profile.arrow.showdistance then
			wayframe.status:Show()
			wayframe.tta:ClearAllPoints()
			wayframe.tta:SetPoint("TOP", wayframe.status, "BOTTOM", 0, 0)
		else
			wayframe.status:Hide()
			wayframe.tta:ClearAllPoints()
			wayframe.tta:SetPoint("TOP", wayframe, "BOTTOM", 0, 0)
		end

		if self.profile.arrow.showtta then
			tta:Show()
		else
			tta:Hide()
		end
	else
		wayframe:Hide()
	end
end

wayframe:SetScript("OnUpdate", OnUpdate)


--[[-------------------------------------------------------------------------
--  Dropdown
-------------------------------------------------------------------------]]--

local function initDropdown(parent)
	local menu = ldd:NewMenu(wayframe, 'MyFrameDropDown')
	menu:SetAnchor("TOPLEFT", parent, "CENTER", 25, -25)

	local dropdownInfo = {
		{
			isTitle = true,
			text = L["TomTom Waypoint Arrow"],
		},
		{
			text = L["Send waypoint to"],
			menu = {
				{
					-- Title
					text = L["Waypoint communication"],
					isTitle = true,
				},
				{
					-- Party
					text = L["Send to party"],
					func = function()
						TomTom:SendWaypoint(TomTom.dropdown_uid, "PARTY")
					end
				},
				{
					-- Raid
					text = L["Send to raid"],
					func = function()
						TomTom:SendWaypoint(TomTom.dropdown_uid, "RAID")
					end
				},
				{
					-- Battleground
					text = L["Send to battleground"],
					func = function()
						TomTom:SendWaypoint(TomTom.dropdown_uid, "BATTLEGROUND")
					end
				},
				{
					-- Guild
					text = L["Send to guild"],
					func = function()
						TomTom:SendWaypoint(TomTom.dropdown_uid, "GUILD")
					end
				},
			},
		},
		{
			-- Clear waypoint from crazy arrow
			text = L["Clear waypoint from crazy arrow"],
			func = function()
				TomTom:ClearCrazyArrowPoint(false)
			end,
		},
		{
			-- Remove a waypoint
			text = L["Remove waypoint"],
			func = function()
				TomTom:ClearCrazyArrowPoint(true)
			end,
		},
		{
            -- Remove all waypoints from this zone
            text = L["Remove all waypoints from this zone"],
            func = function()
                local uid = active_point
                local data = uid
                local mapId = data[1]
                for key, waypoint in pairs(TomTom.waypoints[mapId]) do
                    TomTom:RemoveWaypoint(waypoint)
                end

            end,
        },
		{
			-- Remove all waypoints
			text = L["Remove all waypoints"],
			func = function()
				if TomTom.db.profile.general.confirmremoveall then
					StaticPopup_Show("TOMTOM_REMOVE_ALL_CONFIRM")
				else
					StaticPopupDialogs["TOMTOM_REMOVE_ALL_CONFIRM"].OnAccept()
					return
				end
			end,
		},
		{
			-- Lock Arrow
			text = L["Arrow locked"],
			checked = function () return TomTom.db.profile.arrow.lock; end,
			func = function ()
				TomTom.db.profile.arrow.lock = not TomTom.db.profile.arrow.lock
				TomTom:ShowHideCrazyArrow()
			end,
			isNotRadio = true,
		}
	}

	menu:AddLines(unpack(dropdownInfo))
	return menu
end

local wayframeMenu = initDropdown(wayframe)
local function WayFrame_OnClick(self, button)
	if active_point then
		if TomTom.db.profile.arrow.menu then
			TomTom.dropdown_uid = active_point
			wayframeMenu:Toggle()
		end
	end
end

wayframe:RegisterForClicks("RightButtonUp")
wayframe:SetScript("OnClick", WayFrame_OnClick)

local function getCoords(column, row)
	local xstart = (column * 56) / 512
	local ystart = (row * 42) / 512
	local xend = ((column + 1) * 56) / 512
	local yend = ((row + 1) * 42) / 512
	return xstart, xend, ystart, yend
end

local texcoords = setmetatable({}, {__index = function(t, k)
	local col,row = k:match("(%d+):(%d+)")
	col,row = tonumber(col), tonumber(row)
	local obj = {getCoords(col, row)}
	rawset(t, k, obj)
	return obj
end})

wayframe:RegisterEvent("ADDON_LOADED")
local function wayframe_OnEvent(self, event, arg1, ...)
	if arg1 == "TomTom" then
		if TomTom.db.profile.feeds.arrow then
			-- Create a data feed for coordinates
			local feed_crazy = ldb:NewDataObject("TomTom_CrazyArrow", {
				type = "data source",
				icon = IMAGE_ARROW,
				staticIcon = IMAGE_STATIC_ARROW,
				text = "Crazy",
				iconR = 0.2,
				iconG = 1.0,
				iconB = 0.2,
				iconCoords = texcoords["1:1"],
				OnTooltipShow = function(tooltip)
					local dist = TomTom:GetDistanceToWaypoint(active_point)
					if dist then
						tooltip:AddLine(point_title or L["Unknown waypoint"])
						tooltip:AddLine(sformat(L["%d yards"], dist), 1, 1, 1)
					end
				end,
				OnClick = WayFrame_OnClick,
			})

			local crazyFeedFrame = CreateFrame("Frame")
			local throttle = TomTom.db.profile.feeds.arrow_throttle
			local counter = 0

			function TomTom:UpdateArrowFeedThrottle()
				throttle = TomTom.db.profile.feeds.arrow_throttle
			end

			wayframe.crazyFeedFrame = crazyFeedFrame
			crazyFeedFrame:SetScript("OnUpdate", function(self, elapsed)
				counter = counter + elapsed
				if counter < throttle then
					return
				end

				counter = 0
				if not active_point then
					self:Hide()
				end
				local angle = TomTom:GetDirectionToWaypoint(active_point)
				local player = GetPlayerFacing()
				if not angle or not player then
					feed_crazy.iconCoords = texcoords["1:1"]
					feed_crazy.iconR = 0.2
					feed_crazy.iconG = 1.0
					feed_crazy.iconB = 0.2
					feed_crazy.text = "No waypoint"
					return
				end

				angle = angle - player

				local perc = math.abs((math.pi - math.abs(angle)) / math.pi)

				local gr,gg,gb = unpack(TomTom.db.profile.arrow.goodcolor)
				local mr,mg,mb = unpack(TomTom.db.profile.arrow.middlecolor)
				local br,bg,bb = unpack(TomTom.db.profile.arrow.badcolor)
				local r,g,b = ColorGradient(perc, br, bg, bb, mr, mg, mb, gr, gg, gb)

				-- If we're 98% heading in the right direction, then use the exact
				-- color instead of the gradient. This allows us to distinguish 'good'
				-- from 'on target'. Thanks to Gregor_Curse for the suggestion.
				if perc > 0.98 then
					r,g,b = unpack(TomTom.db.profile.arrow.exactcolor)
				end

				feed_crazy.iconR = r
				feed_crazy.iconG = g
				feed_crazy.iconB = b

				local cell = floor(angle / twopi * 108 + 0.5) % 108
				local column = cell % 9
				local row = floor(cell / 9)

				local key = column .. ":" .. row
				feed_crazy.iconCoords = texcoords[key]
				feed_crazy.text = point_title or L["Unknown waypoint"]
			end)
		end
	end
end

wayframe:HookScript("OnEvent", wayframe_OnEvent)

--[[-------------------------------------------------------------------------
--  API for manual control of Crazy Arrow
--
--  This allow for an addon to specify their own control of the waypoint
--  arrow without needing to tip-toe around the API.  It may not integrate
--  properly, but in general it should work.
--
--  Example Usage:
--
--  if not TomTom:CrazyArrowIsHijacked() then
--    TomTom:HijackCrazyArrow(function(self, elapsed)
--      -- Random angle
--      local angle = math.random(math.pi * 2)
--      TomTom:SetCrazyArrowDirection(angle)
--      -- Random color
--      local r = math.random(100) / 100
--      local g = math.random(100) / 100
--      local b = math.random(100) / 100
--      TomTom:SetCrazyArrowColor(r, g, b)
--      -- Titles
--      TomTom:SetCrazyArrowTitle("Hijacked arrow", "Hijacked", "You will never arrive")
--    end)
--  end
--
--  -- At some point later
--  TomTom:ReleaseCrazyArrow()
-------------------------------------------------------------------------]]--

-- Set the direction of the crazy arrow without taking the player's facing
-- into consideration.  This can be accomplished by subtracting
-- GetPlayerFacing() from the angle before passing it in.
function TomTom:SetCrazyArrowDirection(angle)
    local cell = floor(angle / twopi * 108 + 0.5) % 108
    local column = cell % 9
    local row = floor(cell / 9)

    local key = column .. ":" .. row
    arrow:SetTexCoord(unpack(texcoords[key]))
end

-- Convenience function to set the color of the crazy arrow
function TomTom:SetCrazyArrowColor(r, g, b, a)
    arrow:SetVertexColor(r, g, b, a)
end

-- Convenience function to set the title/status and time to arrival text
-- of the crazy arrow.
function TomTom:SetCrazyArrowTitle(title, status, tta)
    wayframe.title:SetText(title)
    wayframe.status:SetText(status)
    wayframe.tta:SetText(tta)
end

-- Function to actually hijack the crazy arrow by replacing the OnUpdate script
function TomTom:HijackCrazyArrow(onupdate)
    wayframe:SetScript("OnUpdate", onupdate)
    wayframe.hijacked = true
    wayframe:Show()
end

-- Releases the crazy arrow by restoring the original OnUpdate script
function TomTom:ReleaseCrazyArrow()
    wayframe:SetScript("OnUpdate", OnUpdate)
    wayframe.hijacked = false
end

-- Returns whether or not the crazy arrow is currently hijacked
function TomTom:CrazyArrowIsHijacked()
    return wayframe.hijacked
end

-- Logs Crazy Arrow status
function TomTom:DebugCrazyArrow()
    local msg
    msg = string.format(L["|cffffff78TomTom:|r CrazyArrow %s hijacked"], (wayframe.hijacked and L["is"]) or L["not"])
    ChatFrame1:AddMessage(msg)
    msg = string.format(L["|cffffff78TomTom:|r CrazyArrow %s visible"], (wayframe:IsVisible() and L["is"]) or L["not"])
    ChatFrame1:AddMessage(msg)
    msg = string.format(L["|cffffff78TomTom:|r Waypoint %s valid"], (active_point and TomTom:IsValidWaypoint(active_point) and L["is"]) or L["not"])
    ChatFrame1:AddMessage(msg)

    local dist,x,y = TomTom:GetDistanceToWaypoint(active_point)
    msg = string.format("|cffffff78TomTom:|r Waypoint distance=%s", tostring(dist))
    ChatFrame1:AddMessage(msg)

    if wayframe:IsVisible() then
        local point, relativeTo, relativePoint, xOfs, yOfs = wayframe:GetPoint(1)
        relativeTo = (relativeTo and relativeTo:GetName()) or "UIParent"
        msg = string.format("|cffffff78TomTom:|r CrazyArrow point=%s frame=%s rpoint=%s xo=%.2f yo=%.2f",  point, relativeTo, relativePoint, xOfs, yOfs)
        ChatFrame1:AddMessage(msg)
    end
end

-- Clear the waypoint from the crazy arrow
--   remove: true if the waypoint should be removed entirely, otherwise
--   this method only clears it from the crazy arrow itself.
function TomTom:ClearCrazyArrowPoint(remove)
	if active_point then
		if remove then
			local uid = active_point
			TomTom:RemoveWaypoint(uid)
		else
			local prior = active_point
			active_point = nil
			if TomTom.profile.arrow.setclosest then
				local uid = TomTom:GetClosestWaypoint()
				if uid and uid ~= prior then
					TomTom:SetClosestWaypoint()
					return
				end
			end
		end
	end
end

local regionsAreMetric = {
	false, -- US
	true,
	true,
	true,
	true,
}

function TomTom:RegionIsMetric()
	if self.accountRegion == nil then
		local gameAccountInfo = C_BattleNet.GetGameAccountInfoByGUID(UnitGUID("player"))
		local regionID = gameAccountInfo and gameAccountInfo.regionID or GetCurrentRegion()
		self.accountRegion = regionID
	end

	if regionsAreMetric[self.accountRegion] ~= nil then
		return regionsAreMetric[self.accountRegion]
	else
		-- Default to true
		return true
	end
end

local floor = math.floor

local function yardsToMeters(yards)
	local meters = yards * 0.9144
	return meters
end

local function humanizeYardsMiles(yards)
	local yardsInMile = 1760 -- yards in a mile
	local miles = floor(yards / yardsInMile)
	local remaining = floor(yards % yardsInMile)
	return miles, remaining
end

local function humanizeYardsKilometers(yards)
	local meters = yards * 0.9144
	local km = floor(meters / 1000)
	local remaining = floor(meters % 1000)
	return km, remaining
end

-- Return the formatted distance, taking the player options
-- into account and converting to Metric in appropriate circumstances
-- Thanks to Lotimar for the contribution
function TomTom:GetFormattedDistance(distanceInYards)
	local distanceMode = "humanmeters"

	if self.db.profile.arrow.distanceUnits == "auto" then
		if not self:RegionIsMetric() then
			distanceMode = "yards"
		end
	elseif self.db.profile.arrow.distanceUnits == "yards" then
		distanceMode = "yards"
	elseif self.db.profile.arrow.distanceUnits == "meters" then
		distanceMode = "meters"
	elseif self.db.profile.arrow.distanceUnits == "humanyards" then
		distanceMode = "humanyards"
	elseif self.db.profile.arrow.distanceUnits == "humanmeters" then
		distanceMode = "humanmeters"
	end

	if distanceMode == "humanmeters" then
		local km, meters = humanizeYardsKilometers(distanceInYards)
		if km == 0 then
			return L["%dm away"]:format(meters)
		else
			return L["%dkm %dm away"]:format(km, meters)
		end
	elseif distanceMode == "humanyards" then
		local miles, yards = humanizeYardsMiles(distanceInYards)
		if miles == 0 then
			return L["%d yards away"]:format(yards)
		elseif miles == 1 then
			return L["%d mile %d away"]:format(miles, yards)
		else
			return L["%d miles %d yards away"]:format(miles, yards)
		end
	elseif distanceMode == "meters" then
		local meters = yardsToMeters(distanceInYards)
		return L["%dm away"]:format(meters)
	elseif distanceMode == "yards" then
		return L["%d yards away"]:format(distanceInYards)
	end
end
