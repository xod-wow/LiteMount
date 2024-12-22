--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  List of mounts with some kinds of extra stuff, mostly shuffle/random.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

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

function LM.MountList:LFUWeights()
    local weights = { total=0 }
    local lowestSummonCount

    for i, m in ipairs(self) do
        if m:GetPriority() ~= LM.Options.DISABLED_PRIORITY then
            local c = m:GetSummonCount()
            if c <= (lowestSummonCount or c) then
                lowestSummonCount = c
            end
        end
    end

    for i, m in ipairs(self) do
        if m:GetPriority() == LM.Options.DISABLED_PRIORITY then
            weights[i] = 0
        elseif m:GetSummonCount() == lowestSummonCount then
            weights[i] = 1
        else
            weights[i] = 0
        end
        weights.total = weights.total + weights[i]
    end

    return weights
end

function LM.MountList:WeightedRandom(weights, r)
    if weights.total == 0 then
        LM.Debug('  * WeightedRandom n=%d all weights 0', #self)
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
    elseif style == 'LeastUsed' then
        local weights = self:LFUWeights()
        return self:WeightedRandom(weights, r)
    else
        return self:SimpleRandom(r)
    end
end

local function filterMatch(m, ...)
    return m:MatchesFilters(...)
end

function LM.MountList:FilterSearch(...)
    return self:Search(filterMatch, ...)
end

-- Limits can be intersect (no prefix), subtract (-) or union (+). This really
-- only works when called on a list of the full set of mounts because it's
-- assuming self is everything. So bundle up all the limit expressions into a
-- list and call this once.

local function expressionMatch(m, e)
    return m:MatchesExpression(e)
end

function LM.MountList:ExpressionSearch(e)
    return self:Search(expressionMatch, e)
end

function LM.MountList:Limit(limits)
    local mounts = self:Copy()
    for _, arg in ipairs(limits) do
        local e = arg:ParseExpression()
        if e == nil then
            -- SYNTAX ERROR PRINT SOMETHING?
            return nil
        elseif e.op == '+' then
            mounts = mounts:Extend(self:ExpressionSearch(e[1]))
        elseif e.op == '-' then
            mounts = mounts:Reduce(self:ExpressionSearch(e[1]))
        elseif e.op == '=' then
            mounts = self:ExpressionSearch(e[1])
        else
            mounts = mounts:ExpressionSearch(e)
        end
    end
    return mounts
end

local SortFunctions = {
    -- Show all the collected mounts before the uncollected mounts, then by name
    ['default'] =
        function (a, b)
            if a:IsCollected() and not b:IsCollected() then return true end
            if not a:IsCollected() and b:IsCollected() then return false end
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
    table.sort(self, SortFunctions[key] or SortFunctions.default)
end

function LM.MountList:Dump()
    for _,m in ipairs(self) do
        m:Dump()
    end
end
