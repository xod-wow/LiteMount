--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local TABLET_OF_GHOST_WOLF_AURA = GetSpellInfo(168799)

_G.LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

function LM_GhostWolf:Get()
    return LM_Spell.Get(self, LM_SPELL.GHOST_WOLF, 'WALK')
end

function LM_GhostWolf:CurrentFlags()
    -- This had better return a copy of tha table.
    local flags = LM_Mount.CurrentFlags(self)

    -- Ghost Wolf is also 100% speed if the Rehgar Earthfury bodyguard
    -- is following you around in Lost Isles (Legion). Unfortunately there's
    -- no way to detect him as far as I can tell.

    if flags.WALK then
        if UnitAura("player", TABLET_OF_GHOST_WOLF_AURA) then
            flags.WALK = nil
            flags.RUN = true
        end
    end

    return flags
end
