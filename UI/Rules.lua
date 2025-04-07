--[[----------------------------------------------------------------------------

  LiteMount/UI/Rules.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[------------------------------------------------------------------------]]--

LiteMountRuleButtonMixin = {}

local function MoveRule(i, n)
    local scroll = LiteMountRulesPanel.ScrollBox
    scroll.isDirty = true
    local rules = LM.Options:GetRules(scroll.tab)
    if i+n < 1 or i+n > #rules then return end
    local elt = table.remove(rules, i)
    table.insert(rules, i+n, elt)
    LM.Options:SetRules(scroll.tab, rules)
end

function LiteMountRuleButtonMixin:OnShow()
    self:SetWidth(self:GetParent():GetWidth())
end

function LiteMountRuleButtonMixin:OnEnter()
    if self.errorLines then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:AddLine(ERRORS, 1, 1, 1)
        for _, line in ipairs(self.errorLines) do
            GameTooltip:AddLine(line)
        end
        GameTooltip:Show()
    end
end

function LiteMountRuleButtonMixin:OnLoad()
    self.MoveUp:SetScript('OnClick', function () MoveRule(self.index, -1) end)
    self.MoveDown:SetScript('OnClick', function () MoveRule(self.index, 1) end)
end

function LiteMountRuleButtonMixin:Initialize(index, rule, compiledRule)
    self.index = index
    self.rule = rule
    self.NumText:SetText(index)
    if next(compiledRule.errors) then
        self.Error:Show()
        self.errorLines = compiledRule.errors
        self.Condition:ClearAllPoints()
        self.Condition:SetPoint("LEFT", self.Error, "RIGHT", 4, 0)
        self.Condition:SetPoint("RIGHT", self, "CENTER")
    else
        self.Error:Hide()
        self.errorLines = nil
        self.Condition:ClearAllPoints()
        self.Condition:SetPoint("LEFT", self.NumText, "RIGHT", 4, 0)
        self.Condition:SetPoint("RIGHT", self, "CENTER")
    end
    local conditions, action = compiledRule:ToDisplay()
    self.Action:SetText(action)
    self.Condition:SetText(table.concat(conditions, '\n'))
    self.Selected:SetShown(self.rule == LiteMountRulesPanel.selectedRule)
end

function LiteMountRuleButtonMixin:OnClick()
    LiteMountRulesPanel.selectedRule = self.rule
    LiteMountRulesPanel:OnRefresh()
end


--[[------------------------------------------------------------------------]]--

LiteMountRulesScrollMixin = {}

function LiteMountRulesScrollMixin:RefreshRules()
    local rules = LM.Options:GetRules(self.tab)
    local ruleSet = LM.Options:GetCompiledRuleSet(self.tab)

    local buttonRuleSet = LM.Options:GetCompiledButtonRuleSet(self.tab)
    local isEnabled = buttonRuleSet:HasApplyRules()

    local dp = CreateDataProvider()

    if isEnabled then
        for i = 1, #rules do
            -- this is the elementData from SetElementInitializer
            dp:Insert({ index = i, rule = rules[i], compiledRule = ruleSet[i] })
        end
    end

    if isEnabled then
        self.Inactive:Hide()
        LiteMountRulesPanel.AddButton:Enable()
        LiteMountRulesPanel.DefaultsButton:Enable()
    else
        LiteMountRulesPanel.selectedRule = nil
        LiteMountRulesPanel.AddButton:Disable()
        LiteMountRulesPanel.DefaultsButton:Disable()
        self.Inactive:SetText(string.format(L.LM_RULES_INACTIVE, self.tab))
        self.Inactive:Show()
    end

    self:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountRulesScrollMixin:SetOption(v, i)
    self:GetParent().selectedRule = nil
    return LM.Options:SetRules(i, v)
end

function LiteMountRulesScrollMixin:GetOption(i)
    return LM.Options:GetRules(i)
end

function LiteMountRulesScrollMixin:GetOptionDefault()
    return nil
end


--[[------------------------------------------------------------------------]]--

local function BindingGenerator(owner, rootDescription)
    local scroll = LiteMountRulesPanel.ScrollBox
    local IsSelected = function (v) return scroll.tab == v end
    local SetSelected = function (v) LiteMountOptionsControl_SetTab(scroll, v) end
    for i = 1, 4 do
        rootDescription:CreateRadio(BindingText(i), IsSelected, SetSelected, i)
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountRulesPanelMixin = {}

function LiteMountRulesPanelMixin:AddRuleCallback(rule)
    local binding = self.ScrollBox.tab
    local rules = LM.Options:GetRules(binding)
    local insertPos = tIndexOf(rules, self.selectedRule) or 1
    table.insert(rules, insertPos, rule)
    self.selectedRule = rule
    self.ScrollBox.isDirty = true
    LM.Options:SetRules(binding, rules)
end

function LiteMountRulesPanelMixin:AddRule()
    LiteMountRuleEdit:Clear()
    LiteMountRuleEdit:SetCallback(self.AddRuleCallback, self)
    LiteMountOptionsPanel_PopOver(self, LiteMountRuleEdit)
end

function LiteMountRulesPanelMixin:DeleteRule()
    local binding = self.ScrollBox.tab
    if self.selectedRule then
        self.ScrollBox.isDirty = true
        local rules = LM.Options:GetRules(binding)
        tDeleteItem(rules, self.selectedRule)
        self.selectedRule = nil
        LM.Options:SetRules(binding, rules)
    end
end

function LiteMountRulesPanelMixin:EditRuleCallback(rule)
    local binding = self.ScrollBox.tab
    local rules = LM.Options:GetRules(binding)
    local index = tIndexOf(rules, self.selectedRule)
    if index then
        rules[index] = rule
        self.selectedRule = rule
        self.ScrollBox.isDirty = true
        LM.Options:SetRules(binding, rules)
    end
end

function LiteMountRulesPanelMixin:EditRule()
    LiteMountRuleEdit:SetRule(self.selectedRule)
    LiteMountRuleEdit:SetCallback(self.EditRuleCallback, self)
    LiteMountOptionsPanel_PopOver(self, LiteMountRuleEdit)
end

function LiteMountRulesPanelMixin:OnRefresh(trigger)
    self.DeleteButton:SetEnabled(self.selectedRule ~= nil)
    self.EditButton:SetEnabled(self.selectedRule ~= nil)
    LiteMountOptionsPanel_OnRefresh(self, trigger)
end

function LiteMountRulesPanelMixin:OnShow()
    self.ScrollBox:RefreshRules()
end

function LiteMountRulesPanelMixin:OnLoad()
    self.BindingDropDown:SetupMenu(BindingGenerator)

    local function ButtonInitializer(button, elementData)
        button:Initialize(elementData.index, elementData.rule, elementData.compiledRule)
    end

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("LiteMountRuleButtonTemplate", ButtonInitializer)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

    --[[
    --
    -- This is almost working, except the cursor frame is way out of position. Not
    -- sure if this is my bug, or Blizzard's. Also needs whatever magic happens to
    -- actually do the reorder, probably dragBehavior:SetPostDrop.
    --

    local function CursorInitializer(button, sourceButton, elementData)
        button:Initialize(elementData.index, elementData.rule, elementData.compiledRule)
        button.Selected:Hide()
        button:SetWidth(sourceButton:GetWidth())
    end

    local function CursorFactory(elementData) return "LiteMountRuleButtonTemplate", CursorInitializer end

    local dragBehavior = ScrollUtil.InitDefaultLinearDragBehavior(self.ScrollBox)
    dragBehavior:SetReorderable(true)
    dragBehavior:SetDragRelativeToCursor(true)
    dragBehavior:SetCursorFactory(ScrollUtil.GenerateCursorFactory(self.ScrollBox))

    ]]

    self.ScrollBox.ntabs = 4
    self.ScrollBox.update = self.ScrollBox.RefreshRules
    self.ScrollBox.SetControl = self.ScrollBox.RefreshRules

    self.AddButton:SetScript('OnClick', function () self:AddRule() end)
    self.DeleteButton:SetScript('OnClick', function () self:DeleteRule() end)
    self.EditButton:SetScript('OnClick', function () self:EditRule() end)

    LiteMountOptionsPanel_RegisterControl(self.ScrollBox)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountRulesPanelMixin:OnHide()
    LiteMountRuleEdit:Hide()
end
