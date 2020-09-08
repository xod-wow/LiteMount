--[[----------------------------------------------------------------------------

  LiteMount/Print.lua

  AddMessage() into the currently displayed chat window.

  Copyright 2011-2020 Mike Battersby

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

function LM.TableToString(o,indent)
    indent = indent or 0
    local pad = string.rep('  ', indent)
    local pad2 = string.rep('  ', indent+1)

    if type(o) == 'table' then
        local s = '{\n'

        for k,v in pairsByKeys(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. pad2 .. '['..k..'] = ' .. LM.TableToString(v, indent+1) .. ',\n'
        end

        return s .. pad .. '}\n'
    else
        if type(o) == 'string' then
            return '"' .. tostring(o) .. '"'
        else
            return tostring(o)
        end
    end
end
