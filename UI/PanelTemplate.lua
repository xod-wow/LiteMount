--[[----------------------------------------------------------------------------

  LiteMount/UI/PanelTemplate.lua

  Copyright 2016 Mike Battersby

  In an ideal world most of this would be replaced with an AceDB that has a
  snapshot and restore capability.

----------------------------------------------------------------------------]]--

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

local _, LM = ...

local L = LM.L

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

function LiteMountOptionsPanel_OnReset(self, trigger)
    LM.UIDebug(self, "Panel_OnReset t="..tostring(trigger))
    LiteMountOptionsPanel_OnCommit(self, trigger)
    LiteMountOptionsPanel_Refresh(self, trigger)
end

function LiteMountOptionsPanel_Refresh(self, trigger)
    LM.UIDebug(self, "Panel_Refresh t="..tostring(trigger))
    if self.oldValues == nil then
        self.oldValues = {}
        for i = 1, (self.ntabs or 1) do
            self.oldValues[i] = self:GetOption(i)
        end
        self.isDirty = nil
    end
    self:SetControl(self:GetOption(self.tab), self.tab)
    if not self.hideRevertButton then
        self.RevertButton:SetEnabled(self.isDirty)
    end
end

function LiteMountOptionsPanel_OnDefault(self, onlyCurrentTab)
    LM.UIDebug(self, "Panel_OnDefault")
    if not self.GetOptionDefault then return end
    self.isDirty = true

    if onlyCurrentTab then
        self:SetOption(self:GetOptionDefault(self.tab), self.tab)
    else
        for i = 1, (self.ntabs or 1) do
            self:SetOption(self:GetOptionDefault(i), i)
        end
    end
end

function LiteMountOptionsPanel_OnCommit(self)
    LM.UIDebug(self, "Panel_OnCommit")
    self.oldValues = nil
    self.isDirty = nil
end

function LiteMountOptionsPanel_Revert(self)
    LM.UIDebug(self, "Panel_Revert")
    if self.isDirty then
        self.isDirty = nil
        for i = 1, (self.ntabs or 1) do
            if self.oldValues[i] ~= nil then
                self:SetOption(self.oldValues[i], i)
                self.oldValues[i] = self:GetOption(i)
            end
        end
    end
end

function LiteMountOptionsPanel_OnShow(self)
    LM.UIDebug(self, "Panel_OnShow")
    LiteMountOptions.CurrentOptionsPanel = self

    self:Refresh()

    LM.db.RegisterCallback(self, "OnOptionsModified", "Refresh")
    LM.db.RegisterCallback(self, "OnOptionsProfile", "OnReset")
end

function LiteMountOptionsPanel_OnHide(self)
    LM.UIDebug(self, "Panel_OnHide")
    LM.db.UnregisterAllCallbacks(self)

    while self.popOverStack and next(self.popOverStack) do
        LiteMountOptionsPanel_RemoveTopPopOver(self)
    end

    -- Seems like the InterfacePanel calls all the OnCommit for
    -- anything that's been opened when the appropriate button is clicked
    -- LiteMountOptionsPanel_OnCommit(self)
end

function LiteMountOptionsPanel_OnLoad(self)
    AutoLocalize(self)

    if self ~= LiteMountOptions then
        self.name = L[self.name] or self.name
        self.Title:SetText(self.name)
        local topCategory = LiteMountOptions.category
        self.category = Settings.RegisterCanvasLayoutSubcategory(topCategory, self, self.name)
    else
        self.name = "LiteMount"
        self.Title:SetText("LiteMount")
        self.category = Settings.RegisterCanvasLayoutCategory(self, "LiteMount")
        Settings.RegisterAddOnCategory(self.category)
    end

    if self.hideDefaultsButton then
        self.DefaultsButton:Hide()
    end

    if self.hideRevertButton then
        self.RevertButton:Hide()
    end

    self.tab = 1

    self.OnCommit = LiteMountOptionsPanel_OnCommit
    self.OnReset = LiteMountOptionsPanel_OnReset

    self.OnDefault = self.OnDefault or LiteMountOptionsPanel_OnDefault
    self.Refresh = self.Refresh or LiteMountOptionsPanel_Refresh

    self.SetControl = self.SetControl or function () end
    self.GetOption = self.GetOption or function () end
end

function LiteMountOptionsPanel_SetTab(self, n)
    self.tab = n
    self:SetControl(self:GetOption(n))
end

function LiteMountOptionsPanel_UpdatePopOverDisplay(self)
    self.Disable:Hide()
    for i, f in ipairs(self.popOverStack) do
        if i == #self.popOverStack then
            f:SetParent(self)
            f:SetFrameLevel(self.Disable:GetFrameLevel() + 4)
            f:ClearAllPoints()
            f:SetPoint("CENTER", self, "CENTER")
            f:SetScript('OnHide', function () LiteMountOptionsPanel_RemoveTopPopOver(self) end)
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

function LiteMountOptionsPanel_PopOver(f, self)
    self.popOverStack = self.popOverStack or {}
    f.origOnHide = f:GetScript('OnHide')
    table.insert(self.popOverStack, f)
    LiteMountOptionsPanel_UpdatePopOverDisplay(self)
end

function LiteMountOptionsPanel_RemoveTopPopOver(self)
    local f = table.remove(self.popOverStack)
    if f then
        f:SetParent(nil)
        f:ClearAllPoints()
        if f.origOnHide then f.origOnHide(f) end
        f:SetScript('OnHide', f.origOnHide)
        f.origOnHide = nil
        LiteMountOptionsPanel_UpdatePopOverDisplay(self)
    end
    return f
end

function LiteMountPopOverPanel_OnLoad(self)
    AutoLocalize(self)
    self.name = L[self.name] or self.name
    self.Title:SetText(self.name)
end

function LM.OpenOptions()
    local f = LiteMountOptions
    if not f.CurrentOptionsPanel then
        f.CurrentOptionsPanel = LiteMountOptions
        f.CurrentOptionsPanel.category.expanded = true
    end
    SettingsPanel:Open()
    SettingsPanel:SelectCategory(f.CurrentOptionsPanel.category, true)
end

