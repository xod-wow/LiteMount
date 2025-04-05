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
    return LM.Options:GetOption('useCombatMacro')[self:GetID()]
end

function LiteMountCombatMacroEnableButtonMixin:GetOptionDefault()
    return LM.Options:GetOptionDefault('useCombatMacro')[self:GetID()]
end

function LiteMountCombatMacroEnableButtonMixin:SetOption(v)
    v = v and true or nil
    local opt = LM.Options:GetOption('useCombatMacro')
    opt[self:GetID()] = v
    LM.Options:SetOption('useCombatMacro', opt)
end

--[[------------------------------------------------------------------------]]--

LiteMountCombatMacroPanelMixin = {}

function LiteMountCombatMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. COMBAT

    LiteMountOptionsPanel_RegisterControl(self.EditBox)

    for i, b in ipairs(self.EnableButton) do
        b.Text:SetText(i)
        if i == 1 then
            b:SetPoint("LEFT", self.Enable, "RIGHT", 8, 0)
        else
            b:SetPoint("LEFT", self.EnableButton[i-1], "RIGHT", 24, 0)
        end
        LiteMountOptionsPanel_RegisterControl(b)
    end

    LiteMountOptionsPanel_OnLoad(self)
end
