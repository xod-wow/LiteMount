--[[----------------------------------------------------------------------------

  LiteMount/Rule.lua

  An action rule.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

LM.Rule = { }

local function ReadWord(line)
    local token, rest

    -- Skip whitespace
    token, rest = line:match('^(%s+)(.*)$')
    if token then return nil, rest end

    -- Skip from # to end of line
    token, rest = line:match('^#')
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

function LM.Rule:Get()
    return CreateFromMixins(LM.Rule)
end

function LM.Rule:ParseLine(line)

    local r = LM.Rule:Get()

    r.line = line

    local argTokens, condWords, rest = { }, { }, nil

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

    -- args is not neat. Mount arguments are an expression where , is AND but
    -- other kinds of arguments are just a comma-separated list. We need to
    -- lex x/y here so we can handle the quoting, but we don't want to try to
    -- parse it. So to be lazy I just shove the '/' into the arg list and
    -- make the handlers deal with it however they want. Note that it is
    -- almost certainly going to give weird behaviour using / with the Limit
    -- actions because the first character can be an operator and something
    -- like
    --      Limit -RUN/FLY
    -- is going to parse as
    --      LIMIT ( -RUN or FLY )
    -- but humans would intuitively expect it to be
    --      LIMIT -( RUN or FLY )

    r.args = LM.RuleArguments:Get(argTokens)

    local ok, err = r:Validate()

    return ok and r or nil, err
end

function LM.Rule:Validate()
    local fcHandler = LM.Actions:GetFlowControlHandler(self.action)
    local handler = LM.Actions:GetHandler(self.action)

    if not ( fcHandler or handler ) then
        return false, format(L.LM_ERR_BAD_ACTION, self.action)
    end

    local ok, err = self.conditions:Validate()
    if not ok then
        return false, err
    end

    local argType = LM.Actions:GetArgType(self.action)

    if not self.args:Validate(argType) then
        return false, format(L.LM_ERR_BAD_ARGUMENTS, self.args:ToString())
    end

    return true
end

function LM.Rule:Dispatch(context)

    local isTrue = self.conditions:Eval(context)

    local handler = LM.Actions:GetFlowControlHandler(self.action)
    if handler then
        LM.Debug("  Dispatching flow control action " .. (self.line or self:ToString()))
        handler(self.args, context, isTrue)
        return
    end

    if not isTrue or LM.Actions:IsFlowSkipped(context) then
        return
    end

    handler = LM.Actions:GetHandler(self.action)
    if not handler then
        -- Shouldn't reach this due to Validate at compile time
        LM.WarningAndPrint(L.LM_ERR_BAD_ACTION, self.action)
        return
    end

    LM.Debug("  Dispatching rule " .. (self.line or self:ToString()))

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
