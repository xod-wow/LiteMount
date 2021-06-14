--[[----------------------------------------------------------------------------

  LiteMount/Rules.lua

  An action rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LM.Rules = { }

local function replaceConstant(k) return LM.Vars:GetConst(k) end

local function ReadWord(line)
    local token, rest

    -- Skip whitespace
    token, rest = line:match('^(%s+)(.*)$')
    if token then return nil, rest end

    -- Skip from # to end of line
    token, rest = line:match('^#')
    if token then return nil, nil end

    -- Match ""
    token, rest = line:match('^("[^"]*")(.*)$')
    if token then return token, rest end

    -- Match '', turn into ""
    token, rest = line:match("^'([^']*)'(.*)$")
    if token then return '"' .. token .. '"', rest end

    -- Match [] empty condition, which is just skipped
    token, rest = line:match('^(%[%])(.*)$')
    if token then return nil, rest end

    -- Match regular conditions
    token, rest = line:match('^(%[.-%])(.*)$')
    if token then return token, rest end

    -- Match comma separated arguments
    token, rest = line:match('^([^,]+),?(.*)$')
    if token then return token, rest end
end

function LM.Rules:ParseLine(line)
    local argWords, condWords = { }, { }

    -- Note this is intentionally unanchored to skip leading whitespace
    local action, rest = line:match('(%S+)%s*(.*)')

    while rest ~= nil do
        local word
        word, rest = ReadWord(rest)
        if word then
            if word:match('^%[filter=.-%]$') then
                tinsert(argWords, word:sub(9, -2))
            elseif word:match('^%[.-%]$') then
                tinsert(condWords, word:sub(2, -2))
            else
                tinsert(argWords, word)
            end
        end
    end

    local conditions = { op="OR" }
    local vars

    for _, word in ipairs(condWords) do
        local clause = { op="AND" }
        for c in word:gmatch('[^,]+') do
            c = c:gsub('{.-}', function (k)
                    local v = LM.Vars:GetConst(k)
                    if v then
                        return v
                    else
                        vars = true
                    end
                 end)
            if c:sub(1,2) == 'no' then
                tinsert(clause, { c:sub(3), op = 'NOT' })
            else
                tinsert(clause, c)
            end
        end
        -- Simplify, no need for op="AND" if just one term
        if #clause < 2 then clause = clause[1] end
        if clause then
            tinsert(conditions, clause)
        end
    end

    -- Simplify if no need for op="OR"
    if #conditions < 2 then conditions = conditions[1] end

    local args = { }

    for _, word in ipairs(argWords) do
        word = word:gsub('{.-}', replaceConstant)
        if word:match('^".+"$') then
            tinsert(args, word:sub(2, -2))
        else
            for w in word:gmatch('[^,]+') do
                tinsert(args, w)
            end
        end
    end

    return {
        action = action,
        line = line,
        args = args,
        conditions = conditions,
        vars = vars
    }
end

function LM.Rules:Compile(text)
    local out = { }
    for line in text:gmatch('([^\r\n]+)') do
        line = line:gsub('%s*#.*', '')
        if line ~= '' then
            tinsert(out, self:ParseLine(line))
        end
    end

    return out
end

local function OneConditionToString(ruleCondition)

    local isNot

    -- Only handles 'NOT' for now
    if type(ruleCondition) == 'table' then
        if ruleCondition.op == 'NOT' then
            isNot = true
            ruleCondition = ruleCondition[1]
        else
            return ERROR_CAPS
        end
    end

    local cText = LM.Conditions:ToString(ruleCondition)
    local cArgText = LM.Conditions:ArgsToString(ruleCondition)

    local text
    if cArgText then
        text = string.format("%s : %s", cText, cArgText)
    else
        text = cText
    end
    if isNot then
        -- XXX LOCALIZE XXX
        return RED_FONT_COLOR:WrapTextInColorCode('NOT ' .. text)
    else
        return GREEN_FONT_COLOR:WrapTextInColorCode(text)
    end
end

function LM.Rules:ConditionsToString(rule)
    local conditions = {}
    for _, ruleCondition in ipairs(rule.conditions) do
        local text = OneConditionToString(ruleCondition)
        table.insert(conditions, GREEN_FONT_COLOR:WrapTextInColorCode(text))
    end
    return conditions
end

function LM.Rules:ActionToString(rule)
    local action = LM.Actions:ToString(rule.action, rule.args)
    local actionArg = LM.Actions:ArgsToString(rule.action, rule.args)
    if actionArg then
        return action .. '\n' .. actionArg
    else
        return action
    end
end

function LM.Rules:RuleToString(rule)
    return self:ConditionsToString(rule), self:ActionToString(rule)
end

function LM.Rules:Dispatch(rule, env)

    local isTrue = LM.Conditions:Eval(rule.conditions, env)

    local handler = LM.Actions:GetFlowControlHandler(rule.action)
    if handler then
        LM.Debug("Dispatching flow control action " .. rule.line)
        handler(rule.args or {}, env, isTrue)
        return
    end

    if not isTrue or LM.Actions:IsFlowSkipped(env) then
        return
    end

    handler = LM.Actions:GetHandler(rule.action)
    if not handler then
        LM.WarningAndPrint(format(L.LM_ERR_BAD_ACTION, rule.action))
        return
    end

    LM.Debug("Dispatching rule " .. (rule.line or rule.action))

    return handler(rule.args or {}, env)
end
