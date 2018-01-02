--[[----------------------------------------------------------------------------

  LiteMount/LM_RunningWild.lua

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_RunningWild = setmetatable({ }, LM_Spell)
LM_RunningWild.__index = LM_RunningWild

function LM_RunningWild:Get()
    return LM_Spell.Get(self, LM_SPELL.RUNNING_WILD, 'RUN')
end
