--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Spell = setmetatable({ }, LM.Mount)
LM.Spell.__index = LM.Spell

function LM.Spell:Get(spellID, ...)

    local name, _, icon = GetSpellInfo(spellID)

    if not name then
        LM.Debug("LM.Mount: Failed GetSpellInfo #"..spellID)
        return
    end

    local m = LM.Mount.new(self, spellID)

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

function LM.Spell:Refresh()
    self.isCollected = IsSpellKnown(self.spellID)
    LM.Mount.Refresh(self)
end

function LM.Spell:IsCastable()
    if not IsSpellKnown(self.spellID) or not IsUsableSpell(self.spellID) then
        return false
    end
    return LM.Mount.IsCastable(self)
end
