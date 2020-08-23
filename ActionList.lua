--[[----------------------------------------------------------------------------

  LiteMount/ActionList.lua

  A list of actions.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.ActionList = { }

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

function LM.ActionList:ParseActionLine(line)
    local argWords, condWords = { }, { }
    local action

    -- Note this is intentionally unanchored to skip leading whitespace
    action, line = line:match('(%S+)%s*(.*)')

    while line ~= nil do
        local word
        word, line = ReadWord(line)
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

    local conditions

    for _, word in ipairs(condWords) do
        local clause, vars = {}, false
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

    return action, args, conditions
end

function LM.ActionList:Compile(text)
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
