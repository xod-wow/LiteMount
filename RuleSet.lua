--[[----------------------------------------------------------------------------

  LiteMount/RuleSet.lua

  Copyright 2011 Mike Battersby

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
        for i, line in ipairs(lines) do
            local rule, err = LM.Rule:ParseLine(line)
            if rule then
                tinsert(ruleset, rule)
            elseif err then
                ruleset.errors = ruleset.errors or {}
                tinsert(ruleset.errors, { num=i, line=line, err=err })
            end
        end
    else
        local i = 1
        for line in lines:gmatch('([^\r\n]+)') do
            local rule, err = LM.Rule:ParseLine(line)
            if rule then
                tinsert(ruleset, rule)
            elseif err then
                ruleset.errors = ruleset.errors or {}
                tinsert(ruleset.errors, { num=i, line=line, err=err })
            end
            i = i + 1
        end
    end
    return ruleset
end

function LM.RuleSet:PrintErrors()
    if self.errors then
        for _, info in ipairs(self.errors) do
            LM.PrintError(info.err)
        end
    end
end

function LM.RuleSet:Run(context)
    -- Annoy people on purpose so they fix their action lists
    self:PrintErrors()
    for n,rule in ipairs(self) do
        context.rule = {}
        local act = rule:Dispatch(context)
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
