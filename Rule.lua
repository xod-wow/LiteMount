--[[----------------------------------------------------------------------------

  LiteMount/Rule.lua

  An action rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

LM.Rule = { }

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

function LM.Rule:Get()
    return CreateFromMixins(LM.Rule)
end

function LM.Rule:ParseLine(line)

    local r = LM.Rule:Get()

    r.line = line

    local argWords, condWords, rest = { }, { }, nil

    -- Note this is intentionally unanchored to skip leading whitespace
    r.action, rest = line:match('(%S+)%s*(.*)')

    -- Commands and empty are skipped
    if not r.action or r.action == '' or r.action:sub(1,1) == '#' then
        return
    end

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

    local conditions = { }

    for _, word in ipairs(condWords) do
        local clause = { }
        for c in word:gmatch('[^,]+') do
            c = c:gsub('{.-}', function (k)
                    local v = LM.Vars:GetConst(k)
                    if v then
                        return v
                    else
                        r.vars = true
                    end
                 end)
            if c:sub(1,2) == 'no' then
                local l = LM.RuleBoolean:Leaf(c:sub(3))
                table.insert(clause, LM.RuleBoolean:Not(l))
            else
                table.insert(clause, LM.RuleBoolean:Leaf(c))
            end
        end
        table.insert(conditions, LM.RuleBoolean:And(unpack(clause)))
    end

    r.conditions = LM.RuleBoolean:Or(unpack(conditions))

    r.args = { }

    for _, word in ipairs(argWords) do
        word = word:gsub('{.-}', replaceConstant)
        if word:match('^".+"$') then
            tinsert(args, word:sub(2, -2))
        else
            for w in word:gmatch('[^,]+') do
                tinsert(r.args, w)
            end
        end
    end

    return r
end

function LM.Rule:Dispatch(env)

    local isTrue = self.conditions:Eval(env)

    local handler = LM.Actions:GetFlowControlHandler(self.action)
    if handler then
        LM.Debug("Dispatching flow control action " .. self.line)
        handler(self.args or {}, env, isTrue)
        return
    end

    if not isTrue or LM.Actions:IsFlowSkipped(env) then
        return
    end

    handler = LM.Actions:GetHandler(self.action)
    if not handler then
        LM.WarningAndPrint(format(L.LM_ERR_BAD_ACTION, self.action))
        return
    end

    LM.Debug("Dispatching rule " .. (self.line or self:ToLine(self)))

    return handler(self.args or {}, env)
end

function LM.Rule:ToString()
    local out = { self.action }
    local cText = self.conditions:ToString()
    if cText then table.insert(out, cText) end
    if self.args then table.insert(out, table.concat(self.args, ',')) end
    return table.concat(out, ' ')
end

function LM.Rule:ActionToDisplay()
    local action = LM.Actions:ToString(self.action, self.args)
    local actionArg = LM.Actions:ArgsToString(self.action, self.args)
    if actionArg then
        return action .. '\n' .. actionArg
    else
        return action
    end
end

function LM.Rule:ToDisplay()
    return self.conditions:ToDisplay(), self:ActionToDisplay()
end

-- Simple rules can be used in the user rules UI. They must have:
--   * action one of Mount/SmartMount/LimitSet/LimitInclude/LimitExclude
--   * maximum 3 ANDed conditions, no ORed conditions
--   * exactly one action argument

local SimpleActions = {
    "Mount",
    "SmartMount",
    "LimitSet",
    "LimitInclude",
    "LimitExclude",
}

function LM.Rule:IsSimpleRule()
    if not tContains(SimpleActions, self.action) then
        return false
    end
    if #self.args ~= 1 then
        return false
    end
    if not self.conditions:IsSimpleCondition() then
        return false
    end
    return true
end

-- This is a converter from the original storage format, used only
-- by LM.Options:VersionUpgrade8
--
-- Example:
--
--  {
--      ["action"] = "Mount",
--      ["conditions"] = {
--          "tracking:Find Herbs",
--          { "class:DRUID", ["op"] = "NOT" },
--          ["op"] = "AND",
--      },
--      ["args"] = { "HERB" },
--  }
--


function LM.Rule:MigrateFromTable(tableRule)
    local textParts = { tableRule.action }
    if tableRule.conditions then
        local cTexts = { }
        for _,c in ipairs(tableRule.conditions) do
            if type(c) == 'table' then      -- only 'NOT'
                table.insert(cTexts, 'no'..c[1])
            else
                table.insert(cTexts, c)
            end
        end
        table.insert(textParts, '[' .. table.concat(cTexts, ',') .. ']')
    end
    if tableRule.args then
        table.insert(textParts, table.concat(tableRule.args, ','))
    end
    return table.concat(textParts, ' ')
end

