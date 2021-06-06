--[[----------------------------------------------------------------------------

  LiteMount/UI/LMDropDown.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

--[[------------------------------------------------------------------------]]--

local function tSlice(t, from, to)
    return { unpack(t, from, to) }
end

LM.UIDropDown = {}

local function InitDropDownSection(self, template, level, menuList)

    local info = UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true
    info.isNotRadio = true

    if level == 1 then
        if not template.menulist then
            info.text = template.text
            info.func = function (_, _, _, v) template.set(v) end
            info.checked = function () return template.checked() end
            UIDropDownMenu_AddButton(info, level)
        else
            info.hasArrow = true
            info.notCheckable = true
            info.text = template.text
            info.value = template.value
            info.menuList = template.menulist()
            UIDropDownMenu_AddButton(info, level)
        end
        return
    end

    if level == 2 then
        info.notCheckable = true
        info.text = CHECK_ALL
        info.func = function ()
                template.setall(true)
                UIDropDownMenu_Refresh(self, nil, level)
            end
        UIDropDownMenu_AddButton(info, level)

        info.text = UNCHECK_ALL
        info.func = function ()
                template.setall(false)
                UIDropDownMenu_Refresh(self, nil, level)
            end
        UIDropDownMenu_AddButton(info, level)

        -- UIDropDownMenu_AddSeparator(level)
    end

    info.notCheckable = nil

    if #menuList > MENU_SPLIT_SIZE * 1.5 then
        info.notCheckable = true
        info.hasArrow = true
        info.func = nil
        for i = 1, #menuList, MENU_SPLIT_SIZE do
            local j = math.min(#menuList, i+MENU_SPLIT_SIZE-1)
            info.menuList = tSlice(menuList, i, j)
            local f = template.gettext(info.menuList[1])
            local t = template.gettext(info.menuList[#info.menuList])
            info.text = format('%s...%s', f, t)
            info.value = template.value
            UIDropDownMenu_AddButton(info, level)
        end
    else
        for _, k in ipairs(menuList) do
            info.text = template.gettext(k)
            info.arg1 = k
            info.func = function (_, _, _, v)
                    if IsShiftKeyDown() then
                        template.setall(false)
                        template.set(k, true)
                    else
                        template.set(k, v)
                    end
                    UIDropDownMenu_Refresh(self, nil, level)
                end
            info.checked = function ()
                    return template.checked(k)
                end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LM.UIDropDown.Initialize(frame, DROPDOWNS, level, menuList)
    if level == nil then return end

    if level == 1 then
        for _, section in ipairs(DROPDOWNS) do
            InitDropDownSection(fraem, section, level, menuList)
        end
    else
        for _, section in ipairs(DROPDOWNS) do
            if section.value == UIDROPDOWNMENU_MENU_VALUE then
                InitDropDownSection(frame, section, level, menuList)
                return
            end
        end
    end
end
