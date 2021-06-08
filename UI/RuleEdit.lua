--[[----------------------------------------------------------------------------

  LiteMount/UI/Ruledit.lua

  Pop-over to edit a user rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[--------------------------------------------------------------------------]]--

local function MapTreeToTypeInfo(node)
    local out = { val = "map:" .. node.mapID, text = node.name }
    for _, n in ipairs(node) do table.insert(out, MapTreeToTypeInfo(n))
    end
    return out
end

local TypeInfo = {
    {
        arg = "map",
        text = WORLD_MAP,
        values = MapTreeToTypeInfo(LM.Environment:GetMapTree()),
    },
    {
        arg="instance",
        text=INSTANCE,
    },
    {
        arg="location",
        text="Location",
    },
    {
        arg="flyable",
        text=LM.Rules:ExpandOneCondition("flyable"),
    },
    {
        arg="class",
        text=CLASS,
        values = function ()
            local result = {
                { val = "class:" .. select(2, GetClassInfo(1)), text = GetClassInfo(1) },
                { val = "class:" .. select(2, GetClassInfo(2)), text = GetClassInfo(2) },
                { val = "class:" .. select(2, GetClassInfo(3)), text = GetClassInfo(3) },
                { val = "class:" .. select(2, GetClassInfo(4)), text = GetClassInfo(4) },
                { val = "class:" .. select(2, GetClassInfo(5)), text = GetClassInfo(5) },
                { val = "class:" .. select(2, GetClassInfo(6)), text = GetClassInfo(6) },
                { val = "class:" .. select(2, GetClassInfo(7)), text = GetClassInfo(7) },
                { val = "class:" .. select(2, GetClassInfo(8)), text = GetClassInfo(8) },
                { val = "class:" .. select(2, GetClassInfo(9)), text = GetClassInfo(9) },
                { val = "class:" .. select(2, GetClassInfo(10)), text = GetClassInfo(10) },
                { val = "class:" .. select(2, GetClassInfo(11)), text = GetClassInfo(11) },
                { val = "class:" .. select(2, GetClassInfo(12)), text = GetClassInfo(12) },
            }
            sort(result, function (a, b) return a.text < b.text end)
            return result
        end,
    },
    {
        arg = "faction",
        text = FACTION,
        values = {
            { val = "faction:" .. PLAYER_FACTION_GROUP[0], text = FACTION_LABELS[0] },
            { val = "faction:" .. PLAYER_FACTION_GROUP[1], text = FACTION_LABELS[1] },
        },
    },
    {
        arg="submerged",
        text=LM.Rules:ExpandOneCondition("submerged"),
    },
    {
        arg = "mod",
        text = "Modifer Key",
        values = {
            { val = "mod:alt", text = ALT_KEY },
            { val = "mod:ctrl", text = CTRL_KEY },
            { val = "mod:shift", text = SHIFT_KEY },
        }
    },
    {
        arg="raw",
        text="Raw Condition Text"
    },
}

local function GetTypeInfo(arg)
    for _, info in ipairs(TypeInfo) do
        if info.arg == arg then
            return info
        end
    end
end

local function TypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = UIDropDownMenu_CreateInfo()
        info.func = function (button, arg1, arg2)
            dropDown.owner:SetType(arg1, arg2)
        end
        for _,item in ipairs(TypeInfo) do
            info.text = item.text
            info.arg1 = item.arg
            info.arg2 = item.text
            info.checked = dropDown.owner:GetType() == item.arg
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

local function TypeButtonClick(self, mouseButton)
    local dropdown = self:GetParent().DropDown
    dropdown.owner = self:GetParent()
    UIDropDownMenu_Initialize(dropdown, TypeInitialize, 'MENU')
    ToggleDropDownMenu(1, nil, dropdown, self, 16, 0)
end

local function ArgsInitialize(dropDown, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.func = function (button, arg1, arg2)
                    dropDown.owner:SetArg(arg1, arg2)
                    CloseDropDownMenus(1)
                end

    if menuList then
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

local function ArgButtonClick(self, mouseButton)
    local dropdown = self:GetParent().DropDown
    dropdown.owner = self:GetParent()
    local argType = self:GetParent().type

    for _, t in pairs(TypeInfo) do
        if t.arg == argType then
            UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
            if type(t.values) == 'table' then
                ToggleDropDownMenu(1, nil, dropdown, self, 0, 0, t.values)
            elseif type(t.values) == 'function' then
                ToggleDropDownMenu(1, nil, dropdown, self, 0, 0, t.values())
            end
        end
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountRuleEditConditionMixin = { }

function LiteMountRuleEditConditionMixin:GetType(arg)
    return self.type
end

function LiteMountRuleEditConditionMixin:Update()
    self.Type:SetText(self.typeText)
    if self.arg then
        self.ArgDropDown:SetText(LM.Rules:ExpandOneCondition(self.arg))
    else
        self.ArgDropDown:SetText(nil)
    end
end

function LiteMountRuleEditConditionMixin:SetType(type, text)
    local info = GetTypeInfo(type)
    if not info.values then
        self.arg = info.arg
    elseif self.type ~= type then
        self.arg = nil
    end
    self.type = type
    self.typeText = text
    self:Update()
end

function LiteMountRuleEditConditionMixin:SetArg(arg)
    self.arg = arg
    self:Update()
end

function LiteMountRuleEditConditionMixin:OnLoad()
    self.Type:SetScript('OnClick', TypeButtonClick)
    self.ArgDropDown:SetScript('OnClick', ArgButtonClick)
end


--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditMixin = {}
