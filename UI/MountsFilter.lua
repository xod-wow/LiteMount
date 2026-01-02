--[[----------------------------------------------------------------------------

  LiteMount/UI/MountsFilter.lua

  Options frame for the mount list.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MENU_SPLIT_SIZE = 20

--[[------------------------------------------------------------------------]]--

-- Yeah this is ugly, it's converted from UIDropDownMenu and would be very
-- different if it were done natively for Blizzard_Menu.

local DROPDOWNS = {
    {
        order = 1,
        text = COLLECTED,
        checked = function () return LM.UIFilter.IsOtherChecked("COLLECTED") end,
        set = function (v) LM.UIFilter.SetOtherFilter("COLLECTED", v) end,
    },
    {
        order = 2,
        text = NOT_COLLECTED,
        checked = function () return LM.UIFilter.IsOtherChecked("NOT_COLLECTED") end,
        set = function (v) LM.UIFilter.SetOtherFilter("NOT_COLLECTED", v) end,
    },
    {
        order = 3,
        text = MOUNT_JOURNAL_FILTER_UNUSABLE,
        checked = function () return LM.UIFilter.IsOtherChecked("UNUSABLE") end,
        set = function (v) LM.UIFilter.SetOtherFilter("UNUSABLE", v) end,
    },
    {
        order = 4,
        text = L.LM_HIDDEN,
        checked = function () return LM.UIFilter.IsOtherChecked("HIDDEN") end,
        set = function (v) LM.UIFilter.SetOtherFilter("HIDDEN", v) end,
    },
    {
        order = 5,
        disable = ( WOW_PROJECT_ID ~= 1 ),
        text = L.LM_ZONEMATCH,
        checked = function () return LM.UIFilter.IsOtherChecked("ZONEMATCH") end,
        set = function (v) LM.UIFilter.SetOtherFilter("ZONEMATCH", v) end,
    },
    {
        text = L.LM_PRIORITY,
        checked = function (k) return LM.UIFilter.IsPriorityChecked(k) end,
        set = function (k, v) LM.UIFilter.SetPriorityFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllPriorityFilters(v) end,
        menulist = function () return LM.UIFilter.GetPriorities() end,
        gettext = function (k) return string.join(' - ', LM.UIFilter.GetPriorityColorTexts(k)) end,
    },
    {
        text = string.format('%s (%s)', TYPE, ID),
        checked = function (k) return LM.UIFilter.IsTypeNameChecked(k) end,
        set = function (k, v) LM.UIFilter.SetTypeNameFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllTypeNameFilters(v) end,
        menulist = function () return LM.UIFilter.GetTypeNames() end,
        gettext = function (k) return LM.UIFilter.GetTypeNameText(k) end,
    },
    {
        text = L.LM_GROUP,
        checked = function (k) return LM.UIFilter.IsGroupChecked(k) end,
        set = function (k, v) LM.UIFilter.SetGroupFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllGroupFilters(v) end,
        menulist = function () return LM.UIFilter.GetGroups() end,
        gettext = function (k) return LM.UIFilter.GetGroupText(k) end,
    },
    {
        text = TYPE,
        checked = function (k) return LM.UIFilter.IsFlagChecked(k) end,
        set = function (k, v) LM.UIFilter.SetFlagFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllFlagFilters(v) end,
        menulist = function () return LM.UIFilter.GetFlags() end,
        gettext = function (k) return LM.UIFilter.GetFlagText(k) end,
    },
    {
        disable = ( WOW_PROJECT_ID ~= 1 ),
        text = L.LM_FAMILY,
        -- text = MODEL,
        checked = function (k) return LM.UIFilter.IsFamilyChecked(k) end,
        set = function (k, v) LM.UIFilter.SetFamilyFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllFamilyFilters(v) end,
        menulist = function () return LM.UIFilter.GetFamilies() end,
        gettext = function (k) return LM.UIFilter.GetFamilyText(k) end,
    },
    {
        disable = ( WOW_PROJECT_ID ~= 1 ),
        text = SOURCES,
        checked = function (k) return LM.UIFilter.IsSourceChecked(k) end,
        set = function (k, v) LM.UIFilter.SetSourceFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllSourceFilters(v) end,
        menulist = function () return LM.UIFilter.GetSources() end,
        gettext = function (k) return LM.UIFilter.GetSourceText(k) end,
    },
    {
        disable = ( WOW_PROJECT_ID ~= 1 ),
        text = EXPANSION_FILTER_TEXT,
        checked = function (k) return LM.UIFilter.IsExpansionChecked(k) end,
        set = function (k, v) LM.UIFilter.SetExpansionFilter(k, v) end,
        setall = function (v) LM.UIFilter.SetAllExpansionFilters(v) end,
        menulist = function () return LM.UIFilter.GetExpansions() end,
        gettext = function (k) return LM.UIFilter.GetExpansionText(k) end,
    },
    {
        order = -1,
        text = BLUE_FONT_COLOR:WrapTextInColorCode(RAID_FRAME_SORT_LABEL),
        checked = function (k) return LM.UIFilter.GetSortKey() == k end,
        set = function (k) LM.UIFilter.SetSortKey(k) end,
        menulist = function () return LM.UIFilter.GetSortKeys() end,
        gettext = function (k) return LM.UIFilter.GetSortKeyText(k) end,
    },
}

table.sort(DROPDOWNS,
    function (a, b)
        if a.order and b.order then
            return a.order % 10000 < b.order % 10000
        elseif a.order then
            return a.order > 0
        elseif b.order then
            return b.order < 0
        else
            return a.text < b.text
        end
    end)

local function InitDropDownSection(info, dropdown, rootDescription)
    if info.menulist then
        local subMenu = rootDescription:CreateButton(info.text)
        if info.setall then
            local function set(v) info.setall(v) return MenuResponse.Refresh end
            subMenu:CreateButton(CHECK_ALL, set, true)
            subMenu:CreateButton(UNCHECK_ALL, set, false)
        end
        local options = info.menulist()
        for _, v in ipairs(options) do
            local text = info.gettext(v)
            local function checked() return info.checked(v) end
            local function set()
                local isMiddleButton = GetMouseButtonClicked() == 'MiddleButton'
                if (IsShiftKeyDown() or isMiddleButton) and info.setall then
                    info.setall(false)
                    info.set(v, true)
                else
                    info.set(v, not info.checked(v))
                end
            end
            local box = subMenu:CreateCheckbox(text, checked, set)
            if info.setall then
                box:AddInitializer(
                    function (f)
                        f:RegisterForClicks("LeftButtonUp", "MiddleButtonUp")
                    end)
                box:SetTooltip(
                    function(tooltip, elementDescription)
                        GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription))
                        GameTooltip_AddInstructionLine(tooltip, KEY_BUTTON1 .. ': ' .. L.LM_TOGGLE)
                        GameTooltip_AddInstructionLine(tooltip, KEY_BUTTON3 .. ': ' .. LFG_LIST_SELECT)
                    end)
            end
        end
        if #options > 20 then
            local _, y = GetPhysicalScreenSize()
            subMenu:SetScrollMode(math.floor(y/3))
        end
    else
        local function set () info.set(not info.checked()) end
        rootDescription:CreateCheckbox(info.text, info.checked, set)
    end
end

local function DropdownGenerate(dropdown, rootDescription)

    -- Gets called in OnLoad for some reason, and vars aren't loaded yet. I
    -- suspect I might be doing something wrong.

    if not LM.db then return end

    rootDescription:SetTag("MENU_MOUNT_COLLECTION_FILTER")

    for _, info in ipairs(DROPDOWNS) do
        if not info.disable then
            InitDropDownSection(info, dropdown, rootDescription)
        end
    end

end

--[[------------------------------------------------------------------------]]--
--
LiteMountFilterMixin = {}

function LiteMountFilterMixin:OnLoad()
    self.FilterDropdown:SetIsDefaultCallback(function () return not LM.UIFilter.IsFiltered() end)
    self.FilterDropdown:SetDefaultCallback(function () LM.UIFilter.Clear() end)
    self.FilterDropdown:SetupMenu(DropdownGenerate)
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
