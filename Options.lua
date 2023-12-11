--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local Serializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

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
IF [mod:shift]
    IF [submerged]
        Limit -SWIM
    ELSEIF [dragonridable]
        Limit -DRAGONRIDING
    ELSEIF [flyable]
        Limit -FLY
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

local DefaultRulesByProject = {
    -- Wrath Classic
    [11] = {
        -- AQ Battle Tanks in the raid instance
        "Mount [instance:531] mt:241",
    },
    -- Retail
    [1] = {
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
}

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

        -- Paranoia, for now. Later delete these and let the cleanup work
        oldRules            = { },
        oldFlagChanges      = { },
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

function LM.Options:UpdateVersion(n)
    for _,c in pairs(self.db.sv.char) do
        c.configVersion = math.max(c.configVersion or 0, n)
    end
    for _,p in pairs(self.db.profiles) do
        p.configVersion = math.max(p.configVersion or 0, n)
    end
    self.db.global.configVersion = math.max(self.db.global.configVersion or 0, n)
end

-- Version 3 moved flag stuff global, and now version 4 is putting them
-- back into profile. I hope I'm not making the same mistakes all over
-- again. "Those who cannot remember the past are condemned to repeat it."
function LM.Options:VersionUpgrade4()
    LM.Debug('VersionUpgrade: 4')

    if (self.db.global.configVersion or 4) < 4 then
        LM.Debug(' - migrating global.flagChanges')
        for n, p in pairs(self.db.profiles) do
            LM.Debug('   - into profile: ' .. n)
            p.flagChanges = p.flagChanges or {}
            for spellID,changes in pairs(self.db.global.flagChanges or {}) do
                p.flagChanges[spellID] = Mixin(p.flagChanges[spellID] or {}, changes)
            end
        end
        LM.Debug(' - migrating global.customFlags')
        for n, p in pairs(self.db.profiles) do
            LM.Debug('   - into profile: ' .. n)
            p.customFlags = p.customFlags or {}
            Mixin(p.customFlags, self.db.global.customFlags)
        end
        self.db.global.customFlags = nil
        self.db.global.flagChanges = nil
    end

    self:UpdateVersion(4)
end

function LM.Options:VersionUpgrade5()
    LM.Debug('VersionUpgrade: 5')

    -- Because I stuffed up downgrading version numbers, don't check for 5
    -- just look for excludedSpells with no mountPriorities

    for n,p in pairs(self.db.profiles) do
        if p.excludedSpells and not p.mountPriorities then
            LM.Debug('   - upgrading profile: ' .. n)
            p.mountPriorities = p.mountPriorities or {}
            local nTotal, nExcluded, nIncluded = 0, 0, 0
            for spellID,isExcluded in pairs(p.excludedSpells or {}) do
                nTotal = nTotal + 1
                if isExcluded then
                    nExcluded = nExcluded + 1
                    p.mountPriorities[spellID] = self.DISABLED_PRIORITY
                else
                    nIncluded = nIncluded + 1
                    p.mountPriorities[spellID] = self.DEFAULT_PRIORITY
                end
            end
            LM.Debug('   - finished: total=%d, p0=%d, p1=%d', nTotal, nExcluded, nIncluded)
            p.excludedSpells = nil
            p.uiMountFilterList = nil
            p.enableTwoPress = nil
        end
    end

    self:UpdateVersion(5)
end

-- This fixes a stupid typo I made in the code at one point

function LM.Options:VersionUpgrade6()
    LM.Debug('VersionUpgrade: 6')
    for _,c in pairs(self.db.sv.char) do
        if (c.configVersion or 6) < 6 then
            if c.unvailableMacro then
                c.unavailableMacro = c.unvailableMacro
                c.unvailableMacro = nil
            end
        end
    end
    self:UpdateVersion(6)
end

-- From 7 onwards flagChanges is only the base flags, groups are stored
-- in the groups attribute, renamed from customFlags and having the spellID
-- members as keys with true as value.

function LM.Options:VersionUpgrade7()
    LM.Debug('VersionUpgrade: 7')

    for n, p in pairs(self.db.profiles) do
        if (p.configVersion or 7) < 7 and p.flagChanges then
            LM.Debug(' - upgrading profile: ' .. n)
            p.oldFlagChanges = CopyTable(p.flagChanges)
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
    self:UpdateVersion(7)
end

-- Version 8 moves to storing the user rules as action lines and compiling
-- them rather than trying to store them as raw rules, which caused all
-- sorts of grief.

function LM.Options:VersionUpgrade8()
    LM.Debug('VersionUpgrade: 8')

    for n, p in pairs(self.db.profiles) do
        if (p.configVersion or 8) < 8 and p.rules then
            LM.Debug('   - upgrading profile: ' .. n)
            p.oldRules = CopyTable(p.rules)
            for k, ruleset in pairs(p.rules) do
                LM.Debug('   - ruleset ' .. k)
                for i, rule in ipairs(ruleset) do
                    ruleset[i] = LM.Rule:MigrateFromTable(rule)
                end
            end
        end
    end
    self:UpdateVersion(8)
end

-- Version 9 changes excludeNewMounts (true/false) to defaultPriority

function LM.Options:VersionUpgrade9()
    LM.Debug('VersionUpgrade: 9')

    for n, p in pairs(self.db.profiles) do
        if (p.configVersion or 9) < 9 then
            LM.Debug(' - upgrading profile: ' .. n)
            if p.excludeNewMounts then
                p.defaultPriority = 0
                p.excludeNewMounts = nil
            end
        end
    end
    self:UpdateVersion(9)
end

function LM.Options:CleanDatabase()
    for n,c in pairs(self.db.sv.char) do
        for k in pairs(c) do
            if k ~= "configVersion" and defaults.char[k] == nil then
                c[k] = nil
            end
        end
    end
    for n,p in pairs(self.db.profiles) do
        for k in pairs(p) do
            if k ~= "configVersion" and defaults.profile[k] == nil then
                p[k] = nil
            end
        end
    end
    for k in pairs(self.db.global) do
        if k ~= "configVersion" and defaults.global[k] == nil then
            self.db.global[k] = nil
        end
    end
end

function LM.Options:VersionUpgrade()
    self:VersionUpgrade4()
    self:VersionUpgrade5()
    self:VersionUpgrade6()
    self:VersionUpgrade7()
    self:VersionUpgrade8()
    self:VersionUpgrade9()
    self:CleanDatabase()
end

function LM.Options:OnProfile()
    table.wipe(self.cachedMountFlags)
    table.wipe(self.cachedMountGroups)
    table.wipe(self.cachedRuleSets)
    self:InitializePriorities()
    self.db.callbacks:Fire("OnOptionsProfile")
end

-- This is split into two because I want to load it early in the
-- setup process to get access to the debugging settings.

function LM.Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)
    self.cachedMountFlags = {}
    self.cachedMountGroups = {}
    self.cachedRuleSets = {}
    self:VersionUpgrade()
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfile")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfile")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfile")

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
    return self.db.profile.mountPriorities
end

function LM.Options:SetRawMountPriorities(v)
    self.db.profile.mountPriorities = v
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetPriority(m)
    local p = self.db.profile.mountPriorities[m.spellID] or self.db.profile.defaultPriority
    return p, (self.db.profile.priorityWeights[p] or 0)
end

function LM.Options:InitializePriorities()
    for _,m in ipairs(LM.MountRegistry.mounts) do
        if not self.db.profile.mountPriorities[m.spellID] then
            self.db.profile.mountPriorities[m.spellID] = self.db.profile.defaultPriority
        end
    end
end

function LM.Options:SetPriority(m, v)
    LM.Debug("Setting mount %s (%d) to priority %s", m.name, m.spellID, tostring(v))
    if v then
        v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    end
    self.db.profile.mountPriorities[m.spellID] = v
    self.db.callbacks:Fire("OnOptionsModified")
end

-- Don't just loop over SetPriority because we don't want the UI to freeze up
-- with hundreds of unnecessary callback refreshes.

function LM.Options:SetPriorities(mountlist, v)
    LM.Debug("Setting %d mounts to priority %s", #mountlist, tostring(v))
    if v then
        v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    end
    for _,m in ipairs(mountlist) do
        self.db.profile.mountPriorities[m.spellID] = v
    end
    self.db.callbacks:Fire("OnOptionsModified")
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
    return self.db.profile.flagChanges
end

function LM.Options:SetRawFlagChanges(v)
    self.db.profile.flagChanges = v
    table.wipe(self.cachedMountFlags)
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetMountFlags(m)

    if not self.cachedMountFlags[m.spellID] then
        local changes = self.db.profile.flagChanges[m.spellID]

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
    self.db.profile.flagChanges[m.spellID] = nil
    self.cachedMountFlags[m.spellID] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:ResetAllMountFlags()
    table.wipe(self.db.profile.flagChanges)
    table.wipe(self.cachedMountFlags)
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:SetMountFlags(m, flags)
    self.db.profile.flagChanges[m.spellID] = FlagDiff(m.flags, flags)
    self.cachedMountFlags[m.spellID] = nil
    self.db.callbacks:Fire("OnOptionsModified")
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
    return self.db.profile.groups, self.db.global.groups
end

function LM.Options:SetRawGroups(profileGroups, globalGroups)
    self.db.profile.groups = profileGroups or self.db.profile.groups
    self.db.global.groups = globalGroups or self.db.global.groups
    table.wipe(self.cachedMountGroups)
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetGroupNames()
    -- It's possible (annoyingly) to have a global and profile group with
    -- the same name, by making a group in a profile then switching to a
    -- different profile and making the global group.

    local groupNames = {}
    for g,v in pairs(self.db.global.groups) do
        if v then groupNames[g] = true end
    end
    for g,v in pairs(self.db.profile.groups) do
        if v then groupNames[g] = true end
    end
    local out = GetKeysArray(groupNames)
    table.sort(out)
    return out
end

function LM.Options:IsGlobalGroup(g)
    return self.db.profile.groups[g] == nil and self.db.global.groups[g] ~= nil
end

function LM.Options:IsProfileGroup(g)
    return self.db.profile.groups[g] ~= nil
end

function LM.Options:IsGroup(g)
    return self:IsGlobalGroup(g) or self:IsProfileGroup(g)
end

function LM.Options:CreateGroup(g, isGlobal)
    if self:IsGroup(g) or self:IsFlag(g) then return end
    if isGlobal then
        self.db.global.groups[g] = { }
    else
        self.db.profile.groups[g] = { }
    end
    table.wipe(self.cachedMountGroups)
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:DeleteGroup(g)
    if self.db.profile.groups[g] then
        self.db.profile.groups[g] = nil
    elseif self.db.global.groups[g] then
        self.db.global.groups[g] = nil
    end
    table.wipe(self.cachedMountGroups)
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:RenameGroup(g, newG)
    if self:IsFlag(newG) then return end
    if g == newG then return end

    -- all this "tmp" stuff is to deal with f == newG, just in case
    if self.db.profile.groups[g] then
        local tmp = self.db.profile.groups[g]
        self.db.profile.groups[g] = nil
        self.db.profile.groups[newG] = tmp
    elseif self.db.global.groups[g] then
        local tmp = self.db.global.groups[g]
        self.db.global.groups[g] = nil
        self.db.global.groups[newG] = tmp
    end
    table.wipe(self.cachedMountGroups)
    self.db.callbacks:Fire("OnOptionsModified")
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
    if self.db.profile.groups[g] then
        return self.db.profile.groups[g][m.spellID]
    elseif self.db.global.groups[g] then
        return self.db.global.groups[g][m.spellID]
    end
end

function LM.Options:SetMountGroup(m, g)
    if self.db.profile.groups[g] then
        self.db.profile.groups[g][m.spellID] = true
    elseif self.db.global.groups[g] then
        self.db.global.groups[g][m.spellID] = true
    end
    self.cachedMountGroups[m.spellID] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:ClearMountGroup(m, g)
    if self.db.profile.groups[g] then
        self.db.profile.groups[g][m.spellID] = nil
    elseif self.db.global.groups[g] then
        self.db.global.groups[g][m.spellID] = nil
    end
    self.cachedMountGroups[m.spellID] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Rules stuff.
----------------------------------------------------------------------------]]--

function LM.Options:GetRules(n)
    local rules = self.db.profile.rules[n] or DefaultRules
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
        self.db.profile.rules[n] = nil
    else
        self.db.profile.rules[n] = rules
    end
    self.cachedRuleSets['user'..n] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
   Generic Get/Set Option
----------------------------------------------------------------------------]]--

function LM.Options:GetOption(name)
    for _, k in ipairs({ 'char', 'profile', 'global' }) do
        if defaults[k][name] ~= nil then
            return self.db[k][name]
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
                self.db[k][name] = val
                self.db.callbacks:Fire("OnOptionsModified")
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
    return self.db.profile.buttonActions[n]
end

function LM.Options:GetCompiledButtonRuleSet(n)
    if not self.cachedRuleSets['button'..n] then
        self.cachedRuleSets['button'..n] = LM.RuleSet:Compile(self:GetButtonRuleSet(n))
    end
    return self.cachedRuleSets['button'..n]
end

function LM.Options:SetButtonRuleSet(n, v)
    self.db.profile.buttonActions[n] = v
    self.cachedRuleSets['button'..n] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Instance recording
----------------------------------------------------------------------------]]--


function LM.Options:RecordInstance()
    local info = { GetInstanceInfo() }
    self.db.global.instances[info[8]] = info[1]
end

function LM.Options:GetInstances(id)
    return LM.tCopyShallow(self.db.global.instances)
end

function LM.Options:GetInstanceNameByID(id)
    if self.db.global.instances[id] then
        return self.db.global.instances[id]
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
    self.db.global.summonCounts[m.spellID] =
        (self.db.global.summonCounts[m.spellID] or 0) + 1
    return self.db.global.summonCounts[m.spellID]
end

function LM.Options:GetSummonCount(m)
    return self.db.global.summonCounts[m.spellID] or 0
end

function LM.Options:ResetSummonCount(m)
    self.db.global.summonCounts[m.spellID] = nil
end


--[[----------------------------------------------------------------------------
    Import/Export Profile
----------------------------------------------------------------------------]]--

function LM.Options:ExportProfile(profileName)
    -- remove all the defaults from the DB before export
    local savedDefaults = self.db.defaults
    self.db:RegisterDefaults(nil)

    -- Add an export time into the profile

    self.db.profiles[profileName].__export__ = time()

    local data = LibDeflate:EncodeForPrint(
                    LibDeflate:CompressDeflate(
                     Serializer:Serialize(
                       self.db.profiles[profileName]
                     ) ) )

    self.db.profiles[profileName].__export__ = nil

    -- put the defaults back
    self.db:RegisterDefaults(savedDefaults)

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

    if profileName == self.db:GetCurrentProfile() then return false end

    local data = self:DecodeProfileData(str)
    if not data then return false end

    local savedDefaults = self.db.defaults

    self.db.profiles[profileName] = data
    self:VersionUpgrade()

    self.db:RegisterDefaults(savedDefaults)

    return true
end
