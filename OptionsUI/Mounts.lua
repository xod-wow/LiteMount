--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_OptionsUIMountsFlag_OnClick(self)
    local mount = self:GetParent().mount

    if self:GetChecked() then
        LM_Options:SetMountFlag(mount, self.flag)
    else
        LM_Options:ClearMountFlag(mount, self.flag)
    end
    LM_OptionsUIMounts_UpdateMountList()
end

-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
local function CreateMoreButtons(self)
    HybridScrollFrame_CreateButtons(self, "LM_OptionsUIMountsButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")

    -- Note: the buttons are laid out right to left
    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
        b.flag1.flag = LM_FLAG.RUN
        b.flag2.flag = LM_FLAG.FLY
        b.flag3.flag = LM_FLAG.SWIM
        b.flag4.flag = LM_FLAG.AQ
        b.flag5.flag = LM_FLAG.VASHJIR
        b.flag6.flag = LM_FLAG.CUSTOM2
        b.flag7.flag = LM_FLAG.CUSTOM1
    end
end

local function EnableDisableMount(mount, onoff)
    if onoff == "0" then
        LM_Options:ExcludeMount(mount)
    else
        LM_Options:IncludeMount(mount)
    end
end

local function FlagButtonUpdate(checkButton, mount)
    local flags = mount:CurrentFlags()

    checkButton:SetChecked(flags[checkButton.flag])

    -- If we changed this from the default then color the background
    if flags[checkButton.flag] == mount.flags[checkButton.flag] then
        checkButton.modified:Hide()
    else
        checkButton.modified:Show()
    end
end

local function GetFilteredMountList()
    local function notBlizFiltered(m)
        return m.isFiltered ~= true
    end

    local mounts = LM_PlayerMounts:Search(notBlizFiltered)

    local function cmp(a,b)
        if a.isCollected == b.isCollected then
            return a.name < b.name
        elseif a.isCollected then
            return true
        else
            return false
        end
    end

    sort(mounts, cmp)

    local searchtext = LM_OptionsUIMounts.SearchBox:GetText()
    if searchtext == SEARCH then
        searchtext = ""
    else
        searchtext = CaseAccentInsensitiveParse(searchtext)
    end

    local n

    searchtext, n = gsub(searchtext, "^+fly *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.FLY) then
                tremove(mounts, i)
            end
        end
    end

    searchtext, n = gsub(searchtext, "^+run *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.RUN) then
                tremove(mounts, i)
            end
        end
    end

    searchtext, n = gsub(searchtext, "^+swim *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.SWIM) then
                tremove(mounts, i)
            end
        end
    end

    searchtext, n = gsub(searchtext, "^+c1 *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.CUSTOM1) then
                tremove(mounts, i)
            end
        end
    end

    searchtext, n = gsub(searchtext, "^+c2 *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.CUSTOM2) then
                tremove(mounts, i)
            end
        end
    end

    searchtext, n = gsub(searchtext, "^+enabled *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if LM_Options:IsExcludedMount(mounts[i]) then
                tremove(mounts, i)
            end
        end
    end

    searchtext, n = gsub(searchtext, "^+active *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not UnitAura("player", mounts[i].spellName) then
                tremove(mounts, i)
            end
        end
    end

    if searchtext ~= "" then
        for i = #mounts, 1, -1 do
            local matchname = CaseAccentInsensitiveParse(mounts[i].name)
            if not strfind(matchname, searchtext, 1, true) then
                tremove(mounts, i)
            end
        end
    end

    return mounts
end

local function UpdateAllSelected(mounts)

    if not mounts then
        mounts = GetFilteredMountList()
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

    local checkedTexture = LM_OptionsUIMountsAllSelect:GetCheckedTexture()
    if allDisabled == 1 then
        LM_OptionsUIMountsAllSelect:SetChecked(false)
    else
        LM_OptionsUIMountsAllSelect:SetChecked(true)
        if allEnabled == 1 then
            checkedTexture:SetDesaturated(false)
        else
            checkedTexture:SetDesaturated(true)
        end
    end
end

local function StyleCollected(button, torf)
    if torf then
        button.name:SetFontObject("GameFontNormal")
        button.icon:GetNormalTexture():SetDesaturated(false)
        button.icon:GetNormalTexture():SetAlpha(1.0)
        button.enabled:GetCheckedTexture():SetDesaturated(false)
        button.enabled:GetCheckedTexture():SetAlpha(1.0)
    else
        button.name:SetFontObject("GameFontDisable")
        button.icon:GetNormalTexture():SetDesaturated(true)
        button.icon:GetNormalTexture():SetAlpha(0.75)
        button.enabled:GetCheckedTexture():SetDesaturated(true)
        button.enabled:GetCheckedTexture():SetAlpha(0.75)
    end
end

local function UpdateMountButton(button, mount)
    button.mount = mount
    button.icon:SetNormalTexture(mount.iconTexture)
    button.name:SetText(mount.name)

    if not InCombatLockdown() then
        mount:SetupActionButton(button.icon)
    end

    StyleCollected(button, mount.isCollected)

    local i = 1
    while button["flag"..i] do
        FlagButtonUpdate(button["flag"..i], mount)
        i = i + 1
    end

    if LM_Options:IsExcludedMount(mount) then
        button.enabled:SetChecked(false)
    else
        button.enabled:SetChecked(true)
    end

    -- if mount:IsUsable() then
    --     button.icon:Enable()
    --     button.icon.unusable:Hide()
    -- else
    --     button.icon:Disable()
    --     button.icon.unusable:SetBlendMode("ADD")
    --     button.icon.unusable:SetAlpha(0.25)
    --     button.icon.unusable:Show()
    -- end

    button.enabled.setFunc = function(setting)
                            EnableDisableMount(button.mount, setting)
                            button.enabled:GetScript("OnEnter")(button.enabled)
                            UpdateAllSelected()
                        end

    if GameTooltip:GetOwner() == button.enabled then
        button.enabled:GetScript("OnEnter")(button.enabled)
    end

end

function LM_OptionsUIMounts_AllSelect_OnClick(self)
    local mounts = GetFilteredMountList()

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
    LM_OptionsUIMounts_UpdateMountList()

end

function LM_OptionsUIMounts_UpdateMountList()

    local scrollFrame = LM_OptionsUIMounts.scrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    if not buttons then return end

    local mounts = GetFilteredMountList()

    for i = 1, #buttons do
        local button = buttons[i]
        local index = offset + i
        if index <= #mounts then
            UpdateMountButton(button, mounts[index])
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

function LM_OptionsUIMountsScrollFrame_OnSizeChanged(self, w, h)
    CreateMoreButtons(self)
    LM_OptionsUIMounts_UpdateMountList()

    self.stepSize = self.buttonHeight
    self.update = LM_OptionsUIMounts_UpdateMountList
end

StaticPopupDialogs["LM_OPTIONS_NEW_PROFILE"] = {
    text = "LiteMount : New Profile",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 24,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            local text = self.editBox:GetText()
            LM_Options.db:SetProfile(text)
        end,
    EditBoxOnEnterPressed = function (self)
            local parent = self:GetParent()
            local text = parent.editBox:GetText()
            if text and text ~= "" then
                LM_Options.db:SetProfile(text)
                if parent.data then
                    LM_Options.db:CopyProfile(parent.data)
                end
            end
            parent:Hide()
        end,
    EditBoxOnEscapePressed = function (self)
            self:GetParent():Hide()
        end,
    OnShow = function (self)
            self.editBox:SetFocus()
        end,
    OnHide = function (self)
            local currentProfile = LM_Options.db:GetCurrentProfile()
            LM_OptionsUIMounts_UpdateMountList()
        end,
}

StaticPopupDialogs["LM_OPTIONS_DELETE_PROFILE"] = {
    text = "LiteMount : Delete Profile %s",
    button1 = DELETE,
    button2 = CANCEL,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            LM_Options.db:DeleteProfile(self.data)
        end,
}

StaticPopupDialogs["LM_OPTIONS_RESET_PROFILE"] = {
    text = "LiteMount : Reset Profile %s",
    button1 = OKAY,
    button2 = CANCEL,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            LM_Options.db:ResetProfile(self.data)
        end,
    OnHide = function (self)
            LM_OptionsUIMounts_UpdateMountList()
        end,
}

local function ClickSetProfile(self, arg1, arg2, checked)
    LM_Options.db:SetProfile(self.value)
    UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
end

local function ClickNewProfile(self, arg1, arg2, check)
    CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_NEW_PROFILE", arg1, nil, arg1)
end

local function ClickDeleteProfile(self, arg1, arg2, check)
    CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_DELETE_PROFILE", arg1, nil, arg1)
end

local function ClickResetProfile(self, arg1, arg2, check)
    CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_RESET_PROFILE", arg1, nil, arg1)
end

function LM_OptionsUIMountsProfileDropDown_Init(self, level)
    local info

    local currentProfile = LM_Options.db:GetCurrentProfile()

    local dbProfiles = LM_Options.db:GetProfiles() or {}
    tDeleteItem(dbProfiles, "Default")
    sort(dbProfiles)
    tinsert(dbProfiles, 1, "Default")

    if level == 1 then
        info = UIDropDownMenu_CreateInfo()
        info.text = "Profiles"
        info.isTitle = 1
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(info, level)

        for _,v in ipairs(dbProfiles) do
            info = UIDropDownMenu_CreateInfo()
            info.text = v
            info.value = v
            info.checked = function ()
                    return (v == LM_Options.db:GetCurrentProfile())
                end
            info.keepShownOnClick = 1
            info.func = ClickSetProfile

            UIDropDownMenu_AddButton(info, level)
        end

        UIDropDownMenu_AddSeparator(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Reset"
        info.notCheckable = 1
        info.func = ClickResetProfile
        info.arg1 = currentProfile
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = "New Profile - Current Settings"
        info.notCheckable = 1
        info.func = ClickNewProfile
        info.arg1 = currentProfile
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = "New Profile - Default Settings"
        info.notCheckable = 1
        info.func = ClickNewProfile
        info.arg1 = "Default"
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Delete Profile"
        info.value = "DELETE"
        info.notCheckable = 1
        info.hasArrow = 1
        UIDropDownMenu_AddButton(info, level)

    elseif level == 2 then
        if UIDROPDOWNMENU_MENU_VALUE == "DELETE" then
            tDeleteItem(dbProfiles, "Default")
            tDeleteItem(dbProfiles, currentProfile)

            for _, p in ipairs(dbProfiles) do
                info = UIDropDownMenu_CreateInfo()
                info.text = p
                info.arg1 = p
                info.notCheckable = 1
                info.func = ClickDeleteProfile
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
end

-- This can't be OnLoad because LM_Options.db isn't set yet.

function LM_OptionsUIMountsProfileDropDown_OnShow(self)
    UIDropDownMenu_Initialize(self, LM_OptionsUIMountsProfileDropDown_Init, "MENU")
end

function LM_OptionsUIMounts_OnLoad(self)

    -- Because we're the wrong size at the moment we'll only have 1 button
    CreateMoreButtons(self.scrollFrame)

    self.name = format("%s %s", MOUNT, OPTIONS)
    self.default = function ()
            for m in LM_PlayerMounts:Iterate() do
                LM_Options:ResetMountFlags(m)
            end
            LM_Options:SetExcludedMounts({})
            LM_OptionsUIMounts_UpdateMountList()
        end

    LM_OptionsUIPanel_OnLoad(self)
end

local function UpdateProfileCallback(self)
    LM_OptionsUIMounts.ProfileButton:SetText(LM_Options.db:GetCurrentProfile())
    LM_OptionsUIMounts_UpdateMountList()
end

function LM_OptionsUIMounts_OnShow(self)
    LM_OptionsUI.CurrentOptionsPanel = self
    LM_OptionsUIMounts_UpdateMountList()
    LM_Options.db.RegisterCallback(self, "OnProfileCopied", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileChanged", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileReset", UpdateProfileCallback)
end

function LM_OptionsUIMounts_OnHide(self)
    LM_Options.db:UnregisterAllCallbacks(self)
end
