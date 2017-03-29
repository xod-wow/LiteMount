--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/CombatMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_OptionsUICombatMacro_OnLoad(self)
    self.name = MACRO .. " : " .. COMBAT
    LM_OptionsUIPanel_OnLoad(self)
end

function LM_OptionsUICombatMacro_OnTextChanged(self)
    local c = strlen(self:GetText() or "")
    LM_OptionsUICombatMacroCount:SetText(format(MACROFRAME_CHAR_LIMIT, c))
end
