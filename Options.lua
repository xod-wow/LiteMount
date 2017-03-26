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

flagChanges is a table of sets of flags to set or clear.
    ["flagChanges"] = {
        ["spellid"] = { [flag] = '+' or '-', ... },
        ...
    }

----------------------------------------------------------------------------]]--

-- All of these values must be arrays so we can copy them by reference.
local Default_LM_OptionsDB = {
    ["seenspells"]              = { },
    ["excludedspells"]          = { },
    ["flagChanges"]             = { },
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

    -- Add any default settings from Default_LM_OptionsDB we don't have yet
    for k,v in pairs(Default_LM_OptionsDB) do
        db[k] = db[k] or v
    end

    -- Changed this into a key array around 7.0.3
    if db["useglobal"][1] ~= nil then
        db["useglobal"] = { ["mounts"] = db["useglobal"][1] }
        db["useglobal"][1] = nil
    end

    -- Flag used to be a bitmap, now just a set
    for spell,v in pairs(db.flagoverrides or {}) do
        local addBits, delBits = v[1], v[2]

        db.flagChanges[spell]= { }

        for n, b in pairs(UpgradeFlagMap) do
            if bit.band(addBits, b) then db.flagChanges[spell][n] = '+' end
            if bit.band(delBits, b) then db.flagChanges[spell][n] = '-' end
        end
    end

    db.flagoverrides = nil

    -- Delete any obsolete settings we have that aren't in Default_LM_OptionsDB
    for k,v in pairs(db) do
        if not Default_LM_OptionsDB[k] then
            db[k] = nil
        end
    end

end

function LM_Options:Initialize()

    if not LM_OptionsDB then
        LM_OptionsDB = CopyTable(Default_LM_OptionsDB)
    end

    if not LM_GlobalOptionsDB then
        LM_GlobalOptionsDB = CopyTable(Default_LM_OptionsDB)
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
        self.db["flagChanges"] = LM_GlobalOptionsDB.flagChanges
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
                self.db["flagChanges"] = LM_GlobalOptionsDB.flagChanges
            else
                self.db["useglobal"]["mounts"] = false
                self.db["excludedspells"] = LM_OptionsDB.excludedspells
                self.db["flagChanges"] = LM_OptionsDB.flagChanges
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
    local flags = CopyTable(m.flags)

    local ov = self.db.flagChanges[m.spellID]

    for f,action in pairs(ov or {}) do
        if action == '+' then
            flags[f] = true
        elseif action == '-' then
            flags[f] = nil
        end
    end
    return flags
end

function LM_Options:SetMountFlag(m, flag)
    local ov = self.db.flagChanges
    ov[m.spellID] = ov[m.spellID] or { }
    if m.flags[flag] then
        ov[m.spellID][flag] = nil
    else
        ov[m.spellID][flag] = '+'
    end
end

function LM_Options:ClearMountFlag(m, flag)
    local ov = self.db.flagChanges
    ov[m.spellID] = ov[m.spellID] or { }
    if not m.flags[flag] then
        ov[m.spellID][flag] = nil
    else
        ov[m.spellID][flag] = '-'
    end
end

function LM_Options:ResetMountFlags(m)
    self.db.flagChanges[m.spellID] = { }
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

