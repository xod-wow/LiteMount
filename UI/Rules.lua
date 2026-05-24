--[[----------------------------------------------------------------------------

  LiteMount/UI/Rules.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[------------------------------------------------------------------------]]--

LiteMountRuleButtonMixin = {}

local function ReorderRulesFromDataProvider(dataProvider)
    local self = LiteMountRulesPanel
    local oldRules = LM.Options:GetRules(self.tab)
    local newRules = {}
    for i, elementData in dataProvider:EnumerateEntireRange() do
        newRules[i] = oldRules[elementData.index]
        elementData.index = i
    end
    self:MarkDirty()
    LM.Options:SetRules(self.tab, newRules)
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
    LiteMountRulesPanel:RefreshDisplay()
end


--[[------------------------------------------------------------------------]]--

local function BindingGenerator(owner, rootDescription)
    local self = LiteMountRulesPanel
    local IsSelected = function (v) return self.tab == v end
    local SetSelected = function (v) self:SetTab(v) end
    for i = 1, 4 do
        rootDescription:CreateRadio(BindingText(i), IsSelected, SetSelected, i)
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountRulesPanelMixin = {}

function LiteMountRulesPanelMixin:RefreshDisplay()
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
        self.ScrollBox.Inactive:Hide()
        self.AddButton:Enable()
        self.DefaultsButton:Enable()
    else
        self.selectedRule = nil
        self.AddButton:Disable()
        self.DefaultsButton:Disable()
        self.ScrollBox.Inactive:SetText(string.format(L.LM_RULES_INACTIVE, self.tab))
        self.ScrollBox.Inactive:Show()
    end

    self.ScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)

    LiteMountSettingsPanelMixin.RefreshDisplay(self)
end

function LiteMountRulesPanelMixin:LoadSettings(sets)
    self.selectedRule = nil
    local dontFire = true
    for i = 1, self.ntabs do
        LM.Options:SetRules(i, sets[i], dontFire)
    end
end

function LiteMountRulesPanelMixin:SaveSettings()
    local sets = {}
    for i = 1, self.ntabs do
        sets[i] = LM.Options:GetRules(i)
    end
    return sets
end

function LiteMountRulesPanelMixin:LoadDefaultSettings()
    local dontFire = true
    for i = 1, self.ntabs do
        LM.Options:SetRules(i, nil, dontFire)
    end
end

function LiteMountRulesPanelMixin:AddRuleCallback(rule)
    local rules = LM.Options:GetRules(self.tab)
    local insertPos = tIndexOf(rules, self.selectedRule) or 1
    table.insert(rules, insertPos, rule)
    self.selectedRule = rule
    self:MarkDirty()
    LM.Options:SetRules(self.tab, rules)
end

function LiteMountRulesPanelMixin:AddRule()
    LiteMountRuleEdit:Clear()
    LiteMountRuleEdit:SetCallback(self.AddRuleCallback, self)
    self:PopOver(LiteMountRuleEdit)
end

function LiteMountRulesPanelMixin:DeleteRule()
    if self.selectedRule then
        local rules = LM.Options:GetRules(self.tab)
        tDeleteItem(rules, self.selectedRule)
        self.selectedRule = nil
        self:MarkDirty()
        LM.Options:SetRules(self.tab, rules)
    end
end

function LiteMountRulesPanelMixin:EditRuleCallback(rule)
    local rules = LM.Options:GetRules(self.tab)
    local index = tIndexOf(rules, self.selectedRule)
    if index then
        rules[index] = rule
        self.selectedRule = rule
        self:MarkDirty()
        LM.Options:SetRules(self.tab, rules)
    end
end

function LiteMountRulesPanelMixin:EditRule()
    LiteMountRuleEdit:SetRule(self.selectedRule)
    LiteMountRuleEdit:SetCallback(self.EditRuleCallback, self)
    self:PopOver(LiteMountRuleEdit)
end

function LiteMountRulesPanelMixin:OnLoad()
    self.BindingDropDown:SetupMenu(BindingGenerator)

    local function ButtonInitializer(button, elementData)
        button:Initialize(elementData.index, elementData.rule, elementData.compiledRule)
    end

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("LiteMountRuleButtonTemplate", ButtonInitializer)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

    -- This is dependent on the panels starting out with parent=UIParent in the
    -- XML even though it seems irrelevant, because the drag behavior closures
    -- capture "rootparent" on init for positioning and it needs to come out as
    -- UIParent.

    local templateInfo = C_XMLUtil.GetTemplateInfo("LiteMountRuleButtonTemplate")

    local dragBehavior = ScrollUtil.InitDefaultLinearDragBehavior(self.ScrollBox)
    dragBehavior:SetReorderable(true)
    dragBehavior:SetAreaIntersectMargin(
        function (destinationElementData, sourceElementData, contextData)
            return templateInfo.height * 0.5
        end)
    dragBehavior:SetDropPredicate(
        function (sourceElementData, contextData)
            return contextData.area ~= DragIntersectionArea.Inside
        end)
    dragBehavior:SetDropEnter(
        function (factory, candidate)
            local candidateArea = candidate.area
            local candidateFrame = candidate.frame
            local w, h = candidateFrame:GetSize()
            local frame = factory("ScrollBoxDragBoxTemplate")
            frame:SetSize(w, h/4)
            if candidateArea == DragIntersectionArea.Above then
                frame:SetPoint("CENTER", candidateFrame, "TOP")
            elseif candidateArea == DragIntersectionArea.Below then
                frame:SetPoint("CENTER", candidateFrame, "BOTTOM")
            elseif candidateArea == DragIntersectionArea.Inside then
                frame:SetPoint("CENTER", candidateFrame, "CENTER")
            end

        end)
    dragBehavior:SetPostDrop(
        function (contextData)
            ReorderRulesFromDataProvider(contextData.dataProvider)
        end)

    self.ntabs = 4
    self.tab = 1

    self.AddButton:SetScript('OnClick', function () self:AddRule() end)
    self.DeleteButton:SetScript('OnClick', function () self:DeleteRule() end)
    self.EditButton:SetScript('OnClick', function () self:EditRule() end)

    LiteMountSettingsPanelMixin.OnLoad(self)
end

function LiteMountRulesPanelMixin:OnHide()
    LiteMountRuleEdit:Hide()
    LiteMountSettingsPanelMixin.OnHide(self)
end
