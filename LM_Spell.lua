--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_Spell = setmetatable({ }, LM_Mount)
LM_Spell.__index = LM_Spell

function LM_Spell:Get(spellID, ...)

    local name, _, icon = GetSpellInfo(spellID)

    if not name then
        LM_Debug("LM_Mount: Failed GetSpellInfo #"..spellID)
        return
    end

    local m = LM_Mount.new(self, spellID)

    m.name = name
    m.spellID = spellID
    m.icon = icon
    m.isCollected = IsSpellKnown(m.spellID)
    m.flags = { }

    for i = 1, select('#', ...) do
        local f = select(i, ...)
        m.flags[f] = true
    end

    return m
end

function LM_Spell:Refresh()
    self.isCollected = IsSpellKnown(self.spellID)
    LM_Mount.Refresh(self)
end

function LM_Spell:IsCastable()
    if not IsSpellKnown(self.spellID) or not IsUsableSpell(self.spellID) then
        return false
    end
    return LM_Mount.IsCastable(self)
end
