--[[----------------------------------------------------------------------------

  LiteMount/Print.lua

  AddMessage() into the currently displayed chat window.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

local ChatWindowCache = nil

local DebugEnabled = false

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

function LM_SetDebug(onoff)
    if onoff then
        DebugEnabled = true
    else
        DebugEnabled = nil
    end
end

function LM_Debug(msg)
    if DebugEnabled then
        LM_Print(msg)
    end
end

-- This prints into the UI error box the same as Blizzards code
function LM_Warning(msg)
    UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1)
end
