--[[----------------------------------------------------------------------------

  LiteMount/Rules.lua

  An action rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

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

function LM.Rules:ExpandOneCondition(ruleCondition)
    local condition, conditionArg = string.split(':', ruleCondition, 2)

    if condition == "map" then
        if conditionArg then
            local info = C_Map.GetMapInfo(tonumber(conditionArg))
            return string.format("%s: %s (%s)", WORLD_MAP, info.name, conditionArg)
        end
    elseif condition == "instance" then
        local n = LM.Options:GetInstanceNameByID(tonumber(conditionArg))
        if n then
            return string.format("%s: %s (%s)", INSTANCE, n, conditionArg)
        end
    elseif condition == "location" then
        if conditionArg then
            return string.format("%s %s", LOCATION_COLON, conditionArg)
        end
    elseif condition == "submerged" then
        return TUTORIAL_TITLE28
    elseif condition == "mod" then
        if conditionArg == "alt" then
            return ALT_KEY
        elseif conditionArg == "ctrl" then
            return CTRL_KEY
        elseif conditionArg == "shift" then
            return SHIFT_KEY
        end
    elseif condition == "flyable" then
        return "Flyable area"
    end

    return ORANGE_FONT_COLOR_CODE .. ruleCondition .. FONT_COLOR_CODE_CLOSE
end

function LM.Rules:ExpandConditions(rule)
    local conditions = {}
    for _, ruleCondition in ipairs(rule.conditions) do
        if type(ruleCondition) == 'table' then
            table.insert(conditions, RED_FONT_COLOR_CODE .. 'NOT ' .. self:ExpandOneCondition(ruleCondition[1]) .. FONT_COLOR_CODE_CLOSE)
        else
            table.insert(conditions, self:ExpandOneCondition(ruleCondition))
        end
    end
    return table.concat(conditions, "\n")
end

local function ExpandMountFilter(actionArg)
    if not actionArg then return end
    if actionArg:match('id:%d+') then
        local _, id = string.split(':', actionArg)
        actionArg = C_MountJournal.GetMountInfoByID(tonumber(id))
    elseif actionArg:match('family:') then
        local _, family = string.split(':', actionArg)
        return L.LM_FAMILY .. ': ' .. L[family]
    elseif actionArg:match('mt:230') then
        return "Type: Ground"
    elseif actionArg:match('mt:231') then
        return "Type: Turtle"
    elseif actionArg:match('mt:232') then
        return "Type: Vashj'ir"
    elseif actionArg:match('mt:241') then
        return "Type: Ahn'qiraj"
    elseif actionArg:match('mt:248') then
        return "Type: Flying"
    elseif actionArg:match('mt:254') then
        return "Type: Swimming"
    elseif actionArg:match('mt:284') then
        return "Type: Chauffeur"
    elseif actionArg:match('mt:398') then
        return "Type: Kua'fon"
    elseif LM.Options:IsActiveFlag(actionArg) then
        return GROUP .. ': ' .. actionArg
    end
    return actionArg
end

local function ExpandAction(rule)
    local action = rule.action
    local actionArg = table.concat(rule.args, ' ')
    if tContains({ 'Mount', 'SmartMount' }, action) then
        if actionArg then
            return action .. "\n" .. ExpandMountFilter(actionArg)
        end
    elseif action == "Limit" then
        if actionArg:sub(1,1) == '-' then
            return "Exclude\n" .. ExpandMountFilter(actionArg:sub(2))
        elseif actionArg:sub(1,1) == '+' then
            return "Include\n" .. ExpandMountFilter(actionArg:sub(2))
        else
            return "Limit\n" .. ExpandMountFilter(actionArg)
        end
    end
    return action .. ' ' .. actionArg
end

function LM.Rules:UserRuleText(rule)
    return self:ExpandConditions(rule), ExpandAction(rule)
end
