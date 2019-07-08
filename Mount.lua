--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011-2019 Mike Battersby

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

function LM_Mount:MatchesOneFilter(flags, f)
    if f == "CASTABLE" then
        if self:IsCastable() then return true end
    elseif f == "ENABLED" then
        if LM_Options:IsExcludedMount(self) ~= true then return true end
    elseif tonumber(f) then
        if self.spellID == tonumber(f) then return true end
    elseif f:sub(1, 3) == 'id:' then
        if self.mountID == tonumber(f:sub(4)) then return true end
    elseif f:sub(1, 3) == 'mt:' then
        if self.mountType == tonumber(f:sub(4)) then return true end
    elseif f:sub(1, 1) == '~' then
        if self:MatchesOneFilter(flags, f:sub(2)) then return true end
    else
        if flags[f] ~= nil then return true end
    end
end

function LM_Mount:MatchesFilter(flags, filterStr)

    local filters = { strsplit('/', filterStr) }

    -- These are all ORed so return true as soon as one is true

    for _, f in ipairs(filters) do
        if self:MatchesOneFilter(flags, f) then
            return true
        end
    end

    return false
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
    prefix = prefix or ""

    local spellName = GetSpellInfo(self.spellID)

    local currentFlags, defaultFlags = {}, {}
    for f in pairs(self:CurrentFlags()) do tinsert(currentFlags, f) end
    for f in pairs(self.flags) do tinsert(defaultFlags, f) end
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
    LM_Print(prefix .. " isFavorite: " .. tostring(self.isFavorite))
    LM_Print(prefix .. " isFiltered: " .. tostring(self.isFiltered))
    LM_Print(prefix .. " excluded: " .. tostring(LM_Options:IsExcludedMount(self)))
    LM_Print(prefix .. " castable: " .. tostring(self:IsCastable()) .. " (spell " .. tostring(IsUsableSpell(self.spellID)) .. ")")
end
