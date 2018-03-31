--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  List of mounts with some kinds of extra stuff, mostly shuffle/random.

  Copyright 2011-2018 Mike Battersby

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
        -- LM_Profile(1)
        if matchfunc(m, ...) then
            tinsert(result, m)
        end
    end

    return result
end

-- Note that Find doesn't make another table
function LM_MountList:Find(matchfunc, ...)
    for _,m in ipairs(self) do
        -- LM_Profile(1)
        if matchfunc(m, ...) then
            return m
        end
    end
end

function LM_MountList:Shuffle()
    -- Fisher-Yates algorithm.
    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #self, 2, -1 do
        -- LM_Profile(1)
        local r = math.random(i)
        self[i], self[r] = self[r], self[i]
    end
end

function LM_MountList:Random()
    local n = #self
    if n == 0 then
        return nil
    else
        return self[math.random(n)]
    end
end

function LM_MountList:WeightedRandom(weightfunc)
    local n = #self
    if n == 0 then return nil end

    local weightsum = 0
    for _,m in ipairs(self) do
        weightsum = weightsum + (weightfunc(m) or 10)
    end

    local r = math.random(weightsum)
    local t = 0
    for _,m in ipairs(self) do
        t = t + (weightfunc(m) or 10)
        if t >= r then return m end
    end
end

local function filterMatch(m, ...)
    return m:MatchesFilters(...)
end

function LM_MountList:FilterSearch(...)
    return self:Search(filterMatch, ...)
end

function LM_MountList:FilterFind(...)
    return self:Find(filterMatch, ...)
end

function LM_MountList:Dump()
    for _,m in ipairs(self) do
        m:Dump()
    end
end
