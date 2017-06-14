--[[----------------------------------------------------------------------------

  LiteMount/ShuffleList.lua

  List with some kinds of extra stuff, mostly shuffle/random.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

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

LM_ShuffleList = { }
LM_ShuffleList.__index = LM_ShuffleList

function LM_ShuffleList:New(ml)
    local ml = ml or { }
    setmetatable(ml, LM_ShuffleList)
    return ml
end

function LM_ShuffleList:Iterate()
    local i = 0
    local iter = function ()
            i = i + 1
            return self[i]
        end
    return iter
end

function LM_ShuffleList:Search(matchfunc)
    local result = LM_ShuffleList:New()

    for m in self:Iterate() do
        if matchfunc(m) then
            tinsert(result, m)
        end
    end

    return result
end

function LM_ShuffleList:Find(matchfunc)
    for m in self:Iterate() do
        if matchfunc(m) then
            return m
        end
    end
end

function LM_ShuffleList:Shuffle()
    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #self, 2, -1 do
        local r = math.random(i)
        self[i], self[r] = self[r], self[i]
    end
end

function LM_ShuffleList:Random()
    local n = #self
    if n == 0 then
        return nil
    else
        return self[math.random(n)]
    end
end

function LM_ShuffleList:WeightedRandom(weightfunc)
    local n = #self
    if n == 0 then return nil end

    local weightsum = 0
    for m in self:Iterate() do
        weightsum = weightsum + (weightfunc(m) or 10)
    end

    local r = math.random(weightsum)
    local t = 0
    for m in self:Iterate() do
        t = t + (weightfunc(m) or 10)
        if t >= r then return m end
    end
end

function LM_ShuffleList:__add(other)
    local r = LM_ShuffleList:New()
    local seen = { }
    for m in self:Iterate() do
        tinsert(r, m)
        seen[m] = true
    end
    for m in other:Iterate() do
        if not seen[m] then
            tinsert(r, m)
        end
    end
    return r
end

function LM_ShuffleList:__sub(other)
    local r = LM_ShuffleList:New()
    local remove = { }
    for m in other:Iterate() do
        remove[m] = true
    end
    for m in self:Iterate() do
        if not remove[m] then
            tinsert(r, m)
        end
    end
    return r
end

function LM_ShuffleList:Map(mapfunc)
    for m in self:Iterate() do
        mapfunc(m)
    end
end

