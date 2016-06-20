--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

--[[----------------------------------------------------------------------------

seenspells is an array of mount spells we've seen before, so we can tell if
we scan a new mount
    ["seenspells"] = { [spellid1] = true, [spellid2] = true, ... }

excludedspells is a list of spell ids the player has disabled
    ["excludedspells"] = { spellid1, spellid2, spellid3, ... }
  
flagoverrides is a table of tuples with bits to set and clear.
    ["flagoverrides"] = {
        ["spellid"] = { bits_to_set, bits_to_clear },
        ...
    }


The modified mount flags are then:
    ( flags | bits_to_set ) & !bits_to_clear

The reason to do it this way instead of just storing the xor is that
the default flags might change and we don't want the override to suddenly
go from disabling something to enabling it.

----------------------------------------------------------------------------]]--

-- All of these values must be arrays so we can copy them by reference.
local Default_LM_OptionsDB = {
    ["seenspells"]       = { },
    ["excludedspells"]   = { },
    ["flagoverrides"]    = { },
    ["macro"]            = { },       -- [1] = macro
    ["combatMacro"]      = { },       -- [1] = macro, [2] == 0/1 enabled
    ["useglobal"]        = { },
    ["excludeNewMounts"] = { },
    ["copyTargetsMount"] = { 1 },
}

LM_Options = { }

local function VersionUpgradeOptions(db)

    -- This is a special case because I made a mistake setting this as
    -- a global option to begin with.

    if not db["useglobal"] and LM_UseGlobalOptions then
        db["useglobal"] = { true }
    end

    -- Add any default settings from Default_LM_OptionsDB we don't have yet
    for k,v in pairs(Default_LM_OptionsDB) do
        if not db[k] then
            db[k] = v
        end
    end

    -- Delete any obsolete settings we have that aren't in Default_LM_OptionsDB
    for k,v in pairs(db) do
        if not Default_LM_OptionsDB[k] then
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

    self.db = { }
    for k,v in pairs(LM_OptionsDB) do
        self.db[k] = v
    end

    if self.db["useglobal"][1] then
        self.db["excludedspells"] = LM_GlobalOptionsDB.excludedspells
        self.db["flagoverrides"] = LM_GlobalOptionsDB.flagoverrides
    end

end

function LM_Options:UseGlobal(trueFalse)

    if trueFalse ~= nil then
        if trueFalse then
            self.db["useglobal"][1] = true
            self.db["excludedspells"] = LM_GlobalOptionsDB.excludedspells
            self.db["flagoverrides"] = LM_GlobalOptionsDB.flagoverrides
        else
            self.db["useglobal"][1] = false
            self.db["excludedspells"] = LM_OptionsDB.excludedspells
            self.db["flagoverrides"] = LM_OptionsDB.flagoverrides
        end
    end

    if self.db["useglobal"][1] then
        return true
    else
        return false
    end
end


--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    local id = m:SpellID()
    for _,s in ipairs(self.db.excludedspells) do
        if s == id then return true end
    end
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m:SpellName(), m:SpellID()))
    if not self:IsExcludedMount(m) then
        tinsert(self.db.excludedspells, m:SpellID())
        sort(self.db.excludedspells)
    end
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m:SpellName(), m:SpellID()))
    local id = m:SpellID()
    for i = 1, #self.db.excludedspells do
        if self.db.excludedspells[i] == id then
            tremove(self.db.excludedspells, i)
            return
        end
    end
end

function LM_Options:ToggleExcludedMount(m)
    LM_Debug(format("Toggling mount %s (%d).", m:SpellName(), m:SpellID()))
    if self:IsExcludedMount(m) then
        self:RemoveExcludedMount(m)
    else
        self:AddExcludedMount(m)
    end
end

function LM_Options:SetExcludedMounts(mountlist)
    LM_Debug("Setting complete list of disabled mounts.")
    wipe(self.db.excludedspells)
    for _,m in ipairs(mountlist) do
        tinsert(self.db.excludedspells, m:SpellID())
    end
    sort(self.db.excludedspells)
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)
    local id = m:SpellID()
    local flags = m:Flags()
    local ov = self.db.flagoverrides[id]

    if not ov then return flags end

    flags = bit.bor(flags, ov[1])
    flags = bit.band(flags, bit.bnot(ov[2]))

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
    local id = m:SpellID()
    local name = m:SpellName()

    LM_Debug(format("Defaulting flags for spell %s (%d).", name, id))

    self.db.flagoverrides[id] = nil
end

function LM_Options:SetMountFlags(m, flags)

    if flags == m:Flags() then
        return self:ResetMountFlags(m)
    end

    local id = m:SpellID()
    local def = m:Flags()

    local toset = bit.band(bit.bxor(flags, def), flags)
    local toclear = bit.band(bit.bxor(flags, def), bit.bnot(flags))

    self.db.flagoverrides[id] = { toset, toclear }
end


--[[----------------------------------------------------------------------------
    Last resort / combat macro stuff
----------------------------------------------------------------------------]]--

function LM_Options:UseMacro()
    return self.db.macro[1] ~= nil
end

function LM_Options:GetMacro()
    return self.db.macro[1]
end

function LM_Options:SetMacro(text)
    LM_Debug("Setting custom macro: " .. (text or "nil"))
    self.db.macro[1] = text
end

function LM_Options:UseCombatMacro(trueFalse)
    if trueFalse == true or trueFalse == 1 or trueFalse == "on" then
        LM_Debug("Enabling custom combat macro.")
        self.db.combatMacro[2] = 1
    elseif trueFalse == false or trueFalse == 0 or trueFalse == "off" then
        LM_Debug("Disabling custom combat macro.")
        self.db.combatMacro[2] = nil
    end

    return self.db.combatMacro[2] ~= nil
end

function LM_Options:GetCombatMacro()
    return self.db.combatMacro[1]
end

function LM_Options:SetCombatMacro(text)
    LM_Debug("Setting custom combat macro: " .. (text or "nil"))
    self.db.combatMacro[1] = text
end


--[[----------------------------------------------------------------------------
    Copying Target's Mount 
----------------------------------------------------------------------------]]--

function LM_Options:CopyTargetsMount(v)
    if v ~= nil then
        local vtext = (v and "true") or "false"
        LM_Debug(format("Setting copy targets mount: %s", vtext))
        self.db.copyTargetsMount[1] = v
    end
    return self.db.copyTargetsMount[1]
end


--[[----------------------------------------------------------------------------
    Exclude newly learned mounts
----------------------------------------------------------------------------]]--

function LM_Options:ExcludeNewMounts(v)
    if v ~= nil then
        local vtext = (v and "true") or "false"
        LM_Debug(format("Setting exclude new mounts: %s", vtext))
        self.db.excludeNewMounts[1] = v
    end
    return self.db.excludeNewMounts[1]
end


--[[----------------------------------------------------------------------------
    Have we seen a mount before on this toon?
    Includes automatically adding it to the excludes if requested.
----------------------------------------------------------------------------]]--

function LM_Options:SeenMount(m, flagSeen)
    local spellID = m:SpellID()
    local seen = self.db.seenspells[spellID]

    if flagSeen and not seen then
        self.db.seenspells[spellID] = true
        if self.db.excludeNewMounts[1] == true then
            self:AddExcludedMount(m)
        end
    end

    return seen
end
