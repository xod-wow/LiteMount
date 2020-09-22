--[[----------------------------------------------------------------------------

  LiteMount/UI/MountsPreviewTooltip.lua

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--[[--------------------------------------------------------------------------]]--

LiteMountPreviewMixin = {}

function LiteMountPreviewMixin:SetMount(m)
    if m.modelID then
        self.Model:SetDisplayInfo(m.modelID)
        if m.isSelfMount then
            LiteMountPreview.Model:SetDoBlend(false)
            LiteMountPreview.Model:SetAnimation(618, -1)
        end
        self:Show()
    else
        self:Hide()
    end
end

function LiteMountPreviewMixin:OnLoad()
    self.Model:SetRotation(MODELFRAME_DEFAULT_ROTATION)
end

function LiteMountPreviewMixin:OnShow()
    self:SetSize(200, 200)
end

--[[--------------------------------------------------------------------------]]--

function LM.ShowMountTooltip(self, m)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8)
    if m.mountID then
        GameTooltip:SetMountBySpellID(m.spellID)
    else
        GameTooltip:SetSpellByID(m.spellID)
    end

    GameTooltipTextRight2:SetText(ID.." "..m.spellID)
    GameTooltipTextRight2:Show()

    if m.description then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffffffff" .. DESCRIPTION .. "|r")
        GameTooltip:AddLine(m.description, nil, nil, nil, true)
    end

    if m.sourceText then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffffffff" .. SOURCE .. "|r")
        GameTooltip:AddLine(m.sourceText, nil, nil, nil, true)
    end

    if m:IsCastable() then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffff00ff" .. HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. ": " .. MOUNT .. "|r")
    end

    GameTooltip:Show()
    LiteMountPreview:SetMount(m)
end

function LM.HideMountTooltip()
    GameTooltip:Hide()
    LiteMountPreview:Hide()
end
