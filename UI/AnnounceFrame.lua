--[[----------------------------------------------------------------------------

  LiteMount/UI/AnnounceFrame.lua

  An announce frame on the screen like ZoneTextFrame.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local C_Spell = LM.C_Spell or C_Spell

LiteMountAnnounceFrameMixin = {}

function LiteMountAnnounceFrameMixin:OnLoad()
    FadingFrame_OnLoad(self)
    FadingFrame_SetFadeInTime(self, 0.5)
    FadingFrame_SetHoldTime(self, 3)
    FadingFrame_SetFadeOutTime(self, 1)
    LM.MountRegistry.RegisterCallback(self, "OnMountSummoned", "OnCallback")
    self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
end

-- Announce the flight style switching (skyriding/steady)

function LiteMountAnnounceFrameMixin:OnEvent(event, ...)
    if event == 'UNIT_SPELLCAST_SUCCEEDED' then
        if LM.Options:GetOption('announceFlightStyle') then
            local unit, guid, spellID = ...
            if spellID == 460002 or spellID == 460003 then
                local name = LM.Environment:GetFlightStyle()
                self:ShowText(name)
            end
        end
    end
end

local function GetColorText(mount)
    local style =  LM.Options:GetOption('randomWeightStyle')
    if style == 'Rarity' then
        local r = mount:GetRarity()
        local c = LM.UIFilter.GetRarityColor(r)
        return c:WrapTextInColorCode(mount.name)
    elseif style == 'Priority' then
        local p = mount:GetPriority()
        local c = LM.UIFilter.GetPriorityColor(p)
        return c:WrapTextInColorCode(mount.name)
    else
        return mount.name
    end
end

function LiteMountAnnounceFrameMixin:ShowText(text, r, g, b, a)
    self.Text:SetText(text)
    if r and g and b then
        self.Text:SetTextColor(r, g, b, a)
    end
    FadingFrame_Show(self)
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
