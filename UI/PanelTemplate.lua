--[[----------------------------------------------------------------------------

  LiteMount/UI/PanelTemplate.lua

  Copyright 2016 Mike Battersby

  In an ideal world most of this would be replaced with an AceDB that has a
  snapshot and restore capability.

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L


--[[------------------------------------------------------------------------]]--

-- These two control widgets are for using with Blizzards Settings

LiteMountCheckboxControlMixin = CreateFromMixins(SettingsCheckboxControlMixin)

function LiteMountCheckboxControlMixin:Init(initializer)
    SettingsCheckboxControlMixin.Init(self, initializer)

    local leftPad = self:GetIndent() + 37

    self.Checkbox:ClearAllPoints()
    self.Checkbox:SetPoint("LEFT", self, "LEFT", leftPad, 0)

    leftPad = leftPad + self.Checkbox:GetWidth() + 8
    self.Text:ClearAllPoints()
    self.Text:SetPoint("LEFT", self, "LEFT", leftPad, 0)
end

LiteMountDropdownControlMixin = CreateFromMixins(SettingsDropdownControlMixin)

function LiteMountDropdownControlMixin:Init(initializer)
    SettingsDropdownControlMixin.Init(self, initializer)

    local leftPad = self:GetIndent() + 37

    self.Text:ClearAllPoints()
    self.Text:SetPoint("TOPLEFT", self, "TOPLEFT", leftPad, -4)

    self.Control:ClearAllPoints()
    self.Control:SetPoint("BOTTOM", self, "BOTTOM", 0, 4)
    self.Control.Dropdown:SetWidth(440)
end


--[[------------------------------------------------------------------------]]--

LM_CONTAINER_BACKDROP_INFO = {
    bgFile = "Interface/ChatFrame/ChatFrameBackground",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

LM_POPOVER_BACKDROP_INFO = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

LM_LIST_ITEM_BACKDROP_INFO = {
    bgFile = "Interface/Buttons/UI-SliderBar-Background",
    edgeFile = "Interface/Buttons/UI-SliderBar-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 4,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}


----------------------------------------------------------------------------]]--

local autoLocalizedFrames = {}

-- Recurse all children finding any FontStrings and replacing their texts
-- with localized copies.
local function AutoLocalize(f)
    if not L then return end

    local regions = { f:GetRegions() }
    for _,r in ipairs(regions) do
        if r and r:IsObjectType("FontString") and not autoLocalizedFrames[r] then
            local text = r:GetText()
            if rawget(L, text) then r:SetText(L[text]) end
            autoLocalizedFrames[r] = true
        end
    end

    local children = { f:GetChildren() }
    for _,c in ipairs(children) do
        if not autoLocalizedFrames[c] then
            AutoLocalize(c)
            autoLocalizedFrames[c] = true
        end
    end
end


----------------------------------------------------------------------------]]--

LiteMountSettingsPanelMixin = {}

function LiteMountSettingsPanelMixin:MarkDirty()
    self.isDirty = true
end

function LiteMountSettingsPanelMixin:SaveSettings()
end

function LiteMountSettingsPanelMixin:LoadSettings()
end

function LiteMountSettingsPanelMixin:LoadDefaultSettings()
end

function LiteMountSettingsPanelMixin:RefreshDisplay()
    self.RevertButton:SetEnabled(self.isDirty)
end

function LiteMountSettingsPanelMixin:OnOptionsProfile()
    LM.UIDebug(self, "Panel_OnOptionsProfile")
    self:OnCommit()
    self:OnRefresh()
end

-- OnRefresh is called for all panels when the settings are opened. And called
-- again in OnShow which we want to ignore.
--
-- OnCommit is called for all panels when the settings are closed.
--
-- OnDefault is called from the Defaults button, which for non-canvas panels
-- is handled by Blizzard, but for canvas we have to make our own button.
--
-- OnRevert is entirely us, Blizzard doesn't have such an advanced concept.

function LiteMountSettingsPanelMixin:OnRefresh()
    LM.UIDebug(self, "Panel_OnRefresh")
    if self.savedSettings == nil then
        self.savedSettings = self:SaveSettings()
        self.isDirty = nil
    end
end

function LiteMountSettingsPanelMixin:OnCommit()
    LM.UIDebug(self, "Panel_OnCommit")
    self.savedSettings = nil
    self.isDirty = nil
end

function LiteMountSettingsPanelMixin:OnDefault()
    LM.UIDebug(self, "Panel_OnDefault")
    self:LoadDefaultSettings()
    self.isDirty = true
    self:RefreshDisplay()
end

function LiteMountSettingsPanelMixin:OnRevert()
    LM.UIDebug(self, "Panel_OnRevert")
    if self.isDirty then
        self.isDirty = nil
        self:LoadSettings(self.savedSettings)
        self:RefreshDisplay()
    end
end

function LiteMountSettingsPanelMixin:OnShow()
    LM.UIDebug(self, "Panel_OnShow")
    LiteMountBasePanel.CurrentOptionsPanel = self

    self:RefreshDisplay()

    LM.db.RegisterCallback(self, "OnOptionsModified", "RefreshDisplay")
    LM.db.RegisterCallback(self, "OnOptionsProfile", "OnOptionsProfile")
end

function LiteMountSettingsPanelMixin:OnHide()
    LM.UIDebug(self, "Panel_OnHide")
    LM.db.UnregisterAllCallbacks(self)
    self:RemoveAllPopOver()
end

function LiteMountSettingsPanelMixin:OnLoad()
    AutoLocalize(self)

    if self ~= LiteMountBasePanel then
        self.name = L[self.name] or self.name
        self.Title:SetText(self.name)
        local topCategory = LiteMountBasePanel.category
        self.category = Settings.RegisterCanvasLayoutSubcategory(topCategory, self, self.name)
    else
        self.name = "LiteMount"
        self.Title:SetText("LiteMount")
        self.category = Settings.RegisterCanvasLayoutCategory(self, "LiteMount")
        Settings.RegisterAddOnCategory(self.category)
    end

    self.DefaultsButton:SetScript('OnClick', function () self:OnDefault() end)
    if self.hideDefaultsButton then
        self.DefaultsButton:Hide()
    end

    self.RevertButton:SetScript('OnClick', function () self:OnRevert() end)
    if self.hideRevertButton then
        self.RevertButton:Hide()
    end
end

function LiteMountSettingsPanelMixin:SetTab(n)
    if self.tab ~= n then
        self.tab = n
        if self:IsShown() then
            self:RefreshDisplay()
        end
    end
end

function LiteMountSettingsPanelMixin:StaticPopupShow(which, text_arg1, text_arg2, data)
    self.Disable:Show()
    local hideCallback = function () self.Disable:Hide() end
    StaticPopup_Show(which, text_arg1, text_arg2, data, nil, hideCallback)
end

function LiteMountSettingsPanelMixin:UpdatePopOverDisplay()
    self.Disable:Hide()
    for i, f in ipairs(self.popOverStack) do
        if i == #self.popOverStack then
            f:SetParent(self)
            f:SetFrameLevel(self.Disable:GetFrameLevel() + 4)
            f:ClearAllPoints()
            f:SetPoint("CENTER", self, "CENTER")
            f:SetScript('OnHide', function () self:RemoveTopPopOver() end)
            f:Show()
            self.Disable:Show()
        else
            f:SetParent(nil)
            f:ClearAllPoints()
            f:SetScript('OnHide', nil)
            f:Hide()
        end
    end
end

function LiteMountSettingsPanelMixin:PopOver(f)
    self.popOverStack = self.popOverStack or {}
    f.origOnHide = f:GetScript('OnHide')
    table.insert(self.popOverStack, f)
    self:UpdatePopOverDisplay()
end

function LiteMountSettingsPanelMixin:RemoveTopPopOver()
    local f = table.remove(self.popOverStack)
    if f then
        f:SetParent(nil)
        f:ClearAllPoints()
        if f.origOnHide then f.origOnHide(f) end
        f:SetScript('OnHide', f.origOnHide)
        f.origOnHide = nil
        self:UpdatePopOverDisplay()
    end
    return f
end

function LiteMountSettingsPanelMixin:RemoveAllPopOver()
    while self.popOverStack and next(self.popOverStack) do
        self:RemoveTopPopOver()
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountPopOverPanelMixin = {}

function LiteMountPopOverPanelMixin:OnLoad()
    AutoLocalize(self)
    self.name = L[self.name] or self.name
    self.Title:SetText(self.name)
end

function LiteMountPopOverPanelMixin:OnHide()
end

function LiteMountPopOverPanelMixin:OnShow()
    self:RefreshDisplay()
end

function LiteMountPopOverPanelMixin:RefreshDisplay()
end

--[[------------------------------------------------------------------------]]--

function LM.OpenOptions()
    local f = LiteMountBasePanel
    if not f.CurrentOptionsPanel then
        f.CurrentOptionsPanel = LiteMountBasePanel
        f.CurrentOptionsPanel.category.expanded = true
    end
    SettingsPanel:Open()
    SettingsPanel:SelectCategory(f.CurrentOptionsPanel.category, true)
end

