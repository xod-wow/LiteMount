--[[----------------------------------------------------------------------------

  LiteMount/Vars.lua

  Variables usable in action conditions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local CONSTS = {}
local VARS = setmetatable({}, CONSTS)

CONSTS["{CLASSID}"] =
    function ()
        local _, _, v = UnitClass("PLAYER")
        return v
    end

CONSTS["{CLASS}"] =
    function ()
        local _, v = UnitClass("PLAYER")
        return v
    end

CONSTS["{FACTION}"] =
    function ()
        local v = UnitFactionGroup("player")
        return v
    end

VARS["{SPECID}"] =
    function ()
        local v = GetSpecializationInfo(GetSpecialization())
        return v
    end

VARS["{SPEC}"] =
    function ()
        local v = GetSpecialization()
        return v
    end

VARS["{ROLE}"] =
    function ()
        local v = select(5, GetSpecializationInfo(GetSpecialization()))
        return v
    end

VARS["{AREAID}"] =
    function ()
        return LM_Location.areaID
    end

VARS["{CONTINENTID}"] =
    function ()
        return LM_Location.continent
    end

-- this should totally be some kind of metatable but who cares

_G.LM_Vars = {}

function LM_Vars:GetVar(v)
    if VARS[v] then
        return VARS[v]()
    end
end

function LM_Vars:GetConst(v)
    if CONSTS[v] then
        return CONSTS[v]()
    end
end

function LM_Vars:StrSubConsts(str)
    return str:gsub('{.-}', function (k) return self:GetConst(k) end)
end

function LM_Vars:StrSubVars(str)
    return str:gsub('{.-}', function (k) return self:GetVar(k) end)
end
