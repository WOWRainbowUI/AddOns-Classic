local mod	= DBM:NewMod("Oggleflint", "DBM-Party-Vanilla", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20241103114940")
mod:SetCreatureID(11517)
--mod:SetEncounterID(1443)
mod:SetZone(389)

mod:RegisterCombat("combat")
