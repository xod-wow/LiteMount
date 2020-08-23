--[[----------------------------------------------------------------------------

  LiteMount/LM_FlightForm.lua

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.FlightForm = setmetatable({ }, LM.Spell)
LM.FlightForm.__index = LM.FlightForm

function LM.FlightForm:Get(spellID)
    -- if we knew the modelIDs for the various forms across the two
    -- factions we could set m.modelID here and have the preview window
    -- display them.
    return LM.Spell.Get(self, spellID, 'FLY')
end
