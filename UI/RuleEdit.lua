--[[----------------------------------------------------------------------------

  LiteMount/UI/Ruledit.lua

  Pop-over to edit a user rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

--[[--------------------------------------------------------------------------]]--

local function ArgsInitialize(dropDown, level, menuList)
    if not menuList then return end

    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.func = function (button, arg1, arg2)
                    dropDown.owner:GetParent():SetArg(arg1)
                    CloseDropDownMenus(1)
                end

    if #menuList > MENU_SPLIT_SIZE * 1.5 then
        info.notCheckable = true
        info.hasArrow = true
        info.func = nil

        local stride = 1
        while #menuList/stride > MENU_SPLIT_SIZE do
            stride = stride * MENU_SPLIT_SIZE
        end

        for i = 1, #menuList, stride do
            local j = math.min(#menuList, i+stride-1)
            info.menuList = LM.tSlice(menuList, i, j)
            local f = info.menuList[1].text
            local t = info.menuList[#info.menuList].text
            info.text = format('%s...%s', f, t)
            UIDropDownMenu_AddButton(info, level)
        end
    else
        for _,item in ipairs(menuList) do
            info.text = item.text
            info.arg1 = item.val
            info.arg2 = item.text
            if #item > 0 then
                info.hasArrow = true
                info.menuList = item
            else
                info.hasArrow = nil
                info.menuList = nil
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end


--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditConditionMixin = { }

function ConditionTypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = UIDropDownMenu_CreateInfo()
        info.minWidth = dropDown.owner:GetWidth() - 25 - 10
        info.func = function (button, arg1, arg2)
            dropDown.owner:GetParent():SetType(arg1)
        end
        info.text = NONE:upper()
        info.arg1 = nil
        UIDropDownMenu_AddButton(info, level)
        info.text = ALWAYS:upper()
        info.arg1 = ""
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        for _,item in ipairs(LM.Conditions:GetConditions()) do
            info.text = item.name
            info.arg1 = item.condition
            info.checked = dropDown.owner:GetParent():GetType() == item.condition
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LiteMountRuleEditConditionMixin.TypeButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    dropdown.owner = button
    UIDropDownMenu_Initialize(dropdown, ConditionTypeInitialize, 'MENU')
    UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
    ToggleDropDownMenu(1, nil, dropdown)
end

function LiteMountRuleEditConditionMixin.ArgButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    dropdown.owner = button
    local argType = button:GetParent().type

    UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
    local values = LM.Conditions:ArgsMenu(argType)
    if values then
        UIDropDownMenu_SetAnchor(dropdown, 5, 0, 'TOPLEFT', button, 'BOTTOMLEFT')
        ToggleDropDownMenu(1, nil, dropdown, nil, 0, 0, values)
        return
    end
end

function LiteMountRuleEditConditionMixin:GetType(arg)
    return self.type
end

local function OnTextChanged(self, info)
    local text = self:GetText()
    if info.validate and not info.validate(text) then
        self:SetTextColor(1,0.4,0.5)
        self:GetParent().arg = nil
    else
        self:SetTextColor(1,1,1)
        self:GetParent().arg = text
    end
end

function LiteMountRuleEditConditionMixin:Update()
    local info = LM.Conditions:GetCondition(self.type)

    if not info then
        if self.type == "" then
            self.TypeDropDown:SetText(ALWAYS:upper())
        else
            self.TypeDropDown:SetText(NONE:upper())
        end
    else
        self.TypeDropDown:SetText(info.name)
    end

    self.ArgDropDown:Hide()
    self.ArgText:Hide()

    if info then
        if info.menu then
            if self.arg then
                self.ArgDropDown:SetText(LM.Conditions:ArgsToString(self.arg))
            else
                self.ArgDropDown:SetText(nil)
            end
            self.ArgDropDown:Show()
        elseif info.validate then
            self.ArgText:SetText(self.arg or '')
            self.ArgText:Show()
        end
    end
end

function LiteMountRuleEditConditionMixin:SetType(type)
    if self.type ~= type then
        self.arg = nil
    end
    self.type = type
    self:Update()
end

function LiteMountRuleEditConditionMixin:SetArg(arg)
    self.arg = arg
    self:Update()
end

function LiteMountRuleEditConditionMixin:OnShow()
    self:Update()
end

function LiteMountRuleEditConditionMixin:OnLoad()
    self.NumText:SetText(self:GetID())
    self.TypeDropDown:SetScript('OnClick', self.TypeButtonClick)
    self.ArgDropDown:SetScript('OnClick', self.ArgButtonClick)
end


--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditActionMixin = {}

local TypeMenu = {
    "Mount",
    "SmartMount",
    "Limit",
    "LimitInclude",
    "LimitExclude",
}

function ActionTypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = UIDropDownMenu_CreateInfo()
        info.minWidth = dropDown.owner:GetWidth() - 25 - 10
        info.func = function (button, arg1, arg2)
            dropDown.owner:GetParent():SetType(arg1)
        end
        for _,item in ipairs(TypeMenu) do
            info.text = LM.Actions:ToString(item)
            info.arg1 = item
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LiteMountRuleEditActionMixin.TypeButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    dropdown.owner = button
    UIDropDownMenu_Initialize(dropdown, ActionTypeInitialize, 'MENU')
    UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
    ToggleDropDownMenu(1, nil, dropdown)
end

local function MountToInfo(m)
    return { val = m.spellID, text = m.name }
end

function LiteMountRuleEditActionMixin.ArgButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    dropdown.owner = button
    UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
    UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
    local values = LM.tMap(LM.PlayerMounts.mounts, MountToInfo)
    table.sort(values, function (a, b) return a.text < b.text end)
    ToggleDropDownMenu(1, nil, dropdown, nil, 0, 0, values)
end

function LiteMountRuleEditActionMixin:SetType(type)
    if self.type ~= type then
        self.arg = nil
    end
    self.type = type
    self:Update()
end

function LiteMountRuleEditActionMixin:Update()
    self.TypeDropDown:SetText(LM.Actions:ToString(self.type))

    if not self.type then
        self.ArgDropDown:Hide()
    else
        if self.arg then
            self.ArgDropDown:SetText(LM.Conditions:ArgsToString(self.arg))
        else
            self.ArgDropDown:SetText("")
        end
        self.ArgDropDown:Show()
    end
end

function LiteMountRuleEditActionMixin:OnLoad()
    self.TypeDropDown:SetScript('OnClick', self.TypeButtonClick)
    self.ArgDropDown:SetScript('OnClick', self.ArgButtonClick)
end

--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditMixin = {}
