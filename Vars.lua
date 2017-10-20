--[[----------------------------------------------------------------------------

  LiteMount/Vars.lua

  Variables usable in action conditions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local VARS = {}

VARS["{SPECID}"] =
    function ()
        local v = GetSpecialization()
        return v
    end

VARS["{SPEC}"] =
    function ()
        local _, v = GetSpecializationInfo(GetSpecialization())
        return v
    end

VARS["{CLASSID}"] =
    function ()
        local _, _, v = UnitClass("PLAYER")
        return v
    end

VARS["{CLASS}"] =
    function ()
        local v = UnitClass("PLAYER")
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

LM_Vars = {}

function LM_Vars:Get(v)
    if VARS[v] then
        return VARS[v]()
    end
end
