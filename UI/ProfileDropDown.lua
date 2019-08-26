--[[----------------------------------------------------------------------------

  LiteMount/UI/ProfileDropDown.lua

  Attachable profile-switching button.

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local function ClickSetProfile(self, arg1, arg2, checked)
    LM_Options.db:SetProfile(self.value)
    UIDropDownMenu_RefreshAll(LiteMountProfileDropDown, true)
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

function LiteMountProfileDropDown_Initialize(self, level)
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
    LiteMountProfileButton:SetText(LM_Options.db:GetCurrentProfile())
end

function LiteMountProfileDropDown_Attach(parent)
    local self = LiteMountProfileButton
    self:SetParent(parent)
    self:ClearAllPoints()
    self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -32, -12)
    self:Show()
end

function LiteMountProfileDropDown_OnShow(self)
    self:SetText(LM_Options.db:GetCurrentProfile())
    LM_Options.db.RegisterCallback(self, "OnProfileCopied", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileChanged", UpdateProfileCallback)
    LM_Options.db.RegisterCallback(self, "OnProfileReset", UpdateProfileCallback)
end

function LiteMountProfileDropDown_OnHide(self)
    LM_Options.db.UnregisterAllCallbacks(self)
end

function LiteMountProfileDropDown_OnLoad(self)
    UIDropDownMenu_Initialize(self, LiteMountProfileDropDown_Initialize, "MENU")
end

