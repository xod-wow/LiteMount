--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

function OnTextChanged(self, userInput)
    local c = strlen(self:GetText() or "")
    self:GetParent().Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end

LiteMountMacroPanelMixin = {}

function LiteMountMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. UNAVAILABLE

    self.EditBox.SetOption =
        function (self, v) LM_Options:SetUnavailableMacro(v) end
    self.EditBox.GetOption =
        function (self) return LM_Options:GetUnavailableMacro() or "" end
    self.EditBox.GetOptionDefault =
        function (self) return "" end
    LiteMountOptionsPanel_RegisterControl(self.EditBox)

    self.EditBox:SetScript("OnTextChanged", OnTextChanged)
    self.DeleteButton:SetScript("OnClick",
            function () self.EditBox:SetOption("") end)
    self.RevertButton:SetScript("OnClick",
            function () LiteMountOptionsPanel_Revert(self) end)
    LiteMountOptionsPanel_OnLoad(self)
end
