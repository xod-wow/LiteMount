--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

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
# Slow Fall, Levitate, Zen Flight, Glide
Spell [falling] 130, 1706, 125883, 131347
LeaveVehicle
CancelForm
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
SmartMount
Macro
]]

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
        copyTargetsMount    = true,
        enableTwoPress      = false,
        excludeNewMounts    = false,
        priorityWeights     = { 1, 2, 6 },
        randomKeepSeconds   = 0,
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

_G.LM_Options = {
    MIN_PRIORITY = 0,
    MAX_PRIORITY = 3,
    DISABLED_PRIORITY = 0,
    DEFAULT_PRIORITY = 1,
}


local function FlagDiff(allFlags, a, b)
    local diff = { }

    for _,flagName in ipairs(allFlags) do
        if a[flagName] and not b[flagName] then
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

function LM_Options:FlagIsUsed(f)
    for spellID,changes in pairs(self.db.profile.flagChanges) do
        if changes[f] then return true end
    end
    return false
end

-- Note to self. In any profile except the active one, the defaults
-- are not applied and you can't rely on them being there.

function LM_Options:VersionUpgrade()

    -- From 1 -> 2 moved a bunch of stuff from char to profile that
    -- can't be migrated.

    if (self.db.global.configVersion or 2) < 2 then
        self.db.global.enableTwoPress = nil
    end

    if (self.db.char.configVersion or 2) < 2 then
        self.db.char.copyTargetsMount = nil
        self.db.char.uiMountFilterList = nil
    end

    -- Version 3 moved flag stuff global, and now version 4 is putting them
    -- back into profile. I hope I'm not making the same mistakes all over
    -- again. "Those who cannot remember the past are condemned to repeat it."

    if (self.db.global.configVersion or 4) < 4 then
        for _,p in pairs(self.db.profiles) do
            p.flagChanges = p.flagChanges or {}
            p.customFlags = p.customFlags or {}
            for spellID,changes in pairs(self.db.global.flagChanges or {}) do
                p.flagChanges[spellID] = Mixin(p.flagChanges[spellID] or {}, changes)
            end
            Mixin(p.customFlags, self.db.global.customFlags or {})
            p.configVersion = 4
        end
        self.db.global.customFlags = nil
        self.db.global.flagChanges = nil
    end

    -- Version 5
    -- Changed profile.excludedSpells into profile.mountPriorities
    -- Removed any persistance for the GUI filters

    if (self.db.global.configVersion or 5) < 5 then
        for _,p in pairs(self.db.profiles) do
            p.mountPriorities = p.mountPriorities or {}
            for spellID,isExcluded in pairs(p.excludedSpells or {}) do
                if isExcluded then
                    p.mountPriorities[spellID] = self.DISABLED_PRIORITY
                else
                    p.mountPriorities[spellID] = self.DEFAULT_PRIORITY
                end
            end
            p.excludedSpells = nil
            p.uiMountFilterList = nil
            p.enableTwoPress = nil
            p.configVersion = 5
        end
    end

    -- Set current version
    self.db.global.configVersion = 5
    self.db.char.configVersion = 5
end

-- We don't delete flags from the profile flagChanges on delete, because
-- that lets us undo the flag delete by just putting it back.

function LM_Options:PruneDeletedFlags()
    for spellID,changes in pairs(self.db.profile.flagChanges) do
        for f in pairs(changes) do
            if not self:IsActiveFlag(f) then
                self.db.profile.flageChanges[f] = nil
            end
        end
    end
end

function LM_Options:OnProfile()
    self:PruneDeletedFlags()
    self:UpdateFlagCache()
    self:InitializePriorities()
    LiteMount:RecompileActions()
    self.db.callbacks:Fire("OnOptionsModified", true)
end

function LM_Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)
    self:VersionUpgrade()
    self:PruneDeletedFlags()
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfile")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfile")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfile")
end


--[[----------------------------------------------------------------------------
    Mount priorities stuff.
----------------------------------------------------------------------------]]--

function LM_Options:GetRawMountPriorities()
    return self.db.profile.mountPriorities
end

function LM_Options:SetRawMountPriorities(v)
    self.db.profile.mountPriorities = v
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:GetPriority(m)
    local p = self.db.profile.mountPriorities[m.spellID]
    return p, (self.db.profile.priorityWeights[p] or 0)
end

function LM_Options:InitializePriorities()
    for _,m in ipairs(LM_PlayerMounts.mounts) do
        if not self.db.profile.mountPriorities[m.spellID] then
            if self.db.profile.excludeNewMounts then
                self.db.profile.mountPriorities[m.spellID] = self.DISABLED_PRIORITY
            else
                self.db.profile.mountPriorities[m.spellID] = self.DEFAULT_PRIORITY
            end
        end
    end
end

function LM_Options:SetPriority(m, v)
    LM_Debug(format("Setting mount %s (%d) to priority %d", m.name, m.spellID, v))
    v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    self.db.profile.mountPriorities[m.spellID] = v
    self.db.callbacks:Fire("OnOptionsModified")
end

-- Don't just loop over SetPriority because we don't want the UI to freeze up
-- with hundreds of unnecessary callback refreshes.

function LM_Options:SetPriorities(mountlist, v)
    LM_Debug(format("Setting %d mounts to priority %d", #mountlist, v))
    v = math.max(self.MIN_PRIORITY, math.min(self.MAX_PRIORITY, v))
    for _,m in ipairs(mountlist) do
        self.db.profile.mountPriorities[m.spellID] = v
    end
    self.db.callbacks:Fire("OnOptionsModified")
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:GetRawFlagChanges()
    return self.db.profile.flagChanges
end

function LM_Options:SetRawFlagChanges(v)
    self.db.profile.flagChanges = v
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:ApplyMountFlags(m)

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

function LM_Options:SetMountFlag(m, setFlag)
    LM_Debug(format("Setting flag %s for spell %s (%d).",
                    setFlag, m.name, m.spellID))

    if setFlag == "FAVORITES" then
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

function LM_Options:ClearMountFlag(m, clearFlag)
    LM_Debug(format("Clearing flag %s for spell %s (%d).",
                     clearFlag, m.name, m.spellID))

    -- See note above
    local flags = self:ApplyMountFlags(m)
    flags[clearFlag] = nil
    self:SetMountFlags(m, flags)
end

function LM_Options:ResetMountFlags(m)
    LM_Debug(format("Defaulting flags for spell %s (%d).", m.name, m.spellID))
    self.db.profile.flagChanges[m.spellID] = nil
    self.cachedMountFlags[m.spellID] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:ResetAllMountFlags()
    table.wipe(self.db.profile.flagChanges)
    table.wipe(self.cachedMountFlags)
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:SetMountFlags(m, flags)
    self.db.profile.flagChanges[m.spellID] = FlagDiff(self.allFlags, m.flags, flags)
    self.cachedMountFlags[m.spellID] = nil
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Custom flags
----------------------------------------------------------------------------]]--

function LM_Options:GetRawFlags()
    return self.db.profile.customFlags
end

function LM_Options:SetRawFlags(v)
    self.db.profile.customFlags = v
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:IsPrimaryFlag(f)
    return LM_FLAG[f] ~= nil
end

function LM_Options:IsCustomFlag(f)
    return self.db.profile.customFlags[f] ~= nil
end

function LM_Options:IsActiveFlag(f)
    return self:IsPrimaryFlag(f) or self:IsCustomFlag(f)
end

-- Empty strings and primary flag names are not valid
function LM_Options:IsValidNewFlagName(n)
    if n == "" or self:IsPrimaryFlag(n) then
        return false
    end
    return true
end

function LM_Options:CreateFlag(f)
    if self.db.profile.customFlags[f] then return end
    if self:IsPrimaryFlag(f) then return end
    self.db.profile.customFlags[f] = { }
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:DeleteFlag(f)
    self.db.profile.customFlags[f] = nil
    self:UpdateFlagCache()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:RenameFlag(f, newF)
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

-- This keeps a cached list of all flags in sort order, with the LM_FLAG
-- set of flags first, then the user-added flags in alphabetical order

function LM_Options:UpdateFlagCache()
    self.cachedMountFlags = wipe(self.cachedMountFlags or {})
    self.allFlags = wipe(self.allFlags or {})

    for f in pairs(LM_FLAG) do tinsert(self.allFlags, f) end
    for f in pairs(self.db.profile.customFlags) do tinsert(self.allFlags, f) end

    sort(self.allFlags,
        function (a, b)
            if LM_FLAG[a] and LM_FLAG[b] then
                return LM_FLAG[a] < LM_FLAG[b]
            elseif LM_FLAG[a] then
                return true
            elseif LM_FLAG[b] then
                return false
            else
                return a < b
            end
        end)
end

function LM_Options:GetAllFlags()
    if not self.allFlags then
        self:UpdateFlagCache()
    end
    return CopyTable(self.allFlags)
end


--[[----------------------------------------------------------------------------
    Copy targets mount
----------------------------------------------------------------------------]]--

function LM_Options:GetCopyTargetsMount()
    return self.db.profile.copyTargetsMount
end

function LM_Options:SetCopyTargetsMount(v)
    if v then
        self.db.profile.copyTargetsMount = true
    else
        self.db.profile.copyTargetsMount = false
    end
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Exclude new mounts
----------------------------------------------------------------------------]]--

function LM_Options:GetExcludeNewMounts()
    return self.db.profile.excludeNewMounts
end

function LM_Options:SetExcludeNewMounts(v)
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

function LM_Options:GetUnavailableMacro()
    return self.db.char.unvailableMacro
end

function LM_Options:GetUseUnavailableMacro()
    return self.db.char.useUnavailableMacro
end

function LM_Options:SetUnavailableMacro(v)
    self.db.char.unvailableMacro = v
    self.db.char.useUnavailableMacro = (v ~= "")
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Combat macro
----------------------------------------------------------------------------]]--

function LM_Options:GetCombatMacro()
    return self.db.char.combatMacro
end

function LM_Options:SetCombatMacro(v)
    self.db.char.combatMacro = v
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:GetUseCombatMacro()
    return self.db.char.useCombatMacro
end

function LM_Options:SetUseCombatMacro(v)
    self.db.char.useCombatMacro = v
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Random persistence
----------------------------------------------------------------------------]]--

function LM_Options:GetRandomPersistence()
    return self.db.profile.randomKeepSeconds
end

function LM_Options:SetRandomPersistence(v)
    v = tonumber(v) or 0
    if v then
        self.db.profile.randomKeepSeconds = math.max(0, v)
    end
    self.db.callbacks:Fire("OnOptionsModified")
end


--[[----------------------------------------------------------------------------
    Button action lists
----------------------------------------------------------------------------]]--

function LM_Options:GetButtonAction(i)
    return self.db.profile.buttonActions[i]
end

function LM_Options:SetButtonAction(i, v)
    self.db.profile.buttonActions[i] = v
    LiteMount.actions[i]:CompileActions()
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:GetDefaultButtonAction()
     return self.db.defaults.profile.buttonActions['*']
end


--[[----------------------------------------------------------------------------
    Instance recording
----------------------------------------------------------------------------]]--


function LM_Options:RecordInstance()
    local name, _, _, _, _, _, _, id = GetInstanceInfo()
    if not self.db.global.instances[id] then
        self.db.global.instances[id] = name
    end
end


--[[----------------------------------------------------------------------------
    Debug settings
----------------------------------------------------------------------------]]--

function LM_Options:GetDebug(v)
    return self.db.char.debugEnabled
end

function LM_Options:SetDebug(v)
    self.db.char.debugEnabled = not not v
    self.db.callbacks:Fire("OnOptionsModified")
end

function LM_Options:GetUIDebug()
    return self.db.char.uiDebugEnabled
end

function LM_Options:SetUIDebug(v)
    self.db.char.uiDebugEnabled = not not v
    self.db.callbacks:Fire("OnOptionsModified")
end
