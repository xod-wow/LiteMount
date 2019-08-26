
--[[----------------------------------------------------------------------------

  LiteMount/UI/StaticPopups.lua

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

StaticPopupDialogs["LM_OPTIONS_NEW_FLAG"] = {
    text = format("LiteMount : %s", L.LM_NEW_FLAG),
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
            if LM_Options:IsValidFlagName(text) then
                LM_Options:CreateFlag(text)
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
            if LM_Options:IsValidFlagName(text) then
                self:GetParent().button1:Enable()
            else
                self:GetParent().button1:Disable()
            end
        end,
    OnShow = function (self)
        self.editBox:SetFocus()
    end,
    OnHide = function (self)
            LiteMountMounts.refresh()
        end,
}

StaticPopupDialogs["LM_OPTIONS_DELETE_FLAG"] = {
    text = format("LiteMount : %s", L.LM_DELETE_FLAG),
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            LM_Options:DeleteFlag(self.data)
        end,
    OnShow = function (self)
            self.text:SetText(format("LiteMount : %s : %s", L.LM_DELETE_FLAG, self.data))
        end,
    OnHide = function (self)
            LiteMountMounts.refresh()
        end,
}

StaticPopupDialogs["LM_OPTIONS_RENAME_FLAG"] = {
    text = format("LiteMount : %s", L.LM_RENAME_FLAG),
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
            if LM_Options:IsValidFlagName(text) then
                LM_Options:RenameFlag(self.data, text)
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
            if LM_Options:IsValidFlagName(text) then
                self:GetParent().button1:Enable()
            else
                self:GetParent().button1:Disable()
            end
        end,
    OnShow = function (self)
            self.text:SetText(format("LiteMount : %s : %s", L.LM_RENAME_FLAG, self.data))
            self.editBox:SetFocus()
        end,
    OnHide = function (self)
            LiteMountMounts.refresh()
        end,
}

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
            LiteMountMounts.refresh()
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
            LiteMountMounts.refresh()
        end,
}
