--[[----------------------------------------------------------------------------

  LiteMount/UI/MountTooltip.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize


--[[------------------------------------------------------------------------]]--

LiteMountTooltipPreviewMixin = {}

function LiteMountTooltipPreviewMixin:SetAsMount(mount, parent)
    if mount.creatureDisplayID and mount.modelSceneID then
        self:SetParent(parent)
        self:Attach(parent)
        self.ModelScene:SetMount(mount)
        self:Show()
    else
        self:SetParent(nil)
        self:ClearAllPoints()
        self:Hide()
    end
end

function LiteMountTooltipPreviewMixin:Attach(parent)
    local w, h = parent:GetSize()

    local maxTop = parent:GetTop() + h
    local maxLeft = parent:GetLeft() - w
    local maxBottom = parent:GetBottom() - h
    local maxRight = parent:GetRight() + w

    self:ClearAllPoints()

    -- Preferred attach: RIGHT, BOTTOM, TOP, LEFT
    if maxRight <= GetScreenWidth() then
        self:SetPoint("TOPLEFT", parent, "TOPRIGHT")
    elseif maxBottom >= 0 then
        self:SetPoint("TOP", parent, "BOTTOM")
    elseif maxTop <= GetScreenHeight() then
        self:SetPoint("BOTTOM", parent, "TOP")
    elseif maxLeft >= 0 then
        self:SetPoint("TOPRIGHT", parent, "TOPLEFT")
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountTooltipMixin = {}

function LiteMountTooltipMixin:SetMount(m, hasMenu)
    if m.mountID then
        self:SetMountBySpellID(m.spellID)
    else
        self:SetSpellByID(m.spellID)
    end

    self:AddLine(" ")

    if m.mountID then
        self:AddLine("|cffffffff"..ID..":|r "..tostring(m.mountID))
    end

    self:AddLine("|cffffffff"..STAT_CATEGORY_SPELL..":|r "..tostring(m.spellID))

    self:AddLine("|cffffffff"..SUMMONS..":|r "..tostring(m:GetSummonCount()))

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if m.family then
            self:AddLine("|cffffffff"..L.LM_FAMILY..":|r "..L[m.family])
        end

        local r = m:GetRarity()
        if r then
            self:AddLine("|cffffffff"..RARITY..":|r "..string.format(L.LM_RARITY_FORMAT, r))
        end
    end

    if m.descriptionText and m.descriptionText ~= "" then
        self:AddLine(" ")
        self:AddLine("|cffffffff" .. DESCRIPTION .. "|r")
        self:AddLine(m.descriptionText, nil, nil, nil, true)
    end

    if m.sourceText and m.sourceText ~= "" then
        self:AddLine(" ")
        self:AddLine("|cffffffff" .. SOURCE .. "|r")
        self:AddLine(m.sourceText, nil, nil, nil, true)
    end

    if hasMenu or m:IsCastable() then
        self:AddLine(" ")
    end

    if m:IsCastable() then
        self:AddLine("|cffff00ff" .. L.LM_LEFT_CLICK .. ": " .. MOUNT .. "|r")
    end

    if hasMenu then
        self:AddLine("|cffff00ff" .. L.LM_RIGHT_CLICK .. ": " .. CLICK_BINDING_OPEN_MENU .. "|r")
    end

    self:Show()
    LiteMountTooltipPreview:SetAsMount(m, self)
end
