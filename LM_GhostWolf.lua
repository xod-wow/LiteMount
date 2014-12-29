--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

function LM_GhostWolf:DefaultFlags(v)
    return LM_FLAG_BIT_WALK
end

function LM_GhostWolf:Get()
    local m = LM_Spell:Get(LM_SPELL_GHOST_WOLF)
    if m then setmetatable(m, LM_GhostWolf) end
    return m
end
