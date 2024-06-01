--[[----------------------------------------------------------------------------

  LiteMount/LM_Soar.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.Soar = setmetatable({ }, LM.Spell)
LM.Soar.__index = LM.Soar

function LM.Soar:Get(...)
    local m = LM.Spell.Get(self, ...)
    if m then
        m.dragonRiding = true
        return m
    end
end

-- Soar gives an error message instead of IsUsableSpell false in a variety
-- of pretty ordinary circumstances.

function LM.Soar:IsCastable()
    if IsSubmerged() then
        return false
    else
        return LM.Spell.IsCastable(self)
    end
end
