--[[----------------------------------------------------------------------------

  LiteMount/Print.lua

  AddMessage() into the currently displayed chat window.

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

local ChatWindowCache = nil

local function GetActiveChatFrame()
    if not ChatWindowCache then
        ChatWindowCache = { }
        for i = 1,NUM_CHAT_WINDOWS do
            tinsert(ChatWindowCache, _G["ChatFrame"..i])
        end
    end

    for _,f in pairs(ChatWindowCache) do
        if f:IsShown() then return f end
    end
    return DEFAULT_CHAT_FRAME
end

function LM_Print(msg)
    GetActiveChatFrame():AddMessage("|cff00ff00LiteMount:|r " .. msg)
end

function LM_PrintError(msg)
    LM_Print("|cffff6666" .. msg .. "|r")
end

-- This should be replaced with debug types
function LM_Debug(msg)
    if LM_Options.db.char.debugEnabled == true then
        LM_Print(msg)
    end
end

function LM_UIDebug(msg)
    if LM_Options.db.char.uiDebugEnabled == true then
        LM_Print(msg)
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
