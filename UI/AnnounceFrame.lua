--[[----------------------------------------------------------------------------

  LiteMount/UI/AnnounceFrame.lua

  An announce frame on the screen like ZoneTextFrame.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LiteMountAnnounceFrameMixin = {}

function LiteMountAnnounceFrameMixin:OnLoad()
    FadingFrame_OnLoad(self)
    FadingFrame_SetFadeInTime(self, 0.5)
    FadingFrame_SetHoldTime(self, 3)
    FadingFrame_SetFadeOutTime(self, 1)
    LM.MountRegistry.RegisterCallback(self, "OnMountSummoned", "OnCallback")
end

local function GetColorText(mount)
    if LM.Options:GetOption('randomWeightStyle') == 'Rarity' then
        local r = mount:GetRarity()
        local c = LM.UIFilter.GetRarityColor(r)
        return c:WrapTextInColorCode(mount.name)
    else
        local p = mount:GetPriority()
        local c = LM.UIFilter.GetPriorityColor(p)
        return c:WrapTextInColorCode(mount.name)
    end
end

function LiteMountAnnounceFrameMixin:OnCallback(callbackName, mount)
    if LM.Options:GetOption('announceViaUI') then
        if LM.Options:GetOption('announceColors') then
            self.Text:SetText(GetColorText(mount))
        else
            self.Text:SetText(mount.name)
            self.Text:SetTextColor(1, 1, 0.25)
        end
        FadingFrame_Show(self)
    end
end
