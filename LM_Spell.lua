--[[----------------------------------------------------------------------------

  LiteMount/LM_Spell.lua

  A mount summoned directly from a spell with no Mount Journal entry.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local issecretvalue = issecretvalue or function () return false end

LM.Spell = setmetatable({ }, LM.Mount)
LM.Spell.__index = LM.Spell

function LM.Spell:Get(data)

    local info = C_Spell.GetSpellInfo(data.spellID)

    if not info then
        LM.Debug("LM.Mount: Failed GetSpellInfo #"..data.spellID)
        return
    end

    local m = LM.Mount.new(self, data)

    m.name = info.name
    m.spellID = info.spellID
    m.icon = info.iconID

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

    -- Is there any way to check if the spell can be cast in M+
    local cooldownInfo = C_Spell.GetSpellCooldown(self.spellID)
    if cooldownInfo and not issecretvalue(cooldownInfo.startTime) and cooldownInfo.startTime > 0 then
        return false
    end

    return LM.Mount.IsCastable(self)
end
