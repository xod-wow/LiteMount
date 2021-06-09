--[[----------------------------------------------------------------------------

  LiteMount/UI/Ruledit.lua

  Pop-over to edit a user rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

local function tSlice(t, from, to)
    return { unpack(t, from, to) }
end

--[[--------------------------------------------------------------------------]]--

local function MapTreeToTypeInfo(node)
    local out = { val = "map:" .. node.mapID, text = string.format("%s (%d)", node.name, node.mapID) }
    for _, n in ipairs(node) do table.insert(out, MapTreeToTypeInfo(n))
    end
    return out
end

local function InstanceTypeInfo()
    local out = { }
    for id, name in pairs(LM.Environment:GetInstances()) do
        table.insert(out, { val = "instance:" .. id, text = string.format("%s (%d)", name, id) })
    end
    return out
end

local function LocationTypeInfo()
    local names = {}
    for i = 1, LM.Environment:MaxMapID() do
        local info = C_Map.GetMapInfo(i)
        if info and info.name ~= '' and info.mapType <= Enum.UIMapType.Zone then
            names[info.name] = true
        end
    end
    local out = {}
    for k in pairs(names) do
        table.insert(out, { val = "location:" .. k })
    end
    return out
end

local TypeInfo = {
    {
        type = "map",
        text = WORLD_MAP,
        values = MapTreeToTypeInfo(LM.Environment:GetMapTree()),
    },
    {
        type = "instance",
        text = INSTANCE,
        values = InstanceTypeInfo,
    },
    {
        type = "location",
        text = "Location",
        values = LocationTypeInfo,
        validate=function () return true end,
    },
    {
        type = "flyable",
        text=LM.Rules:ExpandOneCondition("flyable"),
    },
    {
        type = "class",
        text = CLASS,
        values = function ()
            local result = {
                { val = "class:" .. select(2, GetClassInfo(1)) },
                { val = "class:" .. select(2, GetClassInfo(2)) },
                { val = "class:" .. select(2, GetClassInfo(3)) },
                { val = "class:" .. select(2, GetClassInfo(4)) },
                { val = "class:" .. select(2, GetClassInfo(5)) },
                { val = "class:" .. select(2, GetClassInfo(6)) },
                { val = "class:" .. select(2, GetClassInfo(7)) },
                { val = "class:" .. select(2, GetClassInfo(8)) },
                { val = "class:" .. select(2, GetClassInfo(9)) },
                { val = "class:" .. select(2, GetClassInfo(10)) },
                { val = "class:" .. select(2, GetClassInfo(11)) },
                { val = "class:" .. select(2, GetClassInfo(12)) },
            }
            return result
        end,
    },
    {
        type = "faction",
        text = FACTION,
        values = {
            { val = "faction:" .. PLAYER_FACTION_GROUP[0], text = FACTION_LABELS[0] },
            { val = "faction:" .. PLAYER_FACTION_GROUP[1], text = FACTION_LABELS[1] },
        },
    },
    {
        type = "submerged",
        text = LM.Rules:ExpandOneCondition("submerged"),
    },
    {
        type = "mod",
        text = "Modifer Key",
        values = {
            { val = "mod:alt", text = ALT_KEY },
            { val = "mod:ctrl", text = CTRL_KEY },
            { val = "mod:shift", text = SHIFT_KEY },
        }
    },
    {
        type = "raw",
        text = "Raw Condition Text",
        validate = function (txt) return LM.Conditions:Validate(txt:gsub(':.*', '')) end,
    },
}

sort(TypeInfo, function (a,b) return a.text < b.text end)
table.insert(TypeInfo, 1, { text=ALWAYS, type="true" })
table.insert(TypeInfo, 1, { text=NONE:upper() })

local function GetTypeInfo(type)
    for _, info in ipairs(TypeInfo) do
        if info.type == type then
            return info
        end
    end
end

local function TypeInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = UIDropDownMenu_CreateInfo()
        info.func = function (button, arg1, arg2)
            dropDown.owner:GetParent():SetType(arg1)
        end
        for _,item in ipairs(TypeInfo) do
            info.minWidth = dropDown.owner:GetWidth() - 25 - 10
            info.text = item.text
            info.arg1 = item.type
            info.checked = dropDown.owner:GetParent():GetType() == item.type
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

-- UIDropDownMenu_SetAnchor(dropdown, xOffset, yOffset, point, relativeTo, relativePoint)
-- ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)


local function TypeButtonClick(self, mouseButton)
    local dropdown = self:GetParent().DropDown
    dropdown.owner = self
    UIDropDownMenu_Initialize(dropdown, TypeInitialize, 'MENU')
    UIDropDownMenu_SetAnchor(dropdown, 5, 5, 'TOPLEFT', self, 'BOTTOMLEFT')
    ToggleDropDownMenu(1, nil, dropdown)
end

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
            info.menuList = tSlice(menuList, i, j)
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

local function ArgButtonClick(self, mouseButton)
    local dropdown = self:GetParent().DropDown
    dropdown.owner = self
    local argType = self:GetParent().type

    local info = GetTypeInfo(argType)
    if info then
        UIDropDownMenu_Initialize(dropdown, ArgsInitialize, 'MENU')
        local values
        if type(info.values) == 'table' then
            values = info.values
        elseif type(info.values) == 'function' then
            values = info.values()
        end
        if values then
            for _,item in ipairs(values) do
                item.text = item.text or LM.Rules:ExpandOneCondition(item.val):gsub('^.-: ', '')
            end
            table.sort(values, function (a,b) return a.text < b.text end)
            UIDropDownMenu_SetAnchor(dropdown, 5, 0, 'TOPLEFT', self, 'BOTTOMLEFT')
            ToggleDropDownMenu(1, nil, dropdown, nil, 0, 0, values)
            return
        end
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountRuleEditConditionMixin = { }

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
    local info = GetTypeInfo(self.type)
    self.TypeDropDown:SetText(info.text)

    self.ArgDropDown:Hide()
    self.ArgText:Hide()

    if not info then return end

    if info.values then
        if self.arg then
            self.ArgDropDown:SetText(LM.Rules:ExpandOneCondition(self.arg):gsub('^.-: ', ''))
        else
            self.ArgDropDown:SetText(nil)
        end
        self.ArgDropDown:Show()
    elseif info.validate then
        self.ArgText:SetText(self.arg or "")
        self.ArgText:SetScript('OnTextChanged', function (f) OnTextChanged(f, info) end)
        self.ArgText:Show()
    end
end

function LiteMountRuleEditConditionMixin:SetType(type)
    local info = GetTypeInfo(type)
    if self.type ~= type then
        self.arg = nil
    end
    self.type = type
    if not info.values and not info.validate then
        self.arg = type
    end
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
    self.TypeDropDown:SetScript('OnClick', TypeButtonClick)
    self.ArgDropDown:SetScript('OnClick', ArgButtonClick)
end


--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditMixin = {}
