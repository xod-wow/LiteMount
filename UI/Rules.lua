--[[----------------------------------------------------------------------------

  LiteMount/UI/Rules.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local TabPanels = {
    [1] = { BRAWL_TOOLTIP_RULES, "Rules" },
    [2] = { ADVANCED_LABEL, "Advanced" },
}

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[------------------------------------------------------------------------]]--

local function BindingGenerator(owner, rootDescription)
    local parent = owner:GetParent()
    local IsSelected = function (v) return parent.tab == v end
    local SetSelected = function (v) LiteMountOptionsControl_SetTab(parent, v) end
    for i = 1, 4 do
        rootDescription:CreateRadio(BindingText(i), IsSelected, SetSelected, i)
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountRulesPanelMixin = {}

function LiteMountRulesPanelMixin:GetTabPanel(i)
    i = i or self.selectedTab
    local tabPanelKey = TabPanels[i][2]
    return self[tabPanelKey]
end

function LiteMountRulesPanelMixin:SetupFromTabbing()
    self.selectedTab = self.selectedTab or 1

    for i, tabButton in ipairs(self.Tabs) do
        local tabPanel = self:GetTabPanel(i)
        if i == self.selectedTab then
            PanelTemplates_SelectTab(tabButton)
            self.currentTabPanel = tabPanel
            tabPanel:Show()
        else
            PanelTemplates_DeselectTab(tabButton)
            tabPanel:Hide()
        end
    end
end

function LiteMountRulesPanelMixin:Refresh()
    self.currentTabPanel:Refresh()
end

function LiteMountRulesPanelMixin:SetTab(i)
    self.selectedTab = i
    self:SetupFromTabbing()
    self:Refresh()
end

function LiteMountRulesPanelMixin:SetControl()
    self:Refresh()
end

function LiteMountRulesPanelMixin:GetOption(i)
    return LM.Options:GetRules(i)
end

function LiteMountRulesPanelMixin:SetOption(v, i)
    return LM.Options:SetRules(i, v)
end

function LiteMountRulesPanelMixin:SetOptionDefault()
    return nil
end

function LiteMountRulesPanelMixin:OnShow()
    self:SetupFromTabbing()
    self:Refresh()
end

function LiteMountRulesPanelMixin:OnLoad()
    self.selectedTab = 1
    self.ntabs = 4

    self:SetupFromTabbing()

    self.BindingDropDown:SetupMenu(BindingGenerator)

    for i, tabButton in ipairs(self.Tabs) do
        if i == 1 then
            tabButton:SetPoint("TOPLEFT", self.Container, "BOTTOMLEFT", 16, 0)
        else
            local prevTab = self.Tabs[i-1]
            tabButton:SetPoint("LEFT", prevTab, "RIGHT", 0, 0)
        end
        tabButton:SetText(TabPanels[i][1])
        tabButton:SetScript('OnClick', function () self:SetTab(i) end)
    end

    LiteMountOptionsPanel_RegisterControl(self, self)
end

function LiteMountRulesPanelMixin:OnHide()
    for i in ipairs(self.Tabs) do
        local tabPanel = self:GetTabPanel(i)
        tabPanel:Hide()
    end
end
