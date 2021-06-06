--[[----------------------------------------------------------------------------

  LiteMount/UI/Ruledit.lua

  Pop-over to edit a user rule.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[--------------------------------------------------------------------------]]--

local TypesInfo = {
    {
        arg = "map",
        text = WORLD_MAP,
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
        arg="zone",
        text=ZONE,
    },
    {
        arg="flyable",
        text=LM.Rules:ExpandOneCondition("flyable"),
    },
    {
        arg="submerged",
        text=LM.Rules:ExpandOneCondition("submerged"),
    },
    {
        arg="mod",
        text="Modifer Key"
    },
    {
        arg="raw",
        text="Raw Condition Text"
    },
}

local function TypesInitialize(dropDown, level, menuList)
    if level == 1 then
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true
        info.func = function (button, arg1, arg2)
            dropDown.owner:SetType(arg1)
        end
        for _,item in ipairs(TypesInfo) do
            info.text = item.text
            info.arg1 = item.arg
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

local function MapInitialize(dropDown, level, menuList)
    local info = UIDropDownMenu_CreateInfo()

    info.notCheckable = true
    info.func = function (button, arg1, arg2)
                    print(UIDROPDOWNMENU_MENU_VALUE)
                end

    if menuList then
        for i, mapInfo in pairs(menuList) do
            info.text = string.format('%s (%d)', mapInfo.name, mapInfo.mapID)
            info.arg = mapInfo.mapID
            if mapInfo.children then
                info.hasArrow = true
                info.menuList = mapInfo.children
            else
                info.hasArrow = nil
                info.menuList = nil
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

local mapTree = LM.Environment:GetMapTree()

local function TypeButtonClick(self, mouseButton)
    local dropdown = self:GetParent().DropDown
    dropdown.owner = self:GetParent()
    UIDropDownMenu_Initialize(dropdown, MapInitialize, 'MENU')
    ToggleDropDownMenu(1, nil, dropdown, self, 74, 15, mapTree)
end

LiteMountRuleEditConditionMixin = { }

function LiteMountRuleEditConditionMixin:SetType(arg)
    local info
    for _, item in ipairs(TypesInfo) do
        if item.arg == arg then
            return
        end
    end
end

function LiteMountRuleEditConditionMixin:OnLoad()
    self.Type:SetScript('OnClick', TypeButtonClick)
end


--[[--------------------------------------------------------------------------]]--

LiteMountRuleEditMixin = {}
