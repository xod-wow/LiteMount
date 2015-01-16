--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

--[[----------------------------------------------------------------------------

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
go from disabling somthing to enabling it.

----------------------------------------------------------------------------]]--

-- All of these values must be arrays so we can copy them by reference.
local Default_LM_OptionsDB = {
    ["excludedspells"]   = { },
    ["flagoverrides"]    = { },
    ["macro"]            = { },       -- [1] = macro
    ["combatMacro"]      = { },       -- [1] = macro, [2] == 0/1 enabled
    ["useglobal"]        = { },
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

function LM_Options:UseGlobal()
    if self.db["useglobal"][1] then
        return true
    else
        return nil
    end
end

function LM_Options:SetGlobal(onoff)

    self.db["useglobal"][1] = onoff

    if onoff then
        self.db["excludedspells"] = LM_GlobalOptionsDB.excludedspells
        self.db["flagoverrides"] = LM_GlobalOptionsDB.flagoverrides
    else
        self.db["excludedspells"] = LM_OptionsDB.excludedspells
        self.db["flagoverrides"] = LM_OptionsDB.flagoverrides
    end

end


--[[----------------------------------------------------------------------------
     Excluded Spell stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedSpell(id)
    for _,s in ipairs(self.db.excludedspells) do
        if s == id then return true end
    end
end

function LM_Options:AddExcludedSpell(id)
    LM_Debug(format("Disabling mount %s (%d).", GetSpellInfo(id), id))
    if not self:IsExcludedSpell(id) then
        tinsert(self.db.excludedspells, id)
        sort(self.db.excludedspells)
    end
end

function LM_Options:RemoveExcludedSpell(id)
    LM_Debug(format("Enabling mount %s (%d).", GetSpellInfo(id), id))
    for i = 1, #self.db.excludedspells do
        if self.db.excludedspells[i] == id then
            tremove(self.db.excludedspells, i)
            return
        end
    end
end

function LM_Options:SetExcludedSpells(idlist)
    LM_Debug("Setting complete list of disabled mounts.")
    wipe(self.db.excludedspells)
    for _,id in ipairs(idlist) do
        tinsert(self.db.excludedspells, id)
    end
    sort(self.db.excludedspells)
end

--[[----------------------------------------------------------------------------
     Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplySpellFlags(id, flags)
    local ov = self.db.flagoverrides[id]

    if not ov then return flags end

    flags = bit.bor(flags, ov[1])
    flags = bit.band(flags, bit.bnot(ov[2]))

    return flags
end

function LM_Options:SetSpellFlagBit(id, origflags, flagbit)
    LM_Debug(format("Setting flag bit %d for spell %s (%d).",
                    flagbit, GetSpellInfo(id), id))

    local newflags = self:ApplySpellFlags(id, origflags)
    newflags = bit.bor(newflags, flagbit)
    LM_Options:SetSpellFlags(id, origflags, newflags)
end

function LM_Options:ClearSpellFlagBit(id, origflags, flagbit)
    LM_Debug(format("Clearing flag bit %d for spell %s (%d).",
                     flagbit, GetSpellInfo(id), id))

    local newflags = self:ApplySpellFlags(id, origflags)
    newflags = bit.band(newflags, bit.bnot(flagbit))
    LM_Options:SetSpellFlags(id, origflags, newflags)
end

function LM_Options:ResetSpellFlags(id)
    LM_Debug(format("Defaulting flags for spell %s (%d).",
                    GetSpellInfo(id), id))

    self.db.flagoverrides[id] = nil
end

function LM_Options:SetSpellFlags(id, origflags, newflags)

    if origflags == newflags then
        self:ResetSpellFlags(id)
        return
    end

    if not self.db.flagoverrides[id] then
        self.db.flagoverrides[id] = { 0, 0 }
    end

    local toset = bit.band(bit.bxor(origflags, newflags), newflags)
    local toclear = bit.band(bit.bxor(origflags, newflags), bit.bnot(newflags))

    self.db.flagoverrides[id][1] = toset
    self.db.flagoverrides[id][2] = toclear
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

function LM_Options:UseCombatMacro()
    return self.db.combatMacro[2] ~= nil
end

function LM_Options:GetCombatMacro()
    return self.db.combatMacro[1]
end

function LM_Options:SetCombatMacro(text)
    LM_Debug("Setting custom combat macro: " .. (text or "nil"))
    self.db.combatMacro[1] = text
end

function LM_Options:EnableCombatMacro()
    LM_Debug("Enabling custom combat macro.")
    self.db.combatMacro[2] = 1
end

function LM_Options:DisableCombatMacro()
    LM_Debug("Disabling custom combat macro.")
    self.db.combatMacro[2] = nil
end


--[[----------------------------------------------------------------------------
     Copying Target's Mount 
----------------------------------------------------------------------------]]--

function LM_Options:CopyTargetsMount()
    return self.db.copyTargetsMount[1]
end

function LM_Options:SetCopyTargetsMount(v)
    self.db.copyTargetsMount[1] = v
end
