--[[----------------------------------------------------------------------------

  LiteMount/Print.lua

  AddMessage() into the currently displayed chat window.

----------------------------------------------------------------------------]]--

local ChatWindowCache = nil

local function GetActiveChatFrame()
    if not ChatWindowCache then
        ChatWindowCache = { }
        for i = 1,NUM_CHAT_WINDOWS do
            table.insert(ChatWindowCache, _G["ChatFrame"..i])
        end
    end

    for _,f in pairs(ChatWindowCache) do
        if f:IsShown() then return f end
    end
    return DEFAULT_CHAT_FRAME
end

function LM_Print(msg)
    GetActiveChatFrame():AddMessage(MessagePrefix .. msg)
end

