--[[----------------------------------------------------------------------------

  LiteMount/RuleSet.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

LM.RuleSet = { }

function LM.RuleSet:Get()
    return CreateFromMixins(LM.RuleSet)
end

function LM.RuleSet:Compile(lines)
    local ruleset = LM.RuleSet:Get()
    if type(lines) == 'table' then
        for _,line in ipairs(lines) do
            local rule = LM.Rule:ParseLine(line)
            if rule then tinsert(ruleset, rule) end
        end
    else
        for line in lines:gmatch('([^\r\n]+)') do
            local rule = LM.Rule:ParseLine(line)
            if rule then tinsert(ruleset, rule) end
        end
    end
    return ruleset
end

function LM.RuleSet:Run(env)
    for n,rule in ipairs(self) do
        env.unit = nil
        local act = rule:Dispatch(env)
        if act then return act, n end
    end
end

function LM.RuleSet:HasApplyRules()
    for _,r in ipairs(self) do
        if r.action == 'ApplyRules' then
            return true
        end
    end
    return false
end
