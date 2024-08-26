--[[----------------------------------------------------------------------------

  LiteMount/LM_Nagrand.lua

  Nagrand mounts, Telaari Talbuk and Frostwolf War Wolf.

  Draenor Ability spells are weird.

  The name of the Garrison Ability (localized) is
        name = C_Spell.GetSpellName(161691)
  But,
        C_Spell.GetSpellName(name)
  returns the actual current spell that's active.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.Nagrand = setmetatable({ }, LM.Spell)
LM.Nagrand.__index = LM.Nagrand

function LM.Nagrand:Get(spellID, faction, ...)
    local m = LM.Spell.Get(self, spellID, ...)

    if m then
        m.baseSpellID = LM.SPELL.GARRISON_ABILITY
        m.baseSpellName = C_Spell.GetSpellName(m.baseSpellID)
        m.needsFaction = faction
    end

    return m
end

function LM.Nagrand:IsHidden()
    local playerFaction = UnitFactionGroup("player")
    return playerFaction ~= self.needsFaction
end

function LM.Nagrand:IsCollected()
    return not self:IsHidden() and IsPlayerSpell(self.baseSpellID)
end

function LM.Nagrand:GetCastAction(context)
    return LM.SecureAction:Spell(self.baseSpellName)
end

-- Check if the spell is in one of the zone spell slots.

function LM.Nagrand:IsCastable()
    local zoneAbilities = C_ZoneAbility.GetActiveAbilities()
    for _,info in ipairs(zoneAbilities) do
        local zoneSpellName = C_Spell.GetSpellName(info.spellID)
        local zoneSpellID = C_Spell.GetSpellInfo(zoneSpellName).spellID
        if zoneSpellID == self.spellID then
            return C_Spell.IsSpellUsable(info.spellID) and LM.Mount.IsCastable(self)
        end
    end
    return false
end
