--[[----------------------------------------------------------------------------

  LiteMount/RuleBoolean.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

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

local function any(f, cond, context, ...)
    local n = select('#', ...)
    for i = 1, n do
        local v = select(i, ...)
        if f(cond, context, v) then return true end
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

function LM.RuleBoolean:EvalLeaf(context)
    -- Empty condition [] is true
    if self.condition == "" then
        return true
    end

    if self.condition:len() > 1 then
        if self.condition:sub(1,1) == '@' then
            context.rule.unit = self.condition:sub(2)
            return true
        end

        -- This is a mildly awful hack to allow setting binary options on actions
        -- using conditions instead of having heterogenous arg types or overloading
        -- the expression syntax (even more). Devoid of backwards compatibility it'd
        -- probably be better to have used this for Limit as well as Mount.
        if self.condition:sub(1,1) == '+' then
            context.rule[self.condition:sub(2)] = true
            return true
        elseif self.condition:sub(1,1) == '-' then
            context.rule[self.condition:sub(2)] = false
            return true
        end
    end

    local c = LM.Conditions:GetCondition(self.condition)
    if not c then
        -- Hopefully stopped at compile time and can't happen
        return false
    end

    if c.args then
        return c.handler(self, context, unpack(self.args))
    elseif #self.args == 0 then
        return c.handler(self, context)
    else
        return any(c.handler, self, context, unpack(self.args))
    end
end

function LM.RuleBoolean:EvalNot(context)
    return not self.conditions[1]:Eval(context)
end

-- the ANDed sections carry the per-rule context between them
function LM.RuleBoolean:EvalAnd(context)
    for _,c in ipairs(self.conditions) do
        local v = c:Eval(context)
        if not v then return false end
    end
    return true
end

-- Note: deliberately resets the per-rule context on false
function LM.RuleBoolean:EvalOr(context)
    if #self.conditions == 0 then
        return true
    end
    local origRuleContext = CopyTable(context.rule)
    for _,c in ipairs(self.conditions) do
        local v = c:Eval(context)
        if v then return v end
        context.rule = origRuleContext
    end
    return false
end

function LM.RuleBoolean:Eval(context)
    if self.op == 'LEAF' then
        return self:EvalLeaf(context)
    elseif self.op == 'NOT' then
        return self:EvalNot(context)
    elseif self.op == 'AND' then
        return self:EvalAnd(context)
    elseif self.op == 'OR' then
        return self:EvalOr(context)
    end
end

-- 3 or fewer ANDed conditions
function LM.RuleBoolean:IsSimpleCondition()
    if #self.conditions ~= 1 then
        return false
    end
    if #self.conditions[1].conditions > 3 then
        return false
    end
    return true
end

function LM.RuleBoolean:GetSimpleConditions()
    if self.conditions[1] then
        return self.conditions[1].conditions
    else
        return {}
    end
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
        local c, a = LM.Conditions:ToDisplay(s)
        if a then
            return string.format('%s : %s', c, a)
        elseif c then
            return c
        else
            return s.." |A:gmchat-icon-alert:15:15|a"
        end
    end
end

function LM.RuleBoolean:ValidateLeaf(badList)
    if self.condition == '' then
        return true
    elseif self.condition:len() > 1 then
        if self.condition:sub(1, 1) == '@' then
            return true
        elseif self.condition:sub(1, 1) == '+' then
            return true
        elseif self.condition:sub(1, 1) == '-' then
            return true
        end
    end
    local c = LM.Conditions:GetCondition(self.condition)
    if not c then
        table.insert(badList, self.condition)
    end
end

function LM.RuleBoolean:Validate(badList)
    badList = badList or {}
    if self.op == 'LEAF' then
        self:ValidateLeaf(badList)
    else
        for _, c in ipairs(self.conditions) do
            c:Validate(badList)
        end
    end
    if #badList == 0 then
        return true
    else
        return false, format(L.LM_ERR_BAD_CONDITION, table.concat(badList, ', '))
    end
end
