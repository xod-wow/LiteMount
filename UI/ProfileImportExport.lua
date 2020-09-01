--[[----------------------------------------------------------------------------

  LiteMount/UI/ProfileImportExport.lua

  A frame to export/import profiles.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--[[ Export  ---------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local function PositionAtCursor(frame)
    local x, y = GetCursorPosition()
    frame:ClearAllPoints()
    x = x / frame:GetEffectiveScale();
    y = y / frame:GetEffectiveScale();

    -- Try to position so the bottom right button is under the cursor
    frame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMLEFT", x+64, y-16)
    frame:Raise();
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

--[[ Inspect ---------------------------------------------------------------]]--

local function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil else return a[i], t[a[i]] end
    end
    return iter
end

local function dump(o,indent)
    indent = indent or 0
    local pad = string.rep('  ', indent)
    local pad2 = string.rep('  ', indent+1)

    if type(o) == 'table' then
        local s = '{\n'

        for k,v in pairsByKeys(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. pad2 .. '['..k..'] = ' .. dump(v, indent+1) .. ',\n'
        end

        return s .. pad .. '}\n'
    else
        if type(o) == 'string' then
            return '"' .. tostring(o) .. '"'
        else
            return tostring(o)
        end
    end
end

LiteMountProfileInspectMixin = {}

function LiteMountProfileInspectMixin:Apply()
    local text = self.ProfileData:GetText()
    local data = LM.Options:DecodeProfileData(text)
    self.Scroll.EditBox:SetText(dump(data))
end
