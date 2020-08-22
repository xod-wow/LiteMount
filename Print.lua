--[[----------------------------------------------------------------------------

  LiteMount/Print.lua

  AddMessage() into the currently displayed chat window.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_Print(msg)
    local f = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
    f:AddMessage("|cff00ff00LiteMount:|r " .. msg)
end

function LM_PrintError(msg)
    LM_Print("|cffff6666" .. msg .. "|r")
end

-- This should be replaced with debug types
function LM_Debug(msg)
    if LM_Options:GetDebug() then
        LM_Print(msg)
    end
end

local function GetFrameNameInternal(frame)
    local name = frame:GetName()
    if name then
        return name
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

function LM_UIDebug(frame, msg)
    if LM_Options:GetUIDebug() then
        local name = GetFrameName(frame)
        LM_Print(ORANGE_FONT_COLOR:WrapTextInColorCode(name) .. ' : ' .. msg)
    end
end

-- This prints into the UI error box the same as Blizzards code
function LM_Warning(msg)
    UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1)
end

function LM_WarningAndPrint(msg)
    LM_Warning(msg)
    LM_PrintError(msg)
end
