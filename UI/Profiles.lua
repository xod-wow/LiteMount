--[[----------------------------------------------------------------------------

  LiteMount/UI/Profiles.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local LibDD = LibStub("LibUIDropDownMenu-4.0")

--[[------------------------------------------------------------------------]]--

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
                LM.db:SetProfile(text)
                if self.data then
                    LM.db:CopyProfile(self.data)
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
            if text ~= "" and not LM.db.profiles[text] then
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
            LM.db:DeleteProfile(self.data)
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
            LM.db:ResetProfile(self.data)
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
    LM.db:SetProfile(self.value)
    LibDD:UIDropDownMenu_RefreshAll(L_UIDROPDOWNMENU_OPEN_MENU, true)
end

local function ClickNewProfile(self, arg1, arg2, check)
    StaticPopup_Show("LM_OPTIONS_NEW_PROFILE", arg1, nil, arg1)
end

local function ClickDeleteProfile(self, arg1, arg2, check)
    StaticPopup_Show("LM_OPTIONS_DELETE_PROFILE", arg1, nil, arg1)
end

local function ClickResetProfile(self)
    local arg1 = LM.db:GetCurrentProfile()
    StaticPopup_Show("LM_OPTIONS_RESET_PROFILE", arg1, nil, arg1)
end

local function ClickExportProfile(self, arg1, arg2, check)
    LiteMountProfileExport:SetProfile(arg1)
    LiteMountOptionsPanel_PopOver(LiteMountProfilesPanel, LiteMountProfileExport)
end

local function ClickImportProfile(self, arg1, arg2, check)
    LiteMountOptionsPanel_PopOver(LiteMountProfilesPanel, LiteMountProfileImport)
end

--[[------------------------------------------------------------------------]]--

-- function lib:ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)

local function OnClick(self)
    local dropDown = self:GetParent().DropDown
    LibDD:UIDropDownMenu_Initialize(dropDown, self.Initialize, "MENU")
    LibDD:UIDropDownMenu_SetAnchor(dropDown, 0, 8, "TOP", self, "BOTTOM")
    LibDD:ToggleDropDownMenu(1, nil, dropDown, self)
end

local function OnShow(self)
    local parent = self:GetParent()
end

--[[------------------------------------------------------------------------]]--

local ChangeProfileMixin = {}

function ChangeProfileMixin.Initialize(dropDown, level)
    local currentProfile = LM.db:GetCurrentProfile()
    local dbProfiles = LM.db:GetProfiles() or {}
    tDeleteItem(dbProfiles, "Default")
    sort(dbProfiles)
    tinsert(dbProfiles, 1, "Default")

    if level == 1 then

        for _,p in ipairs(dbProfiles) do
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = GetProfileNameText(p)
            info.value = p
            info.checked = function ()
                    return (p == LM.db:GetCurrentProfile())
                end
            info.keepShownOnClick = 1
            info.func = ClickSetProfile

            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end


--[[------------------------------------------------------------------------]]--

local NewProfileMixin = {}

function NewProfileMixin.Initialize(dropDown, level)
    if level == 1 then
        local currentProfile = LM.db:GetCurrentProfile()
        local info = LibDD:UIDropDownMenu_CreateInfo()
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
    end
end

--[[------------------------------------------------------------------------]]--

local DeleteProfileMixin = {}

function DeleteProfileMixin.Initialize(dropDown, level)
    if level == 1 then
        local currentProfile = LM.db:GetCurrentProfile()
        local dbProfiles = LM.db:GetProfiles() or {}
        tDeleteItem(dbProfiles, "Default")
        tDeleteItem(dbProfiles, currentProfile)

        for _, p in ipairs(dbProfiles) do
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = GetProfileNameText(p)
            info.arg1 = p
            info.notCheckable = 1
            info.func = ClickDeleteProfile
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[------------------------------------------------------------------------]]--

local ExportProfileMixin = {}

function ExportProfileMixin.Initialize(dropDown, level)
    local dbProfiles = LM.db:GetProfiles() or {}
    for _, p in ipairs(dbProfiles) do
        local info = LibDD:UIDropDownMenu_CreateInfo()
        info.text = GetProfileNameText(p)
        info.arg1 = p
        info.notCheckable = 1
        info.func = ClickExportProfile
        LibDD:UIDropDownMenu_AddButton(info, level)
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountProfilesPanelMixin = {}

function LiteMountProfilesPanelMixin:OnRefresh()
    local currentProfile = LM.db:GetCurrentProfile()
    self.CurrentProfile:SetText(currentProfile)
end

function LiteMountProfilesPanelMixin:OnShow()
    LM.db.RegisterCallback(self, "OnProfileCopied", "OnRefresh")
    LM.db.RegisterCallback(self, "OnProfileChanged", "OnRefresh")
    LM.db.RegisterCallback(self, "OnProfileReset", "OnRefresh")
end

function LiteMountProfilesPanelMixin:OnHide()
    LM.db.UnregisterAllCallbacks(self)
end

function LiteMountProfilesPanelMixin:OnLoad()

    self.name = L.LM_PROFILES

    LibDD:Create_UIDropDownMenu(self.DropDown)

    self.CurrentProfileLabel:SetText(L.LM_CURRENT_PROFILE .. " :")

    Mixin(self.ChangeProfile, ChangeProfileMixin)
    self.ChangeProfile:SetScript("OnShow", OnShow)
    self.ChangeProfile:SetScript("OnClick", OnClick)

    self.ResetProfile:SetScript("OnClick", ClickResetProfile)

    Mixin(self.NewProfile, NewProfileMixin)
    self.NewProfile:SetScript("OnShow", OnShow)
    self.NewProfile:SetScript("OnClick", OnClick)

    Mixin(self.DeleteProfile, DeleteProfileMixin)
    self.DeleteProfile:SetScript("OnShow", OnShow)
    self.DeleteProfile:SetScript("OnClick", OnClick)

    Mixin(self.ExportProfile, ExportProfileMixin)
    self.ExportProfile:SetScript("OnShow", OnShow)
    self.ExportProfile:SetScript("OnClick", OnClick)

    self.ImportProfile:SetScript("OnClick", ClickImportProfile)

    LiteMountOptionsPanel_OnLoad(self)
end
