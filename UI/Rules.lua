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

-- user rules have a simpler condition format: 1 level and op="AND"

local function ExpandOneCondition(ruleCondition)
    local condition, conditionArg = string.split(':', ruleCondition, 2)

    if condition == "map" then
        local info = C_Map.GetMapInfo(tonumber(conditionArg))
        return string.format("%s: %s (%s)", WORLD_MAP, info.name, conditionArg)
    elseif condition == "instance" then
        local n = LM.Options:GetInstanceNameByID(tonumber(conditionArg))
        if n then
            return string.format("%s: %s (%s)", INSTANCE, n, conditionArg)
        end
    elseif condition == "location" then
        return string.format("%s %s", LOCATION_COLON, conditionArg)
    elseif condition == "submerged" then
        return TUTORIAL_TITLE28
    elseif condition == "mod" then
        if conditionArg == "alt" then
            return ALT_KEY
        elseif conditionArg == "ctrl" then
            return CTRL_KEY
        elseif conditionArg == "shift" then
            return SHIFT_KEY
        end
    elseif condition == "flyable" then
        return "Flying mounts are usable"
    end

    return ORANGE_FONT_COLOR_CODE .. '[' .. ruleCondition .. ']' .. FONT_COLOR_CODE_CLOSE
end

local function ExpandConditions(rule)
    local conditions = {}
    for _, ruleCondition in ipairs(rule.conditions) do
        if type(ruleCondition) == 'table' then
            table.insert(conditions, RED_FONT_COLOR_CODE .. 'NOT ' .. ExpandOneCondition(ruleCondition[1]) .. FONT_COLOR_CODE_CLOSE)
        else
            table.insert(conditions, ExpandOneCondition(ruleCondition))
        end
    end
    return table.concat(conditions, "\n")
end

local function ExpandMountFilter(actionArg)
    if not actionArg then return end
    if actionArg:match('id:%d+') then
        local _, id = string.split(':', actionArg)
        actionArg = C_MountJournal.GetMountInfoByID(tonumber(id))
    elseif actionArg:match('mt:230') then
        return "Ground Type"
    elseif actionArg:match('mt:231') then
        return "Turtle Type"
    elseif actionArg:match('mt:232') then
        return "Vashj'ir Type"
    elseif actionArg:match('mt:241') then
        return "Ahn'qiraj Type"
    elseif actionArg:match('mt:248') then
        return "Flying Type"
    elseif actionArg:match('mt:254') then
        return "Swimming Type"
    elseif actionArg:match('mt:284') then
        return "Chauffeur Type"
    elseif actionArg:match('mt:398') then
        return "Kua'fon Type"
    end
    return actionArg
end

local function ExpandAction(rule)
    local action = rule.action
    local actionArg = table.concat(rule.args, ' ')
    if tContains({ 'Mount', 'SmartMount' }, action) then
        if actionArg then
            return ExpandMountFilter(actionArg)
        end
    elseif action == "Limit" then
        if actionArg:sub(1,1) == '-' then
            return "Exclude " .. ExpandMountFilter(actionArg:sub(2))
        elseif actionArg:sub(1,1) == '+' then
            return "Include" .. ExpandMountFilter(actionArg:sub(2))
        else
            return "Restrict to " .. ExpandMountFilter(actionArg)
        end
    end
    return action .. ' ' .. actionArg
end

local function ExpandRule(rule)
    return ExpandConditions(rule), ExpandAction(rule)
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
            local c, a = ExpandRule(rule)
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
    self.EditBox:SetWidth(self:GetWidth() - 18)
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
