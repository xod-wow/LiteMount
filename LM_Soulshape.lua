--[[----------------------------------------------------------------------------

  LiteMount/LM_Soulshape.lua

  Copyright 2011-2021 Mike Battersby

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

function LM.Soulshape:Get(spellID, ...)
    local m = LM.Spell.Get(self, spellID, ...)
    m.isCollected = m:IsKnown()
    return m
end

function LM.Soulshape:IsActive()
    return false
end

function LM.Soulshape:IsCancelable()
    return false
end

function LM.Soulshape:Refresh()
    self.isCollected = self:IsKnown()
end

function LM.Soulshape:IsKnown()
    if IsSpellKnown(self.spellID) then
        return true
    end
    for _,ability in ipairs(C_ZoneAbility.GetActiveAbilities()) do
        local id = FindSpellOverrideByID(ability.spellID) or ability.spellID
        if id == LM.SPELL.SOULSHAPE or id == LM.SPELL.FLICKER then
            return true
        end
    end
end

function LM.Soulshape:IsCastable()
    if not self:IsKnown() then
        return false
    end

--[[
    if LM.UnitAura('player', self.spellID) then
        return false
    end
]]

    local activeSpellID = select(7, GetSpellInfo(self.name))

    if not IsUsableSpell(activeSpellID) then
        return false
    end

    if GetSpellCooldown(activeSpellID) > 0 then
        return false
    end

    return LM.Mount.IsCastable(self)
end
