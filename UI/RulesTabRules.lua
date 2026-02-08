--[[----------------------------------------------------------------------------

  LiteMount/UI/Rules.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountRuleButtonMixin = {}

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
    self.Selected:SetShown(self.rule == LiteMountRulesPanel.Rules.selectedRule)
end

function LiteMountRuleButtonMixin:OnClick()
    LiteMountRulesPanel.Rules.selectedRule = self.rule
    LiteMountRulesPanel.Rules:Refresh()
end


--[[------------------------------------------------------------------------]]--

LiteMountRulesScrollMixin = {}

function LiteMountRulesScrollMixin:RefreshRules()
    local parent = self:GetParent()
    local optionsPanel = parent:GetParent()
    local keyBind = optionsPanel.tab
    local rules = LM.Options:GetRules(keyBind)
    local ruleSet = LM.Options:GetCompiledRuleSet(keyBind)

    local buttonRuleSet = LM.Options:GetCompiledButtonRuleSet(keyBind)
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
        parent.AddButton:Enable()
        optionsPanel.DefaultsButton:Enable()
    else
        parent.selectedRule = nil
        optionsPanel.AddButton:Disable()
        LiteMountRulesPanel.DefaultsButton:Disable()
        self.Inactive:SetText(string.format(L.LM_RULES_INACTIVE, keyBind))
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

LiteMountRulesTabRulesMixin = {}

function LiteMountRulesTabRulesMixin:GetBindingIndex()
    local parent = self:GetParent()
    return parent.tab or 1
end

function LiteMountRulesTabRulesMixin:ReorderRulesFromDataProvider(dataProvider)
    local bindingIndex = self:GetBindingIndex()
    local oldRules = LM.Options:GetRules(bindingIndex)
    local newRules = {}
    for i, elementData in dataProvider:EnumerateEntireRange() do
        newRules[i] = oldRules[elementData.index]
        elementData.index = i
    end
    LM.Options:SetRules(bindingIndex, newRules)
    self.isDirty = true
end

function LiteMountRulesTabRulesMixin:AddRuleCallback(rule)
    local bindingIndex = self:GetBindingIndex()
    local rules = LM.Options:GetRules(bindingIndex)
    local insertPos = tIndexOf(rules, self.selectedRule) or 1
    table.insert(rules, insertPos, rule)
    self.selectedRule = rule
    self.isDirty = true
    LM.Options:SetRules(bindingIndex, rules)
end

function LiteMountRulesTabRulesMixin:AddRule()
    LiteMountRuleEdit:Clear()
    LiteMountRuleEdit:SetCallback(self.AddRuleCallback, self)
    LiteMountOptionsPanel_PopOver(LiteMountRuleEdit, self:GetParent())
end

function LiteMountRulesTabRulesMixin:DeleteRule()
    local bindingIndex = self:GetBindingIndex()
    if self.selectedRule then
        self.ScrollBox.isDirty = true
        local rules = LM.Options:GetRules(bindingIndex)
        tDeleteItem(rules, self.selectedRule)
        self.selectedRule = nil
        LM.Options:SetRules(bindingIndex, rules)
    end
end

function LiteMountRulesTabRulesMixin:EditRuleCallback(rule)
    local bindingIndex = self:GetBindingIndex()
    local rules = LM.Options:GetRules(bindingIndex)
    local index = tIndexOf(rules, self.selectedRule)
    if index then
        rules[index] = rule
        self.selectedRule = rule
        self.ScrollBox.isDirty = true
        LM.Options:SetRules(bindingIndex, rules)
    end
end

function LiteMountRulesTabRulesMixin:EditRule()
    LiteMountRuleEdit:SetRule(self.selectedRule)
    LiteMountRuleEdit:SetCallback(self.EditRuleCallback, self)
    LiteMountOptionsPanel_PopOver(LiteMountRuleEdit, self:GetParent())
end

function LiteMountRulesTabRulesMixin:Refresh()
    self.ScrollBox:RefreshRules()
    self.DeleteButton:SetEnabled(self.selectedRule ~= nil)
    self.EditButton:SetEnabled(self.selectedRule ~= nil)
end

function LiteMountRulesTabRulesMixin:OnShow()
    self.ScrollBox:RefreshRules()
end

function LiteMountRulesTabRulesMixin:OnLoad()
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
            self:ReorderRulesFromDataProvider(contextData.dataProvider)
        end)

    self.AddButton:SetScript('OnClick', function () self:AddRule() end)
    self.DeleteButton:SetScript('OnClick', function () self:DeleteRule() end)
    self.EditButton:SetScript('OnClick', function () self:EditRule() end)
end

function LiteMountRulesTabRulesMixin:OnHide()
    LiteMountRuleEdit:Hide()
end
