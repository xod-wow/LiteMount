--[[----------------------------------------------------------------------------

  LiteMount/RuleArguments.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

LM.RuleArguments = { }

function LM.RuleArguments:Get(args)
    return CreateFromMixins(args or {}, LM.RuleArguments)
end
