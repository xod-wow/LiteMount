--[[----------------------------------------------------------------------------

  LiteMount/UI/ProfileImportExport.lua

  A frame to export/import profiles.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--[[ Export  ---------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LiteMountProfileExportMixin = {}

function LiteMountProfileExportMixin:ExportProfile(profileName)
    profileName = profileName or 'Default'

    self.Title:SetText('LiteMount : Export Profile: ' .. profileName)

    local text = LM.Options:ExportProfile(profileName)
    self.Scroll.EditBox:SetText(text)
    self.Scroll.EditBox:HighlightText()
    self:Show()
end

function LiteMountProfileExportMixin:OnShow()
    self.Scroll.EditBox:SetWidth(self.Scroll:GetWidth() - 18)
end

function LiteMountProfileExportMixin:OnLoad()
    tinsert(UISpecialFrames, self:GetName())
end

--[[ Import  ---------------------------------------------------------------]]--

LiteMountProfileImportMixin = {}

function LiteMountProfileImportMixin:ImportProfile()
    local profileName = self.ProfileName:GetText()
    local profileData = self.ProfileData:GetText()
    LM.Options:ImportProfile(profileName, profileData)
end

function LiteMountProfileImportMixin:OnLoad()
    self.Title:SetText(L.LM_NEW_PROFILE)
    self.ProfileNameText:SetText(L.LM_NEW_PROFILE)
end

