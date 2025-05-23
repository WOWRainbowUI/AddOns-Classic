if not Stuf then return end

local Stuf = Stuf
local su = Stuf.units
local db

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local smed = LibStub("LibSharedMedia-3.0")

local rawget, _Global = rawget, getfenv(0)
local _G = setmetatable({ }, {
	__index = function(self, key)
		return _Global[key] or key or "blah"
	end
})
local floor, type = floor, type
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight

-- for external localization, make a mod titled Stuf_OptionsLocale and create table StufOptionsLocalization
local L = setmetatable(StufOptionsLocalization or { 
	pettarget = _G.PET.." ".._G.TARGET,
	party1 = _G.PARTY.." 1",
	partypet1 = _G.PARTY.." 1 ".._G.PET,
	arena1 = _G.ARENA.." 1",
	arenapet1 = _G.ARENA.." 1 ".._G.PET,
	arena1target = _G.ARENA.." 1 ".._G.TARGET,
	taghelptext =
		"Tag Help:\n"..
		"[|cff00ff00infotag|r] or [|cffff9900colortag|r:|cff00ff00infotag|r] or\n"..
		"[|cffff9900colortag|r_if_|cffffff00condition|r:|cff00ff00infotag|r] or [|cffff9900colortag|r_ifnot_|cffffff00condition|r:|cff00ff00infotag|r]\n"..
		"* if infotag does not exist, it will be shown as is\n"..
		"* if the condition is false, the infotag is hidden\n"..
		"* tag without colortag or with colortag 'solid' will be colored by 'Font Color'\n"..
		"* all text outside of the brackets are left alone\n\n"..
		"|cff00ff00infotag|r:\n"..
		"  - name, class, level, classification |cffaaaaaa(elite, boss, etc)|r, race, creaturetype, guild, titlename\n"..
		"  - |cffaaaaaaHealth tags:|r curhp, maxhp, perchp, deficithp\n"..
		"  - |cffaaaaaaPower tags:|r curmp, maxmp, percmp, deficitmp, shards\n"..
		"  - nl |cffaaaaaa(new line)|r, % |cffaaaaaa(percent sign)|r, lp |cffaaaaaa('(')|r, rp |cffaaaaaa(')')|r,\n"..
		"  - |cffaaaaaaany other text will be displayed as is|r\n\n"..
		"|cffff9900colortag|r:\n"..
		"  - class, classdark, reaction, reactiondark, difficulty, difficultydark\n"..
		"  - classreaction |cffaaaaaa(reaction if NPC/PVP, else class)|r, classreactiondark,\n"..
		"  - reactionnpc |cffaaaaaa(reaction if NPC, class if PC)|r, reactionnpcdark,\n"..
		"  - hpgreen, hpgreendark, hpred, hpreddark, hpthreshold, hpthresholddark\n"..
		"  - power, powerdark,\n"..
		"  - gray, solid, custom\n\n"..
		"|cffffff00condition|r:\n"..
		"  - npc |cffaaaaaa(not player controlled)|r, pc, male, female, pvp,\n"..
		"  - helpful, enemy, hostile, attackable, boss,\n"..
		"  - combat, selfcombat, tapped, dead, ghost, offline, alive, afk, dnd, ingroup,\n"..
		"  - hp10 |cffaaaaaa(health < 10%)|r, hp20, hp35, hp99, mp15 |cffaaaaaa(mana < 15%)|r, mp99, manapower |cffaaaaaa(type mana)|r \n"..
		"  - oor |cffaaaaaa(unit is not visible or support spell out of range)|r, aggro\n\n"..
		"Examples:\n"..
		" 1. [name] - shows unit's name by default font color\n"..
		" 2. [class:name] - shows unit's name by class color\n"..
		" 3. [class_if_pc:name] - shows unit name by class color if player controlled, hide otherwise\n"..
		" 4. [class:blahblah] - shows the text 'blahblah' by class color\n"..
		" 5. [curhp] / [maxhp] - shows current health and max health separated by ' / '",
	pushhelp = "Adjust position from set location depending on the specified \"from\" element's width, height, and/or growth direction.",
	playerbuffs = "Buffs can be canceled by right-clicking the red box. Pushing is disabled for player buffs.",
	draghelp = "Enable draggable unitframes\n"..
	    "|cff00ff00<Drag> any unit frame to move that single frame\n"..
	    "<Control-drag> any unit frame to move all frames\n"..
		"<Shift-drag> any party or arena frame to move all related units|r",
	advancecodehelp = "Lua code must have this format: |cff888888function(unit, cache, textframe) <some code> return \"text\", ... end|r "..
		"where 'cache' may be used as |cff888888cache.|cff00ff00infotag|r (see Pattern Tag Help or core.lua)|r and \"...\" are optional arguments to SetFormattedText",
	generalhelp = "* Enable 'Toggle Highlighter' to help locate certain elements while configuring.\n"..
		"* Check thru 'Global' options for shared settings.\n"..
		"* All sliders have three methods of changing values:\n"..
		"  - Click and drag slider\n"..
		"  - Manually change values in input box and then press Enter\n"..
		"  - Mouse-wheel nudging:\n"..
		"    1. Move your cursor over the text above the slider (a tooltip should be showing).\n"..
		"    2. Move your cursor up until the tooltip disappears.\n"..
		"    3. Left-click.\n"..
		"    4. Move your cursor back over the slider until the tooltip reappears.\n"..
		"    5. Now you can nudge using mouse-wheel.\n"..
		"* You can save settings per character by enabling it at the bottom of this page.\n"..
		"* Visit the website above for more information and changelog.",
}, 
{
	__index = function(self, key)
		return rawget(self, key) or key
	end
})


local highlight, taghelp, drag, config
local function OnDragStart(this)
	if not this.db or not InCombatLockdown() then
		if this.db then
			if IsControlKeyDown() then
				this.movingall = true
				local scale = this.dbf.scale or 1
				local ox, oy = this.db.x * scale, this.db.y * scale
				for unit, uf in pairs(su) do
					if uf ~= this then
						uf:ClearAllPoints()
						local s = uf.dbf.scale or 1
						uf:SetPoint("TOPLEFT", this, "TOPLEFT", uf.db.x - ox / s, uf.db.y - oy / s)
					end
				end
			elseif IsShiftKeyDown() then
				local group = strmatch(this.unit, "party") or strmatch(this.unit, "arena") or strmatch(this.unit, "boss")
				if group then
					this.movinggroup = group
					local scale = this.dbf.scale or 1
					local ox, oy = this.db.x * scale, this.db.y * scale
					for unit, uf in pairs(su) do
						if uf ~= this and strmatch(unit, this.movinggroup) then
							uf:ClearAllPoints()
							local s = uf.dbf.scale or 1
							uf:SetPoint("TOPLEFT", this, "TOPLEFT", uf.db.x - ox / s, uf.db.y - oy / s)
						end
					end
				end
			end
		end
		this:StartMoving()
	end
end
local function OnDragStop(this)
	if this.db then
		this:StopMovingOrSizing()
		local scale = this.dbf.scale or 1
		local ox, oy = this.db.x, this.db.y
		local cx, cy = floor(this:GetLeft() + 0.5), floor(this:GetTop() - GetScreenHeight()/scale + 0.5)
		local dx, dy = (cx - ox) * scale, (cy - oy) * scale
		this.db.x, this.db.y = cx, cy
		this:ClearAllPoints()
		this:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cx, cy)
		if this.movinggroup then
			for unit, dbuf in pairs(db) do
				if unit ~= this.unit and strmatch(unit, this.movinggroup) then
					local copy = Stuf.unitcopy[unit]
					local targetdb = (copy and db[copy]) or db[unit]
					local s = targetdb.frame.scale or 1
					dbuf.frame.x, dbuf.frame.y = floor(dbuf.frame.x + dx/s), floor(dbuf.frame.y + dy/s)
					
					local uf = su[unit]
					if uf then
						uf:StopMovingOrSizing()
						uf:ClearAllPoints()
						uf:SetPoint("TOPLEFT", UIParent, "TOPLEFT", dbuf.frame.x, dbuf.frame.y)
					end
				end
			end
			this.movinggroup = nil
		elseif this.movingall then
			this.movingall = nil
			for unit, dbuf in pairs(db) do
				if unit ~= "global" and unit ~= this.unit then
					local copy = Stuf.unitcopy[unit]
					local targetdb = (copy and db[copy]) or db[unit]
					local s = targetdb.frame.scale or 1
					dbuf.frame.x, dbuf.frame.y = floor(dbuf.frame.x + dx/s), floor(dbuf.frame.y + dy/s)
					
					local uf = su[unit]
					if uf then
						uf:StopMovingOrSizing()
						uf:ClearAllPoints()
						uf:SetPoint("TOPLEFT", UIParent, "TOPLEFT", dbuf.frame.x, dbuf.frame.y)
					end
				end
			end
		end
		this.movingall, this.movinggroup = nil, nil
	else
		this:StopMovingOrSizing()
	end
end

local optionframe
local function CreateOptionFrame()
	if optionframe then return end
	optionframe = AceConfigDialog:AddToBlizOptions("Stuf", L["Stuf"])
	optionframe.fshow = CreateFrame("Frame", nil, optionframe, BackdropTemplateMixin and 'BackdropTemplate')
	optionframe.fshow:SetScript("OnShow", function(this)
		local w = SettingsPanel:GetWidth()
		if not SettingsPanel:IsMovable() then
			this.p, this.rt, this.rp, this.x, this.y = SettingsPanel:GetPoint()
			SettingsPanel:SetMovable(true)
			SettingsPanel:RegisterForDrag("LeftButton")
			SettingsPanel:SetScript("OnDragStart", OnDragStart)
			SettingsPanel:SetScript("OnDragStop", OnDragStop)
			this.moved = true
		end
		if w < 860 then
			this.oldw = w
			SettingsPanel:SetWidth(860)
		else
			this.oldw = nil
		end
	end)
	optionframe.fshow:SetScript("OnHide", function(this)
		--------edited out 5 may 2022
		--	if this.oldw then
		--	SettingsPanel:SetWidth(this.oldw)
		--	this.oldw = nil
		--end
		--------------------
		if this.moved then
			SettingsPanel:SetMovable(false)
			SettingsPanel:RegisterForDrag()
			SettingsPanel:SetScript("OnDragStart", nil)
			SettingsPanel:SetScript("OnDragStop", nil)
			SettingsPanel:ClearAllPoints()
			SettingsPanel:SetPoint(this.p, this.rt, this.rp, this.x, this.y)
		end
	end)
end

----------------------------------------------------------
function Stuf:LoadDefaults(db, restore, perchar, justboss)
----------------------------------------------------------
	CreateOptionFrame()
	
	local screenw, screenh = GetScreenWidth(), GetScreenHeight()
	local arenax, arenay = floor(screenw * 0.7), -200
	local playerx, playery
	
	playerx = floor((screenw - 340)/2)
	playery = -(screenh - 180)
	
	-- 預設關閉個人資源條
	SetCVar("nameplateShowSelf", 0)

	if justboss then
		db.boss1={
			frame={ x=55, y=-170, w=80, h=6, bordercolormethod="reaction", },
			portrait={ x=-38, y=18, w=30, h=30, border="None", },
			hpbar={ x=0, y=1, w=80, h=10, barcolormethod="reaction", bgcolormethod="reactiondark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="None", fade=true, inc=true, framelevel=1, },
			mpbar={ x=95, y=0, w=80, h=8, barcolormethod="power", bgcolormethod="powerdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, }, fade=true, framelevel=1, },
			text1={ pattern="[reaction:name]", 
					x=0, y=20, w=200, h=16, 
					fontsize=16, fontflags="OUTLINE", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="[curhp]", 
					x=0, y=-5, w=85, h=20, fontsize=12, fontflags="OUTLINE", 
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[perchp]%", hide=true,
					x=0, y=-5, w=80, h=20, fontsize=14, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2,	},
			text4={ pattern="[curmp]",
					x=95, y=-5, w=85, h=20, fontsize=12,
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			buffgroup={
					x=240, y=25, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, showpie=true, },
			debuffgroup={ 
					x=240, y=-25, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, onlymine=true, showpie=true, push="None", },
			infoicon={ hide=true, x=-38, y=18, w=30, h=30, circular=true, framelevel=2, },
			castbar={ 
					x=0, y=15, w=175, h=6, alpha=1,
					baralpha=1, bgcolor={ r=0, g=0, b=0, a=0.3, }, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, },
					spellx=0, spelly=20, spellw=140, spellh=16, 
					spellfontsize=14, spellfontflags="OUTLINE", spelljustifyH="RIGHT", spelljustifyV="BOTTOM", spellshadowx=1, spellshadowy=-1,
					spellfontcolor={ r=1, g=1, b=1, a=1, },
					timex=0, timey=-10, timew=120, timeh=20, 
					timefontsize=16, timefontflags="OUTLINE", timejustifyH="RIGHT", timejustifyV="TOP", timefont="傷害數字",
					timefontcolor={ r=1, g=1, b=1, a=1, }, timeformat="none", showlag=true, lagcolor={ r=1, g=0, b=0, a=1, },
					iconx=-48, icony=16, iconw=1, iconh=1, iconalpha=1, framelevel=8, },
			raidtargeticon={ x=-35, y=16, w=26, h=26, framelevel=6, },
			threatbar={ x=0, y=-10, w=40, h=14, bgcolor={ r=0, g=0, b=0, a=0.4, }, fontsize=12, framelevel=4, },
		}
		for i = 2, MAX_BOSS_FRAMES, 1 do
			db["boss"..i]={ frame={ x=55, y=-170 - (60 * (i - 1)), w=80, h=6, }, }
		end
		db.boss1target={
			frame={ x=245, y=-170, w=40, h=6, bordercolormethod="classreaction", },
			portrait={ x=-35, y=12, w=30, h=30, hide=true, },
			hpbar={ x=0, y=1, w=40, h=10, barcolormethod="classreaction", bgcolormethod="classreactiondark",
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="None", fade=true, framelevel=1, },
			mpbar={ hide=true, x=55, y=-1, w=40, h=6, barcolormethod="power", bgcolormethod="powerdark", bordercolor={ r=1, g=0.8, b=0, a=1, },
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="Blizzard Tooltip", fade=true, framelevel=1, },
			text1={ pattern="[classreaction:name]", 
					x=-3, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="", hide=true,
					x=0, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[perchp]%", hide=true,
					x=0, y=-5, w=60, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text4={ pattern="[curmp]", hide=true,
					x=55, y=-5, w=40, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			buffgroup={ 
					hide=true, x=105, y=8, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, },
			debuffgroup={ 
					hide=true, x=105, y=-10, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, push="None", },
			infoicon={ hide=true, x=-35, y=12, w=30, h=30, circular=true, framelevel=2, },
			raidtargeticon={ hide=true, x=-33, y=10, w=26, h=26, framelevel=6, },
		}
		for i = 2, MAX_BOSS_FRAMES, 1 do
			db["boss"..i.."target"]={ frame={ x=245, y=-170 - (60 * (i - 1)) -3, w=40, h=6, }, }
		end
		-- db.boss4.frame.hide = true
		-- db.boss5.frame.hide = true
		-- db.boss4target.frame.hide = true
		-- db.boss5target.frame.hide = true
		return
	end

	local defaults={
		global={
			bartexture="Blizzard",
			bglist="statusbar",
			bg="Blizzard",
			font= ((GetLocale() == "enUS" or GetLocale() == "enGB") and "Franklin Gothic Medium") or smed:GetDefault("font"),
			bgcolor={ r=0, g=0, b=0, a=0.4, },
			bgmousecolor={ r=1, g=1, b=0, a=0.6, },
			border="Blizzard Tooltip",
			borderaggrocolor={ r=1, g=0, b=0, a=0, },
			bordermousecolor={ r=1, g=1, b=0, a=0, },
			alpha=1, shortk=10000,
			classification={
				worldboss=L[" Boss"],
				rareelite=L["+ Rare"],
				elite=L["+"],
				rare=L[" Rare"],
				normal="",
			},
			classcolor={ }, 
			reactioncolor={ 
				[1]={ r=1, g=0, b=0, },		-- 仇恨
				[2]={ r=0.8, g=0, b=0, },	-- 敵對
				[3]={ r=1, g=0.3, b=0, },	-- 不友好
				[4]={ r=1, g=1, b=0, },		-- 中立
				[5]={ r=0.4, g=0.8, b=0.2, },	-- 友好
				[6]={ r=0, g=0.9, b=0, },	-- 尊敬
				[7]={ r=0, g=0.7, b=0, },	-- 崇敬
				[8]={ r=0, g=0.5, b=0, },	-- 崇拜
				[9]={ r=0.8, g=1, b=0.8, },
				[10]={ r=1, g=0.8, b=0.8, },
			},
			powercolor={
				[0]={ r=0.2, g=0.5, b=1, },	-- 法力
			},
			auracolor={ 
				Buff={ r=0, g=0, b=0, }, 
				MyBuff={ r=0.5, g=0.5, b=0.6 },
			},
			hpgreen={ r=0, g=0.5, b=0, a=1, },
			hpred={ r=0.5, g=0, b=0, a=1, },
			gray={ r=0.4, g=0.4, b=0.4, a=0.8, },
			hpfadecolor={ r=1, g=0.1, b=0.1, a=1, },
			mpfadecolor={ r=1, g=1, b=1, a=0.5, },
			shadowcolor={ r=0, g=0, b=0, a=0.9, },
			castcolor={ r=1, g=0.7, b=0, },
			channelcolor={ r=0, g=1, b=0, },
			completecolor={ r=1, g=1, b=0, },
			failcolor={ r=1, g=0, b=0, },
			hidepartyinraid = true,
			disableboss = true,
			strata="LOW",
		},
		player={
			frame={ x=playerx, y=playery, w=160, h=8, bordercolormethod="solid", bordercolor={ r=1, g=0.8, b=0, a=1, }, },
			portrait={ hide=true, x=-40, y=12, w=30, h=30, border="None", framelevel=3, },
			hpbar={ x=0, y=1, w=160, h=10, barcolormethod="class", bgcolormethod="classdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="None", fade=true, inc=true, framelevel=1, },
			mpbar={ x=180, y=0, w=160, h=10, barcolormethod="power", bgcolormethod="powerdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="Blizzard Tooltip",  bordercolor={ r=1, g=0.8, b=0, a=1, }, fade=true, framelevel=1, },
			text1={ pattern="[class:name] [class:level][class:級]", 
					x=0, y=18, w=200, h=16, 
					fontsize=14, fontflags="None", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="", hide=true,
					x=0, y=18, w=20, h=16, 
					fontsize=14, fontflags="None", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[curhp]", 
					x=0, y=-5, w=160, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text4={ pattern="[curmp]", 
					x=180, y=-5, w=160, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text5={ pattern="[percmp]%", 
					x=180, y=-5, w=165, h=20, 
					fontsize=14, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text6={ pattern="[gray_if_dead:死亡][gray_if_ghost:靈魂]", 
					x=0, y=20, w=160, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="RIGHT", justifyV="CENTER", shadowx=1, shadowy=-1, framelevel=2, },
			text7={ pattern="[perchp]%", 
					x=0, y=-5, w=165, h=20, 
					fontsize=14, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text8={ pattern="", hide=true,
					x=0, y=18, w=200, h=16, 
					fontsize=14, fontflags="None", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			combattext={ hide=true, x=0, y=-15, w=200, h=18, fontsize=16, justifyH="LEFT", justifyV="CENTER", shadowx=-1, shadowy=-1, framelevel=4, },
			grouptext={
					x=-18, y=18, w=18, h=18, 
					fontsize=16, font="傷害數字",
					justifyH="CENTER", fontflags="OUTLINE", justifyV="CENTER", shadowx=1, shadowy=-1, framelevel=4, },
			buffgroup={
					x=350, y=10, w=30, h=30, hide=true,
					count=20, rows=2, cols=10, 
					timey=-10, countty=5, counttfontflags="OUTLINE", growth="LRTB", spacing=2, vspacing=5, showpie=true},
			debuffgroup={ 
					x=350, y=65, w=48, h=48, hide=true,
					count=10, rows=1, cols=10, 
					timey=-10, countty=10, counttfontflags="OUTLINE", growth="LRTB", spacing=2, vspacing=5, showpie=true, push="None", },
			tempenchant={ x=180, y=8, w=36, h=36, count=2, growth="LRBT", spacing=2, },
			dispellicon={ x=125, y=40, w=36, h=36, framelevel=4, },
			voiceicon={ x=-20, y=35, w=20, h=20, framelevel=4,},
			pvpicon={ x=-43, y=14, w=36, h=36, framelevel=4, },
			statusicon={ x=318, y=25, w=24, h=24, framelevel=1, },
			leadericon={ x=0, y=35, w=20, h=20, framelevel=1, },
			looticon={ x=20, y=35, w=20, h=20, framelevel=1, },
			raidtargeticon={ x=-36, y=10, w=26, h=26, framelevel=6, },
			infoicon={ x=-40, y=12, w=30, h=30, circular=true, framelevel=2, },
			lfgicon={ x=-40, y=12, w=30, h=30, circular=true, framelevel=3, },
			totembar={ hide=true, x=262, y=80, w=80, h=12, bgcolor={ r=0, g=0, b=0, a=0.4, }, framelevel=2, fontsize=11, vstack=true, },
			runebar={ x=96, y=45, w=38, h=6, bgcolor={ r=0, g=0, b=0, a=0.4, }, },
			druidbar={
					hide=true, x=360, y=0, w=80, h=10,
					fade=nil, vertical=nil, reverse=nil,
					barcolormethod="solid", bgcolormethod="solid", bgalpha=0.4,
					barcolor={ r=0.3, g=0.3, b=1, }, bgcolor={ r=0, g=0, b=0, },
					bartexture="Blizzard", border="Blizzard Tooltip",  bordercolor={ r=1, g=0.8, b=0, a=1, }, fade=true, framelevel=1, },
			castbar={ 
					hide=false, x=100, y=100, w=160, h=10, alpha=1,
					baralpha=1, bgcolor={ r=0, g=0, b=0, a=0.3, }, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, },
					spellx=0, spelly=20, spellw=160, spellh=16, 
					spellfontsize=14, spellfontflags="OUTLINE", spelljustifyH="LEFT", spelljustifyV="BOTTOM", spellshadowx=1, spellshadowy=-1,
					spellfontcolor={ r=1, g=1, b=1, a=1, },
					timex=0, timey=-12, timew=160, timeh=20, 
					timefontsize=16, timefontflags="OUTLINE", timejustifyH="RIGHT", timejustifyV="TOP", timefont="傷害數字",
					timefontcolor={ r=1, g=1, b=1, a=1, }, timeformat="remaindurationdelay", showlag=true, lagcolor={ r=1, g=0, b=0, a=1, },
					iconx=-48, icony=16, iconw=40, iconh=40, iconalpha=1, framelevel=8,
			},
			vehicleicon={ hide=true, x=-40, y=14, w=32, h=32, framelevel=4, },
			holybar={ x=90, y=-8, },
			shardbar={ x=100, y=30, },
			arcanebar={ x=90, y=40, },
			eclipsebar={ x=90, y=50, },
			priestbar={ x=0, y=0, },
		},
		target={
			frame={ x=55, y=-50, w=320, h=8, bordercolormethod="classreaction", },
			portrait={ hide=true, x=-40, y=12, w=30, h=30, border="None", framelevel=3, },
			hpbar={ x=0, y=1, w=320, h=10, barcolormethod="classreaction", bgcolormethod="classreactiondark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="None", fade=true, inc=true, framelevel=1, },
			mpbar={ x=242, y=-30, w=80, h=8, barcolormethod="power", bgcolormethod="powerdark", bordercolormethod="power", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="Blizzard Tooltip",  bordercolor={ r=1, g=0.8, b=0, a=1, }, fade=true, framelevel=1, },
			text1={ pattern="[classreaction:name] [difficulty:level][difficulty:級][difficulty:classification] [class_if_npc:creaturetype][class_if_pc:race]", 
					x=0, y=18, w=320, h=16, 
					fontsize=16, fontflags="OUTLINE", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="", hide=true,
					x=0, y=18, w=320, h=16, 
					fontsize=14, fontflags="None", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[curhp]", 
					x=5, y=-6, w=320, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text4={ pattern="[curmp]", 
					x=240, y=-40, w=86, h=20, 
					fontsize=14, fontflags="OUTLINE",
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text5={ pattern="[solid_if_manapower:percmp][solid_if_manapower:%]", hide=true,
					x=228, y=-50, w=100, h=20, 
					fontsize=14, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text6={ pattern="[gray_if_oor:距離過遠][gray_if_tapped:無效目標][gray_if_offline:離線][gray_if_dead:死亡][gray_if_ghost:靈魂]", 
					x=5, y=320, w=20, h=20, 
					fontsize=16, fontflags="OUTLINE", font="傷害數字",
					justifyH="RIGHT", justifyV="CENTER", shadowx=1, shadowy=-1, framelevel=2, },
			text7={ pattern="[perchp]%", 
					x=5, y=-6, w=320, h=20, 
					fontsize=14, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text8={ pattern="", hide=true,
					x=0, y=18, w=320, h=16, 
					fontsize=14, fontflags="None", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			combattext={ hide=true, x=0, y=-15, w=200, h=18, fontsize=16, justifyH="LEFT", justifyV="CENTER", shadowx=-1, shadowy=-1, framelevel=4, },
			grouptext={
					x=-18, y=18, w=18, h=18, 
					fontsize=16, font="傷害數字",
					justifyH="CENTER", fontflags="OUTLINE", justifyV="CENTER", shadowx=1, shadowy=-1, framelevel=4, },
			buffgroup={
					x=0, y=-30, w=20, h=20,
					count=30, rows=2, cols=15,
					timey=-10, countty=5, counttfontflags="OUTLINE", growth="LRTB", spacing=2, vspacing=5, showpie=true, },
			debuffgroup={
					x=0, y=-54, w=30, h=30,
					count=10, rows=1, cols=10, 
					timey=-10, countty=10, counttfontflags="OUTLINE", growth="LRTB", spacing=2, vspacing=5, showpie=true, onlymine=true, push="None", framelevel=3, },
			auratimers={
					hide=true, x=340, y=-30, w=70, h=14,
					count=12, rows=6, cols=2, growth="TBLR", push="None", },
			dispellicon={ x=285, y=40, w=36, h=36, framelevel=4, },
			pvpicon={ x=-30, y=20, w=28, h=28, framelevel=4, },
			statusicon={ x=290, y=25, w=24, h=24, framelevel=1, },
			leadericon={ x=0, y=35, w=20, h=20, framelevel=1, },
			looticon={ x=20, y=35, w=20, h=20, framelevel=1, },
			raidtargeticon={ x=-38, y=10, w=26, h=26, framelevel=6, },
			infoicon={ x=-40, y=12, w=30, h=30, circular=true, framelevel=2, },
			lfgicon={ x=-40, y=12, w=30, h=30, circular=true, framelevel=3, },
			castbar={ 
					x=160, y=30, w=160, h=8, alpha=1,
					baralpha=1, bgcolor={ r=0, g=0, b=0, a=0.3, }, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, },
					spellx=0, spelly=20, spellw=170, spellh=16, 
					spellfontsize=14, spellfontflags="OUTLINE", spelljustifyH="LEFT", spelljustifyV="BOTTOM", spellshadowx=1, spellshadowy=-1,
					spellfontcolor={ r=1, g=1, b=1, a=1, },
					timex=0, timey=-10, timew=160, timeh=20, 
					timefontsize=16, timefontflags="OUTLINE", timejustifyH="RIGHT", timejustifyV="TOP", timefont="傷害數字", timefontflags="OUTLINE",
					timefontcolor={ r=1, g=1, b=1, a=1, }, timeformat="remain", showlag=true, lagcolor={ r=1, g=0, b=0, a=1, },
					iconx=-48, icony=16, iconw=1, iconh=1, iconalpha=1, framelevel=8, },
			comboframe={ 
					x=45, y=30, w=150, h=20,
					combostyle=2, combo1w=10, combo1h=10, framelevel=10,
					color={ r=0.7, g=0, b=0, a=1, }, glowcolor={ r=1, g=1, b=0, a=0.8, }, 
					combocolor={ r=0.98, g=1, b=0.15, a=1, }, combo2color={ r=0.97, g=1, b=0.12, a=1, }, combo3color={ r=1, g=0.85, b=0.15, a=1, }, 
					combo4color={ r=1, g=0.53, b=0.13, a=1, }, combo5color={ r=1, g=0.15, b=0.05, a=1, }, combo6color={ r=1, g=0.12, b=0.03, a=1, }, },
			inspectbutton={ x=315, y=25, w=26, h=26, framelevel=1, },
			threatbar={ x=60, y=-11, w=45, h=16, fontsize=14, bgcolor={ r=0, g=0, b=0, a=0.4, }, framelevel=4,},
			rangetext={ x=0, y=-15, w=100, h=10, fontsize=14, justifyH="LEFT", framelevel=4, },
		},
		targettarget={
			frame={ x=405, y=-50, w=160, h=8, bordercolormethod="classreaction" },
			portrait={ hide=true, x=-40, y=12, w=30, h=30, border="None", framelevel=3, },
			hpbar={ x=0, y=1, w=160, h=10, barcolormethod="classreaction", bgcolormethod="classreactiondark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="None", fade=true, inc=true, framelevel=1, },
			mpbar={ hide=true, x=180, y=0, w=160, h=10, barcolormethod="power", bgcolormethod="powerdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="Blizzard Tooltip",  bordercolor={ r=1, g=0.8, b=0, a=1, }, fade=true, framelevel=1, },
			text1={ pattern="[classreaction:name]", 
					x=0, y=18, w=200, h=16, 
					fontsize=14, fontflags="None", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="", hide=true,
					x=0, y=18, w=20, h=16, 
					fontsize=14, fontflags="None", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[curhp]", hide=true,
					x=0, y=-5, w=160, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text4={ pattern="[curmp]", hide=true,
					x=180, y=-5, w=160, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			buffgroup={
					hide=true, x=0, y=-30, w=20, h=20,
					count=30, rows=2, cols=15,
					timey=0, countty=-5, counttfontflags="OUTLINE", growth="LRTB", spacing=2, vspacing=5, },
			debuffgroup={
					hide=true, x=0, y=-54, w=30, h=30,
					count=10, rows=1, cols=10, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRTB", spacing=2, vspacing=5, showpie=true, onlymine=true, push="None", framelevel=3, },
			statusicon={ hide=true, x=318, y=25, w=24, h=24, framelevel=1, },
			dispellicon={ hide=true, x=130, y=25, w=36, h=36, framelevel=4, },
			pvpicon={ hide=true, x=-43, y=14, w=36, h=36, framelevel=4, },
			raidtargeticon={ hide=true, x=-33, y=10, w=26, h=26, framelevel=6, },
			infoicon={ hide=true, x=-35, y=12, w=30, h=30, circular=true, framelevel=2, },
		},
		targettargettarget={
			frame={ hide=true, x=575, y=-50, w=80, h=8, bordercolormethod="classreaction", }, 
			portrait={ hide=true, x=-64, y=18, w=60, h=60, border="None", },
			hpbar={ x=0, y=1, w=80, h=10, barcolormethod="class", bgcolormethod="classdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="None", fade=true, inc=true, framelevel=1, },
			mpbar={ hide=true, x=95, y=1, w=80, h=10, barcolormethod="power", bgcolormethod="powerdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1,}, fade=true, framelevel=1, },
			text1={ pattern="[classreaction:name]", 
					x=0, y=18, w=200, h=16, 
					fontsize=14, fontflags="None", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ hide=true, pattern="[curhp]", 
					x=0, y=-5, w=85, h=20, fontsize=12, fontflags="OUTLINE", 
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ hide=true, pattern="[perchp]%", hide=true,
					x=0, y=-5, w=80, h=20, fontsize=14, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2,	},
			text4={ hide=true, pattern="[curmp]",
					x=95, y=-5, w=85, h=20, fontsize=12,
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			raidtargeticon={ hide=true, x=-35, y=16, w=26, h=26, framelevel=6, },
			buffgroup={
					hide=true, x=240, y=25, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, showpie=true, onlymine=true},
			debuffgroup={ 
					hide=true, x=240, y=-25, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, showpie=true, push="None", },
			infoicon={ hide=true, x=-38, y=18, w=30, h=30, circular=true, framelevel=2, },
		},
		focus={
			frame={ x=playerx-310, y=playery+250, w=150, h=36, bordercolormethod="classreaction", },
			portrait={ x=-2, y=1, w=152, h=38, show3d=true, },
			hpbar={ x=-2, y=1, w=154, h=38, barcolormethod="classreaction", bgcolormethod="classreactiondark", bgalpha=0, baralpha=0.3, framelevel=4, },
			mpbar={ x=70, y=-25, w=90, h=8, barcolormethod="power", bgcolormethod="powerdark", bgalpha=0.3, framelevel=6, },
			text1={ 
				pattern="[classreaction:name]", 
				x=5, y=10, w=150, h=14, 
				fontsize=16, justifyH="LEFT", justifyV="TOP", shadowx=2, shadowy=-2, fontflags="OUTLINE", framelevel=7, 
			},
			text2={ 
				pattern="[difficulty:level][difficulty:classification] [class_if_npc:creaturetype][class_if_pc:race]", 
				x=5, y=-9, w=140, h=12, 
				fontsize=10, justifyH="LEFT", justifyV="TOP", shadowx=-1, shadowy=-1, framelevel=6,
			},
			text3={ 
				pattern="[curhp] | [perchp]%", 
				x=25, y=-12, w=125, h=12, 
				fontsize=11, justifyH="RIGHT", justifyV="BOTTOM", fontflags="OUTLINE", framelevel=6, 
			},
			text4={ 
				hide=true, pattern="[curmp]", 
				x=87, y=-24, w=60, h=10, 
				fontsize=10, justifyH="RIGHT", justifyV="BOTTOM", framelevel=6, 
			},
			buffgroup={
					x=0, y=-42, w=20, h=20, 
					count=21, rows=3, cols=7,
					timey=0, countty=-5, counttfontflags="OUTLINE", growth="LRTB", spacing=1, vspacing=2, showpie=true,
			},
			debuffgroup={ 
					x=0, y=30, w=30, h=30, 
					count=10, rows=2, cols=5, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=1, vspacing=2, showpie=true, push="None",
			},
			auratimers={
				x=-60, y=-40, w=50, h=12,
				count=4, rows=4, cols=1, growth="TBLR", push="v",
			},
			statusicon={x=-12, y=-26, w=20, h=20, framelevel=6, },
			dispellicon={x=70, y=12, w=36, h=36, framelevel=10, },
			pvpicon={x=-13, y=-5, w=20, h=20, framelevel=6, },
			raidtargeticon={x=144, y=11, w=16, h=16, framelevel=6, },
			infoicon={hide=true, x=115, y=15, w=28, h=28, circular=true, framelevel=6, },
			threatbar={x=114, y=22, w=38, h=14, bgcolor={ r=0, g=0, b=0, a=0.4, }, fontsize=12, framelevel=10, },
			comboframe={x=70, y=10, w=40, h=20, color={ r=0.7, g=0, b=0, a=1, }, glowcolor={ r=1, g=1, b=0, a=0.8, }, framelevel=11, },
			castbar={ 
				hide=true, x=-2, y=1, w=154, h=38, alpha=1,
				baralpha=0, bgcolor={ r=1, g=1, b=0, a=0.2, },
				spellx=0, spelly=-26, spellw=150, spellh=14, 
				spellfontsize=14, spellfontflags="THICKOUTLINE", spelljustifyH="CENTER", spelljustifyV="CENTER", spellshadowx=-1, spellshadowy=-1,
				spellfontcolor={ r=1, g=0.95, b=0.32, a=0.7, },
				timex=0, timey=0, timew=80, timeh=26, 
				timefontsize=8, timefontflags="OUTLINE", timejustifyH="CENTER", timejustifyV="CENTER",
				timefontcolor={ r=1, g=0.5, b=0.2, a=0, },
				iconx=-16, icony=0, iconw=14, iconh=14, framelevel=7,
			},
			rangetext={ x=40, y=20, w=100, h=10, fontsize=12, justifyH="CENTER", framelevel=12, },
		},
		focustarget={
			frame={ x=playerx-140, y=playery+240, w=40, h=6, bordercolormethod="classreaction", },
			portrait={ x=-35, y=12, w=30, h=30, hide=true, },
			hpbar={ x=0, y=1, w=40, h=10, barcolormethod="classreaction", bgcolormethod="classreactiondark",
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="None", fade=true, framelevel=1, },
			mpbar={ hide=true, x=55, y=-1, w=40, h=6, barcolormethod="power", bgcolormethod="powerdark", bordercolor={ r=1, g=0.8, b=0, a=1, },
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="Blizzard Tooltip", fade=true, framelevel=1, },
			text1={ pattern="[classreaction:name]", 
					x=-3, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="", hide=true,
					x=0, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[perchp]%", hide=true,
					x=0, y=-5, w=60, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text4={ pattern="[curmp]", hide=true,
					x=55, y=-5, w=40, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			buffgroup={ 
					hide=true, x=105, y=8, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, },
			debuffgroup={ 
					hide=true, x=105, y=-10, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, push="None", },
			infoicon={ hide=true, x=-35, y=12, w=30, h=30, circular=true, framelevel=2, },
			raidtargeticon={ hide=true, x=-33, y=10, w=26, h=26, framelevel=6, },
		},
		pet={
			frame={ x=playerx-270, y=playery+70, w=80, h=6, bordercolormethod="class", }, 
			portrait={ x=-40, y=18, w=30, h=30, border="None", },
			hpbar={ x=0, y=1, w=80, h=10, barcolormethod="class", bgcolormethod="classdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="None", fade=true, inc=true, framelevel=1, },
			mpbar={ x=95, y=0, w=80, h=8, barcolormethod="power", bgcolormethod="powerdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, }, fade=true, framelevel=1, },
			text1={ pattern="[class:name]", 
					x=0, y=18, w=200, h=16, 
					fontsize=14, fontflags="None", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="[curhp]", 
					x=0, y=-5, w=85, h=20, fontsize=12, fontflags="OUTLINE", 
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[perchp]%", hide=true,
					x=0, y=-5, w=80, h=20, fontsize=14, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2,	},
			text4={ pattern="[curmp]",
					x=95, y=-5, w=85, h=20, fontsize=12,
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text5={ pattern="[percmp]%", hide=true,
					x=95, y=-5, w=80, h=20, fontsize=14, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2,	},
			text6={ hide=true, pattern="", 
					x=0, y=25, w=180, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="RIGHT", justifyV="CENTER", shadowx=1, shadowy=-1, framelevel=2, },
			combattext={ hide=true, x=0, y=-6, w=200, h=18, fontsize=16, justifyH="LEFT", justifyV="CENTER", shadowx=-1, shadowy=-1, framelevel=4, },
			buffgroup={
					x=0, y=-20, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, showpie=true},
			debuffgroup={ 
					x=0, y=25, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, showpie=true, push="None", },
			dispellicon={ x=140, y=30, w=36, h=36, framelevel=4, },
			statusicon={ hide=true, x=154, y=25, w=24, h=24, framelevel=1, },
			raidtargeticon={ x=-35, y=16, w=26, h=26, framelevel=6, },
			infoicon={ hide=true, x=-38, y=18, w=30, h=30, circular=true, framelevel=2, },
			castbar={ 
					x=0, y=15, w=175, h=6, alpha=1,
					baralpha=1, bgcolor={ r=0, g=0, b=0, a=0.3, }, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, },
					spellx=0, spelly=20, spellw=140, spellh=16, 
					spellfontsize=14, spellfontflags="OUTLINE", spelljustifyH="RIGHT", spelljustifyV="BOTTOM", spellshadowx=1, spellshadowy=-1,
					spellfontcolor={ r=1, g=1, b=1, a=1, },
					timex=0, timey=-10, timew=120, timeh=20, 
					timefontsize=16, timefontflags="OUTLINE", timejustifyH="RIGHT", timejustifyV="TOP", timefont="傷害數字",
					timefontcolor={ r=1, g=1, b=1, a=1, }, timeformat="none", showlag=true, lagcolor={ r=1, g=0, b=0, a=1, },
					iconx=-48, icony=16, iconw=1, iconh=1, iconalpha=1, framelevel=8, },
			pettime={ x=-5, y=-10, w=36, h=10, fontsize=16, shadowx=-1, shadowy=-1, framelevel=1, },
		},
		party1={ 
			frame={ x=55, y=-350, w=80, h=10, bordercolormethod="class", }, 
			portrait={ hide=true, x=-40, y=18, w=30, h=30, border="None", },
			hpbar={ x=0, y=0, w=80, h=10, barcolormethod="class", bgcolormethod="classdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="None", fade=true, inc=true, framelevel=1, },
			mpbar={ x=95, y=1, w=80, h=11, barcolormethod="power", bgcolormethod="powerdark", baralpha=1, bgalpha=0.3, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, }, fade=true, framelevel=1, },
			text1={ pattern="[class:name] [class:level][class:級]", 
					x=0, y=20, w=200, h=16, 
					fontsize=16, fontflags="OUTLINE", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="[curhp]", 
					x=0, y=-5, w=85, h=20, fontsize=12, fontflags="OUTLINE", 
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[perchp]%", hide=true,
					x=0, y=-5, w=80, h=20, fontsize=14, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2,	},
			text4={ pattern="[curmp]",
					x=95, y=-5, w=85, h=20, fontsize=12,
					justifyH="RIGHT", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text5={ pattern="[percmp]%", hide=true,
					x=95, y=-5, w=80, h=20, fontsize=14, fontflags="OUTLINE", font="傷害數字",
					justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2,	},
			text6={ pattern="[gray_if_oor:距離過遠][gray_if_tapped:無效目標][gray_if_offline:離線][gray_if_dead:死亡][gray_if_ghost:靈魂]", 
					x=0, y=25, w=180, h=20, 
					fontsize=20, fontflags="OUTLINE", font="傷害數字",
					justifyH="RIGHT", justifyV="CENTER", shadowx=1, shadowy=-1, framelevel=2, },
			combattext={ hide=true, x=0, y=-6, w=200, h=18, fontsize=16, justifyH="LEFT", justifyV="CENTER", shadowx=-1, shadowy=-1, framelevel=4, },
			buffgroup={
					x=240, y=25, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, showpie=true, onlymine=true},
			debuffgroup={ 
					x=240, y=-25, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, showpie=true, push="None", },
			dispellicon={ x=140, y=30, w=36, h=36, framelevel=4, },
			voiceicon={ x=-20, y=35, w=20, h=20, framelevel=4,},
			pvpicon={ x=-48, y=5, w=24, h=24, framelevel=3, },
			statusicon={ x=154, y=25, w=24, h=24, framelevel=1, },
			leadericon={ x=0, y=35, w=20, h=20, framelevel=1, },
			looticon={ x=20, y=35, w=20, h=20, framelevel=1, },
			raidtargeticon={ x=-35, y=16, w=26, h=26, framelevel=6, },
			infoicon={ x=-38, y=18, w=30, h=30, circular=true, framelevel=2, },
			castbar={ 
					x=0, y=15, w=175, h=6, alpha=1,
					baralpha=1, bgcolor={ r=0, g=0, b=0, a=0.3, }, 
					bartexture="Blizzard", border="Blizzard Tooltip", bordercolor={ r=1, g=0.8, b=0, a=1, },
					spellx=0, spelly=20, spellw=140, spellh=16, 
					spellfontsize=14, spellfontflags="OUTLINE", spelljustifyH="RIGHT", spelljustifyV="BOTTOM", spellshadowx=1, spellshadowy=-1,
					spellfontcolor={ r=1, g=1, b=1, a=1, },
					timex=0, timey=-10, timew=120, timeh=20, 
					timefontsize=16, timefontflags="OUTLINE", timejustifyH="RIGHT", timejustifyV="TOP", timefont="傷害數字",
					timefontcolor={ r=1, g=1, b=1, a=1, }, timeformat="none", showlag=true, lagcolor={ r=1, g=0, b=0, a=1, },
					iconx=-48, icony=16, iconw=1, iconh=1, iconalpha=1, framelevel=8, },
			vehicleicon={ x=-38, y=18, w=32, h=32, framelevel=3, },
			lfgicon={ x=-22, y=22, w=20, h=20, circular=true, framelevel=4, },
		},
		party2={ frame={ x=55, y=-410, }, },
		party3={ frame={ x=55, y=-470, }, },
		party4={ frame={ x=55, y=-530, }, },
		pettarget={ 
			frame={ x=playerx-120, y=playery+70, w=40, h=8, bordercolormethod="classreaction", },
			portrait={ x=-35, y=12, w=30, h=30, hide=true, },
			hpbar={ x=0, y=1, w=40, h=10, barcolormethod="classreaction", bgcolormethod="classreactiondark",
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="None", fade=true, framelevel=1, },
			mpbar={ hide=true, x=55, y=-1, w=40, h=8, barcolormethod="power", bgcolormethod="powerdark", bordercolor={ r=1, g=0.8, b=0, a=1, },
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="Blizzard Tooltip", fade=true, framelevel=1, },
			text1={ pattern="[classreaction:name]", 
					x=-3, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="", hide=true,
					x=0, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[perchp]%", hide=true,
					x=0, y=-5, w=60, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text4={ pattern="[curmp]", hide=true,
					x=55, y=-5, w=40, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			buffgroup={ 
					hide=true, x=105, y=8, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, },
			debuffgroup={ 
					hide=true, x=105, y=-10, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, push="None", },
			infoicon={ hide=true, x=-35, y=12, w=30, h=30, circular=true, framelevel=2, },
			raidtargeticon={ hide=true, x=-33, y=10, w=26, h=26, framelevel=6, },
		},
		party1target={ frame={ x=245, y=-350, }, },
		party2target={ frame={ x=245, y=-410, }, },
		party3target={ frame={ x=245, y=-470, }, },
		party4target={ frame={ x=245, y=-530, }, },
		partypet1={ 
			frame={ x=245, y=-380, w=40, h=6, bordercolormethod="classreaction", },
			portrait={ x=-35, y=12, w=30, h=30, hide=true, },
			hpbar={ x=0, y=1, w=40, h=10, barcolormethod="classreaction", bgcolormethod="classreactiondark",
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="None", fade=true, framelevel=1, },
			mpbar={ hide=true, x=55, y=-1, w=40, h=6, barcolormethod="power", bgcolormethod="powerdark", bordercolor={ r=1, g=0.8, b=0, a=1, },
					baralpha=1, bgalpha=0.3, bartexture="Blizzard", border="Blizzard Tooltip", fade=true, framelevel=1, },
			text1={ pattern="[classreaction:name]", 
					x=-3, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="LEFT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text2={ pattern="", hide=true,
					x=0, y=18, w=200, h=16, 
					fontsize=12, fontflags="OUTLINE", justifyH="RIGHT", justifyV="BOTTOM", shadowx=1, shadowy=-1, framelevel=2, },
			text3={ pattern="[perchp]%", hide=true,
					x=0, y=-5, w=60, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			text4={ pattern="[curmp]", hide=true,
					x=55, y=-5, w=40, h=20, 
					fontsize=14, fontflags="OUTLINE", font="傷害數字", justifyH="CENTER", justifyV="TOP", shadowx=1, shadowy=-1, framelevel=2, },
			buffgroup={ 
					hide=true, x=105, y=8, w=20, h=20, 
					count=10, rows=1, cols=10,
					timey=0, countty=-5, counttfontflags="OUTLINE", spacing=2, },
			debuffgroup={ 
					hide=true, x=105, y=-10, w=30, h=30, 
					count=7, rows=1, cols=7, 
					timey=0, countty=-10, counttfontflags="OUTLINE", growth="LRBT", spacing=2, push="None", },
			infoicon={ hide=true, x=-35, y=12, w=30, h=30, circular=true, framelevel=2, },
			raidtargeticon={ hide=true, x=-33, y=10, w=26, h=26, framelevel=6, },
		},
		partypet2={ frame={ x=245, y=-440, }, },
		partypet3={ frame={ x=245, y=-500, }, },
		partypet4={ frame={ x=245, y=-560, }, },
		arena1={
			frame={ hide=true, x=arenax, y=arenay, w=78, h=24, },
			portrait={ x=0, y=0, w=24, h=24, show3d=nil, },
			hpbar={ x=24, y=-1, w=53, h=17, barcolormethod="hpgreen", bgcolormethod="hpgreendark", bgalpha=0.3, },
			mpbar={ x=24, y=-19, w=53, h=5, barcolormethod="power", bgcolormethod="powerdark", bgalpha=0.3, },
			text1={ 
				pattern="[class:name]", 
				x=25, y=0, w=54, h=12, 
				fontsize=12, justifyH="LEFT", justifyV="TOP", shadowx=-1, shadowy=-1,
			},
			text2={ hide=true, pattern="", x=0, y=0, w=54, h=10, },
			text3={ 
				pattern="[perchp]%", 
				x=25, y=-13, w=54, h=10, 
				fontsize=10, justifyH="CENTER", justifyV="CENTER", 
			},
			text4={ hide=true, pattern="", x=0, y=0, w=54, h=10, },
			buffgroup={ 
				x=0, y=-24, w=10, h=10, 
				count=8, rows=1, cols=8, growth="LRTB",
			},
			debuffgroup={ 
				x=0, y=-23, w=10, h=10, 
				count=8, rows=1, cols=8, growth="LRTB", push="v",
			},
			infoicon={ hide=true, x=0, y=0, w=12, h=12, },
			castbar={ 
				x=-1, y=1, w=80, h=26, alpha=1,
				baralpha=0, bgcolor={ r=1, g=1, b=0, a=0.2, },
				spellx=0, spelly=-12, spellw=80, spellh=12, 
				spellfontsize=10, spelljustifyH="CENTER", spelljustifyV="CENTER", spellshadowx=-1, spellshadowy=-1,
				spellfontcolor={ r=1, g=0.5, b=0.2, a=0.7, },
				timex=0, timey=0, timew=80, timeh=26, 
				timefontsize=8, timejustifyH="CENTER", timejustifyV="CENTER",
				timefontcolor={ r=1, g=0.5, b=0.2, a=0, },
				iconx=-16, icony=0, iconw=14, iconh=14, iconalpha=0,
			},
		},
		arena2={ frame={ hide=true, x=arenax, y=arenay - 47, w=78, h=24, }, },
		arena3={ frame={ hide=true, x=arenax, y=arenay - 94, w=78, h=24, }, },
		arena4={ frame={ hide=true, x=arenax, y=arenay - 141, w=78, h=24, }, },
		arena5={ frame={ hide=true, x=arenax, y=arenay - 188, w=78, h=24, }, },
		arena1target={
			frame={ hide=true, x=arenax + 79, y=arenay, w=78, h=24, },
			portrait={ x=55, y=0, w=24, h=24, show3d=nil, },
			hpbar={ x=1, y=-1, w=53, h=17, barcolormethod="hpgreen", bgcolormethod="hpgreendark", reverse=true, bgalpha=0.3, },
			mpbar={ x=1, y=-19, w=53, h=5, barcolormethod="power", bgcolormethod="powerdark", reverse=true, bgalpha=0.3, },
			text1={ 
				pattern="[reaction:*][class:name]", 
				x=1, y=0, w=54, h=12, 
				fontsize=12, justifyH="RIGHT", justifyV="TOP", shadowx=-1, shadowy=-1,
			},
			text2={ hide=true, pattern="", x=1, y=-11, w=108, h=10, },
			text3={ 
				pattern="[perchp]%", 
				x=1, y=-13, w=54, h=10, 
				fontsize=10, justifyH="CENTER", justifyV="CENTER", 
			},
			text4={ hide=true, pattern="", x=1, y=-24, w=54, h=10, },
			buffgroup={ 
				hide=true, x=0, y=-24, w=10, h=10, 
				count=8, rows=1, cols=8, growth="LRTB",
			},
			debuffgroup={ 
				hide=true, x=0, y=-23, w=10, h=10, 
				count=8, rows=1, cols=8, growth="LRTB", push="v",
			},
			infoicon={ hide=true, x=0, y=0, w=12, h=12, },
		},
		arena2target={ frame={ hide=true, x=arenax + 79, y=arenay - 47, w=78, h=24, }, },
		arena3target={ frame={ hide=true, x=arenax + 79, y=arenay - 94, w=78, h=24, }, },
		arena4target={ frame={ hide=true, x=arenax + 79, y=arenay - 141, w=78, h=24, }, },
		arena5target={ frame={ hide=true, x=arenax + 79, y=arenay - 188, w=78, h=24, }, },
		arenapet1={
			frame={ hide=true, x=arenax - 37, y=arenay - 12, w=36, h=12, },
			portrait={ x=24, y=0, w=12, h=12, },
			hpbar={ 
				x=0, y=0, w=24, h=12, 
				barcolormethod="hpgreen", bgcolormethod="hpgreendark", reverse=true, bgalpha=0.3, 
			},
			mpbar={ 
				hide=true, x=0, y=-9, w=24, h=3, 
				barcolormethod="power", bgcolormethod="powerdark", bgalpha=0.3, 
			},
			text1={ hide=true, pattern="", x=0, y=0, w=24, h=12, },
			text2={ 
				pattern="[perchp]", 
				x=0, y=0, w=24, h=12, 
				fontsize=9, justifyH="CENTER", justifyV="CENTER",
			},
			text3={ hide=true, pattern="", x=0, y=0, w=10, h=10, fontsize=10, },
			text4={ hide=true, pattern="", x=0, y=0, w=10, h=10, fontsize=10, },
			buffgroup={ hide=true, x=0, y=-12, w=6, h=6, count=6, rows=1, cols=6, },
			debuffgroup={ hide=true, x=0, y=-12, w=6, h=6, count=6, rows=1, cols=6, push="v", },
			infoicon={ hide=true, x=0, y=0, w=12, h=12, },
		},
		arenapet2={ frame={ hide=true, x=arenax - 37, y=arenay - 59, w=78, h=24, }, },
		arenapet3={ frame={ hide=true, x=arenax - 37, y=arenay - 106, w=78, h=24, }, },
		arenapet4={ frame={ hide=true, x=arenax - 37, y=arenay - 153, w=78, h=24, }, },
		arenapet5={ frame={ hide=true, x=arenax - 37, y=arenay - 200, w=78, h=24, }, },
	}
	local dgc = defaults.global
	for class, color in pairs(CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS) do
		dgc.classcolor[class]={ r=color.r, g=color.g, b=color.b, }
	end
	for index, color in pairs(FACTION_BAR_COLORS) do
		-- 使用自訂顏色
		if not dgc.reactioncolor[index] then
			dgc.reactioncolor[index]={ r=color.r, g=color.g, b=color.b, }
		end
	end
	for i = 0, 10, 1 do
		local color = PowerBarColor[i]
		-- 使用自訂顏色
		if dgc.powercolor[i] or not color then break end
		dgc.powercolor[i]={ r=color.r, g=color.g, b=color.b, }
	end
	for dtype, color in pairs(DebuffTypeColor) do
		dgc.auracolor[dtype]={ r=color.r, g=color.g, b=color.b, }
	end
	
	if restore then
		if perchar then
			StufCharDB = defaults
			StufCharDB.global.init = 9
		else
			StufDB = defaults
			StufDB.global.init = 9
		end
		ReloadUI()
	else
		local function SetDefaults(db, t)
			for k, v in pairs(t) do
				if type(db[k]) == "table" then
					SetDefaults(db[k], v)
				else
					if db[k] == nil and type(v) ~= "boolean" and k ~= "push" then
						db[k] = v
					end
					if db[k] == false then
						db[k] = nil
					end
				end
			end
		end
		SetDefaults(db, defaults)
	end
end


local function shorten(num)
	if type(num) == "number" then
		return floor(num * 1000 + 0.5) / 1000
	end
	if num == false then
		return nil
	end
	return num
end


-- selection tables
local colormethods={
	power=L["Power Type"], powerdark=L["Dark Power Type"],
	hpgreen=L["Health Green"], hpgreendark=L["Dark Health Green"],
	hpred=L["Health Red"], hpreddark=L["Dark Health Red"],
	hpthreshold=L["Health Threshold"], hpthresholddark=L["Dark Health Threshold"],
	class=L["Class"], classdark=L["Dark Class"], 
	reaction=L["Reaction"], reactiondark=L["Dark Reaction"], 
	classreaction=L["Reaction NPC/PVP, else Class"], classreactiondark=L["Dark Reaction NPC/PVP, else Class"],
	reactionnpc=L["Reaction NPC, Class PC"], reactionnpcdark=L["Dark Reaction NPC, Class PC"],
	difficulty=L["Difficulty"], difficultydark=L["Dark Difficulty"],
	solid=L["Custom"],
}
local strata={ L["BACKGROUND"], L["LOW"], L["MEDIUM"], L["HIGH"], L["DIALOG"], }
local stratakey={ "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", }

-- get/set functions
local subobjects={ time=true, countt=true, spell=true, icon=true, combo1=true, combo2=true, combo3=true, combo4=true, combo5=true, combo6=true, }
local function infobreakdown(info)
	db = db or (StufDB ~= "perchar" and StufDB) or StufCharDB
	local num = #info
	local unit, object, setting = info[num-2], info[num-1], info[num]
	if subobjects[object] then
		setting = object..setting
		object = unit
		unit = info[num-3]
	end
	return unit, object, setting
end
local function getget(info)
	local unit, object, setting = infobreakdown(info)
	if highlight then
		local f = su[unit] and su[unit][object]
		if f then
			highlight:SetFrameLevel(4)
			highlight:SetPoint("TOPLEFT", f, "TOPLEFT")
			highlight:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
			highlight:SetAlpha(1)
		else
			highlight:SetAlpha(0)
		end
	end
	if object == "global" then
		return db.global[setting]
	else
		return db[unit] and db[unit][object] and db[unit][object][setting]
	end
end
local function get(info)
	local dbk = getget(info)
	if type(dbk) == "table" then
		return dbk.r, dbk.g, dbk.b, dbk.a
	else
		return dbk
	end
end
local function getornone(info)
	local dbk = getget(info)
	return not dbk and "None" or dbk
end
local function getorzero(info)
	local dbk = getget(info)
	return not dbk and 0 or dbk
end
local function getorone(info)
	local dbk = getget(info)
	return not dbk and 1 or dbk
end
local function getorfont(info)
	local dbk = getget(info)
	return not dbk and db.global.font or dbk
end
local function getorbar(info)
	local dbk = getget(info)
	return not dbk and db.global.bartexture or dbk
end
local function getorbg(info)
	local dbk = getget(info)
	return not dbk and "Blizzard" or dbk
end
local function getcolororblank(info)  -- get color or default blank
	local dbk = getget(info)
	if not dbk then
		return 0, 0, 0, 0
	else
		return dbk.r, dbk.g, dbk.b, dbk.a
	end
end
local function getcolororwhite(info)  -- get color or default white
	local dbk = getget(info)
	if not dbk then
		return 1, 1, 1, 1
	else
		return dbk.r, dbk.g, dbk.b, dbk.a
	end
end
local function getstrata(info)
	local dbk = getget(info)
	for i, k in ipairs(stratakey) do
		if k == dbk then return i end
	end
end

local function set(info, r, g, b, a)
	local unit, object, setting = infobreakdown(info)
	if object == "global" then
		if b then
			r, g, b, a = shorten(r), shorten(g), shorten(b), shorten(a)
			local dbk = db.global[setting]
			if dbk then
				dbk.r, dbk.g, dbk.b, dbk.a = r, g, b, a
			else
				db.global[setting]={ r=r, g=g, b=b, a=a, }
			end
		elseif setting == "strata" then
			db.global[setting] = stratakey[r] or nil
		else
			db.global[setting] = shorten(r)
		end
		Stuf:UpdateElementLook("global", setting)
	else
		if b then
			r, g, b, a = shorten(r), shorten(g), shorten(b), shorten(a)
			local dbk = db[unit][object][setting]
			if dbk then
				dbk.r, dbk.g, dbk.b, dbk.a = r, g, b, a
			else
				db[unit][object][setting]={ r=r, g=g, b=b, a=a, }
			end
		elseif setting == "strata" then
			db[unit][object][setting] = stratakey[r] or nil
		else
			db[unit][object][setting] = shorten(r)
		end
		Stuf:UpdateElementLook(unit, object)
	end
end

local hide={ name=L["Disable"], type="toggle", set=set, get=get, order=1, }
local copy={ 
	name=function(info)
		local unit, object, setting = infobreakdown(info)
		local copyunit = Stuf.unitcopy[unit]
		if copyunit and copyunit ~= unit then
			return format(L["This unit copies the settings for %s."], L[copyunit])
		end
		return ""
	end, type="description", order=2, 
}
local copyvalues={ 
	player=_G.PLAYER, target=_G.TARGET,
	targettarget=_G.TARGET.." ".._G.TARGET, focus=L["Focus"],
	pet=_G.PET, pettarget=_G.PET.." ".._G.TARGET, 
	targettargettarget=_G.TARGET.." ".._G.TARGET.." ".._G.TARGET, focustarget=L["Focus"].." ".._G.TARGET,
	party1=_G.PARTY.." 1", partypet1=_G.PARTY.." 1 ".._G.PET,
	arena1=_G.ARENA.." 1", arena1target=_G.ARENA.." 1 ".._G.TARGET,
}
local copyelement={
	name=L["Copy Unit's"], desc=L["Copy this element's settings from another unit's"], type="select", order=2,
	values=copyvalues,
	set=function(info, v)
		local unit, object, setting = infobreakdown(info)
		if unit == v or not db[v] then return end
		if not db[v][object or "blah"] then
			return print("|cff00ff00Stuf|r: "..L["This unit does not have the element from which to copy."])
		end
		local et = db[unit][object]
		wipe(et)
		for k, value in pairs(db[v][object]) do
			if type(value) == "table" then
				et[k]={ }
				for sk, svalue in pairs(value) do
					et[k][sk] = svalue
				end
			else
				et[k] = value
			end
		end
		Stuf:UpdateElementLook(unit, object)
	end,
}

local x, y, x2, y2, w, h
local function getorzeroupdateminmax(info)
	local unit, object, setting = infobreakdown(info)
	local copy = Stuf.unitcopy[unit]
	local s = ((copy and db[copy]) or db[unit]).frame.scale or 1
	local sw, sh = GetScreenWidth(), GetScreenHeight()
	x.max, y.min = floor(sw / s), -floor(sh / s)
	x2.min, x2.max = -floor(sw / s), floor(sw / s)
	y2.min, y2.max = -floor(sh / s), floor(sh / s)
	w.max, h.max = floor(sw / s), floor(sh / s)
	return getorzero(info)
end
local blank={ name=" ", type="header", order=3, }
x={ name=L["X Position"], type="range", min=0, max=1, step=1, set=set, get=getorzeroupdateminmax, order=4, }
y={ name=L["Y Position"], type="range", min=-1, max=0, step=1, set=set, get=getorzeroupdateminmax, order=5, }
x2={ name=L["X Position"], type="range", min=-1, max=1, step=1, set=set, get=getorzeroupdateminmax, order=4, }
y2={ name=L["Y Position"], type="range", min=-1, max=1, step=1, set=set, get=getorzeroupdateminmax, order=5, }
w={ name=L["Width"], type="range", min=0, max=1, step=1, set=set, get=getorzeroupdateminmax, order=6, }
h={ name=L["Height"], type="range", min=0, max=1, step=1, set=set, get=getorzeroupdateminmax, order=7, }


local scale={ name=L["Scale"], type="range", min=0.02, max=5, step=0.02, set=set, get=getorone, order=8, }
local alpha={ name=_G.OPACITY, type="range", min=0, max=1, step=0.02, set=set, get=getorone, order=9, }
local framelevel={ name=L["Frame Level"], type="range", min=0, max=32, step=1, set=set, get=getorone, order=9, }
local blank2={ name=" ", type="header", order=10, }

local border={ name=L["Border"], type="select", dialogControl="LSM30_Border", values=AceGUIWidgetLSMlists.border, set=set, get=getornone, order=12, }
local bordercolor={ name=L["Border Custom Color"], type="color", hasAlpha=true, set=set, get=getcolororblank, order=13, }
local bordercolormethod={ name=L["Border Color Method"], type="select", values=colormethods, set=set, get=get, order=14, }
local bg={ name=L["Backdrop Texture"], type="select", dialogControl="LSM30_Statusbar", values=AceGUIWidgetLSMlists.statusbar, set=set, get=getorbg, order=15, }
local bgcolor={ name=L["Backdrop Custom Color"], type="color", hasAlpha=true, set=set, get=getcolororblank, order=16, }
local bgalpha={ name=L["Backdrop Opacity"], type="range", isPercent=true, min=0, max=1, step=0.02, set=set, get=getorone, order=17, }
local bgcolormethod={ name=L["Backdrop Color Method"], width="double", type="select", values=colormethods, set=set, get=get, order=18, }
local blank3={ name=" ", type="header", order=19, }

local bartexture={ name=L["Statusbar Texture"], type="select", dialogControl="LSM30_Statusbar", values=AceGUIWidgetLSMlists.statusbar, set=set, get=getorbar, order=19.9, }
local barcolor={ name=L["Bar Custom Color"], type="color", set=set, get=getcolororblank, order=20, }
local baralpha={ name=L["Bar Opacity"], isPercent=true, type="range", min=0, max=1, step=0.02, set=set, get=getorone, order=21, }
local barcolormethod={ name=L["Bar Color Method"], width="double", type="select", values=colormethods, set=set, get=get, order=22, }
local fade={ name=L["Fade Bar Loss"], type="toggle", set=set, get=get, order=23, }
local smoothfade={ name=L["Smooth Fade"], type="toggle", set=set, get=get, order=23.1,
	desc=L["High CPU. May not work properly with merged Visual Heal Bar."],
	hidden=function(info)
		local unit, object, setting = infobreakdown(info)
		return not db[unit][object].fade
	end,
}
local vertical={ name=L["Vertical Orientation"], type="toggle", set=set, get=get, order=25, }
local hflip={ name=L["Horizontal Flip Texture"], type="toggle", set=set, get=get, order=26, }
local vflip={ name=L["Vertical Flip Texture"], type="toggle", set=set, get=get, order=27, }
local reverse={ name=L["Reverse Direction"], type="toggle", set=set, get=get, order=28, }
local deplete={ name=L["Fill on Loss"], desc=L["Does not work well with Show Incoming Heals and Fade Bar Loss"], type="toggle", set=set, get=get, order=28.1, }
local blank4={ name=" ", type="header", order=29, }
local barinsetleft={ name=L["Bar Left Offset"], type="range", min=-20, max=20, step=1, set=set, get=get, order=30, }
local barinsetright={ name=L["Bar Right Offset"], type="range", min=-20, max=20, step=1, set=set, get=get, order=31, }
local barinsettop={ name=L["Bar Top Offset"], type="range", min=-20, max=20, step=1, set=set, get=get, order=32, }
local barinsetbottom={ name=L["Bar Bottom Offset"], type="range", min=-20, max=20, step=1, set=set, get=get, order=33, }
local blank5={ name=" ", type="header", order=39, }
local sparkcolor={ name=L["Spark Color"], type="color", hasAlpha=true, set=set, get=getcolororwhite, order=99, }

local font={ name=L["Font"], type="select", dialogControl="LSM30_Font", values=AceGUIWidgetLSMlists.font, set=set, get=getorfont, order=40, }
local fontsize={ name=L["Font Size"], type="range", min=1, max=80, step=1, set=set, get=getorone, order=41, }
local fontflags={ name=L["Font Extras"], type="select", values=fontflags, set=set, get=getornone, order=42, 
	values={ None=L["None"], OUTLINE=L["OUTLINE"], THICKOUTLINE=L["THICKOUTLINE"], 
		MONOCHROME=L["MONOCHROME"], ["OUTLINE|MONOCHROME"]=L["OUTLINE|MONOCHROME"], 
		["THICKOUTLINE|MONOCHROME"]=L["THICKOUTLINE|MONOCHROME"], 
	},
}
local fontcolor={ name=L["Font Color"], type="color", hasAlpha=true, set=set, get=getcolororwhite, order=43, }
local justifyH={ name=L["H Justify"], type="select", values={ LEFT=L["Left"], CENTER=L["Center"], RIGHT=L["Right"], }, set=set, get=get, order=44, }
local justifyV={ name=L["V Justify"], type="select", values={ TOP=L["Top"], CENTER=L["Center"], BOTTOM=L["Bottom"], }, set=set, get=get, order=45, }
local shadowx={ name=L["Shadow Offset X"], type="range", min=-20, max=20, step=1, set=set, get=getorzero, order=46, }
local shadowy={ name=L["Shadow Offset Y"], type="range", min=-20, max=20, step=1, set=set, get=getorzero, order=47, }
local alphazero={ name=L["Color alpha set to zero; object may not be visible."], type="description", width="double", order=43.1,
	hidden=function(info)
		local unit, object, setting = infobreakdown(info)
		local fontcolor = (gsub(setting, "alphazero", "") or "").."fontcolor"
		return not db[unit][object][fontcolor] or not db[unit][object][fontcolor].a or db[unit][object][fontcolor].a > 0.01
	end,
}

local textoptions={ hide=hide, copyelement=copyelement, blank=blank, 
	x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
	bg=bg, bgcolor=bgcolor, border=border, bordercolor=bordercolor, blank3=blank3,
	font=font, fontsize=fontsize, fontflags=fontflags, fontcolor=fontcolor, alphazero=alphazero,
	justifyH=justifyH, justifyV=justifyV,
	shadowx=shadowx, shadowy=shadowy,
}
local textoptions2={ x=x2, y=y2, w=w, h=h, blank2=blank2,
	font=font, fontsize=fontsize, fontflags=fontflags, fontcolor=fontcolor, alphazero=alphazero,
	justifyH=justifyH, justifyV=justifyV,
	shadowx=shadowx, shadowy=shadowy,
	onlymine={ name=L["Only on Mine"], type="toggle", set=set, get=get, order=50,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return (object ~= "buffgroup" and object ~= "debuffgroup") or setting ~= "timeonlymine"
		end,
	},
}

local frame={ name=L["Base Frame"], type="group", dialogInline=true, order=1, 
	args={ 
		basedesc={ name=L["The base frame is what receives important mouse actions."], type="description", order=0.1, },
		metrodesc={
			name=L["This is a high CPU-usage unit. If performance is an issue, disable this entirely or reduce the amount of info it displays."],
			type="description", order=0.1,
			hidden=function(info)
				local unit, object, setting = infobreakdown(info)
				return Stuf.mainunits1[unit] or Stuf.mainunits2[unit]
			end,
		},
		hide=hide,
		copyframe={
			name=L["Copy Unit"], desc=L["Copy a unit's current applicable settings"], type="select", confirm=true, order=2,
			values=copyvalues,
			set=function(info, v)
				local unit, object, setting = infobreakdown(info)
				if unit == v or not db[v] then return end
				for e, et in pairs(db[unit]) do  -- only iterate thru this frame's applicable elements
					local ce = db[v][e]
					if ce then
						local hide, x, y
						if e == "frame" then
							hide, x, y = et.hide, et.x, et.y
						end
						for k, value in pairs(et) do  -- clear out this element's settings
							et[k] = nil
						end
						for k, value in pairs(ce) do  -- now copy target's element's settings
							if type(value) == "table" then
								et[k]={ }
								for sk, svalue in pairs(value) do
									et[k][sk] = svalue
								end
							else
								et[k] = value
							end
						end
						if e == "frame" then
							et.hide, et.x, et.y = hide, x, y
						end
					end
				end
				Stuf:UpdateElementLook(unit, "frame")
			end,
		},
		disablearena={
			name=L["Hide All Arena"], desc=L["May need to reload to take full effect."], type="execute", order=2.1,
			func=function()
				for unit, ut in pairs(db) do
					if strmatch(unit, "arena") then
						ut.frame.hide = true
					end
				end
				Stuf:UpdateElementLook("global")
			end,
			hidden=function(info) return infobreakdown(info) ~= "arena1" end,
		},
		blank=blank,
		x=x, y=y, w=w, h=h, scale=scale, blank2=blank2,
		bordercolormethod=bordercolormethod, bordercolor=bordercolor,
		vertical=vertical, hflip=hflip, vflip=vflip,
		fasthp={ name=L["Fast Health Updates"], desc=L["Maybe updates health info faster but guarantees increased CPU usage."], type="toggle", width="double", set=set, get=get, order=2.2, },
	},
}
local frame2={  -- frame options for copy setting units
	name=L["Base"], type="group", dialogInline=true, order=1, 
	args={ 
		hide=hide, copy=copy, blank=blank,
		x=x, y=y,
	},
}
local portrait={ name=L["Portrait"], type="group", order=2,
	args={ 
		hide=hide, copyelement=copyelement, blank=blank, 
		x=x2, y=y2, w=w, h=h, alpha=alpha, framelevel=framelevel, blank2=blank2,
		bg=bg, bgcolor=bgcolor, border=border, bordercolor=bordercolor,
		zoom2d={ name=L["2D Zoom/Square"], type="toggle", set=set, get=get, order=20.1, },
		show3d={ name=L["3D Portrait"], type="toggle", set=set, get=get, order=20.2,
			desc=function(info)
				local unit = infobreakdown(info)
				if (su[unit] and su[unit].ismetro) or unit == "pettarget" then
					return L["Enabling for this unit will cause the portrait to jitter"]
				end
			end,
		},
		camera={ name=L["3D Camera View"], type="select", values={ [1]=L["Facial"], [0]=L["Body"], }, set=set, get=getorone, order=20.3,
			hidden=function(info)
				local unit, object, setting = infobreakdown(info)
				return not db[unit][object].show3d
			end,
		},
	},
}
local hpbar={ name=L["Health Bar"], type="group", order=3,
	args={ 
		hide=hide, copyelement=copyelement, blank=blank,
		x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
		border=border, bordercolor=bordercolor,
		bgcolormethod=bgcolormethod, bgcolor=bgcolor, bgalpha=bgalpha,
		bartexture=bartexture, barcolormethod=barcolormethod, barcolor=barcolor, baralpha=baralpha, blank3=blank3,
		fade=fade, smoothfade=smoothfade, reverse=reverse, deplete=deplete, vertical=vertical, hflip=hflip, vflip=vflip, blank4=blank4,
		barinsetleft=barinsetleft, barinsetright=barinsetright, barinsettop=barinsettop, barinsetbottom=barinsetbottom,
		inc={ name=L["Show Incoming Heals"], desc=L["Beta - only works with rectangular bar textures"], type="toggle", order=100, set=set, get=get, },
	},
}
local function notplayer(info)
	return infobreakdown(info) ~= "player"
end
local mpbar={ name=L["Power Bar"], type="group", order=4,
	args={ 
		hide=hide, copyelement=copyelement, blank=blank, 
		x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
		border=border, bordercolor=bordercolor,
		bgcolormethod=bgcolormethod, bgcolor=bgcolor, bgalpha=bgalpha,
		bartexture=bartexture, barcolormethod=barcolormethod, barcolor=barcolor, baralpha=baralpha, blank3=blank3,
		fade=fade, smoothfade=smoothfade, reverse=reverse, deplete=deplete, vertical=vertical, hflip=hflip, vflip=vflip, blank4=blank4,
		barinsetleft=barinsetleft, barinsetright=barinsetright, barinsettop=barinsettop, barinsetbottom=barinsetbottom,
		hidemanatick={ name=L["Hide 5s Rule Tick"], type="toggle", set=set, get=get, hidden=notplayer, order=34, },
		sparkcolor={ name=L["Spark Color"], type="color", hasAlpha=true, set=set, get=getcolororwhite, hidden=notplayer, order=99, }
	},
}

local texttagoptions={ hide=hide, copyelement=copyelement, blank=blank, 
	x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
	bg=bg, bgcolor=bgcolor, border=border, bordercolor=bordercolor, 
	blank3=blank3,
	patternhelp={
	name=L["Pattern Tag Help"], type="toggle", order=30,
		set=function(info, v)
			if not taghelp then
				taghelp=CreateFrame("Frame", nil, Stuf, BackdropTemplateMixin and "BackdropTemplate")
				taghelp:SetWidth(500)
				taghelp:SetHeight(750)
				taghelp:EnableMouse(true)
				taghelp:SetMovable(true)
				taghelp:RegisterForDrag("LeftButton")
				taghelp:SetScript("OnDragStart", OnDragStart)
				taghelp:SetScript("OnDragStop", OnDragStop)
				taghelp:SetPoint("TOP", UIParent, "BOTTOMLEFT", SettingsPanel:GetRight() - 100, SettingsPanel:GetTop() + 100)
				taghelp:SetBackdrop({ bgFile="Interface\\Tooltips\\UI-Tooltip-Background" })
				taghelp:SetBackdropColor(0, 0, 0, 0.7)
				
				taghelp.close = CreateFrame("Button", nil, taghelp, "UIPanelCloseButton,BackdropTemplate")
				taghelp.close:SetWidth(22)
				taghelp.close:SetHeight(22)
				taghelp.close:SetPoint("TOPRIGHT", 4, 4)
				
				taghelp.text=taghelp:CreateFontString(nil, "ARTWORK")
				taghelp.text:SetAllPoints()
				taghelp.text:SetFontObject(GameFontHighlightSmall)
				taghelp.text:SetJustifyH("LEFT")
				taghelp.text:SetJustifyV("TOP")
				taghelp.text:SetText(L["taghelptext"])
			end
			if v then taghelp:Show() else taghelp:Hide() end
		end,
		get=function() return taghelp and taghelp:IsShown() end,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return not db[unit][object].pattern
		end,
	},
	useadvance={ name=L["Use Custom Lua"], desc=L["Only for advanced users; misuse may cause errors and performance issues."], type="toggle", get=get, order=30.1,
		set=function(info, v)
			local unit, object, setting = infobreakdown(info)
			if v then
				db[unit][object].pattern = ""
			else
				db[unit][object].advancecode = nil
			end
			set(info, v)
		end,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return not db[unit][object].pattern
		end,
	},
	pattern={ name=L["Text Pattern"], type="input", width="full", set=set, get=get, order=30.2, 
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return not db[unit][object].pattern or db[unit][object].useadvance
		end,
	},
	advancecode={ name=L["Code"], desc=L.advancecodehelp, type="input", width="full", multiline=true, order=30.2,
		set=set,
		get=function(info)
			local unit, object, setting = infobreakdown(info)
			return db[unit][object][setting] or "function(unit, cache, textframe) return 'text' end"
		end,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return not db[unit][object].useadvance
		end,
	},
	frequent={ name=L["Frequent Updates"], desc=L["Update three times per second (once per unit refresh if disabled)"], width="full", type="toggle", set=set, get=get, order=30.3,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return not db[unit][object].useadvance
		end,
	},
	emptyhide={ name=L["Hide Frame If Empty"], desc=L["Only necessary if border/backdrop is visible."], type="toggle", set=set, get=get, order=30.4,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return db[unit][object].useadvance or not strmatch(object, "^text")
		end,
	},
	onmouse={
		name=L["Show Only on Mouseover"], type="toggle", set=set, get=get, order=30.5,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return not db[unit][object].pattern
		end,
	},
	font=font, fontsize=fontsize, fontflags=fontflags, fontcolor=fontcolor, alphazero=alphazero,
	justifyH=justifyH, justifyV=justifyV,
	shadowx=shadowx, shadowy=shadowy,
}
local text1={ name=L["Text"]..1, type="group", order=5, args=texttagoptions, }
local text2={ name=L["Text"]..2, type="group", order=6, args=texttagoptions, }
local text3={ name=L["Text"]..3, type="group", order=7, args=texttagoptions, }
local text4={ name=L["Text"]..4, type="group", order=8, args=texttagoptions, }
local text5={ name=L["Text"]..5, type="group", order=9, args=texttagoptions, }
local text6={ name=L["Text"]..6, type="group", order=10, args=texttagoptions, }
local text7={ name=L["Text"]..7, type="group", order=11, args=texttagoptions, }
local text8={ name=L["Text"]..8, type="group", order=12, args=texttagoptions, }
local combattext={ name=L["Combat Text"], type="group", order=13, args=textoptions, }
local grouptext={ name=L["Group Number"], type="group", order=14, args=textoptions, }

local spacing={ name=L["Horizontal Spacing"], type="range", min=-5, max=40, step=1, set=set, get=getorzero, order=12, }
local vspacing={ name=L["Vertical Spacing"], type="range", min=-5, max=40, step=1, set=set, get=getorzero, order=13, }
local growth={ name=L["Growth"], type="select", set=set, get=get, order=11, 
	values={ 
		LRTB=L["Left"].." "..L["Right"]..", "..L["Top"].." "..L["Bottom"], LRBT=L["Left"].." "..L["Right"]..", "..L["Bottom"].." "..L["Top"], 
		RLTB=L["Right"].." "..L["Left"]..", "..L["Top"].." "..L["Bottom"], RLBT=L["Right"].." "..L["Left"]..", "..L["Bottom"].." "..L["Top"], 
		TBLR=L["Top"].." "..L["Bottom"]..", "..L["Left"].." "..L["Right"], TBRL=L["Top"].." "..L["Bottom"]..", "..L["Right"].." "..L["Left"], 
		BTLR=L["Bottom"].." "..L["Top"]..", "..L["Left"].." "..L["Right"], BTRL=L["Bottom"].." "..L["Top"]..", "..L["Right"].." "..L["Left"], 
	},
}
local pushvalues={ None=L["None"], h=L["Horizontal"], v=L["Vertical"], }
local onlymine={ name=L["Show Mine Only"], type="toggle", set=set, get=get, order=16.09, }
local showpie={ name=L["Show Cooldown Pie"], desc=L["Enabling may decrease performance"], type="toggle", set=set, get=get, order=16.2, }
local pieonlymine={
	name=L["Pie Only on Mine"], type="toggle", set=set, get=get, order=16.3,
	hidden=function(info)
		local unit, object, setting = infobreakdown(info)
		return not db[unit][object].showpie
	end,
}
local hidecc={
	name=L["Hide OmniCC"], type="toggle", set=set, get=get, order=16.4,
	hidden=function(info)
		local unit, object, setting = infobreakdown(info)
		return not db[unit][object].showpie
	end,
}
local nomouse={ name=_G.MAKE_UNINTERACTABLE or "Noninteractive", type="toggle", set=set, get=get, order=16.5, }
local countt={ name=L["Count Text"], dialogInline=true, type="group", order=40, args=textoptions2, }
local timet={
	name=L["Time Text"], dialogInline=true, type="group", order=41, args=textoptions2, 
	hidden=function(info)
		local unit, object, setting = infobreakdown(info)
		return not su[unit] or su[unit].ismetro
	end,
}

local playeraura={
	name=L["Premade Player"], desc=L["Apply base layout to replace default buff/debuff icons."], type="execute", order=2.8,
	func=function()
		local bdb = db.player.buffgroup
		bdb.hide = nil
		bdb.push = nil
		bdb.x, bdb.y = floor(BuffFrame:GetCenter() - db.player.frame.x), floor(BuffFrame:GetTop() - GetScreenHeight() - db.player.frame.y)
		bdb.w, bdb.h, bdb.alpha = 32, 32, 1
		bdb.count, bdb.rows, bdb.cols, bdb.vspacing, bdb.spacing, bdb.growth = 32, 4, 8, 9, 2, "RLTB"
		bdb.counttfontsize = 13
		bdb.timex, bdb.timey, bdb.timew, bdb.timeh, bdb.timefontsize, bdb.timejustifyH = -5, -29, 39, 12, 10, "CENTER"
		bdb.timefontcolor = bdb.timefontcolor or { }
		bdb.timefontcolor.r, bdb.timefontcolor.g, bdb.timefontcolor.b, bdb.timefontcolor.a = 1, 1, 1, 0.9
		Stuf:UpdateElementLook("player", "buffgroup")

		local ddb = db.player.debuffgroup
		ddb.hide = nil
		ddb.push = nil
		ddb.x, ddb.y = bdb.x, bdb.y - 166
		ddb.w, ddb.h, ddb.alpha = bdb.w, bdb.h, 1
		ddb.count, ddb.rows, ddb.cols, ddb.vspacing, ddb.spacing, ddb.growth = 16, 2, 8, 9, 2, "RLTB"
		ddb.counttfontsize = 13
		ddb.timex, ddb.timey, ddb.timew, ddb.timeh, ddb.timefontsize, ddb.timejustifyH = -5, -29, 39, 12, 10, "CENTER"
		ddb.timefontcolor = ddb.timefontcolor or { }
		ddb.timefontcolor.r, ddb.timefontcolor.g, ddb.timefontcolor.b, ddb.timefontcolor.a = 1, 1, 1, 0.9
		Stuf:UpdateElementLook("player", "debuffgroup")

		local tdb = db.player.tempenchant
		tdb.hide = nil
		tdb.x, tdb.y = bdb.x + 4, bdb.y
		tdb.w, tdb.h, tdb.alpha = 16, 16, 1
		tdb.count, tdb.growth = 2, "TBLR"
		tdb.timex, tdb.timey, tdb.timew, tdb.timefontsize, tdb.timejustifyH = 17, -2, 24, 8, "LEFT"
		tdb.timefontcolor = tdb.timefontcolor or { }
		tdb.timefontcolor.r, tdb.timefontcolor.g, tdb.timefontcolor.b, tdb.timefontcolor.a = 1, 1, 1, 0.9
		Stuf:UpdateElementLook("player", "tempenchant")
	end,
	hidden=notplayer, confirm=true,
}

local ispushed={
	name=L["Pushing is enabled (see below). This position may have an offset."], type="description", width="double", order=3.9,
	hidden=function(info)
		local unit, object, setting = infobreakdown(info)
		return not db[unit][object].push or db[unit][object].push == "None" or unit == "player"
	end,
}
local buffgroup={ 
	name=L["Buff Icons"], type="group", order=15, 
	args={
		hide=hide, copyelement=copyelement, playeraura=playeraura, blank=blank, 
		ispushed=ispushed, 
		plapush={
			name=L.playerbuffs, type="description", width="double", order=3.91,
			hidden=function(info)
				local unit, object, setting = infobreakdown(info)
				return unit ~= "player"
			end,
		},
		x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
		count={ name=L["Max Icons"], type="range", min=1, max=32, step=1, set=set, get=get, order=10, },
		growth=growth,
		rows={ name=L["Rows"], type="range", min=1, max=32, step=1, set=set, get=get, order=11.1, },
		cols={ name=L["Columns"], type="range", min=1, max=32, step=1, set=set, get=get, order=11.2, },
		spacing=spacing, vspacing=vspacing,
		push={
			name=L["Push Direction from Cast Bar"], desc=L["pushhelp"], type="select", set=set, get=getornone, order=16, values=pushvalues,
			hidden=function(info)
				local unit, object, setting = infobreakdown(info)
				return unit == "player"
			end,
		},
		onlymine=onlymine,
		curable={ name=L["Show Only Castable on Friendlies"], type="toggle", set=set, get=get, order=16.1, },
		showpie=showpie, pieonlymine=pieonlymine, hidecc=hidecc, nomouse=nomouse,
		countt=countt, time=timet,
	},
}
local debuffgroup={ 
	name=L["Debuff Icons"], type="group", order=16,
	args={
		hide=hide, copyelement=copyelement, playeraura=playeraura, blank=blank, 
		ispushed=ispushed, x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
		count={ name=L["Max Icons"], type="range", min=1, max=40, step=1, set=set, get=get, order=10, },
		growth=growth,
		rows={ name=L["Rows"], type="range", min=1, max=40, step=1, set=set, get=get, order=14, },
		cols={ name=L["Columns"], type="range", min=1, max=40, step=1, set=set, get=get, order=15, },
		spacing=spacing, vspacing=vspacing,
		push={ name=L["Push Direction from Buffs"], desc=L["pushhelp"], type="select", set=set, get=getornone, order=16, values=pushvalues, },
		onlymine=onlymine,
		curable={ name=L["Show Only Curable on Friendlies"], type="toggle", set=set, get=get, order=16.1, },
		showpie=showpie, pieonlymine=pieonlymine, hidecc=hidecc, nomouse=nomouse,
		countt=countt, time=timet,
	},
}
local auratimers={
	name=L["Aura Timers"], type="group", order=17,
	args={
		hide=hide, copyelement=copyelement, blank=blank, 
		ispushed=ispushed, x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
		count={ name=L["Max Timers"], type="range", min=1, max=16, step=1, set=set, get=get, order=10, },
		growth=growth,
		rows={ name=L["Rows"], type="range", min=1, max=16, step=1, set=set, get=get, order=14, },
		cols={ name=L["Columns"], type="range", min=1, max=16, step=1, set=set, get=get, order=15, },
		spacing=spacing, vspacing=vspacing,
		push={ name=L["Push Direction from Debuffs"], desc=L["pushhelp"], type="select", set=set, get=getornone, order=16, values=pushvalues, },
		showpet={ name=L["Show Pet Aura"], type="toggle", set=set, get=get, order=16.2, },
		showspellname={ name=L["Show Spell Name"], type="toggle", order=16.3, set=set, get=get, },
		reverse=reverse, blank4=blank4,
		font=font, fontsize=fontsize, fontcolor=fontcolor,
		sparkcolor=sparkcolor,
	},
}
local tempenchant={ 
	name=L["Temp Enchants"], type="group", order=16,
	args={
		hide=hide, playeraura=playeraura, blank=blank, 
		x=x2, y=y2, w=w, h=h, blank2=blank2,
		spacing=spacing, vspacing=vspacing, growth=growth, nomouse=nomouse,
		countt=countt, time=timet,
	},
}
local dispellicon={ 
	name=L["Curable Debuff Icon"], type="group", order=26, hidden=function() return not Stuf.supportspell and Stuf.CLS ~= "WARLOCK" end, 
	args={
		hide=hide, copyelement=copyelement, blank=blank, 
		x=x2, y=y2, w=w, h=h,
		framelevel=framelevel, alpha=alpha, blank2=blank2,
		countt=countt,
	},
}

local basicicon={
	hide=hide, copyelement=copyelement, blank=blank, x=x2, y=y2, w=w, h=h, framelevel=framelevel, alpha=alpha,
	circular={
		name=L["Circular Icon"], type="toggle", set=set, get=get, order=20,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return object ~= "infoicon" and object ~= "lfgicon"
		end,
	},
	flip={
		name=L["Flip Icon"], type="toggle", set=set, get=get, order=21,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return object ~= "infoicon"
		end,
	},
	font={
		name=L["Font"], type="select", dialogControl="LSM30_Font", values=AceGUIWidgetLSMlists.font, set=set, get=getorfont, order=21,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return object ~= "pvpicon" or unit ~= "player"
		end,
	},
	fontsize={
		name=L["Font Size"], type="range", min=1, max=80, step=1, set=set, get=getorone, order=22,
		hidden=function(info)
			local unit, object, setting = infobreakdown(info)
			return object ~= "pvpicon" or unit ~= "player"
		end,
	},
}
local pvpicon={ name=L["PVP Icon"], type="group", order=20, args=basicicon, }
local statusicon={ name=L["Status Icon"], type="group", order=21, args=basicicon, }
local leadericon={ name=L["Leader Icon"], type="group", order=22, args=basicicon, }
local looticon={ name=L["Loot Icon"], type="group", order=23, args=basicicon, }
local raidtargeticon={ name=L["Raid Target Icon"], type="group", order=24, args=basicicon, }
local infoicon={ name=L["Class Icon"], type="group", order=25, args=basicicon, }
local voiceicon={ name=L["Voice Icon"], type="group", order=27, args=basicicon, }
local inspectbutton={ name=L["Inspect Button"], type="group", order=28, args=basicicon, }
local vehicleicon={ name=L["Vehicle Icon"], type="group", order=27.1, args=basicicon, }
local lfgicon = UnitGroupRolesAssigned and { name=L["LFG Role Icon"], type="group", order=27.2, args=basicicon, }

local castbar={
	name=L["Cast Bar"], type="group", order=28,
	args={
		hide=hide, copyelement=copyelement, blank=blank,
		premade={
			name=L["Premade Player"], desc=L["Apply a base layout for player casting bar."], type="execute", confirm=true, order=2.8,
			func=function()
				local pcb = db.player.castbar
				pcb.hide = nil
				pcb.x, pcb.y = GetScreenWidth() * 0.5 - 128 - db.player.frame.x, -GetScreenHeight() * 0.75 - db.player.frame.y
				pcb.w, pcb.h, pcb.alpha = 255, 17, 1
				pcb.bgcolor = pcb.bgcolor or { }
				pcb.bgcolor.r, pcb.bgcolor.g, pcb.bgcolor.b, pcb.bgcolor.a = 0, 0, 0, 0.5
				pcb.baralpha = 1
				pcb.bordercolor = pcb.bordercolor or { }
				pcb.bordercolor.r, pcb.bordercolor.g, pcb.bordercolor.b, pcb.bordercolor.a = 0, 0, 0, 0.8
				pcb.border = "Square Outline"
				pcb.iconx, pcb.icony, pcb.iconw, pcb.iconh, pcb.iconalpha = 1, -1, 15, 15, 1
				pcb.timex, pcb.timey, pcb.timew, pcb.timeh = 53, -2, 200, 12
				pcb.timefontcolor = pcb.timefontcolor or { }
				pcb.timefontcolor.r, pcb.timefontcolor.g, pcb.timefontcolor.b, pcb.timefontcolor.a = 1, 1, 1, 1
				pcb.timeformat = "remaindurationdelay"
				pcb.timefontsize, pcb.timeshadowx, pcb.timeshadowy, pcb.timejustifyH, pcb.timejustifyV = 10, -1, -1, "RIGHT", "CENTER"
				pcb.spellx, pcb.spelly, pcb.spellw, pcb.spellh, pcb.spellshadowx, pcb.spellshadowy = 16, -2, 183, 14, -1, -1
				pcb.spellfontsize, pcb.spelljustifyH, pcb.spelljustifyV = 12, "LEFT", "TOP"
				pcb.spellfontcolor = pcb.spellfontcolor or { }
				pcb.spellfontcolor.r, pcb.spellfontcolor.g, pcb.spellfontcolor.b, pcb.spellfontcolor.a = 1, 1, 1, 1
				Stuf:UpdateElementLook("player", "castbar")
				
				db.pet.castbar.hide = nil
				db.pet.castbar.iconalpha = 0
				Stuf:UpdateElementLook("pet", "castbar")
			end,
			hidden=notplayer,
		},
		x=x2, y=y2, w=w, h=h, alpha=alpha, framelevel=framelevel, blank2=blank2,
		border=border, bordercolor=bordercolor,
		bartexture=bartexture, bgcolor=bgcolor, baralpha=baralpha,
		reverse=reverse, vertical=vertical, hflip=hflip, vflip=vflip, blank4=blank4,
		barinsetleft=barinsetleft, barinsetright=barinsetright, barinsettop=barinsettop, barinsetbottom=barinsetbottom,
		showlag={ name=L["Show Latency"], type="toggle", set=set, get=get, order=28, hidden=notplayer, },
		lagcolor={ name=L["Latency Color"], type="color", hasAlpha=true, set=set, get=getcolororwhite, order=28.1, hidden=notplayer, },
		spell={ name=L["Spell Text"], dialogInline=true, type="group", order=40, args=textoptions2, },
		time=timet,
		icon={ name=L["Cast Icon"], dialogInline=true, type="group", order=42, args={ x=x2, y=y2, w=w, h=h, alpha=alpha, }, },
		sparkcolor=sparkcolor,
		timeformat={
			name=L["Cast Time Format"], type="select", set=set, get=get, order=50,
			values={ none=L["None"], remain=L["Remain"], remainduration=L["Remain | Duration"], remaindelay=L["+Delay Remain"], remaindurationdelay=L["+Delay Remain | Duration"], },
		},
	},
}
local threatbar={
	name=L["Threat Bar"], type="group", order=29,
	args={
		hide=hide, copyelement=copyelement, blank=blank,
		x=x2, y=y2, w=w, h=h, alpha=alpha, framelevel=framelevel, blank2=blank2,
		border=border, bordercolor=bordercolor,
		bgcolor=bgcolor, baralpha=baralpha,
		reverse=reverse, vertical=vertical,
		blank4=blank4,
		font=font, fontsize=fontsize, fontcolor=fontcolor,
		groupshow={ name=L["Only Show in Group"], width="double", type="toggle", order=60, set=set, get=get, },
	},
}

local totembar={
	name=L["Totem Timer Bar"], type="group", order=30,
	args={
		hide=hide, blank=blank,
		x=x2, y=y2, w=w, h=h, alpha=alpha, framelevel=framelevel, blank2=blank2,
		bgcolor=bgcolor, baralpha=baralpha,
		reverse=reverse, vertical=vertical, nomouse=nomouse,
		vstack={ name=L["Vertical Stack"], type="toggle", set=set, get=get, order=28, },
		blank4=blank4,
		font=font, fontsize=fontsize, fontcolor=fontcolor,
		sparkcolor=sparkcolor,
	},
}
local druidbar={
	name=L["Alternate Mana Bar"], type="group", hidden=function() return Stuf.CLS ~= "DRUID" and Stuf.CLS ~= "SHAMAN" and Stuf.CLS ~= "PRIEST" end, order=31,
	args={ 
		hide=hide, blank=blank, 
		x=x2, y=y2, w=w, h=h, framelevel=framelevel, blank2=blank2,
		border=border, bordercolor=bordercolor,
		bgcolormethod=bgcolormethod, bgcolor=bgcolor, bgalpha=bgalpha,
		barcolormethod=barcolormethod, barcolor=barcolor, baralpha=baralpha, blank3=blank3,
		fade=fade, reverse=reverse, vertical=vertical, hflip=hflip, vflip=vflip, blank4=blank4,
		barinsetleft=barinsetleft, barinsetright=barinsetright, barinsettop=barinsettop, barinsetbottom=barinsetbottom,
	},
}
local function DKHide() return Stuf.CLS ~= "DEATHKNIGHT" end
local runebar={
	name=L["Rune Bar"], type="group", hidden=DKHide, order=30,
	args={
		hide=hide, blank=blank,
		x=x2, y=y2, w=w, h=h, alpha=alpha, framelevel=framelevel,
	},
}

local bstrata={ name=L["Frame Strata/Overlay"], type="select", values=strata, set=set, get=getstrata, order = 50, }
local holybar={
	name=L["Holy Bar"], type="group", hidden=function() return Stuf.CLS ~= "PALADIN" end, order=30,
	args={
		hide=hide, blank=blank,
		x=x2, y=y2, scale=scale, alpha=alpha, framelevel=framelevel, nomouse=nomouse, strata=bstrata,
	},
}
local priestbar={
	name=L["Priest Bar"], type="group", hidden=function() return Stuf.CLS ~= "PRIEST" end, order=30,
	args={
		hide=hide, blank=blank,
		x=x2, y=y2, scale=scale, alpha=alpha, framelevel=framelevel, nomouse=nomouse, strata=bstrata,
	},
}
local shardbar={
	name=L["Shard Bar"], type="group", hidden=function() return Stuf.CLS ~= "WARLOCK" end, order=30,
	args={
		hide=hide, blank=blank,
		x=x2, y=y2, scale=scale, alpha=alpha, framelevel=framelevel, nomouse=nomouse, strata=bstrata,
	},
}
local eclipsebar={
	name=L["Eclipse Bar"], type="group", hidden=function() return Stuf.CLS ~= "DRUID" end, order=30,
	args={
		hide=hide, blank=blank,
		x=x2, y=y2, scale=scale, alpha=alpha, framelevel=framelevel, nomouse=nomouse, strata=bstrata,
	},
}
local arcanebar={
	name=L["Arcane Charges"], type="group", hidden=function() return Stuf.CLS ~= "MAGE" end, order=30,
	args={
		hide=hide, blank=blank,
		x=x2, y=y2, scale=scale, alpha=alpha, framelevel=framelevel, nomouse=nomouse, strata=bstrata,
	},
}

local function pointhide(info)
	local unit, object, setting = infobreakdown(info)
	return db[unit][object].combostyle ~= 2
end
local function colorhide(info)
	return not pointhide(info)
end
local pointoptions={ 
	x=x2, y=y2, w=w, h=h, 
	color={ name=L["Color"], type="color", hasAlpha=true, set=set, get=getcolororwhite, order=20, },
	glowcolor={ name=L["Glow Color"], type="color", hasAlpha=true, set=set, get=getcolororwhite, order=21, },
}
local comboframe={
	name=L["Combo Frame"], type="group", order=30,
	args={
		hide=hide, copyelement=copyelement, blank=blank, 
		x=x2, y=y2, w=w, h=h, alpha=alpha, framelevel=framelevel, blank2=blank2,
		combostyle={ name=L["Style"], width="double", type="select", values={ L["Tally Points"], L["Individual Circles"], }, set=set, get=getorone, order=10, },
		color={ name=L["Color"], type="color", hidden=colorhide, hasAlpha=true, set=set, get=getcolororwhite, order=20, },
		glowcolor={ name=L["Glow Color"], type="color", hidden=colorhide, hasAlpha=true, set=set, get=getcolororwhite, order=21, },
		tflip={ name=L["Flip Tally Texture"], type="toggle", hidden=colorhide, set=set, get=get, order=22, },
		combo1={ name=L["Point "]..1, dialogInline=true, type="group", hidden=pointhide, args=pointoptions, order=11, },
		combo2={ name=L["Point "]..2, dialogInline=true, type="group", hidden=pointhide, args=pointoptions, order=12, },
		combo3={ name=L["Point "]..3, dialogInline=true, type="group", hidden=pointhide, args=pointoptions, order=13, },
		combo4={ name=L["Point "]..4, dialogInline=true, type="group", hidden=pointhide, args=pointoptions, order=14, },
		combo5={ name=L["Point "]..5, dialogInline=true, type="group", hidden=pointhide, args=pointoptions, order=15, },
		combo6={ name=L["Point "]..6, dialogInline=true, type="group", hidden=pointhide, args=pointoptions, order=16, },
	},
}
local hidealpha = function() return not db.global.morealpha end

local options
options={
	type="group",
	name = L["Stuf"],
	args={ 
		configmode={
			name=L["Config Mode"], desc=L["Preview everything."], type="toggle", order=1, 
			set=function(info, v)
				if InCombatLockdown() then
					return ChatFrame1:AddMessage("|cff00ff00Stuf|r: "..L["Unable to process while in combat."])
				end
				config=v 
				Stuf:SetConfigMode(v) 
			end, 
			get=function() return config end,
		},
		highlight={ 
			name=L["Toggle Highlighter"], desc=L["Highlights currently selected element."], type="toggle", order=1, 
			set=function(info, v)
				if not highlight then
					highlight=CreateFrame("Frame", nil, Stuf, BackdropTemplateMixin and 'BackdropTemplate')
					highlight.t=highlight:CreateTexture(nil, "OVERLAY")
					highlight.t:SetTexture("Interface\\AddOns\\Stuf\\media\\outline.tga")
					highlight.t:SetVertexColor(1, 1, 0, 0.7)
					highlight.t:SetAllPoints()
					highlight:Hide()
				end
				if v then
					highlight:Show()
				else
					highlight:Hide()
				end
			end,
			get=function() return highlight and highlight:IsShown() end,
		},
		movable={
			name=L["Toggle Drag"], desc=L["draghelp"], type="toggle", order=1,
			set=function(info, v)
				if InCombatLockdown() then
					return ChatFrame1:AddMessage("|cff00ff00Stuf|r: "..L["Unable to process while in combat."])
				end
				drag=v
				for unit, uf in pairs(su) do
					uf:SetMovable(drag)
					uf:RegisterForDrag(drag and "LeftButton")
					uf:SetScript("OnDragStart", OnDragStart)
					uf:SetScript("OnDragStop", OnDragStop)
				end
			end,
			get=function() return drag end,
		},
		global={
			name=L["Global"], type="group", order=3,
			args={
				desc={
					name=L["Only configure while out of combat. For more info or to report bugs, go here:"],
					type="input", width="full", order=0.1, get=function() return "http://www.wowinterface.com/downloads/info11182.html" end, },
				hidehints={ name=L["Hide Tips"], type="toggle", width="full", set=function(info, v) db.global.hidehints = v end, get=get, order=0.2, },
				hints={ name=L.generalhelp, type="description", width="full", hidden=function() return db.global.hidehints end, order=0.3, },
				morealpha={ name=L["Enable Target/Combat Opacity"], desc=L["Enabling this may cause lag"], type="toggle", set=set, get=get, order=1.1, },
				alpha={ 
					name=function() return db and db.global and db.global.morealpha and L["No Target/No Combat"] or L["Frame Opacity"] end, 
					type="range", min=0, max=1, step=0.05, set=set, get=getorone, order=1.2, },
				targetalpha={ name=L["Target/No Combat"], type="range", min=0, max=1, step=0.05, set=set, get=getorone, hidden=hidealpha, order=1.3, },
				combatalpha={ name=L["No Target/Combat"], type="range", min=0, max=1, step=0.05, set=set, get=getorone, hidden=hidealpha, order=1.4, },
				combattargetalpha={ name=L["Target/Combat"], type="range", min=0, max=1, step=0.05, set=set, get=getorone, hidden=hidealpha, order=1.5, },
				ooralpha={
					name=L["Out-of-Range Opacity"], desc=L["May cause lag if value is different from Frame Opacity. Does not work in combo with Target/Combat opacity.  Only applies to friendly and/or group units."], type="range", min=0, max=1, step=0.05, order=1.6,
					set=set, get=getorone, hidden=function(info) return not hidealpha(info) end, },
				strata={ name=L["Frame Strata/Overlay"], type="select", values=strata, set=set, get=getstrata, order=1.7, },
				petbattlehide={ name=L["Hide Stuf During Pet Battles"], type="toggle", width="double", set=set, get=get, order=1.71,  },
				blank=blank,
				bglist={ name=L["Background List"], type="select", values={ statusbar="Statusbars", background="Backgrounds", }, set=set, get=get, order=4, },
				bg={
					name=L["Background Texture"], type="select", dialogControl="LSM30_Border", set=set, get=get, order=5, 
					values=function()
						if db.global.bglist == "background" then
							options.args.global.args.bg.dialogControl="LSM30_Background"
							return AceGUIWidgetLSMlists.background
						else
							options.args.global.args.bg.dialogControl="LSM30_Statusbar"
							return AceGUIWidgetLSMlists.statusbar
						end
					end,
				},
				bgcolor={ name=L["Background Color"], type="color", hasAlpha=true, set=set, get=get, order=6, },
				bgmousecolor={ name=L["Background Mouseover Color"], type="color", hasAlpha=true, set=set, get=get, order=7, },
				border={ name=L["Border Texture"], type="select", dialogControl="LSM30_Border", values=AceGUIWidgetLSMlists.border, set=set, get=get, order=8, },
				bordermousecolor={ name=L["Border Mouseover Color"], type="color", hasAlpha=true, set=set, get=get, order=9, },
				borderaggrocolor={ name=L["Border Aggro Color"], type="color", hasAlpha=true, set=set, get=get, order=9, },
				blank2=blank2,
				bartexture={
					name=L["Statusbar Texture"], desc=L["Changing this will override all current bar settings"], type="select", order=11,
					dialogControl="LSM30_Statusbar", values=AceGUIWidgetLSMlists.statusbar, confirm=true, set=set, get=get, },
				font={ 
					name=L["Default Font"], desc=L["Changing this will override all current font settings"], type="select", order=11,
					dialogControl="LSM30_Font", values=AceGUIWidgetLSMlists.font, confirm=true, set=set, get=get, },
				aurastyle={ name=L["Aura Icon Style"], type="select", values={ L["Default"], L["Square"], }, set=set, get=getorone, order=12, },
				shortk={ 
					name=L["Number Shorten Start"], type="input", order=12.2,
					set=function(info, v)
						v = tonumber(v)
						db.global.shortk = v or 100000
						if not v then
							print("|cff00ff00Stuf|r: "..L["Value must be a number."])
						end
						Stuf:UpdateElementLook("global")
					end,
					get=function() return tostring(db.global.shortk) end
				},
				nK={ name=L["Thousand Short"], type="input", order=12.21, set=set, get=get, },
				nM={ name=L["Million Short"], type="input", order=12.22, set=set, get=get, },
				hidepartyinraid={ name=_G.HIDE_PARTY_INTERFACE_TEXT, type="toggle", width="double", order=12.4,
					set=function(info, v) set(info, v) Stuf.GroupUpdate() end, get=get, },
				showarena={
					name=L["Show Party in Arena"], type="toggle", width="double", set=set, get=get, order=12.5,
					set=function(info, v)
						set(info, v)
						Stuf.GroupUpdate()
					end,
					hidden=function() return GetCVar("hidePartyInRaid") ~= "1" end,
				},
				disableboss={ name=L["Disable Default Boss Frames"], type="toggle", width="double", desc=L["Disable default boss frames and use Stuf's. Automatically reloads UI"], confirm=true, 
					set=function(info, v) set(info, v) ReloadUI() end, get=get, order=12.6, },
				disableprframes={ name=L["Hide Default Group Frames"], desc=L["May need to reload to take full effect."], type="toggle", width="double", confirm=true,
					set=function(info, v) set(info, v) end, get=get, order=12.7, },
				classification={
					name=L["Classification Text"], dialogInline=true, type="group", order=12.9,
					args={
						normal={ name=L["Normal"], type="input", set=set, get=get, order=1, },
						rare={ name=L["Rare"], type="input", set=set, get=get, order=2, },
						elite={ name=L["Elite"], type="input", set=set, get=get, order=3, },
						rareelite={ name=L["Rare Elite"], type="input", set=set, get=get, order=4, },
						worldboss={ name=L["Boss"], type="input", set=set, get=get, order=5, },
						unknown={ name=L["Unknown Level"], type="input", set=set, get=get, order=6, }, 
					},
				},
				classcolor={ name=L["Class Colors"], dialogInline=true, type="group", order=20, args={ }, },
				reactioncolor={ name=L["Reaction Colors"], dialogInline=true, type="group", order=20, args={ }, },
				powercolor={ name=L["Power Type Colors"], dialogInline=true, type="group", order=21, args={ }, },
				auracolor={ name=L["Aura Type Colors"], dialogInline=true, type="group", order=22, args={ }, },
				runecolor={ name=L["Rune Type Colors"], dialogInline=true, type="group", hidden=DKHide, order=22, args={ }, },
				hpgreen={ name=L["Health Green Color"], desc=L["Used in threshold coloring"], type="color", hasAlpha=true, set=set, get=get, order=23, },
				hpred={ name=L["Health Red Color"], desc=L["Used in threshold coloring"], type="color", hasAlpha=true, set=set, get=get, order=24, },
				hpfadecolor={ name=L["Health Fade Color"], type="color", hasAlpha=true, set=set, get=get, order=25, },
				mpfadecolor={ name=L["Power Fade Color"], type="color", hasAlpha=true, set=set, get=get, order=26, },
				shadowcolor={ name=L["Text Shadow Color"], type="color", hasAlpha=true, set=set, get=get, order=27, },
				gray={ name=L["Gray Color"], type="color", hasAlpha=true, set=set, get=get, order=28, },
				blank4=blank4,
				castcolor={ name=L["Casting Color"], type="color", hasAlpha=true, set=set, get=get, order=30, },
				channelcolor={ name=L["Channeling Color"], type="color", hasAlpha=true, set=set, get=get, order=31, },
				completecolor={ name=L["Cast Complete Color"], type="color", hasAlpha=true, set=set, get=get, order=32, },
				failcolor={ name=L["Cast Fail Color"], type="color", hasAlpha=true, set=set, get=get, order=33, },
				defaults={ 
					name=L["Restore Defaults"], desc=L["Automatically reloads UI"], type="execute", confirm=true, order=34,
					func=function()
						if StufDB == "perchar" then
							Stuf:LoadDefaults(StufCharDB, true, true)
						else
							Stuf:LoadDefaults(StufDB, true)
						end
					end,
				},
				perchar={
					name=L["Save Per Character"], desc=L["Automatically reloads UI and may reset settings for other characters."], type="toggle", confirm=true, order=35,
					set=function(info, v)
						if v then
							StufCharDB = StufDB ~= "perchar" and StufDB or { }
							StufDB = "perchar"
							ReloadUI()
						else
							StufDB = StufCharDB
							StufCharDB = nil
							ReloadUI()
						end
					end,
					get=function() return StufDB == "perchar" or (type(StufDB) == "table" and StufDB.temp) end,
				},
				copyvars={
					name=L["Copy to Next Char"], desc=L["Current settings will be copied to next character login."], type="execute", confirm=true, order=36,
					func=function() StufDB={ temp = db, } end,
					hidden=function() return StufDB ~= "perchar" end,
				},
				version={ name="v"..(C_AddOns.GetAddOnMetadata("Stuf", "Version") or "?.?.???"), type="description", width="full", order=40, },
			},
		},
		player={
			name=_G.PLAYER, type="group", order=4,
			args={
				frame=frame, 
				portrait=portrait,
				hpbar=hpbar, 
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4, text5=text5, text6=text6, text7=text7, text8=text8,
				combattext=combattext,
				grouptext=grouptext,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				tempenchant=tempenchant,
				dispellicon=dispellicon,
				pvpicon=pvpicon,
				statusicon=statusicon,
				leadericon=leadericon,
				looticon=looticon,
				raidtargeticon=raidtargeticon,
				infoicon=infoicon,
				voiceicon=voiceicon,
				vehicleicon=vehicleicon,
				lfgicon=lfgicon,
				totembar=totembar,
				runebar=runebar, druidbar=druidbar, holybar=holybar, shardbar=shardbar,
				eclipsebar=eclipsebar, priestbar=priestbar, arcanebar=arcanebar,
				castbar=castbar,
			},
		},
		target={
			name=_G.TARGET, type="group", order=5,
			args={
				frame=frame, 
				portrait=portrait,
				hpbar=hpbar, 
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4, text5=text5, text6=text6, text7=text7, text8=text8,
				combattext=combattext,
				grouptext=grouptext,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				auratimers=auratimers,
				dispellicon=dispellicon,
				pvpicon=pvpicon,
				statusicon=statusicon,
				leadericon=leadericon,
				looticon=looticon,
				raidtargeticon=raidtargeticon,
				infoicon=infoicon,
				castbar=castbar,
				comboframe=comboframe,
				inspectbutton=inspectbutton,
				threatbar=threatbar,
				lfgicon=lfgicon,
			},
		},
		targettarget={
			name=_G.TARGET..L[" of Tar"], type="group", order=7,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				statusicon=statusicon,
				dispellicon=dispellicon,
				pvpicon=pvpicon,
				raidtargeticon=raidtargeticon,
				infoicon=infoicon,
			},
		},
		targettargettarget={
			-- name=_G.TARGET.." ".._G.TARGET.." ".._G.TARGET, type="group", order=7.1,
			name=L["Tar"]..L[" of Tar"]..L[" of Tar"], type="group", order=7.1,
			args={ 
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				raidtargeticon=raidtargeticon,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				infoicon=infoicon,
			},
		},
		focus={
			name=L["Focus"], type="group", order=8,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				auratimers=auratimers,
				statusicon=statusicon,
				dispellicon=dispellicon,
				pvpicon=pvpicon,
				raidtargeticon=raidtargeticon,
				infoicon=infoicon,
				threatbar=threatbar,
				comboframe=comboframe,
				castbar=castbar,
			},
		},
		focustarget={
			name=L["Focus"].." ".._G.TARGET, type="group", order=8.1,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				raidtargeticon=raidtargeticon,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				infoicon=infoicon,
			},
		},
		pet={
			name=_G.PET, type="group", order=6,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar, 
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4, text5=text5, text6=text6,
				combattext=combattext,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				dispellicon=dispellicon,
				statusicon=statusicon,
				raidtargeticon=raidtargeticon,
				infoicon=infoicon,
				castbar=castbar,
				pettime={ name=L["Pet Timer"], type="group", order=33, args=textoptions, },
			},
		},
		party1={
			name=_G.PARTY.." 1", type="group", order=10,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar, 
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4, text5=text5, text6=text6,
				combattext=combattext,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				dispellicon=dispellicon,
				pvpicon=pvpicon,
				statusicon=statusicon,
				leadericon=leadericon,
				looticon=looticon,
				raidtargeticon=raidtargeticon,
				infoicon=infoicon,
				voiceicon=voiceicon,
				vehicleicon=vehicleicon,
				lfgicon=lfgicon,
				castbar=castbar,
			},
		},
		party2={ name=_G.PARTY.." 2", type="group", order=11, args={ frame=frame2, }, },
		party3={ name=_G.PARTY.." 3", type="group", order=12, args={ frame=frame2, }, },
		party4={ name=_G.PARTY.." 4", type="group", order=13, args={ frame=frame2, }, },
		pettarget={
			name=_G.PET.." ".._G.TARGET, type="group", order=20,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				raidtargeticon=raidtargeticon,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				infoicon=infoicon,
			},
		},
		party1target={ name=_G.PARTY.." 1 ".._G.TARGET, type="group", order=23, args={ frame=frame2, }, },
		party2target={ name=_G.PARTY.." 2 ".._G.TARGET, type="group", order=24, args={ frame=frame2, }, },
		party3target={ name=_G.PARTY.." 3 ".._G.TARGET, type="group", order=25, args={ frame=frame2, }, },
		party4target={ name=_G.PARTY.." 4 ".._G.TARGET, type="group", order=26, args={ frame=frame2, }, },
		
		partypet1={
			name=_G.PARTY.." 1 ".._G.PET, type="group", order=30,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				raidtargeticon=raidtargeticon,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				infoicon=infoicon,
			},
		},
		partypet2={ name=_G.PARTY.." 2 ".._G.PET, type="group", order=31, args={ frame=frame2, }, },
		partypet3={ name=_G.PARTY.." 3 ".._G.PET, type="group", order=32, args={ frame=frame2, }, },
		partypet4={ name=_G.PARTY.." 4 ".._G.PET, type="group", order=33, args={ frame=frame2, }, },
		arena1={
			name=_G.ARENA.." 1", type="group", order=35,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				infoicon=infoicon,
				castbar=castbar,
			},
		},
		arena2={ name=_G.ARENA.." 2", type="group", order=36, args={ frame=frame2, }, },
		arena3={ name=_G.ARENA.." 3", type="group", order=37, args={ frame=frame2, }, },
		arena4={ name=_G.ARENA.." 4", type="group", order=38, args={ frame=frame2, }, },
		arena5={ name=_G.ARENA.." 5", type="group", order=39, args={ frame=frame2, }, },
		arenapet1={
			name=_G.ARENA.." 1 ".._G.PET, type="group", order=40,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				infoicon=infoicon,
			},
		},
		arenapet2={ name=_G.ARENA.." 2 ".._G.PET, type="group", order=41, args={ frame=frame2, }, },
		arenapet3={ name=_G.ARENA.." 3 ".._G.PET, type="group", order=42, args={ frame=frame2, }, },
		arenapet4={ name=_G.ARENA.." 4 ".._G.PET, type="group", order=43, args={ frame=frame2, }, },
		arenapet5={ name=_G.ARENA.." 5 ".._G.PET, type="group", order=44, args={ frame=frame2, }, },
		arena1target={
			name=_G.ARENA.." 1 ".._G.TARGET, type="group", order=45,
			args={
				frame=frame,
				portrait=portrait,
				hpbar=hpbar,
				mpbar=mpbar,
				text1=text1, text2=text2, text3=text3, text4=text4,
				buffgroup=buffgroup,
				debuffgroup=debuffgroup,
				infoicon=infoicon,
			},
		},
		arena2target={ name=_G.ARENA.." 2 ".._G.TARGET, type="group", order=46, args={ frame=frame2, }, },
		arena3target={ name=_G.ARENA.." 3 ".._G.TARGET, type="group", order=47, args={ frame=frame2, }, },
		arena4target={ name=_G.ARENA.." 4 ".._G.TARGET, type="group", order=48, args={ frame=frame2, }, },
		arena5target={ name=_G.ARENA.." 5 ".._G.TARGET, type="group", order=49, args={ frame=frame2, }, },
	},
}

if Boss1TargetFrame and (not Stuf.dbg or Stuf.dbg.disableboss) then
	options.args.boss1={
		name=_G.BOSS.." 1", type="group", order=50,
		args={
			frame=frame,
			portrait=portrait,
			hpbar=hpbar,
			mpbar=mpbar,
			text1=text1, text2=text2, text3=text3, text4=text4,
			buffgroup=buffgroup,
			debuffgroup=debuffgroup,
			infoicon=infoicon,
			castbar=castbar,
			raidtargeticon=raidtargeticon,
			threatbar=threatbar,
		},
	}
	for i = 2, MAX_BOSS_FRAMES, 1 do
		options.args["boss"..i]={ name=_G.BOSS.." "..i, type="group", order=49+i, args={ frame=frame2, }, }
	end
	options.args.boss1target={
		name=_G.BOSS.." 1 ".._G.TARGET, type="group", order=60,
		args={
			frame=frame,
			portrait=portrait,
			hpbar=hpbar,
			mpbar=mpbar,
			text1=text1, text2=text2, text3=text3, text4=text4,
			buffgroup=buffgroup,
			debuffgroup=debuffgroup,
			infoicon=infoicon,
			raidtargeticon=raidtargeticon,
		},
	}
	for i = 2, MAX_BOSS_FRAMES, 1 do
		options.args["boss"..i.."target"]={ name=_G.BOSS.." "..i.." ".._G.TARGET, type="group", order=59+i, args={ frame=frame2, }, }
	end
end

do  -- setup options for grouped colors
	local keys={
		powercolor={
			MANA=0, RAGE=1, FOCUS=2, ENERGY=3, HAPPINESS=4, RUNES=5, RUNIC_POWER=6, SOUL_SHARDS=7,
			LUNAR_POWER=8, HOLY_POWER=9, MAELSTROM=11, INSANITY=13, FURY=17, PAIN=18,
		},
		reactioncolor={},
	}
	local function getcolor(info)
		local _, colorgroup, key = infobreakdown(info)
		local dbk = db.global[colorgroup][ keys[colorgroup][key] ]
		if not dbk then
			return 0, 0, 0, 0
		else
			return dbk.r, dbk.g, dbk.b, dbk.a
		end
	end
	local function setcolor(info, r, g, b, a)
		local _, colorgroup, key = infobreakdown(info)
		local dbk = db.global[colorgroup][ keys[colorgroup][key] ]
		r, g, b, a = shorten(r), shorten(g), shorten(b), shorten(a)
		if not dbk then
			db.global[colorgroup][ keys[colorgroup][key] ]={ r=r, g=g, b=b, a=a, }
		else
			dbk.r, dbk.g, dbk.b, dbk.a = r, g, b, a
		end
		Stuf:UpdateElementLook("global")
	end

	local oargs = options.args.global.args
	
	local lbf = LibStub("LibButtonFacade", true)
	if lbf then
		oargs.lbfskin={
			name=L["ButtonFacade Skin"], type="select", values=lbf:ListSkins(), set=set, get=get, order=12.1,
			hidden=function(info) return db.global.aurastyle ~= 3 end,
		}
		oargs.aurastyle.values[3] = L["ButtonFacade"]
		oargs.aurastyle.desc = L["Switching from ButtonFacade requires a reload."]
	end
	
	local cargs = oargs.classcolor.args
	local classcolorshide
	if CUSTOM_CLASS_COLORS then
		classcolorshide = function()
			return not db.global.nocustomclass
		end
		cargs.help={
			name=L["Use !ClassColors"], type="toggle", width="double", order = 0.1,
			get = function() return not db.global.nocustomclass end,
			set = function(info, value)
				db.global.nocustomclass = not value
				if value then
					Stuf.CCC_CB = Stuf.CCC_CB or function()
						for class, color in pairs(CUSTOM_CLASS_COLORS) do
							local dgcc = db.global.classcolor[class]
							dgcc.r, dgcc.g, dgcc.b = color.r, color.g, color.b
						end
						Stuf:UpdateElementLook("global")
					end
					CUSTOM_CLASS_COLORS:RegisterCallback(Stuf.CCC_CB)
					Stuf.CCC_CB()
				elseif Stuf.CCC_CB then
					CUSTOM_CLASS_COLORS:UnregisterCallback(Stuf.CCC_CB)
				end
			end,
		}
	end
	-- 將職業名稱改為中文
	local classNameList = {}
	FillLocalizedClassList(classNameList)
	for class, color in pairs(RAID_CLASS_COLORS) do
		if classNameList[class] then -- 過濾掉惡魔獵人等沒有職業名稱的
			cargs[class]={ name=classNameList[class], type="color", set=set, get=getcolororblank, hidden=classcolorshide, }
		end
	end
	
	local pargs = oargs.powercolor.args
	for power, index in pairs(keys.powercolor) do
		pargs[power]={ name=getglobal(power) or power, type="color", set=setcolor, get=getcolor, order=index, }
	end

	local rargs = oargs.reactioncolor.args
	for i = 1, 8, 1 do
		local key = _G["FACTION_STANDING_LABEL"..i]
		if key then
			rargs["faction"..i]={ name=key, type="color", set=setcolor, get=getcolor, order=i, }
			keys.reactioncolor["faction"..i] = i
		end
	end
	rargs["faction9"]={ name=L["Non-PVP Friendly"], type="color", set=setcolor, get=getcolor, order=9, }
	keys.reactioncolor["faction9"] = 9
	rargs["faction10"]={ name=L["Non-PVP Enemy"], type="color", set=setcolor, get=getcolor, order=10, }
	keys.reactioncolor["faction10"] = 10

	local aargs = oargs.auracolor.args
	aargs.none={ name=L["none"], type="color", set=set, get=getcolororblank, order=1, }
	aargs.Magic={ name=L["Magic"], type="color", set=set, get=getcolororblank, order=2, }
	aargs.Curse={ name=L["Curse"], type="color", set=set, get=getcolororblank, order=3, }
	aargs.Disease={ name=L["Disease"], type="color", set=set, get=getcolororblank, order=4, }
	aargs.Poison={ name=L["Poison"], type="color", set=set, get=getcolororblank, order=5, }
	aargs.Buff={ name=L["Buff"], type="color", set=set, get=getcolororblank, order=6, }
	aargs.MyBuff={ name=L["My Buff"], type="color", set=set, get=getcolororblank, order=7, }

	local runeargs = oargs.runecolor.args
	runeargs.BLOOD={ name=COMBAT_TEXT_RUNE_BLOOD or "Blood", type="color", set=set, get=getcolororblank, order=1, }
	runeargs.UNHOLY={ name=COMBAT_TEXT_RUNE_UNHOLY or "Unholy", type="color", set=set, get=getcolororblank, order=2, }
	runeargs.FROST={ name=COMBAT_TEXT_RUNE_FROST or "Frost", type="color", set=set, get=getcolororblank, order=3, }
	runeargs.DEATH={ name=COMBAT_TEXT_RUNE_DEATH or "Death", type="color", set=set, get=getcolororblank, order=4, }
end


-------------------------------
function Stuf:GetOptionsTable()
-------------------------------
	return options, textoptions
end

AceConfig:RegisterOptionsTable("Stuf", options)
--------------------------------
function Stuf:OpenOptions(frame)
--------------------------------
	if frame and not optionframe then
		frame.hidden = true
		CreateOptionFrame()
	end
	C_Timer.After(0.3, function()
		Settings.OpenToCategory(L["Stuf"], true)
	end)
end
