--[[----------------------------------------------------------------------------

  LiteMount/LM_Nagrand.lua

  Nagrand mounts, Telaari Talbuk and Frostwolf War Wolf.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Nagrand = setmetatable({ }, LM_Spell)
LM_Nagrand.__index = LM_Nagrand

local FactionRequirements = {
    [LM_SPELL_FROSTWOLF_WAR_WOLF] = "Horde",
    [LM_SPELL_TELAARI_TALBUK] = "Alliance",
}


function LM_Nagrand:DefaultFlags(f)
    return LM_FLAG_BIT_NAGRAND
end

function LM_Nagrand:Get(spellId)
    local m

    if HasDraenorZoneAbility() then
        m = LM_Spell:Get(spellId, true)
    end

    if m then
        setmetatable(m, LM_Nagrand)
        m:NeedsFaction(FactionRequirements[spellId])
    end

    return m
end

-- Draenor Ability spells are weird.  The name of the Garrison Ability
-- (localized) is name = GetSpellInfo(DraenorZoneAbilitySpellID).
-- But, GetSpellInfo(name) returns the actual current spell that's active.
function LM_Nagrand:IsUsable(flags)
    local DraenorZoneAbilityName = GetSpellInfo(DraenorZoneAbilitySpellID)
    local id = select(7, GetSpellInfo(DraenorZoneAbilityName))
    if id ~= self:SpellId() then return false end
    return LM_Mount.IsUsable(self, flags)
end
