--[[----------------------------------------------------------------------------

  LiteMount/TableUtil.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

function LM.tMap(t, f)
    local out = {}
    for k, v in pairs(t) do
        out[k] = f(v)
    end
    return out
end

function LM.tSlice(t, from, to)
    return { unpack(t, from, to) }
end

function LM.PairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil else return a[i], t[a[i]] end
    end
    return iter
end

-- This dumper is adapted from DevTools_Dump and is a lot less
-- capable BUT it never truncates anything, and it doesn't put
-- color codes into the output.

local function prepSimple(val)
    local valType = type(val)
    if valType == 'nil'  then
        return 'nil'
    elseif valType == 'number' then
        return val
    elseif valType == 'boolean' then
        if val then
            return 'true'
        else
            return 'false'
        end
    elseif valType == 'string' then
        return string.format('%q', val)
    end
end

local function prepSimpleKey(val)
    if (string.match(val, "^[a-zA-Z_][a-zA-Z0-9_]*$")) then
        return val
    else
        return '[' .. prepSimple(val) .. ']'
    end
end

local DumpValue

local function DumpTableContents(val, prefix, firstPrefix, context)
    local oldDepth = context.depth
    local oldKey = context.key

    local iter = pairsByKeys(val)
    local nextK, nextV = iter(val, nil)

    while nextK do
        local k, v = nextK, nextV
        nextK, nextV = iter(val, k)

        local prepKey = prepSimpleKey(k)
        if oldKey == nil then
            context.key = prepKey
        elseif prepKey:sub(1,1) == '[' then
            context.key = oldKey .. prepKey
        else
            context.key = oldKey .. '.' .. prepKey
        end
        context.depth = oldDepth + 1
        local rp = string.format('%s%s = ', firstPrefix, prepKey)
        firstPrefix = prefix
        DumpValue(v, prefix, rp, (nextK and ',') or '', context)
    end

    context.key = oldKey
    context.depth = oldDepth
end

function DumpValue(val, prefix, firstPrefix, suffix, context)
    local valType = type(val)

    if valType ~= 'table' then
        table.insert(context.lines, string.format('%s%s%s', firstPrefix, prepSimple(val), suffix))
        return
    else
        firstPrefix = firstPrefix .. '{'
        local oldPrefix = prefix
        prefix = prefix .. '    '

        table.insert(context.lines, firstPrefix)
        firstPrefix = prefix
        DumpTableContents(val, prefix, firstPrefix, context)
        table.insert(context.lines, oldPrefix .. '}' .. suffix)
    end
end

function LM.TableToString(val)
    local context = { depth = 0, key = startKey, lines = {} }
    DumpTableContents(val, '', '', context)
    return table.concat(context.lines, '\n') .. '\n'
end