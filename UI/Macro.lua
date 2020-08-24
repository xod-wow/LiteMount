--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LiteMountMacroEditBoxMixin = {}

function LiteMountMacroEditBoxMixin:OnTextChanged(userInput)
    local c = strlen(self:GetText() or "")
    self:GetParent().Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end

function LiteMountMacroEditBoxMixin:GetOption()
    return LM.Options:GetUnavailableMacro() or ""
end
function LiteMountMacroEditBoxMixin:GetOptionDefault()
    return ""
end

function LiteMountMacroEditBoxMixin:SetOption(v)
    LM.Options:SetUnavailableMacro(v)
end

--[[--------------------------------------------------------------------------]]--

LiteMountMacroPanelMixin = {}

function LiteMountMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. UNAVAILABLE

    LiteMountOptionsPanel_RegisterControl(self.EditBox)

    self.DeleteButton:SetScript("OnClick",
            function () self.EditBox:SetOption("") end)
    LiteMountOptionsPanel_OnLoad(self)
end
