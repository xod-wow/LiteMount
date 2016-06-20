--[[----------------------------------------------------------------------------

  LiteMount/LM_GhostWolf.lua

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

local LM_SPELL_TABLET_OF_GHOST_WOLF = 168799

LM_GhostWolf = setmetatable({ }, LM_Spell)
LM_GhostWolf.__index = LM_GhostWolf

local tabletBuffName

function LM_GhostWolf:Flags(v)
    if not tabletBuffName then
        tabletBuffName = GetSpellInfo(LM_SPELL_TABLET_OF_GHOST_WOLF)
    end
    if UnitAura("player", tabletBuffName) then
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
