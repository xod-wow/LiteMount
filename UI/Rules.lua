--[[----------------------------------------------------------------------------

  LiteMount/UI/Rules.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[--------------------------------------------------------------------------]]--

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

function LiteMountRuleButtonMixin:OnLoad()
    self.MoveUp:SetScript('OnClick', function () MoveRule(self.index, -1) end)
    self.MoveDown:SetScript('OnClick', function () MoveRule(self.index, 1) end)
end

function LiteMountRuleButtonMixin:Update(index, rule)
    self.index = index
    self.rule = rule
    self.NumText:SetText(index)
    local conditions, action = LM.Rules:RuleToString(rule)
    self.Action:SetText(action)
    self.Condition:SetText(table.concat(conditions, '\n'))
    self.Selected:SetShown(self.rule == LiteMountRulesPanel.selectedRule)
end

function LiteMountRuleButtonMixin:OnClick()
    LiteMountRulesPanel.selectedRule = self.rule
    LiteMountRulesPanel:refresh()
end


--[[--------------------------------------------------------------------------]]--

LiteMountRulesScrollMixin = {}

function LiteMountRulesScrollMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local rules = LM.Options:GetRules(self.tab)

    local totalHeight = #rules * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local index = offset + i
        if index <= #rules then
            button:Update(index, rules[index])
            button:Show()
        else
            button:Hide()
        end
    end

    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountRulesScrollMixin:SetOption(v, i)
    self:GetParent().selectedRule = nil
    return LM.Options:SetRules(i, v)
end

function LiteMountRulesScrollMixin:GetOption(i)
    return LM.Options:GetRules(i)
end

function LiteMountRulesScrollMixin:GetOptionDefault()
    return CopyTable(LM.Options:GetRules('__default__'))
end

function LiteMountRulesScrollMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.ntabs = 4
    self.update = self.Update
    self.SetControl = self.Update
end

--[[--------------------------------------------------------------------------]]--

local function BindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()
    local scroll = LiteMountRulesPanel.Scroll
    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(scroll, v)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (scroll.tab == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[--------------------------------------------------------------------------]]--

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

function LiteMountRulesPanelMixin:OnSizeChanged(x, y)
    HybridScrollFrame_CreateButtons(
            self.Scroll,
            "LiteMountRuleButtonTemplate",
            0, 0, "TOPLEFT", "TOPLEFT",
            0, 0, "TOP", "BOTTOM"
        )
    self.Scroll:Update()
end

function LiteMountRulesPanelMixin:refresh(trigger)
    self.DeleteButton:SetEnabled(self.selectedRule ~= nil)
    self.EditButton:SetEnabled(self.selectedRule ~= nil)
    LiteMountOptionsPanel_Refresh(self, trigger)
end

function LiteMountRulesPanelMixin:OnLoad()
    self.AddButton:SetScript('OnClick', function () self:AddRule() end)
    self.DeleteButton:SetScript('OnClick', function () self:DeleteRule() end)
    self.EditButton:SetScript('OnClick', function () self:EditRule() end)

    LiteMountOptionsPanel_RegisterControl(self.Scroll)

    UIDropDownMenu_Initialize(self.BindingDropDown, BindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountRulesPanelMixin:OnHide()
    LiteMountRuleEdit:Hide()
end
