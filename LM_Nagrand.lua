--[[----------------------------------------------------------------------------

  LiteMount/LM_Nagrand.lua

  Nagrand mounts, Telaari Talbuk and Frostwolf War Wolf.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Nagrand = setmetatable({ }, LM.Spell)
LM.Nagrand.__index = LM.Nagrand

local FactionRequirements = {
    [LM.SPELL.FROSTWOLF_WAR_WOLF] = "Horde",
    [LM.SPELL.TELAARI_TALBUK] = "Alliance",
}

function LM.Nagrand:Get(spellID, ...)
    local m = LM.Spell.Get(self, spellID, ...)

    if m then
        local playerFaction = UnitFactionGroup("player")
        m.isCollected = ( UnitLevel("player") >= 100 )
        m.isFiltered = ( playerFaction ~= FactionRequirements[spellID] )
        m.needsFaction = FactionRequirements[spellID]
    end

    return m
end

function LM.Nagrand:Refresh()
    self.isCollected = ( UnitLevel("player") >= 100 )
    LM.Mount.Refresh(self)
end

function LM.Nagrand:GetMountAttributes()
    local spellName = GetSpellInfo(LM.SPELL.GARRISON_ABILITY)
    return { ["type"] = "spell", ["spell"] = spellName }
end

-- Draenor Ability spells are weird.  The name of the Garrison Ability
-- (localized) is name = GetSpellInfo(161691)
-- But, GetSpellInfo(name) returns the actual current spell that's active.
function LM.Nagrand:IsCastable()
    local zoneAbilities = C_ZoneAbility.GetActiveAbilities();
    for _,info in ipairs(zoneAbilities) do
        local baseSpellName = GetSpellInfo(info.spellID)
        local id = select(7, GetSpellInfo(baseSpellName))
        if id == self.spellID and IsUsableSpell(info.spellID) then
            return LM.Mount.IsCastable(self)
        end
    end
    return false
end
