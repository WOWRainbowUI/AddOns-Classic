local mod	= DBM:NewMod("ArchmageArugal", "DBM-Party-Vanilla", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20241103114940")
mod:SetCreatureID(4275)
mod:SetZone(33)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 7621 7587",
	"SPELL_AURA_APPLIED 7621"
)

local warningArugalsCurse			= mod:NewTargetNoFilterAnnounce(7621, 2)
local warningShadowPort				= mod:NewSpellAnnounce(7587, 2)

local timerArugalsCurseCD			= mod:NewAITimer(180, 7621, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerShadowPortCD				= mod:NewAITimer(180, 7587, nil, nil, nil, 6)

function mod:OnCombatStart(delay)
	timerArugalsCurseCD:Start(1-delay)
	timerShadowPortCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(7621) then
		timerArugalsCurseCD:Start()
	elseif args:IsSpell(7587) then
		warningShadowPort:Show()
		timerShadowPortCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(7621) then
		warningArugalsCurse:Show(args.destName)
	end
end
