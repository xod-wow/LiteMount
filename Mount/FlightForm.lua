--[[----------------------------------------------------------------------------

  LiteMount/LM_FlightForm.lua

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_FlightForm = setmetatable({ }, LM_Spell)
LM_FlightForm.__index = LM_FlightForm

function LM_FlightForm:Flags(v)
    return LM_FLAG_BIT_FLY
end

function LM_FlightForm:Get(spellID)
    local m = LM_Spell:Get(spellID)
    if m then
        setmetatable(m, LM_FlightForm)
        -- if we knew the modelIDs for the various forms across the two
        -- factions we could set m.modelID here and have the preview window
        -- display them.
    end
    return m
end
