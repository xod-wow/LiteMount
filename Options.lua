--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2016 Mike Battersby

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

-- You can't have these be nil or they will always be deleted by the cleaner
local Default_LM_OptionsDB = {
    ["excludedSpells"]      = { },
    ["flagChanges"]         = { },
    ["unavailableMacro"]    = "",
    ["useUnavailableMacro"] = false,
    ["combatMacro"]         = "",
    ["useCombatMacro"]      = false,
    ["useGlobal"]           = false,
    ["excludeNewMounts"]    = false,
    ["copyTargetsMount"]    = true,
}

LM_Options = { }

local function FlagConvert(toSet, toClear)
    local changes = { }

    for flagName,flagBit in pairs(LM_FLAG) do
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

local function VersionUpgradeOptions(db)

    -- Add any default settings from Default_LM_OptionsDB we don't have yet
    for k,v in pairs(Default_LM_OptionsDB) do
        if not db[k] then
            db[k] = CopyTable({ v })[1]
        end
    end

    -- Convert the old flagoverrides set/clear pairs to flag table
    if db.flagoverrides then
        for spellID, bitChanges in pairs(db.flagoverrides) do
            db.flagChanges[spellID] = FlagConvert(unpack(bitChanges))
        end
    end

    -- seenspells and excludedspells folded into tristate excludedSpells
    -- (note the capital S in the second case)
    if db.seenspells then
        for id in pairs(db.seenspells) do
            if db.excludedSpells[id] == nil then
                db.excludedSpells[id] = tContains(db.excludedspells or {}, id)
            end
        end
    end

    if type(db.excludeNewMounts) == "table" then
        db.excludeNewMounts = (db.excludeNewMounts[1] ~= nil)
    end

    if type(db.copyTargetsMount) == "table" then
        db.copyTargetsMount = (db.copyTargetsMount[1] ~= nil)
    end

    if type(db.macro) == "table" then
        db.unavailableMacro = db.macro[1]
        db.useUnavailableMacro = (db.macro[1] ~= "")
    end

    if type(db.combatMacro) == "table" then
        db.useCombatMacro = (db.combatMacro[2] == 1)
        db.combatMacro = db.combatMacro[1]
    end

    if db.useglobal then
        db.useGlobal = (db.useglobal[1] ~= nil)
    end

    -- LoadAddOn("Blizzard_DebugTools")
    -- DevTools_Dump(db)

    -- Delete any obsolete settings we have that aren't in Default_LM_OptionsDB
    for k,v in pairs(db) do
        if Default_LM_OptionsDB[k] == nil then
            db[k] = nil
        end
    end
end

function LM_Options:Initialize()

    if not LM_OptionsDB then
        LM_OptionsDB = Default_LM_OptionsDB
    end

    if not LM_GlobalOptionsDB then
        LM_GlobalOptionsDB = Default_LM_OptionsDB
    end

    VersionUpgradeOptions(LM_OptionsDB)
    VersionUpgradeOptions(LM_GlobalOptionsDB)

    -- The annoyance with this is that we don't want global macros, only
    -- global mount excludes and flags.

    self.db = LM_OptionsDB

    if self.db.useGlobal then
        self.excludedSpells = LM_GlobalOptionsDB.excludedSpells
        self.flagChanges = LM_GlobalOptionsDB.flagChanges
    else
        self.excludedSpells = LM_OptionsDB.excludedSpells
        self.flagChanges = LM_OptionsDB.flagChanges
    end

end

function LM_Options:UseGlobal(trueFalse)

    if trueFalse ~= nil then
        if trueFalse then
            self.db.useGlobal = true
            self.excludedSpells = LM_GlobalOptionsDB.excludedSpells
            self.flagChanges = LM_GlobalOptionsDB.flagChanges
        else
            self.db.useGlobal = false
            self.excludedSpells = LM_OptionsDB.excludedSpells
            self.flagChanges = LM_OptionsDB.flagChanges
        end
    end

    return (self.db.useGlobal == true)
end


--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    return self.excludedSpells[m:SpellID()]
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m:SpellName(), m:SpellID()))
    self.excludedSpells[m:SpellID()] = true
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m:SpellName(), m:SpellID()))
    self.excludedSpells[m:SpellID()] = false
end

function LM_Options:ToggleExcludedMount(m)
    local id = m:SpellID()
    LM_Debug(format("Toggling mount %s (%d).", m:SpellName(), id))
    self.excludedSpells[id] = not self.excludedSpells[id]
end

function LM_Options:SetExcludedMounts(mountlist)
    LM_Debug("Setting complete list of disabled mounts.")
    for k in pairs(self.excludedSpells) do
        self.excludedSpells[k] = false
    end
    for _,m in ipairs(mountlist) do
        self:AddExcludedMount(m)
    end
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)
    local id = m:SpellID()
    local flags = m:Flags()
    local changes = self.flagChanges[id] or { }

    for flagName,flagBit in pairs(LM_FLAG) do
        if changes[flagName] == '+' then
            flags = bit.bor(flags, LM_FLAG[flagName])
        elseif changes[flagName] == '-' then
            flags = bit.band(flags, bit.bnot(LM_FLAG[flagName]))
        end
    end

    return flags
end

function LM_Options:SetMountFlagBit(m, setBit)
    local id = m:SpellID()
    local name = m:SpellName()

    LM_Debug(format("Setting flag bit %d for spell %s (%d).",
                    setBit, name, id))

    LM_Options:SetMountFlags(m, bit.bor(m:CurrentFlags(), setBit))
end

function LM_Options:ClearMountFlagBit(m, clearBit)
    local id = m:SpellID()
    local name = m:SpellName()
    LM_Debug(format("Clearing flag bit %d for spell %s (%d).",
                     clearBit, name, id))

    LM_Options:SetMountFlags(m, bit.band(m:CurrentFlags(), bit.bnot(clearBit)))
end

function LM_Options:ResetMountFlags(m)
    local id = m:SpellID()
    local name = m:SpellName()

    LM_Debug(format("Defaulting flags for spell %s (%d).", name, id))

    self.flagChanges[id] = nil
end

function LM_Options:SetMountFlags(m, flags)

    if flags == m:Flags() then
        return self:ResetMountFlags(m)
    end

    local id = m:SpellID()
    local def = m:Flags()

    local toSet = bit.band(bit.bxor(flags, def), flags)
    local toClear = bit.band(bit.bxor(flags, def), bit.bnot(flags))

    self.flagChanges[id] = FlagConvert(toSet, toClear)
end


--[[----------------------------------------------------------------------------
    Last resort / combat macro stuff
----------------------------------------------------------------------------]]--

function LM_Options:UseMacro()
    return self.db.useUnavailableMacro
end

function LM_Options:GetMacro()
    return self.db.unavailableMacro
end

function LM_Options:SetMacro(text)
    LM_Debug("Setting unavailable macro: " .. tostring(text))
    self.db.unavailableMacro = text
    self.db.useUnavailableMacro = (text ~= "")
end

function LM_Options:UseCombatMacro(trueFalse)
    if trueFalse == true or trueFalse == 1 or trueFalse == "on" then
        LM_Debug("Enabling custom combat macro.")
        self.db.useCombatMacro = true
    elseif trueFalse == false or trueFalse == 0 or trueFalse == "off" then
        LM_Debug("Disabling custom combat macro.")
        self.db.useCombatMacro = false
    end

    return self.db.useCombatMacro
end

function LM_Options:GetCombatMacro()
    return self.db.combatMacro
end

function LM_Options:SetCombatMacro(text)
    LM_Debug("Setting custom combat macro: " .. tostring(text))
    self.db.combatMacro = text
end


--[[----------------------------------------------------------------------------
    Copying Target's Mount 
----------------------------------------------------------------------------]]--

function LM_Options:CopyTargetsMount(v)
    if v ~= nil then
        LM_Debug(format("Setting copy targets mount: %s", tostring(v)))
        self.db.copyTargetsMount = v
    end
    return self.db.copyTargetsMount
end


--[[----------------------------------------------------------------------------
    Exclude newly learned mounts
----------------------------------------------------------------------------]]--

function LM_Options:ExcludeNewMounts(v)
    if v ~= nil then
        LM_Debug(format("Setting exclude new mounts: %s", tostring(v)))
        self.db.excludeNewMounts = v
    end
    return self.db.excludeNewMounts
end


--[[----------------------------------------------------------------------------
    Have we seen a mount before on this toon?
    Includes automatically adding it to the excludes if requested.
----------------------------------------------------------------------------]]--

function LM_Options:SeenMount(m, flagSeen)
    local spellID = m:SpellID()
    local seen = (self.excludedSpells[spellID] ~= nil)

    if flagSeen and not seen then
        self.excludedSpells[spellID] = (self.db.excludeNewMounts[1] and true) or false
    end

    return seen
end
