--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Spell = setmetatable({ }, LM_Mount)
LM_Spell.__index = LM_Spell

function LM_Spell:Get(spellID, forceKnown)

    if not forceKnown and not IsSpellKnown(spellID) then return end

    if self.cacheBySpellID[spellID] then
        return self.cacheBySpellID[spellID]
    end

    local name, rank, icon, castingTime, _, _, _ = GetSpellInfo(spellID)

    if not name then
        LM_Debug("LM_Mount: Failed GetSpellInfo #"..spellID)
        return
    end

    local m = setmetatable(LM_Mount:new(), LM_Spell)

    m.name = name
    m.spellName = name
    m.icon = icon
    m.flags = 0
    m.castTime = castingTime
    m.spellID = spellID

    self.cacheByName[m:Name()] = m
    self.cacheBySpellID[m:SpellID()] = m

    return m
end

function LM_Spell:IsUsable()
    if not IsUsableSpell(self:SpellID()) then return end
    return LM_Mount.IsUsable(self)
end
