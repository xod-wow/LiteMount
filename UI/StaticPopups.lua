
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
            LiteMountOptionsMounts.refresh()
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
            LiteMountOptionsMounts.refresh()
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
            LiteMountOptionsMounts.refresh()
        end,
}
