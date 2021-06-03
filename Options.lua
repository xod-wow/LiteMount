--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2021 Mike Battersby

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

customFlags is a table of flag names, with data about them (currently none)
    customFlags = {
        ["PASSENGER"] = { }
    }

----------------------------------------------------------------------------]]--

-- Don't use names here, it will break in other locales

local DefaultButtonAction = [[
# Slow Fall, Levitate, Zen Flight, Glide, Flap
Spell [falling] 130, 1706, 125883, 131347, 164862
LeaveVehicle
Dismount
CopyTargetsMount
# Swimming mount to fly in Nazjatar with Budding Deepcoral
Mount [map:1355,flyable,qfc:56766] mt:254
# Vashj'ir seahorse is faster underwater there
Mount [map:203,submerged] mt:232
# AQ-only bugs in the raid zone
Mount [instance:531] mt:241
# Use Arcanist's Manasaber if it will disguise you
IF [extra:202477][aura:202477]
  Mount [nosubmerged] id:881
END
IF [mod:shift,flyable][mod:shift,waterwalking]
  Limit RUN/WALK,~FLY
END
ApplyRules
SmartMount
Macro
]]

local DefaultRules = {
--@debug@
    {
        conditions = { "location:Stormwind City", },
        action = "Mount",
        args = { "Mimiron's Head" },
    },
    {
        conditions = { "map:203", "submerged", op="AND" },
        action = "Mount",
        args = { "mt:232" }
    },
    {
        conditions = { "map:1355", "flyable", "qfc:56766", op="AND" },
        action = "Mount",
        args = { "mt:254" }
    },
    {
        conditions = { "instance:531" },
        action = "Mount",
        args = { "mt:241" }
    },
    {
        conditions = { "extra:202477", "nosubmerged", op="AND" },
        action = "Mount",
        args = { "id:881" }
    },
    {
        conditions = { "mod:shift", "flyable", op="AND" },
        action = "Limit",
        args = { "RUN/WALK", "~FLY" }
    },
    {
        conditions = { "mod:shift", "waterwalking", op="AND" },
        action = "Limit",
        args = { "RUN/WALK", "~FLY" }
    }
--@end-debug@
}

-- A lot of things need to be cleaned up when flags are deleted/renamed

local defaults = {
    global = {
        instances = { },
    },
    profile = {
        customFlags         = { },
        flagChanges         = { },
        mountPriorities     = { },
        buttonActions       = { ['*'] = DefaultButtonAction },
        rules               = { ['*'] = DefaultRules },
        copyTargetsMount    = true,
        excludeNewMounts    = false,
        priorityWeights     = { 1, 2, 6, 1 },
        randomKeepSeconds   = 0,
        instantOnlyMoving   = false,
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


local function FlagDiff(allFlags, a, b)
    local diff = { }

    for _,flagName in ipairs(allFlags) do
        if flagName == "FAVORITES" then
            -- Do nothing
        elseif a[flagName] and not b[flagName] then
            diff[flagName] = '-'
        elseif not a[flagName] and b[flagName] then
            diff[flagName] = '+'
        end
    end

    if next(diff) == nil then
        return nil
    end

    return diff
end

function LM.Options:FlagIsUsed(f)
    for spellID,changes in pairs(self.db.profile.flagChanges) do
        if changes[f] then return true end
    end
    return false
end

-- Note to self. In any profile except the active one, the defaults are not
-- applied and you can't rely on them being there. This is super annoying.
-- Any time you loop over the profiles table one profile has all the defaults
-- jammed into it and all the other don't. You can't assume the profile has
-- any valeus in it at all.

-- Version 3 moved flag stuff global, and now version 4 is putting them
-- back into profile. I hope I'm not making the same mistakes all over
-- again. "Those who cannot remember the past are condemned to repeat it."
function LM.Options:VersionUpgrade4()
    if (self.db.global.configVersion or 4) >= 4 then
        return
    end

    LM.Debug('VersionUpgrade: 4')

    if self.db.global.flagChanges then
        LM.Debug(' - migrating global.flagChanges')
        for n, p in pairs(self.db.profiles) do
            LM.Debug('   - into profile: ' .. n)
            p.flagChanges = p.flagChanges or {}
            for spellID,changes in pairs(self.db.global.flagChanges) do
                p.flagChanges[spellID] = Mixin(p.flagChanges[spellID] or {}, changes)
            end
        end
    end

    if self.db.global.customFlags then
        LM.Debug(' - migrating global.customFlags')
        for n, p in pairs(self.db.profiles) do
            LM.Debug('   - into profile: ' .. n)
            p.customFlags = p.customFlags or {}
            Mixin(p.customFlags, self.db.global.customFlags)
        end
    end

    self.db.global.customFlags = nil
    self.db.global.flagChanges = nil

    for _, p in pairs(self.db.profiles) do p.configVersion = 4 end
    self.db.global.configVersion = 4
end

function LM.Options:VersionUpgrade5()
    LM.Debug('VersionUpgrade: 5')

    for n, p in pairs(self.db.profiles) do
        LM.Debug(' - checking profile: ' .. n)
        if (p.configVersion or 5) < 5 then
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
            -- p.excludedSpells = nil
            p.uiMountFilterList = nil
            p.enableTwoPress = nil
            LM.Debug(string.format('   - finished: total=%d, p0=%d, p1=%d', nTotal, nExcluded, nIncluded))
        end
        p.uiMountFilterList = nil
        p.enableTwoPress = nil
        p.configVersion = 5
    end

    for _, p in pairs(self.db.profiles) do p.configVersion = 5 end
    self.db.global.configVersion = 5
    self.db.char.configVersion = 5
end

function LM.Options:VersionUpgrade()
    local savedDefaults = self.db.defaults
    self.db:RegisterDefaults(nil)

    self:VersionUpgrade4()

    self:VersionUpgrade5()

    self.db:RegisterDefaults(savedDefaults)
end

-- We don't delete flags from the profile flagChanges on delete, because
-- that lets us undo the flag delete by just putting it back.

function LM.Options:PruneDeletedFlags()
    for spellID,changes in pairs(self.db.profile.flagChanges) do
        for f in pairs(changes) do
            if f == 'FAVORITES' or not self:IsActiveFlag(f) then
                changes[f] = nil
            end
        end
        if next(changes) == nil then
            self.db.profile.flagChanges[spellID] = nil
        end
    end
end

function LM.Options:OnProfile()
    self:PruneDeletedFlags()
    self:UpdateFlagCache()
    self:InitializePriorities()
    LiteMount:RecompileActions()
    self.db.callbacks:Fire("OnOptionsProfile")
end

-- This is split into two because I want to load it early in the
-- setup process to get access to the debugging settings, but it can't
-- run OnProfile() until the action buttons are set up as RecompileActions
-- won't work yet.

function LM.Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)
    self:VersionUpgrade()
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfile")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfile")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfile")
end

--[[----------------------------------------------------------------------------
    Mount priorities stuff.
----------------------------------------------------------------------------]]--

function LM.Options:GetAllPriorities()
    return { 0, 1, 2, 3, 4 }
end

function LM.Options:GetRawMountPriorities()
    return CopyTable(self.db.profile.mountPriorities)
end

function LM.Options:SetRawMountPriorities(v)
    self.db.profile.mountPriorities = CopyTable(v)
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetPriority(m)
    local p = self.db.profile.mountPriorities[m.spellID]
    return p, (self.db.profile.priorityWeights[p] or 0)
end

function LM.Options:InitializePriorities()
    for _,m in ipairs(LM.PlayerMounts.mounts) do
        if not self.db.profile.mountPriorities[m.spellID] then
            if self.db.profile.excludeNewMounts then
                self.db.profile.mountPriorities[m.spellID] = self.DISABLED_PRIORITY
            else
                self.db.profile.mountPriorities[m.spellID] = self.DEFAULT_PRIORITY
            end
        end
    end
end

function LM.Options:SetPriority(m, v)
    LM.Debug(format("Setting mount %s (%d) to priority %d", m.name, m.spellID, v))
    v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    self.db.profile.mountPriorities[m.spellID] = v
    self.db.callbacks:Fire("OnOptionsModified")
end

-- Don't just loop over SetPriority because we don't want the UI to freeze up
-- with hundreds of unnecessary callback refreshes.

function LM.Options:SetPriorities(mountlist, v)
    LM.Debug(format("Setting %d mounts to priority %d", #mountlist, v))
    v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    for _,m in ipairs(mountlist) do
        self.db.profile.mountPriorities[m.spellID] = v
    end
    self.db.callbacks:Fire("OnOptionsModified")
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM.Options:GetRawFlagChanges()
    return CopyTable(self.db.profile.flagChanges)
end

function LM.Options:SetRawFlagChanges(v)
    self.db.profile.flagChanges = CopyTable(v)
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:ApplyMountFlags(m)

    if not self.cachedMountFlags[m.spellID] then
        local changes = self.db.profile.flagChanges[m.spellID]
        self.cachedMountFlags[m.spellID] = CopyTable(m.flags)

        if changes then
            for _,flagName in ipairs(self.allFlags) do
                if self:IsActiveFlag(flagName) then
                    if changes[flagName] == '+' then
                        self.cachedMountFlags[m.spellID][flagName] = true
                    elseif changes[flagName] == '-' then
                        self.cachedMountFlags[m.spellID][flagName] = nil
                    end
                end
            end
        end
        if m.isFavorite then
            self.cachedMountFlags[m.spellID].FAVORITES = true
        end
    end

    return self.cachedMountFlags[m.spellID]
end

function LM.Options:SetMountFlag(m, setFlag)
    LM.Debug(format("Setting flag %s for spell %s (%d).",
                    setFlag, m.name, m.spellID))

    if setFlag == "FAVORITES" or setFlag == "NONE" or setFlag == "CASTABLE" then
        -- This needs to fire to reset the UI, because something went wrong
        self.db.callbacks:Fire("OnOptionsModified")
        return
    end

    -- Note this is the actual cached copy, we can only change it here
    -- (and below in ClearMountFlag) because we are invalidating the cache
    -- straight after.
    local flags = self:ApplyMountFlags(m)
    flags[setFlag] = true
    self:SetMountFlags(m, flags)
end

function LM.Options:ClearMountFlag(m, clearFlag)
    LM.Debug(format("Clearing flag %s for spell %s (%d).",
                     clearFlag, m.name, m.spellID))

    -- See note above
    local flags = self:ApplyMountFlags(m)
    flags[clearFlag] = nil
    self:SetMountFlags(m, flags)
end

function LM.Options:ResetMountFlags(m)
    LM.Debug(format("Defaulting flags for spell %s (%d).", m.name, m.spellID))
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
    self.db.profile.flagChanges[m.spellID] = FlagDiff(self.allFlags, m.flags, flags)
    self.cachedMountFlags[m.spellID] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Custom flags
----------------------------------------------------------------------------]]--

function LM.Options:GetRawFlags()
    return self.db.profile.customFlags
end

function LM.Options:SetRawFlags(v)
    self.db.profile.customFlags = v
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:IsPrimaryFlag(f)
    -- These are pseudo-flags used in Mount:MatchesOneFilter and we don't
    -- let custom flags have the name.
    if f == "NONE" or f == "CASTABLE" then
        return true
    else
        return LM.FLAG[f] ~= nil
    end
end

function LM.Options:IsCustomFlag(f)
    return self.db.profile.customFlags[f] ~= nil
end

function LM.Options:IsActiveFlag(f)
    return self:IsPrimaryFlag(f) or self:IsCustomFlag(f)
end

function LM.Options:CreateFlag(f)
    if self.db.profile.customFlags[f] then return end
    if self:IsPrimaryFlag(f) then return end
    self.db.profile.customFlags[f] = { }
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:DeleteFlag(f)
    self.db.profile.customFlags[f] = nil
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:RenameFlag(f, newF)
    if self:IsPrimaryFlag(f) then return end
    if f == newF then return end

    -- all this "tmp" stuff is to deal with f == newF, just in case
    local tmp

    for _,c in pairs(self.db.profile.flagChanges) do
        tmp = c[f]
        c[f] = nil
        c[newF] = tmp
    end

    tmp = self.db.profile.customFlags[f]
    self.db.profile.customFlags[f] = nil
    self.db.profile.customFlags[newF] = tmp

    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

-- This keeps a cached list of all flags in sort order, with the LM.FLAG
-- set of flags first, then the user-added flags in alphabetical order

function LM.Options:UpdateFlagCache()
    self.cachedMountFlags = wipe(self.cachedMountFlags or {})
    self.allFlags = wipe(self.allFlags or {})

    for f in pairs(LM.FLAG) do tinsert(self.allFlags, f) end
    for f in pairs(self.db.profile.customFlags) do tinsert(self.allFlags, f) end

    sort(self.allFlags,
        function (a, b)
            if LM.FLAG[a] and LM.FLAG[b] then
                return LM.FLAG[a] < LM.FLAG[b]
            elseif LM.FLAG[a] then
                return true
            elseif LM.FLAG[b] then
                return false
            else
                return a < b
            end
        end)
end

function LM.Options:GetAllFlags()
    if not self.allFlags then
        self:UpdateFlagCache()
    end
    return CopyTable(self.allFlags)
end

--[[----------------------------------------------------------------------------
    Rules stuff.
----------------------------------------------------------------------------]]--

function LM.Options:GetRules(n)
    return self.db.profile.rules[n]
end

function LM.Options:SetRules(n, rules)
    self.db.profile.rules[n] = rules
end

--[[----------------------------------------------------------------------------
    Copy targets mount
----------------------------------------------------------------------------]]--

function LM.Options:GetCopyTargetsMount()
    return self.db.profile.copyTargetsMount
end

function LM.Options:SetCopyTargetsMount(v)
    if v then
        self.db.profile.copyTargetsMount = true
    else
        self.db.profile.copyTargetsMount = false
    end
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Only use instant cast mounts when moving
----------------------------------------------------------------------------]]--

function LM.Options:GetInstantOnlyMoving()
    return self.db.profile.instantOnlyMoving
end

function LM.Options:SetInstantOnlyMoving(v)
    if v then
        self.db.profile.instantOnlyMoving = true
    else
        self.db.profile.instantOnlyMoving = false
    end
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Exclude new mounts
----------------------------------------------------------------------------]]--

function LM.Options:GetExcludeNewMounts()
    return self.db.profile.excludeNewMounts
end

function LM.Options:SetExcludeNewMounts(v)
    if v then
        self.db.profile.excludeNewMounts = true
    else
        self.db.profile.excludeNewMounts = false
    end
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Unavailable macro
----------------------------------------------------------------------------]]--

function LM.Options:GetUnavailableMacro()
    return self.db.char.unvailableMacro
end

function LM.Options:GetUseUnavailableMacro()
    return self.db.char.useUnavailableMacro
end

function LM.Options:SetUnavailableMacro(v)
    self.db.char.unvailableMacro = v
    self.db.char.useUnavailableMacro = (v ~= "")
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Combat macro
----------------------------------------------------------------------------]]--

function LM.Options:GetCombatMacro()
    return self.db.char.combatMacro
end

function LM.Options:SetCombatMacro(v)
    self.db.char.combatMacro = v
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetUseCombatMacro()
    return self.db.char.useCombatMacro
end

function LM.Options:SetUseCombatMacro(v)
    self.db.char.useCombatMacro = v
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Random persistence
----------------------------------------------------------------------------]]--

function LM.Options:GetRandomPersistence()
    return self.db.profile.randomKeepSeconds
end

function LM.Options:SetRandomPersistence(v)
    v = tonumber(v) or 0
    if v then
        self.db.profile.randomKeepSeconds = math.max(0, v)
    end
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Button action lists
----------------------------------------------------------------------------]]--

function LM.Options:GetButtonAction(i)
    return self.db.profile.buttonActions[i]
end

function LM.Options:SetButtonAction(i, v)
    self.db.profile.buttonActions[i] = v
    LiteMount.actions[i]:CompileActions()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetDefaultButtonAction()
     return self.db.defaults.profile.buttonActions['*']
end


--[[----------------------------------------------------------------------------
    Instance recording
----------------------------------------------------------------------------]]--


function LM.Options:RecordInstance(info)
    self.db.global.instances[info[8]] = info[1]
end


--[[----------------------------------------------------------------------------
    Debug settings
----------------------------------------------------------------------------]]--

function LM.Options:GetDebug(v)
    return self.db.char.debugEnabled
end

function LM.Options:SetDebug(v)
    self.db.char.debugEnabled = not not v
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM.Options:GetUIDebug()
    return self.db.char.uiDebugEnabled
end

function LM.Options:SetUIDebug(v)
    self.db.char.uiDebugEnabled = not not v
    self.db.callbacks:Fire("OnOptionsModified")
end

--[[----------------------------------------------------------------------------
    Import/Export Profile
----------------------------------------------------------------------------]]--

function LM.Options:ExportProfile(profileName)
    local currentProfileName = self.db:GetCurrentProfile()

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

