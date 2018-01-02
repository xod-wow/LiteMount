--[[----------------------------------------------------------------------------

  LiteMount/LM_FlightForm.lua

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_FlightForm = setmetatable({ }, LM_Spell)
LM_FlightForm.__index = LM_FlightForm

function LM_FlightForm:Get(spellID)
    -- if we knew the modelIDs for the various forms across the two
    -- factions we could set m.modelID here and have the preview window
    -- display them.
    return LM_Spell.Get(self, spellID, 'FLY')
end
