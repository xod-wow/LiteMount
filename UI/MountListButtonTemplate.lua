--[[----------------------------------------------------------------------------

  LiteMount/UI/MountListButtonTemplate.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountMountListHeaderMixin = {}

function LiteMountMountListHeaderMixin:SetCollapsedState(isCollapsed)
    local atlas = isCollapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse"
    self.CollapseIcon:SetAtlas(atlas, true)
    self.CollapseIconAlphaAdd:SetAtlas(atlas, true)
end


--[[------------------------------------------------------------------------]]--

LiteMountMountCommonButtonMixin = {}

function LiteMountMountCommonButtonMixin:SetDirtyCallback(func)
    self.callbackFunc = func
end

function LiteMountMountCommonButtonMixin:SetDirty()
    if self.callbackFunc then
        self.callbackFunc()
    end
end

function LiteMountMountCommonButtonMixin:Initialize(mount, hasMenu)
    self.mount = mount
    self.Icon:SetMount(mount, hasMenu)
    self.Name:SetText(mount.name)
--@debug@
    self.Name:SetText(mount.name .. ' ' .. tostring(mount.mountTypeID))
--@end-debug@
    self.Types:SetText(mount:GetTypeString())

    local rarity = mount:GetRarity()
    if WOW_PROJECT_ID == 1 and rarity then
        self.Rarity:SetFormattedText(L.LM_RARITY_FORMAT, rarity)
        self.Rarity.toolTip = format(L.LM_RARITY_FORMAT_LONG, rarity)
    else
        self.Rarity:SetText('')
        self.Rarity.toolTip = nil
    end

    if not mount:IsCollected() then
        self.Name:SetFontObject("GameFontDisable")
        self.Icon:GetNormalTexture():SetVertexColor(1, 1, 1)
        self.Icon:GetNormalTexture():SetDesaturated(true)
    elseif not mount:IsUsable() then
        -- Mounts are made red if you can't use them
        self.Name:SetFontObject("GameFontNormal")
        self.Icon:GetNormalTexture():SetDesaturated(true)
        self.Icon:GetNormalTexture():SetVertexColor(0.6, 0.2, 0.2)
    else
        self.Name:SetFontObject("GameFontNormal")
        self.Icon:GetNormalTexture():SetVertexColor(1, 1, 1)
        self.Icon:GetNormalTexture():SetDesaturated(false)
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountMountListButtonMixin = CreateFromMixins(LiteMountMountCommonButtonMixin)

function LiteMountMountListButtonMixin:OnLoad()
    local dirtyFunc = function () self:SetDirty() end
    self.Priority:SetDirtyCallback(dirtyFunc)

    self.Ground:SetScript('OnClick',
        function ()
            self:SetDirty()
            local checked = self.Ground:GetChecked()
            LM.Options:SetUseOnGround(self.mount, checked)
        end)

    self.Ground:SetScript('OnEnter',
        function ()
            GameTooltip:SetOwner(self.Ground, "ANCHOR_RIGHT")
            GameTooltip:SetText(L. LM_USE_FLYING_AS_GROUND)
            GameTooltip:Show()
        end)

    self.Ground:SetScript('OnLeave', GameTooltip_Hide)

end

function LiteMountMountListButtonMixin:Initialize(mount)
    local hasMenu = true
    LiteMountMountCommonButtonMixin.Initialize(self, mount, hasMenu)

    self.Priority:Update(mount)

    if self.mount.flags.FLY then
        self.Ground:Show()
        self.Ground:SetChecked(LM.Options:GetUseOnGround(self.mount))
    else
        self.Ground:Hide()
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountMountGridButtonMixin = CreateFromMixins(LiteMountMountCommonButtonMixin)

function LiteMountMountGridButtonMixin:Initialize(mount)
    local hasMenu = true
    LiteMountMountCommonButtonMixin.Initialize(self, mount, hasMenu)
    self.ModelScene:SetMount(mount)
end
