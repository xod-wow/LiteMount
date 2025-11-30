--[[----------------------------------------------------------------------------

  LiteMount/LM_RunningWild.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local Env = LM.Environment

LM.RunningWild = setmetatable({ }, LM.Spell)
LM.RunningWild.__index = LM.RunningWild

local worgenPlayerModels = {
    [ 307453] = true,       -- Worgen male
    [ 307454] = true,       -- Worgen female
    [1011653] = true,       -- Human male
    [1000764] = true,       -- Human female
}

-- Running Wild doesn't work if you're shapeshifted in any way.

function LM.RunningWild:IsCastable()
    return worgenPlayerModels[Env.playerModel]
        and Env.knowsRidingSkill
        and LM.Spell.IsCastable(self)
end

function LM.RunningWild:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
