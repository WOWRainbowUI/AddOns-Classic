local mod	= DBM:NewMod("Gelihast", "DBM-Party-Vanilla", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20241103114940")
mod:SetCreatureID(6243)
mod:SetEncounterID(2763)
mod:SetZone(48)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 6533",
	"SPELL_AURA_APPLIED 6533"
)

local warningNet			= mod:NewTargetNoFilterAnnounce(6533, 2)

local timerNetCD			= mod:NewAITimer(180, 6533, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerNetCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(6533) then
		timerNetCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(6533) then
		warningNet:Show(args.destName)
	end
end
