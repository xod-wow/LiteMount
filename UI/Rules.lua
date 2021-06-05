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

local function ExpandRule(rule)
    local condition, conditionArg = string.split(':', rule.conditions[1][1], 2)
    local action = rule.action
    local actionArg = table.concat(rule.args, ' ')

    if condition == "map" then
        local info = C_Map.GetMapInfo(tonumber(conditionArg))
        conditionArg = string.format('%s (%s)', info.name, conditionArg)
    elseif condition == "instance" then
        local n = LM.Options:GetInstanceNameByID(tonumber(conditionArg))
        if n then conditionArg = string.format('%s (%s)', n, conditionArg) end
    elseif condition == "extra" and conditionArg then
        local n = GetSpellInfo(tonumber(conditionArg))
        if n then conditionArg = n end
    elseif condition == "mod" then
        if conditionArg == "alt" then
            conditionArg = ALT_KEY
        elseif conditionArg == "ctrl" then
            conditionArg = CTRL_KEY
        elseif conditionArg == "shift" then
            conditionArg = SHIFT_KEY
        end
    end

    if tContains({ 'Mount', 'SmartMount', 'Limit'}, action) then
        if actionArg and actionArg:match('id:%d+') then
            local _, id = string.split(':', actionArg)
            actionArg = C_MountJournal.GetMountInfoByID(tonumber(id))
        end
    end

    return condition, conditionArg, action, actionArg
end

--[[--------------------------------------------------------------------------]]--

LiteMountRuleButtonMixin = {}

function LiteMountRuleButtonMixin:OnShow()
    self:SetWidth(self:GetParent():GetWidth())
end

function LiteMountRuleButtonMixin:OnLoad()
--[[
    UIDropDownMenu_Initialize(self.Condition.DropDown, self.Initialize, "MENU")
    UIDropDownMenu_Initialize(self.ConditionArg.DropDown, self.Initialize, "MENU")
    UIDropDownMenu_Initialize(self.Action.DropDown, self.Initialize, "MENU")
    UIDropDownMenu_Initialize(self.ActionArg.DropDown, self.Initialize, "MENU")
]]
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
            local rule = rules[index]
            button.NumText:SetText(index)
            local c, ca, a, aa = ExpandRule(rule)
            button.Condition:SetText(c)
            button.ConditionArg:SetText(ca)
            button.Action:SetText(a)
            button.ActionArg:SetText(aa)
            button:Show()
        else
            button:Hide()
        end
    end

    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountRulesScrollMixin:OnShow()
    self.EditBox:SetWidth(self:GetWidth() - 18)
end

function LiteMountRulesScrollMixin:SetOption(v, i)
end

function LiteMountRulesScrollMixin:GetOption(i)
    return LM.Options:GetButtonAction(i)
end

function LiteMountRulesScrollMixin:GetOptionDefault()
    return LM.Options:GetButtonAction('*')
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
