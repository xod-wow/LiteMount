--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

  Copyright 2011-2017 Mike Battersby

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

customFlags is a table of flag names, with data about them (currently only
whether they are used in the drop-down filter list or not)

    customFlags = {
        ["PASSENGER"] = { filter = true }
    }

----------------------------------------------------------------------------]]--

local DefaultButtonAction = [[
LeaveVehicle
Dismount
CancelForm
CopyTargetsMount
Mount [filter=VASHJIR][area:610/614/615,submerged]
Mount [filter=AQ][area:766,noflyable,nosubmerged]
Mount [filter=NAGRAND][area:950,noflyable,nosubmerged]
Mount [filter=230987][nosubmerged,extra:202477]
Mount [filter=230987][nosubmerged,aura:202477]
SmartMount [filter={CLASS}]
SmartMount [filter=~FLY][mod:shift]
SmartMount
Macro
]]

local OldNoFlyAction = [[
LeaveVehicle
Dismount
CancelForm
CopyTargetsMount
Mount [filter=VASHJIR][area:610/614/615,submerged]
Mount [filter=AQ][area:766,noflyable,nosubmerged]
Mount [filter=NAGRAND][area:950,noflyable,nosubmerged]
Mount [filter=230987][nosubmerged,extra:202477]
Mount [filter=230987][nosubmerged,aura:202477]
SmartMount [filter={CLASS}]
SmartMount [filter=~FLY]
Macro
]]

local OldCustom1Action = [[
LeaveVehicle
Dismount
CancelForm
CopyTargetsMount
Mount [filter=CUSTOM1]
Macro
]]

local OldCustom2Action = [[
LeaveVehicle
Dismount
CancelForm
CopyTargetsMount
Mount [filter=CUSTOM2]
Macro
]]

local defaults = {
    global = {
        customFlags         = { },
    },
    profile = {
        excludedSpells      = { },
        flagChanges         = { },
        buttonActions       = { ['*'] = DefaultButtonAction },
        excludeNewMounts    = false,
    },
    char = {
        unavailableMacro    = "",
        useUnavailableMacro = false,
        combatMacro         = "",
        useCombatMacro      = false,
        copyTargetsMount    = true,
        -- If changed these are not preserved because nil becomes defaults
        uiMountFilterList   = { NOT_COLLECTED = true, UNUSABLE = true },
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
    for _,p in pairs(self.db.profiles) do
        for _,changes in pairs(p.flagChanges or {}) do
            if changes[f] then return true end
        end
    end
    return false
end

function LM_Options:VersionUpgrade()

    if not self.db.profile.configVersion then
        self.db.profile.buttonActions[2] = OldNoFlyAction

        if self:FlagIsUsed('CUSTOM1') then
            self.db.profile.buttonActions[3] = OldCustom1Action
        end

        if self:FlagIsUsed('CUSTOM2') then
            self.db.profile.buttonActions[4] = OldCustom2Action
        end
    end

    self.db.global.configVersion = 1
    self.db.profile.configVersion = 1
end

function LM_Options:ConsistencyCheck()
    -- Make sure any flag in any profile is included in the flag list
    for _,p in pairs(self.db.profiles) do
        for _,c in pairs(p.flagChanges or {}) do
            for f in pairs(c) do
                if LM_FLAG[f] == nil and self.db.global.customFlags[f] == nil then
                    self.db.global.customFlags[f] = { filter = true }
                end
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
    return self.db.profile.excludedSpells[m.spellID]
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = true
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m.name, m.spellID))
    self.db.profile.excludedSpells[m.spellID] = false
end

function LM_Options:ToggleExcludedMount(m)
    local id = m.spellID
    LM_Debug(format("Toggling mount %s (%d).", m.name, id))
    self.db.profile.excludedSpells[id] = not self.db.profile.excludedSpells[id]
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

    if not m.currentFlags then
        local changes = self.db.profile.flagChanges[m.spellID]
        m.currentFlags = CopyTable(m.flags)

        if changes then
            for _,flagName in ipairs(self.allFlags) do
                if changes[flagName] == '+' then
                    m.currentFlags[flagName] = true
                elseif changes[flagName] == '-' then
                    m.currentFlags[flagName] = nil
                end
            end
        end
    end

    return m.currentFlags
end

function LM_Options:SetMountFlag(m, setFlag)
    LM_Debug(format("Setting flag %s for spell %s (%d).",
                    setFlag, m.name, m.spellID))

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
    m.currentFlags = nil
end

function LM_Options:SetMountFlags(m, flags)
    self.db.profile.flagChanges[m.spellID] = FlagDiff(self.allFlags, m.flags, flags)
    m.currentFlags = nil
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

function LM_Options:CreateFlag(f, isFilter)
    if self.db.global.customFlags[f] then return end
    if self:IsPrimaryFlag(f) then return end
    if isFilter == nil then isFilter = true end
    self.db.global.customFlags[f] = { filter = (isFilter and true or false) }
    self:UpdateAllFlags()
end

function LM_Options:DeleteFlag(f)
    for _,p in pairs(self.db.profiles) do
        for _,c in pairs(p.flagChanges) do
            c[f] = nil
        end
    end
    self.db.global.customFlags[f] = nil
    self:UpdateAllFlags()
end

function LM_Options:RenameFlag(f, newF)
    local tmp
    if self:IsPrimaryFlag(f) then return end
    if f == newF then return end
    for _,p in pairs(self.db.profiles) do
        for _,c in pairs(p.flagChanges) do
            tmp = c[f]
            c[f] = nil
            c[newF] = tmp
        end
    end
    tmp = self.db.global.customFlags[f]
    self.db.global.customFlags[f] = nil
    self.db.global.customFlags[newF] = tmp
    self:UpdateAllFlags()
end

-- This keeps a cached list of all flags in sort order, with the LM_FLAG
-- set of flags first, then the user-added flags in alphabetical order

function LM_Options:UpdateAllFlags()
    local index = {}

    self.allFlags = wipe(self.allFlags or {})

    for f in pairs(LM_FLAG) do tinsert(self.allFlags, f) end
    for f in pairs(self.db.global.customFlags) do tinsert(self.allFlags, f) end

    sort(self.allFlags,
        function (a, b)
            if LM_FLAG[a] and LM_FLAG[b] then
                return LM_FLAG[a] <= LM_FLAG[b]
            elseif LM_FLAG[a] then
                return true
            elseif LM_FLAG[b] then
                return false
            else
                return a <= b
            end
        end)
end

function LM_Options:GetAllFlags()
    return CopyTable(self.allFlags)
end

function LM_Options:IsFilterFlag(f)
    if self:IsPrimaryFlag(f) then return true end

    local cf = self.db.global.customFlags[f]
    if cf and cf.filter == true then return true end
    return false
end

--[[----------------------------------------------------------------------------
    Have we seen a mount before on this toon?
    Includes automatically adding it to the excludes if requested.
----------------------------------------------------------------------------]]--

function LM_Options:SeenMount(m)
    local spellID = m.spellID

    if self.db.profile.excludedSpells[spellID] == nil then
        self.db.profile.excludedSpells[spellID] = self.db.profile.excludeNewMounts
    end
end
