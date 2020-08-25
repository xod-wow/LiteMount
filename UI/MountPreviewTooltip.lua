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
