--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  List of mounts with some kinds of extra stuff, mostly shuffle/random.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

--[[----------------------------------------------------------------------------

  A primer reminder for me on LUA metatables and doing OO stuff in
  them.  If you rewrite this from scratch don't make it OO, OK.
  See also: http://www.lua.org/pil/13.html

  You can set a "metatable" on a table with
    setmetatable(theTable, theMetaTable)

  Special records in the metatable are used for table access in
  the case that the table key doesn't exist:

    __index = function (table, key) return value end
    __newindex = function (table, key, value) store_value_somehow end

  Also arithmetic and comparison operators: __add __mul __eq __lt __le

  For a full list: http://lua-users.org/wiki/MetatableEvents

  The generic case for metatable "inheritence" is

    baseTable = { whatever }
    childTable = { whateverelse }
    metaTable = { __index = function (t,k) return baseTable[k] end }
    setmetatable(childTable, metaTable)

  This is so common that LUA allows a shortcut where you can set __index
  to be a table instead of a function, and it will do the lookups in
  that table.

    baseTable = { whatever }
    childTable = { whateverelse }
    metaTable = { __index = baseTable }
    setmetatable(childTable, metaTable)

  Then as a further shortcut, instead of requiring a separate metatable
  you can just use the base table itself as the metatable by setting its
  __index record.

    baseTable = { whatever }
    baseTable.__index = baseTable
    setmetatable(childTable, baseTable)

  This is typical class-style OO.

----------------------------------------------------------------------------]]--

LM.MountList = { }
LM.MountList.__index = LM.MountList

function LM.MountList:New(ml)
    return setmetatable(ml or {}, LM.MountList)
end

function LM.MountList:Copy()
    local out = { }
    for i,v in ipairs(self) do
        out[i] = v
    end
    return self:New(out)
end

function LM.MountList:Clear()
    table.wipe(self)
    return self
end

function LM.MountList:Extend(other)
    local exists = { }
    for _,m in ipairs(self) do
        exists[m] = true
    end
    for _,m in ipairs(other) do
        if not exists[m] then
            table.insert(self, m)
        end
    end
    return self
end

function LM.MountList:Reduce(other)
    local remove = { }
    for _,m in ipairs(other) do
        remove[m] = true
    end
    local j, n = 1, #self
    for i = 1, n do
        if remove[self[i]] then
            self[i] = nil
        else
            if i ~= j then
                self[j] = self[i]
                self[i] = nil
            end
            j = j + 1
        end
    end
    return self
end

function LM.MountList:Search(matchfunc, ...)
    local result = self:New()
    for _,m in ipairs(self) do
        if matchfunc(m, ...) then
            tinsert(result, m)
        end
    end
    return result
end

-- Note that Find doesn't make another table
function LM.MountList:Find(matchfunc, ...)
    for _,m in ipairs(self) do
        if matchfunc(m, ...) then
            return m
        end
    end
end

function LM.MountList:Shuffle()
    -- Fisher-Yates algorithm.
    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #self, 2, -1 do
        local r = math.random(i)
        self[i], self[r] = self[r], self[i]
    end
end

function LM.MountList:SimpleRandom(r)
    if #self > 0 then
        if r then
            r = math.ceil(r * #self)
        else
            r = math.random(#self)
        end
        return self[r]
    end
end

-- This is not a basic weight by priority. The ratios of how often you get a mount of
-- each priority remain the same regardless of how many you have.

function LM.MountList:PriorityWeights()
    local priorityCounts = { }

    for _,m in ipairs(self) do
        local p = m:GetPriority()
        priorityCounts[p] = ( priorityCounts[p] or 0 ) + 1
    end

    local weights = { total=0 }

    for i, m in ipairs(self) do
        local p, w  = m:GetPriority()
        -- Handle the "always" priority by setting all the others to weight 0
        if priorityCounts[LM.Options.ALWAYS_PRIORITY] and p ~= LM.Options.ALWAYS_PRIORITY then
            weights[i] = 0
        else
            weights[i] = w / ( priorityCounts[p] + 1 )
        end
        weights.total = weights.total + weights[i]
    end

    return weights
end

function LM.MountList:RarityWeights()
    local weights = { total=0 }

    for i, m in ipairs(self) do
        if m:GetPriority() == LM.Options.DISABLED_PRIORITY then
            weights[i] = 0
        else
            local rarity = m:GetRarity() or 50
            -- The weight is the mount's inverted rarity (rarer mounts are more likely)
            -- Math fudge to guard against 0% rarity.
            weights[i] = 101 / ( rarity + 1) - 1
        end
        weights.total = weights.total + weights[i]
    end

    return weights
end

function LM.MountList:WeightedRandom(weights, r)
    if weights.total == 0 then
        LM.Debug('  * WeightedRandom n=%d all weights 0')
        return
    end

    local cutoff = (r or math.random()) * weights.total

    local t = 0
    for i = 1, #self do
        t = t + weights[i]
        if t > cutoff then
            LM.Debug('  * WeightedRandom n=%d, t=%0.3f, c=%0.3f, w=%0.3f, p=%0.3f',
                        #self, weights.total,
                        cutoff,
                        weights[i],
                        weights[i] / weights.total)
            return self[i]
        end
    end
end

function LM.MountList:Random(r, style)
    if #self == 0 then return end
    if style == 'Priority' then
        local weights = self:PriorityWeights()
        return self:WeightedRandom(weights, r)
    elseif style == 'Rarity' then
        local weights = self:RarityWeights()
        return self:WeightedRandom(weights, r)
    else
        return self:SimpleRandom(r)
    end
end

local function filterMatch(m, ...)
    return m:MatchesFilters(...)
end

function LM.MountList:FilterSearch(...)
    -- This looks like a terrible idea but it's actually way faster and memory
    -- efficient to do all this here once rather than do it for every mount
    -- in the list

    -- Or filters have the literal '/' in the table and need to be made into
    -- subtables which the Search understands as "OR"

    local state, termList = nil, { }

    for i = 1, select('#', ...) do
        local term = select(i, ...)
        if term == '/' then
            state = '/'
        elseif state == '/' then
            if type(termList[#termList]) ~= 'table' then
                termList[#termList] = { termList[#termList] }
            end
            state = nil
            table.insert(termList[#termList], term)
        else
            state = nil
            table.insert(termList, term)
        end
    end

    return self:Search(filterMatch, unpack(termList))
end

-- Limits can be filter (no prefix), set (=), reduce (-) or extend (+).

function LM.MountList:Limit(...)

    -- This is a dubiously worthwhile optimization, to look for the last
    -- set (=) and ignore everything before it as irrelevant. Depending on
    -- how inefficient sub(1,1) is this might actually be slower.

    local begin = 1
    for i = 1, select('#', ...) do
        if select(i, ...):sub(1,1) == '=' then
            begin = i
        end
    end

    local mounts = self:Copy()

    for i = begin, select('#', ...) do
        local f = select(i, ...)
        if f:sub(1,1) == '+' then
            mounts:Extend(self:FilterSearch(f:sub(2)))
        elseif f:sub(1,1) == '-' then
            mounts:Reduce(self:FilterSearch(f:sub(2)))
        elseif f:sub(1,1) == '=' then
            mounts = self:FilterSearch(f:sub(2))
        else
            mounts = mounts:FilterSearch(f)
        end
    end

    return mounts
end

-- Don't call CanDragonRide thousands of times for no reason
local dragonRidingSort = false

local SortFunctions = {
    -- Show all the collected mounts before the uncollected mounts, then by name
    ['default'] =
        function (a, b)
            if a.isCollected and not b.isCollected then return true end
            if not a.isCollected and b.isCollected then return false end
            if dragonRidingSort then
                if a.dragonRiding and not b.dragonRiding then return true end
                if not a.dragonRiding and b.dragonRiding then return false end
            end
            return a.name < b.name
        end,
    ['name'] =
        function (a, b)
            return a.name < b.name
        end,
    ['rarity'] =
        function (a, b)
            return ( a:GetRarity() or 101 ) < ( b:GetRarity() or 101 )
        end,
    ['summons'] =
        function (a, b)
            return a:GetSummonCount() > b:GetSummonCount()
        end,
}

function LM.MountList:Sort(key)
    dragonRidingSort = IsAdvancedFlyableArea and IsAdvancedFlyableArea()
    table.sort(self, SortFunctions[key] or SortFunctions.default)
end

function LM.MountList:Dump()
    for _,m in ipairs(self) do
        m:Dump()
    end
end
