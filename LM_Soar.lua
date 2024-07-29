--[[----------------------------------------------------------------------------

  LiteMount/LM_Soar.lua

  Soar only mostly behaves like a Dragonriding mount, there are some exceptions
  that don't make a lot of consistent sense to me. You can't soar underwater
  and it's not affected by the Amirdrassil buff that enables Dragonriding.

  Pretend to be a Dragonriding mount then pile this full of corner cases. At
  least then they're all in one spot.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.Soar = setmetatable({ }, LM.Spell)
LM.Soar.__index = LM.Soar

-- Soar gives an error message instead of IsSpellUsable false in a variety
-- of pretty ordinary circumstances.

function LM.Soar:IsCastable()
    if IsSubmerged() then
        -- You can actually cast it but it bugs out.
        return false
    else
        return LM.Spell.IsCastable(self)
    end
end
