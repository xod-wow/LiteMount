--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.Spell = setmetatable({ }, LM.Mount)
LM.Spell.__index = LM.Spell

function LM.Spell:Get(spellID, ...)

    local info = C_Spell.GetSpellInfo(spellID)

    if not info then
        LM.Debug("LM.Mount: Failed GetSpellInfo #"..spellID)
        return
    end

    local m = LM.Mount.new(self, info.spellID)

    m.name = info.name
    m.spellID = info.spellID
    m.icon = info.iconID
    m.flags = { }

    for i = 1, select('#', ...) do
        local f = select(i, ...)
        m.flags[f] = true
    end

    return m
end

function LM.Spell:IsCollected()
    return IsPlayerSpell(self.spellID)
end

function LM.Spell:IsCastable()
    if not IsPlayerSpell(self.spellID) then
        return false
    end

    if not C_Spell.IsSpellUsable(self.spellID) then
        return false
    end

    local cooldownInfo = C_Spell.GetSpellCooldown(self.spellID)
    if cooldownInfo and cooldownInfo.startTime > 0 then
        return false
    end

    return LM.Mount.IsCastable(self)
end
