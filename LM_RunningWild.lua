--[[----------------------------------------------------------------------------

  LiteMount/LM_RunningWild.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.RunningWild = setmetatable({ }, LM.Spell)
LM.RunningWild.__index = LM.RunningWild

function LM.RunningWild:Get()
    return LM.Spell.Get(self, LM.SPELL.RUNNING_WILD, 'RUN')
end

local worgenPlayerModels = {
    [ 307453] = true,       -- Worgen male
    [ 307454] = true,       -- Worgen female
    [1011653] = true,       -- Human male
    [1000764] = true,       -- Human female
}

-- Running Wild doesn't work if you're shapeshifted in any way.

function LM.RunningWild:IsCastable()
    local id = LM.Environment:GetPlayerModel()
    return worgenPlayerModels[id]
        and LM.Environment:KnowsRidingSkill()
        and LM.Spell.IsCastable(self)
end

function LM.RunningWild:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
