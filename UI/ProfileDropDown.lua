--[[----------------------------------------------------------------------------

  LiteMount/UI/ProfileDropDown.lua

  Attachable profile-switching button.

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

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
    UIDropDownMenu_RefreshAll(LiteMountOptionsProfileDropDown, true)
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

function LiteMountOptionsProfileDropDown_Initialize(self, level)
    local info

    if level == nil then return end

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

        if _G.C_Map then
            UIDropDownMenu_AddSeparator(level)
        else
            UIDropDownMenu_AddSeparator(info, level)
        end

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

        if _G.C_Map then
            UIDropDownMenu_AddSeparator(level)
        else
            UIDropDownMenu_AddSeparator(info, level)
        end

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

local function UpdateProfileCallback(self)
    LiteMountOptionsProfileButton:SetText(LM_Options.db:GetCurrentProfile())
end

function LiteMountOptionsProfileDropDown_Attach(parent)
    local self = LiteMountOptionsProfileButton
    self:SetParent(parent)
    self:ClearAllPoints()
    self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -32, -12)
    self:Show()
end

function LiteMountOptionsProfileDropDown_OnShow(self)
    self:SetText(LM_Options.db:GetCurrentProfile())
    LM_Options.db.RegisterCallback(self, "OnProfileCopied", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileChanged", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileReset", UpdateProfileCallback)
end

function LiteMountOptionsProfileDropDown_OnHide(self)
    LM_Options.db.UnregisterAllCallbacks(self)
end

function LiteMountOptionsProfileDropDown_OnLoad(self)
    UIDropDownMenu_Initialize(self, LiteMountOptionsProfileDropDown_Initialize, "MENU")
end

