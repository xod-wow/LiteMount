--[[----------------------------------------------------------------------------

  LiteMount/LM_Nagrand.lua

  Nagrand mounts, Telaari Talbuk and Frostwolf War Wolf.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Nagrand = setmetatable({ }, LM_Spell)
LM_Nagrand.__index = LM_Nagrand

local FactionRequirements = {
    [LM_SPELL_FROSTWOLF_WAR_WOLF] = "Horde",
    [LM_SPELL_TELAARI_TALBUK] = "Alliance",
}


function LM_Nagrand:Flags(f)
    return LM_FLAG_BIT_NAGRAND
end

function LM_Nagrand:Get(spellID)
    local m

    local playerFaction = UnitFactionGroup("player")
    local requiredFaction = FactionRequirements[spellID]
    if requiredFaction and playerFaction ~= requiredFaction then
        return
    end

    local baseSpellID, garrisonType = GetZoneAbilitySpellInfo()
    if baseSpellID ~= 0 then
        m = LM_Spell:Get(spellID, true)
    end

    if m then
        setmetatable(m, LM_Nagrand)
    end

    return m
end

function LM_Nagrand:SetupActionButton(button)
    local id = GetZoneAbilitySpellInfo()
    local spellName = GetSpellinfo(id)
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", spellname)
end

-- Draenor Ability spells are weird.  The name of the Garrison Ability
-- (localized) is name = GetSpellInfo(161691)
-- But, GetSpellInfo(name) returns the actual current spell that's active.
function LM_Nagrand:IsUsable()
    local baseSpellID, garrisonType = GetZoneAbilitySpellInfo()
    local baseSpellName = GetSpellInfo(baseSpellID)

    local id = select(7, GetSpellInfo(baseSpellName))
    if id ~= self:SpellID() then return false end
    if not IsUsableSpell(baseSpellID) then return false end
    return LM_Mount.IsUsable(self)
end
