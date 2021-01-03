--[[----------------------------------------------------------------------------

  LiteMount/UI/MountsFilter.lua

  Options frame for the mount list.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

--[[------------------------------------------------------------------------]]--

local function tSlice(t, from, to)
    return { unpack(t, from, to) }
end

--[[------------------------------------------------------------------------]]--

LiteMountFilterMixin = {}

function LiteMountFilterMixin:OnLoad()
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "Update")
end

function LiteMountFilterMixin:Update()
    if LM.UIFilter.IsFiltered() then
        self.FilterButton.ClearButton:Show()
    else
        self.FilterButton.ClearButton:Hide()
    end
end

function LiteMountFilterMixin:Attach(parent, fromPoint, frame, toPoint, xOff, yOff)
    self:SetParent(parent)
    self:ClearAllPoints()
    self:SetPoint(fromPoint, frame, toPoint, xOff, yOff)
end

--[[------------------------------------------------------------------------]]--

LiteMountSearchBoxMixin = {}

function LiteMountSearchBoxMixin:OnTextChanged()
    SearchBoxTemplate_OnTextChanged(self)
    LM.UIFilter.SetSearchText(self:GetText())
end

--[[------------------------------------------------------------------------]]--

LiteMountFilterClearMixin = {}

function LiteMountFilterClearMixin:OnClick()
    LM.UIFilter.Clear()
end

--[[------------------------------------------------------------------------]]--

LiteMountFilterButtonMixin = {}

function LiteMountFilterButtonMixin:OnClick()
    ToggleDropDownMenu(1, nil, self.FilterDropDown, self, 74, 15)
end

local DROPDOWNS = {
    ['COLLECTED'] = {
        value = 'COLLECTED',
        text = COLLECTED,
        checked = function () return LM.UIFilter.IsFlagChecked("COLLECTED") end,
        set = function (v) LM.UIFilter.SetFlagFilter("COLLECTED", v) end
    },
    ['NOT_COLLECTED'] = {
        value = 'NOT_COLLECTED',
        text = NOT_COLLECTED,
        checked = function () return LM.UIFilter.IsFlagChecked("NOT_COLLECTED") end,
        set = function (v) LM.UIFilter.SetFlagFilter("NOT_COLLECTED", v) end
    },
    ['UNUSABLE'] = {
        value = 'UNUSABLE',
        text = MOUNT_JOURNAL_FILTER_UNUSABLE,
        checked = function () return LM.UIFilter.IsFlagChecked("UNUSABLE") end,
        set = function (v) LM.UIFilter.SetFlagFilter("UNUSABLE", v) end
    },
    ['HIDDEN'] = {
        value = 'HIDDEN',
        text = L.LM_HIDDEN,
        checked = function () return LM.UIFilter.IsFlagChecked("HIDDEN") end,
        set = function (v) LM.UIFilter.SetFlagFilter("HIDDEN", v) end
    },
    ['PRIORITY'] = {
        value = 'PRIORITY',
        text = L.LM_PRIORITY,
        checked = function (k) return LM.UIFilter.IsPriorityChecked(k) end,
        set = function (k, v) LM.UIFilter.SetPriorityFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllPriorityFilters(v) end,
        menulist = function () return LM.UIFilter.GetPriorities() end,
        gettext = function (k) return LM.UIFilter.GetPriorityText(k) end,
    },
    ['FLAGS'] = {
        value = 'FLAGS',
        text = L.LM_FLAGS,
        checked = function (k) return LM.UIFilter.IsFlagChecked(k) end,
        set = function (k, v) LM.UIFilter.SetFlagFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllFlagFilters(v) end,
        menulist = function () return LM.UIFilter.GetFlags() end,
        gettext = function (k) return LM.UIFilter.GetFlagText(k) end,
    },
    ['FAMILY'] = {
        value = 'FAMILY',
        text = L.LM_FAMILY,
        checked = function (k) return LM.UIFilter.IsFamilyChecked(k) end,
        set = function (k, v) LM.UIFilter.SetFamilyFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllFamilyFilters(v) end,
        menulist = function () return LM.UIFilter.GetFamilies() end,
        gettext = function (k) return LM.UIFilter.GetFamilyText(k) end,
    },
    ['SOURCES'] = {
        value = 'SOURCES',
        text = SOURCES,
        checked = function (k) return LM.UIFilter.IsSourceChecked(k) end,
        set = function (k, v) LM.UIFilter.SetSourceFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllSourceFilters(v) end,
        menulist = function () return LM.UIFilter.GetSources() end,
        gettext = function (k) return LM.UIFilter.GetSourceText(k) end,
    },
}

local function InitDropDownSection(template, self, level, menuList)

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

function LiteMountFilterButtonMixin:Initialize(level, menuList)
    if level == nil then return end

    if level == 1 then
        ---- 1. COLLECTED ----
        InitDropDownSection(DROPDOWNS.COLLECTED, self, level, menuList)

        ---- 2. NOT COLLECTED ----
        InitDropDownSection(DROPDOWNS.NOT_COLLECTED, self, level, menuList)

        ---- 3. UNUSABLE ----
        InitDropDownSection(DROPDOWNS.UNUSABLE, self, level, menuList)

        ---- 4. HIDDEN ----
        InitDropDownSection(DROPDOWNS.HIDDEN, self, level, menuList)

        ---- 5. PRIORITY ----
        InitDropDownSection(DROPDOWNS.PRIORITY, self, level, menuList)

        ---- 6. FLAGS ----
        InitDropDownSection(DROPDOWNS.FLAGS, self, level, menuList)

        ---- 7. FAMILY ----
        InitDropDownSection(DROPDOWNS.FAMILY, self, level, menuList)

        ---- 8. SOURCES ----
        InitDropDownSection(DROPDOWNS.SOURCES, self, level, menuList)
    else
        InitDropDownSection(DROPDOWNS[UIDROPDOWNMENU_MENU_VALUE], self, level, menuList)
    end
end

function LiteMountFilterButtonMixin:OnLoad()
    UIDropDownMenu_Initialize(self.FilterDropDown, self.Initialize, "MENU")
end
