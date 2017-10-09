--[[----------------------------------------------------------------------------

  LiteMount/ActionList.lua

  A list of actions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ActionList = { }

local function ReplaceDollarVars(line)
    local vars = {
        ['$s'] = GetSpecialization(),
        ['$S'] = select(2, GetSpecializationInfo(GetSpecialization())),
        ['$c'] = select(3, UnitClass("PLAYER")),
        ['$C'] = select(1, UnitClass("PLAYER")),
    }

    for k,v in pairs(vars) do
        line = gsub(line, k, v)
    end

    return line
end

function LM_ActionList:ParseActionLine(line)
    line = ReplaceDollarVars(line)
    local action = strmatch(line, "%S+")
    local filters, conditions = {}, {}
    gsub(line, '%[filter=(.-)%]',
            function (v)
                for f in gmatch(v, '[^, ]+') do tinsert(filters, f) end
            end)
    gsub(line, '%[[^=]-%]', function (v) tinsert(conditions, v) end)

    if #conditions == 0 then
        table.insert(conditions, '[]')
    end

    return action, filters, table.concat(conditions, '')
end

function LM_ActionList:Compile(text)
    local out = { }
    local action, filters, conditions
    for line in text:gmatch("([^\r\n]+)") do
        action, filters, conditions = self:ParseActionLine(line)
        tinsert(out, { action = action, filters = filters, conditions = conditions })
    end
    return out
end
