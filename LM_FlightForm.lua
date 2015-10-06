--[[----------------------------------------------------------------------------

  LiteMount/LM_FlightForm.lua

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

LM_FlightForm = setmetatable({ }, LM_Spell)
LM_FlightForm.__index = LM_FlightForm

function LM_FlightForm:Flags(v)
    return LM_FLAG_BIT_FLY
end

function LM_FlightForm:Get(spellId)
    local m = LM_Spell:Get(spellId)
    if m then
        setmetatable(m, LM_FlightForm)
        -- if we knew the modelIds for the various forms across the two
        -- factions we could set m.modelId here and have the preview window
        -- display them.
    end
    return m
end
