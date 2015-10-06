--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Spell = setmetatable({ }, LM_Mount)
LM_Spell.__index = LM_Spell

function LM_Spell:Get(spellId, forceKnown)

    if not forceKnown and not IsSpellKnown(spellId) then return end

    if self.cacheBySpellId[spellId] then
        return self.cacheBySpellId[spellId]
    end

    local name, rank, icon, castingTime, _, _, _ = GetSpellInfo(spellId)

    if not name then
        LM_Debug("LM_Mount: Failed GetSpellInfo #"..spellId)
        return
    end

    local m = setmetatable(LM_Mount:new(), LM_Spell)

    m.name = name
    m.spellName = name
    m.icon = icon
    m.flags = 0
    m.castTime = castingTime
    m.spellId = spellId

    self.cacheByName[m:Name()] = m
    self.cacheBySpellId[m:SpellId()] = m

    return m
end

function LM_Spell:IsUsable()
    if not IsUsableSpell(self:SpellId()) then return end
    return LM_Mount.IsUsable(self)
end
