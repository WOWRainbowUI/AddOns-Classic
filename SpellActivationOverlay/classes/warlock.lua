local AddonName, SAO = ...

-- Optimize frequent calls
local GetTalentTabInfo = GetTalentTabInfo
local UnitCanAttack = UnitCanAttack
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local chaosBolt = 50796;
local drainSoul = 1120;
local felFlame = 77799;
local felSpark = 89937;
local incinerate = 29722;
local shadowBolt = 686;
local shadowburn = 17877;
local shadowCleave = 403841;
local soulFire = 6353;

local moltenCoreBuff = { 47383, 71162, 71165 };
local decimationBuff = { 63165, 63167 };
local backdraftBuff = { 54274, 54276, 54277 };

--[[
    DrainSoulHandler evaluates when the Drain Soul button should glow
    because the target has 25% health or less. Only in Wrath Classic.

    The following conditions must be met:
    - the current target can be attacked
    - the current target has 25% or less than 25% health

    This stops if either:
    - the target cannot be attacked
    - the target is healed over 25% health
]]
local DrainSoulHandler = {

    initialized = false,

    -- Methods

    checkOption = function(option)
        if option == "spec:1/2/3" then
            -- Always glow if 'all specs' option is chosen
            return true;
        elseif option == "spec:1" then
            -- If 'affliction only' option is chosen, check if Affliction is the majority spec
            local selector = SAO.IsCata() and 5 or 3;
            local afflictionPoints = select(selector, GetTalentTabInfo(1));
            local demonologyPoints = select(selector, GetTalentTabInfo(2));
            local destructionPoints = select(selector, GetTalentTabInfo(3));
            return afflictionPoints > demonologyPoints and afflictionPoints > destructionPoints;
        end
        return false;
    end,

    init = function(self, id, name)
        SAO.GlowInterface:bind(self);
        self:initVars(id, name, false, nil, {
            SAO:SpecVariantValue({ 1 }),
            SAO:SpecVariantValue({ 1, 2, 3 }),
        }, self.checkOption);
        self.initialized = true;
    end,

    checkTargetHealth = function(self)
        local canExecute = false;

        if UnitCanAttack("player", "target") then
            local hp = UnitHealth("target");
            local hpMax = UnitHealthMax("target");
            canExecute = hp > 0 and hp/hpMax <= 0.25;
        end

        if canExecute and not self.glowing then
            self:glow();
        elseif not canExecute and self.glowing then
            self:unglow();
        end
    end,
}

local function customLogin(self, ...)
    if self.IsWrath() or self.IsCata() then
        -- Drain Soul is empowered on low health enemies only in Wrath Classic and Cataclysm Classic
        local spellName = GetSpellInfo(drainSoul);
        if (spellName) then
            -- Must register glowing buttons manually, because Drain Soul is not registered by an aura/counter/etc.
            self:RegisterGlowIDs({ spellName });
            local allSpellIDs = self:GetSpellIDsByName(spellName);
            for _, oneSpellID in ipairs(allSpellIDs) do
                self:AwakeButtonsBySpellID(oneSpellID);
            end
            -- Initialize handler
            DrainSoulHandler:init(drainSoul, spellName);
        end
    elseif self.IsSoD() then
        -- No need to use the DrainSoulHandler for Season of Discovery
        -- The goal of the handler is to let players choose for which spec(s) Drain Soul will glow
        -- This allows to ask the players explicitly what they want, because we cannot always guess correctly
        -- But in Season of Discovery, there is a rune which dedicated to improve Drain Soul
        -- The rune answers implicitly, thus we don't need to ask players, hence the absence of handler
        self:CreateEffect(
            "drain_soul",
            SAO.SOD,
            drainSoul,
            "execute",
            {
                execThreshold = 20,
                requireTalent = true,
                talent = 403511, -- Soul Siphon (rune)
                button = drainSoul,
            }
        );
    end
end

local function retarget(self, ...)
    if DrainSoulHandler.initialized then
        DrainSoulHandler:checkTargetHealth();
    end
end

local function unitHealth(self, unitID)
    if DrainSoulHandler.initialized and unitID == "target" then
        DrainSoulHandler:checkTargetHealth();
    end
end

local function unitHealthFrequent(self, unitID)
    if self:IsResponsiveMode() then
        unitHealth(self, unitID);
    end
end

local function useNightfall(self)
    self:CreateEffect(
        "nightfall",
        SAO.ALL_PROJECTS,
        17941, -- Shadow Trance (buff)
        "aura",
        {
            talent = 18094, -- Nightfall (talent)
            overlay = { texture = "nightfall", position = "Left + Right (Flipped)" },
            buttons = {
                [SAO.ALL_PROJECTS] = shadowBolt,
                [SAO.SOD] = shadowCleave,
            },
        }
    );
end

local function registerMoltenCore(self, rank)
    local moltenCoreName = { "molten_core_low", "molten_core_medium", "molten_core_high" };
    local overlayOption = (rank == 3) and { setupHash = SAO:HashNameFromStacks(0), testHash = SAO:HashNameFromStacks(3) };
    local buttonOption = rank == 3;

    self:CreateEffect(
        moltenCoreName[rank],
        SAO.WRATH + SAO.CATA,
        moltenCoreBuff[rank], -- Molten Core (buff) rank 1, 2 or 3
        "aura",
        {
            talent = 47245, -- Molten Core (talent)
            overlays = {
                { stacks = 1, texture = "molten_core", position = "Left", option = false },
                { stacks = 2, texture = "molten_core", position = "Left + Right (Flipped)", option = false },
                { stacks = 3, texture = "molten_core", position = "Left + Right (Flipped)", option = overlayOption }, -- Same visuals as 2 charges
            },
            buttons = {
                default = { option = buttonOption },
                [SAO.WRATH] = { incinerate, soulFire },
                [SAO.CATA] = { incinerate },
            },
        }
    );
end

local function useMoltenCore(self)
    if self.IsWrath() or self.IsCata() then
        self:AddOverlayLink(moltenCoreBuff[3], moltenCoreBuff[1]);
        self:AddOverlayLink(moltenCoreBuff[3], moltenCoreBuff[2]);
        self:AddGlowingLink(moltenCoreBuff[3], moltenCoreBuff[1]);
        self:AddGlowingLink(moltenCoreBuff[3], moltenCoreBuff[2]);

        registerMoltenCore(self, 1); -- 1/3 talent point
        registerMoltenCore(self, 2); -- 2/3 talent points
        registerMoltenCore(self, 3); -- 3/3 talent points
    end
end

local function registerDecimation(self, rank)
    local decimationName = { "decimation_low", "decimation_high" };

    self:CreateEffect(
        decimationName[rank],
        SAO.WRATH + SAO.CATA,
        decimationBuff[rank], -- Decimation (buff) rank 1 or 2
        "aura",
        {
            talent = 63156, -- Decimation (talent)
            overlay = { texture = "impact", position = "Top", scale = 0.8, option = (rank == 2) },
            button = { spellID = soulFire, option = (rank == 2) },
        }
    );
end

local function useDecimation(self)
    if self.IsWrath() or self.IsCata() then
        self:AddOverlayLink(decimationBuff[2], decimationBuff[1]);
        self:AddGlowingLink(decimationBuff[2], decimationBuff[1]);

        registerDecimation(self, 1); -- 1/2 talent point
        registerDecimation(self, 2); -- 2/2 talent points
    elseif self.IsSoD() then
        self:CreateEffect(
            "decimation",
            SAO.SOD,
            440873, -- Decimation (buff)
            "aura",
            {
                talent = 440870, -- Decimation (rune)
                overlay = { texture = "impact", position = "Top", scale = 0.8 },
                button = { spellID = soulFire },
            }
        );
    end
end

local function registerBackdraft(self, rank)
    local backdraftName = { "backdraft_low", "backdraft_medium", "backdraft_high" };

    self:CreateEffect(
        backdraftName[rank],
        SAO.CATA,
        backdraftBuff[rank], -- Backdraft (buff) rank 1, 2 or 3
        "aura",
        {
            talent = 47258, -- Backdraft (talent)
            buttons = {
                default = { option = (rank == 3) },
                [SAO.CATA] = { shadowBolt, incinerate, chaosBolt },
            },
        }
    );
end

local function useBackdraft(self)
    if self.IsCata() then
        self:AddOverlayLink(backdraftBuff[3], backdraftBuff[1]);
        self:AddOverlayLink(backdraftBuff[3], backdraftBuff[2]);
        self:AddGlowingLink(backdraftBuff[3], backdraftBuff[1]);
        self:AddGlowingLink(backdraftBuff[3], backdraftBuff[2]);

        registerBackdraft(self, 1); -- 1/3 talent point
        registerBackdraft(self, 2); -- 2/3 talent points
        registerBackdraft(self, 3); -- 3/3 talent points
    end
end

local function useShadowburn(self)
    self:CreateEffect(
        "shadowburn",
        SAO.CATA,
        shadowburn,
        "counter"
    );
end

local function useBacklash(self)
    self:CreateEffect(
        "backlash",
        SAO.TBC + SAO.WRATH + SAO.CATA,
        34936, -- Backlash (buff)
        "aura",
        {
            talent = 34935, -- Backlash (talent)
            overlay = { texture = "backlash", position = "Top" },
            buttons = { shadowBolt, incinerate },
        }
    );
end

local function useEmpoweredImp(self)
    self:CreateEffect(
        "empowered_imp",
        SAO.WRATH + SAO.CATA,
        47283, -- Empowered Imp (buff)
        "aura",
        {
            talent = 47220, -- Empowered Imp (talent)
            overlay = { texture = "imp_empowerment", position = "Left + Right (Flipped)" },
            buttons = {
                [SAO.CATA] = soulFire,
            }
        }
    );
end

local function useFelSpark(self)
    self:CreateEffect(
        "fel_spark",
        SAO.CATA,
        felSpark,
        "aura",
        {
            overlays = {
                { stacks = 1, texture = "impact", position = "Left (CCW)", scale = 0.6, color = { 22, 222, 122 }, option = false },
                { stacks = 2, texture = "impact", position = "Left (CCW)", scale = 0.6, color = { 22, 222, 122 }, option = false },
                { stacks = 2, texture = "impact", position = "Right (CW)", scale = 0.6, color = { 22, 222, 122 }, option = { setupHash = self:HashNameFromStacks(0), testHash = self:HashNameFromStacks(2) } },
            },
            button = felFlame,
        }
    );
end

local function registerClass(self)
    -- Affliction
    useNightfall(self); -- a.k.a. Shadow Trance

    -- Demonology
    useMoltenCore(self);
    useDecimation(self);

    -- Destruction
    useBackdraft(self);
    useShadowburn(self);
    useBacklash(self);
    useEmpoweredImp(self);

    -- Tier 11
    useFelSpark(self);
end

local function loadOptions(self)
    if DrainSoulHandler.initialized then
        self:AddGlowingOption(nil, DrainSoulHandler.optionID, drainSoul, nil, SAO:ExecuteBelow(25), DrainSoulHandler.variants);
    end
end

SAO.Class["WARLOCK"] = {
    ["Register"] = registerClass,
    ["LoadOptions"] = loadOptions,
    ["PLAYER_LOGIN"] = customLogin,
    ["PLAYER_TARGET_CHANGED"] = retarget,
    ["UNIT_HEALTH"] = unitHealth,
    ["UNIT_HEALTH_FREQUENT"] = unitHealthFrequent,
    IsDisabled = SAO.IsMoP(),
}
