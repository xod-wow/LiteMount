--[[----------------------------------------------------------------------------

  LiteMount/UI/Profiles.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

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

local function ClickResetProfile(self)
    local arg1 = LM.db:GetCurrentProfile()
    StaticPopup_Show("LM_OPTIONS_RESET_PROFILE", arg1, nil, arg1)
end

local function ClickImportProfile(self, arg1, arg2, check)
    LiteMountOptionsPanel_PopOver(LiteMountProfilesPanel, LiteMountProfileImport)
end


--[[------------------------------------------------------------------------]]--

local ChangeProfileMixin = {}

function ChangeProfileMixin.Generate(owner, rootDescription)
    local currentProfile = LM.db:GetCurrentProfile()
    local dbProfiles = LM.db:GetProfiles() or {}
    tDeleteItem(dbProfiles, "Default")
    sort(dbProfiles)
    tinsert(dbProfiles, 1, "Default")

    for i,p in ipairs(dbProfiles) do
        local function IsSelected() return p == currentProfile end
        local function SetSelected() LM.db:SetProfile(p) end
        rootDescription:CreateRadio(GetProfileNameText(p), IsSelected, SetSelected, i)
    end
end


--[[------------------------------------------------------------------------]]--

local NewProfileMixin = {}

function NewProfileMixin.Generate(owner, rootDescription)
    local currentProfile = LM.db:GetCurrentProfile()

    local function OnClick(data)
        StaticPopup_Show("LM_OPTIONS_NEW_PROFILE", data, nil, data)
    end

    rootDescription:CreateButton(L.LM_CURRENT_SETTINGS, OnClick, currentProfile)
    rootDescription:CreateButton(L.LM_DEFAULT_SETTINGS, OnClick)
end

--[[------------------------------------------------------------------------]]--

local DeleteProfileMixin = {}

function DeleteProfileMixin.Generate(owner, rootDescription)
    local currentProfile = LM.db:GetCurrentProfile()
    local dbProfiles = LM.db:GetProfiles() or {}
    tDeleteItem(dbProfiles, "Default")
    tDeleteItem(dbProfiles, currentProfile)

    local function OnClick(data)
        StaticPopup_Show("LM_OPTIONS_DELETE_PROFILE", data, nil, data)
    end

    for _, p in ipairs(dbProfiles) do
        rootDescription:CreateButton(GetProfileNameText(p), OnClick, p)
    end
end

--[[------------------------------------------------------------------------]]--

local ExportProfileMixin = {}

function ExportProfileMixin.Generate(owner, rootDescription)
    local dbProfiles = LM.db:GetProfiles() or {}

    local function OnClick(data)
        LiteMountProfileExport:SetProfile(data)
        LiteMountOptionsPanel_PopOver(LiteMountProfilesPanel, LiteMountProfileExport)
    end

    for _, p in ipairs(dbProfiles) do
        rootDescription:CreateButton(p, OnClick, p)
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

    self.CurrentProfileLabel:SetText(L.LM_CURRENT_PROFILE .. " :")

    local function OnClick(self)
        MenuUtil.CreateContextMenu(self, self.Generate)
    end

    Mixin(self.ChangeProfile, ChangeProfileMixin)
    self.ChangeProfile:SetScript("OnClick", OnClick)

    self.ResetProfile:SetScript("OnClick", ClickResetProfile)

    Mixin(self.NewProfile, NewProfileMixin)
    self.NewProfile:SetScript("OnClick", OnClick)

    Mixin(self.DeleteProfile, DeleteProfileMixin)
    self.DeleteProfile:SetScript("OnClick", OnClick)

    Mixin(self.ExportProfile, ExportProfileMixin)
    self.ExportProfile:SetScript("OnClick", OnClick)

    self.ImportProfile:SetScript("OnClick", ClickImportProfile)

    LiteMountOptionsPanel_OnLoad(self)
end
