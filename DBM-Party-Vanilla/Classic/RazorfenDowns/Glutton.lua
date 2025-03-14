local mod	= DBM:NewMod("Glutton", "DBM-Party-Vanilla", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20241103114940")
mod:SetCreatureID(8567)
--mod:SetEncounterID(585)
mod:SetZone(129)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 12795"
)

--TODO, add Disease Cloud when data is known
local warningEnrage					= mod:NewSpellAnnounce(12795, 2)

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(12795) and args:IsSrcTypeHostile() then
		warningEnrage:Show()
	end
end
