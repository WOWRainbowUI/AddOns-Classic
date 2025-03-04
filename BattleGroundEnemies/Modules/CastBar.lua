---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local L = Data.L

local styles = {
	Arena =  DoesTemplateExist("ArenaCastingBarFrameTemplate") and ARENA or nil,
	Normal = L.NormalCastingBar,
	Small = L.SmallCastingBar
}

local defaultSettings = {
	Parent = "Button",
	ActivePoints = 1,
	Style = "Small",
	Scale = 1.5
}

local options = function(location)
	return {
		Style = {
			type = "select",
			name = L.Style,
			values = styles,
			order = 1
		},
		Scale = {
			type = "range",
			name = L.Scale,
			min = 0.1,
			max = 2,
			step = 0.05,
			order = 2
		}
	}
end


local CastingBarFrame_OnLoad = CastingBarFrame_OnLoad or CastingBarMixin.OnLoad --CastingBarMixin is used in Dragonflight 10.0
local CastingBarFrame_SetUnit = CastingBarFrame_SetUnit or CastingBarMixin.SetUnit
local CreateFrame = CreateFrame

local castBar = BattleGroundEnemies:NewButtonModule({
	moduleName = "CastBar",
	localizedModuleName = SHOW_ENEMY_CAST,
	defaultSettings = defaultSettings,
	options = options,
	flags =  {
		Height = "Fixed",
		Width = "Fixed"
	},
	events = {"UnitIdUpdate"},
	enabledInThisExpansion = true
})

local settingToTemplate = {
	Normal = function(self)
		self:SetWidth(195)
		self:SetHeight(13)

		local f = CreateFrame("statusbar", nil, self, "CastingBarFrameTemplate")
		f:SetAllPoints()
		return f
	end,
	Small = function(self)
		self:SetWidth(150)
		self:SetHeight(10)

		local f = CreateFrame("statusbar", nil, self, "SmallCastingBarFrameTemplate")
		f:SetAllPoints()
		return f
	end,
	Arena = DoesTemplateExist("ArenaCastingBarFrameTemplate") and function(self)
		self:SetWidth(80)
		self:SetHeight(14)

		local f = CreateFrame("statusbar", nil, self, "ArenaCastingBarFrameTemplate")
		f:SetAllPoints()
		f.Icon:SetPoint("RIGHT", f, "LEFT", -5, 0)
		return f
	end or nil
}

function castBar:AttachToPlayerButton(playerButton)
	playerButton.CastBar = CreateFrame("frame", nil, playerButton)

	--when unitID changes
	playerButton.CastBar.UnitIdUpdate = function(self, unitID)
		if not self.CastBar then return end
		CastingBarFrame_SetUnit(self.CastBar, unitID);
	end

	playerButton.CastBar.Reset = function(self)
		if not self.CastBar then return end
		CastingBarFrame_SetUnit(self.CastBar, nil)
	end

	playerButton.CastBar.Disable = function(self)
		if not self.CastBar then return end
		CastingBarFrame_SetUnit(self.CastBar, nil)
	end

	playerButton.CastBar.ApplyAllSettings = function(self)
		if not self.config then return end
		self:CreateCastBar()
		local unitID = playerButton:GetUnitID()
		CastingBarFrame_SetUnit(self.CastBar, unitID)
	end

	playerButton.CastBar.CreateCastBar = function(self)
		local style = self.config.Style
		if style ~= self.style then
			if self.CastBar then --This will create a bit of garbage behind, but hopefully the user doesn't switch the castbar style/template too much
				self.CastBar:UnregisterAllEvents()
				self.CastBar:Hide()
				wipe(self.CastBar)
			end
			if not settingToTemplate[style] then
				self.config.Style = defaultSettings.Style
				BattleGroundEnemies:OnetimeInformation("The Castbar style/template doesnt exist on this client. Automatically set castbar style to: " .. defaultSettings.Style)
			end
			self.CastBar = settingToTemplate[style](self)
			CastingBarFrame_OnLoad(self.CastBar, "fake") --set a fake unit to avoid The error in the onupdate script CastingBarFrame_OnUpdate which gets set by the template

			self.style = style
		end

		local scale = self.config.Scale
		if scale then
			self:SetScale(scale)
		end
	end
	return playerButton.CastBar
end
