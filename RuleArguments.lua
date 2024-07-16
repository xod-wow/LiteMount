--[[----------------------------------------------------------------------------

  LiteMount/RuleArguments.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LM.RuleArguments = { }

function LM.RuleArguments:Get(tokens, ...)
    tokens = tokens or {}
    if type(tokens) == 'table' then
        return CreateFromMixins(tokens, LM.RuleArguments)
    else
        return CreateFromMixins({ tokens, ...}, LM.RuleArguments)
    end
end

function LM.RuleArguments:Clone()
    local clone = LM.RuleArguments:Get()
    for _, token in ipairs(self) do
        table.insert(clone, token)
    end
    return clone
end

function LM.RuleArguments:Append(tokens, ...)
    local out = self:Clone()
    if tokens ~= nil then
        if type(tokens) ~= 'table' then
            tokens = { tokens, ... }
        end
        for _, v in ipairs(tokens) do
            table.insert(out, v)
        end
    end
    return out
end

function LM.RuleArguments:Prepend(tokens, ...)
    local out = self:Clone()
    if tokens ~= nil then
        if type(tokens) ~= 'table' then
            tokens = { tokens, ... }
        end
        for i, v in ipairs(tokens) do
            table.insert(out, i, v)
        end
    end
    return out
end

function LM.RuleArguments:ToString()
    return table.concat(self, '')
end

local UNARYOPERATORS = {
    ['~'] = true,
    ['-'] = true,
    ['+'] = true,
    ['='] = true,
}

local OPERATORS = {
    ['~'] = true,
    ['-'] = true,
    ['+'] = true,
    ['='] = true,
    ['/'] = true,
    [','] = true,
}

function LM.RuleArguments:IsSimpleArguments()
    if #self == 1 then
        return true
    elseif #self == 2 and UNARYOPERATORS[self[1]] then
        return true
    else
        return false
    end
end

function LM.RuleArguments:ReplaceVars()
    local newTokens = {}
    for _,l in ipairs(self) do
        l = LM.Vars:StrSubVars(l)
        tinsert(newTokens, l)
    end
    return LM.RuleArguments:Get(newTokens)
end

function LM.RuleArguments:ParseList()
    if self.asList == nil then
        self.asList = {}
        for i, token in ipairs(self) do
            if token == '/' or token == ',' then
                -- we'll accept either as list delims, even mixed
                if i == 1 or i == #self then
                    -- SYNTAX ERROR : leading or trailing operator
                    return nil
                elseif self[i-1] == '/' or self[i-1] == ',' then
                    -- SYNTAX ERROR : consecutive operators
                    return nil
                end
            elseif OPERATORS[token] then
                return nil
            else
                table.insert(self.asList, token)
            end
        end
    end
    return self.asList
end

-- A unary operator that must be the very first token
local function ReduceStart(t, op)
    if t[1] == op then
        if #t == 1 then
            return false    -- SYNTAX ERROR : only operator
        end
        table.remove(t, 1)
        if OPERATORS[t[1]] then
            return false    -- SYNTAX ERROR : consecutive operators
        end
        t[1] = { op = op, t[1] }
    end
    return true
end

local function ReduceUnary(t, op)
    local i = 1
    while i <= #t do
        if t[i] == op then
            if i+1 > #t then
                return false    -- SYNTAX ERROR : no operator arg
            end
            table.remove(t, i)
            if OPERATORS[t[i]] then
                return false    -- SYNTAX ERROR : consecutive operators
            end
            t[i] = { op = op, t[i] }
        end
        i = i + 1
    end
    return true
end

local function ReduceBinary(t, op)
    local i = 1
    while i <= #t do
        if t[i] == op then
            if i == 1 or i+1 > #t then
                return false    -- SYNTAX ERROR : no LHS or RHS arg
            end
            table.remove(t, i)
            local rhs = table.remove(t, i)
            if OPERATORS[rhs] then
                return false    -- SYNTAX ERROR : consecutive operators
            end
            if type(t[i-1]) == 'table' and t[i-1].op == op then
                table.insert(t[i-1], rhs)
            else
                if type(t[i-1]) == 'string' and OPERATORS[t[i-1]] then
                    return false    -- SYNTAX ERROR : consecutive operators
                end
                t[i-1] = { op = op, t[i-1], rhs }
            end
        else
            i = i + 1
        end
    end
    return true
end

function LM.RuleArguments:ParseExpression()
    if self.asExpression == nil then
        local t = { }
        for i, token in ipairs(self) do t[i] = token end

        -- Returns nil on syntax error. These are in precedence order.
        -- No support for parens means no recursion, hooray!

        if not ReduceUnary(t, '~')  then return nil end
        if not ReduceBinary(t, '/') then return nil end
        if not ReduceStart(t, '+')  then return nil end
        if not ReduceStart(t, '-')  then return nil end
        if not ReduceStart(t, '=')  then return nil end
        if not ReduceBinary(t, ',') then return nil end

        self.asExpression = t[1]
    end
    return self.asExpression
end

function LM.RuleArguments:Validate(action)
    local argType = LM.Actions:GetArgType(action)
    if argType == 'expression' and #self > 0 then
        if self:ParseExpression() == nil then
            return false, format(L.LM_ERR_BAD_ARGUMENTS, self:ToString())
        end
    elseif argType == 'list' then
        if self:ParseList() == nil then
            return false, format(L.LM_ERR_BAD_ARGUMENTS, self:ToString())
        end
    elseif argType == 'none' then
        if #self > 0 then
            return false, format(L.LM_ERR_BAD_ARGUMENTS, self:ToString())
        end
    elseif argType == 'macrotext' then
        local macrotext = self:ToString()
        if macrotext:sub(1,1) ~= '/' then
            return false, format(L.LM_ERR_BAD_ARGUMENTS, macrotext)
        end
    elseif argType == 'value' then
        return #self == 1, format(L.LM_ERR_BAD_ARGUMENTS, self:ToString())
    elseif argType == 'valueOrNone' then
        return #self == 0 or #self == 1, format(L.LM_ERR_BAD_ARGUMENTS, self:ToString())
    end
    return true
end
