--[[----------------------------------------------------------------------------

  LiteMount/UI/Ruledit.lua

  Pop-over to edit a user rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

--[[--------------------------------------------------------------------------]]--

local function SetArgFunction(button, arg1, owner)
    CloseDropDownMenus(1)
    owner:SetArg(arg1)
end

local function SetArgFromPickerFunction(button, arg1, owner)
    local parent = owner:GetParent()

    CloseDropDownMenus(1)
    LiteMountPicker:SetParent(parent)
    LiteMountPicker:ClearAllPoints()
    LiteMountPicker:SetPoint("CENTER")
    LiteMountPicker:SetFrameLevel(parent:GetFrameLevel() + 3)
    LiteMountPicker:SetCallback(function (self, m) owner:SetArg(m.name) end, owner)
    LiteMountPicker:Show()
end

local function ArgsInitialize(dropDown, level, menuList)
    if not menuList then return end

    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true

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
        info.arg2 = dropDown:GetParent()
        for _,item in ipairs(menuList) do
            if item.val == 'PICKER' then
                info.func = SetArgFromPickerFunction
            else
                info.func = SetArgFunction
            end
            info.text = item.text
            info.arg1 = item.val
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

local function ConditionTypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = UIDropDownMenu_CreateInfo()
        local currentType = dropDown:GetParent():GetType()
        -- info.minWidth = dropDown:GetParent():GetWidth() - 25 - 10
        info.func = function (button, arg1, owner)
            owner:SetType(arg1)
        end
        info.text = NONE:upper()
        info.arg1 = nil
        info.arg2 = dropDown:GetParent()
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        for _,item in ipairs(LM.Conditions:GetConditions()) do
            info.text = item.name
            info.arg1 = item.condition
            info.checked = currentType == item.condition
            UIDropDownMenu_AddButton(info, level)
        end
        UIDropDownMenu_AddSeparator(level)
        info.text = ADVANCED_LABEL
        info.arg1 = "advanced"
        info.checked = currentType == "advanced"
        UIDropDownMenu_AddButton(info, level)
    end
end

local function ConditionTypeButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    UIDropDownMenu_Initialize(dropdown, ConditionTypeInitialize, 'MENU')
    UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
    ToggleDropDownMenu(1, nil, dropdown)
end

local function ConditionArgButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    local argType = button:GetParent().type

    local values = LM.Conditions:ArgsMenu(argType)
    if values then
        UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
        UIDropDownMenu_SetAnchor(dropdown, 5, 0, 'TOPLEFT', button, 'BOTTOMLEFT')
        ToggleDropDownMenu(1, nil, dropdown, nil, 0, 0, values)
        return
    end
end

local function ConditionNegatedClick(self)
    self:GetParent().isNegated = self:GetChecked()
end

function LiteMountRuleEditConditionMixin:GetType(arg)
    return self.type
end

function LiteMountRuleEditConditionMixin:IsValidCondition()
    if self.type == "advanced" then
        if not self.arg or self.arg == "" then return false end
        return LM.Conditions:ArgsToString(self.arg) ~= nil
    else
        local info = LM.Conditions:GetCondition(self.type)
        if not info then return false end
        if info.menu and not self.arg then return false end
        if info.validate and not self.arg then return false end
        return true
    end
end

function LiteMountRuleEditConditionMixin:SetCondition(condition)
    if not condition then
        self.type = nil
        self.arg = nil
        self.isNegated = nil
        return
    end

    if type(condition) == 'table' then
        self.isNegated = true
        condition = condition[1]
    end

    local type = string.split(':', condition)

    local info = LM.Conditions:GetCondition(type)
    if info and info.name then
        self.type = type
        self.arg = condition
    else
        self.type = "advanced"
        self.arg = condition
    end
end

local function ConditionOnTextChanged(self)
    local text = self:GetText()
    if text == "" then
        self:GetParent():SetArg(nil)
    else
        self:GetParent():SetArg(text)
    end
end

local conditionHelp = DISABLED_FONT_COLOR:WrapTextInColorCode(NONE:upper())

function LiteMountRuleEditConditionMixin:Update()
    local info = LM.Conditions:GetCondition(self.type)

    self.Negated:SetChecked(self.isNegated)

    if not self.type then
        self.TypeDropDown:SetText(conditionHelp)
        self.ArgDropDown:Hide()
        self.ArgText:Hide()
    elseif self.type == "advanced" then
        self.TypeDropDown:SetText(ADVANCED_LABEL)
        self.ArgText:SetText(self.arg or "")
        self.ArgText:Show()
        self.ArgDropDown:Hide()
    elseif info.menu then
        self.TypeDropDown:SetText(info.name)
        if self.arg then
            self.ArgDropDown:SetText(LM.Conditions:ArgsToString(self.arg))
        else
            self.ArgDropDown:SetText("")
        end
        self.ArgDropDown:Show()
        self.ArgText:Hide()
    else
        self.TypeDropDown:SetText(info.name)
        self.ArgDropDown:Hide()
        self.ArgText:Hide()
    end
end

function LiteMountRuleEditConditionMixin:SetType(type)
    if self.type ~= type then
        self.arg = nil
    end
    self.type = type
    self:GetParent():Update()
end

function LiteMountRuleEditConditionMixin:SetArg(arg)
    self.arg = arg
    self:GetParent():Update()
end

function LiteMountRuleEditConditionMixin:OnLoad()
    self.NumText:SetText(self:GetID())
    self.Negated:SetScript('OnClick', ConditionNegatedClick)
    self.TypeDropDown:SetScript('OnClick', ConditionTypeButtonClick)
    self.ArgDropDown:SetScript('OnClick', ConditionArgButtonClick)
    self.ArgText:SetScript('OnTextChanged', ConditionOnTextChanged)
end


--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditActionMixin = {}

local TypeMenu = {
    "SmartMount",
    "Mount",
    "Limit",
    "LimitInclude",
    "LimitExclude",
}

local function ActionTypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = UIDropDownMenu_CreateInfo()
        -- info.minWidth = dropDown.owner:GetWidth() - 25 - 10
        info.func = function (button, arg1, owner)
            owner:SetType(arg1)
        end
        for _,item in ipairs(TypeMenu) do
            info.text = LM.Actions:ToString(item)
            info.arg1 = item
            info.arg2 = dropDown:GetParent()
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

local function ActionTypeButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    UIDropDownMenu_Initialize(dropdown, ActionTypeInitialize, 'MENU')
    UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
    ToggleDropDownMenu(1, nil, dropdown)
end

local function MountToInfo(m) return { val = m.spellID, text = m.name } end
local function GroupToInfo(v) return { val = v, text = LM.UIFilter.GetGroupText(v) } end
local function FlagToInfo(v) return { val = v, text = LM.UIFilter.GetFlagText(v) } end
local function FamilyToInfo(v) return { val = "family:"..v, text = LM.UIFilter.GetFamilyText(v) } end
local function TypeToInfo(v) return { val = "mt:"..v, text = LM.UIFilter.GetTypeText(v) } end

local function ActionArgsMenu()
    local groupMenuList = LM.tMap(LM.UIFilter.GetGroups(), GroupToInfo)
    groupMenuList.text = GROUP

    local familyMenuList = LM.tMap(LM.UIFilter.GetFamilies(), FamilyToInfo)
    familyMenuList.text = L.LM_FAMILY

    local typeMenuList = LM.tMap(LM.UIFilter.GetTypes(), TypeToInfo)
    typeMenuList.text = TYPE

    local flagMenuList = LM.tMap(LM.UIFilter.GetFlags(), FlagToInfo)
    flagMenuList.text = L.LM_FLAG

    local mountMenuList = { text=MOUNT, val="PICKER" }

    return {
        nosort = true,
        mountMenuList,
        groupMenuList,
        flagMenuList,
        typeMenuList,
        familyMenuList,
        { val = "NONE", text = NONE:upper() },
    }
end

local function ActionArgButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    -- local values = LM.tMap(LM.PlayerMounts.mounts, MountToInfo)
    local values = ActionArgsMenu()
    if values then
        UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
        UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
        ToggleDropDownMenu(1, nil, dropdown, nil, 0, 0, values)
    end
end

function LiteMountRuleEditActionMixin:SetArg(arg)
    self.arg = arg
    self:GetParent():Update()
end

function LiteMountRuleEditActionMixin:SetType(type)
    -- XXX reset arg if arg type is ever differen XXX
    -- if self.type ~= type then self.arg = nil end
    self.type = type
    self:GetParent():Update()
end

local actionHelp = DISABLED_FONT_COLOR:WrapTextInColorCode(LFGWIZARD_TITLE)

function LiteMountRuleEditActionMixin:Update()
    self.TypeDropDown:SetText(LM.Actions:ToString(self.type))

    if not self.type then
        self.TypeDropDown:SetText(actionHelp)
        self.ArgDropDown:Hide()
    else
        if self.arg then
            local text = LM.Actions:ArgsToString(self.type, { self.arg })
            self.ArgDropDown:SetText(text)
        else
            self.ArgDropDown:SetText("")
        end
        self.ArgDropDown:Show()
    end
end

function LiteMountRuleEditActionMixin:OnLoad()
    self.TypeDropDown:SetScript('OnClick', ActionTypeButtonClick)
    self.ArgDropDown:SetScript('OnClick', ActionArgButtonClick)
end

--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditMixin = {}

function LiteMountRuleEditMixin:IsValidRule()
    if not self.Action.arg then return false end
    for _, cFrame in ipairs(self.Conditions) do
        if cFrame.type then
            if not cFrame:IsValidCondition() then
                return false
            end
        end
    end
    return true
end

function LiteMountRuleEditMixin:MakeRule()
    if not self:IsValidRule() then return end

    local rule = {
        action      = self.Action.type,
        args        = { self.Action.arg },
        conditions  = { op="AND" },
    }

    for _,cFrame in ipairs(self.Conditions) do
        if cFrame.isNegated then
            table.insert(rule.conditions, { op="NOT", cFrame.arg or cFrame.type })
        else
            table.insert(rule.conditions, cFrame.arg or cFrame.type)
        end
    end

    if #rule.conditions == 0 then
        rule.conditions = nil
    end

    return rule
end

function LiteMountRuleEditMixin:Cancel()
    self:Hide()
end

function LiteMountRuleEditMixin:Okay()
    if self.callback then
        local rule = self:MakeRule()
        if rule then
            self.callback(self.callbackFrame, rule)
        end
    end
    self:Hide()
end

function LiteMountRuleEditMixin:OnLoad()
    LiteMountOptionsPanel_AutoLocalize(self)
    for i = 2, #self.Conditions do
        self.Conditions[i]:SetPoint('TOPLEFT', self.Conditions[i-1], 'BOTTOMLEFT', 0, -4)
        self.Conditions[i]:SetPoint('RIGHT', self.Conditions[i-1], 'RIGHT')
    end
end

function LiteMountRuleEditMixin:SetCallback(callback, frame)
    self.callback = callback
    self.callbackFrame = frame
end

function LiteMountRuleEditMixin:Clear()
    for _,cFrame in ipairs(self.Conditions) do
        cFrame:SetCondition(nil)
    end
    self.Action.type = nil
    self.Action.arg = nil
end

function LiteMountRuleEditMixin:SetRule(rule)
    for i,cFrame in ipairs(self.Conditions) do
        if rule.conditions then
            cFrame:SetCondition(rule.conditions[i])
        else
            cFrame:SetCondition(nil)
        end
    end

    self.Action.type = rule.action
    self.Action.arg = rule.args[1]
end

function LiteMountRuleEditMixin:Update()
    self.Action:Update()
    LM.tMap(self.Conditions, function (f) f:Update() end)

    if self:IsValidRule() then
        self.OkayButton:Enable()
    else
        self.OkayButton:Disable()
    end
end

function LiteMountRuleEditMixin:OnShow()
    self:Update()
end

function LiteMountRuleEditMixin:OnHide()
    self.callback = nil
    self.callbackFrame = nil
    LiteMountPicker:Hide()
end
