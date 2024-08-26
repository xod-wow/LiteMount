--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local TABLET_OF_GHOST_WOLF_AURA = C_Spell.GetSpellName(168799)

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

function LM.GhostWolf:GetFlags()
    local flags = LM.Mount.GetFlags(self)

    -- Ghost Wolf is also 100% speed if the Rehgar Earthfury bodyguard
    -- is following you around in Lost Isles (Legion). Unfortunately there's
    -- no way to detect him as far as I can tell.

    if flags.SLOW then
        local hasAura
        hasAura = LM.UnitAura('player', TABLET_OF_GHOST_WOLF_AURA)
        if hasAura then
            flags = CopyTable(flags)
            flags.SLOW = nil
        end
    end

    return flags
end

function LM.GhostWolf:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
