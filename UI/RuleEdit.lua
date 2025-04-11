--[[----------------------------------------------------------------------------

  LiteMount/UI/Ruledit.lua

  Pop-over to edit a user rule.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

--[[------------------------------------------------------------------------]]--

-- Maximum height of dropdown menus before they scroll, 1/3 of screen. This
-- might be too small for 1080p screens, not sure.

local function GetScrollExtent()
    local _, y = GetPhysicalScreenSize()
    return math.floor(y/3)
end

--[[------------------------------------------------------------------------]]--


local function SetArgFromPickerFunction(owner)
    local parent = owner:GetParent()
    LiteMountPicker:SetParent(parent)
    LiteMountPicker:ClearAllPoints()
    LiteMountPicker:SetPoint("CENTER")
    LiteMountPicker:SetFrameLevel(parent:GetFrameLevel() + 3)
    LiteMountPicker:SetCallback(function (self, m) owner:SetArg(m.name) end, owner)
    LiteMountPicker:Show()
end

local function ArgsGenerate(dropdown, rootDescription, data)
    if not data then return end

    local parent = dropdown:GetParent()

    rootDescription:SetScrollMode(GetScrollExtent())

    for _,item in ipairs(data) do
        if item.val == 'PICKER' then
            rootDescription:CreateButton(item.text, function () SetArgFromPickerFunction(parent) end)
        elseif #item > 0 then
            local subMenu = rootDescription:CreateButton(item.text)
            subMenu:SetScrollMode(GetScrollExtent())
            ArgsGenerate(dropdown, subMenu, item)
        else
            rootDescription:CreateButton(item.text, function () parent:SetArg(item.val) end)
        end
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountRuleEditConditionMixin = { }

local function ConditionTypeGenerate(dropdown, rootDescription)
    local parent = dropdown:GetParent()

    rootDescription:SetScrollMode(GetScrollExtent())

    rootDescription:CreateCheckbox(NONE:upper(),
            function () return parent:GetType() == nil end,
            function () parent:SetType(nil) return MenuResponse.CloseAll end
        )

    rootDescription:CreateSpacer()

    for _, item in ipairs(LM.Conditions:GetConditions()) do
        local function checked() return item.condition == parent:GetType() end
        local function set() parent:SetType(item.condition) return MenuResponse.CloseAll end
        rootDescription:CreateCheckbox(item.name, checked, set)
    end

    rootDescription:CreateSpacer()

    rootDescription:CreateCheckbox(ADVANCED_LABEL,
            function () return parent:GetType() == "advanced" end,
            function () parent:SetType("advanced") return MenuResponse.CloseAll end
        )
end

local function ConditionArgGenerate(dropdown, rootDescription)
    local argType = dropdown:GetParent().type
    local values = LM.Conditions:ArgsMenu(argType)
    if values then
        ArgsGenerate(dropdown, rootDescription, values)
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
    self.NumText:SetText(self:GetID())
    self.Negated:SetScript('OnClick', ConditionNegatedClick)
    self.TypeDropDown:SetupMenu(ConditionTypeGenerate)
    self.ArgDropDown:SetupMenu(ConditionArgGenerate)
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

local function ActionTypeButtonGenerate(dropdown, rootDescription)
    rootDescription:SetScrollMode(GetScrollExtent())

    local parent = dropdown:GetParent()
    for _,item in ipairs(TypeMenu) do
        local text = LM.Actions:ToDisplay(item)
        local ttTitle = item.text
        local ttText = LM.Actions:GetDescription(item)
        local function checked() return parent.type == item end
        local function set() dropdown:GetParent():SetType(item) end
        local button = rootDescription:CreateCheckbox(text, checked, set)
        local function tt(tooltip)
            GameTooltip_SetTitle(tooltip, ttTitle)
            GameTooltip_AddNormalLine(tooltip, ttText)
        end
        button:SetTooltip(tt)
    end
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

local function ActionArgsGenerate(dropdown, rootDescription)
    local values = MountArgsMenu()
    if values then
        ArgsGenerate(dropdown, rootDescription, values)
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
    self.TypeDropDown:SetupMenu(ActionTypeButtonGenerate)
    self.TypeDropDown:SetScript('OnEnter', ActionTypeButtonOnEnter)
    self.TypeDropDown:SetScript('OnLeave', GameTooltip_Hide)
    self.ArgDropDown:SetupMenu(ActionArgsGenerate)
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
