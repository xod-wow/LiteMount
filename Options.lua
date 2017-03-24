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

flagoverrides is a table of sets of flags to set and clear.
    ["flagoverrides"] = {
        ["spellid"] = { {flags_to_set}, {flags_to_clear} },
        ...
    }
The reason to do it this way instead of just storing the new flags is that
the default flags might change and we don't want the override to suddenly
go from disabling something to enabling it.

----------------------------------------------------------------------------]]--

-- All of these values must be arrays so we can copy them by reference.
local Default_LM_OptionsDB = {
    ["seenspells"]              = { },
    ["excludedspells"]          = { },
    ["flagoverrides"]           = { },
    ["macro"]                   = { },      -- [1] = macro
    ["combatMacro"]             = { },      -- [1] = macro, [2] == 0/1 enabled
    ["useglobal"]               = { },      -- "mounts", "actions"
    ["excludeNewMounts"]        = { },
    ["copyTargetsMount"]        = { 1 },
    ["actionLists"]             = { },
    ["actionListBindings"]      = { },
}

LM_Options = { }

local UpgradeFlagMap = {
    [LM_FLAG.RUN] = 1,
    [LM_FLAG.FLY] = 2,
    [LM_FLAG.FLOAT] = 4,
    [LM_FLAG.SWIM] = 8,
    [LM_FLAG.JUMP] = 16,
    [LM_FLAG.WALK] = 32,
    [LM_FLAG.AQ] = 128,
    [LM_FLAG.VASHJIR] = 256,
    [LM_FLAG.NAGRAND] = 512,
    [LM_FLAG.CUSTOM1] = 1024,
    [LM_FLAG.CUSTOM2] = 2048,
}

local function VersionUpgradeOptions(db)

    -- This is a special case because I made a mistake setting this as
    -- a global option to begin with.

    if not db["useglobal"] and LM_UseGlobalOptions then
        db["useglobal"] = { ["mounts"] = true }
    end

    -- Changed this into a key array around 7.0.3
    if db["useglobal"][1] ~= nil then
        db["useglobal"] = { ["mounts"] = db["useglobal"][1] }
        db["useglobal"][1] = nil
    end

    -- Flag used to be a bitmap, now just a set
    for k,v in pairs(db.flagoverrides) do
        local addBits, delBits = v[1], v[2]
        v[1], v[2] = { }, { }
        for n, b in pairs(UpgradeFlagMap) do
            if bit.band(addBits, b) then v[1][n] = true end
            if bit.band(delBits, b) then v[2][n] = true end
        end
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

    if self.db["useglobal"]["mounts"] then
        self.db["excludedspells"] = LM_GlobalOptionsDB.excludedspells
        self.db["flagoverrides"] = LM_GlobalOptionsDB.flagoverrides
    end

end

function LM_Options:UseGlobal(which, trueFalse)

    if trueFalse ~= nil then
        if trueFalse then trueFalse = true else trueFalse = false end
    end

    if which == "mounts" then
        if trueFalse ~= nil then
            if trueFalse then
                self.db["useglobal"]["mounts"] = true
                self.db["excludedspells"] = LM_GlobalOptionsDB.excludedspells
                self.db["flagoverrides"] = LM_GlobalOptionsDB.flagoverrides
            else
                self.db["useglobal"]["mounts"] = false
                self.db["excludedspells"] = LM_OptionsDB.excludedspells
                self.db["flagoverrides"] = LM_OptionsDB.flagoverrides
            end
        end
        return self.db["useglobal"]["mounts"]
    end

    if which == "actions" then
        if trueFalse ~= nil then
            self.db["useglobal"]["actions"] = trueFalse
        end
        return self.db["useglobal"]["actions"]
    end

    return false
end


--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    for _,s in ipairs(self.db.excludedspells) do
        if s == m.spellID then return true end
    end
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m.name, m.spellID))
    if not self:IsExcludedMount(m) then
        tinsert(self.db.excludedspells, m.spellID)
        sort(self.db.excludedspells)
    end
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m.name, m.spellID))
    for i = 1, #self.db.excludedspells do
        if self.db.excludedspells[i] == m.spellID then
            tremove(self.db.excludedspells, i)
            return
        end
    end
end

function LM_Options:ToggleExcludedMount(m)
    LM_Debug(format("Toggling mount %s (%d).", m.name, m.spellID))
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
        tinsert(self.db.excludedspells, m.spellID)
    end
    sort(self.db.excludedspells)
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)
    local ov = self.db.flagoverrides[m.spellID] or { }

    local flags = CopyTable(m.flags)

    for f in pairs(ov[1] or { }) do flags[f] = true end
    for f in pairs(ov[2] or { }) do flags[f] = nil end

    return flags
end

function LM_Options:SetMountFlag(m, flag)
    if not self.db.flagoverrides[m.spellID] then
        self.db.flagoverrides[m.spellID] = { { }, { } }
    end
        
    self.db.flagoverrides[m.spellID][1][flag] = m.flags[flag]
    self.db.flagoverrides[m.spellID][2][flag] = nil
end

function LM_Options:ClearMountFlag(m, flag)
    if not self.db.flagoverrides[m.spellID] then
        self.db.flagoverrides[m.spellID] = { { }, { } }
    end

    self.db.flagoverrides[m.spellID][1][flag] = nil
    self.db.flagoverrides[m.spellID][2][flag] = m.flags[flag]
end

function LM_Options:ResetMountFlags(m)
    self.db.flagoverrides[m.spellID] = { {}, {} }
end


--[[----------------------------------------------------------------------------
    Last resort / combat macro stuff
----------------------------------------------------------------------------]]--

function LM_Options:UseMacro()
    return self.db.macro[1] ~= nil and self.db.macro[1] ~= ""
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
    local spellID = m.spellID
    local seen = self.db.seenspells[spellID]

    if flagSeen and not seen then
        self.db.seenspells[spellID] = true
        if self.db.excludeNewMounts[1] == true then
            self:AddExcludedMount(m)
        end
    end

    return seen
end

--[[----------------------------------------------------------------------------
    Action Lists
----------------------------------------------------------------------------]]--

function LM_Options:ActionLists()
    return self.db.actionLists
end

function LM_Options:ActionList(name, text)
    if text ~= nil then
        self.db.actionLists[name] = text
    end
    return self.db.actionLists[name]
end

function LM_Options:ActionListBinding(i, name)

end

