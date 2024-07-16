--[[----------------------------------------------------------------------------

  LiteMount/LM_Soulshape.lua

  Copyright 2011 Mike Battersby

  Soulshape works the same way that the Draenor garrison abilities did.
  GetSpellInfo(310143) returns the spell name, but GetSpellInfo(spellName) will
  return Flicker if you are already in Soulshape.

  Soulshape has a quite long cooldown so it's not really that clear if it
  should be a mount or not.

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.Soulshape = setmetatable({ }, LM.Spell)
LM.Soulshape.__index = LM.Soulshape

function LM.Soulshape:IsActive()
    return false
end

function LM.Soulshape:IsCancelable()
    return false
end

function LM.Soulshape:IsCollected()
    return self:IsKnown()
end

function LM.Soulshape:IsKnown()
    if IsPlayerSpell(self.spellID) then
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

    local activeSpellInfo = C_Spell.GetSpellInfo(self.name)

    if not C_Spell.IsSpellUsable(activeSpellInfo.spellID) then
        return false
    end

    local cooldownInfo = C_Spell.GetSpellCooldown(activeSpellInfo.spellID)
    if cooldownInfo and cooldownInfo.startTime > 0 then
        return false
    end

    return LM.Mount.IsCastable(self)
end
