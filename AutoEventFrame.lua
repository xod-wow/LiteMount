--[[----------------------------------------------------------------------------

  LiteMount/AutoEventFrame.lua

  Wrappers CreateFrame with an on-event handler that looks for a function
  named for the event and calls it.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

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
