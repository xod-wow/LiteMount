--[[----------------------------------------------------------------------------

  LiteMount/UI/AnnounceFrame.lua

  An announce frame on the screen like ZoneTextFrame.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LiteMountAnnounceFrameMixin = {}

function LiteMountAnnounceFrameMixin:OnLoad()
    FadingFrame_OnLoad(self)
    FadingFrame_SetFadeInTime(self, 0.5)
    FadingFrame_SetHoldTime(self, 1)
    FadingFrame_SetFadeOutTime(self, 2)
    LM.MountRegistry.RegisterCallback(self, "OnMountSummoned", "OnCallback")
end

function LiteMountAnnounceFrameMixin:OnCallback(callbackName, mount)
    local _, viaUI, colors = LM.Options:GetAnnounce()
    if viaUI then
        if colors then
            local p = mount:GetPriority()
            local c = LM.UIFilter.GetPriorityColor(p)
            self.Text:SetText(c:WrapTextInColorCode(mount.name))
        else
            self.Text:SetText(mount.name)
            self.Text:SetTextColor(1, 1, 0.25)
        end
        FadingFrame_Show(self)
    end
end
