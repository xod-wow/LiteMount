--[[----------------------------------------------------------------------------

  LiteMount/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local NUM_FLAG_BUTTONS = 5

local function tSlice(t, first, last)
    local out = { }
    for i = first or 1, last or #t do
        tinsert(out, t[i])
    end
    return out
end

local function tSortedKeys(t)
    local out = { }
    for k in pairs(t) do
        tinsert(out, k)
    end
    sort(out, function (a,b) return t[a] < t[b] end)
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

    local flags = mount:CurrentFlags()

    local checked = tContains(flags, flag)
    checkButton:SetChecked(checked)

    -- If we changed this from the default then color the background
    if checked == tContains(mount.flags, flag) then
        checkButton.Modified:Hide()
    else
        checkButton.Modified:Show()
    end
end

function LiteMountOptionsMountsFilterDropDown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true

    local function flagFunc(self, arg1, arg2, v)
        LM_Options.db.char.uiMountFilterList[arg1] = (not v or nil)
        LiteMountOptions_UpdateMountList()
    end

    if level == 1 then
        info.func = flagFunc
        info.isNotRadio = true

        info.text = VIDEO_OPTIONS_ENABLED
        info.arg1 = "ENABLED"
        info.checked = not LM_Options.db.char.uiMountFilterList.ENABLED
        UIDropDownMenu_AddButton(info, level)

        info.text = VIDEO_OPTIONS_DISABLED
        info.arg1 = "DISABLED"
        info.checked = not LM_Options.db.char.uiMountFilterList.DISABLED
        UIDropDownMenu_AddButton(info, level)

        info.text = COLLECTED
        info.arg1 = "COLLECTED"
        info.checked = not LM_Options.db.char.uiMountFilterList.COLLECTED
        UIDropDownMenu_AddButton(info, level)

        info.text = NOT_COLLECTED
        info.arg1 = "NOT_COLLECTED"
        info.checked = not LM_Options.db.char.uiMountFilterList.NOT_COLLECTED
        UIDropDownMenu_AddButton(info, level)

        info.text = MOUNT_JOURNAL_FILTER_UNUSABLE
        info.arg1 = "UNUSABLE"
        info.checked = not LM_Options.db.char.uiMountFilterList.UNUSABLE
        UIDropDownMenu_AddButton(info, level)

        info.text = L.LM_FLAGS
        info.checked = nil
        info.func = nil
        info.isNotRadio = nil
        info.hasArrow = true
        info.notCheckable = true
        info.value = 1
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        info.isNotRadio = true
        info.notCheckable = true

        info.text = CHECK_ALL
        info.func = function () 
                for k in pairs(LM_FLAG) do 
                    LM_Options.db.char.uiMountFilterList[k] = nil
                end
                UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, 1, 2)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.text = UNCHECK_ALL
        info.func = function ()
                for k in pairs(LM_FLAG) do 
                    LM_Options.db.char.uiMountFilterList[k] = true
                end
                UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, 1, 2)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.notCheckable = false
        info.func = flagFunc

        local allFlags = { }
        for flagName in pairs(LM_FLAG) do tinsert(allFlags, flagName) end
        sort(allFlags, function(a,b) return LM_FLAG[a] < LM_FLAG[b] end)

        for _, flagName in ipairs(allFlags) do 
            info.text = L[flagName]
            info.arg1 = flagName
            info.checked = function ()
                    return not LM_Options.db.char.uiMountFilterList[flagName]
                end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LiteMountOptionsMountsFilterDropDown_OnLoad(self)
    UIDropDownMenu_Initialize(self, LiteMountOptionsMountsFilterDropDown_Initialize, "MENU")
end

StaticPopupDialogs["LM_OPTIONS_NEW_PROFILE"] = {
    text = format("LiteMount : %s", L.LM_NEW_PROFILE),
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
            if text and text ~= "" then
                LM_Options.db:SetProfile(text)
                if self.data then
                    LM_Options.db:CopyProfile(self.data)
                end
            end
        end,
    EditBoxOnEnterPressed = function (self)
            StaticPopup_OnClick(self:GetParent(), 1)
        end,
    EditBoxOnEscapePressed = function (self)
            self:GetParent():Hide()
        end,
    OnShow = function (self)
            self.editBox:SetFocus()
        end,
    OnHide = function (self)
            LiteMountOptions_UpdateMountList()
        end,
}

StaticPopupDialogs["LM_OPTIONS_DELETE_PROFILE"] = {
    text = "LiteMount : " .. CONFIRM_COMPACT_UNIT_FRAME_PROFILE_DELETION,
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
    text = "LiteMount : " .. L.LM_RESET_PROFILE .. " %s",
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
            LiteMountOptions_UpdateMountList()
        end,
}

local function ClickSetProfile(self, arg1, arg2, checked)
    LM_Options.db:SetProfile(self.value)
    UIDropDownMenu_RefreshAll(LiteMountOptionsMountsFilterDropDown, true)
end

local function ClickNewProfile(self, arg1, arg2, check)
    CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_NEW_PROFILE", arg1, nil, arg1)
end

local function ClickDeleteProfile(self, arg1, arg2, check)
    CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_DELETE_PROFILE", arg1, nil, arg1)
end

local function ClickResetProfile(self)
    local arg1 = LM_Options.db:GetCurrentProfile()
    CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_RESET_PROFILE", arg1, nil, arg1)
end

function LiteMountOptionsMountsProfileDropDown_Initialize(self, level)
    local info

    local currentProfile = LM_Options.db:GetCurrentProfile()
    local dbProfiles = LM_Options.db:GetProfiles() or {}
    tDeleteItem(dbProfiles, "Default")
    sort(dbProfiles)
    tinsert(dbProfiles, 1, "Default")

    if level == 1 then
        info = UIDropDownMenu_CreateInfo()
        info.text = L.LM_PROFILES
        info.isTitle = 1
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(info, level)

        for _,v in ipairs(dbProfiles) do
            info = UIDropDownMenu_CreateInfo()
            if v == "Default" then
                info.text = DEFAULT -- localized by Blizzard
            else
                info.text = v
            end
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
        info.text = L.LM_RESET_PROFILE
        info.notCheckable = 1
        info.func = ClickResetProfile
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = L.LM_NEW_PROFILE
        info.value = NEW
        info.notCheckable = 1
        info.hasArrow = 1
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = L.LM_DELETE_PROFILE
        info.value = DELETE
        info.notCheckable = 1
        info.hasArrow = 1
        UIDropDownMenu_AddButton(info, level)

    elseif level == 2 then
        if UIDROPDOWNMENU_MENU_VALUE == DELETE then
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
        elseif UIDROPDOWNMENU_MENU_VALUE == NEW then
            info = UIDropDownMenu_CreateInfo()
            info.text = L.LM_CURRENT_SETTINGS
            info.notCheckable = 1
            info.arg1 = currentProfile
            info.func = ClickNewProfile
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = L.LM_DEFAULT_SETTINGS
            info.notCheckable = 1
            info.func = ClickNewProfile
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LiteMountOptionsMountsProfileDropDown_OnLoad(self)
    UIDropDownMenu_Initialize(self, LiteMountOptionsMountsProfileDropDown_Initialize, "MENU")
end

local function FilterSort(a, b)
    if a.isCollected and not b.isCollected then return true end
    if not a.isCollected and b.isCollected then return false end
    return a.name < b.name
end

local function GetFilteredMountList()

    local filters = LM_Options.db.char.uiMountFilterList

    local mounts = LM_PlayerMounts:GetAllMounts()
    sort(mounts, FilterSort)

    local filtertext = LiteMountOptionsMounts.Search:GetText()
    if filtertext == SEARCH then
        filtertext = ""
    else
        filtertext = strlower(filtertext)
    end

    for i = #mounts, 1, -1 do
        local m = mounts[i]

        local remove = false

        if m.isFiltered then
            remove = true
        elseif filters.DISABLED and LM_Options:IsExcludedMount(m) then
            remove = true
        elseif filters.ENABLED and not LM_Options:IsExcludedMount(m) then
            remove = true
        elseif filters.COLLECTED and m.isCollected then
            remove = true
        elseif filters.NOT_COLLECTED and not m.isCollected then
            remove = true
        elseif filters.UNUSABLE and m.needsFaction and m.needsFaction ~= UnitFactionGroup("player") then
            remove = true
        else
            local okflags = m:CurrentFlags()
            local noFilters = true
            for flagName in pairs(LM_FLAG) do
                if filters[flagName] then
                    tDeleteItem(okflags, flagName)
                    noFilters = false
                end
            end
            if noFilters == false and #okflags == 0 then
                remove = true
            end
        end

        -- strfind is expensive, avoid if possible
        if not remove then
            if filtertext == "=" then
                local spellName = GetSpellInfo(m.spellID)
                if UnitAura("player", spellName) == nil then
                    remove = true
                end
            elseif filtertext ~= "" then
                local matchname = strlower(m.name)
                if not strfind(matchname, filtertext, 1, true) then
                    remove = true
                end
            end
        end


        if remove then
            tremove(mounts, i)
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

    button.Enabled.setFunc = function(setting)
                            EnableDisableMount(button.mount, setting)
                            button.Enabled:GetScript("OnEnter")(button.Enabled)
                            UpdateAllSelected()
                        end

    if GameTooltip:GetOwner() == button.Enabled then
        button.Enabled:GetScript("OnEnter")(button.Enabled)
    end

end

function LiteMountOptions_AllSelect_OnClick(self)
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
    LiteMountOptions_UpdateMountList()

end


function LiteMountOptions_UpdateFlagPaging(self)
    local allFlags = tSortedKeys(LM_FLAG)
    self.maxFlagPages = math.ceil(#allFlags / NUM_FLAG_BUTTONS)
    self.PrevPageButton:SetEnabled(self.currentFlagPage ~= 1)
    self.NextPageButton:SetEnabled(self.currentFlagPage ~= self.maxFlagPages)

    local pageOffset = (self.currentFlagPage - 1 ) * NUM_FLAG_BUTTONS + 1
    self.pageFlags = tSlice(allFlags, pageOffset, pageOffset+NUM_FLAG_BUTTONS-1)

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

function LiteMountOptions_UpdateMountList()

    local scrollFrame = LiteMountOptionsMounts.ScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    if not buttons then return end

    local mounts = GetFilteredMountList()

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
        LiteMountOptions_UpdateFlagPaging(self)
        LiteMountOptions_UpdateMountList()
    end

    LiteMountOptionsPanel_OnLoad(self)
end

local function UpdateProfileCallback(self)
    LiteMountOptionsMountsProfileButton:SetText(LM_Options.db:GetCurrentProfile())
    LiteMountOptions_UpdateMountList()
end

function LiteMountOptionsMounts_OnShow(self)
    LM_Options.db.RegisterCallback(self, "OnProfileCopied", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileChanged", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileReset", UpdateProfileCallback)

    -- This is specifically to catch the "Currently Active Mount" filter
    self:SetScript("OnEvent", LiteMountOptions_UpdateMountList)
    self:RegisterUnitEvent("UNIT_AURA", "player")

    LiteMountOptions_UpdateFlagPaging(self)
    LiteMountOptions_UpdateMountList()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsMounts_OnHide(self)
    LM_Options.db:UnregisterAllCallbacks(self)
    self:UnregisterEvent("UNIT_AURA", "player")
end

