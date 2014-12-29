--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Spell = setmetatable({ }, LM_Mount)
LM_Spell.__index = LM_Spell

function LM_Spell:Get(spellId, forceKnown)

    if not forceKnown and not IsSpellKnown(spellId) then return end

    if self.cacheBySpellId[spellId] then
        return self.cacheBySpellId[spellId]
    end

    local spell_info = { GetSpellInfo(spellId) }

    if not spell_info[1] then
        LM_Debug("LM_Mount: Failed GetMountBySpell #"..spellId)
        return
    end

    local m = setmetatable({ }, LM_Spell)

    m.name = spell_info[1]
    m.spellName = spell_info[1]
    m.icon = spell_info[3]
    m.flags = 0
    m.tags = { }
    m.castTime = spell_info[4]
    m.spellId = spell_info[7]

    self.cacheByName[m.name] = m
    self.cacheBySpellId[m.spellId] = m

    return m
end

function LM_Spell:IsUsable(flags)
    if not IsUsableSpell(self:SpellId()) then return end
    return LM_Mount.IsUsable(self, flags)
end
