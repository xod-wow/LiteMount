--[[----------------------------------------------------------------------------

  LiteMount/RuleSet.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LM.RuleSet = { }

function LM.RuleSet:Get()
    return CreateFromMixins(LM.RuleSet)
end

function LM.RuleSet:CompileLine(line, lineNumber)
    local rule = LM.Rule:ParseLine(line)
    if rule then
        tinsert(self, rule)
        for _, errorText in ipairs(rule.errors) do
            self.errors = self.errors or {}
            tinsert(self.errors, { num=lineNumber, line=line, err=errorText })
        end
    end
end

function LM.RuleSet:Compile(lines)
    local ruleset = LM.RuleSet:Get()
    if type(lines) == 'table' then
        for i, line in ipairs(lines) do
            ruleset:CompileLine(line, i)
        end
    else
        local i = 1
        for line in lines:gmatch('([^\r\n]+)') do
            ruleset:CompileLine(line, i)
            i = i + 1
        end
    end
    return ruleset
end

function LM.RuleSet:PrintErrors()
    if self.errors then
        for _, info in ipairs(self.errors) do
            LM.PrintError(L.LM_ERR_BAD_RULE, info.line, info.err)
        end
    end
end

function LM.RuleSet:Run(context)
    -- Annoy people on purpose so they fix their action lists. Otherwise
    -- this should be moved into the places Compile() is called.
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
