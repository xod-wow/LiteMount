--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local TABLET_OF_GHOST_WOLF_AURA = GetSpellInfo(168799)

LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

function LM_GhostWolf:Get()
    local m = LM_Spell.Get(self, LM_SPELL.GHOST_WOLF)
    if m then
        m.flags = LM_FLAG.WALK
    end
    return m
end

function LM_GhostWolf:CurrentFlags()
    local flags = LM_Mount.CurrentFlags(self)

    if bit.band(flags, LM_FLAG.WALK) then
        if UnitAura("player", TABLET_OF_GHOST_WOLF_AURA) then
            flags = bit.band(flags, bit.bnot(LM_FLAG.WALK))
            flags = bit.bor(flags, LM_FLAG.RUN)
        end
    end

    return flags
end
