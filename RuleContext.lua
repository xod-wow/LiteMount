--[[----------------------------------------------------------------------------

  LiteMount/RuleContext.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

LM.RuleContext = {}

function LM.RuleContext:New(t)
    local context = Mixin(t or {}, LM.RuleContext)
    context.filters = { {} }
    context.flowControl = {}
    return context
end

function LM.RuleContext:Clone()
    return CopyTable(self)
end

