--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

LM.GhostWolf = setmetatable({ }, LM.Spell)
LM.GhostWolf.__index = LM.GhostWolf

function LM.GhostWolf:IsCancelable()
    return false
end

function LM.GhostWolf:IsCastable()
    if LM.UnitAura('player', self.spellID) then
        return false
    end
    return LM.Spell.IsCastable(self)
end

function LM.GhostWolf:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
