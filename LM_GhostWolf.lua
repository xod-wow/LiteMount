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
    -- Not castable if we are already in ghost wolf form. Assumption is that
    -- if the spell is castable then you are a shaman with ghost wolf, and
    -- since there is only one form GetShapeshiftForm tests if you're in it.
    return LM.Spell.IsCastable(self) and GetShapeshiftForm(true) == 0
end

function LM.GhostWolf:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
