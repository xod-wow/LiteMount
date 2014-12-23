--[[----------------------------------------------------------------------------

  LiteMount/TravelForm.lua

  Travel Form has to update its fly/don't fly status depending on whether
  you have Glyph of the Stag or not.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_TravelForm = { }

function LM_TravelForm:FlagsSet(f)

    local flags = self:Flags()

    -- If we know Flight Form then Travel Form can't fly. Sigh.
    if self:SpellId() == LM_SPELL_TRAVEL_FORM then
        if IsSpellKnown(LM_SPELL_FLIGHT_FORM) then
            LM_Debug("REMOVING FLY FROM TRAVEL FORM")
            flags = bit.band(self.flags, bit.bnot(LM_FLAG_BIT_FLY))
        end
    end

    return bit.band(flags, f) == f
end
