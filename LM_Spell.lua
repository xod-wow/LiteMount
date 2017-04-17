--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Spell = setmetatable({ }, LM_Mount)
LM_Spell.__index = LM_Spell

function LM_Spell:Get(spellID)

    local name, rank, icon, castTime, _, _, _ = GetSpellInfo(spellID)

    if not name then
        LM_Debug("LM_Mount: Failed GetSpellInfo #"..spellID)
        return
    end

    local m = setmetatable(LM_Mount:new(), LM_Spell)

    m.name = name
    m.spellName = name
    m.icon = icon
    m.flags = 0
    m.castTime = castTime
    m.spellID = spellID
    m.isCollected = IsSpellKnown(m.spellID)

    return m
end

function LM_Spell:Refresh()
    self.isCollected = IsSpellKnown(self.spellID)
end

function LM_Spell:IsUsable()
    if not IsSpellKnown(self.spellID) or not IsUsableSpell(self.spellID) then
        return false
    end
    return LM_Mount.IsUsable(self)
end
