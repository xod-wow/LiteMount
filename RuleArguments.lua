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

function LM.RuleArguments:Get(tokens, ...)
    tokens = tokens or {}
    if type(tokens) == 'table' then
        return CreateFromMixins(tokens or {}, LM.RuleArguments)
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
            table.insert(out, v, i)
        end
    end
    return out
end

function LM.RuleArguments:ToString()
    if #self > 0 then
        return table.concat(self, '')
    end
end

local unaryTokenOperators = {
    ['~'] = true,
    ['-'] = true,
    ['+'] = true,
    ['='] = true,
}

function LM.RuleArguments:IsSimpleArguments()
    if #self == 1 then
        return true
    elseif #self == 2 and unaryTokenOperators[self[1]] then
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
                -- pass
            else
                table.insert(self.asList, token)
            end
        end
    end
    return self.asList
end

function LM.RuleArguments:ParseFilter()
    if self.asFilter == nil then
        self.asFilter = {}
        local mech
        for i, token in ipairs(self) do
            if token == '-' or token == '+' or token  == '=' then
                mech = token
            elseif token == '/' then
                -- pass
            elseif token == ',' then
                mech = nil
            else
                table.insert(self.asFilter, (mech or '') .. token)
            end
        end
    end
    return self.asFilter
end

function LM.RuleArguments:ParseMountExpression()
    if self.asMountExpression == nil then
        local t, state, negate = {}, ',', false
        for i, token in ipairs(self) do
            if token == '/' then
                state = token
            elseif token == ',' then
                state = token
                negate = false
            elseif token == '~' then
                negate = true
            elseif state == '/' and negate == false then
                if type(t[#t]) ~= 'table' then
                    t[#t] = { t[#t] }
                end
                table.insert(t[#t], token)
            else
                table.insert(t, token)
            end
        end
        self.asMountExpression = t
    end
    return self.asMountExpression
end
