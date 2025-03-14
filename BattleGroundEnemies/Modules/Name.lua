
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

local L = Data.L

local generalDefaults = {
	ShowRealmnames = true
}

local defaultSettings = {
	Enabled = true,
	Parent = "healthBar",
	ActivePoints = 2,
	Points = {
		{
			Point = "TOPLEFT",
			RelativeFrame = "Level",
			RelativePoint = "TOPRIGHT",
			OffsetX = 5,
			OffsetY = -2
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "TargetIndicatorNumeric",
			RelativePoint = "BOTTOMLEFT",
		}
	},
	Text = {
		FontSize = 13,
		JustifyH = "LEFT",
		JustifyV = "MIDDLE",
		WordWrap = false
	},
}

local generalOptions = function(location)
	return {
		ShowRealmnames = {
			type = "toggle",
			name = L.ShowRealmnames,
			desc = L.ShowRealmnames_Desc,
			width = "normal",
			order = 2
		}
	}
end

local options = function(location)
	return {
		TextSettings = {
			type = "group",
			name = L.Text,
			inline = true,
			order = 4,
			get = function(option)
				return Data.GetOption(location.Text, option)
			end,
			set = function(option, ...)
				return Data.SetOption(location.Text, option, ...)
			end,
			args = Data.AddNormalTextSettings(location.Text)
		}
	}
end



local name = BattleGroundEnemies:NewButtonModule({
	moduleName = "Name",
	localizedModuleName = L.Name,
	generalDefaults = generalDefaults,
	defaultSettings = defaultSettings,
	generalOptions = generalOptions,
	options = options,
	enabledInThisExpansion = true,
	attachSettingsToButton = true
})


function name:AttachToPlayerButton(playerButton)
	playerButton.Name = BattleGroundEnemies.MyCreateFontString(playerButton)

	function playerButton.Name:SetName()
		if not playerButton.PlayerDetails then return end
		local playerName = playerButton.PlayerDetails.PlayerName
		if not playerName then return end

		local name, realm = strsplit( "-", playerName, 2)

		if BattleGroundEnemies.db.profile.ConvertCyrillic then
			playerName = ""
			for i = 1, name:utf8len() do
				local c = name:utf8sub(i,i)

				if Data.CyrillicToRomanian[c] then
					playerName = playerName..Data.CyrillicToRomanian[c]
					if i == 1 then
						playerName = playerName:gsub("^.",string.upper) --uppercase the first character
					end
				else
					playerName = playerName..c
				end
			end
			--self.DisplayedName = self.DisplayedName:gsub("-.",string.upper) --uppercase the realm name
			name = playerName
			if realm then
				playerName = playerName.."-"..realm
			end
		end

		if self.config.ShowRealmnames then
			name = playerName
		end

		self:SetText(name)
		self.DisplayedName = name
	end

	function playerButton.Name:ApplyAllSettings()
		if not self.config then return end
		local config = self.config
		-- name
		self:ApplyFontStringSettings(config.Text)
		self:SetName()
	end
	return playerButton.Name
end