AuctionatorConfigTabMixin = {}

function AuctionatorConfigTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigTabMixin:OnLoad()")

  if Auctionator.Constants.IsClassic then
    -- Reposition lower down translator entries so that they don't go past the
    -- bottom of the tab
    self.frFR:SetPoint("TOPLEFT", self.deDE, "TOPLEFT", 300, 0)
  end
end

function AuctionatorConfigTabMixin:OpenOptions()
  if Settings and SettingsPanel then
    Settings.OpenToCategory(AUCTIONATOR_L_ADDON_OPTIONS)
  else
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(AUCTIONATOR_L_ADDON_OPTIONS)
  end
end
