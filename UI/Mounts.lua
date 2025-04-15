--[[----------------------------------------------------------------------------

  LiteMount/UI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountPriorityMixin = {}

function LiteMountPriorityMixin:Update()
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
    local mount = self:GetParent().mount
    if mount then
        return mount:GetPriority()
    end
end

function LiteMountPriorityMixin:Set(v)
    local mount = self:GetParent().mount
    if mount then
        LiteMountMountsPanel.ScrollBox.isDirty = true
        LM.Options:SetPriority(mount, v or LM.Options.DEFAULT_PRIORITY)
    end
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

LiteMountFlagBitMixin = {}

function LiteMountFlagBitMixin:OnClick()
    local mount = self:GetParent().mount

    LiteMountMountsPanel.ScrollBox.isDirty = true
    if self:GetChecked() then
        LM.Options:SetMountFlag(mount, self.flag)
    else
        LM.Options:ClearMountFlag(mount, self.flag)
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

function LiteMountFlagBitMixin:Update(flag, mount)
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

--[[------------------------------------------------------------------------]]--

-- This is a minimal emulation of LM.ActionButton

LiteMountMountIconMixin = {}

function LiteMountMountIconMixin:OnEnter()
    local m = self:GetParent().mount
    LiteMountTooltip:SetOwner(self, "ANCHOR_RIGHT", 8)
    LiteMountTooltip:SetMount(m, true)
end

function LiteMountMountIconMixin:OnLeave()
    LiteMountTooltip:Hide()
end

function LiteMountMountIconMixin:OnClickHook(mouseButton, isDown)
    if self.clickHookFunction then
        self.clickHookFunction()
    end
end

function LiteMountMountIconMixin:PreClick(mouseButton, isDown)
    if mouseButton == 'LeftButton' and IsModifiedClick("CHATLINK") then
        local mount = self:GetParent().mount
        ChatEdit_InsertLink(C_Spell.GetSpellLink(mount.spellID))
    end
end

function LiteMountMountIconMixin:OnLoad()
    self:SetAttribute("unit", "player")
    self:RegisterForClicks("AnyUp")
    self:RegisterForDrag("LeftButton")
    self:SetScript('PreClick', self.PreClick)
    self:HookScript('OnClick', self.OnClickHook)
end

function LiteMountMountIconMixin:OnDragStart()
    local mount = self:GetParent().mount
    if mount.spellID then
        C_Spell.PickupSpell(mount.spellID)
    elseif mount.itemID then
        C_Item.PickupItem(mount.itemID)
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountMountHeaderMixin = {}

function LiteMountMountHeaderMixin:SetCollapsedState(isCollapsed)
    local atlas = isCollapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse"
    self.CollapseIcon:SetAtlas(atlas, true)
    self.CollapseIconAlphaAdd:SetAtlas(atlas, true)
end


--[[------------------------------------------------------------------------]]--

LiteMountMountButtonMixin = {}

function LiteMountMountButtonMixin:Initialize(bitFlags, mount)
    self.mount = mount
    self.Icon:SetNormalTexture(mount.icon)
    self.Name:SetText(mount.name)
--@debug@
    self.Name:SetText(mount.name .. ' ' .. tostring(mount.mountTypeID))
--@end-debug@

    local count = mount:GetSummonCount()
    if count > 0 then
        self.Icon.Count:SetText(count)
        self.Icon.Count:Show()
    else
        self.Icon.Count:Hide()
    end

    if not InCombatLockdown() then
        mount:GetCastAction():SetupActionButton(self.Icon, 2)
    end

    local i = 1
    while self["Bit"..i] do
        self["Bit"..i]:Update(bitFlags[i], mount)
        i = i + 1
    end

    local flagTexts = { }

    for _, flag in ipairs(LM.Options:GetFlags()) do
        if mount.flags[flag] then
            table.insert(flagTexts, L[flag])
        end
        self.Types:SetText(strjoin(' ', unpack(flagTexts)))
    end

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

    self.Priority:Update()
end

--[[------------------------------------------------------------------------]]--

LiteMountMountScrollBoxMixin = {}

function LiteMountMountScrollBoxMixin:RefreshMountList()
    -- Because the Icon is a SecureActionButton and a child of the scroll
    -- buttons, we can't show or hide them in combat. Rather than throw a
    -- LUA error, it's better just not to do anything at all.
    if InCombatLockdown() then return end

    local mounts = LM.UIFilter.GetFilteredMountList()
    local dp = CreateTreeDataProvider()

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
    else
        for _, m in ipairs(mounts) do
            dp:Insert(m)
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

function LiteMountMountsPanelMixin:OnLoad()

    local view = CreateScrollBoxListTreeListView()
--[[
    view:SetElementInitializer("LiteMountMountButtonTemplate",
        function (button, elementData)
            button:Initialize(LiteMountMountsPanel.allFlags, elementData)
        end)
]]
    view:SetElementFactory(
        function (factory, node)
            local data = node:GetData()
            if data.isHeader then
                factory("LiteMountMountHeaderTemplate",
                    function (button, node)
                        button.Name:SetText(data.name .. ' (' .. #node:GetNodes() .. ')')
                        button:SetCollapsedState(node:IsCollapsed())
                        button:SetScript("OnClick",
                            function ()
                                node:ToggleCollapsed()
                                button:SetCollapsedState(node:IsCollapsed())
                            end)
                    end)
            else
                factory("LiteMountMountButtonTemplate",
                    function (button, node)
                        button:Initialize(LiteMountMountsPanel.allFlags, data)
                    end)
            end
        end)
    view:SetElementExtentCalculator(
        function (dataIndex, node)
            if node:GetData().isHeader then
                return 22
            else
                return 44
            end
        end)
    view:SetElementIndentCalculator(
        function (node)
            if node:GetData().isHeader then
                return 0
            else
                return 8
            end
        end)
    view:SetPadding(0, 0, 0, 0, 0)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

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

    LiteMountOptionsPanel_OnLoad(self)

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

