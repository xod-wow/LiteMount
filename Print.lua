--[[----------------------------------------------------------------------------

  LiteMount/Print.lua

  AddMessage() into the currently displayed chat window.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local debugLines = {}
local debugLinePos = 1
local maxDebugLines = 100

local format = format

function LM.Print(...)
    local msg = format(...)
    local f = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
    f:AddMessage("|cff00ff00LiteMount:|r " .. msg)
end

function LM.PrintError(...)
    local msg = format(...)
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

function LM.Debug(...)
    local msg = format(...)

    debugLines[debugLinePos] = msg
    debugLinePos = ( debugLinePos + 1 ) % (maxDebugLines + 1)

    if LM.Options:GetOption('debugEnabled') then
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
    for childName, child in pairs(parent) do
        if child == frame then
            return GetFrameNameInternal(parent)..'.'..childName
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

function LM.UIDebug(frame, ...)
    local msg = format(...)
    if LM.Options:GetOption('uiDebugEnabled') then
        local name = GetFrameName(frame)
        LM.Print(ORANGE_FONT_COLOR:WrapTextInColorCode(name) .. ' : ' .. msg)
    end
end

-- This prints into the UI error box the same as Blizzards code. The weirdness
-- here is to force it through the OnEvent handler so things like LeatrixPlus
-- that try to suppress error messages can. Could also be "UI_INFO_MESSAGE"
-- which is yellow color. LE_GAME_ERR_SPELL_FAILED_S is the error number (57)
-- that the server sends for can't mount.

function LM.Warning(msg)
    local method = UIErrorsFrame:GetScript('OnEvent')
    if method then
        method(UIErrorsFrame, "UI_ERROR_MESSAGE", LE_GAME_ERR_SPELL_FAILED_S, msg)
    end
end

function LM.WarningAndPrint(...)
    LM.Warning(...)
    LM.PrintError(...)
end
