--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  List of mounts with some kinds of extra stuff, mostly shuffle/random.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

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

_G.LM_MountList = { }
LM_MountList.__index = LM_MountList

function LM_MountList:New(ml)
    return setmetatable(ml or {}, LM_MountList)
end

function LM_MountList:Copy()
    local out = { }
    for i,v in ipairs(self) do
        out[i] = v
    end
    return self:New(out)
end

function LM_MountList:Search(matchfunc, ...)
    local result = self:New()

    for _,m in ipairs(self) do
        if matchfunc(m, ...) then
            tinsert(result, m)
        end
    end

    return result
end

-- Note that Find doesn't make another table
function LM_MountList:Find(matchfunc, ...)
    for _,m in ipairs(self) do
        if matchfunc(m, ...) then
            return m
        end
    end
end

function LM_MountList:Shuffle()
    -- Fisher-Yates algorithm.
    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #self, 2, -1 do
        local r = math.random(i)
        self[i], self[r] = self[r], self[i]
    end
end

function LM_MountList:Random(r)
    if #self > 0 then
        if r then
            r = math.ceil(r * #self)
        else
            r = math.random(#self)
        end
        return self[r]
    end
end

function LM_MountList:PriorityRandom(r)

    if #self == 0 then return end

    local priorityCounts = { }

    for _,m in ipairs(self) do
        local p = LM_Options:GetPriority(m)
        priorityCounts[p] = ( priorityCounts[p] or 0 ) + 1
    end

    local weights, totalWeight = {}, 0

    for i,m in ipairs(self) do
        local p, w  = LM_Options:GetPriority(m)
        weights[i] = w / priorityCounts[p]
        totalWeight = totalWeight + weights[i]
    end

    local cutoff = (r or math.random()) * totalWeight

    LM_Debug(format(' - PriorityRandom n=%d, t=%0.3f, c=%0.3f', #self, totalWeight, cutoff))

    local t = 0
    for i = 1, #self do
        t = t + weights[i]
        if t > cutoff then
            return self[i]
        end
    end
end

local function filterMatch(m, ...)
    return m:MatchesFilters(...)
end

function LM_MountList:FilterSearch(...)
    return self:Search(filterMatch, ...)
end

local function cmpName(a, b)
    return a.name < b.name
end

function LM_MountList:Sort(cmp)
    table.sort(self, cmp or cmpName)
end

function LM_MountList:Dump()
    for _,m in ipairs(self) do
        m:Dump()
    end
end
