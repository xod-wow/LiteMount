--[[----------------------------------------------------------------------------

  LiteMount/UI/ProfileImportExport.lua

  A frame to export/import profiles.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[ Export  ---------------------------------------------------------------]]--

local function PositionAtCursor(frame)
    local x, y = GetCursorPosition()
    frame:ClearAllPoints()
    x = x / frame:GetEffectiveScale()
    y = y / frame:GetEffectiveScale()

    -- Try to position so the bottom right button is under the cursor
    frame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMLEFT", x+64, y-16)
    frame:Raise()
end

LiteMountProfileExportMixin = {}

function LiteMountProfileExportMixin:ExportProfile(profileName)
    profileName = profileName or 'Default'
    self.Title:SetText('LiteMount : Export Profile : ' .. profileName)

    local text = LM.Options:ExportProfile(profileName)
    self.Scroll.EditBox:SetText(text)
    self.Scroll.EditBox:HighlightText()

    self:Show()
    PositionAtCursor(self)
end

function LiteMountProfileExportMixin:OnLoad()
    LiteMountOptionsPanel_AutoLocalize(self)
    self.OkayButton:SetScript('OnClick', function () self:Hide() end)
    self.Scroll.EditBox:SetScript('OnEscapePressed', function () self:Hide() end)
    self.Scroll.EditBox:SetAutoFocus(true)
end

--[[ Import  ---------------------------------------------------------------]]--

LiteMountProfileImportMixin = {}

function LiteMountProfileImportMixin:ImportProfile()
    local profileName = self.ProfileName:GetText()
    local profileData = self.ProfileData:GetText()

    local ok = LM.Options:ImportProfile(profileName, profileData)
    if ok then
        self:Hide()
    end
end

function LiteMountProfileImportMixin:OnShow()
    PositionAtCursor(self)
    self.ProfileName:SetText("")
    self.ProfileData:SetText("")
end

function LiteMountProfileImportMixin:OnLoad()
    LiteMountOptionsPanel_AutoLocalize(self)
    self.Title:SetText("LiteMount : " .. L.LM_IMPORT_PROFILE)
    self.ImportButton:Disable()
    self.ProfileName:SetMaxLetters(24)
    self.ProfileName.nextEditBox = self.ProfileData
    self.ProfileData.nextEditBox = self.ProfileName
end

function LiteMountProfileImportMixin:UpdateImportButton()
    local profileName = self.ProfileName:GetText()
    local profileData = self.ProfileData:GetText()

    if profileName ~= "" and
      profileName ~= LM.Options.db:GetCurrentProfile() and
      LM.Options:DecodeProfileData(profileData) then
        self.ImportButton:Enable()
    else
        self.ImportButton:Disable()
    end
end

--@debug@

--[[ Inspect ---------------------------------------------------------------]]--

local Serializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

LiteMountProfileInspectMixin = {}

function LiteMountProfileInspectMixin:Apply()
    local text = self.ProfileData:GetText()
    if not text then return end

    local decoded = LibDeflate:DecodeForPrint(text)
    if not decoded then return end

    local deflated = LibDeflate:DecompressDeflate(decoded)
    if not deflated then return end

    local isValid, data = Serializer:Deserialize(deflated)
    if not isValid then return end

    self.Scroll.EditBox:SetText(LM.TableToString({ LiteMountDB = data }))
end

--@end-debug@
