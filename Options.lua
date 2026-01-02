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
Downshift [mod:shift]
SmartMount
Falling [falling]
Dismount
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
        -- "Mount [map:1355,flyable,qfc:56766] mt:254",
        -- AQ Battle Tanks in the raid instance
        "Mount [instance:531] mt:241",
        -- Arcanist's Manasaber to disguise you in Suramar
        "Mount [extra:202477,nosubmerged] id:881",
        -- Rustbolt Resistor and Aerial Unit R-21/X avoid being shot down
        -- "Mount [map:1462,flyable] MECHAGON"
    },
})

local DefaultRules = DefaultRulesByProject[WOW_PROJECT_ID]

local DefaultFallingByProject = LM.TableWithDefault({
    DEFAULT = {
        "spell:130",    -- Slow Fall
        "spell:1706",   -- Levitate
        "spell:125883", -- Zen Flight
    },
    [1] = { -- Retail
        "spell:130",    -- Slow Fall
        "spell:1706",   -- Levitate
        "spell:125883", -- Zen Flight
        "spell:131347", -- Glide
        "spell:164862", -- Flap
        "item:182729",  -- Hearty Dragon Plume
        "item:131811",  -- Rocfeather Skyhorn Kite
    },
})

-- A lot of things need to be cleaned up when flags are deleted/renamed

local defaults = {
    char = {
        unavailableMacro    = "",
        useUnavailableMacro = false,
        combatMacro         = "",
        useCombatMacro      = false,
        debugEnabled        = false,
        uiDebugEnabled      = false,
    },
    profile = {
        flagChanges         = { },
        useOnGround         = { },
        mountPriorities     = { },
        buttonActions       = { ['*'] = DefaultButtonAction },
        falling             = DefaultFallingByProject[WOW_PROJECT_ID],
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
        mountSpecialTimer   = 0,
    },
    global = {
        groups              = { },
        instances           = { },
        summonCounts        = { },
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

-- Version 11 remove the longstanding flagChanges and replaces it with a
-- simpler useOnGround setting. Because I am paranoid I'm leaving the
-- flagChanges there, unused.

function LM.Options:VersionUpgrade11()
    if (LM.db.global.configVersion or 11) >= 11 then
        return
    end
    LM.Debug('VersionUpgrade: 11')
    for n, p in pairs(LM.db.sv.profiles or {}) do
        LM.Debug(' - upgrading profile: ' .. n)
        for spellID, changes in pairs(p.flagChanges or {}) do
            if changes.RUN == '+' then
                p.useOnGround = p.useOnGround or {}
                p.useOnGround[spellID] = true
            end
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
    if self:VersionUpgrade11() then changed = true end
    if self:CleanDatabase() then changed = true end
    LM.db.global.configVersion = 11
    return changed
end

function LM.Options:NotifyChanged()
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:OnProfile()
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

function LM.Options:SetPriority(m, v, dontFire)
    LM.Debug("Setting mount %s (%d) to priority %s", m.name, m.spellID, tostring(v))
    if v then
        v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    end
    LM.db.profile.mountPriorities[m.spellID] = v
    if not dontFire then
        LM.db.callbacks:Fire("OnOptionsModified", m)
    end
end

-- Don't just loop over SetPriority because we don't want the UI to freeze up
-- with hundreds of unnecessary callback refreshes.

function LM.Options:SetPriorityList(mountlist, v)
    LM.Debug("Setting %d mounts to priority %s", #mountlist, tostring(v))
    for _,m in ipairs(mountlist) do
        self:SetPriority(m, v, true)
    end
    LM.db.callbacks:Fire("OnOptionsModified")
end

--[[----------------------------------------------------------------------------
    useOnGround
----------------------------------------------------------------------------]]--

function LM.Options:GetRawUseOnGround()
    return LM.db.profile.useOnGround
end

function LM.Options:SetRawUseOnGround(v)
    LM.db.profile.useOnGround = v
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetUseOnGround(m)
    return LM.db.profile.useOnGround[m.spellID]
end

function LM.Options:SetUseOnGround(m, v, dontFire)
    if not m.flags.FLY then
        return
    end
    LM.Debug("Setting useOnGround to %s for %s (%d).", tostring(v), m.name, m.spellID)
    LM.db.profile.useOnGround[m.spellID] = v and true or nil
    if not dontFire then
        LM.db.callbacks:Fire("OnOptionsModified", m)
    end
end

function LM.Options:SetUseOnGroundList(mountlist, v)
    for _,m in ipairs(mountlist) do
        self:SetUseOnGround(m, v, true)
    end
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:ResetAllUseOnGround()
    table.wipe(LM.db.profile.useOnGround)
    LM.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Flags
----------------------------------------------------------------------------]]--

-- These are pseudo-flags used in Mount:MatchesOneFilter and we don't
-- let custom flags have the name.
local PseudoFlags = {
    "CASTABLE",
    "USABLE",
    "COLLECTED",
    "SLOW",
    "JOURNAL",
    "DRAGONRIDING",
    "ZONEMATCH",
    "FAVORITES", FAVORITES,
    "ENABLED", VIDEO_OPTIONS_ENABLED,
    "DISABLED", VIDEO_OPTIONS_DISABLED,
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

function LM.Options:SetMountGroup(m, g, dontFire)
    if LM.db.profile.groups[g] then
        LM.db.profile.groups[g][m.spellID] = true
    elseif LM.db.global.groups[g] then
        LM.db.global.groups[g][m.spellID] = true
    end
    self.cachedMountGroups[m.spellID] = nil
    if not dontFire then
        LM.db.callbacks:Fire("OnOptionsModified", m)
    end
end

function LM.Options:SetMountGroupList(mountlist, g)
    for _, m in ipairs(mountlist) do
        self:SetMountGroup(m, g, true)
    end
    LM.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:ClearMountGroup(m, g, dontFire)
    if LM.db.profile.groups[g] then
        LM.db.profile.groups[g][m.spellID] = nil
    elseif LM.db.global.groups[g] then
        LM.db.global.groups[g][m.spellID] = nil
    end
    self.cachedMountGroups[m.spellID] = nil
    if not dontFire then
        LM.db.callbacks:Fire("OnOptionsModified", m)
    end
end

function LM.Options:ClearMountGroupList(mountlist, g)
    for _, m in ipairs(mountlist) do
        self:ClearMountGroup(m, g, true)
    end
    LM.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Rules stuff.
----------------------------------------------------------------------------]]--

function LM.Options:GetRules(n)
    local rules = LM.db.profile.rules[n] or DefaultRules
    return CopyTable(rules, true)
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

function LM.Options:GetClassOption(class, name)
    if class == 'PLAYER' then
        return LM.db.char[name]
    elseif class == UnitClassBase('player') then
        return LM.db.class[name]
    elseif LM.db.sv.class and LM.db.sv.class[class] then
        return LM.db.sv.class[class][name]
    end
end

function LM.Options:SetClassOption(class, name, val)
    if class == 'PLAYER' then
        LM.db.char[name] = val
        LM.db.callbacks:Fire("OnOptionsModified")
    elseif class == UnitClassBase('player') then
        LM.db.class[name] = val
        LM.db.callbacks:Fire("OnOptionsModified")
    else
        LM.db.sv.class = LM.db.sv.class or {}
        LM.db.sv.class[class] = LM.db.sv.class[class] or {}
        LM.db.sv.class[class][name] = val
        LM.db.callbacks:Fire("OnOptionsModified")
    end
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
    return CopyTable(LM.db.global.instances, true)
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
