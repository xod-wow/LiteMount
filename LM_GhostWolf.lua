--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2019 Mike Battersby

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
    local flags = LM_Mount.CurrentFlags(self)

    -- Ghost Wolf is also 100% speed if the Rehgar Earthfury bodyguard
    -- is following you around in Lost Isles (Legion). Unfortunately there's
    -- no way to detect him as far as I can tell.

    if flags.WALK then
        local hasAura
        if _G.AuraUtil then
            hasAura = AuraUtil.FindAuraByName(TABLET_OF_GHOST_WOLF_AURA, "player")
        else
            hasAura = UnitAura("player", TABLET_OF_GHOST_WOLF_AURA)
        end
        if hasAura then
            flags = CopyTable(flags)
            flags.WALK = nil
            flags.RUN = true
        end
    end

    return flags
end
