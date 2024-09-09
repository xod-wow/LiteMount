--[[----------------------------------------------------------------------------

  LiteMount/LM_Soar.lua

  Soar only mostly behaves like a Skyriding mount, there are some exceptions
  that don't make a lot of consistent sense to me. You can't soar underwater
  and it's not affected by the Amirdrassil buff that enables Skyriding.

  Pretend to be a Skyriding mount then pile this full of corner cases. At
  least then they're all in one spot.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.Soar = setmetatable({ }, LM.Spell)
LM.Soar.__index = LM.Soar

-- Soar gives an error message instead of IsSpellUsable false in a variety
-- of pretty ordinary circumstances.

-- Soar still has a lot of weirdnesses as of TWW. If you never unlocked
-- dragonriding it behaves as a steady flight mount sometimes, and other
-- times instantly dismounts you.

function LM.Soar:IsCastable()
    if IsSubmerged() then
        -- You can actually cast it but it bugs out.
        return false
    else
        return LM.Spell.IsCastable(self)
    end
end

function LM.Soar:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
