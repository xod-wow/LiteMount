--[[----------------------------------------------------------------------------

  LiteMount/UI/MountTooltip.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountPreviewMixin = {}

function LiteMountPreviewMixin:SetMount(m)
    if m.sceneID and m.modelID then
        self.ModelScene:SetFromModelSceneID(m.sceneID)
        local actor = self.ModelScene:GetActorByTag("unwrapped")
        actor:SetModelByCreatureDisplayID(m.modelID)
        self:Show()
    else
        self:Hide()
    end
end

function LiteMountPreviewMixin:OnShow()
    local w = LiteMountTooltip:GetWidth()
    self:SetSize(w, w)
end

--[[--------------------------------------------------------------------------]]--

function LM.SetMountTooltip(tooltipFrame, m, canMount)
    if m.mountID then
        tooltipFrame:SetMountBySpellID(m.spellID)
    else
        tooltipFrame:SetSpellByID(m.spellID)
    end

    -- LiteMountTooltip:Show()

    tooltipFrame:AddLine(" ")

    if m.mountID then
        tooltipFrame:AddLine("|cffffffff"..ID..":|r "..tostring(m.mountID))
    end

    tooltipFrame:AddLine("|cffffffff"..STAT_CATEGORY_SPELL..":|r "..tostring(m.spellID))

    if m.family then
        tooltipFrame:AddLine("|cffffffff"..L.LM_FAMILY..":|r "..L[m.family])
    end

    if m.description then
        tooltipFrame:AddLine(" ")
        tooltipFrame:AddLine("|cffffffff" .. DESCRIPTION .. "|r")
        tooltipFrame:AddLine(m.description, nil, nil, nil, true)
    end

    if m.sourceText then
        tooltipFrame:AddLine(" ")
        tooltipFrame:AddLine("|cffffffff" .. SOURCE .. "|r")
        tooltipFrame:AddLine(m.sourceText, nil, nil, nil, true)
    end

    if canMount and m:IsCastable() then
        tooltipFrame:AddLine(" ")
        tooltipFrame:AddLine("|cffff00ff" .. HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. ": " .. MOUNT .. "|r")
    end

    tooltipFrame:Show()
    LiteMountPreview:SetMount(m)
    LiteMountPreview:ClearAllPoints()
    if tooltipFrame:GetRight() + 4 + LiteMountPreview:GetWidth() <= GetScreenWidth() then
        LiteMountPreview:SetPoint("TOPLEFT", tooltipFrame, "TOPRIGHT", 4, 0)
    elseif tooltipFrame:GetBottom() - 4 - LiteMountPreview:GetHeight() >= 0 then
        LiteMountPreview:SetPoint("TOP", tooltipFrame, "BOTTOM", 0, -4)
    elseif tooltipFrame:GetTop() + 4 + LiteMountPreview:GetHeight() < GetScreenHeight() then
        LiteMountPreview:SetPoint("BOTTOM", tooltipFrame, "TOP", 0, 4)
    end
end

function LM.HideMountTooltip()
    LiteMountTooltip:Hide()
    LiteMountPreview:Hide()
end
