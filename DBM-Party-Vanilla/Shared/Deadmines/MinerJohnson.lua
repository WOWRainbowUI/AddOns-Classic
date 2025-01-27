local mod	= DBM:NewMod("MinerJohnson", "DBM-Party-Vanilla", DBM:IsRetail() and 18 or 5)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "timewalker"
else
	mod.statTypes = "normal"
end

mod:SetRevision("20241103114940")
mod:SetCreatureID(3586)
--mod:SetEncounterID(1144)--Doesn't have Encounter ID
mod:SetZone(36)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 12097",
	"SPELL_AURA_APPLIED 12097"
)

local warningPierceArmor			= mod:NewTargetNoFilterAnnounce(12097, 2)

local timerPierceArmorCD			= mod:NewAITimer(180, 12097, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerPierceArmorCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(12097) then
		timerPierceArmorCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(12097) then
		warningPierceArmor:Show(args.destName)
	end
end
