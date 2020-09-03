mockChatFrame = setmetatable({}, mockFrame)
mockChatFrame.__index = mockChatFrame

local function stripColor(msg)
    local msg = msg:gsub("|c........(.-)|r", "%1")
    return msg
end

function mockChatFrame:AddMessage(msg)
    print(stripColor(msg))
end

DEFAULT_CHAT_FRAME = mockChatFrame:New()

SELECTED_CHAT_FRAME = DEFAULT_CHAT_FRAME
