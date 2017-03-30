--[[----------------------------------------------------------------------------

  LiteMount/OptionsDB.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--[[----------------------------------------------------------------------------

excludedSpells is a list of spell ids the player has seen and a true/false
flag for whether they are disabled or not.

    ["excludedSpells"] = { [spellid1] = true, [spellid2] = true, ... }

flagChanges is a table of sets of flags to set or clear.

    ["flagChanges"] = {
        [spellid1] = { [flag] = '+' or '-', ... },
        ...
    }

----------------------------------------------------------------------------]]--

-- All of these values must be arrays so we can copy them by reference.
local defaults = {
    profile = {
        excludedSpells              = { },
        flagChanges                 = { },
    },
    char = {
        unavailableMacro            = "",
        combatMacro                 = "",
        useCombatMacro              = false,
    },
    global = {
        copyTargetsMount            = true,
        excludeNewMounts            = false,
    }
}

LM_Options = { }

function LM_Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)
end

--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    return (self.db.profile.excludedSpells[m.spellID] == true)
end

function LM_Options:ExcludeMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = true
end

function LM_Options:IncludeMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = false
end

function LM_Options:ToggleExcludedMount(m)
    LM_Debug(format("Toggling mount %s (%d).", m.name, m.spellID))
    if self:IsExcludedMount(m) then
        self:IncludeMount(m)
    else
        self:ExcludeMount(m)
    end
end

function LM_Options:SetExcludedMounts(mountlist)
    LM_Debug("Setting complete list of disabled mounts.")
    wipe(self.db.profile.excludedSpells)
    for _,m in ipairs(mountlist) do
        self.db.profile.excludedSpells[m.spellID] = true
    end
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)
    local flags = CopyTable(m.flags)

    local ov = self.db.profile.flagChanges[m.spellID]

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
    local ov = self.db.profile.flagChanges
    ov[m.spellID] = ov[m.spellID] or { }
    if m.flags[flag] then
        ov[m.spellID][flag] = nil
    else
        ov[m.spellID][flag] = '+'
    end
end

function LM_Options:ClearMountFlag(m, flag)
    local ov = self.db.profile.flagChanges
    ov[m.spellID] = ov[m.spellID] or { }
    if not m.flags[flag] then
        ov[m.spellID][flag] = nil
    else
        ov[m.spellID][flag] = '-'
    end
end

function LM_Options:ResetMountFlags(m)
    self.db.profile.flagChanges[m.spellID] = nil
end


--[[----------------------------------------------------------------------------
    Last resort / combat macro stuff
----------------------------------------------------------------------------]]--

function LM_Options:GetMacro()
    return self.db.char.unavailableMacro
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
        LM_Debug(format("Setting copy targets mount: %s", tostring(v)))
        self.db.global.copyTargetsMount = v
    end
    return self.db.global.copyTargetsMount
end


--[[----------------------------------------------------------------------------
    Exclude newly learned mounts
----------------------------------------------------------------------------]]--

function LM_Options:ExcludeNewMounts(v)
    if v ~= nil then
        LM_Debug(format("Setting exclude new mounts: %s", tostring(v)))
        self.db.global.excludeNewMounts = v
    end
    return self.db.global.excludeNewMounts
end


--[[----------------------------------------------------------------------------
    Have we seen a mount before?
    Includes automatically adding it to the excludes if requested.
----------------------------------------------------------------------------]]--

function LM_Options:IsNewMount(m)
    local new = (self.db.profile.excludedSpells[m.spellID] == nil)

    if new then
        if self:ExcludeNewMounts() then
            self:ExcludeMount(m)
        else
            self:IncludeMount(m)
        end
    end
    return new
end

