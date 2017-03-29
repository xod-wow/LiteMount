--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_SPELL.TABLET_OF_GHOST_WOLF = 168799

LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

function LM_GhostWolf:Get()
    local m = LM_Spell:Get(LM_SPELL.GHOST_WOLF)
    if m then setmetatable(m, LM_GhostWolf) end
    m.flags[LM_FLAG.WALK] = true
    return m
end
