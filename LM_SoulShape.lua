--[[----------------------------------------------------------------------------

  LiteMount/LM_Soulshape.lua

  Copyright 2011-2020 Mike Battersby

  Soulshape works the same way that the Draenor garrison abilities did.
  GetSpellInfo(310143) returns the spell name, but GetSpellInfo(spellName) will
  return Flicker if you are already in Soulshape.

  Soulshape has a quite long cooldown so it's not really that clear if it
  should be a mount or not.

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Soulshape = setmetatable({ }, LM.Spell)
LM.Soulshape.__index = LM.Soulshape

function LM.Soulshape:IsCancelable()
--  if IsResting() and not LM.Environment:IsMovingOrFalling() then
--      return true
--  end
    return false
end

function LM.Soulshape:IsCastable()
    if not IsSpellKnown(self.spellID) then
        return false
    end

    local activeSpellID = select(7, GetSpellInfo(self.name))
    if not IsUsableSpell(activeSpellID) then
        return false
    end
    if GetSpellCooldown(activeSpellID) > 0 then
        return false
    end
    return true
end
