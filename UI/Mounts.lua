--[[----------------------------------------------------------------------------

  LiteMount/UI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.L

local TabNames = {
    [1] = L.LM_LIST_VIEW,
    [2] = L.LM_MODEL_VIEW,
}


--[[------------------------------------------------------------------------]]--

LiteMountMountsPanelMixin = {}

function LiteMountMountsPanelMixin:SaveSettings()
    local profileGroups, globalGroups = LM.Options:GetRawGroups()
    return {
        CopyTable(LM.Options:GetRawFlagChanges(), true),
        CopyTable(LM.Options:GetRawMountPriorities()),
        CopyTable(profileGroups),
        CopyTable(globalGroups),
    }
end

function LiteMountMountsPanelMixin:LoadSettings(v)
    local dontFire = true
    LM.Options:SetRawFlagChanges(v[1], dontFire)
    LM.Options:SetRawMountPriorities(v[2], dontFire)
    LM.Options:SetRawGroups(v[3], v[4], dontFire)
end

function LiteMountMountsPanelMixin:LoadDefaultSettings()
    local dontFire = true
    LM.Options:ResetAllMountFlags(true)
    LM.Options:SetPriorityList(LM.MountRegistry.mounts, nil, dontFire)
end

function LiteMountMountsPanelMixin:RefreshDisplay()
    for i, tabButton in ipairs(self.Tabs) do
        if i == self.selectedTab then
            PanelTemplates_SelectTab(tabButton)
        else
            PanelTemplates_DeselectTab(tabButton)
        end
    end

    local view = self.tabViews[self.selectedTab]
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

    self.PriorityLabel:SetShown(self.selectedTab==1)

    for i = 1, 4 do
        local label = self["BitLabel"..i]
        label:SetShown(self.selectedTab==1)
    end

    LM.MountRegistry:RefreshMounts(true)

    -- Update the counts, Journal-only
    local counts = LM.MountRegistry:GetJournalTotals()
    self.Counts:SetText(
            string.format(
                '%s: %s %s: %s %s: %s',
                TOTAL,
                WHITE_FONT_COLOR:WrapTextInColorCode(counts.total),
                COLLECTED,
                WHITE_FONT_COLOR:WrapTextInColorCode(counts.collected),
                L.LM_USABLE,
                WHITE_FONT_COLOR:WrapTextInColorCode(counts.usable)
            )
        )

    -- Hopefully with InsecureActionButtonTemplate it's ok to refresh in combat
    local currentView = self.ScrollBox:GetView()
    local wantTree = ( currentView.stride == nil )
    local dp = LM.UIFilter.GetFilteredMountDataProvider(wantTree)
    self.ScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)

    LiteMountSettingsPanelMixin.RefreshDisplay(self)
end

function LiteMountMountsPanelMixin:SetTab(n)
    if self.selectedTab ~= n then
        self.selectedTab = n
        if self:IsShown() then
            self:RefreshDisplay()
        end
    end
end

local function ActionMenuGenerate(owner, rootDescription)
    local parent = owner:GetParent()

    rootDescription:CreateTitle(L.LM_ACTION_MENU_TITLE)

    local allGroups = LM.Options:GetGroupNames()

    local groupMenu = rootDescription:CreateButton(L.LM_GROUPS)
    for _, g in pairs(allGroups) do
        local function Add()
            parent:MarkDirty()
            local mounts = LM.UIFilter.GetFilteredMountList()
            LM.Options:SetMountGroupList(mounts, g)
        end
        local function Clear()
            parent:MarkDirty()
            local mounts = LM.UIFilter.GetFilteredMountList()
            LM.Options:ClearMountGroupList(mounts, g)
        end
        if LM.Options:IsGlobalGroup(g) then
            g = BLUE_FONT_COLOR:WrapTextInColorCode(g)
        end
        local thisGroupMenu = groupMenu:CreateButton(g)
        thisGroupMenu:CreateButton(ADD, Add)
        thisGroupMenu:CreateButton(REMOVE, Clear)
    end

    local priorityMenu = rootDescription:CreateButton(L.LM_PRIORITY)
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        local t, d = LM.UIFilter.GetPriorityText(p)
        local function Set()
            parent:MarkDirty()
            local mounts = LM.UIFilter.GetFilteredMountList()
            LM.Options:SetPriorityList(mounts, p)
        end
        priorityMenu:CreateButton(t..' - '..d, Set)
    end
end

function LiteMountMountsPanelMixin:OnLoad()
    self.tabViews = {}

    local function dirtyFunc() self:MarkDirty() end

    self.tabViews[1] = CreateScrollBoxListTreeListView()
    self.tabViews[1]:SetElementFactory(
        function (factory, node)
            local data = node:GetData()
            if data.isHeader then
                factory("LiteMountMountListHeaderTemplate",
                    function (button)
                        button.Name:SetText(data.name .. ' (' .. #node:GetNodes() .. ')')
                        button:SetCollapsedState(node:IsCollapsed())
                        button:SetScript("OnClick",
                            function ()
                                node:ToggleCollapsed()
                                button:SetCollapsedState(node:IsCollapsed())
                            end)
                    end)
            else
                factory("LiteMountMountListButtonTemplate",
                    function (button)
                        button:Initialize(data, self.allFlags)
                        button:SetDirtyCallback(dirtyFunc)
                    end)
            end
        end)
    self.tabViews[1]:SetElementExtentCalculator(
        function (dataIndex, node)
            if node:GetData().isHeader then
                return 22
            else
                return 44
            end
        end)
    self.tabViews[1]:SetElementIndentCalculator(
        function (node)
            if LM.UIFilter.GetSortKey() ~= 'family' or node:GetData().isHeader then
                return 0
            else
                return 8
            end
        end)

    -- CreateScrollBoxListGridView(stride, top, bottom, left, right, horizontalSpacing, verticalSpacing)
    local stride = 3
    self.tabViews[2] = CreateScrollBoxListGridView(stride, 0, 0, 0, 0, 5, 5)
    self.tabViews[2]:SetElementInitializer("LiteMountMountGridButtonTemplate",
        function (button, elementData)
            button:Initialize(elementData, self.allFlags)
            button:SetDirtyCallback(dirtyFunc)
        end)

    self.name = MOUNTS

    self.allFlags = LM.Options:GetFlags()

    for i = 1, 4 do
        local label = self["BitLabel"..i]
        if self.allFlags[i] then
            label:SetText(L[self.allFlags[i]])
        end
    end

    -- MOUNT_JOURNAL_USABILITY_CHANGED
    self:SetScript('OnEvent', self.RefreshDisplay)

    -- Set up the tabs
    if WOW_PROJECT_ID == 1 then
        for i, tabButton in ipairs(self.Tabs) do
            if i == 1 then
                tabButton:SetPoint("TOPLEFT", self.MountsContainer, "BOTTOMLEFT", 16, 0)
            else
                local prevTab = self.Tabs[i-1]
                tabButton:SetPoint("LEFT", prevTab, "RIGHT", 0, 0)
            end
            tabButton:SetText(TabNames[i])
            tabButton:SetScript('OnClick',
                function ()
                    self:SetTab(i)
                end)
        end
        PanelTemplates_ResizeTabsToFit(self, self.ScrollBox:GetWidth() - 32)
    else
        -- Grid view doesn't work in classic because ModelScene won't clip
        for _, tabButton in ipairs(self.Tabs) do
            tabButton:Hide()
        end
    end

    self:SetTab(1)

    self.ActionDropdown:SetText(L.LM_ACTIONS)

    --@debug@
    self.NextFamily = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate')
    self.NextFamily:SetSize(96, 22)
    self.NextFamily:SetText("NextFamily")
    self.NextFamily:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -40, -54)
    self.NextFamily:SetScript('OnClick', function () LM.SlashCommandFunc('fam') end)
    self.NextFamily:Show()
    --@end-debug@

    LiteMountSettingsPanelMixin.OnLoad(self)
end

function LiteMountMountsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.ScrollBox, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "RefreshDisplay")
    LM.MountRegistry.RegisterCallback(self, "OnMountSummoned", "RefreshDisplay")

    self.ActionDropdown:SetupMenu(ActionMenuGenerate)

    LM.MountRegistry:UpdateFilterUsability()

    self:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')

    LiteMountSettingsPanelMixin.OnShow(self)
end

function LiteMountMountsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LM.MountRegistry.UnregisterAllCallbacks(self)
    self:UnregisterAllEvents()
    LiteMountSettingsPanelMixin.OnHide(self)
end
