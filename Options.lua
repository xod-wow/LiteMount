--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

--[[----------------------------------------------------------------------------

excludedSpells is actually tristate, the presence of an entry indicating
whether we have seen the mount before or not, and the value true/false
indicating whether it is to be excluded.0

----------------------------------------------------------------------------]]--

local defaults = {
    profile = {
        excludedSpells              = { },
        flagChanges                 = { },
        copyTargetsMount            = true,
        excludeNewMounts            = false,
    },
    char = {
        unavailableMacro            = "",
        combatMacro                 = "",
        useCombatMacro              = false,
    },
}

local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey

LM_Options = { }

local flagList = {
    run     = LM_FLAG_BIT_RUN,
    fly     = LM_FLAG_BIT_FLY,
    float   = LM_FLAG_BIT_FLOAT,
    swim    = LM_FLAG_BIT_SWIM,
    jump    = LM_FLAG_BIT_JUMP,
    walk    = LM_FLAG_BIT_WALK,
    aq      = LM_FLAG_BIT_AQ,
    vashjir = LM_FLAG_BIT_VASHJIR,
    nagrand = LM_FLAG_BIT_NAGRAND,
    custom1 = LM_FLAG_BIT_CUSTOM1,
    custom2 = LM_FLAG_BIT_CUSTOM2,
}

local function flagConvert(toSet, toClear)
    local flags = { }

    for flag,flagBit in pairs(flagList) do
        if bit.band(toSet, flagBit) == flagBit then
            flags[flag] = '+'
        elseif bit.band(toClear, flagBit) == flagBit then
            flags[flag] = '-'
        end
    end

    return flags
end

function LM_Options:ConvertToAce()
    if LM_OptionsDB then
        self.db.char.unavailableMacro = (not not LM_OptionsDB.macro[1])
        self.db.char.combatMacro = LM_OptionsDB.combatMacro[1]
        self.db.char.useCombatMacro = (LM_OptionsDB.combatMacro[2] == 1)

        self.db:SetProfile(charKey)
        self.db.profile.excludeNewMounts = LM_OptionsDB.excludeNewMounts[1]
        for spellID in pairs(LM_OptionsDB.seenspells) do
            self.db.profile.excludedSpells[spellID] = tContains(LM_OptionsDB.excludedspells, spellID)
        end
        for spellID, bitTable in pairs(LM_OptionsDB.flagoverrides) do
            self.db.profile.flagChanges[spellID] = flagConvert(unpack(bitTable))
        end
    end

    if LM_GlobalOptionsDB then
        self.db:SetProfile("Default")
        self.db.profile.excludeNewMounts = LM_GlobalOptionsDB.excludeNewMounts[1]
        for spellID in pairs(LM_GlobalOptionsDB.seenspells) do
            self.db.profile.excludedSpells[spellID] = tContains(LM_GlobalOptionsDB.excludedspells[spellID])
        end
        for spellID, bitTable in pairs(LM_GlobalOptionsDB.flagoverrides) do
            self.db.profile.flagChanges[spellID] = flagConvert(unpack(bitTable))
        end
    end

    if LM_OptionsDB and LM_OptionsDB.useglobal[1] ~= true then
        self.db:SetProfile(charKey)
    end

    LM_OptionsDB = nil
    LM_GlobalOptionsDB = nil
end

function LM_Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)
    self:ConvertToAce()
end

function LM_Options:UseGlobal(trueFalse)
    if trueFalse ~= nil then
        if trueFalse then
            LM_Debug("Setting profile to Default")
            self.db:SetProfile("Default")
        else
            LM_Debug("Setting profile to " .. charKey)
            self.db:SetProfile(charKey)
        end
    end

    return (self.db:GetCurrentProfile() == "Default")
end


--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    return self.db.profile.excludedSpells[m:SpellID()]
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m:SpellName(), m:SpellID()))
    self.db.profile.excludedSpells[m:SpellID()] = true
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m:SpellName(), m:SpellID()))
    self.db.profile.excludedSpells[m:SpellID()] = false
end

function LM_Options:ToggleExcludedMount(m)
    LM_Debug(format("Toggling mount %s (%d).", m:SpellName(), m:SpellID()))
    local id = m:SpellID()
    self.db.profile.excludedSpells[id] = not self.db.profile.excludedSpells[id]
end

function LM_Options:ResetExcludedMounts()
    LM_Debug("Clearing complete list of disabled mounts.")
    for k in pairs(self.db.profile.excludedSpells) do
        self.db.profile.excludedSpells[k] = false
    end
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)
    local flags = m:Flags()
    local ov = self.db.profile.flagChanges[m:SpellID()]

    for b, plusMinus in pairs(ov or {}) do
        if plusMinus == '+' then
            flags = bit.bor(flags, flagList[b])
        else
            flags = bit.band(flags, bit.bnot(flagList[b]))
        end
    end
    return flags
end

function LM_Options:SetMountFlagBit(m, flagbit)
    local id = m:SpellID()
    local name = m:SpellName()

    LM_Debug(format("Setting flag bit %d for spell %s (%d).",
                    flagbit, name, id))

    LM_Options:SetMountFlags(m, bit.bor(m:CurrentFlags(), flagbit))
end

function LM_Options:ClearMountFlagBit(m, flagbit)
    local id = m:SpellID()
    local name = m:SpellName()
    LM_Debug(format("Clearing flag bit %d for spell %s (%d).",
                     flagbit, name, id))

    LM_Options:SetMountFlags(m, bit.band(m:CurrentFlags(), bit.bnot(flagbit)))
end

function LM_Options:ResetMountFlags(m)
    LM_Debug(format("Defaulting flags for spell %s (%d).", m:Name(), m:SpellID()))
    self.db.profile.flagChanges[m:SpellID()] = nil
end

function LM_Options:SetMountFlags(m, flags)

    if flags == m:Flags() then
        self:ResetMountFlags(m)
        return
    end

    local id = m:SpellID()
    local def = m:Flags()

    local toSet = bit.band(bit.bxor(flags, def), flags)
    local toClear = bit.band(bit.bxor(flags, def), bit.bnot(flags))

    self.db.profile.flagChanges[id] = flagConvert(toSet, toClear)
end


--[[----------------------------------------------------------------------------
    Last resort / combat macro stuff
----------------------------------------------------------------------------]]--

function LM_Options:UseMacro()
    return (self.db.char.unvailableMacro ~= "")
end

function LM_Options:GetMacro()
    return self.db.char.unvailableMacro
end

function LM_Options:SetMacro(text)
    LM_Debug("Setting custom macro: " .. tostring(text))
    self.db.char.unavailableMacro = text
end

function LM_Options:UseCombatMacro(trueFalse)
    if trueFalse == true or trueFalse == 1 or trueFalse == "on" then
        LM_Debug("Enabling custom combat macro.")
        self.db.char.useCombatMacro = true
    elseif trueFalse == false or trueFalse == 0 or trueFalse == "off" then
        LM_Debug("Disabling custom combat macro.")
        self.db.char.useCombatMacro = false
    end

    return self.db.char.useCombatMacro
end

function LM_Options:GetCombatMacro()
    return self.db.char.combatMacro
end

function LM_Options:SetCombatMacro(text)
    LM_Debug("Setting custom combat macro: " .. tostring(text))
    self.db.char.combatMacro = text
end


--[[----------------------------------------------------------------------------
    Copying Target's Mount 
----------------------------------------------------------------------------]]--

function LM_Options:CopyTargetsMount(v)
    if v ~= nil then
        LM_Debug("Setting copy targets mount: " .. tostring(v))
        self.db.profile.copyTargetsMount = v
    end
    return self.db.profile.copyTargetsMount
end


--[[----------------------------------------------------------------------------
    Exclude newly learned mounts
----------------------------------------------------------------------------]]--

function LM_Options:ExcludeNewMounts(v)
    if v ~= nil then
        LM_Debug("Setting exclude new mounts: " .. tostring(v))
        self.db.profile.excludeNewMounts = v
    end
    return self.db.profile.excludeNewMounts
end


--[[----------------------------------------------------------------------------
    Have we seen a mount before on this toon?
    Includes automatically adding it to the excludes if requested.
----------------------------------------------------------------------------]]--

function LM_Options:SeenMount(m, flagSeen)
    local spellID = m:SpellID()

    local new = (self.db.profile.excludedSpells[spellID] == nil)

    if new and flagSeen then
        self.db.profile.excludedSpells[spellID] = self.db.profile.excludeNewMounts
    end

    return seen
end
