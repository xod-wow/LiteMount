--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

local TABLET_OF_GHOST_WOLF_AURA = GetSpellInfo(168799)
local SPIRIT_PACK_AURA = GetSpellInfo(217850)

LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

function LM_GhostWolf:Flags(v)
    if UnitAura("player", TABLET_OF_GHOST_WOLF_AURA) then
        return LM_FLAG_BIT_RUN
    elseif UnitAura("player", SPIRIT_PACK_AURA) then
        return LM_FLAG_BIT_RUN
    else
        return LM_FLAG_BIT_WALK
    end
end

function LM_GhostWolf:Get()
    local m = LM_Spell:Get(LM_SPELL_GHOST_WOLF)
    if m then setmetatable(m, LM_GhostWolf) end
    return m
end
