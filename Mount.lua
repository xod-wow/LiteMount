--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Mount = { }
LM.Mount.__index = LM.Mount

function LM.Mount:new()
    return setmetatable({ }, self)
end

function LM.Mount:Get(className, ...)
    local class = LM[className]

    local m = class:Get(...)
    if not m then return end

    return m
end

function LM.Mount:CurrentFlags()
    return LM.Options:ApplyMountFlags(self)
end

function LM.Mount:Refresh()
    -- Nothing in base
end

function LM.Mount:MatchesOneFilter(flags, f)
    if f == "CASTABLE" then
        if self:IsCastable() then return true end
    elseif tonumber(f) then
        if self.spellID == tonumber(f) then return true end
    elseif f:sub(1, 3) == 'id:' then
        if self.mountID == tonumber(f:sub(4)) then return true end
    elseif f:sub(1, 3) == 'mt:' then
        if self.mountType == tonumber(f:sub(4)) then return true end
    elseif f:sub(1, 1) == '~' then
        if not self:MatchesOneFilter(flags, f:sub(2)) then return true end
    else
        if flags[f] ~= nil then return true end
    end
end

function LM.Mount:MatchesFilter(flags, filterStr)

    if self.name == filterStr then
        return true
    end

    local filters = { strsplit('/', filterStr) }

    -- These are all ORed so return true as soon as one is true

    for _, f in ipairs(filters) do
        if self:MatchesOneFilter(flags, f) then
            return true
        end
    end

    return false
end

function LM.Mount:MatchesFilters(...)
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

function LM.Mount:FlagsSet(checkFlags)
    for _,f in ipairs(checkFlags) do
        if self.flags[f] == nil then return false end
    end
    return true
end

function LM.Mount:IsActive(buffTable)
    return buffTable[self.spellID]
end

function LM.Mount:IsCastable()
    if LM.Environment:IsMovingOrFalling() then
        local castTime = select(4, GetSpellInfo(self.spellID))
        if castTime > 0 then return false end
    end
    return true
end

function LM.Mount:IsCancelable()
    return true
end

-- These should probably not be making new identical objects all tha time.

function LM.Mount:GetCastAction()
    local spellName = GetSpellInfo(self.spellID)
    return LM.SecureAction:Spell(spellName)
end

function LM.Mount:GetCancelAction()
    local spellName = GetSpellInfo(self.spellID)
    return LM.SecureAction:CancelAura(spellName)
end

function LM.Mount:Dump(prefix)
    prefix = prefix or ""

    local spellName = GetSpellInfo(self.spellID)

    local currentFlags, defaultFlags = {}, {}
    for f in pairs(self:CurrentFlags()) do tinsert(currentFlags, f) end
    for f in pairs(self.flags) do tinsert(defaultFlags, f) end
    sort(currentFlags)
    sort(defaultFlags)

    LM.Print("--- Mount Dump ---")
    LM.Print(prefix .. self.name)
    LM.Print(prefix .. " spell: " .. format("%s (id %d)", spellName, self.spellID))
    LM.Print(prefix .. " flags: " ..
             format("%s (default %s)",
                    table.concat(currentFlags, ','),
                    table.concat(defaultFlags, ',')
                   )
            )
    LM.Print(prefix .. " mountID: " .. tostring(self.mountID))
    LM.Print(prefix .. " isCollected: " .. tostring(self.isCollected))
    LM.Print(prefix .. " isFavorite: " .. tostring(self.isFavorite))
    LM.Print(prefix .. " isFiltered: " .. tostring(self.isFiltered))
    LM.Print(prefix .. " priority: " .. tostring(LM.Options:GetPriority(self)))
    LM.Print(prefix .. " castable: " .. tostring(self:IsCastable()) .. " (spell " .. tostring(IsUsableSpell(self.spellID)) .. ")")
end
