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
    self.MoveUp:SetScript('OnClick', function (self) MoveRule(self:GetParent().index, -1) end)
    self.MoveDown:SetScript('OnClick', function (self) MoveRule(self:GetParent().index, 1) end)
end

function LiteMountRuleButtonMixin:Initialize(level, menuList)
end

--[[--------------------------------------------------------------------------]]--

LiteMountRulesScrollMixin = {}

-- LoadAddOn('Blizzard_DebugTools')

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
            button.index = index
            local rule = rules[index]
            button.NumText:SetText(index)
            local c, a = LM.Rules:UserRuleText(rule)
            button.Condition:SetText(c)
            button.Action:SetText(a)
            button:Show()
        else
            button:Hide()
        end
    end

    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountRulesScrollMixin:OnShow()
    self:Update()
end

function LiteMountRulesScrollMixin:SetOption(v, i)
    return LM.Options:SetRules(i, v)
end

function LiteMountRulesScrollMixin:GetOption(i)
    return LM.Options:GetRules(i)
end

function LiteMountRulesScrollMixin:GetOptionDefault()
    return LM.Options:GetRules('*')
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

function LiteMountRulesPanelMixin:OnSizeChanged(x, y)
    HybridScrollFrame_CreateButtons(
            self.Scroll,
            "LiteMountRuleButtonTemplate",
            0, 0, "TOPLEFT", "TOPLEFT",
            0, 0, "TOP", "BOTTOM"
        )
    self.Scroll:Update()
end

function LiteMountRulesPanelMixin:OnLoad()
    self.name = "Rules"

    LiteMountOptionsPanel_RegisterControl(self.Scroll)

    UIDropDownMenu_Initialize(self.BindingDropDown, BindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    LiteMountOptionsPanel_OnLoad(self)
end
