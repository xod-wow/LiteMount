--[[----------------------------------------------------------------------------

  LiteMount/AutoEventFrame.lua

  Wrappers CreateFrame with an on-event handler that looks for a function
  named for the event and calls it.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local function MethodDispatch(self, event, ...)
    if self[event] then
        self[event](self, event, ...)
    end
end

function LM.CreateAutoEventFrame(frameType, ...)
    local f = CreateFrame(frameType, ...)
    f:SetScript("OnEvent", MethodDispatch)
    return f
end
