local _, addonTable = ...
addonTable.Locale = GetLocale()
addonTable.L = setmetatable({}, {
  __index = function(self, key)
    rawset(self, key, key or "")
    return self[key]
end})

local L = addonTable.L

L["%s does not match your currently equipped %s. ReforgeLite only supports equipped items."] = "%s does not match your currently equipped %s. ReforgeLite only supports equipped items."
L["^+(%d+) %s$"] = "^+(%d+) %s$"
L["Active window color"] = "Active window color"
L["Add cap"] = "Add cap"
L["At least"] = "At least"
L["At most"] = "At most"
L["Bearweave"] = "Bearweave"
L["Best result"] = "Best result"
L["Cap value"] = "Cap value"
L["Click an item to lock it"] = "Click an item to lock it"
L["Compute"] = "Calculate"
L["Crit block"] = "Crit block"
L["Debug"] = "Debug"
L["Enter pawn string"] = "Enter pawn string"
L["Enter the preset name"] = "Enter the preset name"
L["Enter WoWSims JSON"] = "Enter WoWSims JSON"
L["Exactly"] = "Exactly"
L["Expertise hard cap"] = "Expertise hard cap"
L["Expertise soft cap"] = "Expertise soft cap"
L["Export"] = "Export"
L["Import Pawn"] = "Import Pawn EP"
L["Import WoWSims"] = "Import WoWSims"
L["Inactive window color"] = "Inactive window color"
L["Masterfrost"] = "Masterfrost"
L["Melee DW hit cap"] = "Melee DW hit cap"
L["Melee hit cap"] = "Melee hit cap"
L["Monocat"] = "Monocat"
L["No reforge"] = "No reforge"
L["Open window when reforging"] = "Open window when reforging"
L["Other/No flask"] = "Other/No flask"
L["Other/No food"] = "Other/No food"
L["Presets"] = "Presets"
L["Reforging window must be open"] = "Reforging window must be open"
L["Remove cap"] = "Remove cap"
L["Result"] = "Result"
L["Score"] = "Score"
L["Show reforged stats in item tooltips"] = "Show reforged stats in item tooltips"
L["Slide to the left if the calculation slows your game too much."] = "Slide to the left if the calculation slows your game too much."
L["Spell hit cap"] = "Spell hit cap"
L["Spirit to hit"] = "Spirit to hit"
L["Stat weights"] = "Stat weights"
L["Sum"] = "Sum"
L["Tanking model"] = "Tanking model"
L["ticks"] = "ticks"
L["Weight after cap"] = "Weight after cap"

L["EquipPredicate"] = ""