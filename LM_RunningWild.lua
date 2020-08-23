--[[----------------------------------------------------------------------------

  LiteMount/LM_RunningWild.lua

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.RunningWild = setmetatable({ }, LM.Spell)
LM.RunningWild.__index = LM.RunningWild

function LM.RunningWild:Get()
    return LM.Spell.Get(self, LM.SPELL.RUNNING_WILD, 'RUN')
end
