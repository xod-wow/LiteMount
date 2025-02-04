--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local Serializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

--[[----------------------------------------------------------------------------

mountPriorities is a list of spell ids the player has seen before mapped to
the priority (0/1/2/3) of that mount. If the value is nil it means we haven't
seen that mount yet.

flagChanges is a table of spellIDs with flags to set (+) and clear (-).
    flagChanges = {
        ["spellid"] = { flag = '+', otherflag = '-', ... },
        ...
    }

groups is a table of group names, with mount spell IDs as members
    groups = {
        ["PASSENGER"] = { [123456] = true }
    }

----------------------------------------------------------------------------]]--

-- Don't use names here, it will break in other locales

local DefaultButtonAction = [[
LeaveVehicle
Dismount [nofalling]
CopyTargetsMount
ApplyRules
SwitchFlightStyle [mod:rshift]
IF [mod:shift]
    IF [drivable]
        Limit -DRIVE
    ELSEIF [submerged]
        Limit -SWIM
    ELSEIF [flyable]
        Limit -DRAGONRIDING/FLY
    ELSEIF [floating]
        Limit -SWIM
    END
END
SmartMount
IF [falling]
  # Slow Fall, Levitate, Zen Flight, Glide, Flap
  Spell 130, 1706, 125883, 131347, 164862
  # Hearty Dragon Plume, Rocfeather Skyhorn Kite
  Use 182729, 131811
  # Last resort dismount even if falling
  Dismount
END
Macro
]]

local DefaultRulesByProject = LM.TableWithDefault({
    DEFAULT = {
        -- AQ Battle Tanks in the raid instance
        "Mount [instance:531] mt:241",
    },
    [1] = { -- Retail
        -- Vash'jir Seahorse
        "Mount [map:203,submerged] mt:232",
        -- Flying swimming mounts in Nazjatar with Budding Deepcoral
        "Mount [map:1355,flyable,qfc:56766] mt:254",
        -- AQ Battle Tanks in the raid instance
        "Mount [instance:531] mt:241",
        -- Arcanist's Manasaber to disguise you in Suramar
        "Mount [extra:202477,nosubmerged] id:881",
        -- Rustbolt Resistor and Aerial Unit R-21/X avoid being shot down
        -- "Mount [map:1462,flyable] MECHAGON"
    },
})

local DefaultRules = DefaultRulesByProject[WOW_PROJECT_ID]

-- A lot of things need to be cleaned up when flags are deleted/renamed

local defaults = {
    global = {
        groups              = { },
        instances           = { },
        summonCounts        = { },
    },
    profile = {
        flagChanges         = { },
        mountPriorities     = { },
        buttonActions       = { ['*'] = DefaultButtonAction },
        groups              = { },
        rules               = { }, -- Note: tables as * don't work
        copyTargetsMount    = true,
        randomWeightStyle   = 'Priority',
        defaultPriority     = 1,
        priorityWeights     = { 1, 2, 6, 1 },
        randomKeepSeconds   = 0,
        instantOnlyMoving   = false,
        restoreForms        = false,
        announceViaChat     = false,
        announceViaUI       = false,
        announceColors      = false,
        announceFlightStyle = true,
    },
    char = {
        unavailableMacro    = "",
        useUnavailableMacro = false,
        combatMacro         = "",
        useCombatMacro      = false,
        debugEnabled        = false,
        uiDebugEnabled      = false,
    },
}

LM.Options = {
    MIN_PRIORITY = 0,
    MAX_PRIORITY = 4,
    DISABLED_PRIORITY = 0,
    DEFAULT_PRIORITY = 1,
    ALWAYS_PRIORITY = 4,
}

-- Note to self. In any profile except the active one, the defaults are not
-- applied and you can't rely on them being there. This is super annoying.
-- Any time you loop over the profiles table one profile has all the defaults
-- jammed into it and all the other don't. You can't assume the profile has
-- any values in it at all.

-- From 7 onwards flagChanges is only the base flags, groups are stored
-- in the groups attribute, renamed from customFlags and having the spellID
-- members as keys with true as value.

function LM.Options:VersionUpgrade7()
    if (LM.db.global.configVersion or 7) >= 7 then
        return
    end

    LM.Debug('VersionUpgrade: 7')

    for n, p in pairs(LM.db.sv.profiles or {}) do
        if p.customFlags and p.flagChanges then
            LM.Debug(' - upgrading profile: ' .. n)
            p.groups = p.customFlags or {}
            p.customFlags = nil
            for spellID,changes in pairs(p.flagChanges) do
                for g,c in pairs(changes) do
                    if p.groups[g] then
                        p.groups[g][spellID] = true
                        changes[g] = nil
                    end
                    if next(changes) == nil then
                        p.flagChanges[spellID] = nil
                    end
                end
            end
        end
    end
    return true
end

-- Version 8 moves to storing the user rules as action lines and compiling
-- them rather than trying to store them as raw rules, which caused all
-- sorts of grief.

function LM.Options:VersionUpgrade8()
    if (LM.db.global.configVersion or 8) >= 8 then
        return
    end

    LM.Debug('VersionUpgrade: 8')
    for n, p in pairs(LM.db.sv.profiles or {}) do
        LM.Debug('   - upgrading profile: ' .. n)
        if p.rules then
            for k, ruleset in pairs(p.rules) do
                LM.Debug('   - ruleset ' .. k)
                for i, rule in pairs(ruleset) do
                    if type(rule) == 'table' then
                        ruleset[i] = LM.Rule:MigrateFromTable(rule)
                    end
                end
            end
        end
    end
    return true
end

-- Version 9 changes excludeNewMounts (true/false) to defaultPriority

function LM.Options:VersionUpgrade9()
    if (LM.db.global.configVersion or 9) >= 9 then
        return
    end

    LM.Debug('VersionUpgrade: 9')
    for n, p in pairs(LM.db.sv.profiles or {}) do
        LM.Debug(' - upgrading profile: ' .. n)
        if p.excludeNewMounts then
            p.defaultPriority = 0
            p.excludeNewMounts = nil
        end
    end
    return true
end

-- Version 10 removes [dragonridable]

function LM.Options:VersionUpgrade10()
    if (LM.db.global.configVersion or 10) >= 10 then
        return
    end

    LM.Debug('VersionUpgrade: 10')
    for n, p in pairs(LM.db.sv.profiles or {}) do
        LM.Debug(' - upgrading profile: ' .. n)
        for k, ruleset in pairs(p.rules or {}) do
            LM.Debug('   - ruleset ' .. k)
            for i, rule in pairs(ruleset) do
                -- this is not right but otherwise we might end up with more
                -- than 3 conditions and the UI will freak
                ruleset[i] = rule:gsub('dragonridable', 'flyable')
            end
        end
        for i, buttonAction in pairs(p.buttonActions or {}) do
            LM.Debug('   - buttonAction ' .. i)
            p.buttonActions[i] = buttonAction:gsub('dragonridable', 'flyable,advflyable')
        end
    end
    return true
end

function LM.Options:CleanDatabase()
    local changed
    for n,c in pairs(LM.db.sv.char or {}) do
        for k in pairs(c) do
            if defaults.char[k] == nil then
                c[k] = nil
                changed = true
            end
        end
    end
    for n,p in pairs(LM.db.sv.profiles or {}) do
        for k in pairs(p) do
            if defaults.profile[k] == nil then
                p[k] = nil
                changed = true
            end
        end
    end
    for k in pairs(LM.db.sv.global or {}) do
        if k ~= "configVersion" and defaults.global[k] == nil then
            LM.db.sv.global[k] = nil
            changed = true
        end
    end
    return changed
end

function LM.Options:DatabaseMaintenance()
    local changed
    if self:VersionUpgrade7() then changed = true end
    if self:VersionUpgrade8() then changed = true end
    if self:VersionUpgrade9() then changed = true end
    if self:VersionUpgrade10() then changed = true end
    if self:CleanDatabase() then changed = true end
    LM.db.global.configVersion = 10
    return changed
end

function LM.Options:OnProfile()
    table.wipe(self.cachedMountFlags)
    table.wipe(self.cachedMountGroups)
    table.wipe(self.cachedRuleSets)
    self:InitializePriorities()
    LM.db.callbacks:Fire("OnOptionsProfile")
end

-- This is split into two because I want to load it early in the
-- setup process to get access to the debugging settings.

function LM.Options:Initialize()
    local oldDB = LiteMountDB and CopyTable(LiteMountDB)

    LM.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)

    -- It would be neater and safer to do the maintenance before AceDB got its
    -- hands on things, but I want to be able to spit out debugging in the
    -- maintenance code which relies on LM.db existing.

    if self:DatabaseMaintenance() then
        if oldDB then
            LM.Debug('Backing up options database.')
            LiteMountBackupDB = oldDB
        end
    end

    self.cachedMountFlags = {}
    self.cachedMountGroups = {}
    self.cachedRuleSets = {}

    LM.db.RegisterCallback(self, "OnProfileChanged", "OnProfile")
    LM.db.RegisterCallback(self, "OnProfileCopied", "OnProfile")
    LM.db.RegisterCallback(self, "OnProfileReset", "OnProfile")

    --@debug@
    LiteMountDB.data = nil
    --@end-debug@
end

--[[----------------------------------------------------------------------------
    Mount priorities stuff.
----------------------------------------------------------------------------]]--

function LM.Options:GetAllPriorities()
    return { 0, 1, 2, 3, 4 }
end

function LM.Options:GetRawMountPriorities()
    return LM.db.profile.mountPriorities
end

function LM.Options:SetRawMountPriorities(v)
    LM.db.profile.mountPriorities = v
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetPriority(m)
    local p = LM.db.profile.mountPriorities[m.spellID] or LM.db.profile.defaultPriority
    return p, (LM.db.profile.priorityWeights[p] or 0)
end

function LM.Options:InitializePriorities()
    for _,m in ipairs(LM.MountRegistry.mounts) do
        if not LM.db.profile.mountPriorities[m.spellID] then
            LM.db.profile.mountPriorities[m.spellID] = LM.db.profile.defaultPriority
        end
    end
end

function LM.Options:SetPriority(m, v)
    LM.Debug("Setting mount %s (%d) to priority %s", m.name, m.spellID, tostring(v))
    if v then
        v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    end
    LM.db.profile.mountPriorities[m.spellID] = v
    LM.db.callbacks:Fire("OnOptionsModified")
end

-- Don't just loop over SetPriority because we don't want the UI to freeze up
-- with hundreds of unnecessary callback refreshes.

function LM.Options:SetPriorities(mountlist, v)
    LM.Debug("Setting %d mounts to priority %s", #mountlist, tostring(v))
    if v then
        v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    end
    for _,m in ipairs(mountlist) do
        LM.db.profile.mountPriorities[m.spellID] = v
    end
    LM.db.callbacks:Fire("OnOptionsModified")
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

local function FlagDiff(a, b)
    local diff = { }

    for flagName in pairs(LM.tMerge(a,b)) do
        if a[flagName] and not b[flagName] then
            diff[flagName] = '-'
        elseif not a[flagName] and b[flagName] then
            diff[flagName] = '+'
        end
    end

    diff.FAVORITES = nil

    if next(diff) == nil then
        return nil
    end

    return diff
end

function LM.Options:GetRawFlagChanges()
    return LM.db.profile.flagChanges
end

function LM.Options:SetRawFlagChanges(v)
    LM.db.profile.flagChanges = v
    table.wipe(self.cachedMountFlags)
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetMountFlags(m)

    if not self.cachedMountFlags[m.spellID] then
        local changes = LM.db.profile.flagChanges[m.spellID]

        self.cachedMountFlags[m.spellID] = CopyTable(m.flags)

        for flagName, change in pairs(changes or {}) do
            if change == '+' then
                self.cachedMountFlags[m.spellID][flagName] = true
            elseif change == '-' then
                self.cachedMountFlags[m.spellID][flagName] = nil
            end
        end
    end

    return self.cachedMountFlags[m.spellID]
end

function LM.Options:SetMountFlag(m, setFlag)
    LM.Debug("Setting flag %s for spell %s (%d).", setFlag, m.name, m.spellID)

    -- Note this is the actual cached copy, we can only change it here
    -- (and below in ClearMountFlag) because we are invalidating the cache
    -- straight after.
    local flags = self:GetMountFlags(m)
    flags[setFlag] = true
    self:SetMountFlags(m, flags)
end

function LM.Options:ClearMountFlag(m, clearFlag)
    LM.Debug("Clearing flag %s for spell %s (%d).", clearFlag, m.name, m.spellID)

    -- See note above
    local flags = self:GetMountFlags(m)
    flags[clearFlag] = nil
    self:SetMountFlags(m, flags)
end

function LM.Options:ResetMountFlags(m)
    LM.Debug("Defaulting flags for spell %s (%d).", m.name, m.spellID)
    LM.db.profile.flagChanges[m.spellID] = nil
    self.cachedMountFlags[m.spellID] = nil
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:ResetAllMountFlags()
    table.wipe(LM.db.profile.flagChanges)
    table.wipe(self.cachedMountFlags)
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:SetMountFlags(m, flags)
    LM.db.profile.flagChanges[m.spellID] = FlagDiff(m.flags, flags)
    self.cachedMountFlags[m.spellID] = nil
    LM.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Flags
----------------------------------------------------------------------------]]--

-- These are pseudo-flags used in Mount:MatchesOneFilter and we don't
-- let custom flags have the name.
local PseudoFlags = {
    "CASTABLE",
    "SLOW",
    "MAWUSABLE",
    "DRAGONRIDING",
    "FAVORITES", FAVORITES,
    "ALL", ALL,
    "NONE", NONE
}

function LM.Options:IsFlag(f)
    if tContains(PseudoFlags, f) then
        return true
    else
        return LM.FLAG[f] ~= nil
    end
end

function LM.Options:GetFlags()
    local out = {}
    for f in pairs(LM.FLAG) do table.insert(out, f) end
    table.sort(out, function (a, b) return LM.FLAG[a] < LM.FLAG[b] end)
    return out
end

--[[----------------------------------------------------------------------------
    Group stuff.
----------------------------------------------------------------------------]]--

function LM.Options:GetRawGroups()
    return LM.db.profile.groups, LM.db.global.groups
end

function LM.Options:SetRawGroups(profileGroups, globalGroups)
    LM.db.profile.groups = profileGroups or LM.db.profile.groups
    LM.db.global.groups = globalGroups or LM.db.global.groups
    table.wipe(self.cachedMountGroups)
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetGroupNames()
    -- It's possible (annoyingly) to have a global and profile group with
    -- the same name, by making a group in a profile then switching to a
    -- different profile and making the global group.

    local groupNames = {}
    for g,v in pairs(LM.db.global.groups) do
        if v then groupNames[g] = true end
    end
    for g,v in pairs(LM.db.profile.groups) do
        if v then groupNames[g] = true end
    end
    local out = GetKeysArray(groupNames)
    table.sort(out)
    return out
end

function LM.Options:IsGlobalGroup(g)
    return LM.db.profile.groups[g] == nil and LM.db.global.groups[g] ~= nil
end

function LM.Options:IsProfileGroup(g)
    return LM.db.profile.groups[g] ~= nil
end

function LM.Options:IsGroup(g)
    return self:IsGlobalGroup(g) or self:IsProfileGroup(g)
end

function LM.Options:CreateGroup(g, isGlobal)
    if self:IsGroup(g) or self:IsFlag(g) then return end
    if isGlobal then
        LM.db.global.groups[g] = { }
    else
        LM.db.profile.groups[g] = { }
    end
    table.wipe(self.cachedMountGroups)
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:DeleteGroup(g)
    if LM.db.profile.groups[g] then
        LM.db.profile.groups[g] = nil
    elseif LM.db.global.groups[g] then
        LM.db.global.groups[g] = nil
    end
    table.wipe(self.cachedMountGroups)
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:RenameGroup(g, newG)
    if self:IsFlag(newG) then return end
    if g == newG then return end

    -- all this "tmp" stuff is to deal with f == newG, just in case
    if LM.db.profile.groups[g] then
        local tmp = LM.db.profile.groups[g]
        LM.db.profile.groups[g] = nil
        LM.db.profile.groups[newG] = tmp
    elseif LM.db.global.groups[g] then
        local tmp = LM.db.global.groups[g]
        LM.db.global.groups[g] = nil
        LM.db.global.groups[newG] = tmp
    end
    table.wipe(self.cachedMountGroups)
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetMountGroups(m)
    if not self.cachedMountGroups[m.spellID] then
        self.cachedMountGroups[m.spellID] = {}
        for _, g in ipairs(self:GetGroupNames()) do
            if self:IsMountInGroup(m, g) then
                self.cachedMountGroups[m.spellID][g] = true
            end
        end
    end
    return self.cachedMountGroups[m.spellID]
end

function LM.Options:IsMountInGroup(m, g)
    if LM.db.profile.groups[g] then
        return LM.db.profile.groups[g][m.spellID]
    elseif LM.db.global.groups[g] then
        return LM.db.global.groups[g][m.spellID]
    end
end

function LM.Options:SetMountGroup(m, g)
    if LM.db.profile.groups[g] then
        LM.db.profile.groups[g][m.spellID] = true
    elseif LM.db.global.groups[g] then
        LM.db.global.groups[g][m.spellID] = true
    end
    self.cachedMountGroups[m.spellID] = nil
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:ClearMountGroup(m, g)
    if LM.db.profile.groups[g] then
        LM.db.profile.groups[g][m.spellID] = nil
    elseif LM.db.global.groups[g] then
        LM.db.global.groups[g][m.spellID] = nil
    end
    self.cachedMountGroups[m.spellID] = nil
    LM.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Rules stuff.
----------------------------------------------------------------------------]]--

function LM.Options:GetRules(n)
    local rules = LM.db.profile.rules[n] or DefaultRules
    return LM.tCopyShallow(rules)
end

function LM.Options:GetCompiledRuleSet(n)
    if not self.cachedRuleSets['user'..n] then
        self.cachedRuleSets['user'..n] = LM.RuleSet:Compile(self:GetRules(n))
    end
    return self.cachedRuleSets['user'..n]
end

function LM.Options:SetRules(n, rules)
    if not rules or tCompare(rules, DefaultRules, 10) then
        LM.db.profile.rules[n] = nil
    else
        LM.db.profile.rules[n] = rules
    end
    self.cachedRuleSets['user'..n] = nil
    LM.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
   Generic Get/Set Option
----------------------------------------------------------------------------]]--

function LM.Options:GetOption(name)
    for _, k in ipairs({ 'char', 'profile', 'global' }) do
        if defaults[k][name] ~= nil then
            return LM.db[k][name]
        end
    end
end

function LM.Options:GetOptionDefault(name)
    for _, k in ipairs({ 'char', 'profile', 'global' }) do
        if defaults[k][name] then
            return defaults[k][name]
        end
    end
end

function LM.Options:SetOption(name, val)
    for _, k in ipairs({ 'char', 'profile', 'global' }) do
        if defaults[k][name] ~= nil then
            if val == nil then val = defaults[k][name] end
            local valType, expectedType = type(val), type(defaults[k][name])
            if valType ~= expectedType then
                LM.PrintError("Bad option type : %s=%s (expected %s)", name, valType, expectedType)
            else
                LM.db[k][name] = val
                LM.db.callbacks:Fire("OnOptionsModified")
            end
            return
        end
    end
    LM.PrintError("Bad option: %s", name)
end


--[[----------------------------------------------------------------------------
    Button action lists
----------------------------------------------------------------------------]]--

function LM.Options:GetButtonRuleSet(n)
    return LM.db.profile.buttonActions[n]
end

function LM.Options:GetCompiledButtonRuleSet(n)
    if not self.cachedRuleSets['button'..n] then
        self.cachedRuleSets['button'..n] = LM.RuleSet:Compile(self:GetButtonRuleSet(n))
    end
    return self.cachedRuleSets['button'..n]
end

function LM.Options:SetButtonRuleSet(n, v)
    LM.db.profile.buttonActions[n] = v
    self.cachedRuleSets['button'..n] = nil
    LM.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Instance recording
----------------------------------------------------------------------------]]--


function LM.Options:RecordInstance()
    local info = { GetInstanceInfo() }
    LM.db.global.instances[info[8]] = info[1]
end

function LM.Options:GetInstances(id)
    return LM.tCopyShallow(LM.db.global.instances)
end

function LM.Options:GetInstanceNameByID(id)
    if LM.db.global.instances[id] then
        return LM.db.global.instances[id]
    end

    -- AQ is hard-coded in the default rules. This is not really the right
    -- name but it's close enough.
    if id == 531 then
        return C_Map.GetMapInfo(319).name
    end
end


--[[----------------------------------------------------------------------------
    Summon counts
----------------------------------------------------------------------------]]--

function LM.Options:IncrementSummonCount(m)
    LM.db.global.summonCounts[m.spellID] =
        (LM.db.global.summonCounts[m.spellID] or 0) + 1
    return LM.db.global.summonCounts[m.spellID]
end

function LM.Options:GetSummonCount(m)
    return LM.db.global.summonCounts[m.spellID] or 0
end

function LM.Options:ResetSummonCount(m)
    LM.db.global.summonCounts[m.spellID] = nil
end


--[[----------------------------------------------------------------------------
    Import/Export Profile
----------------------------------------------------------------------------]]--

function LM.Options:ExportProfile(profileName)
    -- remove all the defaults from the DB before export
    local savedDefaults = LM.db.defaults
    LM.db:RegisterDefaults(nil)

    -- Add an export time into the profile

    LM.db.profiles[profileName].__export__ = time()

    local data = LibDeflate:EncodeForPrint(
                    LibDeflate:CompressDeflate(
                     Serializer:Serialize(
                       LM.db.profiles[profileName]
                     ) ) )

    LM.db.profiles[profileName].__export__ = nil

    -- put the defaults back
    LM.db:RegisterDefaults(savedDefaults)

    -- If something went wrong upstream this could be nil
    return data
end

function LM.Options:DecodeProfileData(str)
    local decoded = LibDeflate:DecodeForPrint(str)
    if not decoded then return end

    local deflated = LibDeflate:DecompressDeflate(decoded)
    if not deflated then return end

    local isValid, data = Serializer:Deserialize(deflated)
    if not isValid then return end

    if not data.__export__ then return end
    data.__export__ = nil

    return data
end


function LM.Options:ImportProfile(profileName, str)

    -- I really just can't be bothered fighting with AceDB to make it safe to
    -- import the current profile, given that they don't expose enough
    -- functionality to do so in an "approved" way.

    if profileName == LM.db:GetCurrentProfile() then return false end

    local data = self:DecodeProfileData(str)
    if not data then return false end

    local savedDefaults = LM.db.defaults

    LM.db.profiles[profileName] = data
    -- XXX profile migrations~ XXX

    LM.db:RegisterDefaults(savedDefaults)

    return true
end
