--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

LiteMountMacroEditBoxMixin = {}

function LiteMountMacroEditBoxMixin:OnTextChanged(userInput)
    local c = strlen(self:GetText() or "")
    self:GetParent().Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end

function LiteMountMacroEditBoxMixin:GetOption()
    return LM_Options:GetUnavailableMacro() or ""
end
function LiteMountMacroEditBoxMixin:GetOptionDefault()
    return ""
end

function LiteMountMacroEditBoxMixin:SetOption(userInput)
    LM_Options:SetUnavailableMacro(v)
end

--[[--------------------------------------------------------------------------]]--

LiteMountMacroPanelMixin = {}

function LiteMountMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. UNAVAILABLE

    self.EditBoxContainer:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    self.EditBoxContainer:SetBackdropColor(0, 0, 0, 0.5)

    LiteMountOptionsPanel_RegisterControl(self.EditBox)

    self.EditBox:SetScript("OnTextChanged", OnTextChanged)
    self.DeleteButton:SetScript("OnClick",
            function () self.EditBox:SetOption("") end)
    self.RevertButton:SetScript("OnClick",
            function () LiteMountOptionsPanel_Revert(self) end)
    LiteMountOptionsPanel_OnLoad(self)
end
