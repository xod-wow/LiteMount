--[[----------------------------------------------------------------------------

  LiteMount/UI/MountTooltip.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local PREVIEW_SIZE_CLAMP = 250

--[[------------------------------------------------------------------------]]--

LiteMountTooltipMixin = {}

function LiteMountTooltipMixin:AttachPreview()
    local w, h = self:GetSize()
    local clampedW = min(PREVIEW_SIZE_CLAMP, w)
    local clampedH = min(PREVIEW_SIZE_CLAMP, h)

    self.Preview:ClearAllPoints()

    local maxTop = self:GetTop() + h
    local maxLeft = self:GetLeft() - w
    local maxBottom = self:GetBottom() - h
    local maxRight = self:GetRight() + w

    -- Preferred attach: RIGHT, BOTTOM, TOP, LEFT
    if maxRight <= GetScreenWidth() then
        self.Preview:SetPoint("TOPLEFT", self, "TOPRIGHT")
        self.Preview:SetSize(clampedW, h)
    elseif maxBottom >= 0 then
        self.Preview:SetPoint("TOP", self, "BOTTOM")
        self.Preview:SetSize(w, clampedH)
    elseif maxTop <= GetScreenHeight() then
        self.Preview:SetPoint("BOTTOM", self, "TOP")
        self.Preview:SetSize(w, clampedH)
    elseif maxLeft >= 0 then
        self.Preview:SetPoint("TOPRIGHT", self, "TOPLEFT")
        self.Preview:SetSize(clampedW, h)
    end

end

function LiteMountTooltipMixin:SetupPreview(m)
    if m.modelID and m.sceneID then
        -- Need width/height for ModelScene not to div/0
        self:AttachPreview()

        self.Preview.ModelScene:SetFromModelSceneID(m.sceneID)

        local mountActor = self.Preview.ModelScene:GetActorByTag("unwrapped")
        if mountActor then
            mountActor:SetModelByCreatureDisplayID(m.modelID)
            if m.isSelfMount then
                mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE)
                mountActor:SetAnimation(618)
            else
                mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_ANIM)
                mountActor:SetAnimation(0)
            end
        end
        -- I don't know why, but the playerActor affects the camera and the
        -- camera is wrong for some mounts without this. I think?
        local playerActor = self.Preview.ModelScene:GetActorByTag("player-rider")
        if playerActor then playerActor:ClearModel() end
        self.Preview:Show()
    else
        self.Preview:Hide()
    end
end

function LiteMountTooltipMixin:OnHide()
end

function LiteMountTooltipMixin:SetMount(m, canMount)
    if m.mountID then
        self:SetMountBySpellID(m.spellID)
    else
        self:SetSpellByID(m.spellID)
    end

    -- LiteMountTooltip:Show()

    self:AddLine(" ")

    if m.mountID then
        self:AddLine("|cffffffff"..ID..":|r "..tostring(m.mountID))
    end

    self:AddLine("|cffffffff"..STAT_CATEGORY_SPELL..":|r "..tostring(m.spellID))

    self:AddLine("|cffffffff"..SUMMONS..":|r "..tostring(m:GetSummonCount()))

    if m.family then
        self:AddLine("|cffffffff"..L.LM_FAMILY..":|r "..L[m.family])
    end

    local r = m:GetRarity()
    if r then
        self:AddLine("|cffffffff"..RARITY..":|r "..string.format(L.LM_RARITY_FORMAT, r))
    end

    if m.description then
        self:AddLine(" ")
        self:AddLine("|cffffffff" .. DESCRIPTION .. "|r")
        self:AddLine(m.description, nil, nil, nil, true)
    end

    if m.sourceText then
        self:AddLine(" ")
        self:AddLine("|cffffffff" .. SOURCE .. "|r")
        self:AddLine(m.sourceText, nil, nil, nil, true)
    end

    if canMount and m:IsCastable() then
        self:AddLine(" ")
        self:AddLine("|cffff00ff" .. HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. ": " .. MOUNT .. "|r")
    end

    self:Show()
    self:SetupPreview(m)
end
