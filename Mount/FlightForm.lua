--[[----------------------------------------------------------------------------

  LiteMount/LM_FlightForm.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_FlightForm = setmetatable({ }, LM_Spell)
LM_FlightForm.__index = LM_FlightForm

function LM_FlightForm:Get(spellID)
    local m = LM_Spell:Get(spellID)
    if m then
        setmetatable(m, LM_FlightForm)
        m.flags = { [LM_FLAG.FLY] = true }
        -- if we knew the modelIDs for the various forms across the two
        -- factions we could set m.modelID here and have the preview window
        -- display them.
    end
    return m
end
