--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--[[----------------------------------------------------------------------------

excludedSpells is a table of spell ids the player has seen before, with
the value true if excluded and false if not excluded

flagChanges is a table of spellIDs with flags to set (+) and clear (-).
    ["flagChanges"] = {
        ["spellid"] = { flag = '+', otherflag = '-', ... },
        ...
    }

----------------------------------------------------------------------------]]--

local defaults = {
    profile = {
        excludedSpells      = { },
        flagChanges         = { },
        buttonActions       = { },
        excludeNewMounts    = false,
    },
    char = {
        unavailableMacro    = "",
        useUnavailableMacro = false,
        combatMacro         = "",
        useCombatMacro      = false,
        copyTargetsMount    = true,
        -- If changed these are not preserved because nil becomes defaults
        uiMountFilterList   = { NOT_COLLECTED = true, UNUSABLE = true },
        debugEnabled        = false,
    },
}

LM_Options = { }

local function tMerge(...)
    local result = { }

    for i = 1, select("#", ...) do
        local src = select(i, ...);
        for k, v in pairs(src) do
            result[k] = v;
        end
    end

    return result
end

local function FlagDiff(a, b)
    local diff = { }

    for flagName in pairs(LM_FLAG) do
        if tContains(a, flagName) and not tContains(b, flagName) then
            diff[flagName] = '-'
        elseif not tContains(a, flagName) and tContains(b, flagName) then
            diff[flagName] = '+'
        end
    end

    if next(diff) == nil then
        return nil
    end

    return diff
end

local OldFlagBits = {
    RUN = 1, FLY = 2, FLOAT = 4, SWIM = 8,
    WALK = 32, AQ = 128, VASHJIR = 256,
    NAGRAND = 512, CUSTOM1 = 1024, CUSTOM2 = 2048,
}

local function BitFlagMigrate(toSet, toClear)
    local changes = { }

    for flagName,flagBit in pairs(OldFlagBits) do
        if bit.band(toSet, flagBit) == flagBit then
            changes[flagName] = '+'
        elseif bit.band(toClear, flagBit) == flagBit then
            changes[flagName] = '-'
        end
    end

    if next(changes) == nil then
        return nil
    end

    return changes
end

local function PreAceDBFinalMigrate(db)

    -- "new" options
    db.excludedSpells = db.excludedSpells or { }
    db.flagChanges = db.flagChanges or { }

    -- Convert the old flagoverrides set/clear pairs to flag table
    if db.flagoverrides then
        for spellID, bitChanges in pairs(db.flagoverrides) do
            db.flagChanges[spellID] = BitFlagMigrate(unpack(bitChanges))
        end
        db.flagoverrides = nil
    end

    -- seenspells and excludedspells folded into tristate excludedSpells
    -- (note the capital S in the second case)
    if db.seenspells then
        for id in pairs(db.seenspells) do
            if db.excludedSpells[id] == nil then
                if tContains(db.excludedspells or {}, id) then
                    db.excludedSpells[id] = true
                else
                    db.excludedSpells[id] = false
                end
            end
        end
        db.seenspells = nil
    end

    if type(db.excludeNewMounts) == "table" then
        db.excludeNewMounts = (not not db.excludeNewMounts[1])
    end

    if type(db.copyTargetsMount) == "table" then
        db.copyTargetsMount = (not not db.copyTargetsMount[1])
    end

    if type(db.macro) == "table" then
        db.unavailableMacro = db.macro[1]
        db.useUnavailableMacro = (db.macro[1] ~= "" and db.macro[1] ~= nil)
        db.macro = nil
    end

    if type(db.combatMacro) == "table" then
        db.useCombatMacro = (db.combatMacro[2] == 1)
        db.combatMacro = db.combatMacro[1]
    end

    if db.useglobal then
        db.useGlobal = (not not db.useglobal[1])
        db.useglobal = nil
    end
end

function LM_Options:VersionUpgrade()

    if LM_OptionsDB then
        local db = LM_OptionsDB
        if not db.flagChanges then
            PreAceDBFinalMigrate(db)
        end
        self.db.char.unavailableMacro = db.unavailableMacro
        self.db.char.useUnvailableMacro = db.useUnvailableMacro
        self.db.char.combatMacro = db.combatMacro
        self.db.char.useCombatMacro = db.useCombatMacro
        self.db.char.copyTargetsMount = db.copyTargetsMount
        self.db.char.uiMountFilterList = CopyTable(db.uiMountFilterList or {})

        -- Lacking any better idea we make a profile named for .char
        local charKey = self.db.keys.char
        self.db:SetProfile(charKey)

        self.db.profile.excludedSpells = CopyTable(db.excludedSpells or {})
        self.db.profile.flagChanges = CopyTable(db.flagChanges or {})
        self.db.profile.excludeNewMounts = db.excludeNewMounts

        if db.useGlobal then
            self.db:SetProfile("Default")
        end
    end

    if LM_GlobalOptionsDB then
        local db = LM_GlobalOptionsDB
        if not db.flagChanges then
            PreAceDBFinalMigrate(db)
        end
        self.db.profiles.Default.excludedSpells = CopyTable(db.excludedSpells or {})
        self.db.profiles.Default.flagChanges = CopyTable(db.flagChanges or {})
        self.db.profiles.Default.excludeNewMounts = db.excludeNewMounts
    end

    LM_OptionsDB = nil
    LM_GlobalOptionsDB = nil
end

function LM_Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)
    self:VersionUpgrade()
end


--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    return self.db.profile.excludedSpells[m.spellID]
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = true
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = false
end

function LM_Options:ToggleExcludedMount(m)
    local id = m.spellID
    LM_Debug(format("Toggling mount %s (%d).", m.name, id))
    self.db.profile.excludedSpells[id] = not self.db.profile.excludedSpells[id]
end

function LM_Options:SetExcludedMounts(mountlist)
    LM_Debug("Setting complete list of disabled mounts.")
    for k in pairs(self.db.profile.excludedSpells) do
        self.db.profile.excludedSpells[k] = false
    end
    for _,m in ipairs(mountlist) do
        self:AddExcludedMount(m)
    end
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)

    local changes = self.db.profile.flagChanges[m.spellID]
    local flags = CopyTable(m.flags)

    if changes then
        for flagName in pairs(LM_FLAG) do
            if changes[flagName] == '+' then
                tinsert(flags, flagName)
            elseif changes[flagName] == '-' then
                tDeleteItem(flags, flagName)
            end
        end
    end

    return flags
end

function LM_Options:SetMountFlag(m, setFlag)
    LM_Debug(format("Setting flag %s for spell %s (%d).",
                    setFlag, m.name, m.spellID))
    local flags = m:CurrentFlags()
    tinsert(flags, setFlag)
    self:SetMountFlags(m, flags)
end

function LM_Options:ClearMountFlag(m, clearFlag)
    LM_Debug(format("Clearing flag %s for spell %s (%d).",
                     clearFlag, m.name, m.spellID))
    local flags = m:CurrentFlags()
    tDeleteItem(flags, clearFlag)
    self:SetMountFlags(m, flags)
end

function LM_Options:ResetMountFlags(m)
    LM_Debug(format("Defaulting flags for spell %s (%d).", m.name, m.spellID))
    self.db.profile.flagChanges[m.spellID] = nil
end

function LM_Options:SetMountFlags(m, flags)
    self.db.profile.flagChanges[m.spellID] = FlagDiff(m.flags, flags)
end


--[[----------------------------------------------------------------------------
    Have we seen a mount before on this toon?
    Includes automatically adding it to the excludes if requested.
----------------------------------------------------------------------------]]--

function LM_Options:SeenMount(m)
    local spellID = m.spellID

    if self.db.profile.excludedSpells[spellID] == nil then
        self.db.profile.excludedSpells[spellID] = self.db.profile.excludeNewMounts
    end

    return seen
end
