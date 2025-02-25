--[[----------------------------------------------------------------------------

  LiteMount/UI/Ruledit.lua

  Pop-over to edit a user rule.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

local LibDD = LibStub("LibUIDropDownMenu-4.0")

--[[------------------------------------------------------------------------]]--

local function SetArgFunction(button, arg1, owner)
    LibDD:CloseDropDownMenus(1)
    owner:SetArg(arg1)
end

local function SetArgFromPickerFunction(button, arg1, owner)
    local parent = owner:GetParent()

    LibDD:CloseDropDownMenus(1)
    LiteMountPicker:SetParent(parent)
    LiteMountPicker:ClearAllPoints()
    LiteMountPicker:SetPoint("CENTER")
    LiteMountPicker:SetFrameLevel(parent:GetFrameLevel() + 3)
    LiteMountPicker:SetCallback(function (self, m) owner:SetArg(m.name) end, owner)
    LiteMountPicker:Show()
end

local function ArgsInitialize(dropDown, level, menuList)
    if not menuList then return end

    local info = LibDD:UIDropDownMenu_CreateInfo()
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
            if i + stride <= #menuList then
                info.text = format("%s ...", f)
            else
                info.text = f
            end
            LibDD:UIDropDownMenu_AddButton(info, level)
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
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountRuleEditConditionMixin = { }

local function ConditionTypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = LibDD:UIDropDownMenu_CreateInfo()
        local currentType = dropDown:GetParent():GetType()
        -- info.minWidth = dropDown:GetParent():GetWidth() - 25 - 10
        info.func = function (button, arg1, owner)
            owner:SetType(arg1)
        end
        info.text = NONE:upper()
        info.arg1 = nil
        info.arg2 = dropDown:GetParent()
        info.checked = ( currentType == nil )
        LibDD:UIDropDownMenu_AddButton(info, level)
        LibDD:UIDropDownMenu_AddSeparator(level)
        for _,item in ipairs(LM.Conditions:GetConditions()) do
            info.text = item.name
            info.arg1 = item.condition
            info.checked = ( currentType == item.condition )
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
        LibDD:UIDropDownMenu_AddSeparator(level)
        info.text = ADVANCED_LABEL
        info.arg1 = "advanced"
        info.checked = ( currentType == "advanced" )
        LibDD:UIDropDownMenu_AddButton(info, level)
    end
end

local function ConditionTypeButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    LibDD:UIDropDownMenu_Initialize(dropdown, ConditionTypeInitialize, 'MENU')
    LibDD:UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
    LibDD:ToggleDropDownMenu(1, nil, dropdown)
end

local function ConditionArgButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    local argType = button:GetParent().type

    local values = LM.Conditions:ArgsMenu(argType)
    if values then
        LibDD:UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
        LibDD:UIDropDownMenu_SetAnchor(dropdown, 5, 0, 'TOPLEFT', button, 'BOTTOMLEFT')
        LibDD:ToggleDropDownMenu(1, nil, dropdown, nil, 0, 0, values)
        return
    end
end

local function ConditionNegatedClick(self)
    self:GetParent().isNegated = self:GetChecked()
end

function LiteMountRuleEditConditionMixin:GetType(arg)
    return self.type
end

function LiteMountRuleEditConditionMixin:SetCondition(condition)
    if not condition then
        self.type = nil
        self.arg = nil
        self.isNegated = nil
        return
    end

    if condition.op == 'NOT' then
        self.isNegated = true
        condition = condition.conditions[1]
    else
        self.isNegated = nil
    end

    local info = LM.Conditions:GetCondition(condition.condition)
    if info and info.name then
        self.type = condition.condition
        self.arg = condition:ToString():sub(2,-2)
    else
        self.type = "advanced"
        self.arg = condition:ToString():sub(2,-2)
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
            local text = select(2, LM.Conditions:ToDisplay(self.arg))
            self.ArgDropDown:SetText(text)
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
    LibDD:Create_UIDropDownMenu(self.DropDown)
    self.NumText:SetText(self:GetID())
    self.Negated:SetScript('OnClick', ConditionNegatedClick)
    self.TypeDropDown:SetScript('OnClick', ConditionTypeButtonClick)
    self.ArgDropDown:SetScript('OnClick', ConditionArgButtonClick)
    self.ArgText:SetScript('OnTextChanged', ConditionOnTextChanged)
end


--[[------------------------------------------------------------------------]]--

LiteMountRuleEditActionMixin = {}

local MountActionTypeMenu = {
    "SmartMount",
    "PriorityMount",
    "Mount",
    "LimitSet",
    "LimitInclude",
    "LimitExclude",
}

local TextActionTypeMenu = {
    "Spell",
    "Use",
    "PreCast",
    "PreUse",
}

local TypeMenu = LM.tJoin(MountActionTypeMenu, TextActionTypeMenu)

local function ActionTypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local currentType = dropDown:GetParent().type
        local info = LibDD:UIDropDownMenu_CreateInfo()
        -- info.minWidth = dropDown.owner:GetWidth() - 25 - 10
        info.func = function (button, arg1, owner)
            owner:SetType(arg1)
        end
        for _,item in ipairs(TypeMenu) do
            info.text = LM.Actions:ToDisplay(item)
            info.tooltipTitle = info.text
            info.tooltipText = LM.Actions:GetDescription(item)
            info.tooltipOnButton = true
            info.arg1 = item
            info.arg2 = dropDown:GetParent()
            info.checked = ( currentType == item )
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end

local function ActionTypeButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    LibDD:UIDropDownMenu_Initialize(dropdown, ActionTypeInitialize, 'MENU')
    LibDD:UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
    LibDD:ToggleDropDownMenu(1, nil, dropdown)
end

local function ActionTypeButtonOnEnter(button)
    local parent = button:GetParent()
    if parent.type then
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:AddLine(LM.Actions:GetDescription(parent.type), 1, 1, 1, true)
        GameTooltip:Show()
    end
end

local function ActionOnTextChanged(self)
    local text = self:GetText()
    if text == "" then
        self:GetParent():SetArg(nil)
    else
        self:GetParent():SetArg(text)
    end
end

local function MountToInfo(m) return { val = m.spellID, text = m.name } end
local function GroupToInfo(v) return { val = v, text = LM.UIFilter.GetGroupText(v) } end
local function FlagToInfo(v) return { val = v, text = LM.UIFilter.GetFlagText(v) } end
local function FamilyToInfo(v) return { val = "family:"..v, text = LM.UIFilter.GetFamilyText(v) } end
local function PriorityToInfo(v) return { val = "prio:"..v, text = LM.UIFilter.GetPriorityText(v) } end
local function TypeToInfo(v) return { val = "mt:"..v, text = LM.UIFilter.GetTypeText(v) } end

local function MountArgsMenu()
    local menuList = { nosort = true }

    local mountMenuList = { text=MOUNT, val="PICKER" }
    table.insert(menuList, mountMenuList)

    local groupMenuList = LM.tMap(LM.UIFilter.GetGroups(), GroupToInfo)
    groupMenuList.text = L.LM_GROUP
    table.insert(menuList, groupMenuList)

    local flagMenuList = LM.tMap(LM.UIFilter.GetFlags(), FlagToInfo)
    flagMenuList.text = TYPE
    table.insert(menuList, flagMenuList)

    local priorityMenuList = LM.tMap(LM.UIFilter.GetPriorities(), PriorityToInfo)
    priorityMenuList.text = L.LM_PRIORITY
    table.insert(menuList, priorityMenuList)

--  local typeMenuList = LM.tMap(LM.UIFilter.GetTypes(), TypeToInfo)
--  typeMenuList.text = TYPE
--  table.insert(menuList, typeMenuList)

--  local familyMenuList = LM.tMap(LM.UIFilter.GetFamilies(), FamilyToInfo)
--  familyMenuList.text = L.LM_FAMILY
--  table.insert(menuList, familyMenuList)

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        table.insert(menuList, { val = "ZONEMATCH", text = L.LM_ZONEMATCH })
    end

    table.insert(menuList, { val = "FAVORITES", text = FAVORITES:upper() })
    table.insert(menuList, { val = "ALL", text = ALL:upper() })
    table.insert(menuList, { val = "NONE", text = NONE:upper() })

    return menuList
end

local function ActionArgButtonClick(button, mouseButton)
    local dropdown = button:GetParent().DropDown
    -- local values = LM.tMap(LM.MountRegistry.mounts, MountToInfo)
    local values = MountArgsMenu()
    if values then
        LibDD:UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
        LibDD:UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', button, 'BOTTOMLEFT')
        LibDD:ToggleDropDownMenu(1, nil, dropdown, nil, 0, 0, values)
    end
end

function LiteMountRuleEditActionMixin:SetArg(arg)
    self.arg = arg
    self:GetParent():Update()
end

function LiteMountRuleEditActionMixin:SetType(type)
    if self.type ~= type then
        self.type = type
        self.arg = nil
    end
    self:GetParent():Update()
end

local actionHelp = DISABLED_FONT_COLOR:WrapTextInColorCode(LFGWIZARD_TITLE)

function LiteMountRuleEditActionMixin:Update()
    if not self.type then
        self.TypeDropDown:SetText(actionHelp)
        self.ArgDropDown:Hide()
        self.ArgText:Hide()
        return
    end

    local actionText, argText
    if self.arg then
        local args = LM.RuleArguments:Get(self.arg)
        actionText, argText = LM.Actions:ToDisplay(self.type, args)
    else
        actionText = LM.Actions:ToDisplay(self.type)
    end

    self.TypeDropDown:SetText(actionText)

    if tContains(TextActionTypeMenu, self.type) then
        self.ArgText:SetText(self.arg or '')
        self.ArgText:Show()
        self.ArgDropDown:Hide()
    else
        self.ArgDropDown:SetText(argText or "")
        self.ArgDropDown:Show()
        self.ArgText:Hide()
    end
end

function LiteMountRuleEditActionMixin:OnLoad()
    LibDD:Create_UIDropDownMenu(self.DropDown)
    self.TypeDropDown:SetScript('OnClick', ActionTypeButtonClick)
    self.TypeDropDown:SetScript('OnEnter', ActionTypeButtonOnEnter)
    self.TypeDropDown:SetScript('OnLeave', GameTooltip_Hide)
    self.ArgDropDown:SetScript('OnClick', ActionArgButtonClick)
    self.ArgText:SetScript('OnTextChanged', ActionOnTextChanged)
end

--[[------------------------------------------------------------------------]]--

LiteMountRuleEditMixin = {}

function LiteMountRuleEditMixin:IsValidCondition(n)
    local cFrame = self.Conditions[n]
    if not cFrame.type then
        return true
    end
    if cFrame.arg then
        return LM.Conditions:IsValidCondition(cFrame.arg)
    end
    local info = LM.Conditions:GetCondition(cFrame.type)
    if not info then
        return false
    elseif info.menu and not cFrame.arg then
        return false
    else
        return true
    end
end

function LiteMountRuleEditMixin:IsValidRule()
    if not self.Action.arg then return false end
    for i = 1, #self.Conditions do
        if not self:IsValidCondition(i) then return false end
    end
    return true
end

function LiteMountRuleEditMixin:MakeRule()
    if not self:IsValidRule() then return end

    local ruleTexts = { self.Action.type }

    local cTexts =  {}
    for _,cFrame in ipairs(self.Conditions) do
        if cFrame.type then
            if cFrame.isNegated then
                table.insert(cTexts, "no" .. (cFrame.arg or cFrame.type))
            else
                table.insert(cTexts, cFrame.arg or cFrame.type)
            end
        end
    end

    if #cTexts > 0 then
        table.insert(ruleTexts, '[' .. table.concat(cTexts, ',') .. ']')
    end

    -- This is super ugly. Support mounts with commas and slashes in the name.
    -- Note that there is no way for a mount to have a double quote in the
    -- name (neither here nor in the rule parsing).

    if self.Action.arg:find('[,/]') then
        table.insert(ruleTexts, '"' .. self.Action.arg .. '"')
    else
        table.insert(ruleTexts, self.Action.arg)
    end

    return table.concat(ruleTexts, ' ')
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
    LibDD:Create_UIDropDownMenu(self.DropDown)
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

function LiteMountRuleEditMixin:SetRule(ruletext)
    local rule = LM.Rule:ParseLine(ruletext)

    local conditions = rule.conditions:GetSimpleConditions()

    for i,cFrame in ipairs(self.Conditions) do
        if conditions[i] then
            cFrame:SetCondition(conditions[i])
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
