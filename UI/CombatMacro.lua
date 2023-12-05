--[[----------------------------------------------------------------------------

  LiteMount/UI/CombatMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LiteMountCombatMacroEditBoxMixin = {}

function LiteMountCombatMacroEditBoxMixin:OnTextChanged(userInput)
    local c = strlen(self:GetText() or "")
    self:GetParent().Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end

function LiteMountCombatMacroEditBoxMixin:GetOption()
    return LM.Options:GetOption('combatMacro') or ""
end

function LiteMountCombatMacroEditBoxMixin:GetOptionDefault()
    return LM.Actions:DefaultCombatMacro()
end

function LiteMountCombatMacroEditBoxMixin:SetOption(v)
    LM.Options:SetOption('combatMacro', v)
end

function LiteMountCombatMacroEditBoxMixin:OnLoad()
end

--[[------------------------------------------------------------------------]]--

LiteMountCombatMacroEnableButtonMixin = {}

function LiteMountCombatMacroEnableButtonMixin:GetOption()
    return LM.Options:GetOption('useCombatMacro')
end

function LiteMountCombatMacroEnableButtonMixin:GetOptionDefault()
    return LM.Options:GetOptionDefault('useCombatMacro')
end

function LiteMountCombatMacroEnableButtonMixin:SetOption(v)
    LM.Options:SetOption('useCombatMacro', v and true or false)
end

--[[------------------------------------------------------------------------]]--

LiteMountCombatMacroPanelMixin = {}

function LiteMountCombatMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. COMBAT

    LiteMountOptionsPanel_RegisterControl(self.EditBox)
    LiteMountOptionsPanel_RegisterControl(self.EnableButton)

    LiteMountOptionsPanel_OnLoad(self)
end
