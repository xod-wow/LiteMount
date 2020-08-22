--[[----------------------------------------------------------------------------

  LiteMount/UI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local NUM_FLAG_BUTTONS = 5

local function tslice(t, first, last)
    local out = { }
    for i = first or 1, last or #t do
        tinsert(out, t[i])
    end
    return out
end

LiteMountPriorityMixin = {}

LiteMountPriorityMixin.PriorityColors = {
    [''] = COMMON_GRAY_COLOR,
    [0] =  RED_FONT_COLOR,
    [1] =  RARE_BLUE_COLOR,
    [2] =  EPIC_PURPLE_COLOR,
    [3] =  LEGENDARY_ORANGE_COLOR,
}

function LiteMountPriorityMixin:Update()
    local value = self:Get()
    if value then
        self.Minus:SetShown(value > LM_Options.MIN_PRIORITY)
        self.Plus:SetShown(value < LM_Options.MAX_PRIORITY)
        self.Priority:SetText(value)
    else
        self.Minus:Show()
        self.Plus:Show()
        self.Priority:SetText('')
    end
    local r, g, b = self.PriorityColors[value or '']:GetRGB()
    self.Background:SetColorTexture(r, g, b, 0.25)
end

function LiteMountPriorityMixin:Get()
    local mount = self:GetParent().mount
    if mount then
        return LM_Options:GetPriority(mount)
    end
end

function LiteMountPriorityMixin:Set(v)
    local mount = self:GetParent().mount
    if mount then
        LM_Options:SetPriority(mount, v or LM_Options.DEFAULT_PRIORITY)
        LiteMountOptionsMounts.ScrollFrame.isDirty = true
    end
end

function LiteMountPriorityMixin:Increment()
    local v = self:Get()
    if v then
        self:Set(v + 1)
    else
        self:Set(LM_Options.DEFAULT_PRIORITY)
    end
end

function LiteMountPriorityMixin:Decrement()
    local v = self:Get() or LM_Options.DEFAULT_PRIORITY
    self:Set(v - 1)
end

function LiteMountPriorityMixin:OnLoad()
    self.Plus:SetScript('OnClick', function () self:Increment() end)
    self.Minus:SetScript('OnClick', function () self:Decrement() end)
end

function LiteMountPriorityMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(L.LM_PRIORITY)
    for _,p in ipairs(LM_UIFilter.GetPriorities()) do
        local t, d = LM_UIFilter.GetPriorityText(p)
        GameTooltip:AddLine(t .. ' - ' .. d)
    end
    GameTooltip:Show()
end

function LiteMountPriorityMixin:OnLeave()
    GameTooltip:Hide()
end

LiteMountAllPriorityMixin = {}

function LiteMountAllPriorityMixin:Set(v)
    local mounts = LM_UIFilter.GetFilteredMountList()
    LM_Options:SetPriorities(mounts, v or LM_Options.DEFAULT_PRIORITY)
    LiteMountOptionsMounts.ScrollFrame.isDirty = true
end

function LiteMountAllPriorityMixin:Get()
    local mounts = LM_UIFilter.GetFilteredMountList()

    local allValue

    for _,mount in ipairs(mounts) do
        local v = LM_Options:GetPriority(mount)
        if (allValue or v) ~= v then
            allValue = nil
            break
        else
            allValue = v
        end
    end

    return allValue
end

LiteMountFlagBitMixin = {}

function LiteMountFlagBitMixin:OnClick()
    local mount = self:GetParent().mount

    if self:GetChecked() then
        LM_Options:SetMountFlag(mount, self.flag)
    else
        LM_Options:ClearMountFlag(mount, self.flag)
    end
    LiteMountOptionsMounts.ScrollFrame.isDirty = true
end

function LiteMountFlagBitMixin:OnEnter()
    if self.flag then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.flag == "FAVORITES" then
            GameTooltip:SetText("Blizzard " .. L[self.flag])
        else
            GameTooltip:SetText(L[self.flag])
        end
        GameTooltip:Show()
    end
end

function LiteMountFlagBitMixin:OnLeave()
    if GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end
end

LiteMountMountIconMixin = {}

function LiteMountMountIconMixin:OnEnter()
    local m = self:GetParent().mount

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8)
    if m.mountID then
        GameTooltip:SetMountBySpellID(m.spellID)
    else
        GameTooltip:SetSpellByID(m.spellID)
    end

    GameTooltipTextRight2:SetText(ID.." "..m.spellID)
    GameTooltipTextRight2:Show()

    if m.sourceText then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffffffff" .. SOURCE .. "|r")
        GameTooltip:AddLine(m.sourceText)
    end

    if m:IsCastable() then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffff00ff" .. HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. ": " .. MOUNT .. "|r")
    end

    LiteMountPreview:SetMount(m)
    GameTooltip:Show()
end

function LiteMountMountIconMixin:OnLeave()
    LiteMountPreview:Hide()
    GameTooltip:Hide()
end

function LiteMountMountIconMixin:OnLoad()
    self:SetAttribute("unit", "player")
    self:RegisterForClicks("RightButtonUp")
    self:RegisterForDrag("LeftButton")
end

function LiteMountMountIconMixin:OnDragStart()
    local mount = self:GetParent().mount
    if mount.spellID then
        PickupSpell(mount.spellID)
    elseif mount.itemID then
        PickupItem(mount.itemID)
    end
end

LiteMountPreviewMixin = {}

function LiteMountPreviewMixin:SetMount(m)
    if m.modelID then
        self.Model:SetDisplayInfo(m.modelID)
        if m.isSelfMount then
            LiteMountPreview.Model:SetDoBlend(false)
            LiteMountPreview.Model:SetAnimation(618, -1)
        end
        self:Show()
    else
        self:Hide()
    end
end

function LiteMountPreviewMixin:OnLoad()
    self.Model:SetRotation(-MODELFRAME_DEFAULT_ROTATION)
    self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
    self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function LiteMountPreviewMixin:OnShow()
    local d = GameTooltip:GetWidth()
    self:SetSize(d, d)
end

LiteMountSearchBoxMixin = {}

function LiteMountSearchBoxMixin:OnTextChanged()
    SearchBoxTemplate_OnTextChanged(self)
    LM_UIFilter.SetSearchText(self:GetText())
    LiteMountOptions_UpdateMountList()
end

-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
local function CreateMoreButtons(self)
    HybridScrollFrame_CreateButtons(self, "LiteMountMountButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")

    -- Note: the buttons are laid out right to left
    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
    end
end

local function BitButtonUpdate(checkButton, flag, mount)
    checkButton.flag = flag

    if not flag then
        checkButton:Hide()
        return
    else
        checkButton:Show()
    end

    local cur = mount:CurrentFlags()

    checkButton:SetChecked(cur[flag] or false)

    if flag == "FAVORITES" then
        checkButton.Modified:Show()
        checkButton.Modified:SetDesaturated(true)
        checkButton:Disable()
    else
        -- If we changed this from the default then color the background
        checkButton.Modified:SetShown(mount.flags[flag] ~= cur[flag])
        checkButton.Modified:SetDesaturated(false)
        checkButton:Enable()
    end
end

function LiteMountOptionsMountsFilterDropDown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true

    if level == 1 then
        info.isNotRadio = true

        info.text = COLLECTED
        info.arg1 = "COLLECTED"
        info.checked = function ()
                return LM_UIFilter.IsFlagChecked("COLLECTED")
            end
        info.func = function (_, _, _, v)
                LM_UIFilter.SetFlagFilter("COLLECTED", v)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.text = NOT_COLLECTED
        info.arg1 = "NOT_COLLECTED"
        info.checked = function ()
                return LM_UIFilter.IsFlagChecked("NOT_COLLECTED")
            end
        info.func = function (_, _, _, v)
                LM_UIFilter.SetFlagFilter("NOT_COLLECTED", v)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.text = MOUNT_JOURNAL_FILTER_UNUSABLE
        info.arg1 = "UNUSABLE"
        info.checked = function ()
                return LM_UIFilter.IsFlagChecked("UNUSABLE")
            end
        info.func = function (_, _, _, v)
                LM_UIFilter.SetFlagFilter("UNUSABLE", v)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.checked = nil
        info.func = nil
        info.isNotRadio = nil
        info.hasArrow = true
        info.notCheckable = true

        info.text = L.LM_PRIORITY
        info.value = 1
        UIDropDownMenu_AddButton(info, level)

        info.text = L.LM_FLAGS
        info.value = 2
        UIDropDownMenu_AddButton(info, level)

        info.text = SOURCES
        info.value = 3
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        info.hasArrow = false
        info.isNotRadio = true
        info.notCheckable = true

        if UIDROPDOWNMENU_MENU_VALUE == 3 then -- Sources
            info.text = CHECK_ALL
            info.func = function ()
                    LM_UIFilter.SetAllSourceFilters(true)
                    UIDropDownMenu_Refresh(LiteMountOptionsMounts.FilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM_UIFilter.SetAllSourceFilters(false)
                    UIDropDownMenu_Refresh(LiteMountOptionsMounts.FilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.notCheckable = false

            for i = 1,LM_UIFilter.GetNumSources() do
                if LM_UIFilter.IsValidSourceFilter(i) then
                    info.text = LM_UIFilter.GetSourceText(i)
                    info.arg1 = i
                    info.func = function (_, _, _, v)
                            LM_UIFilter.SetSourceFilter(i, v)
                            LiteMountOptions_UpdateMountList()
                        end
                    info.checked = function ()
                            return LM_UIFilter.IsSourceChecked(i)
                        end
                    UIDropDownMenu_AddButton(info, level)
                end
            end

        elseif UIDROPDOWNMENU_MENU_VALUE == 2 then -- Flags
            local flags = LM_UIFilter.GetFlags()

            info.text = CHECK_ALL
            info.func = function ()
                    LM_UIFilter:SetAllFlagFilters(true)
                    UIDropDownMenu_Refresh(LiteMountOptionsMounts.FilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM_UIFilter:SetAllFlagFilters(false)
                    UIDropDownMenu_Refresh(LiteMountOptionsMounts.FilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.notCheckable = false

            for _,f in ipairs(flags) do
                info.text = LM_UIFilter.GetFlagText(f)
                info.arg1 = f
                info.func = function (_, _, _, v)
                        LM_UIFilter.SetFlagFilter(f, v)
                        LiteMountOptions_UpdateMountList()
                    end
                info.checked = function ()
                        return LM_UIFilter.IsFlagChecked(f)
                    end
                UIDropDownMenu_AddButton(info, level)
            end
        elseif UIDROPDOWNMENU_MENU_VALUE == 1 then -- Priority
            local priorities = LM_UIFilter.GetPriorities()

            info.text = CHECK_ALL
            info.func = function ()
                    LM_UIFilter:SetAllPriorityFilters(true)
                    UIDropDownMenu_Refresh(LiteMountOptionsMounts.FilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM_UIFilter:SetAllPriorityFilters(false)
                    UIDropDownMenu_Refresh(LiteMountOptionsMounts.FilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.notCheckable = false

            for _,p in ipairs(priorities) do
                info.text = LM_UIFilter.GetPriorityText(p)
                info.arg1 = p
                info.func = function (_, _, _, v)
                        LM_UIFilter.SetPriorityFilter(p, v)
                        LiteMountOptions_UpdateMountList()
                    end
                info.checked = function ()
                        return LM_UIFilter.IsPriorityChecked(p)
                    end
                UIDropDownMenu_AddButton(info, level)
            end

        end
    end
end

function LiteMountOptionsMountsFilterDropDown_OnLoad(self)
    UIDropDownMenu_Initialize(self, LiteMountOptionsMountsFilterDropDown_Initialize, "MENU")
end

local function UpdateMountButton(button, pageFlags, mount)
    button.mount = mount
    button.Icon:SetNormalTexture(mount.icon)
    button.Name:SetText(mount.name)

    if not InCombatLockdown() then
        for k,v in pairs(mount:GetSecureAttributes()) do
            button.Icon:SetAttribute(k, v)
        end
    end

    local i = 1
    while button["Bit"..i] do
        BitButtonUpdate(button["Bit"..i], pageFlags[i], mount)
        i = i + 1
    end

    if not mount.isCollected then
        button.Name:SetFontObject("GameFontDisable")
        button.Icon:GetNormalTexture():SetDesaturated(true)
    else
        button.Name:SetFontObject("GameFontNormal")
        button.Icon:GetNormalTexture():SetDesaturated(false)
    end

    button.Priority:Update()
end

-- local FPCount = 0

function LiteMountOptions_UpdateFlagPaging()
    local self = LiteMountOptionsMounts
    local allFlags = LM_Options:GetAllFlags()

    -- FPCount = FPCount + 1
    -- LM_Debug(format("FPCount %d", FPCount))

    self.maxFlagPages = math.ceil(#allFlags / NUM_FLAG_BUTTONS)
    self.PrevPageButton:SetEnabled(self.currentFlagPage ~= 1)
    self.NextPageButton:SetEnabled(self.currentFlagPage ~= self.maxFlagPages)

    local pageOffset = (self.currentFlagPage - 1 ) * NUM_FLAG_BUTTONS + 1
    self.pageFlags = tslice(allFlags, pageOffset, pageOffset+NUM_FLAG_BUTTONS-1)

    local label
    for i = 1, NUM_FLAG_BUTTONS do
        label = self["BitLabel"..i]
        if self.pageFlags[i] then
            label:SetText(L[self.pageFlags[i]])
            label:Show()
        else
            label:Hide()
        end
    end
end

-- local UpdateCount = 0

function LiteMountOptions_UpdateMountList()

    -- Because the Icon is a SecureActionButton and a child of the scroll
    -- buttons, we can't show or hide them in combat. Rather than throw a
    -- LUA error, it's better just not to do anything at all.

    if InCombatLockdown() then return end

    local scrollFrame = LiteMountOptionsMounts.ScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    -- UpdateCount = UpdateCount + 1
    -- LM_Debug(format("UpdateCount %d", UpdateCount))

    if not buttons then return end

    local mounts = LM_UIFilter.GetFilteredMountList()

    for i = 1, #buttons do
        local button = buttons[i]
        local index = offset + i
        if index <= #mounts then
            UpdateMountButton(button, LiteMountOptionsMounts.pageFlags, mounts[index])
            button:Show()
        else
            button:Hide()
        end
    end

    LiteMountOptionsMounts.AllPriority:Update()

    if LM_UIFilter.IsFiltered() then
        LiteMountOptionsMounts.FilterButton.ClearButton:Show()
    else
        LiteMountOptionsMounts.FilterButton.ClearButton:Hide()
    end

    local totalHeight = scrollFrame.buttonHeight * #mounts
    local shownHeight = scrollFrame.buttonHeight * #buttons

    HybridScrollFrame_Update(scrollFrame, totalHeight, shownHeight)
end

function LiteMountOptionsScrollFrame_OnSizeChanged(self, w, h)
    CreateMoreButtons(self)
    LiteMountOptions_UpdateMountList()

    self.stepSize = self.buttonHeight
    self.update = LiteMountOptions_UpdateMountList
end

function LiteMountOptionsMounts_OnLoad(self)

    -- Because we're the wrong size at the moment we'll only have 1 button
    CreateMoreButtons(self.ScrollFrame)

    self.name = MOUNTS
    self.default = function ()
            LM_UIDebug(self, 'Custom_Default')
            LM_Options:ResetAllMountFlags()
            LM_Options:SetPriorities(LM_PlayerMounts.mounts, LM_Options.DEFAULT_PRIORITY)
            self.ScrollFrame.isDirty = true
        end

    self.ScrollFrame.GetOption =
        function (scrollFrame)
            return {
                CopyTable(LM_Options:GetRawFlagChanges()),
                CopyTable(LM_Options:GetRawMountPriorities())
            }
        end

    self.ScrollFrame.SetOption =
        function (scrollFrame, v)
            LM_Options:SetRawFlagChanges(v[1])
            LM_Options:SetRawMountPriorities(v[2])
        end

    self.ScrollFrame.SetControl =
        function (scrollFrame)
            LM_UIFilter.ClearCache()
            LiteMountOptions_UpdateFlagPaging(self)
            LiteMountOptions_UpdateMountList(self)
        end

    LiteMountOptionsPanel_RegisterControl(self.ScrollFrame)

    self.currentFlagPage = 1
    self.maxFlagPages = 1
    self.pageFlags = { }
    self.NextFlagPage = function (self)
        self.currentFlagPage = Clamp(self.currentFlagPage + 1, 1, self.maxFlagPages)
        LiteMountOptions_UpdateFlagPaging(self)
        LiteMountOptions_UpdateMountList()
    end
    self.PrevFlagPage = function (self)
        self.currentFlagPage = Clamp(self.currentFlagPage - 1, 1, self.maxFlagPages)
        LiteMountOptions_UpdateFlagPaging()
        LiteMountOptions_UpdateMountList()
    end

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsMounts_OnShow(self)

    -- UpdateCount, FPCount = 0, 0
    LM_PlayerMounts:RefreshMounts()

    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsMounts_OnHide(self)
    LiteMountOptionsPanel_OnHide(self)
end

