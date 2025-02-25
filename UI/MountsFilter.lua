--[[----------------------------------------------------------------------------

  LiteMount/UI/MountsFilter.lua

  Options frame for the mount list.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local LibDD = LibStub("LibUIDropDownMenu-4.0")

local MENU_SPLIT_SIZE = 20

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
    self.Search:SetFocus()
    self:Show()
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
    LibDD:ToggleDropDownMenu(1, nil, self.FilterDropDown, self, 74, 15)
end

local DROPDOWNS = {
    ['COLLECTED'] = {
        value = 'COLLECTED',
        text = COLLECTED,
        checked = function () return LM.UIFilter.IsOtherChecked("COLLECTED") end,
        set = function (v) LM.UIFilter.SetOtherFilter("COLLECTED", v) end
    },
    ['NOT_COLLECTED'] = {
        value = 'NOT_COLLECTED',
        text = NOT_COLLECTED,
        checked = function () return LM.UIFilter.IsOtherChecked("NOT_COLLECTED") end,
        set = function (v) LM.UIFilter.SetOtherFilter("NOT_COLLECTED", v) end
    },
    ['UNUSABLE'] = {
        value = 'UNUSABLE',
        text = MOUNT_JOURNAL_FILTER_UNUSABLE,
        checked = function () return LM.UIFilter.IsOtherChecked("UNUSABLE") end,
        set = function (v) LM.UIFilter.SetOtherFilter("UNUSABLE", v) end
    },
    ['HIDDEN'] = {
        value = 'HIDDEN',
        text = L.LM_HIDDEN,
        checked = function () return LM.UIFilter.IsOtherChecked("HIDDEN") end,
        set = function (v) LM.UIFilter.SetOtherFilter("HIDDEN", v) end
    },
    ['ZONEMATCH'] = {
        value = 'ZONEMATCH',
        text = L.LM_ZONEMATCH,
        checked = function () return LM.UIFilter.IsOtherChecked("ZONEMATCH") end,
        set = function (v) LM.UIFilter.SetOtherFilter("ZONEMATCH", v) end
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
    ['TYPENAME'] = {
        value = 'TYPENAME',
        text = string.format('%s (%s)', TYPE, ID),
        checked = function (k) return LM.UIFilter.IsTypeNameChecked(k) end,
        set = function (k, v) LM.UIFilter.SetTypeNameFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllTypeNameFilters(v) end,
        menulist = function () return LM.UIFilter.GetTypeNames() end,
        gettext = function (k) return LM.UIFilter.GetTypeNameText(k) end,
    },
    ['GROUP'] = {
        value = 'GROUP',
        text = L.LM_GROUP,
        checked = function (k) return LM.UIFilter.IsGroupChecked(k) end,
        set = function (k, v) LM.UIFilter.SetGroupFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllGroupFilters(v) end,
        menulist = function () return LM.UIFilter.GetGroups() end,
        gettext = function (k) return LM.UIFilter.GetGroupText(k) end,
    },
    ['FLAG'] = {
        value = 'FLAG',
        text = TYPE,
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
    ['SORTBY'] = {
        value = 'SORTBY',
        text = BLUE_FONT_COLOR:WrapTextInColorCode(RAID_FRAME_SORT_LABEL),
        checked = function (k) return LM.UIFilter.GetSortKey() == k end,
        set = function (k) LM.UIFilter.SetSortKey(k) end,
        menulist = function () return LM.UIFilter.GetSortKeys() end,
        gettext = function (k) return LM.UIFilter.GetSortKeyText(k) end,
    },
}

local function InitDropDownSection(template, self, level, menuList)

    local info = LibDD:UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true
    info.isNotRadio = true

    if level == 1 then
        if not template.menulist then
            info.text = template.text
            info.func = function (_, _, _, v) template.set(v) end
            info.checked = function () return template.checked() end
            LibDD:UIDropDownMenu_AddButton(info, level)
        else
            info.hasArrow = true
            info.notCheckable = true
            info.text = template.text
            info.value = template.value
            info.menuList = template.menulist()
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
        return
    end

    if level == 2 and template.setall then
        info.notCheckable = true
        info.text = CHECK_ALL
        info.func = function ()
                template.setall(true)
                LibDD:UIDropDownMenu_Refresh(self, nil, level)
            end
        LibDD:UIDropDownMenu_AddButton(info, level)

        info.text = UNCHECK_ALL
        info.func = function ()
                template.setall(false)
                LibDD:UIDropDownMenu_Refresh(self, nil, level)
            end
        LibDD:UIDropDownMenu_AddButton(info, level)

        -- UIDropDownMenu_AddSeparator(level)
    end

    info.notCheckable = nil

    -- The complicated stride calc is because the %s...%s entries are super
    -- annoying and so we want to max out the number of entries in the leafs
    -- but still need to make sure each menu is small enough.

    if #menuList > MENU_SPLIT_SIZE * 1.5 then
        info.notCheckable = true
        info.hasArrow = true
        info.func = nil

        local stride = 1
        while #menuList/stride > MENU_SPLIT_SIZE do stride = stride * MENU_SPLIT_SIZE end

        for i = 1, #menuList, stride do
            local j = math.min(#menuList, i+stride-1)
            info.menuList = LM.tSlice(menuList, i, j)
            local f = template.gettext(info.menuList[1])
            if i + stride < #menuList then
                info.text = f .. " ..."
            else
                info.text = f
            end
            --local t = template.gettext(info.menuList[#info.menuList])
            --info.text = format('%s...%s', f, t)
            info.value = template.value
            LibDD:UIDropDownMenu_AddButton(info, level)
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
                    LibDD:UIDropDownMenu_Refresh(self, nil, level)
                end
            info.checked = function ()
                    return template.checked(k)
                end
            LibDD:UIDropDownMenu_AddButton(info, level)
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

        ---- 5. ZONEMATCH ----
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            InitDropDownSection(DROPDOWNS.ZONEMATCH, self, level, menuList)
        end

        ---- 6. GROUP ----
        InitDropDownSection(DROPDOWNS.GROUP, self, level, menuList)

        ---- 7. FLAG ----
        InitDropDownSection(DROPDOWNS.FLAG, self, level, menuList)

        ---- 8. TYPENAME ----
        InitDropDownSection(DROPDOWNS.TYPENAME, self, level, menuList)

        ---- 9. FAMILY ----
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            InitDropDownSection(DROPDOWNS.FAMILY, self, level, menuList)
        end

        ---- 10. SOURCES ----
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            InitDropDownSection(DROPDOWNS.SOURCES, self, level, menuList)
        end

        ---- 11. PRIORITY ----
        InitDropDownSection(DROPDOWNS.PRIORITY, self, level, menuList)

        ---- 12. SORTBY ----
        InitDropDownSection(DROPDOWNS.SORTBY, self, level, menuList)
    else
        InitDropDownSection(DROPDOWNS[L_UIDROPDOWNMENU_MENU_VALUE], self, level, menuList)
    end
end

function LiteMountFilterButtonMixin:OnShow()
    LibDD:UIDropDownMenu_Initialize(self.FilterDropDown, self.Initialize, "MENU")
end

function LiteMountFilterButtonMixin:OnLoad()
    LibDD:Create_UIDropDownMenu(self.FilterDropDown)
end
