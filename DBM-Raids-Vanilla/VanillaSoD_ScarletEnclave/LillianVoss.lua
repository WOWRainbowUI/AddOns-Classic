if not DBM:IsSeasonal("SeasonOfDiscovery") then return end

local mod	= DBM:NewMod("LillianVoss", "DBM-Raids-Vanilla", 11)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic"

mod:SetRevision("20250415162453")

mod:SetZone(2856)
mod:SetEncounterID(3190)
mod:SetCreatureID(243021)
mod:RegisterCombat("combat")
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 1233883 1232192 1233901 1233849",
	"SPELL_AURA_APPLIED_DOSE 1233883 1232192",
	"SPELL_AURA_REMOVED 1233883 1233901 1233849",
	"SPELL_CAST_START 1233847"
)

local specWarnMove		= mod:NewSpecialWarningYou(1233883, nil, nil, nil, 2, 2)

-- Ignite goes on everyone and does a ton of damage, TODO: timer/trigger is unclear, sometimes happens after 15 sec, sometimes only after minutes

-- Scarlet Grasp seems to be on a consistent timer
-- Long cast time of 4 sec, so using a timer that indicates actual cast instead of start (similar to Harbinger in Karazhan)
local timerScarletGrasp = mod:NewNextTimer(30.75, 1233847)
local warnScarletGrasp = mod:NewSpecialWarningSoon(1233847)

-- Debilitate has multiple casts and IDs, but 1232192 is the debuff that stacks
local warnDebilitateStacks = mod:NewTargetCountAnnounce(1232192)
local timerDebilitate = mod:NewVarTimer("v17-21", 1232192)

-- Enrage timer seems very short, but confirmed correct through multiple logs
local berserkTimer = mod:NewBerserkTimer(180)

-- Poison, like Grobbulus, unfortunately the timer seems to be quite random with times between 40 and 80 seconds :/
local timerPoisonFades	= mod:NewBuffFadesTimer(8, 1233901)
local warnPoison		= mod:NewTargetNoFilterAnnounce(1233901)
local specWarnPoison	= mod:NewSpecialWarningYou(1233901, nil, nil, nil, 1, 2)
local yellPoison		= mod:NewIconTargetYell(1233901)
local yellPoisonFades	= mod:NewIconFadesYell(1233901)


-- Unstable Concoction, 7 sec bomb
local timerConcotion		= mod:NewNextTimer(30.5, 1233849)
local timerConcotionFades	= mod:NewBuffFadesTimer(7, 1233849)
local warnConcotion			= mod:NewTargetNoFilterAnnounce(1233849)
local specWarnConcotion		= mod:NewSpecialWarningYou(1233849, nil, nil, 1, 2)
local yellConcotion			= mod:NewIconTargetYell(1233849)
local yellConcotionFades	= mod:NewIconFadesYell(1233849)

mod:AddSetIconOption("SetIconOnPoisonTarget", 1233901, true, 0, {8, 7, 6, 5, 4})
mod:AddSetIconOption("SetIconOnConcotionTarget", 1233849, true, 0, {1, 2, 3})


mod:NewGtfo{antiSpam = 5, spell = 1234708, spellAura = 1234708, spellPeriodicDamage = 1234708}

local poisonTargetIcon = 8
local concotionTargetIcon = 3

local function resetPoisonTargetIcon()
	poisonTargetIcon = 8
end

local function resetConcotionTargetIcon()
	concotionTargetIcon = 3
end

function mod:OnCombatStart(delay)
	berserkTimer:Start(180 - delay)
	timerScarletGrasp:Start(34.75 - delay)
	timerConcotion:Start(30.5 - delay)
	resetPoisonTargetIcon()
	resetConcotionTargetIcon()
end


function mod:KeepMovingYou(amount)
	if self:AntiSpam(amount >= 4 and 1 or amount >= 3 and 3 or 8, "KeepmovingHigh") then
		specWarnMove:Show()
		if amount >= 3 then
			specWarnMove:Play("stackhigh")
		else
			specWarnMove:Play("keepmove")
		end
	end
end

function mod:DelayedDebilitate(target, amount)
	warnDebilitateStacks:Show(amount, target)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(1233883) and args:IsPlayer() then
		self:KeepMovingYou(args.amount or 1)
	elseif args:IsSpell(1232192) then -- Only show warning once as multiple stacks are applied right after each other
		local amount = args.amount or 1
		self:UnscheduleMethod("DelayedDebilitate", args.destName)
		self:ScheduleMethod(0.2, "DelayedDebilitate", args.destName, amount)
		if self:AntiSpam(2, "Debilitate") then
			timerDebilitate:Start()
		end
	elseif args:IsSpell(1233901) then
		if args:IsPlayer() then
			specWarnPoison:Show()
			specWarnPoison:Play("runout")
			yellPoison:Show(4) -- Green triangle to distinguish from the other bomb
			yellPoisonFades:Countdown(8, 4, 4)
		end
		timerPoisonFades:Start()
		warnPoison:CombinedShow(0.1, args.destName)
		if self.Options.SetIconOnPoisonTarget then
			self:SetIcon(args.destName, poisonTargetIcon, 8)
			poisonTargetIcon = poisonTargetIcon - 1
			self:Schedule(2, resetPoisonTargetIcon)
		end
	elseif args:IsSpell(1233849) then
		if args:IsPlayer() then
			specWarnConcotion:Show()
			specWarnConcotion:Play("runout")
			yellConcotion:Show(8)
			yellConcotionFades:Countdown(7, 4, 8)
		end
		timerConcotionFades:Start()
		timerConcotion:Start()
		warnConcotion:CombinedShow(0.1, args.destName)
		if self.Options.SetIconOnConcotionTarget then -- TODO: can someone get both bombs at the same time? then the icon resetting logic is messed up
			self:SetIcon(args.destName, concotionTargetIcon, 7)
			concotionTargetIcon = concotionTargetIcon - 1
			self:Schedule(2, resetConcotionTargetIcon)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpell(1233883) and args:IsPlayer() then
		--specWarnMove:Play("safenow") -- TODO: does this get re-applied during some time? better not warn for now
	elseif args:IsSpell(1233901) and args:IsPlayer() then
		if not UnitIsDeadOrGhost("player") then
			specWarnPoison:Play("safenow")
		end
		yellPoison:Cancel()
	elseif args:IsSpell(1233849) and args:IsPlayer() and not UnitIsDeadOrGhost("player") then
		specWarnConcotion:Play("safenow")
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(1233847) then
		timerScarletGrasp:Schedule(4, -4)
		warnScarletGrasp:Show()
	end
end
