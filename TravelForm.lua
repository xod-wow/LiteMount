--[[----------------------------------------------------------------------------

  LiteMount/TravelForm.lua

  Travel Form has to update its fly/don't fly status depending on whether
  you have Glyph of the Stag or not.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_TravelForm = setmetatable({ }, LM_Mount)
LM_TravelForm.__index = LM_TravelForm

function LM_TravelForm:FlagsSet(f)

    local flags = self:Flags()

    -- If we know Flight Form then Travel Form can't fly. Sigh.
    if self:SpellId() == LM_SPELL_TRAVEL_FORM then
        if IsSpellKnown(LM_SPELL_FLIGHT_FORM) then
            LM_Debug("REMOVING FLY FROM TRAVEL FORM")
            flags = bit.band(flags, bit.bnot(LM_FLAG_BIT_FLY))
        end
    end

    return bit.band(flags, f) == f
end

function LM_TravelForm:DefaultFlags(v)
    local flags = LM_Mount.DefaultFlags(self, v)

    -- If we have glyph of travel then we can also "run"
    for i = 1, NUM_GLYPH_SLOTS do
        local spellId = select(4, GetGlyphSocketInfo(i))
        if spellId == LM_SPELL_GLYPH_OF_TRAVEL then
             return bit.bor(flags, LM_FLAG_BIT_RUN)
        end
    end
    return flags
end

function LM_TravelForm:GetMount()
    local m = LM_Mount:GetMountBySpell(LM_SPELL_TRAVEL_FORM)
    if m then setmetatable(m, LM_TravelForm) end
    return m
end
