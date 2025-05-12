--[[----------------------------------------------------------------------------

  LiteMount/UI/MountListButtonTemplate.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

local allTypeFlags = LM.Options:GetFlags()

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
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and rarity then
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

    local i = 1
    while self["Bit"..i] do
        self["Bit"..i]:SetDirtyCallback(dirtyFunc)
        i = i + 1
    end

    self.Priority:SetDirtyCallback(dirtyFunc)
end

function LiteMountMountListButtonMixin:Initialize(mount)

    LiteMountMountCommonButtonMixin.Initialize(self, mount)

    local i = 1
    while self["Bit"..i] do
        self["Bit"..i]:Update(mount, allTypeFlags[i])
        i = i + 1
    end

    self.Priority:Update(mount)
end


--[[------------------------------------------------------------------------]]--

LiteMountMountGridButtonMixin = CreateFromMixins(LiteMountMountCommonButtonMixin)

function LiteMountMountGridButtonMixin:Initialize(mount)
    local hasMenu = true
    LiteMountMountCommonButtonMixin.Initialize(self, mount, hasMenu)
    self.ModelScene:SetMount(mount)
end
