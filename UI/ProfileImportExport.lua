--[[----------------------------------------------------------------------------

  LiteMount/UI/ProfileImportExport.lua

  A frame to export/import profiles.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[ Export  ---------------------------------------------------------------]]--

LiteMountProfileExportMixin = {}

function LiteMountProfileExportMixin:SetProfile(profileName)
    self.profileName = profileName
end

function LiteMountProfileExportMixin:OnShow()
    local text = LM.Options:ExportProfile(self.profileName or 'Default')
    self.Scroll:SetText(text)
    self.Scroll.ScrollBox.EditBox:HighlightText()
    self.profileName = nil
end

function LiteMountProfileExportMixin:OnLoad()
    LiteMountOptionsPanel_AutoLocalize(self)
    self.OkayButton:SetScript('OnClick', function () self:UnPop() end)
    self.Scroll.ScrollBox.EditBox:SetScript('OnEscapePressed', function () self:UnPop() end)
    self.Scroll.ScrollBox.EditBox:SetAutoFocus(true)
    ScrollUtil.RegisterScrollBoxWithScrollBar(self.Scroll.ScrollBox, self.ScrollBar)
end

--[[ Import  ---------------------------------------------------------------]]--

LiteMountProfileImportMixin = {}

function LiteMountProfileImportMixin:ImportProfile()
    local profileName = self.ProfileName:GetText()
    local profileData = self.ProfileData:GetText()

    local ok = LM.Options:ImportProfile(profileName, profileData)
    if ok then
        self:UnPop()
    end
end

function LiteMountProfileImportMixin:OnShow()
    self.ProfileName:SetText("")
    self.ProfileData:SetText("")
end

function LiteMountProfileImportMixin:OnLoad()
    LiteMountOptionsPanel_AutoLocalize(self)
    self.ImportButton:Disable()
    self.ProfileName:SetMaxLetters(24)
    self.ProfileName.nextEditBox = self.ProfileData
    self.ProfileData.nextEditBox = self.ProfileName
end

function LiteMountProfileImportMixin:UpdateImportButton()
    local profileName = self.ProfileName:GetText()
    local profileData = self.ProfileData:GetText()

    if profileName ~= "" and
      profileName ~= LM.db:GetCurrentProfile() and
      LM.Options:DecodeProfileData(profileData) then
        self.ImportButton:Enable()
    else
        self.ImportButton:Disable()
    end
end

--[[ Inspect ---------------------------------------------------------------]]--

--@debug@

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

    self.Scroll:SetText(LM.TableToString({ LiteMountDB = data }))
end

--@end-debug@
