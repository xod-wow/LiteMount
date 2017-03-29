--[[----------------------------------------------------------------------------

  LiteMount/LM_Nagrand.lua

  Nagrand mounts, Telaari Talbuk and Frostwolf War Wolf.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Nagrand = setmetatable({ }, LM_Spell)
LM_Nagrand.__index = LM_Nagrand

local FactionRequirements = {
    [LM_SPELL.FROSTWOLF_WAR_WOLF] = "Horde",
    [LM_SPELL.TELAARI_TALBUK] = "Alliance",
}

function LM_Nagrand:Get(spellID)
    local m = LM_Spell:Get(spellID, true)

    if not m then return end

    setmetatable(m, LM_Nagrand)
    m.flags = { [LM_FLAG.NAGRAND] = true }

    return m
end

function LM_Nagrand:Refresh()
    local playerFaction = UnitFactionGroup("player")
    local requiredFaction = FactionRequirements[self.spellID]

    if GetZoneAbilitySpellInfo() and playerFaction == requiredFaction then
        self.isCollected = true
    else
        self.isCollected = false
    end
end

-- Draenor Ability spells are weird.  The name of the Garrison Ability
-- (localized) is name = GetSpellInfo(161691)
-- But, GetSpellInfo(name) returns the actual current spell that's active.
function LM_Nagrand:IsUsable()
    local baseSpellID, garrisonType = GetZoneAbilitySpellInfo()
    local baseSpellName = GetSpellInfo(baseSpellID)

    local id = select(7, GetSpellInfo(baseSpellName))
    if id ~= self.spellID then return false end
    if not IsUsableSpell(baseSpellID) then return false end
    return LM_Mount.IsUsable(self)
end
