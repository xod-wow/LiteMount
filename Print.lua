--[[----------------------------------------------------------------------------

  LiteMount/Print.lua

  AddMessage() into the currently displayed chat window.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local debugLines = {}
local debugLinePos = 1
local maxDebugLines = 100

function LM.Print(msg)
    local f = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
    f:AddMessage("|cff00ff00LiteMount:|r " .. msg)
end

function LM.PrintError(msg)
    LM.Print("|cffff6666" .. msg .. "|r")
end

function LM.GetDebugLines()
    local out = {}
    for i = 1, maxDebugLines do
        local offset = (debugLinePos + i - 1) % (maxDebugLines + 1)
        if debugLines[offset] then
            out[#out+1] = debugLines[offset]
        end
    end
    return out
end

function LM.Debug(msg)
    debugLines[debugLinePos] = msg
    debugLinePos = ( debugLinePos + 1 ) % (maxDebugLines + 1)

    if LM.Options:GetDebug() then
        LM.Print(msg)
    end
end

local function GetFrameNameInternal(frame)
    local name = frame:GetName()
    if name then
        if name:sub(1,9) == "LiteMount" then
            return name:sub(10)
        else
            return name
        end
    end
    local parent = frame:GetParent()
    for name,child in pairs(parent) do
        if child == frame then
            return GetFrameNameInternal(parent)..'.'..name
        end
    end
    name = tostring(frame):sub(10)
    return GetFrameNameInternal(parent)..'.'..name
end

local function GetFrameName(frame)
    if not frame.__printableName then
        frame.__printableName = GetFrameNameInternal(frame)
    end
    return frame.__printableName
end

function LM.UIDebug(frame, msg)
    if LM.Options:GetUIDebug() then
        local name = GetFrameName(frame)
        LM.Print(ORANGE_FONT_COLOR:WrapTextInColorCode(name) .. ' : ' .. msg)
    end
end

-- This prints into the UI error box the same as Blizzards code
function LM.Warning(msg)
    UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1)
end

function LM.WarningAndPrint(msg)
    LM.Warning(msg)
    LM.PrintError(msg)
end

local function pairsByKeys (t, f)
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
-- capable BUT it never truncates anything, and it doesn' put
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
