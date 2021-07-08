--[[----------------------------------------------------------------------------

  LiteMount/UI/MountsPreviewTooltip.lua

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
    self:SetSize(200, 300)
end

--[[--------------------------------------------------------------------------]]--

function LM.ShowMountTooltip(self, m, canMount)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8)
    if m.mountID then
        GameTooltip:SetMountBySpellID(m.spellID)
    else
        GameTooltip:SetSpellByID(m.spellID)
    end

    -- GameTooltip:Show()

    GameTooltip:AddLine(" ")

    if m.mountID then
        GameTooltip:AddLine("|cffffffff"..ID..":|r "..tostring(m.mountID))
    end

    GameTooltip:AddLine("|cffffffff"..STAT_CATEGORY_SPELL..":|r "..tostring(m.spellID))

    if m.family then
        GameTooltip:AddLine("|cffffffff"..L.LM_FAMILY..":|r "..L[m.family])
    end

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

    if canMount and m:IsCastable() then
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
