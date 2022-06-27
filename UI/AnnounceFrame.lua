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
    LM.PlayerMounts.RegisterCallback(self, "OnMountSummoned", "OnCallback")
end

function LiteMountAnnounceFrameMixin:OnCallback(callbackName, mount)
    local _, viaUI = LM.Options:GetAnnounce()
    if viaUI then
        self.Text:SetText(mount.name)
        FadingFrame_Show(self)
    end
end
