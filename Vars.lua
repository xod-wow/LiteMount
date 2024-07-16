--[[----------------------------------------------------------------------------

  LiteMount/Vars.lua

  Variables usable in action conditions.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

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

CONSTS["{CLASS_L}"] =
    function ()
        local v = UnitClass("PLAYER")
        return v
    end

CONSTS["{FACTION}"] =
    function ()
        local v = UnitFactionGroup("player")
        return v
    end

CONSTS["{FACTION_L}"] =
    function ()
        local _, v = UnitFactionGroup("player")
        return v
    end

CONSTS["{RACE}"] =
    function ()
        local _, v = UnitRace("player")
        return v
    end

CONSTS["{RACE_L}"] =
    function ()
        local v = UnitRace("player")
        return v
    end

VARS["{SPECID}"] =
    function ()
        local v = GetSpecializationInfo(GetSpecialization())
        return v
    end

VARS["{SPEC}"] =
    function ()
        local _, v = GetSpecializationInfo(GetSpecialization())
        return v
    end

VARS["{ROLE}"] =
    function ()
        local v = select(5, GetSpecializationInfo(GetSpecialization()))
        return v
    end

VARS["{MAPID}"] =
    function ()
        return C_Map.GetBestMapForUnit('player') or ''
    end

-- this should totally be some kind of metatable but who cares

LM.Vars = {}

function LM.Vars:GetVar(v)
    if VARS[v] then
        return VARS[v]()
    end
end

function LM.Vars:GetConst(v)
    if CONSTS[v] then
        return CONSTS[v]()
    end
end

function LM.Vars:StrSubConsts(str)
    return str:gsub('{.-}', function (k) return self:GetConst(k) end)
end

function LM.Vars:StrSubVars(str)
    return str:gsub('{.-}', function (k) return self:GetVar(k) end)
end
