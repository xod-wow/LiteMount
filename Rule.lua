--[[----------------------------------------------------------------------------

  LiteMount/Rule.lua

  An action rule.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LM.Rule = { }

local function ReadWord(line)
    local token, rest

    -- Skip whitespace
    token, rest = line:match('^(%s+)(.*)$')
    if token then return nil, rest end

    -- Skip from # to end of line
    token = line:match('^#')
    if token then return nil, nil end

    -- Match ""
    token, rest = line:match('^"(.-)"(.*)$')
    if token then return token, rest end

    -- Match ''
    token, rest = line:match("^'(.-)'(.*)$")
    if token then return token, rest end

    -- Match conditions (includes empty condition [])
    token, rest = line:match('^(%[.-%])(.*)$')
    if token then return token, rest end

    -- Match argument operator tokens - + = , / ~
    token, rest = line:match('^([-+=,/~])(.*)$')
    if token then return token, rest end

    -- Match argument word tokens
    token, rest = line:match('^([^,/]+)(.*)$')
    if token then return token, rest end
end

function LM.Rule:ParseLine(line)

    local r = CreateFromMixins(LM.Rule)

    r.errors = {}
    r.line = line

    local argTokens, condWords, rest = { }, { }

    -- Note this is intentionally unanchored to skip leading whitespace
    r.action, rest = line:match('(%S+)%s*(.*)')

    -- Commands and empty are skipped
    if not r.action or r.action == '' or r.action:sub(1,1) == '#' then
        return
    end

    -- once we see an argument we are done with conditions
    local inArgs = false

    while rest ~= nil do
        local word
        word, rest = ReadWord(rest)
        if word then
            word = LM.Vars:StrSubConsts(word)
            if not inArgs and word:match('^%[.*%]$') then
                tinsert(condWords, word:sub(2, -2))
            else
                tinsert(argTokens, word)
                inArgs = true
            end
        end
    end

    local conditions = { }

    for _, word in ipairs(condWords) do
        local clause = { }
        for c in word:gmatch('[^,]+') do
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

    -- Delay actually parsing the args until later when the actions can parse
    -- them as they need. Can probably parse them using LM.Actions:GetArgType,
    -- but I've done enough changing things for now so continue to let the
    -- action handlers call the parsing.

    r.args = LM.RuleArguments:Get(argTokens)

    r:CheckErrors()

    return r
end

function LM.Rule:CheckErrors()
    -- XXX At some point should probably OO into LM.RuleAction XXX
    local fcHandler = LM.Actions:GetFlowControlHandler(self.action)
    local handler = LM.Actions:GetHandler(self.action)

    if not ( fcHandler or handler ) then
        table.insert(self.errors, format(L.LM_ERR_BAD_ACTION, self.action))
    end

    local ok, err = self.conditions:Validate()
    if not ok then
        table.insert(self.errors, err)
    end

    ok, err = self.args:Validate(self.action)
    if not ok then
        table.insert(self.errors, err)
    end

    return true
end

function LM.Rule:Dispatch(context)

    if next(self.errors) then
        return
    end

    LM.Debug("  Evaluate rule: " .. (self.line or self:ToString()))

    local isTrue = self.conditions:Eval(context)

    LM.Debug("  * immediate conditions are " .. tostring(isTrue))

    local handler = LM.Actions:GetFlowControlHandler(self.action)
    if handler then
        LM.Debug("  * found flow control action, dispatching")
        handler(self.args, context, isTrue)
        return
    end

    if not isTrue or LM.Actions:IsFlowSkipped(context) then
        LM.Debug("  * skipping due to conditions or flow control")
        return
    end

    handler = LM.Actions:GetHandler(self.action)
    if not handler then
        LM.Debug("  * handler not found, a bug in the addon")
        -- Shouldn't reach this due to Validate at compile time
        return
    end

    LM.Debug("  * try applying")

    return handler(self.args:ReplaceVars(), context)
end

function LM.Rule:ToString()
    local out = { self.action }
    local cText = self.conditions:ToString()
    if cText and cText ~= "" then table.insert(out, cText) end
    local aText = self.args:ToString()
    if aText ~= "" then table.insert(out, aText) end
    return table.concat(out, ' ')
end

function LM.Rule:ToDisplay()
    local conditionText = self.conditions:ToDisplay()
    local actionText, argText = LM.Actions:ToDisplay(self.action, self.args)
    if argText then
        return conditionText, actionText .. "\n" .. argText
    else
        return conditionText, actionText
    end
end

-- Simple rules can be used in the user rules UI. They must have:
--   * action one of Mount/SmartMount/LimitSet/LimitInclude/LimitExclude
--   * maximum 3 ANDed conditions, no ORed conditions
--   * exactly one action argument

local SimpleActions = {
    "Mount",
    "SmartMount",
    "LimitInclude",
    "LimitExclude",
}

function LM.Rule:IsSimpleRule()
    if not tContains(SimpleActions, self.action) then
        return false
    end
    if not self.args:IsSimpleArguments() then
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
