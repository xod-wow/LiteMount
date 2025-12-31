--[[----------------------------------------------------------------------------

  LiteMount/UI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

local TabNames = {
    [1] = L.LM_LIST_VIEW,
    [2] = L.LM_MODEL_VIEW,
}


--[[------------------------------------------------------------------------]]--

LiteMountAllPriorityMixin = {}

function LiteMountAllPriorityMixin:Set(v)
    local mounts = LM.UIFilter.GetFilteredMountList()
    LiteMountMountsPanel.ScrollBox.isDirty = true
    LM.Options:SetPriorities(mounts, v or LM.Options.DEFAULT_PRIORITY)
end

function LiteMountAllPriorityMixin:Get()
    local mounts = LM.UIFilter.GetFilteredMountList()

    local allValue

    for _,mount in ipairs(mounts) do
        local v = mount:GetPriority()
        if (allValue or v) ~= v then
            allValue = nil
            break
        else
            allValue = v
        end
    end

    return allValue
end


--[[------------------------------------------------------------------------]]--

LiteMountMountScrollBoxMixin = {}

function LiteMountMountScrollBoxMixin:RefreshMountList()
    -- Because the Icon is a SecureActionButton and a child of the scroll
    -- buttons, we can't show or hide them in combat. Rather than throw a
    -- LUA error, it's better just not to do anything at all.
    if InCombatLockdown() then return end

    local mounts = LM.UIFilter.GetFilteredMountList()
    local dp

    local currentView = self:GetView()

    if currentView.stride then
        dp = CreateDataProvider(mounts)
    else
        dp = CreateTreeDataProvider()
        if LM.UIFilter.GetSortKey() == 'family' then
            local familySubTrees = {}
            for _, m in ipairs(mounts) do
                if not familySubTrees[m.family] then
                    local data = {
                        isHeader = true,
                        name = LM.UIFilter.GetSortKeyText('family') .. ': ' .. m.family,
                    }
                    familySubTrees[m.family] = dp:Insert(data)
                end
                familySubTrees[m.family]:Insert(m)
            end
        elseif LM.UIFilter.GetSortKey() == 'expansion' then
            local subTrees = {}
            for _, m in ipairs(mounts) do
                local expansion = m.expansion or -1
                if not subTrees[expansion] then
                    local name = _G["EXPANSION_NAME"..tostring(expansion)] or NONE
                    local data = { isHeader = true, name = name }
                    subTrees[expansion] = dp:Insert(data)
                end
                subTrees[expansion]:Insert(m)
            end
        else
            for _, m in ipairs(mounts) do
                dp:Insert(m)
            end
        end
    end
    self:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountMountScrollBoxMixin:GetOption()
    return {
        CopyTable(LM.Options:GetRawFlagChanges(), true),
        CopyTable(LM.Options:GetRawMountPriorities(), true)
    }
end

function LiteMountMountScrollBoxMixin:SetOption(v)
    LM.Options:SetRawFlagChanges(v[1])
    LM.Options:SetRawMountPriorities(v[2])
end

-- The only control: does all the triggered updating for the entire panel
function LiteMountMountScrollBoxMixin:SetControl(v)
    self:GetParent():Update()
end

--[[------------------------------------------------------------------------]]--

LiteMountMountsPanelMixin = {}

function LiteMountMountsPanelMixin:Update()
    LM.UIFilter.ClearCache()
    self.ScrollBox:RefreshMountList()
    self.AllPriority:Update()
end

function LiteMountMountsPanelMixin:OnDefault()
    LM.UIDebug(self, 'Custom_Default')
    self.ScrollBox.isDirty = true
    LM.Options:ResetAllMountFlags()
    LM.Options:SetPriorities(LM.MountRegistry.mounts, nil)
end

function LiteMountMountsPanelMixin:SetupFromTabbing()
    -- Note this is always 1 for classic with tabs disabled
    local n = self.selectedTab or 1
    for i, tabButton in ipairs(self.Tabs) do
        if i == n then
            PanelTemplates_SelectTab(tabButton)
        else
            PanelTemplates_DeselectTab(tabButton)
        end
    end
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.tabViews[n])

    self.AllPriority:SetShown(n==1)
    self.PriorityLabel:SetShown(n==1)
    for i = 1, 4 do
        local label = self["BitLabel"..i]
        label:SetShown(n==1)
    end
end

function LiteMountMountsPanelMixin:OnLoad()
    self.tabViews = {}

    local function dirtyFunc() self.ScrollBox.isDirty = true end

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

    self:SetupFromTabbing()

    self.name = MOUNTS

    self.allFlags = LM.Options:GetFlags()

    for i = 1, 4 do
        local label = self["BitLabel"..i]
        if self.allFlags[i] then
            label:SetText(L[self.allFlags[i]])
        end
    end

    self:SetScript('OnEvent', function () self.ScrollBox:RefreshMountList() end)

    -- We are using the ScrollBox SetControl to do ALL the updating.

    LiteMountOptionsPanel_RegisterControl(self.ScrollBox)

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
                    self.selectedTab = i
                    self:SetupFromTabbing()
                    self.ScrollBox:RefreshMountList()
                end)
        end
        PanelTemplates_ResizeTabsToFit(self, self.ScrollBox:GetWidth() - 32)
    else
        -- Grid view doesn't work in classic because ModelScene won't clip
        for _, tabButton in ipairs(self.Tabs) do
            tabButton:Hide()
        end
    end

    --@debug@
    self.NextFamily = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate')
    self.NextFamily:SetSize(96, 22)
    self.NextFamily:SetText("NextFamily")
    self.NextFamily:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -40, -54)
    self.NextFamily:SetScript('OnClick', function () LM.SlashCommandFunc('fam') end)
    self.NextFamily:Show()
    --@end-debug@
end

function LiteMountMountsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.ScrollBox, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "OnRefresh")
    LM.MountRegistry:RefreshMounts()
    LM.MountRegistry:UpdateFilterUsability()
    LM.MountRegistry.RegisterCallback(self, "OnMountSummoned", "OnRefresh")

    self.ScrollBox:RefreshMountList()

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

    self:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')

    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountMountsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LM.MountRegistry.UnregisterAllCallbacks(self)
    self:UnregisterAllEvents()
    LiteMountOptionsPanel_OnHide(self)
end

