--[[----------------------------------------------------------------------------

  LiteMount/RuleBoolean.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

--[[

    <conditions>    :=  <condition> |
                        <condition> <conditions>

    <condition>     :=  "[" <expressions> "]"

    <expressions>   :=  <expr> |
                        <expr> "," <expressions>

    <expr>          :=  "no" <setting> |
                        <setting>

    <setting>       :=  <tag> |
                        <tag> ":" <args>

    <args>          :=  <arg> |
                        <arg> / <args>

    <arg>           :=  [-a-zA-Z0-9]+

    <tag>           :=  See CONDITIONS array in code

]]

local function any(f, cond, env, ...)
    local n = select('#', ...)
    for i = 1, n do
        local v = select(i, ...)
        if f(cond, env, v) then return true end
    end
    return false
end

LM.RuleBoolean = { }

function LM.RuleBoolean:Get()
    return CreateFromMixins(LM.RuleBoolean)
end

function LM.RuleBoolean:Leaf(text)
    local c = LM.RuleBoolean:Get()
    c.op = 'LEAF'

    local condition, argstr = strsplit(':', text)

    c.condition = condition

    if argstr then
        c.args = { strsplit('/', argstr) }
    else
        c.args = { }
    end

    return c
end

function LM.RuleBoolean:And(...)
    local c = LM.RuleBoolean:Get()
    c.op = 'AND'
    c.conditions = { ... }
    return c
end

function LM.RuleBoolean:Or(...)
    local c = LM.RuleBoolean:Get()
    c.op = 'OR'
    c.conditions = { ... }
    return c
end

function LM.RuleBoolean:Not(cond)
    local c = LM.RuleBoolean:Get()
    c.op = 'NOT'
    c.conditions = { cond }
    return c
end

function LM.RuleBoolean:EvalLeaf(env)
    local condition = LM.Vars:StrSubVars(self.condition)

    -- Empty condition [] is true
    if condition == "" then return true end

    if condition:sub(1,1) == '@' then
        env.unit = condition:sub(2)
        return true
    end

    local c = LM.Conditions:GetCondition(self.condition)
    if not c then
        LM.WarningAndPrint(format(L.LM_ERR_BAD_CONDITION, cond))
        return false
    end

    if c.args then
        return c.handler(self, env, unpack(self.args))
    elseif #self.args == 0 then
        return c.handler(self, env)
    else
        return any(c.handler, self, env, unpack(self.args))
    end
end

function LM.RuleBoolean:EvalNot(env)
    return not self.conditions[1]:Eval(env)
end

-- the ANDed sections carry the unit between them
function LM.RuleBoolean:EvalAnd(env)
    for _,c in ipairs(self.conditions) do
        local v = c:Eval(env)
        if not v then return false end
    end
    return true
end

-- Note: deliberately resets the unit on false
function LM.RuleBoolean:EvalOr(env)
    if #self.conditions == 0 then
        return true
    end
    for _,c in ipairs(self.conditions) do
        local v = c:Eval(env)
        if v then return v end
        env.unit = nil
    end
    return false
end

function LM.RuleBoolean:Eval(env)
    if self.op == 'LEAF' then
        return self:EvalLeaf(env)
    elseif self.op == 'NOT' then
        return self:EvalNot(env)
    elseif self.op == 'AND' then
        return self:EvalAnd(env)
    elseif self.op == 'OR' then
        return self:EvalOr(env)
    end
end

function LM.RuleBoolean:GetSimpleConditions()
    return self.conditions[1].conditions
end

local function UnBracket(txt) return txt:sub(2,-2) end

function LM.RuleBoolean:ToString()
    if self.op == 'LEAF' then
        if #self.args > 0 then
            local argstr = table.concat(self.args, '/')
            return '[' .. self.condition .. ':' .. argstr .. ']'
        else
            return '[' .. self.condition .. ']'
        end
    elseif self.op == 'NOT' then
        return '[' .. 'no' .. self.conditions[1]:ToString():sub(2,-2) .. ']'
    elseif self.op == 'OR' then
        local children = LM.tMap(self.conditions, LM.RuleBoolean.ToString)
        return table.concat(children, '')
    elseif self.op == 'AND' then
        local children = LM.tMap(self.conditions, LM.RuleBoolean.ToString)
        children = LM.tMap(children, UnBracket)
        return '[' .. table.concat(children, ',') .. ']'
    end
end

-- This works exactly just enough for the simple rules that can be created
-- from the UI, and will totally crap itself on a real rule.

function LM.RuleBoolean:ToDisplay()
    if self.op == 'OR' then
        if #self.conditions == 0 then
            return { GREEN_FONT_COLOR:WrapTextInColorCode(ALWAYS:upper()) }
        else
            return self.conditions[1]:ToDisplay()
        end
    elseif self.op == 'AND' then
        local out = { }
        for _,c in ipairs(self.conditions) do
            local text = c:ToDisplay()
            if c.op == 'NOT' then
                table.insert(out, RED_FONT_COLOR:WrapTextInColorCode(text))
            else
                table.insert(out, GREEN_FONT_COLOR:WrapTextInColorCode(text))
            end
        end
        return out
    elseif self.op == 'NOT' then
        local text = self.conditions[1]:ToDisplay()
        return string.format(L.LM_NOT_FORMAT, text)
    elseif self.op == 'LEAF' then
        local s = UnBracket(self:ToString())
        local c, a = LM.Conditions:ToString(s), LM.Conditions:ArgsToString(s)
        if a then
            return string.format('%s : %s', c, a)
        else
            return c
        end
    end
end
