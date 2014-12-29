--[[----------------------------------------------------------------------------

  LiteMount/LM_FlightForm.lua

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_FlightForm = setmetatable({ }, LM_Spell)
LM_FlightForm.__index = LM_FlightForm

function LM_FlightForm:DefaultFlags(v)
    return LM_FLAG_BIT_FLY
end

function LM_FlightForm:Get(spellId)
    local m = LM_Spell:Get(spellId)
    if m then setmetatable(m, LM_FlightForm) end
    return m
end
