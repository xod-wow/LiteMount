--[[----------------------------------------------------------------------------

  LiteMount/ActionList.lua

  A list of actions.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_ActionList = { }

local function replaceConstant(k) return LM_Vars:GetConst(k) end

local function ReadToken(line)
    local token, rest

    -- Skip whitespace
    token, rest = line:match('^(%s+)(.*)$')
    if token then return nil, rest end

    -- Match ""
    token, rest = line:match('^"([^"]*)"(.*)$')
    if token then return nil, rest end

    -- Match ''
    token, rest = line:match("^'([^']*)'(.*)$")
    if token then return nil, rest end

    -- Match [] empty condition, which is just skipped
    token, rest = line:match('^(%[%])(.*)$')
    if token then return nil, rest end

    -- Match regular conditions
    token, rest = line:match('^(%[.-%])(.*)$')
    if token then return token, rest end

    -- Match words
    token, rest = line:match('^(%S+)(.*)$')
    if token then return token, rest end
end

function LM_ActionList:ParseActionLine(line)
    local argTokens, condTokens = { }, { }
    local token

    while line ~= nil do
        token, line = ReadToken(line)
        if token then
            if token:match('^%[filter=.+%]$') then
                tinsert(argTokens, token:sub(9, -2))
            elseif token:match('^%[.-%]$') then
                for c in token:gmatch('%[(.-)%]') do
                    tinsert(condTokens, c)
                end
            else
                tinsert(argTokens, token)
            end
        end
    end

    local conditions

    for _, token in ipairs(condTokens) do
        local clause, vars = {}, false
        for c in token:gmatch('[^,]+') do
            c = c:gsub('{.-}', function (k)
                    local v = LM_Vars:GetConst(k)
                    if v then
                        return v
                    else
                        vars = true
                    end
                 end)
            if c:sub(1,2) == 'no' then
                tinsert(clause, { op = 'NOT', [1] = { c:sub(3), vars=vars } })
            else
                tinsert(clause, { c, vars=vars })
            end
        end
        if #clause > 0 then
            clause.op = 'AND'
            conditions = conditions or { op = 'OR' }
            tinsert(conditions, clause)
        end
    end

    local action, args = nil, { }

    for _, token in ipairs(argTokens) do
        if not action then
            action = token
        else
            token = token:gsub('{.-}', replaceConstant)
            tinsert(args, token)
        end
    end

    return action, args, conditions
end

function LM_ActionList:Compile(text)
    local out = { }
    local action, args, conditions
    for line in text:gmatch('([^\r\n]+)') do
        line = line:gsub('%s*#.*', '')
        if line ~= '' then
            action, args, conditions = self:ParseActionLine(line)
            tinsert(out, { action = action, args = args, conditions = conditions })
        end
    end

    return out
end
