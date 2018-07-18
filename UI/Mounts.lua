--[[----------------------------------------------------------------------------

  LiteMount/UI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local NUM_FLAG_BUTTONS = 6

local function tslice(t, first, last)
    local out = { }
    for i = first or 1, last or #t do
        tinsert(out, t[i])
    end
    return out
end

function LiteMountOptionsBit_OnClick(self)
    local mount = self:GetParent().mount

    if self:GetChecked() then
        LM_Options:SetMountFlag(mount, self.flag)
    else
        LM_Options:ClearMountFlag(mount, self.flag)
    end
    LiteMountOptions_UpdateMountList()
end

-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
local function CreateMoreButtons(self)
    HybridScrollFrame_CreateButtons(self, "LiteMountOptionsButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")

    -- Note: the buttons are laid out right to left
    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
    end
end

local function EnableDisableMount(mount, onoff)
    if onoff == "0" then
        LM_Options:AddExcludedMount(mount)
    else
        LM_Options:RemoveExcludedMount(mount)
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

    -- If we changed this from the default then color the background
    checkButton.Modified:SetShown(mount.flags[flag] ~= cur[flag])
end

function LiteMountOptionsMountsFilterDropDown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true

    if level == 1 then
        info.isNotRadio = true

        info.text = VIDEO_OPTIONS_ENABLED
        info.arg1 = "ENABLED"
        info.checked = function ()
                return LM_UIFilter.IsFlagChecked("ENABLED")
            end
        info.func = function (_, _, _, v)
                LM_UIFilter.SetFlagFilter("ENABLED", v)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.text = VIDEO_OPTIONS_DISABLED
        info.arg1 = "DISABLED"
        info.checked = function ()
                return LM_UIFilter.IsFlagChecked("DISABLED")
            end
        info.func = function (_, _, _, v)
                LM_UIFilter.SetFlagFilter("DISABLED", v)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

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

        info.text = L.LM_FLAGS
        info.value = 1
        UIDropDownMenu_AddButton(info, level)

        info.text = SOURCES
        info.value = 2
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        info.hasArrow = false
        info.isNotRadio = true
        info.notCheckable = true

        if UIDROPDOWNMENU_MENU_VALUE == 2 then -- Sources
            info.text = CHECK_ALL
            info.func = function ()
                    LM_UIFilter.SetAllSourceFilters(true)
                    UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM_UIFilter.SetAllSourceFilters(false)
                    UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, false, 2)
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

        elseif UIDROPDOWNMENU_MENU_VALUE == 1 then -- Flags
            local flags = LM_UIFilter.GetFlags()

            info.text = CHECK_ALL
            info.func = function ()
                    LM_UIFilter:SetAllFlagFilters(true)
                    UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, false, 2)
                    LiteMountOptions_UpdateMountList()
                end
            UIDropDownMenu_AddButton(info, level)

            info.text = UNCHECK_ALL
            info.func = function ()
                    LM_UIFilter:SetAllFlagFilters(false)
                    UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, false, 2)
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
        end
    end
end

function LiteMountOptionsMountsFilterDropDown_OnLoad(self)
    UIDropDownMenu_Initialize(self, LiteMountOptionsMountsFilterDropDown_Initialize, "MENU")
end

local function UpdateAllSelected(mounts)

    if not mounts then
        mounts = LM_UIFilter.GetFilteredMountList()
    end

    local allEnabled = 1
    local allDisabled = 1

    for _,m in ipairs(mounts) do
        if LM_Options:IsExcludedMount(m) then
            allEnabled = 0
        else
            allDisabled = 0
        end
    end

    local checkedTexture = LiteMountOptionsMounts.AllSelect:GetCheckedTexture()
    if allDisabled == 1 then
        LiteMountOptionsMounts.AllSelect:SetChecked(false)
    else
        LiteMountOptionsMounts.AllSelect:SetChecked(true)
        if allEnabled == 1 then
            checkedTexture:SetDesaturated(false)
        else
            checkedTexture:SetDesaturated(true)
        end
    end
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

    if LM_Options:IsExcludedMount(mount) then
        button.Enabled:SetChecked(false)
    else
        button.Enabled:SetChecked(true)
    end

    button.Enabled.SetValue = function (self, setting)
                            EnableDisableMount(button.mount, setting)
                            self:GetScript("OnEnter")(self)
                            UpdateAllSelected()
                        end

    if GameTooltip:GetOwner() == button.Enabled then
        button.Enabled:GetScript("OnEnter")(button.Enabled)
    end

end

function LiteMountOptions_AllSelect_OnClick(self)
    local mounts = LM_UIFilter.GetFilteredMountList()

    local on

    if self:GetChecked() then
        on = "1"
    else
        on = "0"
    end

    for _,m in ipairs(mounts) do
        EnableDisableMount(m, on)
    end

    self:GetScript("OnEnter")(self)
    LiteMountOptions_UpdateMountList()

end


local FPCount = 0

function LiteMountOptions_UpdateFlagPaging()
    local self = LiteMountOptionsMounts
    local allFlags = LM_Options:GetAllFlags()

    FPCount = FPCount + 1
    LM_Debug(format("FPCount %d", FPCount))

    self.maxFlagPages = math.ceil(#allFlags / NUM_FLAG_BUTTONS)
    self.PrevPageButton:SetEnabled(self.currentFlagPage ~= 1)
    self.NextPageButton:SetEnabled(self.currentFlagPage ~= self.maxFlagPages)

    local pageOffset = (self.currentFlagPage - 1 ) * NUM_FLAG_BUTTONS + 1
    self.pageFlags = tslice(allFlags, pageOffset, pageOffset+NUM_FLAG_BUTTONS-1)

    local bt
    for i = 1, NUM_FLAG_BUTTONS do
        bt = self["BitText"..i]
        if self.pageFlags[i] then
            bt:SetText(L[self.pageFlags[i]])
            bt:Show()
        else
            bt:Hide()
        end
    end
end

local UpdateCount = 0

function LiteMountOptions_UpdateMountList()

    local scrollFrame = LiteMountOptionsMounts.ScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    UpdateCount = UpdateCount + 1
    LM_Debug(format("UpdateCount %d", UpdateCount))

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

    UpdateAllSelected(mounts)

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
            for m in LM_PlayerMounts:Iterate() do
                LM_Options:ResetMountFlags(m)
            end
            LM_Options:SetExcludedMounts({})
            LiteMountOptions_UpdateMountList()
        end

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

    self.refresh = function (self)
        LiteMountOptions_UpdateFlagPaging(self)
        LiteMountOptions_UpdateMountList(self)
    end

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsMounts_OnShow(self)

    UpdateCount, FPCount = 0, 0
    LM_PlayerMounts:RefreshMounts()

    LiteMountOptions_UpdateFlagPaging()
    LiteMountOptions_UpdateMountList()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsMounts_OnHide(self)
end

