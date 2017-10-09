--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  List of mounts with some kinds of extra stuff, mostly shuffle/random.

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

LM_MountList = { }
LM_MountList.__index = LM_MountList

function LM_MountList:New(ml)
    return setmetatable(ml or {}, LM_MountList)
end

function LM_MountList:Search(matchfunc, ...)
    local result, remainder = LM_MountList:New(), LM_MountList:New()

    for _,m in ipairs(self) do
        if not matchfunc or matchfunc(m, ...) then
            tinsert(result, m)
        else
            tinsert(remainder, m)
        end
    end

    return result, remainder
end

function LM_MountList:Find(matchfunc, ...)
    for _,m in ipairs(self) do
        if matchfunc(m, ...) then
            return m
        end
    end
end

function LM_MountList:Shuffle()
    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #self, 2, -1 do
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

function LM_MountList:__add(other)
    local r = LM_MountList:New()
    local seen = { }
    for _,m in ipairs(self) do
        tinsert(r, m)
        seen[m] = true
    end
    for _,m in ipairs(other) do
        if not seen[m] then
            tinsert(r, m)
        end
    end
    return r
end

function LM_MountList:__sub(other)
    local r = LM_MountList:New()
    local remove = { }
    for _,m in ipairs(other) do
        remove[m] = true
    end
    for _,m in ipairs(self) do
        if not remove[m] then
            tinsert(r, m)
        end
    end
    return r
end

function LM_MountList:Map(mapfunc)
    for _,m in ipairs(self) do
        mapfunc(m)
    end
end

function LM_MountList:Filter(...)
    local function match(m, ...)
        return m:MatchesFilters(...)
    end
    return self:Search(match, ...)
end

function LM_MountList:GetMountFromUnitAura(unitid)
    local buffs = { }
    for i = 1,BUFF_MAX_DISPLAY do
        local aura = UnitAura(unitid, i)
        if aura then buffs[aura] = true end
    end
    local function match(m)
        local spellName = GetSpellInfo(m.spellID)
        return m.isCollected and buffs[spellName] and m:IsCastable()
    end
    return self:Find(match)
end

function LM_MountList:GetMountByName(name)
    local function match(m) return m.name == name end
    return self:Find(match)
end

function LM_MountList:GetMountBySpell(id)
    local function match(m) return m.spellID == id end
    return self:Find(match)
end

-- For some reason GetShapeshiftFormInfo doesn't work on Ghost Wolf.
function LM_MountList:GetMountByShapeshiftForm(i)
    if not i then return end
    local class = select(2, UnitClass("player"))
    if class == "SHAMAN" and i == 1 then
         return self:GetMountBySpell(LM_SPELL.GHOST_WOLF)
    end
    local name = select(2, GetShapeshiftFormInfo(i))
    if name then return self:GetMountByName(name) end
end

function LM_MountList:Dump()
    for _,m in ipairs(self) do
        m:Dump()
    end
end
