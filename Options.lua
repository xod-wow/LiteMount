--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

--[[----------------------------------------------------------------------------

excludedSpells is a table of spell ids the player has seen before, with
the value true if excluded and false if not excluded

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

local DefaultButtonAction = [[
LeaveVehicle
CancelForm
Dismount
CopyTargetsMount
Mount [filter=VASHJIR][area:203,submerged]
Mount [filter=AQ][area:319/320/321,noflyable,nosubmerged]
Mount [filter=NAGRAND][area:550,noflyable,nosubmerged]
Mount [filter=230987][nosubmerged,extra:202477]
Mount [filter=230987][nosubmerged,aura:202477]
SmartMount [filter={CLASS}]
SmartMount [filter=~FLY][mod:shift]
SmartMount
Macro
]]

-- A lot of things need to be cleaned up when flags are deleted/renamed

local defaults = {
    global = {
        customFlags         = { },
        flagChanges         = { },
    },
    profile = {
        excludedSpells      = { },
        buttonActions       = { ['*'] = DefaultButtonAction },
        copyTargetsMount    = true,
        enableTwoPress      = false,
        excludeNewMounts    = false,
        uiMountFilterList   = { UNUSABLE = true },
    },
    char = {
        unavailableMacro    = "",
        useUnavailableMacro = false,
        combatMacro         = "",
        useCombatMacro      = false,
        debugEnabled        = false,
    },
}

_G.LM_Options = { }

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
    for spellID,changes in pairs(self.db.global.flagChanges) do
        if changes[f] then return true end
    end
    return false
end

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

    if (self.db.global.configVersion or 3) < 3 then
        local gfc = self.db.global.flagChanges

        -- Merge all of the profile flagChanges into one global one
        for _,p in pairs(self.db.profiles) do
            for spellID,changes in pairs(p.flagChanges or {}) do
                gfc[spellID] = Mixin(gfc[spellID] or {}, changes)
            end
            p.flagChanges = nil
        end
    end

    -- Set current version
    self.db.global.configVersion = 3
    self.db.profile.configVersion = 3
    self.db.char.configVersion = 3
end

function LM_Options:ConsistencyCheck()

    -- Make sure any flag is included in the flag list

    for spellID,changes in pairs(self.db.global.flagChanges) do
        for f in pairs(changes) do
            if LM_FLAG[f] == nil and self.db.global.customFlags[f] == nil then
                self.db.global.customFlags[f] = { }
            end
        end
    end

end

function LM_Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LiteMountDB", defaults, true)
    self:VersionUpgrade()
    self:ConsistencyCheck()
    self:UpdateAllFlags()
end


--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    return self.db.profile.excludedSpells[m.spellID] == true
end

function LM_Options:InitializeExcludedMount(m)
    
    if self.db.profile.excludedSpells[m.spellID] ~= nil then
        return
    end

    if self.db.profile.excludeNewMounts then
        LM_Debug(format("Disabled newly added mount %s (%d).", m.name, m.spellID))
        self.db.profile.excludedSpells[m.spellID] = true
    else
        self.db.profile.excludedSpells[m.spellID] = false
        LM_Debug(format("Enabled newly added mount %s (%d).", m.name, m.spellID))
    end
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = true
    self.db.callbacks:Fire("OnMountSetExclude", m)
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = false
    self.db.callbacks:Fire("OnMountSetExclude", m)
end

function LM_Options:ToggleExcludedMount(m)
    local id = m.spellID
    LM_Debug(format("Toggling mount %s (%d).", m.name, id))
    self.db.profile.excludedSpells[id] = not self.db.profile.excludedSpells[id]
    self.db.callbacks:Fire("OnMountSetExclude", m)
end

function LM_Options:SetExcludedMounts(mountlist)
    LM_Debug("Setting complete list of disabled mounts.")
    for k in pairs(self.db.profile.excludedSpells) do
        self.db.profile.excludedSpells[k] = false
    end
    for _,m in ipairs(mountlist) do
        self:AddExcludedMount(m)
    end
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)

    if not self.cachedMountFlags[m.spellID] then
        local changes = self.db.global.flagChanges[m.spellID]
        self.cachedMountFlags[m.spellID] = CopyTable(m.flags)

        if changes then
            for _,flagName in ipairs(self.allFlags) do
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
    else
        self.cachedMountFlags[m.spellID].FAVORITES = nil
    end
    return self.cachedMountFlags[m.spellID]
end

function LM_Options:SetMountFlag(m, setFlag)
    LM_Debug(format("Setting flag %s for spell %s (%d).",
                    setFlag, m.name, m.spellID))

    if setFlag == "FAVORITES" then
        if m.SetFavorite ~= nil then
            m:SetFavorite(true)
        end
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

    if clearFlag == "FAVORITES" then
        if m.SetFavorite ~= nil then
            m:SetFavorite(false)
        end
        return
    end

    -- See note above
    local flags = self:ApplyMountFlags(m)
    flags[clearFlag] = nil
    self:SetMountFlags(m, flags)
end

function LM_Options:ResetMountFlags(m)
    LM_Debug(format("Defaulting flags for spell %s (%d).", m.name, m.spellID))
    self.db.global.flagChanges[m.spellID] = nil
    self.cachedMountFlags[m.spellID] = nil
end

function LM_Options:SetMountFlags(m, flags)
    self.db.global.flagChanges[m.spellID] = FlagDiff(self.allFlags, m.flags, flags)
    self.cachedMountFlags[m.spellID] = nil
end


--[[----------------------------------------------------------------------------
    Custom flags
----------------------------------------------------------------------------]]--

function LM_Options:IsPrimaryFlag(f)
    return LM_FLAG[f] ~= nil
end

-- Empty strings and primary flag names are not valid
function LM_Options:IsValidFlagName(n)
    if n == "" or self:IsPrimaryFlag(n) then
        return false
    end
    return true
end

function LM_Options:CreateFlag(f)
    if self.db.global.customFlags[f] then return end
    if self:IsPrimaryFlag(f) then return end
    self.db.global.customFlags[f] = { }
    self.db.profile.uiMountFilterList[f] = false
    self:UpdateAllFlags()
    self.db.callbacks:Fire("OnFlagsModified")
end

function LM_Options:DeleteFlag(f)
    for _,c in pairs(self.db.global.flagChanges) do
        c[f] = nil
    end
    self.db.profile.uiMountFilterList[f] = nil
    self.db.global.customFlags[f] = nil
    self:UpdateAllFlags()
    self.db.callbacks:Fire("OnFlagsModified")
end

function LM_Options:RenameFlag(f, newF)
    if self:IsPrimaryFlag(f) then return end
    if f == newF then return end

    -- all this "tmp" stuff is to deal with f == newF, just in case
    local tmp

    for _,c in pairs(self.db.global.flagChanges) do
        tmp = c[f]
        c[f] = nil
        c[newF] = tmp
    end

    for _,p in pairs(self.db.profiles) do
        tmp = p.uiMountFilterList[f]
        p.uiMountFilterList[f] = nil
        p.uiMountFilterList[newF] = tmp
    end

    tmp = self.db.global.customFlags[f]
    self.db.global.customFlags[f] = nil
    self.db.global.customFlags[newF] = tmp

    self:UpdateAllFlags()
    self.db.callbacks:Fire("OnFlagsModified")
end

-- This keeps a cached list of all flags in sort order, with the LM_FLAG
-- set of flags first, then the user-added flags in alphabetical order

function LM_Options:UpdateAllFlags()
    self.cachedMountFlags = wipe(self.cachedMountFlags or {})
    self.allFlags = wipe(self.allFlags or {})

    for f in pairs(LM_FLAG) do tinsert(self.allFlags, f) end
    for f in pairs(self.db.global.customFlags) do tinsert(self.allFlags, f) end

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
    return CopyTable(self.allFlags)
end

