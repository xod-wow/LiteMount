--[[----------------------------------------------------------------------------

  LiteMount/UI/MountsFilter.lua

  Options frame for the mount list.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local FAMILY_MENU_SPLIT_SIZE = 20

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

function LiteMountFilterButtonMixin:Initialize(level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true

    if level == 1 then
        info.isNotRadio = true

        ---- 1. COLLECTED ----
        info.text = COLLECTED
        info.arg1 = "COLLECTED"
        info.checked = function ()
                return LM.UIFilter.IsFlagChecked("COLLECTED")
            end
        info.func = function (_, _, _, v)
                LM.UIFilter.SetFlagFilter("COLLECTED", v)
            end
        UIDropDownMenu_AddButton(info, level)

        ---- 2. NOT COLLECTED ----
        info.text = NOT_COLLECTED
        info.arg1 = "NOT_COLLECTED"
        info.checked = function ()
                return LM.UIFilter.IsFlagChecked("NOT_COLLECTED")
            end
        info.func = function (_, _, _, v)
                LM.UIFilter.SetFlagFilter("NOT_COLLECTED", v)
            end
        UIDropDownMenu_AddButton(info, level)

        ---- 3. UNUSABLE ----
        info.text = MOUNT_JOURNAL_FILTER_UNUSABLE
        info.arg1 = "UNUSABLE"
        info.checked = function ()
                return LM.UIFilter.IsFlagChecked("UNUSABLE")
            end
        info.func = function (_, _, _, v)
                LM.UIFilter.SetFlagFilter("UNUSABLE", v)
            end
        UIDropDownMenu_AddButton(info, level)

        ---- 4. HIDDEN ----
        info.text = L.LM_HIDDEN
        info.arg1 = "HIDDEN"
        info.checked = function ()
                return LM.UIFilter.IsFlagChecked("HIDDEN")
            end
        info.func = function (_, _, _, v)
                LM.UIFilter.SetFlagFilter("HIDDEN", v)
            end
        UIDropDownMenu_AddButton(info, level)

        info.checked = nil
        info.func = nil
        info.isNotRadio = nil
        info.hasArrow = true
        info.notCheckable = true

        ---- 5. PRIORITY ----
        info.text = L.LM_PRIORITY
        info.value = 'PRIORITY'
        UIDropDownMenu_AddButton(info, level)

        ---- 6. FLAGS ----
        info.text = L.LM_FLAGS
        info.value = 'FLAGS'
        UIDropDownMenu_AddButton(info, level)

        ---- 7. FAMILY ----
        info.text = L.LM_FAMILY
        info.value = 'FAMILY'
        UIDropDownMenu_AddButton(info, level)

        ---- 8. SOURCES ----
        info.text = SOURCES
        info.value = 'SOURCES'
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        info.hasArrow = false
        info.isNotRadio = true
        info.notCheckable = true

        if UIDROPDOWNMENU_MENU_VALUE == 'FAMILY' then
            info.text = CHECK_ALL
            info.func = function ()
                    LM.UIFilter.SetAllFamilyFilters(true)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM.UIFilter.SetAllFamilyFilters(false)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)

            local families = LM.UIFilter.GetFamilies()

            info.func = nil
            info.isNotRadio = false
            info.hasArrow = true

            for i = 1, #families, FAMILY_MENU_SPLIT_SIZE do
                local j = math.min(#families, i+FAMILY_MENU_SPLIT_SIZE-1)
                info.menuList = tSlice(families, i, j)
                info.text = format('%s...%s', info.menuList[1], info.menuList[#info.menuList])
                info.value = 'FAMILY'
                UIDropDownMenu_AddButton(info, level)
            end

        elseif UIDROPDOWNMENU_MENU_VALUE == 'SOURCES' then
            info.text = CHECK_ALL
            info.func = function ()
                    LM.UIFilter.SetAllSourceFilters(true)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM.UIFilter.SetAllSourceFilters(false)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)

            info.notCheckable = false

            for i = 1,LM.UIFilter.GetNumSources() do
                if LM.UIFilter.IsValidSourceFilter(i) then
                    info.text = LM.UIFilter.GetSourceText(i)
                    info.arg1 = i
                    info.func = function (_, _, _, v)
                            if IsShiftKeyDown() then
                                LM.UIFilter.SetAllSourceFilters(false)
                                LM.UIFilter.SetSourceFilter(i, true)
                                UIDropDownMenu_Refresh(self, false, 2)
                            else
                                LM.UIFilter.SetSourceFilter(i, v)
                            end
                        end
                    info.checked = function ()
                            return LM.UIFilter.IsSourceChecked(i)
                        end
                    UIDropDownMenu_AddButton(info, level)
                end
            end

        elseif UIDROPDOWNMENU_MENU_VALUE == 'FLAGS' then
            local flags = LM.UIFilter.GetFlags()

            info.text = CHECK_ALL
            info.func = function ()
                    LM.UIFilter:SetAllFlagFilters(true)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM.UIFilter:SetAllFlagFilters(false)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)

            info.notCheckable = false

            for _,f in ipairs(flags) do
                info.text = LM.UIFilter.GetFlagText(f)
                info.arg1 = f
                info.func = function (_, _, _, v)
                        if IsShiftKeyDown() then
                            LM.UIFilter.SetAllFlagFilters(false)
                            LM.UIFilter.SetFlagFilter(f, true)
                            UIDropDownMenu_Refresh(self, false, 2)
                        else
                            LM.UIFilter.SetFlagFilter(f, v)
                        end
                    end
                info.checked = function ()
                        return LM.UIFilter.IsFlagChecked(f)
                    end
                UIDropDownMenu_AddButton(info, level)
            end
        elseif UIDROPDOWNMENU_MENU_VALUE == 'PRIORITY' then
            local priorities = LM.UIFilter.GetPriorities()

            info.text = CHECK_ALL
            info.func = function ()
                    LM.UIFilter:SetAllPriorityFilters(true)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM.UIFilter:SetAllPriorityFilters(false)
                    UIDropDownMenu_Refresh(self, false, 2)
                end
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)

            info.notCheckable = false

            for _,p in ipairs(priorities) do
                info.text = LM.UIFilter.GetPriorityText(p)
                info.arg1 = p
                info.func = function (_, _, _, v)
                        if IsShiftKeyDown() then
                            LM.UIFilter.SetAllPriorityFilters(false)
                            LM.UIFilter.SetPriorityFilter(p, true)
                            UIDropDownMenu_Refresh(self, false, 2)
                        else
                            LM.UIFilter.SetPriorityFilter(p, v)
                        end
                    end
                info.checked = function ()
                        return LM.UIFilter.IsPriorityChecked(p)
                    end
                UIDropDownMenu_AddButton(info, level)
            end

        end
    elseif level == 3 then
        local startFrom = UIDROPDOWNMENU_MENU_VALUE

        for i, menuEntry in ipairs(menuList) do
            info.notCheckable = false
            info.isNotRadio = true
            info.hasArrow = false

            if UIDROPDOWNMENU_MENU_VALUE == 'FAMILY' then
                info.text = LM.UIFilter.GetFamilyText(menuEntry)
                info.arg1 = menuEntry
                info.func = function (_, _, _, v)
                        if IsShiftKeyDown() then
                            LM.UIFilter.SetAllFamilyFilters(false)
                            LM.UIFilter.SetFamilyFilter(menuEntry, true)
                            UIDropDownMenu_Refresh(self, false, 3)
                        else
                            LM.UIFilter.SetFamilyFilter(menuEntry, v)
                        end
                    end
                info.checked = function ()
                    return LM.UIFilter.IsFamilyChecked(menuEntry)
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LiteMountFilterButtonMixin:OnLoad()
    UIDropDownMenu_Initialize(self.FilterDropDown, self.Initialize, "MENU")
end
