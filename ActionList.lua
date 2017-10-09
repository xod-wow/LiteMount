--[[----------------------------------------------------------------------------

  LiteMount/ActionList.lua

  A list of actions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ActionList = { }

local function ReplaceVars(line)
    local vars = {
        ['{SPECID}']    = GetSpecialization(),
        ['{SPEC}']      = select(2, GetSpecializationInfo(GetSpecialization())),
        ['{CLASSID}']   = select(3, UnitClass("PLAYER")),
        ['{CLASS}']     = select(1, UnitClass("PLAYER")),
    }

    for k,v in pairs(vars) do
        line = gsub(line, k, v)
    end

    return line
end

function LM_ActionList:ParseActionLine(line)
    line = ReplaceVars(line)
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
        if line:match('^#') == nil then
            action, filters, conditions = self:ParseActionLine(line)
            tinsert(out, { action = action, filters = filters, conditions = conditions })
        end
    end
    return out
end
