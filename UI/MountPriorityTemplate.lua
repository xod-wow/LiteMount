--[[----------------------------------------------------------------------------

  LiteMount/UI/MountIconTemplate.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize


--[[------------------------------------------------------------------------]]--

LiteMountPriorityMixin = {}

function LiteMountPriorityMixin:SetDirtyCallback(func)
    self.callbackFunc = func
end

function LiteMountPriorityMixin:Update(mount)
    self.mount = mount

    local value = self:Get()
    if value then
        self.Minus:SetShown(value > LM.Options.MIN_PRIORITY)
        self.Plus:SetShown(value < LM.Options.MAX_PRIORITY)
        self.Priority:SetText(value)
    else
        self.Minus:Show()
        self.Plus:Show()
        self.Priority:SetText('')
    end
    if LM.Options:GetOption('randomWeightStyle') == 'Priority' or value == 0 then
        local r, g, b = LM.UIFilter.GetPriorityColor(value):GetRGB()
        self.Background:SetColorTexture(r, g, b, 0.33)
    else
        local r, g, b = LM.UIFilter.GetPriorityColor(''):GetRGB()
        self.Background:SetColorTexture(r, g, b, 0.33)
    end
end

function LiteMountPriorityMixin:Get()
    if self.mount then
        return self.mount:GetPriority()
    end
end

function LiteMountPriorityMixin:Set(v)
    if not self.mount then return end

    -- It seems weird that this is called first, but it's used to set the
    -- dirty flag on the panel and it needs to be right before LM.Options
    -- fires the event to refresh the display state.
    if self.callbackFunc then
        self.callbackFunc()
    end

    LM.Options:SetPriority(self.mount, v or LM.Options.DEFAULT_PRIORITY)
end

function LiteMountPriorityMixin:Increment()
    local v = self:Get()
    if v then
        self:Set(v + 1)
    else
        self:Set(LM.Options.DEFAULT_PRIORITY)
    end
end

function LiteMountPriorityMixin:Decrement()
    local v = self:Get() or LM.Options.DEFAULT_PRIORITY
    self:Set(v - 1)
end

function LiteMountPriorityMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(L.LM_PRIORITY)

    if LM.Options:GetOption('randomWeightStyle') ~= 'Priority' then
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(L.LM_RARITY_DISABLES_PRIORITY, 1, 1, 1, true)
        GameTooltip:AddLine(' ')
    end

    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        local t, d = LM.UIFilter.GetPriorityText(p)
        GameTooltip:AddLine(t .. ' - ' .. d)
    end
    GameTooltip:Show()
end

function LiteMountPriorityMixin:OnLeave()
    GameTooltip:Hide()
end
