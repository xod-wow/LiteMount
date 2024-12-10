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
    local scroll = LiteMountRulesPanel.Scroll
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

function LiteMountRuleButtonMixin:Update(index, rule, compiledRule)
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

function LiteMountRulesScrollMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local rules = LM.Options:GetRules(self.tab)
    local ruleSet = LM.Options:GetCompiledRuleSet(self.tab)

    local buttonRuleSet = LM.Options:GetCompiledButtonRuleSet(self.tab)
    local isEnabled = buttonRuleSet:HasApplyRules()

    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local index = offset + i
        if isEnabled and index <= #ruleSet then
            button:Update(index, rules[index], ruleSet[index])
            button:Show()
        else
            button:Hide()
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
    local totalHeight = #ruleSet* self.buttonHeight
    HybridScrollFrame_Update(self, totalHeight, self:GetHeight())
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

function LiteMountRulesScrollMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.ntabs = 4
    self.update = self.Update
    self.SetControl = self.Update
end

--[[------------------------------------------------------------------------]]--

local function BindingGenerator(owner, rootDescription)
    local scroll = LiteMountRulesPanel.Scroll
    local IsSelected = function (v) return scroll.tab == v end
    local SetSelected = function (v) LiteMountOptionsControl_SetTab(scroll, v) end
    for i = 1, 4 do
        rootDescription:CreateRadio(BindingText(i), IsSelected, SetSelected, i)
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountRulesPanelMixin = {}

function LiteMountRulesPanelMixin:AddRuleCallback(rule)
    local binding = self.Scroll.tab
    local rules = LM.Options:GetRules(binding)
    local insertPos = tIndexOf(rules, self.selectedRule) or 1
    table.insert(rules, insertPos, rule)
    self.selectedRule = rule
    self.Scroll.isDirty = true
    LM.Options:SetRules(binding, rules)
end

function LiteMountRulesPanelMixin:AddRule()
    LiteMountRuleEdit:Clear()
    LiteMountRuleEdit:SetCallback(self.AddRuleCallback, self)
    LiteMountOptionsPanel_PopOver(self, LiteMountRuleEdit)
end

function LiteMountRulesPanelMixin:DeleteRule()
    local binding = self.Scroll.tab
    if self.selectedRule then
        self.Scroll.isDirty = true
        local rules = LM.Options:GetRules(binding)
        tDeleteItem(rules, self.selectedRule)
        self.selectedRule = nil
        LM.Options:SetRules(binding, rules)
    end
end

function LiteMountRulesPanelMixin:EditRuleCallback(rule)
    local binding = self.Scroll.tab
    local rules = LM.Options:GetRules(binding)
    local index = tIndexOf(rules, self.selectedRule)
    if index then
        rules[index] = rule
        self.selectedRule = rule
        self.Scroll.isDirty = true
        LM.Options:SetRules(binding, rules)
    end
end

function LiteMountRulesPanelMixin:EditRule()
    LiteMountRuleEdit:SetRule(self.selectedRule)
    LiteMountRuleEdit:SetCallback(self.EditRuleCallback, self)
    LiteMountOptionsPanel_PopOver(self, LiteMountRuleEdit)
end

-- function HybridScrollFrame_CreateButtons (self, buttonTemplate, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
--
function LiteMountRulesPanelMixin:OnSizeChanged(x, y)
    HybridScrollFrame_CreateButtons(self.Scroll, "LiteMountRuleButtonTemplate")
    self.Scroll:Update()
end

function LiteMountRulesPanelMixin:OnRefresh(trigger)
    self.DeleteButton:SetEnabled(self.selectedRule ~= nil)
    self.EditButton:SetEnabled(self.selectedRule ~= nil)
    LiteMountOptionsPanel_OnRefresh(self, trigger)
end

function LiteMountRulesPanelMixin:OnShow()
end

function LiteMountRulesPanelMixin:OnLoad()
    self.BindingDropDown:SetupMenu(BindingGenerator)

    self.AddButton:SetScript('OnClick', function () self:AddRule() end)
    self.DeleteButton:SetScript('OnClick', function () self:DeleteRule() end)
    self.EditButton:SetScript('OnClick', function () self:EditRule() end)

    LiteMountOptionsPanel_RegisterControl(self.Scroll)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountRulesPanelMixin:OnHide()
    LiteMountRuleEdit:Hide()
end
