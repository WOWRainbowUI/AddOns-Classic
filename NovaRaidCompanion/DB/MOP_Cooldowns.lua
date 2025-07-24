----------------------------------
---Nova Raid Companion Cooldowns--
----------------------------------

local addonName, NRC = ...;
if (not NRC.isMOP) then
	return;
end
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");

--I started converting icon paths to iconIds in MoP, new stuff added is generally done but old stuff still has paths.
--{cooldownAdjust} is spells that cooldown time can be changed by talents.
--{talentOnly} is for spells that can only be trained by getting talents (like mana tide).
--tabIndex is tier and talentIndex is column for MoP onwards, just using older expansion names here.
--If there are percentage cooldown reductions on top of a regular seconds reduction talent then the percentage should be in slot 2 "cooldownAdjust2".

--Cooldown Data Structure Example.
--[[["Spell Name"] = {
	class = "HUNTER",
	icon = 236312,
	cooldown = 120,
	minLevel = 60,
	watchForAura = true, --If this cooldown requires watching for an aura to be applied instead of a spell cast (like Cheat Death/Purgatory).
	resetBySpellID = 11958, --If this cooldown can be reset by another spell like Cold Snap.
	talentOnly = { --Only show the cooldown if they have this talent trained.
		tabIndex = 4, (column in mop)
		talentIndex = 2, (row in mop)
	},
	specOnly = "SPECNAME", --Not yet working, coming soon.
	castDetect = true, --If this is cast by a player then show it (goes along as a backup to talent only spells incase we can't inspect them to show it for some reason).
	castDetectOnly = true, --Only show this cooldown once someone is seen casting it, this cooldown never loads unless seen cast, there is no talent detection etc.
	cooldownAdjust = { --Adjust cooldowns based on talents trained.
		tabIndex = 3,
		talentIndex = 2,
		[1] = 30, --One talent spend is 30 secs reduction.
		[2] = 60, --Two talents spent is 60 secs reduction (note all talents in MoP and onwards only have 1 talent spent always.
	},
	glyphCooldownAdjust = {
		[1234567] = 10, --Glyph spellID 1234567 gives a 10 second reduction in cooldown.
		[1234567] = -10, --If a glyph adds time then prefix with a minus sign.
	},
	customCooldown = {
		[123456] = 90,	--One of the spellIDs has a different cooldown, use this to override (like hammer or justice and fist of justice).
	},					--This can never be used in the same cooldown that has a reduction time from talents/glyphs unless it effects this spell too.
	spellIDs = {
		[12345] = "Spell Name",
		[123456] = "Spell Name" 2,
	},
},]]
	
NRC.cooldowns = {
	--Death Knight (tier levels = 56/57/58/60/75/90).
	["Army of the Dead"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_deathknight_armyofthedead",
		cooldown = 600,
		minLevel = 80,
		title = "Army",
		spellIDs = {
			[42650] = "Army of the Dead", --Rank 1.
		},
	},
	["Icebound Fortitude"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_deathknight_iceboundfortitude",
		cooldown = 180,
		minLevel = 62,
		glyphCooldownAdjust = {
			[58673] = 90, --Glyph of Icebound Fortitude.
		},
		spellIDs = {
			[48792] = "Icebound Fortitude", --Rank 1.
		},
	},
	["Anti Magic Zone"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_deathknight_antimagiczone",
		cooldown = 120,
		minLevel = 57,
		talentOnly = {
			tabIndex = 2,
			talentIndex = 2,
		},
		spellIDs = {
			[51052] = "Anti-Magic Zone", --Rank 1.
		},
	},
	["Unholy Frenzy"] = { --Unholy only.
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_shadow_unholyfrenzy",
		cooldown = 180,
		minLevel = 40,
		specOnly = "UNHOLY",
		spellIDs = {
			[49016] = "Unholy Frenzy", --Rank 1.
		},
	},
	["Vampiric Blood"] = { --Blood only.
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_shadow_lifedrain",
		cooldown = 60,
		minLevel = 76,
		specOnly = "BLOOD",
		spellIDs = {
			[55233] = "Vampiric Blood", --Rank 1.
		},
	},
	["Anti Magic Shell"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_shadow_antimagicshell",
		cooldown = 45,
		minLevel = 68,
		spellIDs = {
			[48707] = "Anti-Magic Shell", --Rank 1.
		},
	},
	["Dark Simulacrum"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_holy_consumemagic",
		cooldown = 60,
		minLevel = 85,
		glyphCooldownAdjust = {
			[63331] = 30, --Glyph of Dark Simulacrum.
		},
		spellIDs = {
			[77606] = "Dark Simulacrum", --Rank 1.
		},
	},
	["Raise Ally"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_shadow_deadofnight",
		cooldown = 600,
		minLevel = 72,
		spellIDs = {
			[61999] = "Raise Ally", --Rank 1.
		},
	},
	["Purgatory"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\inv_misc_shadowegg",
		cooldown = 180,
		minLevel = 57,
		watchForAura = true,
		talentOnly = {
			tabIndex = 2,
			talentIndex = 3,
		},
		spellIDs = {
			[116888] = "Purgatory", --This is actually the "Shroud of Purgatory" 3 second debuff.
		},
	},
	["Lichborne"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_shadow_raisedead",
		cooldown = 120,
		minLevel = 57,
		talentOnly = {
			tabIndex = 2,
			talentIndex = 1,
		},
		spellIDs = {
			[49039] = "Lichborne",
		},
	},
	["Asphyxiate"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\ability_deathknight_asphixiate",
		cooldown = 30,
		minLevel = 58,
		talentOnly = {
			tabIndex = 3,
			talentIndex = 3,
		},
		spellIDs = {
			[108194] = "Asphyxiate",
		},
	},
	["Death Pact"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\spell_shadow_deathpact",
		cooldown = 120,
		minLevel = 60,
		talentOnly = {
			tabIndex = 4,
			talentIndex = 1,
		},
		spellIDs = {
			[48743] = "Death Pact",
		},
	},
	["Gorefiend's Grasp"] = {
		class = "DEATHKNIGHT",
		icon = "Interface\\Icons\\ability_deathknight_aoedeathgrip",
		cooldown = 60,
		minLevel = 90,
		talentOnly = {
			tabIndex = 6,
			talentIndex = 1,
		},
		spellIDs = {
			[108199] = "Gorefiend's Grasp",
		},
	},
	--Druid.
	["Rebirth"] = {
		class = "DRUID",
		icon = "Interface\\Icons\\spell_nature_reincarnation",
		cooldown = 600,
		minLevel = 56,
		spellIDs = {
			[20484] = "Rebirth", --Rank 1.
		},
	},
	["Innervate"] = {
		class = "DRUID",
		icon = "Interface\\Icons\\spell_nature_lightning",
		cooldown = 180,
		minLevel = 54,
		spellIDs = {
			[29166] = "Innervate", --Rank 1.
		},
	},
	["Tranquility"] = {
		class = "DRUID",
		icon = "Interface\\Icons\\spell_nature_tranquility",
		cooldown = 480,
		minLevel = 74,
		spellIDs = {
			[740] = "Tranquility", --Rank 1.
		},
	},
	["Survival Instincts"] = { --Guardian only.
		class = "DRUID",
		icon = "Interface\\Icons\\ability_druid_tigersroar",
		cooldown = 180,
		minLevel = 56,
		specOnly = "GUARDIAN",
		glyphCooldownAdjust = {
			[114223] = 60, --Glyph of Survival Instincts.
		},
		spellIDs = {
			[61336] = "Survival Instincts", --Rank 1.
		},
	},
	["Starfall"] = { --Balance only.
		class = "DRUID",
		icon = "Interface\\Icons\\ability_druid_starfall",
		cooldown = 90,
		minLevel = 76,
		specOnly = "BALANCE",
		glyphCooldownAdjust = {
			[54828] = 30, --Glyph of Starfall.
		},
		spellIDs = {
			[48505] = "Starfall", --Rank 1.
		},
	},
	["Barkskin"] = {
		class = "DRUID",
		icon = "Interface\\Icons\\spell_nature_stoneclawtotem",
		cooldown = 60,
		minLevel = 44,
		spellIDs = {
			[22812] = "Barkskin", --Rank 1.
		},
	},
	["Stampeding Roar"] = {
		class = "DRUID",
		icon = "Interface\\Icons\\spell_druid_stamedingroar",
		cooldown = 120,
		minLevel = 84,
		spellIDs = {
			[106898] = "Stampeding Roar",
		},
	},
	["Typhoon"] = {
		class = "DRUID",
		icon = 236170,
		cooldown = 30,
		minLevel = 45,
		talentOnly = {
			tabIndex = 3,
			talentIndex = 3,
		},
		spellIDs = {
			[132469] = "Typhoon",
		},
	},
	["Mass Entanglement"] = {
		class = "DRUID",
		icon = 538515,
		cooldown = 30,
		minLevel = 45,
		talentOnly = {
			tabIndex = 3,
			talentIndex = 2,
		},
		spellIDs = {
			[102359] = "Mass Entanglement",
		},
	},
	["Incarnation"] = {
		class = "DRUID",
		icon = 571586,
		cooldown = 180,
		minLevel = 60,
		talentOnly = {
			tabIndex = 4,
			talentIndex = 2,
		},
		spellIDs = {
			[106731] = "Incarnation",
		},
	},
	["Disorienting Roar"] = {
		class = "DRUID",
		icon = 132121,
		cooldown = 30,
		minLevel = 75,
		talentOnly = {
			tabIndex = 5,
			talentIndex = 1,
		},
		spellIDs = {
			[99] = "Disorienting Roar",
		},
	},
	["Ursol's Vortex"] = {
		class = "DRUID",
		icon = 571588,
		cooldown = 60,
		minLevel = 75,
		talentOnly = {
			tabIndex = 5,
			talentIndex = 2,
		},
		spellIDs = {
			[102793] = "Ursol's Vortex",
		},
	},
	["Mighty Bash"] = {
		class = "DRUID",
		icon = 132114,
		cooldown = 50,
		minLevel = 75,
		talentOnly = {
			tabIndex = 5,
			talentIndex = 3,
		},
		spellIDs = {
			[5211] = "Mighty Bash",
		},
	},
	["Heart of the Wild"] = {
		class = "DRUID",
		icon = 135879,
		cooldown = 360,
		minLevel = 90,
		talentOnly = {
			tabIndex = 6,
			talentIndex = 1,
		},
		spellIDs = {
			[108288] = "Heart of the Wild",
		},
	},
	["Nature's Vigil"] = {
		class = "DRUID",
		icon = 236764,
		cooldown = 90,
		minLevel = 90,
		talentOnly = {
			tabIndex = 6,
			talentIndex = 3,
		},
		spellIDs = {
			[124974] = "Nature's Vigil",
		},
	},
	["Ironbark"] = {
		class = "DRUID",
		icon = 572025,
		cooldown = 60,
		minLevel = 64,
		specOnly = "RESTORATION",
		spellIDs = {
			[102342] = "Ironbark", --Rank 1.
		},
	},
	--Hunter.
	--[[["Misdirection"] = { --Only triggers if damage is done, needs custom code added to track when the cooldown starts, probably not worth the trouble to track track a 30 seconds cooldown.
		class = "HUNTER",
		icon = "Interface\\Icons\\ability_hunter_misdirection",
		cooldown = 30,
		minLevel = 76,
		spellIDs = {
			[34477] = "Misdirection", --Rank 1.
		},
	},]]
	["Binding Shot"] = {
		class = "HUNTER",
		icon = 462650,
		cooldown = 45,
		minLevel = 30,
		talentOnly = {
			tabIndex = 2,
			talentIndex = 1,
		},
		spellIDs = {
			[109248] = "Binding Shot",
		},
	},
	["Deterrence"] = {
		class = "HUNTER",
		icon = 132369,
		cooldown = 180,
		minLevel = 78,
		cooldownAdjust = { --Crouching Tiger, Hidden Chimera.
			tabIndex = 1,
			talentIndex = 3,
			[1] = 60,
		},
		spellIDs = {
			[19263] = "Deterrence",
		},
	},
	--Mage.
	["Evocation"] = {
		class = "MAGE",
		icon = "Interface\\Icons\\spell_nature_purge",
		cooldown = 120,
		minLevel = 40,
		spellIDs = {
			[12051] = "Evocation", --Rank 1.
		},
	},
	["Ice Block"] = { --Casting cold snap needs to reset this cooldown.
		class = "MAGE",
		icon = "Interface\\Icons\\spell_frost_frost",
		cooldown = 300,
		minLevel = 26,
		resetBySpellID = 11958,
		spellIDs = {
			[45438] = "Ice Block", --Rank 1.
		},
	},
	["Invisibility"] = {
		class = "MAGE",
		icon = "Interface\\Icons\\ability_mage_invisibility",
		cooldown = 300,
		minLevel = 56,
		customCooldown = { --Add this later for shared spells with diff cooldowns, greater invis.
			[110959] = 90,
		},
		spellIDs = {
			[66] = "Invisibility", --Rank 1.
			[110959] = "Invisibility", --Greater invis talent.
		},
	},
	["Time Warp"] = {
		class = "MAGE",
		icon = "Interface\\Icons\\ability_mage_timewarp",
		cooldown = 300,
		minLevel = 84,
		spellIDs = {
			[80353] = "Time Warp", --Rank 1.
		},
	},
	["Cold Snap"] = {
		class = "MAGE",
		icon = 135865,
		cooldown = 180,
		minLevel = 60,
		talentOnly = {
			tabIndex = 4,
			talentIndex = 3,
		},
		spellIDs = {
			[11958] = "Cold Snap",
		},
	},
	["Ring of Frost"] = {
		class = "MAGE",
		icon = 464484,
		cooldown = 45,
		minLevel = 45,
		talentOnly = {
			tabIndex = 3,
			talentIndex = 1,
		},
		spellIDs = {
			[113724] = "Ring of Frost",
		},
	},
	--Monk.
	--[[[""] = {
		class = "MONK",
		icon = 0,
		cooldown = ,
		minLevel = ,
		talentOnly = {
			tabIndex = ,
			talentIndex = ,
		},
		spellIDs = {
			[] = "",
		},
	},]]
	["Avert Harm"] = {
		class = "MONK",
		icon = 627605,
		cooldown = 180,
		minLevel = 48,
		specOnly = "BREWMASTER",
		spellIDs = {
			[115213] = "Avert Harm",
		},
	},
	["Life Cocoon"] = {
		class = "MONK",
		icon = 627485,
		cooldown = 120,
		minLevel = 50,
		specOnly = "MISTWEAVER",
		spellIDs = {
			[116849] = "Life Cocoon",
		},
	},
	["Revival"] = {
		class = "MONK",
		icon = 237573,
		cooldown = 180,
		minLevel = 78,
		specOnly = "MISTWEAVER",
		spellIDs = {
			[115310] = "Revival",
		},
	},
	--Paladin.
	["Divine Shield"] = {
		class = "PALADIN",
		icon = "Interface\\Icons\\spell_holy_divineintervention",
		cooldown = 300,
		minLevel = 18,
		cooldownAdjust = { --Unbreakable spirit.
			tabIndex = 4,
			talentIndex = 2,
			[1] = 150,
		},
		spellIDs = {
			[642] = "Divine Shield", --Rank 1.
		},
	},
	["Divine Protection"] = {
		class = "PALADIN",
		icon = "Interface\\Icons\\spell_holy_restoration",
		cooldown = 60,
		minLevel = 26,
		cooldownAdjust = { --Unbreakable spirit.
			tabIndex = 4,
			talentIndex = 2,
			[1] = 30,
		},
		spellIDs = {
			[498] = "Divine Protection", --Rank 1.
		},
	},
	["Lay on Hands"] = {
		class = "PALADIN",
		icon = "Interface\\Icons\\spell_holy_layonhands",
		cooldown = 600,
		minLevel = 16,
		cooldownAdjust = { --Unbreakable spirit.
			tabIndex = 4,
			talentIndex = 2,
			[1] = 300,
		},
		glyphCooldownAdjust = {
			[54939] = -120, --Glyph of Divinity.
		},
		spellIDs = {
			[633] = "Lay on Hands", --Rank 1.
		},
	},
	["Hand of Protection"] = {
		class = "PALADIN",
		icon = "Interface\\Icons\\spell_holy_sealofprotection",
		cooldown = 300,
		minLevel = 48,
		title = "Hand of Prot",
		spellIDs = {
			[1022] = "Hand of Protection", --Rank 1.
		},
	},
	["Hand of Sacrifice"] = {
		class = "PALADIN",
		icon = "Interface\\Icons\\spell_holy_sealofsacrifice",
		cooldown = 120,
		minLevel = 80,
		title = "Hand of Sac",
		spellIDs = {
			[6940] = "Hand of Sacrifice", --Rank 1.
		},
	},
	["Hand of Salvation"] = {
		class = "PALADIN",
		icon = "Interface\\Icons\\spell_holy_sealofsalvation",
		cooldown = 120,
		minLevel = 66,
		title = "Hand of Salv",
		spellIDs = {
			[1038] = "Hand of Salvation", --Rank 1.
		},
	},
	["Hand of Freedom"] = {
		class = "PALADIN",
		icon = "Interface\\Icons\\spell_holy_sealofvalor",
		cooldown = 25,
		minLevel = 52,
		spellIDs = {
			[1044] = "Hand of Freedom", --Rank 1.
		},
	},
	["Hammer of Justice"] = {
		class = "PALADIN",
		icon = 135963,
		cooldown = 60,
		minLevel = 15,
		talentOnly = {
			tabIndex = 2,
			talentIndex = 1,
		},
		customCooldown = { --Fist of justice has lower cd.
			[105593] = 30,
		},
		spellIDs = {
			[853] = "Hammer of Justice",
			[105593] = "Fist of Justice",
		},
	},
	["Hand of Purity"] = {
		class = "PALADIN",
		icon = 135970,
		cooldown = 30,
		minLevel = 60,
		talentOnly = {
			tabIndex = 4,
			talentIndex = 1,
		},
		spellIDs = {
			[114039] = "Hand of Purity",
		},
	},
	["Devotion Aura"] = {
		class = "PALADIN",
		icon = 135872,
		cooldown = 180,
		minLevel = 60,
		glyphCooldownAdjust = {
			[146955] = 60, --Glyph of Devotion Aura.
		},
		spellIDs = {
			[31821] = "Devotion Aura",
		},
	},
	--Priest.
	["Fear Ward"] = {
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_holy_excorcism",
		cooldown = 180,
		minLevel = 54,
		glyphCooldownAdjust = {
			[55678] = 60, --Glyph of Fear Ward.
		},
		spellIDs = {
			[6346] = "Fear Ward", --Rank 1.
		},
	},
	["Shadowfiend"] = {
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_shadow_shadowfiend",
		cooldown = 180,
		minLevel = 42,
		customCooldown = {
			[123040] = 60,	--Mindbender talent overwrites shadowfiend with shorter cooldown.
		},
		spellIDs = {
			[34433] = "Shadowfiend", --Rank 1.
			[123040] = "Mindbender",
		},
	},
	["Psychic Scream"] = {
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_shadow_psychicscream",
		cooldown = 30,
		minLevel = 12,
		spellIDs = {
			[8122] = "Psychic Scream", --Rank 1.
		},
	},
	["Power Infusion"] = {
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_holy_powerinfusion",
		cooldown = 120,
		minLevel = 75,
		talentOnly = {
			tabIndex = 5,
			talentIndex = 2,
		},
		spellIDs = {
			[10060] = "Power Infusion", --Rank 1.
		},
	},
	["Pain Suppression"] = { --Disc only.
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_holy_painsupression",
		cooldown = 180,
		minLevel = 58,
		title = "Pain Supp",
		--specOnly = "DISCIPLINE",
		spellIDs = {
			[33206] = "Pain Suppression", --Rank 1.
		},
	},
	["Divine Hymn"] = { --Holy only.
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_holy_divinehymn",
		cooldown = 180,
		minLevel = 78,
		specOnly = "HOLY",
		spellIDs = {
			[64843] = "Divine Hymn", --Rank 1.
		},
	},
	["Hymn of Hope"] = {
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_holy_symbolofhope",
		cooldown = 360,
		minLevel = 66,
		spellIDs = {
			[64901] = "Hymn of Hope", --Rank 1.
		},
	},
	["Guardian Spirit"] = { --Holy only.
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_holy_guardianspirit",
		cooldown = 180,
		minLevel = 70,
		specOnly = "HOLY",
		spellIDs = {
			[47788] = "Guardian Spirit", --Rank 1.
		},
	},
	["Leap of Faith"] = {
		class = "PRIEST",
		icon = "Interface\\Icons\\priest_spell_leapoffaith_a",
		cooldown = 90,
		minLevel = 70,
		spellIDs = {
			[73325] = "Leap of Faith", --Rank 1.
		},
	},
	["Power Word: Barrier"] = { --Disc only.
		class = "PRIEST",
		icon = "Interface\\Icons\\spell_holy_powerwordbarrier",
		cooldown = 180,
		minLevel = 70,
		title = "PW: Barrier",
		specOnly = "DISCIPLINE",
		spellIDs = {
			[62618] = "Power Word: Barrier", --Rank 1.
		},
	},
	["Void Tendrils"] = {
		class = "PRIEST",
		icon = 537022,
		cooldown = 30,
		minLevel = 15,
		talentOnly = {
			tabIndex = 1,
			talentIndex = 1,
		},
		spellIDs = {
			[108920] = "Void Tendrils",
		},
	},
	["Psyfiend"] = {
		class = "PRIEST",
		icon = 537021,
		cooldown = 45,
		minLevel = 15,
		talentOnly = {
			tabIndex = 1,
			talentIndex = 2,
		},
		spellIDs = {
			[108921] = "Psyfiend",
		},
	},
	["Spirit Shell"] = {
		class = "PRIEST",
		icon = 538565,
		cooldown = 60,
		minLevel = 28,
		specOnly = "DISCIPLINE",
		spellIDs = {
			[109964] = "Spirit Shell",
		},
	},
	--Rogue.
	["Blind"] = {
		class = "ROGUE",
		icon = "Interface\\Icons\\spell_shadow_mindsteal",
		cooldown = 120,
		minLevel = 38,
		spellIDs = {
			[2094] = "Blind", --Rank 1.
		},
	},
	["Vanish"] = {
		class = "ROGUE",
		icon = "Interface\\Icons\\ability_vanish",
		cooldown = 120,
		minLevel = 34,
		spellIDs = {
			[1856] = "Vanish", --Rank 1.
		},
	},
	["Evasion"] = {
		class = "ROGUE",
		icon = "Interface\\Icons\\spell_shadow_shadowward",
		cooldown = 120,
		minLevel = 8,
		spellIDs = {
			[5277] = "Evasion", --Rank 1.
		},
	},
	["Distract"] = {
		class = "ROGUE",
		icon = "Interface\\Icons\\ability_rogue_distract",
		cooldown = 30,
		minLevel = 28,
		spellIDs = {
			[1725] = "Distract", --Rank 1.
		},
	},
	["Tricks of the Trade"] = {
		class = "ROGUE",
		icon = "Interface\\Icons\\ability_rogue_tricksofthetrade",
		cooldown = 30,
		minLevel = 78,
		title = "Tricks",
		spellIDs = {
			[57934] = "Tricks of the Trade", --Rank 1.
		},
	},
	["Cloak of Shadows"] = {
		class = "ROGUE",
		icon = "Interface\\Icons\\spell_shadow_nethercloak",
		cooldown = 60,
		minLevel = 58,
		spellIDs = {
			[31224] = "Cloak of Shadows", --Rank 1.
		},
	},
	["Smoke Bomb"] = {
		class = "ROGUE",
		icon = "Interface\\Icons\\ability_rogue_smoke",
		cooldown = 180,
		minLevel = 85,
		spellIDs = {
			[76577] = "Smoke Bomb", --Rank 1.
		},
	},
	["Cheat Death"] = {
		class = "ROGUE",
		icon = 132285,
		cooldown = 90,
		minLevel = 45,
		watchForAura = true,
		talentOnly = {
			tabIndex = 3,
			talentIndex = 1,
		},
		spellIDs = {
			[45182] = "Cheat Death", --This is actually the 3 second "Cheating Death" debuff.
		},
	},
	--Shaman.
	["Earth Elemental"] = {
		class = "SHAMAN",
		icon = "Interface\\Icons\\spell_nature_earthelemental_totem",
		cooldown = 300,
		minLevel = 58,
		spellIDs = {
			[2062] = "Earth Elemental Totem", --Rank 1.
		},
	},
	["Fire Elemental"] = {
		class = "SHAMAN",
		icon = "Interface\\Icons\\spell_fire_elemental_totem",
		cooldown = 300,
		minLevel = 66,
		glyphCooldownAdjust = {
			[55455] = 150, --Glyph of Fire Elemental Totem.
		},
		spellIDs = {
			[2894] = "Fire Elemental Totem", --Rank 1.
		},
	},
	["Reincarnation"] = {
		--This can't be tracked via combat log.
		--We just use rank 1 spellID for our own tracking purposes.
		class = "SHAMAN",
		icon = "Interface\\Icons\\inv_jewelry_talisman_06", --Use ahnk icon so it doesn't look like druid rebirth.
		cooldown = 1800,
		minLevel = 32,
		spellIDs = {
			[20608] = "Reincarnation", --Rank 1.
		},
	},
	["Mana Tide"] = { --Resto only.
		class = "SHAMAN",
		icon = "Interface\\Icons\\spell_frost_summonwaterelemental",
		cooldown = 180,
		minLevel = 56,
		specOnly = "RESTORATION",
		spellIDs = {
			[16190] = "Mana Tide", --Rank 1.
		},
	},
	["Spiritwalker Grace"] = {
		class = "SHAMAN",
		icon = "Interface\\Icons\\spell_shaman_spiritwalkersgrace",
		cooldown = 120,
		minLevel = 85,
		spellIDs = {
			[79206] = "Spiritwalker's Grace", --Rank 1.
		},
	},
	["Spirit Link"] = { --Resto only.
		class = "SHAMAN",
		icon = "Interface\\Icons\\spell_shaman_spiritlink",
		cooldown = 180,
		minLevel = 70,
		specOnly = "RESTORATION",
		spellIDs = { --Call of the Elements talent doesn't effect this cooldown, has to be below 3mins and not exactly 3mins.
			[98008] = "Spirit Link", --Rank 1.
		},
	},
	["Earthgrab Totem"] = {
		class = "SHAMAN",
		icon = 136100,
		cooldown = 30,
		minLevel = 30,
		talentOnly = {
			tabIndex = 2,
			talentIndex = 2,
		},
		spellIDs = {
			[51485] = "Earthgrab Totem",
		},
	},
	["Astral Shift"] = {
		class = "SHAMAN",
		icon = 538565,
		cooldown = 90,
		minLevel = 15,
		talentOnly = {
			tabIndex = 1,
			talentIndex = 3,
		},
		spellIDs = {
			[108271] = "Astral Shift",
		},
	},
	["Elemental Mastery"] = {
		class = "SHAMAN",
		icon = 136115,
		cooldown = 90,
		minLevel = 60,
		talentOnly = {
			tabIndex = 4,
			talentIndex = 1,
		},
		spellIDs = {
			[16166] = "Elemental Mastery",
		},
	},
	["Ancestral Guidance"] = {
		class = "SHAMAN",
		icon = 538564,
		cooldown = 120,
		minLevel = 75,
		talentOnly = {
			tabIndex = 5,
			talentIndex = 2,
		},
		spellIDs = {
			[108281] = "Ancestral Guidance",
		},
	},
	["Stormlash Totem"] = {
		class = "SHAMAN",
		icon = 538575,
		cooldown = 300,
		minLevel = 78,
		talentOnly = {
			tabIndex = 5,
			talentIndex = 2,
		},
		spellIDs = {
			[120668] = "Stormlash Totem",
		},
	},
	--Warlock.
	["Soulstone"] = {
		class = "WARLOCK",
		icon = "Interface\\Icons\\spell_shadow_soulgem",
		cooldown = 600,
		minLevel = 18,
		spellIDs = { --"Use item" spell ID of the Soulstone item in bag.
			--There is no item in mop? just casts on the target?
			[20707] = "Minor Soulstone", --Rank 1.
		},
	},
	["Soulshatter"] = {
		class = "WARLOCK",
		icon = "Interface\\Icons\\spell_arcane_arcane01",
		cooldown = 120,
		minLevel = 66,
		spellIDs = {
			[29858] = "Soulshatter", --Rank 1.
		},
	},
	["Death Coil"] = { --It's actually called mortal coil in MoP but we'll leave it as death coil.
		class = "WARLOCK",
		icon = "Interface\\Icons\\spell_shadow_deathcoil",
		cooldown = 120,
		minLevel = 42,
		spellIDs = {
			[6789] = "Mortal Coil",  --The spellID in spellbook when talent is trained.
			[108396] = "Mortal Coil", --Not sure what this second spellID is but check for it anyway.
		},
	},
	["Shadowfury"] = {
		class = "WARLOCK",
		icon = 607865,
		cooldown = 30,
		minLevel = 30,
		talentOnly = {
			tabIndex = 2,
			talentIndex = 3,
		},
		spellIDs = {
			[30283] = "Shadowfury",
		},
	},
	--Warrior.
	["Mocking Banner"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\mocking_banner",
		cooldown = 180,
		minLevel = 87,
		spellIDs = {
			[114192] = "Mocking Banner", --Rank 1.
		},
	},
	["Demoralizing Banner"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\demoralizing_banner",
		cooldown = 180,
		minLevel = 87,
		title = "Demo Banner",
		spellIDs = {
			[114203] = "Demoralizing Banner", --Rank 1.
		},
	},
	["Skull Banner"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\warrior_skullbanner",
		cooldown = 180,
		minLevel = 87,
		spellIDs = {
			[114207] = "Skull Banner", --Rank 1.
		},
	},
	["Intimidating Shout"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\ability_golemthunderclap",
		cooldown = 90,
		minLevel = 52,
		spellIDs = {
			[5246] = "Intimidating Shout", --Rank 1.
		},
	},
	["Recklessness"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\ability_criticalstrike",
		cooldown = 180,
		minLevel = 62,
		spellIDs = {
			[1719] = "Recklessness", --Rank 1.
		},
	},
	["Shield Wall"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\ability_warrior_shieldwall",
		cooldown = 180,
		minLevel = 48,
		glyphCooldownAdjust = {
			[63329] = -120, --Glyph of Shield Wall adds 120 seconds.
		},
		spellIDs = {
			[871] = "Shield Wall", --Rank 1.
		},
	},
	["Shattering Throw"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\ability_warrior_shatteringthrow",
		cooldown = 300,
		minLevel = 74,
		spellIDs = {
			[64382] = "Shattering Throw", --Rank 1.
		},
	},
	["Last Stand"] = { --Prot only.
		class = "WARRIOR",
		icon = "Interface\\Icons\\spell_holy_ashestoashes",
		cooldown = 180,
		minLevel = 38,
		spellIDs = {
			[12975] = "Last Stand", --Rank 1.
		},
	},
	["Rallying Cry"] = {
		class = "WARRIOR",
		icon = "Interface\\Icons\\ability_toughness",
		cooldown = 180,
		minLevel = 83,
		spellIDs = {
			[97462] = "Rallying Cry", --Rank 1.
		},
	},
	["Mass Spell Reflection"] = {
		class = "WARRIOR",
		icon = 132358,
		cooldown = 60,
		minLevel = 75,
		talentOnly = {
			tabIndex = 5,
			talentIndex = 1,
		},
		spellIDs = {
			[114028] = "Mass Spell Reflection",
		},
	},
	["Dragon Roar"] = {
		class = "WARRIOR",
		icon = 642418,
		cooldown = 60,
		minLevel = 60,
		talentOnly = {
			tabIndex = 4,
			talentIndex = 3,
		},
		spellIDs = {
			[118000] = "Dragon Roar",
		},
	},
	["Avatar"] = {
		class = "WARRIOR",
		icon = 613534,
		cooldown = 180,
		minLevel = 90,
		talentOnly = {
			tabIndex = 6,
			talentIndex = 1,
		},
		spellIDs = {
			[107574] = "Avatar",
		},
	},
	["Storm Bolt"] = {
		class = "WARRIOR",
		icon = 613535,
		cooldown = 30,
		minLevel = 90,
		talentOnly = {
			tabIndex = 6,
			talentIndex = 3,
		},
		spellIDs = {
			[107570] = "Storm Bolt",
		},
	},
	["Vigilance"] = {
		class = "WARRIOR",
		icon = 236318,
		cooldown = 120,
		minLevel = 75,
		talentOnly = {
			tabIndex = 3,
			talentIndex = 5,
		},
		spellIDs = {
			[114030] = "Vigilance",
		},
	},
	--[[["Shockwave"] = { --Don't track shockwave, hitting 3 targets lowers the CD, it could be tracked and adjusted but not really worth it for such a short cooldown ability.
		class = "WARRIOR",
		icon = 236312,
		cooldown = 40,
		minLevel = 60,
		--talentOnly = { --Must hit 3 targets for this to trigger.
		--	tabIndex = 4,
		--	talentIndex = 2,
		--},
		spellIDs = {
			[46968] = "Shockwave",
		},
	},]]
};

--Add faction specific spells.
if (NRC.faction == "Alliance") then
	NRC.cooldowns["Heroism"] = {
		class = "SHAMAN",
		icon = "Interface\\Icons\\ability_shaman_heroism",
		cooldown = 300,
		minLevel = 70,
		spellIDs = {
			[32182] = "Heroism", --Rank 1.
		},
	};
else
	NRC.cooldowns["Bloodlust"] = {
		class = "SHAMAN",
		icon = "Interface\\Icons\\spell_nature_bloodlust",
		cooldown = 300,
		minLevel = 70,
		spellIDs = {
			[2825] = "Bloodlust", --Rank 1.
		},
	};
end

--Cooldoowns that need to watch for an aura instead of a spell cast, like cheat death etc.
NRC.cooldownsWithAura = {};
for k, v in pairs(NRC.cooldowns) do
	if (v.watchForAura) then
		NRC.cooldownsWithAura[k] = v;
	end
end

NRC.resetBySpellID = {};
for k, v in pairs(NRC.cooldowns) do
	if (v.resetBySpellID) then
		NRC.resetBySpellID[k] = v;
	end
	if (v.talentOnly or v.specOnly) then
		v.castDetect = true;
	end
	if (v.specOnly) then
		v.castDetectOnly = true; --Temp fix unless I add proper spec detection, only show spec spcific spells when seen cast.
	end
end

--Print a rundown of class cooldowns for this expansion.