--[[----------------------------------------------------------------------------

  LiteMount/Rules.lua

  An action rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

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

function LM.Rules:ParseActionLine(line)
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
            tinsert(out, self:ParseActionLine(line))
        end
    end

    return out
end
