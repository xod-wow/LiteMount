--[[----------------------------------------------------------------------------

  LiteMount/UI/MountFlagBitTemplate.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize


--[[------------------------------------------------------------------------]]--

LiteMountFlagBitMixin = {}

function LiteMountFlagBitMixin:SetDirtyCallback(func)
    self.callbackFunc = func
end

function LiteMountFlagBitMixin:OnClick()
    -- It seems weird that this is called first, but it's used to set the
    -- dirty flag on the panel and it needs to be right before LM.Options
    -- fires the event to refresh the display state.

    if self.callbackFunc then
        self.callbackFunc()
    end

    if self:GetChecked() then
        LM.Options:SetMountFlag(self.mount, self.flag)
    else
        LM.Options:ClearMountFlag(self.mount, self.flag)
    end
end

function LiteMountFlagBitMixin:OnEnter()
    if self.flag then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L[self.flag])
        GameTooltip:Show()
    end
end

function LiteMountFlagBitMixin:OnLeave()
    if GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end
end

function LiteMountFlagBitMixin:Update(mount, flag)
    self.mount = mount
    self.flag = flag

    local cur = mount:GetFlags()

    self:SetChecked(cur[flag] or false)

    -- If we changed this from the default then color the background
    self.Modified:SetShown(mount.flags[flag] ~= cur[flag])

    -- You can turn off any flag, but the only ones you can turn on when they
    -- were originally off are RUN for flying and dragonriding mounts and
    -- SWIM for any mount.

    if cur[flag] or mount.flags[flag] then
        self:Enable()
        self:Show()
    elseif flag == "SWIM" and not mount.flags.DRIVE then
        self:Enable()
        self:Show()
    elseif flag == "RUN" and ( mount.flags.FLY or mount.flags.DRAGONRIDING ) then
        self:Enable()
        self:Show()
    elseif flag == "FLY" and mount.flags.DRAGONRIDING then
        self:Enable()
        self:Show()
    else
        self:Hide()
        self:Disable()
    end

end
