--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form is the biggest pain in the butt ever invented.  Blizzard
  change how it works, how fast it is, how many spells it is, and almost
  every other aspect of it ALL THE DAMN TIME.

  LEAVE TRAVEL FORM ALONE!

  Also IsUsableSpell doesn't work right on it.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.TravelForm = setmetatable({ }, LM.Spell)
LM.TravelForm.__index = LM.TravelForm

local travelFormFlags = { 'FLY', 'SWIM', 'RUN' }

function LM.TravelForm:Get()
    return LM.Spell.Get(self, LM.SPELL.TRAVEL_FORM, unpack(travelFormFlags))
end

-- You can cast Travel Form using the SpellID (unlike the journal mounts
-- where you can't), which bypasses a bug.

function LM.TravelForm:GetSecureAttributes()
    return { ["type"] = "spell", ["spell"] = self.spellID }
end

-- IsUsableSpell doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM.TravelForm:IsCastable()
    if IsIndoors() and not IsSubmerged() then return false end
    return LM.Spell.IsCastable(self)
end
