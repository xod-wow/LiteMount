--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_Mount = { }
LM_Mount.__index = LM_Mount

function LM_Mount:new()
    return setmetatable({ }, self)
end

function LM_Mount:Get(className, ...)
    local class = _G["LM_"..className]

    local m = class:Get(...)
    if not m then return end

    return m
end

function LM_Mount:CurrentFlags()
    return LM_Options:ApplyMountFlags(self)
end

function LM_Mount:Refresh()
    -- Nothing in base
end

function LM_Mount:MatchesFilter(flags, f)

    if f == "CASTABLE" then
        return self:IsCastable()
    end

    if f == "ENABLED" then
        return LM_Options:IsExcludedMount(self) ~= true
    end

    if tonumber(f) then
        return self.spellID == tonumber(f)
    end

    if f:sub(1, 1) == '~' then
        return flags[f:sub(2)] == nil
    end

    return flags[f] ~= nil
end

function LM_Mount:MatchesFilters(...)
    local currentFlags = self:CurrentFlags()
    local f

    for i = 1, select('#', ...) do
        f = select(i, ...)
        if not self:MatchesFilter(currentFlags, f) then
            return false
        end
    end
    return true
end

function LM_Mount:FlagsSet(checkFlags)
    for _,f in ipairs(checkFlags) do
        if self.flags[f] == nil then return false end
    end
    return true
end

local function PlayerIsMovingOrFalling()
    return (GetUnitSpeed("player") > 0 or IsFalling())
end

function LM_Mount:IsCastable()

    if PlayerIsMovingOrFalling() then
        local castTime = select(4, GetSpellInfo(self.spellID))
        if castTime > 0 then return false end
    end

    return true
end

function LM_Mount:GetSecureAttributes()
    local spellName = GetSpellInfo(self.spellID)
    return { ["type"] = "spell", ["spell"] = spellName }
end

function LM_Mount:Dump(prefix)
    if prefix == nil then
        prefix = ""
    end

    local spellName = GetSpellInfo(self.spellID)
    local currentFlags = CopyTable(self:CurrentFlags())
    local defaultFlags = CopyTable(self.flags)
    sort(currentFlags)
    sort(defaultFlags)

    LM_Print("--- Mount Dump ---")
    LM_Print(prefix .. self.name)
    LM_Print(prefix .. " spell: " .. format("%s (id %d)", spellName, self.spellID))
    LM_Print(prefix .. " flags: " ..
             format("%s (default %s)",
                    table.concat(currentFlags, ','),
                    table.concat(defaultFlags, ',')
                   )
            )
    LM_Print(prefix .. " mountID: " .. tostring(self.mountID))
    LM_Print(prefix .. " isCollected: " .. tostring(self.isCollected))
    LM_Print(prefix .. " isFiltered: " .. tostring(self.isFiltered))
    LM_Print(prefix .. " excluded: " .. tostring(LM_Options:IsExcludedMount(self)))
    LM_Print(prefix .. " castable: " .. tostring(self:IsCastable()) .. " (spell " .. tostring(IsUsableSpell(self.spellID)) .. ")")
end
