--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Mount = { }
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

-- This was a bit of a convenience since bit.isset doesn't exist
function LM_Mount:MatchesFilter(filters)
    local cur = self:CurrentFlags()

    for _,f in ipairs(filters) do
        if string.match(f, '^%d+$') then
            if self.spellID ~= tonumber(f) then return false end
        elseif string.match(f, '^~') then
            if tContains(cur, f:sub(2)) ~= nil then return false end
        elseif string.match(f, '^%w+$') then
            if tContains(cur, f) == nil then return false end
        else
            LM_WarningAndPrint("Invalid filter in action list: " .. f)
        end
    end
    return true
end

function LM_Mount:FlagsSet(checkFlags)
    for _,f in ipairs(checkFlags) do
        if tContains(self.flags, f) == nil then
            return false
        end
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

    LM_Print("--- Mount Dump ---")
    LM_Print(prefix .. self.name)
    LM_Print(prefix .. " spell: " .. format("%s (id %d)", spellName, self.spellID))
    LM_Print(prefix .. " flags: " .. format("%s (default %s)", table.concat(self:CurrentFlags(), ','), table.concat(self.flags, ',')))
    LM_Print(prefix .. " mountID: " .. tostring(self.mountID))
    LM_Print(prefix .. " isCollected: " .. tostring(self.isCollected))
    LM_Print(prefix .. " isFiltered: " .. tostring(self.isFiltered))
    LM_Print(prefix .. " excluded: " .. tostring(LM_Options:IsExcludedMount(self)))
    LM_Print(prefix .. " castable: " .. tostring(self:IsCastable()) .. " (spell " .. tostring(IsUsableSpell(self.spellID)) .. ")")
end
