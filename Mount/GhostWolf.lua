--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local TABLET_OF_GHOST_WOLF_AURA = GetSpellInfo(168799)
local SPIRIT_PACK_AURA = GetSpellInfo(217850)

LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

function LM_GhostWolf:CurrentFlags()
    return LM_Options:ApplyMountFlags(self)
end

function LM_GhostWolf:Get()
    local m = LM_Spell:Get(LM_SPELL.GHOST_WOLF)
    if m then setmetatable(m, LM_GhostWolf) end
    m.flags[LM_FLAG.WALK] = true
    return m
end
