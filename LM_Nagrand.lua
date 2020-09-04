--[[----------------------------------------------------------------------------

  LiteMount/LM_Nagrand.lua

  Nagrand mounts, Telaari Talbuk and Frostwolf War Wolf.

  Draenor Ability spells are weird.

  The name of the Garrison Ability (localized) is
        name = GetSpellInfo(161691)
  But,
        GetSpellInfo(name)
  returns the actual current spell that's active.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Nagrand = setmetatable({ }, LM.Spell)
LM.Nagrand.__index = LM.Nagrand

function LM.Nagrand:Get(spellID, faction, ...)
    local m = LM.Spell.Get(self, spellID, ...)

    if m then
        local playerFaction = UnitFactionGroup("player")
        m.isFiltered = ( playerFaction ~= faction )
        m.needsFaction = faction
    end

    return m
end

function LM.Nagrand:GetCastAction()
    local spellName = GetSpellInfo(LM.SPELL.GARRISON_ABILITY)
    return LM.SecureAction:Spell(spellName)
end

function LM.Nagrand:GetCancelAction()
    local spellName = GetSpellInfo(LM.SPELL.GARRISON_ABILITY)
    return LM.SecureAction:CancelAura(spellName)
end

-- Check if the spell is in one of the zone spell slots.

function LM.Nagrand:IsCastable()
    local zoneAbilities = C_ZoneAbility.GetActiveAbilities();
    for _,info in ipairs(zoneAbilities) do
        local baseSpellName = GetSpellInfo(info.spellID)
        local id = select(7, GetSpellInfo(baseSpellName))
        if id == self.spellID then
            return IsUsableSpell(info.spellID) and LM.Mount.IsCastable(self)
        end
    end
    return false
end
