--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local TABLET_OF_GHOST_WOLF_AURA = GetSpellInfo(168799)

LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

function LM_GhostWolf:Get()
    return LM_Spell.Get(self, LM_SPELL.GHOST_WOLF, LM_FLAG.WALK)
end

function LM_GhostWolf:CurrentFlags()
    local flags = LM_Mount.CurrentFlags(self)

    -- Ghost Wolf is also 100% speed if the Rehgar Earthfury bodyguard
    -- is following you around in Lost Isles (Legion). Unfortunately there's
    -- no way to detect him as far as I can tell.

    if bit.band(flags, LM_FLAG.WALK) then
        if UnitAura("player", TABLET_OF_GHOST_WOLF_AURA) then
            flags = bit.band(flags, bit.bnot(LM_FLAG.WALK))
            flags = bit.bor(flags, LM_FLAG.RUN)
        end
    end

    return flags
end
