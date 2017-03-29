--[[----------------------------------------------------------------------------

  LiteMount/LM_RunningWild.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_RunningWild = setmetatable({ }, LM_Spell)
LM_RunningWild.__index = LM_RunningWild

function LM_RunningWild:Get()
    local m = LM_Spell:Get(LM_SPELL.RUNNING_WILD)
    if m then
        setmetatable(m, LM_RunningWild)
        m.flags[LM_FLAG.RUN] = true
    end
    return m
end
