--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form is the biggest pain in the butt ever invented.  Blizzard
  change how it works, how fast it is, how many spells it is, and almost
  every other aspect of it ALL THE DAMN TIME.

  LEAVE TRAVEL FORM ALONE!

  Also IsUsableSpell doesn't work right on it.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_TravelForm = setmetatable({ }, LM_Spell)
LM_TravelForm.__index = LM_TravelForm

local travelFormFlags = { 'FLY', 'SWIM', 'RUN' }

function LM_TravelForm:Get()
    return LM_Spell.Get(self, LM_SPELL.TRAVEL_FORM, unpack(travelFormFlags))
end

-- You can cast Travel Form using the SpellID (unlike the journal mounts
-- where you can't), which bypasses a bug.

function LM_TravelForm:GetSecureAttributes()
    return { ["type"] = "spell", ["spell"] = self.spellID }
end

-- IsUsableSpell doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM_TravelForm:IsCastable()
    if IsIndoors() and not IsSubmerged() then return false end
    return LM_Spell.IsCastable(self)
end
