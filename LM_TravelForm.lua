--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form has to update its fly/don't fly status depending on whether
  you have Glyph of the Stag or not.

  It also updates whether it can run or not depending on Glyph of Travel.

  Also IsUsableSpell doesn't work right on it.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_TravelForm = setmetatable({ }, LM_Spell)
LM_TravelForm.__index = LM_TravelForm

local LM_SPELL_GLYPH_OF_THE_STAG = 114338
local LM_SPELL_GLYPH_OF_TRAVEL = 159456

function LM_TravelForm:FlagsSet(f)

    local flags = self:Flags()

    -- If we know Flight Form then Travel Form can't fly. Sigh.
    if self:SpellId() == LM_SPELL_TRAVEL_FORM then
        if IsSpellKnown(LM_SPELL_FLIGHT_FORM) then
            LM_Debug("Removing FLYING from Travel Form due to glyph.")
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

function LM_TravelForm:Get()
    local m = LM_Spell:Get(LM_SPELL_TRAVEL_FORM)
    if m then setmetatable(m, LM_TravelForm) end
    return m
end

-- IsUsableSpell doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM_TravelForm:IsUsable(flags)
    if IsIndoors() and not IsSubmerged() then return false end
    return LM_Spell.IsUsable(self, flags)
end
