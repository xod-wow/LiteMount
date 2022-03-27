--[[----------------------------------------------------------------------------

  LiteMount/UI/ProfileDropDown.lua

  Attachable profile-switching button.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local L = LM.Localize

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
                LM.Options.db:SetProfile(text)
                if self.data then
                    LM.Options.db:CopyProfile(self.data)
                end
            end
        end,
    EditBoxOnEnterPressed = function (self)
            if self:GetParent().button1:IsEnabled() then
                StaticPopup_OnClick(self:GetParent(), 1)
            end
        end,
    EditBoxOnEscapePressed = function (self)
            self:GetParent():Hide()
        end,
    EditBoxOnTextChanged = function (self)
            local text = self:GetText()
            if text ~= "" and not LM.Options.db.profiles[text] then
                self:GetParent().button1:Enable()
            else
                self:GetParent().button1:Disable()
            end
        end,
    OnShow = function (self)
            self.editBox:SetFocus()
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
            LM.Options.db:DeleteProfile(self.data)
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
            LM.Options.db:ResetProfile(self.data)
        end,
}

local function GetProfileNameText(p)
    if p == "Default" then
        return DEFAULT
    else
        return p
    end
end

local function ClickSetProfile(self, arg1, arg2, checked)
    LM.Options.db:SetProfile(self.value)
    LibDD:UIDropDownMenu_RefreshAll(LiteMountProfileButton.DropDown, true)
end

local function ClickNewProfile(self, arg1, arg2, check)
    LibDD:CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_NEW_PROFILE", arg1, nil, arg1)
end

local function ClickDeleteProfile(self, arg1, arg2, check)
    LibDD:CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_DELETE_PROFILE", arg1, nil, arg1)
end

local function ClickResetProfile(self)
    local arg1 = LM.Options.db:GetCurrentProfile()
    LibDD:CloseDropDownMenus()
    StaticPopup_Show("LM_OPTIONS_RESET_PROFILE", arg1, nil, arg1)
end

local function ClickExportProfile(self, arg1, arg2, check)
    LibDD:CloseDropDownMenus()
    LiteMountProfileExport:ExportProfile(arg1)
end

local function ClickImportProfile(self, arg1, arg2, check)
    LibDD:CloseDropDownMenus()
    LiteMountProfileImport:Show()
end

local function DropDown_Initialize(self, level)
    local info

    if level == nil then return end

    local currentProfile = LM.Options.db:GetCurrentProfile()
    local dbProfiles = LM.Options.db:GetProfiles() or {}
    tDeleteItem(dbProfiles, "Default")
    sort(dbProfiles)
    tinsert(dbProfiles, 1, "Default")

    if level == 1 then
        info = LibDD:UIDropDownMenu_CreateInfo()
        info.text = L.LM_PROFILES
        info.isTitle = 1
        info.notCheckable = 1
        LibDD:UIDropDownMenu_AddButton(info, level)

        LibDD:UIDropDownMenu_AddSeparator(level)

        for _,p in ipairs(dbProfiles) do
            info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = GetProfileNameText(p)
            info.value = p
            info.checked = function ()
                    return (p == LM.Options.db:GetCurrentProfile())
                end
            info.keepShownOnClick = 1
            info.func = ClickSetProfile

            LibDD:UIDropDownMenu_AddButton(info, level)
        end

        LibDD:UIDropDownMenu_AddSeparator(level)

        info = LibDD:UIDropDownMenu_CreateInfo()
        info.text = L.LM_RESET_PROFILE
        info.notCheckable = 1
        info.func = ClickResetProfile
        LibDD:UIDropDownMenu_AddButton(info, level)

        info = LibDD:UIDropDownMenu_CreateInfo()
        info.text = L.LM_NEW_PROFILE
        info.value = 'NEW'
        info.notCheckable = 1
        info.hasArrow = 1
        LibDD:UIDropDownMenu_AddButton(info, level)

        info = LibDD:UIDropDownMenu_CreateInfo()
        info.text = L.LM_DELETE_PROFILE
        info.value = 'DELETE'
        info.notCheckable = 1
        info.hasArrow = 1
        LibDD:UIDropDownMenu_AddButton(info, level)

        LibDD:UIDropDownMenu_AddSeparator(level)

        info = LibDD:UIDropDownMenu_CreateInfo()
        info.text = L.LM_EXPORT_PROFILE
        info.value = 'EXPORT'
        info.notCheckable = 1
        info.hasArrow = 1
        LibDD:UIDropDownMenu_AddButton(info, level)

        info = LibDD:UIDropDownMenu_CreateInfo()
        info.text = L.LM_IMPORT_PROFILE
        info.value = 'IMPORT'
        info.notCheckable = 1
        info.func = ClickImportProfile
        LibDD:UIDropDownMenu_AddButton(info, level)

    elseif level == 2 then
        if L_UIDROPDOWNMENU_MENU_VALUE == 'DELETE' then
            tDeleteItem(dbProfiles, "Default")
            tDeleteItem(dbProfiles, currentProfile)

            for _, p in ipairs(dbProfiles) do
                info = LibDD:UIDropDownMenu_CreateInfo()
                info.text = GetProfileNameText(p)
                info.arg1 = p
                info.notCheckable = 1
                info.func = ClickDeleteProfile
                LibDD:UIDropDownMenu_AddButton(info, level)
            end
        elseif L_UIDROPDOWNMENU_MENU_VALUE == 'NEW' then
            info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = L.LM_CURRENT_SETTINGS
            info.notCheckable = 1
            info.arg1 = currentProfile
            info.func = ClickNewProfile
            LibDD:UIDropDownMenu_AddButton(info, level)

            info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = L.LM_DEFAULT_SETTINGS
            info.notCheckable = 1
            info.func = ClickNewProfile
            LibDD:UIDropDownMenu_AddButton(info, level)
        elseif L_UIDROPDOWNMENU_MENU_VALUE == 'EXPORT' then
            for _, p in ipairs(dbProfiles) do
                info = LibDD:UIDropDownMenu_CreateInfo()
                info.text = GetProfileNameText(p)
                info.arg1 = p
                info.notCheckable = 1
                info.func = ClickExportProfile
                LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end
end

local function UpdateProfileCallback()
    local currentProfile = LM.Options.db:GetCurrentProfile()
    LiteMountProfileButton:SetText(GetProfileNameText(currentProfile))
end


LiteMountProfileButtonMixin = {}

function LiteMountProfileButtonMixin:OnClick()
    LibDD:ToggleDropDownMenu(1, nil, self.DropDown, self, 74, 15)
end

function LiteMountProfileButtonMixin:Attach(parent)
    self:SetParent(parent)
    self:ClearAllPoints()
    self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -32, -12)
    self:Show()
end

function LiteMountProfileButtonMixin:OnShow()
    UpdateProfileCallback()
    LM.Options.db.RegisterCallback(self, "OnProfileCopied", UpdateProfileCallback)
    LM.Options.db.RegisterCallback(self, "OnProfileChanged", UpdateProfileCallback)
    LM.Options.db.RegisterCallback(self, "OnProfileReset", UpdateProfileCallback)
end

function LiteMountProfileButtonMixin:OnHide()
    LM.Options.db.UnregisterAllCallbacks(self)
end

function LiteMountProfileButtonMixin:OnLoad()
    LibDD:Create_UIDropDownMenu(self.DropDown)
    LibDD:UIDropDownMenu_Initialize(self.DropDown, DropDown_Initialize, "MENU")
end

