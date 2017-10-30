--[[----------------------------------------------------------------------------

  LiteMount/ActionList.lua

  A list of actions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_ActionList = { }

function LM_ActionList:ParseActionLine(line)
    local action = strmatch(line, '%S+')
    local filters, conditions = { }, { op = 'OR' }
    for filterStr in line:gmatch('%[filter=(.-)%]') do
        for f in filterStr:gmatch('[^,]+') do
            f = f:gsub('{.-}', function (k) return LM_Vars:GetConst(k) end)
            tinsert(filters, f)
        end
    end

    for conditionStr in line:gmatch('%[([^=]-)%]') do
        local clause = { }
        for c in conditionStr:gmatch('[^,]+') do
            local vars = false
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
            tinsert(conditions, clause)
        end
    end

    return action, filters, conditions
end

function LM_ActionList:Compile(text)
    local out = { }
    local action, filters, conditions
    for line in text:gmatch('([^\r\n]+)') do
        line = line:gsub('%s*#.*', '')
        if line ~= '' then
            action, filters, conditions = self:ParseActionLine(line)
            tinsert(out, { action = action, filters = filters, conditions = conditions })
        end
    end

    return out
end
