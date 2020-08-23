--[[----------------------------------------------------------------------------

  LiteMount/UI/CombatMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LiteMountCombatMacroEditBoxMixin = {}

function LiteMountCombatMacroEditBoxMixin:OnTextChanged(userInput)
    local c = strlen(self:GetText() or "")
    self:GetParent().Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end

function LiteMountCombatMacroEditBoxMixin:GetOption()
    return LM.Options:GetCombatMacro() or ""
end

function LiteMountCombatMacroEditBoxMixin:GetOptionDefault()
    return LM.Actions:DefaultCombatMacro()
end

function LiteMountCombatMacroEditBoxMixin:SetOption(v)
    LM.Options:SetCombatMacro(v)
    LiteMount:Refresh()
end

function LiteMountCombatMacroEditBoxMixin:OnLoad()
end

--[[--------------------------------------------------------------------------]]--

LiteMountCombatMacroEnableButtonMixin = {}

function LiteMountCombatMacroEnableButtonMixin:GetOption()
    return LM.Options:GetUseCombatMacro()
end

function LiteMountCombatMacroEnableButtonMixin:GetOptionDefault()
    return false
end

function LiteMountCombatMacroEnableButtonMixin:SetOption(v)
    LM.Options:SetUseCombatMacro(v or false)
    LiteMount:Refresh()
end

--[[--------------------------------------------------------------------------]]--

LiteMountCombatMacroPanelMixin = {}

function LiteMountCombatMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. COMBAT

    self.EditBoxContainer:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    self.EditBoxContainer:SetBackdropColor(0, 0, 0, 0.5)

    LiteMountOptionsPanel_RegisterControl(self.EditBox)
    LiteMountOptionsPanel_RegisterControl(self.EnableButton)

    LiteMountOptionsPanel_OnLoad(self)
end
